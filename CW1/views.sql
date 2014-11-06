-- Hybrid view of all current/future employees.
CREATE VIEW employee AS
SELECT id, name, address, phone_number, start_date, end_date, 'driver' as job_type FROM driver WHERE end_date IS NULL OR end_date > SYSDATE
UNION ALL
SELECT id, name, address, phone_number, start_date, end_date, 'operator' as job_type FROM operator WHERE end_date IS NULL OR end_date > SYSDATE
ORDER BY id ASC;




-- View of the salient details for a given booking
CREATE VIEW booking AS
SELECT b.id, COALESCE(b.client_name, c.name) client_name, COALESCE(b.client_phone_number, c.phone_number) client_phone_number, pickup_location, pickup_time, d.name driver_name, d.phone_number, s.car_registration, price, b.payment_method
FROM booking_details b
LEFT JOIN client c
ON b.account_number = c.account_number
LEFT JOIN driver d
ON b.driver_id = d.id
LEFT JOIN shift s
ON s.employee_id = d.id
AND s.start_time <= b.pickup_time
AND s.end_time >= b.pickup_time
ORDER BY pickup_time ASC;


-- Drivers on shift right now
CREATE VIEW drivers_on_shift AS
SELECT d.name, d.phone_number, car_registration, end_time
FROM shift s
JOIN driver d
ON s.employee_id = d.id
WHERE start_time <= CURRENT_TIMESTAMP
AND end_time > CURRENT_TIMESTAMP;

-- Operators on shift right now
CREATE VIEW operators_on_shift AS
SELECT o.name, o.phone_number, end_time
FROM shift s
JOIN operator o
ON s.employee_id = o.id
WHERE start_time <= CURRENT_TIMESTAMP
AND end_time > CURRENT_TIMESTAMP;


-- Driver salary view

CREATE VIEW driver_salaries AS
SELECT id, name, day, SUM(salary) as salary
FROM (
    SELECT d.id id, d.name name, CAST(start_time AS DATE) day, d.payment_rate * TO_NUMBER(SUBSTR((end_time - start_time), INSTR((end_time - start_time),' ')+1,2)) as salary
    FROM driver d
    LEFT JOIN shift s
    ON s.employee_id = d.id
    AND d.payment_method = 'hourly'
    UNION
    SELECT d.id id, d.name name, CAST(pickup_time AS DATE) day, d.payment_rate * b.price / 100 as salary
    FROM driver d
    LEFT JOIN booking_details b
    ON b.driver_id = d.id
    AND d.payment_method = 'percent'
) GROUP BY id, name, day;