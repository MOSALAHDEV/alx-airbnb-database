-- ------------------------------------------------------
-- Airbnb-style Database Schema for ALX
-- ------------------------------------------------------

-- Create database (optional – adjust name if ALX specifies one)
CREATE DATABASE IF NOT EXISTS alx_airbnb_database
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE alx_airbnb_database;

-- ------------------------------------------------------
-- Drop tables in reverse dependency order (safe re-run)
-- ------------------------------------------------------
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS property_amenities;
DROP TABLE IF EXISTS property_images;
DROP TABLE IF EXISTS amenities;
DROP TABLE IF EXISTS properties;
DROP TABLE IF EXISTS users;

-- ------------------------------------------------------
-- Table: users
-- ------------------------------------------------------
CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  first_name      VARCHAR(100) NOT NULL,
  last_name       VARCHAR(100) NOT NULL,
  email           VARCHAR(255) NOT NULL,
  password_hash   VARCHAR(255) NOT NULL,
  phone_number    VARCHAR(50) NULL,
  role            ENUM('guest', 'host', 'admin') NOT NULL DEFAULT 'guest',
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY uk_users_email (email),
  INDEX idx_users_role (role)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------
-- Table: properties
-- ------------------------------------------------------
CREATE TABLE properties (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  host_id         BIGINT UNSIGNED NOT NULL,
  title           VARCHAR(255) NOT NULL,
  description     TEXT NULL,
  property_type   ENUM('entire_place', 'private_room', 'shared_room') NOT NULL,
  max_guests      INT UNSIGNED NOT NULL,
  bedrooms        INT UNSIGNED NOT NULL DEFAULT 1,
  beds            INT UNSIGNED NOT NULL DEFAULT 1,
  bathrooms       DECIMAL(3,1) NOT NULL DEFAULT 1.0,
  price_per_night DECIMAL(10,2) NOT NULL,
  country         VARCHAR(100) NOT NULL,
  city            VARCHAR(100) NOT NULL,
  address_line    VARCHAR(255) NULL,
  latitude        DECIMAL(10,7) NULL,
  longitude       DECIMAL(10,7) NULL,
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_properties_host
    FOREIGN KEY (host_id) REFERENCES users (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  INDEX idx_properties_host (host_id),
  INDEX idx_properties_location (country, city),
  INDEX idx_properties_active (is_active)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------
-- Table: property_images
-- ------------------------------------------------------
CREATE TABLE property_images (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id   BIGINT UNSIGNED NOT NULL,
  image_url     VARCHAR(500) NOT NULL,
  is_primary    TINYINT(1) NOT NULL DEFAULT 0,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_property_images_property
    FOREIGN KEY (property_id) REFERENCES properties (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  INDEX idx_property_images_property (property_id),
  INDEX idx_property_images_primary (property_id, is_primary)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------
-- Table: amenities
-- ------------------------------------------------------
CREATE TABLE amenities (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  description TEXT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uk_amenities_name (name)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------
-- Table: property_amenities (junction table)
-- ------------------------------------------------------
CREATE TABLE property_amenities (
  property_id BIGINT UNSIGNED NOT NULL,
  amenity_id  BIGINT UNSIGNED NOT NULL,

  PRIMARY KEY (property_id, amenity_id),

  CONSTRAINT fk_property_amenities_property
    FOREIGN KEY (property_id) REFERENCES properties (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_property_amenities_amenity
    FOREIGN KEY (amenity_id) REFERENCES amenities (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------
-- Table: bookings
-- ------------------------------------------------------
CREATE TABLE bookings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  guest_id       BIGINT UNSIGNED NOT NULL,
  property_id    BIGINT UNSIGNED NOT NULL,
  check_in_date  DATE NOT NULL,
  check_out_date DATE NOT NULL,
  total_price    DECIMAL(10,2) NOT NULL,
  status         ENUM('pending', 'confirmed', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_bookings_guest
    FOREIGN KEY (guest_id) REFERENCES users (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  CONSTRAINT fk_bookings_property
    FOREIGN KEY (property_id) REFERENCES properties (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  INDEX idx_bookings_guest (guest_id),
  INDEX idx_bookings_property (property_id),
  INDEX idx_bookings_property_dates (property_id, check_in_date, check_out_date),
  INDEX idx_bookings_status (status)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------
-- Table: payments
-- ------------------------------------------------------
CREATE TABLE payments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  booking_id           BIGINT UNSIGNED NOT NULL,
  amount               DECIMAL(10,2) NOT NULL,
  currency             VARCHAR(10) NOT NULL DEFAULT 'USD',
  payment_method       ENUM('card', 'wallet', 'bank_transfer', 'cash') NOT NULL,
  status               ENUM('pending', 'paid', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
  transaction_reference VARCHAR(255) NULL,
  paid_at              TIMESTAMP NULL,
  created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_payments_booking
    FOREIGN KEY (booking_id) REFERENCES bookings (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  UNIQUE KEY uk_payments_booking (booking_id),
  UNIQUE KEY uk_payments_transaction_reference (transaction_reference),
  INDEX idx_payments_status (status)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------
-- Table: reviews
-- ------------------------------------------------------
CREATE TABLE reviews (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  booking_id  BIGINT UNSIGNED NOT NULL,
  guest_id    BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  rating      TINYINT UNSIGNED NOT NULL,
  comment     TEXT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_reviews_booking
    FOREIGN KEY (booking_id) REFERENCES bookings (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_reviews_guest
    FOREIGN KEY (guest_id) REFERENCES users (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  CONSTRAINT fk_reviews_property
    FOREIGN KEY (property_id) REFERENCES properties (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  CONSTRAINT chk_reviews_rating_range
    CHECK (rating BETWEEN 1 AND 5),

  UNIQUE KEY uk_reviews_booking (booking_id),
  INDEX idx_reviews_property (property_id),
  INDEX idx_reviews_guest (guest_id),
  INDEX idx_reviews_rating (rating)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

