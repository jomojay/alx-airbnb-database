# Normalization Summary

The database specifications was refactored to ensure compliance with 3NF by eliminating data redundancy and transitive dependency.

## Original Issues

| Violation             | Table    | Issue Description                                   |
| :-------------------- | :------- | :-------------------------------------------------- |
| redundancy            | Booking  | `total_price` duplicated `pricepernight * days`     |
| Transitive Dependency | Payment  | `amount` depended on `Booking.total_price`          |
| Atomicity             | Property | `location` combined city/state/country in one field |

## Normalization Steps

1. **Removed Derived Data**

- Deleted `Booking.total_price` and `Payment.amount`
- Added `booked_pricepernight` to preserve historical pricing
- **Result**: Eliminated transitive dependencies (3NF compliance).

2. **Location Normalization**

- Created `Location` table with atomic fields: `(city, state, country, postal_code, lat, lng)`
- **Result**: Atomic data storage (1NF compliance).

## Normalization Benefits

- Reduced Redundancy: Location data stored once, reused across properties.
- Historical Accuracy: booked_price_per_night prevents price tampering.
- Query Efficiency: Indexes on foreign keys and geospatial fields (lat, lng).
- Data Integrity: Constraints prevent invalid ratings/dates/prices.

This schema adheres to 3NF with no transitive dependencies or redundant data!
