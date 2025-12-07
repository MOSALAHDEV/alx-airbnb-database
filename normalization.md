# Normalization of the Airbnb Database Design (Up to 3NF)

## 1. Introduction

This document explains how the database design for the **ALX Airbnb Database** project was normalized up to **Third Normal Form (3NF)**.

The goal of normalization is to:

- Eliminate redundant data  
- Reduce anomalies when **inserting**, **updating**, or **deleting** records  
- Ensure each table models a **single, well-defined concept**

The final design includes the following main tables:

- `users`
- `properties`
- `property_images`
- `amenities`
- `property_amenities`
- `bookings`
- `payments`
- `reviews`

---

## 2. Normalization Concepts (Quick Overview)

### 2.1 First Normal Form (1NF)

A table is in 1NF if:

- All values are **atomic** (no repeating groups or lists in a single column)
- Each field contains a single value
- Each row is unique

### 2.2 Second Normal Form (2NF)

A table is in 2NF if:

- It is already in **1NF**
- **Every non-key attribute** is **fully functionally dependent** on the **whole primary key**
  - This mainly affects tables with **composite primary keys**
  - No **partial dependency** (where a column depends only on part of a composite key)

### 2.3 Third Normal Form (3NF)

A table is in 3NF if:

- It is already in **2NF**
- It has **no transitive dependency**:
  - Non-key attributes do not depend on other non-key attributes
  - Every non-key attribute depends **only on the key, the whole key, and nothing but the key**

---

## 3. Starting Point: Denormalized “Reservation” Table

Conceptually, a naive design might try to put **everything about a reservation** into a single table, like this:

**Table: `reservations_raw` (conceptual example)**

- `reservation_id`  
- `guest_id`, `guest_name`, `guest_email`  
- `host_id`, `host_name`, `host_email`  
- `property_id`, `property_title`, `property_city`, `property_country`, `property_address`  
- `amenities_list` (e.g. `"Wifi, Parking, Pool"`)  
- `check_in_date`, `check_out_date`, `total_price`  
- `payment_status`, `payment_method`, `payment_reference`  
- `review_rating`, `review_comment`  

This design has several problems:

- **Redundancy**:  
  - Guest info repeated for every booking by the same guest  
  - Host & property info repeated for every booking of that property  
  - Amenities stored as a comma-separated list

- **Update anomalies**:
  - Changing a guest email requires updating many rows
  - Renaming a property city means updating all rows with that property

- **Insert anomalies**:
  - Cannot add a new property or amenity without a reservation row

- **Delete anomalies**:
  - Deleting the last reservation for a property might also lose all info about that property

This violates all normal forms beyond very basic structure.

---

## 4. Step-by-Step Normalization

### 4.1 From UNF to 1NF

**Issues in `reservations_raw`:**

- `amenities_list` is a **repeating group** (multiple values in one column)
- `guest_name` is not atomic (can be split into first/last name)
- `host_name` is not atomic

**1NF Fixes:**

1. Ensure **atomic values**:
   - Split `guest_name` → `guest_first_name`, `guest_last_name`
   - Split `host_name` → `host_first_name`, `host_last_name`

2. Remove repeating groups (`amenities_list`):
   - Create separate **Amenity** and **Property_Amenity** tables (see below)

At this point, we move from one large table to multiple tables with atomic attributes.

---

### 4.2 From 1NF to 2NF

To reach 2NF, we must remove **partial dependencies** (non-key attributes depending on only part of a composite key).

In the denormalized design, a natural composite key might be (`guest_id`, `property_id`, `check_in_date`), but many attributes depend only on **guest** or **property**, not the whole combination.

#### 4.2.1 Extracting the `users` Table

Functional dependencies:

- `guest_id → guest_name, guest_email, guest_phone`
- `host_id → host_name, host_email, host_phone`

These show that guest-related and host-related columns **depend only** on `guest_id` or `host_id`, not on the entire “reservation” row.

**Solution:** Create a separate `users` table.

**Table: `users`**

- PK: `id`
- Attributes: `first_name`, `last_name`, `email`, `password_hash`, `phone_number`, `role`, `is_active`, timestamps

Now `guest_id` and `host_id` in other tables will reference `users.id`.

#### 4.2.2 Extracting the `properties` Table

Functional dependencies:

- `property_id → property_title, property_city, property_country, property_address, price_per_night, max_guests, ...`

These attributes depend **only** on `property_id`, not on the whole reservation.

**Solution:** Create `properties` table with `property_id` as primary key.

**Table: `properties`**

- PK: `id`
- FK: `host_id → users.id`
- Attributes: `title`, `description`, `property_type`, `max_guests`, `bedrooms`, `beds`, `bathrooms`, `price_per_night`, `country`, `city`, `address_line`, `latitude`, `longitude`, `is_active`, timestamps

#### 4.2.3 Defining the `bookings` Table

After extracting users and properties, the remaining reservation-specific data:

- `booking_id`
- `guest_id` (FK to `users`)
- `property_id` (FK to `properties`)
- `check_in_date`, `check_out_date`
- `total_price`
- `status`
- timestamps

**Table: `bookings`**

- PK: `id`
- FKs: `guest_id → users.id`, `property_id → properties.id`

In this table:

- All non-key attributes (`guest_id`, `property_id`, `check_in_date`, `check_out_date`, `total_price`, `status`) depend fully on `id` (the primary key).
- No composite primary key is needed, so **no partial dependency** issue.

At this point, our main tables (`users`, `properties`, `bookings`) are in **2NF**.

---

### 4.3 From 2NF to 3NF

To reach 3NF, we must remove **transitive dependencies** (non-key attributes depending on other non-key attributes).

We now look at each table.

#### 4.3.1 `users` Table

Functional dependencies:

- `id → first_name, last_name, email, password_hash, phone_number, role, is_active, created_at, updated_at`
- `email` is unique, but we treat `id` as the primary key.

No non-key attribute depends on another non-key attribute (e.g., `role` does not determine `email` or `phone_number`).  
Therefore, `users` is in **3NF**.

#### 4.3.2 `properties` Table

Functional dependencies:

- `id → host_id, title, description, property_type, max_guests, bedrooms, beds, bathrooms, price_per_night, country, city, address_line, latitude, longitude, is_active, created_at, updated_at`

No attribute like `city` is used to determine `country` in the design; even if logically some cities imply a country, we don’t encode that as a dependency in the schema.  
All non-key attributes depend directly on `id`.  
So `properties` is in **3NF**.

#### 4.3.3 `bookings` Table

Functional dependencies:

- `id → guest_id, property_id, check_in_date, check_out_date, total_price, status, created_at, updated_at`
- `guest_id` and `property_id` are **foreign keys** linking to other tables; they do not determine other non-key attributes within `bookings`.

No non-key attribute functionally determines another non-key attribute inside the `bookings` table, so it is in **3NF**.

#### 4.3.4 `payments` Table

We separate payments from bookings to avoid mixing financial attributes into the booking table.

**Table: `payments`**

- PK: `id`
- FK: `booking_id → bookings.id`

Attributes:

- `id`, `booking_id`, `amount`, `currency`, `payment_method`, `status`, `transaction_reference`, `paid_at`, `created_at`

Functional dependencies:

- `id → booking_id, amount, currency, payment_method, status, transaction_reference, paid_at, created_at`

No non-key attribute (e.g., `payment_method`) determines another non-key attribute. Any relationship between `status` and `paid_at` is a **business rule**, not a functional dependency used as schema-level determinant.  
Therefore, `payments` is in **3NF**.

#### 4.3.5 `reviews` Table

**Table: `reviews`**

- PK: `id`
- FKs: `booking_id → bookings.id`, `guest_id → users.id`, `property_id → properties.id`

Attributes:

- `id`, `booking_id`, `guest_id`, `property_id`, `rating`, `comment`, `created_at`

Functional dependencies:

- `id → booking_id, guest_id, property_id, rating, comment, created_at`

Although `booking_id` could logically determine `guest_id` and `property_id` (because they already exist in `bookings`), we keep them here intentionally as FKs for query convenience or we can skip them and just store `booking_id`.  

Two valid 3NF designs:

1. **Minimal**: Store only `booking_id`, `rating`, `comment`, `created_at` (all other info retrieved via joins)  
2. **Redundant but allowed**: Keep `guest_id` and `property_id` as FKs but ensure they match the values from the referenced booking at the application level.

For strict 3NF with no redundancy, we can rely solely on `booking_id`. In either case, there is no transitive dependency among non-key attributes inside the table itself, so the table satisfies **3NF**.

#### 4.3.6 `amenities` and `property_amenities` Tables

**Table: `amenities`**

- PK: `id`
- Attributes: `name`, `description`, `created_at`

Functional dependencies:

- `id → name, description, created_at`

`amenities` is in **3NF**.

**Table: `property_amenities`**

- Composite PK: (`property_id`, `amenity_id`)
- FKs: `property_id → properties.id`, `amenity_id → amenities.id`

This is a pure **join table** with no additional attributes, so there are no non-key attributes to cause transitive or partial dependencies.  
`property_amenities` is also in **3NF**.

#### 4.3.7 `property_images` Table

**Table: `property_images`**

- PK: `id`
- FK: `property_id → properties.id`
- Attributes: `image_url`, `is_primary`, `created_at`

Functional dependencies:

- `id → property_id, image_url, is_primary, created_at`

No transitive dependency, so `property_images` is in **3NF**.

---

## 5. Summary of Changes and Normalization Benefits

### 5.1 Main Transformations

Starting from a conceptual, denormalized design:

1. **Split user data** into a dedicated `users` table.
2. **Split property data** into a dedicated `properties` table.
3. **Extract reservations** into a `bookings` table.
4. **Separate payments** into a `payments` table.
5. **Separate reviews** into a `reviews` table.
6. **Move amenities** into `amenities` and create `property_amenities` as a proper many-to-many join table.
7. **Move images** into `property_images`, allowing multiple images per property.

### 5.2 Achieved Normal Forms

- All tables use **atomic columns** with no repeating groups → **1NF**
- No non-key attribute depends on part of a composite key → **2NF**
- No non-key attribute depends on another non-key attribute within a table → **3NF**

### 5.3 Advantages of the Final 3NF Design

- **Reduced redundancy**:
  - User, property, amenity, and payment data are stored exactly once.
- **Easier updates**:
  - Updating a user’s email or a property’s price is done in a single place.
- **Cleaner relationships**:
  - `bookings`, `payments`, `reviews`, and `property_amenities` clearly represent real-world relationships.
- **Better scalability and performance**:
  - Smaller, focused tables make indexing and querying more efficient.

The database design is now in **Third Normal Form (3NF)** and ready to be used for schema creation (DDL) and data seeding in the later project tasks.

