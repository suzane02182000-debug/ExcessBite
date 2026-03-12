from flask import Blueprint, render_template, request, jsonify, flash, redirect, url_for, current_app
from flask_login import login_required, current_user
from app.models import db, Donation, FoodRequest, Notification, DonationStatus, Role, Feedback, FeedbackType, Delivery, User
from app.decorators import role_required
from datetime import datetime, timedelta
import json

donor_bp = Blueprint('donor', __name__, url_prefix='/donor')

@donor_bp.route('/dashboard')
@role_required(Role.DONOR)
def dashboard():
    """Donor dashboard"""
    donations = Donation.query.filter_by(donor_id=current_user.id).order_by(Donation.created_at.desc()).all()
    
    stats = {
        'total_donations': len(donations),
        'pending': sum(1 for d in donations if d.status == DonationStatus.PENDING),
        'approved': sum(1 for d in donations if d.approved_at is not None),  # Count donations ever approved by admin
        'delivered': sum(1 for d in donations if d.status == DonationStatus.DELIVERED),
        'cancelled': sum(1 for d in donations if d.status == DonationStatus.CANCELLED),
        'total_packets': sum(d.quantity for d in donations)
    }
    
    return render_template('donor/dashboard.html', donations=donations, stats=stats)

@donor_bp.route('/listing/create', methods=['GET', 'POST'])
@role_required(Role.DONOR)
def create_listing():
    """Create new food listing"""
    if request.method == 'POST':
        data = request.form
        
        errors = []
        
        if not data.get('food_type'):
            errors.append('Food type is required')
        if not data.get('quantity'):
            errors.append('Quantity is required')
        try:
            quantity = int(data.get('quantity', 0))
            if quantity <= 0:
                errors.append('Quantity must be greater than 0')
        except:
            errors.append('Invalid quantity')
        
        if not data.get('expiry_time'):
            errors.append('Expiry time is required')
        
        if not data.get('pickup_date'):
            errors.append('Pickup date is required')
        
        if not data.get('pickup_address'):
            errors.append('Pickup address is required')
        
        if not data.get('latitude') or not data.get('longitude'):
            errors.append('Location coordinates are required')
        
        if errors:
            return render_template('donor/create_listing.html', errors=errors, donor=current_user, google_maps_key=current_app.config['GOOGLE_MAPS_KEY']), 400
        
        try:
            donation = Donation(
                donor_id=current_user.id,
                food_type=data.get('food_type'),
                description=data.get('description', ''),
                quantity=int(data.get('quantity')),
                unit=data.get('unit', 'packets'),
                expiry_time=datetime.fromisoformat(data.get('expiry_time')),
                pickup_date=datetime.strptime(data.get('pickup_date'), '%Y-%m-%d').date(),
                pickup_start_time=datetime.strptime(data.get('pickup_start_time'), '%H:%M').time(),
                pickup_end_time=datetime.strptime(data.get('pickup_end_time'), '%H:%M').time(),
                pickup_address=data.get('pickup_address'),
                latitude=float(data.get('latitude')),
                longitude=float(data.get('longitude')),
                city=data.get('city', ''),
                contact_number=current_user.phone,
                status=DonationStatus.PENDING
            )
            
            db.session.add(donation)
            db.session.commit()
            
            # Notify admins
            from app.models import User
            admins = User.query.filter_by(role=Role.ADMIN).all()
            for admin in admins:
                notification = Notification(
                    user_id=admin.id,
                    title='New Food Listing',
                    message=f'{current_user.full_name} posted {data.get("food_type")}',
                    notification_type='donation',
                    related_id=donation.id
                )
                db.session.add(notification)
            
            db.session.commit()
            
            flash('Food listing created successfully and is pending approval', 'success')
            return redirect(url_for('donor.dashboard'))
        
        except Exception as e:
            db.session.rollback()
            flash('Failed to create listing', 'error')
            return render_template('donor/create_listing.html', donor=current_user, google_maps_key=current_app.config['GOOGLE_MAPS_KEY']), 500
    
    return render_template('donor/create_listing.html', donor=current_user, google_maps_key=current_app.config['GOOGLE_MAPS_KEY'])

@donor_bp.route('/listing/<int:listing_id>/edit', methods=['GET', 'POST'])
@role_required(Role.DONOR)
def edit_listing(listing_id):
    """Edit food listing"""
    donation = Donation.query.get_or_404(listing_id)
    
    if donation.donor_id != current_user.id:
        flash('You do not have permission to edit this listing', 'error')
        return redirect(url_for('donor.dashboard'))
    
    if donation.status != DonationStatus.PENDING:
        flash('Can only edit pending listings', 'error')
        return redirect(url_for('donor.dashboard'))
    
    if request.method == 'POST':
        data = request.form
        
        donation.food_type = data.get('food_type', donation.food_type)
        donation.description = data.get('description', donation.description)
        donation.quantity = int(data.get('quantity', donation.quantity))
        donation.expiry_time = datetime.fromisoformat(data.get('expiry_time', donation.expiry_time.isoformat()))
        donation.pickup_address = data.get('pickup_address', donation.pickup_address)
        
        try:
            db.session.commit()
            flash('Listing updated successfully', 'success')
            return redirect(url_for('donor.dashboard'))
        except:
            db.session.rollback()
            flash('Failed to update listing', 'error')
    
    return render_template('donor/edit_listing.html', donation=donation)

@donor_bp.route('/listing/<int:listing_id>/delete', methods=['POST'])
@role_required(Role.DONOR)
def delete_listing(listing_id):
    """Delete food listing"""
    donation = Donation.query.get_or_404(listing_id)
    
    if donation.donor_id != current_user.id:
        return jsonify({'error': 'Unauthorized'}), 403
    
    if donation.status != DonationStatus.PENDING:
        return jsonify({'error': 'Can only delete pending listings'}), 400
    
    try:
        db.session.delete(donation)
        db.session.commit()
        return jsonify({'success': True})
    except:
        db.session.rollback()
        return jsonify({'error': 'Failed to delete'}), 500

@donor_bp.route('/listing/<int:listing_id>')
@role_required(Role.DONOR)
def view_listing(listing_id):
    """View listing details"""
    donation = Donation.query.get_or_404(listing_id)
    
    if donation.donor_id != current_user.id:
        flash('You do not have permission to view this listing', 'error')
        return redirect(url_for('donor.dashboard'))
    
    requests = FoodRequest.query.filter_by(donation_id=listing_id).all()
    delivery = donation.delivery

    # Get existing feedback given by this donor for this delivery
    given_feedback = {}
    if delivery:
        for fb in Feedback.query.filter_by(delivery_id=delivery.id, from_user_id=current_user.id).all():
            given_feedback[fb.feedback_type] = fb

    return render_template('donor/view_listing.html', donation=donation, requests=requests,
                           delivery=delivery, given_feedback=given_feedback)

@donor_bp.route('/notifications')
@role_required(Role.DONOR)
def notifications():
    """View notifications"""
    from app.models import Notification
    notifications = Notification.query.filter_by(user_id=current_user.id).order_by(Notification.created_at.desc()).all()
    return render_template('donor/notifications.html', notifications=notifications)

@donor_bp.route('/feedback/<int:listing_id>', methods=['POST'])
@role_required(Role.DONOR)
def submit_feedback(listing_id):
    """Submit feedback for completed delivery — Donor can rate NGO and Volunteer"""
    donation = Donation.query.get_or_404(listing_id)

    if donation.donor_id != current_user.id:
        return jsonify({'error': 'Unauthorized'}), 403

    if donation.status != DonationStatus.DELIVERED:
        return jsonify({'error': 'Can only feedback on delivered donations'}), 400

    delivery = donation.delivery
    if not delivery:
        return jsonify({'error': 'No delivery found'}), 400

    data = request.get_json()
    feedback_type = data.get('feedback_type')
    rating = data.get('rating')
    comment = data.get('comment', '')

    if not rating or not feedback_type:
        return jsonify({'error': 'Rating and feedback type are required'}), 400

    if int(rating) < 1 or int(rating) > 5:
        return jsonify({'error': 'Rating must be between 1 and 5'}), 400

    # Determine target user
    if feedback_type == FeedbackType.DONOR_TO_NGO:
        to_user_id = delivery.ngo_id
    elif feedback_type == FeedbackType.DONOR_TO_VOLUNTEER:
        if not delivery.logistics_id:
            return jsonify({'error': 'No volunteer assigned to this delivery'}), 400
        to_user_id = delivery.logistics_id
    else:
        return jsonify({'error': 'Invalid feedback type for donor'}), 400

    # Check for duplicate
    existing = Feedback.query.filter_by(
        delivery_id=delivery.id,
        from_user_id=current_user.id,
        to_user_id=to_user_id
    ).first()
    if existing:
        return jsonify({'error': 'You have already submitted this feedback'}), 400

    try:
        feedback = Feedback(
            delivery_id=delivery.id,
            donation_id=donation.id,
            from_user_id=current_user.id,
            to_user_id=to_user_id,
            feedback_type=feedback_type,
            rating=int(rating),
            comment=comment
        )
        db.session.add(feedback)
        db.session.commit()
        return jsonify({'success': True})
    except Exception:
        db.session.rollback()
        return jsonify({'error': 'Failed to submit feedback'}), 500


@donor_bp.route('/feedback/received')
@role_required(Role.DONOR)
def feedback_received():
    """View feedback received from NGOs and Volunteers"""
    feedbacks = Feedback.query.filter_by(to_user_id=current_user.id).order_by(Feedback.created_at.desc()).all()
    return render_template('donor/feedback.html', feedbacks=feedbacks)
