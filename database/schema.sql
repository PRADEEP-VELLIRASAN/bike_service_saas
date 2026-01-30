-- Bike Service Station Management - PostgreSQL Database Schema
-- ============================================================

-- Enable UUID extension for unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUM TYPES
-- ============================================================

-- User roles
CREATE TYPE user_role AS ENUM ('owner', 'customer');

-- Booking status
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'in_progress', 'ready_for_delivery', 'completed', 'cancelled');

-- ============================================================
-- USERS TABLE
-- ============================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role user_role NOT NULL DEFAULT 'customer',
    is_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster email lookups during login
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ============================================================
-- SERVICES TABLE
-- ============================================================

CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    estimated_time INTEGER NOT NULL CHECK (estimated_time > 0), -- in minutes
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for active services
CREATE INDEX idx_services_active ON services(is_active);

-- ============================================================
-- BOOKINGS TABLE
-- ============================================================

CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    booking_date DATE NOT NULL,
    status booking_status NOT NULL DEFAULT 'pending',
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for booking queries
CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_date ON bookings(booking_date);
CREATE INDEX idx_bookings_created ON bookings(created_at DESC);

-- ============================================================
-- BOOKING_SERVICES (Junction Table - Many-to-Many)
-- ============================================================

CREATE TABLE booking_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
    service_price DECIMAL(10, 2) NOT NULL, -- Price at time of booking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(booking_id, service_id)
);

-- Indexes for junction table
CREATE INDEX idx_booking_services_booking ON booking_services(booking_id);
CREATE INDEX idx_booking_services_service ON booking_services(service_id);

-- ============================================================
-- TRIGGER FUNCTION FOR updated_at
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at
    BEFORE UPDATE ON services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
    BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================

-- Insert a sample owner account (password: admin123)
-- INSERT INTO users (email, password_hash, name, phone, role, is_verified)
-- VALUES ('owner@bikeservice.com', '$2b$12$LQv3c1yqBwlF0xOqNlJkZ.samplehash', 'Service Owner', '+1234567890', 'owner', true);

-- Insert sample services
-- INSERT INTO services (name, description, price, estimated_time) VALUES
-- ('Basic Wash', 'Complete exterior wash with soap and water', 15.00, 30),
-- ('Full Service', 'Complete bike service including chain, brakes, and gears', 50.00, 120),
-- ('Tire Replacement', 'Replace front or rear tire', 25.00, 45),
-- ('Brake Adjustment', 'Adjust and tune brake system', 20.00, 30),
-- ('Chain Lubrication', 'Clean and lubricate chain', 10.00, 20);
