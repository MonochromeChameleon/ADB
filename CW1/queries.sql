-- Sample queries

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
-- Use the booking view to get the client details regardless of whether it is 
-- an account booking or not
FROM booking 
-- Change driver_name depending on who you want to query on
WHERE driver_name = 'Batman'
-- Casting the pickup time to a date will discard the Hour/minute component.
AND CAST(pickup_time AS DATE) = SYSDATE;



-- > Get drivers on shift, and their allocated car, for given date/time

SELECT d.name, d.phone_number, car_registration, end_time
FROM shift s
JOIN driver d
ON s.employee_id = d.id
-- Replace "CURRENT_TIMESTAMP + INTERVAL '4' HOUR" with the time of interest
WHERE start_time <= CURRENT_TIMESTAMP + INTERVAL '4' HOUR
AND end_time > CURRENT_TIMESTAMP + INTERVAL '4' HOUR;

-- > Get operators on shift for given date/time

SELECT o.name, o.phone_number, end_time
FROM shift s
JOIN operator o
ON s.employee_id = o.id
-- Replace "CURRENT_TIMESTAMP + INTERVAL '4' HOUR" with the time of interest
WHERE start_time <= CURRENT_TIMESTAMP + INTERVAL '4' HOUR
AND end_time > CURRENT_TIMESTAMP + INTERVAL '4' HOUR;


-- > Get takings per driver over given date range

SELECT d.name, SUM(price)
FROM booking_details b
JOIN driver d
ON b.driver_id = d.id
-- Replace the date range as required
WHERE CAST(pickup_time AS DATE) >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
AND CAST(pickup_time AS DATE) <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
-- Aggregate all the bookings by driver to determine their total takings 
-- over the period.
GROUP BY d.name;


--> Same as above, grouped by payment method.

SELECT d.name, b.payment_method, SUM(price)
FROM booking_details b
JOIN driver d
ON b.driver_id = d.id
WHERE CAST(pickup_time AS DATE) >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
AND CAST(pickup_time AS DATE) <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
-- Group by name & payment method so we can see each driver's total takings
-- in cash, card and account jobs.
GROUP BY d.name, b.payment_method;


-- Get total hours worked per driver over given date range

-- TO_NUMBER(SUBSTR(.....)) converts the difference between two timestamps to an
-- ingteger number of hours. We can then aggregate that to get the total hours
-- worked in a date range
SELECT d.name, SUM(TO_NUMBER(SUBSTR((end_time - start_time), INSTR((end_time - start_time),' ')+1,2))) as total_hours
FROM shift s
JOIN driver d
ON s.employee_id = d.id
-- Replace the date range as required.
WHERE CAST(start_time AS DATE) >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
AND CAST(end_time AS DATE) <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
GROUP BY d.name;


-- Get salary earned per driver over given date range

SELECT name, SUM(salary) AS salary
-- driver_salaries already takes into account whether the driver is paid by the
-- hour, or as a percentage, so we can simply aggregate over a date range.
FROM driver_salaries 
WHERE day >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
AND day <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
GROUP BY name;


-- Get net money owed over date range per driver

-- The money owed is the driver's salary, minus the balance of payments made to
-- the driver in that time, minus any cash takings (i.e. non-account, non-card
-- bookings) they have made.
SELECT d.name, COALESCE(salary, 0) - COALESCE(payments, 0) - COALESCE(cash_takings, 0) net_owed
FROM 
    -- select all drivers
    driver d
LEFT JOIN
    -- join onto the salaries table for the date range of interest.
    -- Use a left join to ensure that we always get an output row for every driver.
    (SELECT id driver_id, SUM(salary) AS salary
    FROM driver_salaries
    WHERE day >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
    AND day <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
    GROUP BY id) sals
ON d.id = sals.driver_id
LEFT JOIN
    -- join onto the payments table for the date range, again with a left join
    (SELECT driver_id, SUM(
        -- The case statement handles payments made by as well as to the driver
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
    -- join onto the booking_details table to determine how much cash the driver
    -- has taken over the date range.
    (SELECT driver_id, SUM(price) AS cash_takings
    FROM booking_details
    WHERE CAST(pickup_time AS DATE) >= TO_DATE('2014-01-01', 'yyyy-mm-dd')
    AND CAST(pickup_time AS DATE) <= TO_DATE('2020-01-01', 'yyyy-mm-dd')
    AND payment_method = 'cash'
    GROUP BY driver_id) cash
ON d.id = cash.driver_id;
