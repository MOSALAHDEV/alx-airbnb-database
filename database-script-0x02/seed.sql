-- ------------------------------------------------------
-- Seed Data for ALX Airbnb Database
-- ------------------------------------------------------

USE alx_airbnb_database;

-- Disable FK checks so we can safely truncate in any order
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE reviews;
TRUNCATE TABLE payments;
TRUNCATE TABLE bookings;
TRUNCATE TABLE property_amenities;
TRUNCATE TABLE property_images;
TRUNCATE TABLE amenities;
TRUNCATE TABLE properties;
TRUNCATE TABLE users;

SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------
-- Seed: users
-- ------------------------------------------------------
INSERT INTO users (id, first_name, last_name, email, password_hash, phone_number, role, is_active, created_at, updated_at)
VALUES
  (1, 'Alice',  'Host',   'alice.host@example.com',   'hashed_pw_alice',  '+1-555-0101', 'host',  1, NOW(), NOW()),
  (2, 'Bob',    'Guest',  'bob.guest@example.com',    'hashed_pw_bob',    '+1-555-0202', 'guest', 1, NOW(), NOW()),
  (3, 'Charlie','Host',   'charlie.host@example.com', 'hashed_pw_charlie','+44-20-555-0303', 'host', 1, NOW(), NOW()),
  (4, 'Diana',  'Guest',  'diana.guest@example.com',  'hashed_pw_diana',  '+33-1-555-0404', 'guest', 1, NOW(), NOW()),
  (5, 'Eve',    'Admin',  'eve.admin@example.com',    'hashed_pw_eve',    NULL, 'admin', 1, NOW(), NOW());

-- ------------------------------------------------------
-- Seed: properties
-- ------------------------------------------------------
INSERT INTO properties (
  id, host_id, title, description, property_type,
  max_guests, bedrooms, beds, bathrooms,
  price_per_night, country, city, address_line,
  latitude, longitude, is_active, created_at, updated_at
)
VALUES
  (1, 1,
   'Cozy Studio in Downtown Paris',
   'Charming studio located in the heart of Paris, close to cafes and metro.',
   'entire_place',
   2, 1, 1, 1.0,
   120.00, 'France', 'Paris', '10 Rue de Rivoli',
   48.8566, 2.3522, 1, NOW(), NOW()
  ),
  (2, 1,
   'Spacious Family Apartment in Lyon',
   'Perfect for families, with fully equipped kitchen and balcony.',
   'entire_place',
   4, 2, 3, 1.5,
   95.00, 'France', 'Lyon', '25 Avenue des Frères Lumière',
   45.7640, 4.8357, 1, NOW(), NOW()
  ),
  (3, 3,
   'Modern Loft in London',
   'Stylish loft with city views and fast Wi-Fi, ideal for business travelers.',
   'entire_place',
   3, 1, 2, 1.0,
   180.00, 'United Kingdom', 'London', '5 King''s Cross Road',
   51.5074, -0.1278, 1, NOW(), NOW()
  ),
  (4, 3,
   'Private Room in Shared House - Manchester',
   'Private room in a quiet shared house, access to kitchen and living room.',
   'private_room',
   1, 1, 1, 1.0,
   45.00, 'United Kingdom', 'Manchester', '18 Oxford Street',
   53.4808, -2.2426, 1, NOW(), NOW()
  );

-- ------------------------------------------------------
-- Seed: property_images
-- ------------------------------------------------------
INSERT INTO property_images (id, property_id, image_url, is_primary, created_at)
VALUES
  (1, 1, 'https://example.com/images/paris-studio-1.jpg', 1, NOW()),
  (2, 1, 'https://example.com/images/paris-studio-2.jpg', 0, NOW()),
  (3, 2, 'https://example.com/images/lyon-family-1.jpg',  1, NOW()),
  (4, 2, 'https://example.com/images/lyon-family-2.jpg',  0, NOW()),
  (5, 3, 'https://example.com/images/london-loft-1.jpg',  1, NOW()),
  (6, 3, 'https://example.com/images/london-loft-2.jpg',  0, NOW()),
  (7, 4, 'https://example.com/images/manchester-room-1.jpg', 1, NOW());

-- ------------------------------------------------------
-- Seed: amenities
-- ------------------------------------------------------
INSERT INTO amenities (id, name, description, created_at)
VALUES
  (1, 'Wi-Fi',           'High-speed wireless internet', NOW()),
  (2, 'Parking',         'Free on-site parking',         NOW()),
  (3, 'Pool',            'Shared swimming pool',         NOW()),
  (4, 'Air conditioning','Air conditioning in rooms',    NOW()),
  (5, 'Kitchen',         'Access to full kitchen',       NOW()),
  (6, 'Washer',          'Washing machine available',    NOW()),
  (7, 'TV',              'Flat-screen TV with streaming',NOW());

-- ------------------------------------------------------
-- Seed: property_amenities
-- ------------------------------------------------------
-- Paris Studio
INSERT INTO property_amenities (property_id, amenity_id)
VALUES
  (1, 1), -- Wi-Fi
  (1, 4), -- Air conditioning
  (1, 5), -- Kitchen
  (1, 7); -- TV

-- Lyon Family Apartment
INSERT INTO property_amenities (property_id, amenity_id)
VALUES
  (2, 1), -- Wi-Fi
  (2, 2), -- Parking
  (2, 5), -- Kitchen
  (2, 6), -- Washer
  (2, 7); -- TV

-- London Loft
INSERT INTO property_amenities (property_id, amenity_id)
VALUES
  (3, 1), -- Wi-Fi
  (3, 4), -- Air conditioning
  (3, 5), -- Kitchen
  (3, 7); -- TV

-- Manchester Private Room
INSERT INTO property_amenities (property_id, amenity_id)
VALUES
  (4, 1), -- Wi-Fi
  (4, 5); -- Kitchen (shared)

-- ------------------------------------------------------
-- Seed: bookings
-- ------------------------------------------------------
INSERT INTO bookings (
  id, guest_id, property_id,
  check_in_date, check_out_date,
  total_price, status, created_at, updated_at
)
VALUES
  -- Completed booking, has payment & review
  (1, 2, 1,
   '2025-01-10', '2025-01-14',
   120.00 * 4, 'completed', NOW(), NOW()
  ),

  -- Confirmed upcoming stay, has payment, no review yet
  (2, 4, 3,
   '2025-02-01', '2025-02-05',
   180.00 * 4, 'confirmed', NOW(), NOW()
  ),

  -- Cancelled booking, may have no payment or refunded payment
  (3, 2, 2,
   '2025-03-15', '2025-03-18',
   95.00 * 3, 'cancelled', NOW(), NOW()
  ),

  -- Pending booking, no payment yet
  (4, 4, 4,
   '2025-04-05', '2025-04-07',
   45.00 * 2, 'pending', NOW(), NOW()
  );

-- ------------------------------------------------------
-- Seed: payments
-- ------------------------------------------------------
INSERT INTO payments (
  id, booking_id, amount, currency,
  payment_method, status, transaction_reference,
  paid_at, created_at
)
VALUES
  -- Completed stay, fully paid
  (1, 1,
   480.00, 'EUR', 'card', 'paid',
   'TXN-20250110-ALICE-BOB-001',
   '2025-01-09 12:00:00', NOW()
  ),

  -- Upcoming confirmed stay, already paid
  (2, 2,
   720.00, 'GBP', 'card', 'paid',
   'TXN-20250120-CHARLIE-DIANA-001',
   '2025-01-20 09:30:00', NOW()
  ),

  -- Cancelled booking, refunded
  (3, 3,
   285.00, 'EUR', 'wallet', 'refunded',
   'TXN-20250301-ALICE-BOB-REFUND',
   '2025-03-01 16:45:00', NOW()
  );

-- ------------------------------------------------------
-- Seed: reviews
-- ------------------------------------------------------
INSERT INTO reviews (
  id, booking_id, guest_id, property_id,
  rating, comment, created_at
)
VALUES
  (1, 1, 2, 1,
   5,
   'Amazing location and very clean studio. Host was super responsive!',
   '2025-01-15 10:00:00'
  ),
  (2, 3, 2, 2,
   3,
   'Had to cancel last minute, but communication with the host was good.',
   '2025-03-10 14:20:00'
  );

