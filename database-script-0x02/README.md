# Database Schema – ALX Airbnb Database (DataScape)

This directory contains the SQL script that defines the relational database schema for the **Airbnb-like application** used in the ALX Database module.

## Files

- `schema.sql` – SQL DDL script to create the database, tables, constraints, and indexes.

## Requirements

- **MySQL 8.x** (or compatible)
- InnoDB storage engine
- UTF-8 support (the script uses `utf8mb4`)

## How to Run

1. Start your MySQL server.
2. From the project root, run:

   ```bash
   cd database-script-0x01
   mysql -u root -p < schema.sql

