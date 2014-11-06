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

-- > Get takings per driver over given date range

SELECT d.name, SUM(price)
FROM booking_details b
JOIN driver d
ON b.driver_id = d.id
WHERE CAST(pickup_time AS DATE) >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
AND CAST(pickup_time AS DATE) <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
GROUP BY d.name;

-- Same as above, grouped by payment method.

SELECT d.name, b.payment_method, SUM(price)
FROM booking_details b
JOIN driver d
ON b.driver_id = d.id
WHERE CAST(pickup_time AS DATE) >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
AND CAST(pickup_time AS DATE) <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
GROUP BY d.name, b.payment_method;


-- Get total hours worked per driver over given date range

SELECT d.name, SUM(TO_NUMBER(SUBSTR((end_time - start_time), INSTR((end_time - start_time),' ')+1,2))) as total_hours
FROM shift s
JOIN driver d
ON s.employee_id = d.id
WHERE CAST(start_time AS DATE) >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
AND CAST(end_time AS DATE) <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
GROUP BY d.name;


-- Get salary earned per driver over given date range

SELECT name, SUM(salary) as salary
FROM (
    SELECT d.name name, d.payment_rate * TO_NUMBER(SUBSTR((end_time - start_time), INSTR((end_time - start_time),' ')+1,2)) as salary
    FROM shift s
    JOIN driver d
    ON s.employee_id = d.id
    WHERE CAST(start_time AS DATE) >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
    AND CAST(end_time AS DATE) <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
    AND d.payment_method = 'hourly'
    UNION
    SELECT d.name name, d.payment_rate * b.price / 100 as salary
    FROM booking_details b
    JOIN driver d
    ON b.driver_id = d.id
    WHERE CAST(pickup_time AS DATE) >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
    AND CAST(pickup_time AS DATE) <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
    AND d.payment_method = 'percent'
) GROUP BY name;

