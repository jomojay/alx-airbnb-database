-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Insert locations
INSERT INTO locations (location_id, country, state, city, postal_code, lat, lng) 
VALUES
    (uuid_generate_v4(), 'Kenya', 'Nairobi', 'Nairobi', '00100', -1.2921, 36.8219),
    (uuid_generate_v4(), 'Nigeria', 'Federal Capital Territory', 'Abuja', '900001', 9.0765, 7.3986);

-- Insert users
INSERT INTO users (user_id, first_name, last_name, email, password_hash, phone_number, role) 
VALUES
    (uuid_generate_v4(), 'Ernest', 'Wambua', 'ernest@example.com', 'hash1', '+254700111222', 'host'),
    (uuid_generate_v4(), 'Irene', 'Aragona', 'irene@example.com', 'hash2', '+234801234567', 'guest'),
    (uuid_generate_v4(), 'Cole', 'Bidoo', 'cole@example.com', 'hash3', '+233201234567', 'host'),
    (uuid_generate_v4(), 'Faith', 'Okoth', 'faith@example.com', 'hash4', '+254711333444', 'guest'),
    (uuid_generate_v4(), 'Fred', 'Swaniker', 'fred@example.com', 'hash5', '+27821234567', 'admin');

-- Insert properties with proper location references
WITH location_ids AS (
    SELECT 
        (SELECT location_id FROM locations WHERE city = 'Nairobi') AS nairobi,
        (SELECT location_id FROM locations WHERE city = 'Abuja') AS abuja
)
INSERT INTO properties (property_id, host_id, location_id, name, description, pricepernight)
SELECT 
    uuid_generate_v4(),
    u.user_id,
    l.nairobi,
    'Nairobi City Apartment',
    'Modern apartment in Westlands',
    7000.00
FROM users u 
CROSS JOIN location_ids l
WHERE u.email = 'ernest@example.com'

UNION ALL

SELECT 
    uuid_generate_v4(),
    u.user_id,
    l.abuja,
    'Abuja Luxury Suite',
    'Penthouse with city views',
    15000.00
FROM users u 
CROSS JOIN location_ids l
WHERE u.email = 'cole@example.com';

-- Insert bookings with calculated prices
INSERT INTO bookings (booking_id, property_id, user_id, start_date, end_date, booked_pricepernight, status)
WITH property_data AS (
    SELECT 
        p.property_id,
        p.pricepernight,
        u.user_id
    FROM properties p
    JOIN users u ON p.host_id = u.user_id
)
SELECT 
    uuid_generate_v4(),
    pd.property_id,
    gu.user_id,
    '2024-07-15',
    '2024-07-20',
    pd.pricepernight,
    'confirmed'
FROM property_data pd
JOIN users gu ON gu.email = 'irene@example.com'
WHERE pd.pricepernight = 7000.00

UNION ALL

SELECT 
    uuid_generate_v4(),
    pd.property_id,
    gu.user_id,
    '2024-08-01',
    '2024-08-05',
    pd.pricepernight,
    'pending'
FROM property_data pd
JOIN users gu ON gu.email = 'faith@example.com'
WHERE pd.pricepernight = 15000.00;

-- Insert payments
INSERT INTO payments (payment_id, booking_id, payment_method)
SELECT 
    uuid_generate_v4(),
    b.booking_id,
    'credit_card'
FROM bookings b
WHERE b.booked_pricepernight = 7000.00

UNION ALL

SELECT 
    uuid_generate_v4(),
    b.booking_id,
    'paypal'
FROM bookings b
WHERE b.booked_pricepernight = 15000.00;

-- Insert reviews
INSERT INTO reviews (review_id, property_id, user_id, rating, comment)
WITH review_data AS (
    SELECT 
        p.property_id,
        u.user_id
    FROM properties p
    JOIN users u ON u.email = 'irene@example.com'
    WHERE p.pricepernight = 7000.00
)
SELECT 
    uuid_generate_v4(),
    rd.property_id,
    rd.user_id,
    4,
    'Excellent central location!'
FROM review_data rd;

-- Insert messages
INSERT INTO messages (message_id, sender_id, recipient_id, message_body, sent_at)
SELECT 
    uuid_generate_v4(),
    s.user_id,
    r.user_id,
    'Is there parking available?',
    NOW()
FROM users s
JOIN users r ON r.email = 'ernest@example.com'
WHERE s.email = 'irene@example.com';