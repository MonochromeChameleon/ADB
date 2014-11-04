-- > Create booking for non-client

INSERT INTO booking_details (
    client_name,
    client_phone_number,
    pickup_location,
    pickup_time,
    dropoff_location,
    price,
    payment_method,
    driver_id
) VALUES ('example', 'example', 'example', CURRENT_TIMESTAMP + INTERVAL, 'example', 1000, 'cash', 5);

-- > Create booking for client



-- > Get today's bookings for driver
-- > Get drivers on shift for given date/time
-- > Get operators on shift for given date/time


