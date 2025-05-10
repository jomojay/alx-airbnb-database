-- Create ENUM types
CREATE TYPE role_enum AS ENUM ('guest', 'host', 'admin');
CREATE TYPE booking_status_enum AS ENUM ('pending', 'confirmed', 'canceled');
CREATE TYPE payment_method_enum AS ENUM ('credit_card', 'paypal', 'stripe');

-- ========================
-- Location Table (Enhanced)
-- ========================
CREATE TABLE locations (
    location_id UUID PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    lat DECIMAL(9,6) NOT NULL,
    lng DECIMAL(9,6) NOT NULL,
    CONSTRAINT unique_location 
        UNIQUE (city, state, country, postal_code)
);

-- Indexes for Location
CREATE INDEX IF NOT EXISTS idx_location_geo ON locations(lat, lng);
CREATE INDEX IF NOT EXISTS idx_location_city_state ON locations(city, state);

-- ========================
-- User Table (Renamed from "User" to avoid reserved keyword)
-- ========================
CREATE TABLE users (
    user_id UUID PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role role_enum NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Users
CREATE INDEX IF NOT EXISTS idx_user_email ON users(email);

-- ========================
-- Property Table (With explicit constraints)
-- ========================
CREATE TABLE properties (
    property_id UUID PRIMARY KEY,
    host_id UUID NOT NULL,
    location_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    pricepernight DECIMAL(10,2) NOT NULL CHECK (pricepernight > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_property_host 
        FOREIGN KEY (host_id) 
        REFERENCES users(user_id)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_property_location 
        FOREIGN KEY (location_id) 
        REFERENCES locations(location_id)
        ON DELETE RESTRICT
);

-- Indexes for Property
CREATE INDEX IF NOT EXISTS idx_property_host ON properties(host_id);
CREATE INDEX IF NOT EXISTS idx_property_location ON properties(location_id);

-- ========================
-- Booking System Tables
-- ========================
CREATE TABLE bookings (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL CHECK (end_date > start_date),
    booked_pricepernight DECIMAL(10,2) NOT NULL CHECK (booked_pricepernight > 0),
    status booking_status_enum NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_booking_property 
        FOREIGN KEY (property_id) 
        REFERENCES properties(property_id)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_booking_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- Indexes for Booking
CREATE INDEX IF NOT EXISTS idx_booking_dates ON bookings(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_booking_property ON bookings(property_id);

-- ========================
-- Payments Tables
-- ========================
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY,
    booking_id UUID NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method payment_method_enum NOT NULL,
    
    CONSTRAINT fk_payment_booking 
        FOREIGN KEY (booking_id) 
        REFERENCES bookings(booking_id)
        ON DELETE CASCADE
);

-- Indexes for Payments
CREATE INDEX IF NOT EXISTS idx_payment_booking ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payment_date ON payments(payment_date);

-- ========================
-- Review & Messaging Tables
-- ========================
CREATE TABLE reviews (
    review_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_review_property 
        FOREIGN KEY (property_id) 
        REFERENCES properties(property_id)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_review_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(user_id)
        ON DELETE CASCADE
);


-- ========================
-- Messages Tables
-- ========================
CREATE TABLE Message (
    message_id UUID PRIMARY KEY,
    sender_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_message_sender 
        FOREIGN KEY (sender_id) 
        REFERENCES users(user_id)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_message_recipient 
        FOREIGN KEY (recipient_id) 
        REFERENCES users(user_id)
        ON DELETE CASCADE
);