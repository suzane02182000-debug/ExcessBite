from flask import Blueprint, render_template, jsonify
from flask_login import current_user

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def home():
    """Home page"""
    return render_template('index.html')

@main_bp.route('/about')
def about():
    """About page"""
    return render_template('about.html')

@main_bp.route('/how-it-works')
def how_it_works():
    """How it works page"""
    return render_template('how-it-works.html')

@main_bp.route('/contact')
def contact():
    """Contact page"""
    return render_template('contact.html')

@main_bp.route('/api/user/status')
def user_status():
    """Get current user status"""
    if current_user.is_authenticated:
        return jsonify({
            'authenticated': True,
            'user_id': current_user.id,
            'username': current_user.username,
            'role': current_user.role,
            'full_name': current_user.full_name
        })
    return jsonify({
        'authenticated': False
    })
