# AirBnB ERD

```text
// Use DBML to define your database structure
// Docs: https://dbml.dbdiagram.io/docs

Table users {
user_id uuid [primary key]
first_name varchar [not null]
last_name varchar [not null]
email varchar [not null, unique]
password_hash varchar [not null]
phone_number varchar [null]
role role_enum [not null]
created_at timestamp [default: `current_timestamp`]

indexes {
email
}
}

enum role_enum {
guest
host
admin
}

Table properties {
property_id uuid [primary key]
host_id uuid [ref: > users.user_id]
location_id uuid [ref: > locations.location_id]
name varchar [not null]
description text [not null]
pricepernight decimal [not null]
created_at timestamp [default: `current_timestamp`]
updated_at timestamp [note: "On Update set `current_timestamp`]

indexes {
host_id
location_id
}
}

Table bookings {
booking_id uuid [primary key]
property_id uuid [ref: > properties.property_id]
user_id uuid [ref: > users.user_id]
start_date date [not null]
end_date date [not null]
booked_pricepernight decimal [not null]
status booking_status [not null]
created_at timestamp [default: `current_timestamp`]

indexes {
property_id
start_date, end_date
}
}

enum booking_status {
pending
confirmed
canceled
}

Table payments {
payment_id uuid [primary key]
booking_id uuid [ref: > bookings.booking_id]
payment_date timestamp [default: `current_timestamp`]
payment_method payment_method [not null]

indexes {
booking_id
payment_date
}
}

enum payment_method_enum {
credit_card
paypal
stripe
}

Table reviews {
review_id uuid [primary key]
property_id uuid [ref: > properties.property_id]
user_id uuid [ref: > users.user_id]
rating integer [not null, note: 'rating BETWEEN 1 AND 5']
comment text [not null]
created_at timestamp [default: `current_timestamp`]
}

Table messages {
message_id uuid [primary key]
sender_id uuid [ref: > users.user_id]
recipient_id uuid [ref: > users.user_id]
message_body text [not null]
sent_at timestamp [default: `current_timestamp`]
}
```
