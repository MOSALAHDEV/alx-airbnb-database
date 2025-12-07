# Seed Script – ALX Airbnb Database (DataScape)

This directory contains SQL scripts to populate the **ALX Airbnb Database** with realistic sample data for development, testing, and learning.

## Files

- `seed.sql` – Inserts sample data into all main tables:
  - `users`
  - `properties`
  - `property_images`
  - `amenities`
  - `property_amenities`
  - `bookings`
  - `payments`
  - `reviews`

## Prerequisites

- The database schema must already exist.
- Run the DDL script from `database-script-0x01/schema.sql` before running this seed script.

The script assumes the database name is:

```sql
alx_airbnb_database

