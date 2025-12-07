# DataScape: Airbnb Database ERD Requirements

## 1. Overview

This document describes the entities, attributes, and relationships for the **ALX Airbnb Database** project.  
The ER diagram models a simplified Airbnb-like system where:

- **Users** can act as guests and/or hosts.
- **Hosts** create and manage **properties**.
- **Guests** make **bookings** and **payments**.
- **Guests** leave **reviews** for properties.
- Properties expose **amenities** and **images**.

The ERD created from this document will be used in later tasks to generate the SQL schema and seed data.

---

## 2. Entities and Attributes

### 2.1. User

Represents both hosts and guests.

**Table name:** `users`  
**Primary key:** `id`

**Attributes:**

- `id` – integer, PK, auto-increment
- `first_name` – varchar, not null
- `last_name` – varchar, not null
- `email` – varchar, not null, unique
- `password_hash` – varchar, not null
- `phone_number` – varchar, nullable
- `role` – enum (`guest`, `host`, `admin`), not null
- `is_active` – boolean, default true
- `created_at` – datetime, not null
- `updated_at` – datetime, not null

---

### 2.2. Property

Represents a listing (house, apartment, room).

**Table name:** `properties`  
**Primary key:** `id`  
**Foreign keys:**

- `host_id` → `users.id`

**Attributes:**

- `id` – integer, PK, auto-increment
- `host_id` – integer, FK to `users.id`, not null
- `title` – varchar, not null
- `description` – text, nullable
- `property_type` – enum (`entire_place`, `private_room`, `shared_room`), not null
- `max_guests` – integer, not null
- `bedrooms` – integer, default 1
- `beds` – integer, default 1
- `bathrooms` – decimal(3,1), not null
- `price_per_night` – decimal(10,2), not null
- `country` – varchar, not null
- `city` – varchar, not null
- `address_line` – varchar, nullable
- `latitude` – decimal, nullable
- `longitude` – decimal, nullable
- `is_active` – boolean, default true
- `created_at` – datetime, not null
- `updated_at` – datetime, not null

---

### 2.3. Property_Image

Stores images for a property.

**Table name:** `property_images`  
**Primary key:** `id`  
**Foreign keys:**

- `property_id` → `properties.id`

**Attributes:**

- `id` – integer, PK, auto-increment
- `property_id` – integer, FK to `properties.id`, not null
- `image_url` – varchar, not null
- `is_primary` – boolean, default false
- `created_at` – datetime, not null

---

### 2.4. Amenity

Defines possible amenities (Wi-Fi, Pool, etc.).

**Table name:** `amenities`  
**Primary key:** `id`

**Attributes:**

- `id` – integer, PK, auto-increment
- `name` – varchar, not null, unique
- `description` – text, nullable
- `created_at` – datetime, not null

---

### 2.5. Property_Amenity

Junction table for the many-to-many relationship between properties and amenities.

**Table name:** `property_amenities`  
**Primary key:** composite (`property_id`, `amenity_id`)  

**Foreign keys:**

- `property_id` → `properties.id`
- `amenity_id` → `amenities.id`

**Attributes:**

- `property_id` – integer, FK to `properties.id`, not null
- `amenity_id` – integer, FK to `amenities.id`, not null

---

### 2.6. Booking

Represents a reservation of a property by a guest.

**Table name:** `bookings`  
**Primary key:** `id`  

**Foreign keys:**

- `guest_id` → `users.id`
- `property_id` → `properties.id`

**Attributes:**

- `id` – integer, PK, auto-increment
- `guest_id` – integer, FK to `users.id`, not null
- `property_id` – integer, FK to `properties.id`, not null
- `check_in_date` – date, not null
- `check_out_date` – date, not null
- `total_price` – decimal(10,2), not null
- `status` – enum (`pending`, `confirmed`, `cancelled`, `completed`), not null
- `created_at` – datetime, not null
- `updated_at` – datetime, not null

---

### 2.7. Payment

Stores payment details for bookings.

**Table name:** `payments`  
**Primary key:** `id`  

**Foreign keys:**

- `booking_id` → `bookings.id`

**Attributes:**

- `id` – integer, PK, auto-increment
- `booking_id` – integer, FK to `bookings.id`, not null, unique
- `amount` – decimal(10,2), not null
- `currency` – varchar, default `'USD'`, not null
- `payment_method` – enum (`card`, `wallet`, `bank_transfer`, `cash`), not null
- `status` – enum (`pending`, `paid`, `failed`, `refunded`), not null
- `transaction_reference` – varchar, unique, nullable
- `paid_at` – datetime, nullable
- `created_at` – datetime, not null

---

### 2.8. Review

Guests’ reviews of properties.

**Table name:** `reviews`  
**Primary key:** `id`  

**Foreign keys:**

- `booking_id` → `bookings.id`
- `guest_id` → `users.id`
- `property_id` → `properties.id`

**Attributes:**

- `id` – integer, PK, auto-increment
- `booking_id` – integer, FK to `bookings.id`, not null
- `guest_id` – integer, FK to `users.id`, not null
- `property_id` – integer, FK to `properties.id`, not null
- `rating` – integer, not null, range 1–5
- `comment` – text, nullable
- `created_at` – datetime, not null

---

## 3. Relationships Summary

1. **User – Property**
   - One `user` (host) **has many** `properties`.
   - `properties.host_id` → `users.id`

2. **User – Booking**
   - One `user` (guest) **has many** `bookings`.
   - `bookings.guest_id` → `users.id`

3. **Property – Booking**
   - One `property` **has many** `bookings`.
   - `bookings.property_id` → `properties.id`

4. **Booking – Payment**
   - One `booking` **has zero or one** `payment`.
   - `payments.booking_id` → `bookings.id`

5. **Booking – Review**
   - One `booking` **has zero or one** `review`.
   - `reviews.booking_id` → `bookings.id`

6. **User – Review**
   - One `user` (guest) **has many** `reviews`.
   - `reviews.guest_id` → `users.id`

7. **Property – Review**
   - One `property` **has many** `reviews`.
   - `reviews.property_id` → `properties.id`

8. **Property – Property_Image**
   - One `property` **has many** `property_images`.
   - `property_images.property_id` → `properties.id`

9. **Property – Amenity (via Property_Amenity)**
   - Many-to-many:
     - One `property` **has many** `amenities` through `property_amenities`.
     - One `amenity` **belongs to many** `properties` through `property_amenities`.
   - `property_amenities.property_id` → `properties.id`
   - `property_amenities.amenity_id` → `amenities.id`

---

## 4. ERD Deliverable

- The ER diagram must visually represent **all entities, attributes, and relationships** described above.
- Use standard ER notation (crow’s feet) to indicate cardinalities.
- The ERD should be created using **Draw.io** or a similar diagramming tool.
- Export the ERD as an image or PDF (as required by the project) and keep it in the `ERD/` directory alongside this `requirements.md`.

