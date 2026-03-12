from flask import Blueprint, render_template, request, jsonify, flash, redirect, url_for
from flask_login import login_user, logout_user, current_user, login_required
from app.models import db, User, Role, Notification
from datetime import datetime
import re

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

def validate_email(email):
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_password(password):
    """Validate password strength"""
    # At least 8 characters, 1 uppercase, 1 lowercase, 1 digit, 1 special char
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"
    if not re.search(r'[A-Z]', password):
        return False, "Password must contain at least one uppercase letter"
    if not re.search(r'[a-z]', password):
        return False, "Password must contain at least one lowercase letter"
    if not re.search(r'\d', password):
        return False, "Password must contain at least one digit"
    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        return False, "Password must contain at least one special character"
    return True, "Valid"

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    """User registration"""
    if current_user.is_authenticated:
        return redirect(url_for('main.home'))
    
    if request.method == 'POST':
        data = request.form
        
        # Validation
        errors = []
        
        if not data.get('username'):
            errors.append('Username is required')
        elif len(data.get('username', '')) < 3:
            errors.append('Username must be at least 3 characters')
        elif User.query.filter_by(username=data.get('username')).first():
            errors.append('Username already exists')
        
        if not data.get('email'):
            errors.append('Email is required')
        elif not validate_email(data.get('email', '')):
            errors.append('Invalid email format')
        elif User.query.filter_by(email=data.get('email')).first():
            errors.append('Email already registered')
        
        if not data.get('password'):
            errors.append('Password is required')
        else:
            valid, msg = validate_password(data.get('password', ''))
            if not valid:
                errors.append(msg)
        
        if data.get('password') != data.get('password_confirm'):
            errors.append('Passwords do not match')
        
        if not data.get('full_name'):
            errors.append('Full name is required')
        
        if not data.get('phone'):
            errors.append('Phone number is required')
        
        if not data.get('role') or data.get('role') not in Role.ALL_ROLES:
            errors.append('Invalid role selected')
        
        if errors:
            return render_template('register.html', errors=errors, roles=Role.ALL_ROLES), 400
        
        # Create new user
        user = User(
            username=data.get('username'),
            email=data.get('email'),
            full_name=data.get('full_name'),
            phone=data.get('phone'),
            role=data.get('role'),
            address=data.get('address', ''),
            city=data.get('city', ''),
            latitude=float(data.get('latitude')) if data.get('latitude') else None,
            longitude=float(data.get('longitude')) if data.get('longitude') else None,
            organization_name=data.get('organization_name', ''),
            organization_type=data.get('organization_type', ''),
        )
        
        user.set_password(data.get('password'))
        
        # Donors are auto-verified, others need admin approval
        if user.role == Role.DONOR:
            user.is_verified = True
            user.verification_date = datetime.utcnow()
        
        try:
            db.session.add(user)
            db.session.commit()
            
            # Create notification for admin if not donor
            if user.role != Role.DONOR:
                admin_users = User.query.filter_by(role=Role.ADMIN).all()
                for admin in admin_users:
                    notification = Notification(
                        user_id=admin.id,
                        title=f'New {user.role.upper()} Registration',
                        message=f'{user.full_name} ({user.email}) registered as {user.role}',
                        notification_type='registration',
                        related_id=user.id
                    )
                    db.session.add(notification)
                db.session.commit()
            
            flash('Registration successful! Please log in.', 'success')
            return redirect(url_for('auth.login'))
        except Exception as e:
            db.session.rollback()
            return render_template('register.html', errors=['Registration failed. Please try again.'], roles=Role.ALL_ROLES), 500
    
    return render_template('register.html', roles=Role.ALL_ROLES)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    """User login"""
    if current_user.is_authenticated:
        return redirect(url_for('main.home'))
    
    if request.method == 'POST':
        data = request.form
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return render_template('login.html', error='Username and password required'), 400
        
        user = User.query.filter_by(username=username).first()
        
        if not user:
            return render_template('login.html', error='Invalid username or password'), 401
        
        if not user.check_password(password):
            return render_template('login.html', error='Invalid username or password'), 401
        
        if not user.is_active:
            return render_template('login.html', error='Your account has been deactivated'), 401
        
        login_user(user, remember=data.get('remember', False))
        
        next_page = request.args.get('next')
        if next_page and next_page.startswith('/'):
            return redirect(next_page)
        
        # Redirect based on role
        if user.role == Role.ADMIN:
            return redirect(url_for('admin.dashboard'))
        elif user.role == Role.DONOR:
            return redirect(url_for('donor.dashboard'))
        elif user.role == Role.NGO:
            return redirect(url_for('ngo.dashboard'))
        elif user.role == Role.LOGISTICS:
            return redirect(url_for('logistics.dashboard'))
        
        return redirect(url_for('main.home'))
    
    return render_template('login.html')

@auth_bp.route('/logout')
@login_required
def logout():
    """User logout"""
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('main.home'))

@auth_bp.route('/profile', methods=['GET', 'POST'])
@login_required
def profile():
    """User profile"""
    if request.method == 'POST':
        data = request.form
        
        # Update user profile
        current_user.full_name = data.get('full_name', current_user.full_name)
        current_user.phone = data.get('phone', current_user.phone)
        current_user.address = data.get('address', current_user.address)
        current_user.city = data.get('city', current_user.city)
        
        # Update location if provided
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        if latitude and longitude:
            try:
                current_user.latitude = float(latitude)
                current_user.longitude = float(longitude)
            except ValueError:
                pass  # Ignore invalid coordinates
        
        try:
            db.session.commit()
            flash('Profile updated successfully', 'success')
            return redirect(url_for('auth.profile'))
        except Exception as e:
            db.session.rollback()
            flash('Failed to update profile', 'error')
    
    return render_template('profile.html', user=current_user)
