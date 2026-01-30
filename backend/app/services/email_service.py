"""
Email Service
Handles sending email notifications for bookings.
"""

import aiosmtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import List, Optional
from jinja2 import Template

from ..config import settings


class EmailService:
    """Service class for sending email notifications."""
    
    @staticmethod
    async def send_email(
        to_email: str,
        subject: str,
        html_content: str,
        plain_content: Optional[str] = None
    ) -> bool:
        """
        Send an email using SMTP.
        Returns True if successful, False otherwise.
        """
        if not settings.SMTP_USER or not settings.SMTP_PASSWORD:
            print(f"[EMAIL] SMTP not configured. Would send to {to_email}: {subject}")
            return False
        
        try:
            message = MIMEMultipart("alternative")
            message["From"] = f"{settings.SMTP_FROM_NAME} <{settings.SMTP_FROM_EMAIL}>"
            message["To"] = to_email
            message["Subject"] = subject
            
            # Add plain text version
            if plain_content:
                message.attach(MIMEText(plain_content, "plain"))
            
            # Add HTML version
            message.attach(MIMEText(html_content, "html"))
            
            # Send email
            await aiosmtplib.send(
                message,
                hostname=settings.SMTP_HOST,
                port=settings.SMTP_PORT,
                start_tls=settings.SMTP_TLS,
                username=settings.SMTP_USER,
                password=settings.SMTP_PASSWORD
            )
            
            print(f"[EMAIL] Sent successfully to {to_email}: {subject}")
            return True
            
        except Exception as e:
            print(f"[EMAIL] Failed to send to {to_email}: {str(e)}")
            return False
    
    @staticmethod
    async def send_verification_email(to_email: str, name: str, token: str) -> bool:
        """Send email verification email."""
        verification_link = f"{settings.FRONTEND_URL}/verify-email?token={token}"
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
                .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
                .button {{ display: inline-block; background: #667eea; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }}
                .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🏍️ Bike Service Station</h1>
                </div>
                <div class="content">
                    <h2>Welcome, {name}!</h2>
                    <p>Thank you for registering with Bike Service Station. Please verify your email address to complete your registration.</p>
                    <p style="text-align: center;">
                        <a href="{verification_link}" class="button">Verify Email Address</a>
                    </p>
                    <p>Or copy this link: {verification_link}</p>
                    <p>If you didn't create an account, you can safely ignore this email.</p>
                </div>
                <div class="footer">
                    <p>© 2024 Bike Service Station. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return await EmailService.send_email(
            to_email=to_email,
            subject="Verify Your Email - Bike Service Station",
            html_content=html_content
        )
    
    @staticmethod
    async def send_booking_confirmation(
        to_email: str,
        customer_name: str,
        booking_id: str,
        booking_date: str,
        services: List[dict],
        total_price: float
    ) -> bool:
        """Send booking confirmation email to customer."""
        services_html = "".join([
            f"<tr><td style='padding: 10px; border-bottom: 1px solid #eee;'>{s['name']}</td>"
            f"<td style='padding: 10px; border-bottom: 1px solid #eee; text-align: right;'>${s['price']:.2f}</td></tr>"
            for s in services
        ])
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
                .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
                .booking-info {{ background: white; padding: 20px; border-radius: 10px; margin: 20px 0; }}
                table {{ width: 100%; border-collapse: collapse; }}
                .total {{ font-size: 18px; font-weight: bold; color: #667eea; }}
                .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🏍️ Booking Confirmed!</h1>
                </div>
                <div class="content">
                    <h2>Hello, {customer_name}!</h2>
                    <p>Your booking has been confirmed. Here are the details:</p>
                    
                    <div class="booking-info">
                        <p><strong>Booking ID:</strong> {booking_id[:8]}...</p>
                        <p><strong>Date:</strong> {booking_date}</p>
                        
                        <h3>Services:</h3>
                        <table>
                            {services_html}
                            <tr>
                                <td style="padding: 15px 10px; font-weight: bold;">Total</td>
                                <td style="padding: 15px 10px; text-align: right;" class="total">${total_price:.2f}</td>
                            </tr>
                        </table>
                    </div>
                    
                    <p>We'll notify you when your bike is ready for pickup!</p>
                </div>
                <div class="footer">
                    <p>© 2024 Bike Service Station. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return await EmailService.send_email(
            to_email=to_email,
            subject=f"Booking Confirmed - {booking_date}",
            html_content=html_content
        )
    
    @staticmethod
    async def send_ready_for_delivery(
        to_email: str,
        customer_name: str,
        booking_id: str
    ) -> bool:
        """Send notification when bike is ready for delivery."""
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
                .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
                .icon {{ font-size: 48px; }}
                .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <div class="icon">✅</div>
                    <h1>Your Bike is Ready!</h1>
                </div>
                <div class="content">
                    <h2>Great news, {customer_name}!</h2>
                    <p>Your bike service is complete and your bike is ready for pickup.</p>
                    <p><strong>Booking Reference:</strong> {booking_id[:8]}...</p>
                    <p>Please visit us at your earliest convenience to collect your bike.</p>
                    <p>Thank you for choosing Bike Service Station!</p>
                </div>
                <div class="footer">
                    <p>© 2024 Bike Service Station. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return await EmailService.send_email(
            to_email=to_email,
            subject="Your Bike is Ready for Pickup! 🏍️",
            html_content=html_content
        )
    
    @staticmethod
    async def send_new_booking_to_owner(
        owner_email: str,
        customer_name: str,
        customer_email: str,
        customer_phone: str,
        booking_id: str,
        booking_date: str,
        services: List[dict],
        total_price: float
    ) -> bool:
        """Send notification to owner when a new booking is created."""
        services_html = "".join([
            f"<li>{s['name']} - ${s['price']:.2f}</li>"
            for s in services
        ])
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
                .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
                .customer-info {{ background: white; padding: 20px; border-radius: 10px; margin: 20px 0; }}
                .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🔔 New Booking Received!</h1>
                </div>
                <div class="content">
                    <h2>New booking from {customer_name}</h2>
                    
                    <div class="customer-info">
                        <h3>Customer Details</h3>
                        <p><strong>Name:</strong> {customer_name}</p>
                        <p><strong>Email:</strong> {customer_email}</p>
                        <p><strong>Phone:</strong> {customer_phone}</p>
                        
                        <h3>Booking Details</h3>
                        <p><strong>Booking ID:</strong> {booking_id[:8]}...</p>
                        <p><strong>Date:</strong> {booking_date}</p>
                        
                        <h3>Services Requested</h3>
                        <ul>{services_html}</ul>
                        
                        <p><strong>Total:</strong> ${total_price:.2f}</p>
                    </div>
                    
                    <p>Please review and confirm this booking in your dashboard.</p>
                </div>
                <div class="footer">
                    <p>© 2024 Bike Service Station Management System</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return await EmailService.send_email(
            to_email=owner_email,
            subject=f"New Booking from {customer_name} - {booking_date}",
            html_content=html_content
        )
