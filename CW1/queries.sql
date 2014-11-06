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

SELECT name, SUM(salary) AS salary
FROM driver_salaries 
WHERE day >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
AND day <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
GROUP BY name;


-- Get net money owed over date range per driver

SELECT d.name, COALESCE(salary, 0) - COALESCE(payments, 0) - COALESCE(cash_takings, 0) net_owed
FROM 
    driver d
LEFT JOIN
    (SELECT id driver_id, name, SUM(salary) AS salary
    FROM driver_salaries
    WHERE day >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
    AND day <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
    GROUP BY id, name) sals
ON d.id = sals.driver_id
LEFT JOIN
    (SELECT driver_id, SUM(
        CASE direction
        WHEN 'payment to driver' THEN amount
        ELSE (- amount)
        END
    ) as payments
    FROM payment
    WHERE payment_date >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
    AND payment_date <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
    GROUP BY driver_id) pmts
ON d.id = pmts.driver_id
LEFT JOIN
    (SELECT driver_id, SUM(price) AS cash_takings
    FROM booking_details
    WHERE CAST(pickup_time AS DATE) >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
    AND CAST(pickup_time AS DATE) <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
    AND payment_method = 'cash'
    GROUP BY driver_id) cash
ON d.id = cash.driver_id;
