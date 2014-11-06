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
) VALUES ('example', 'example', 'example', CURRENT_TIMESTAMP + INTERVAL '30' MINUTE, 'example', 1000, 'cash', 5);

-- > Create booking for client

INSERT INTO booking_details (
    account_number,
    pickup_location,
    pickup_time,
    dropoff_location,
    price,
    payment_method,
    driver_id
) VALUES (182356, 'Land''s end', CURRENT_TIMESTAMP + INTERVAL '4' HOUR, 'John O'' Groats', 10000, 'cash', 6);

-- > Get today's bookings for driver

SELECT id, client_name, client_phone_number, pickup_location, pickup_time
FROM booking
WHERE driver_name = 'Batman'
AND CAST(pickup_time AS DATE) = SYSDATE;


-- > Get drivers on shift for given date/time

SELECT d.name, d.phone_number, car_registration, end_time
FROM shift s
JOIN driver d
ON s.employee_id = d.id
WHERE start_time <= CURRENT_TIMESTAMP + INTERVAL '4' HOUR
AND end_time > CURRENT_TIMESTAMP + INTERVAL '4' HOUR;

-- > Get operators on shift for given date/time

SELECT o.name, o.phone_number, end_time
FROM shift s
JOIN operator o
ON s.employee_id = o.id
WHERE start_time <= CURRENT_TIMESTAMP + INTERVAL '4' HOUR
AND end_time > CURRENT_TIMESTAMP + INTERVAL '4' HOUR;