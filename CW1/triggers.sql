-- Sequences for automatically-incrementing IDs

CREATE SEQUENCE seq_employee_id;

-- Make account numbers look like "real" account numbers
CREATE SEQUENCE seq_account_number
  START WITH 182356
  INCREMENT BY 87
  NOMAXVALUE;

CREATE SEQUENCE seq_booking_id;

-- ---------------------------------- --
-- Triggers to set ids from sequences --
-- ---------------------------------- --

-- All of the triggers in this section set the ID value when inserting a new value into
-- driver, operator, client or booking_details

-- Driver and Operator tables run off the same ID sequence so that we won't end
-- up with duplicate IDs across the two tables. 
CREATE OR REPLACE TRIGGER trg_driver_id
BEFORE INSERT ON driver
FOR EACH ROW
BEGIN
  SELECT seq_employee_id.NEXTVAL -- Get the next ID value in the sequence
  INTO   :new.id                 -- Set that as the ID value on the new entry
  FROM   DUAL;
END;
/

CREATE OR REPLACE TRIGGER trg_operator_id
BEFORE INSERT ON operator
FOR EACH ROW
BEGIN
  SELECT seq_employee_id.NEXTVAL
  INTO   :new.id
  FROM   DUAL;
END;
/

--

CREATE OR REPLACE TRIGGER trg_client_act
BEFORE INSERT ON client
FOR EACH ROW
BEGIN
  SELECT seq_account_number.NEXTVAL
  INTO   :new.account_number
  FROM   DUAL;
END;
/

--

CREATE OR REPLACE TRIGGER trg_booking_id
BEFORE INSERT ON booking_details
FOR EACH ROW
BEGIN
  SELECT seq_booking_id.NEXTVAL
  INTO   :new.id
  FROM   DUAL;
END;
/

-- ------------------------------------------------- --
-- Triggers to handle defaults on Date / Time fields --
-- ------------------------------------------------- --

-- All of the triggers in this section set default values for not-null date- and
-- time-related fields on creating a new record.

-- On creating an employee (driver or operator), set start date to today's date
-- if it hasn't already been specified.
CREATE OR REPLACE TRIGGER trg_drv_start_date
BEFORE INSERT ON driver
FOR EACH ROW
BEGIN
  IF (:new.start_date IS NULL) THEN -- If the start date has not been specified
    SELECT SYSDATE                  -- Get today's date
    INTO   :new.start_date          -- Use that as the start date
    FROM   DUAL;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_op_start_date
BEFORE INSERT ON operator
FOR EACH ROW
BEGIN
  IF (:new.start_date IS NULL) THEN
    SELECT SYSDATE
    INTO   :new.start_date
    FROM   DUAL;
  END IF;
END;
/

--

-- On creating a car, set registration date to today's date unless it has been
-- explicitly specified.
CREATE OR REPLACE TRIGGER trg_car_reg_date
BEFORE INSERT ON car
FOR EACH ROW
BEGIN
  IF (:new.registration_date IS NULL) THEN
    SELECT SYSDATE
    INTO   :new.registration_date
    FROM   DUAL;
  END IF;
END;
/

--

-- On creating a booking, set pickup time to the current time/date unless it has
-- been explicitly specified.
CREATE OR REPLACE TRIGGER trg_booking_pickup_time
BEFORE INSERT ON booking_details
FOR EACH ROW
BEGIN
  IF (:new.pickup_time IS NULL) THEN
    SELECT CURRENT_TIMESTAMP
    INTO   :new.pickup_time
    FROM   DUAL;
  END IF;
END;
/

--

-- On creating a payment, set payment date to today unless it has been specified
CREATE OR REPLACE TRIGGER trg_payment_date
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    IF (:new.payment_date IS NULL) THEN
        SELECT SYSDATE
        INTO :new.payment_date
        FROM DUAL;
    END IF;
END;
/


-- ---------------------------- --
-- Triggers handling validation --
-- ---------------------------- --

-- Enforce no more than 8 operators
CREATE OR REPLACE TRIGGER trg_max_operators
BEFORE INSERT ON operator
FOR EACH ROW
DECLARE
    too_many_operators EXCEPTION;
    operator_count NUMBER(10);
BEGIN
    SELECT count(id)
    INTO operator_count
    FROM operator
    -- Check whether dates overlap
    WHERE (start_date <= :new.start_date AND (end_date IS NULL OR end_date >= :new.start_date));

    IF (operator_count > 8) THEN -- If we have determined that there are too many 
                                 -- operators with overlapping employent dates,
                                 -- then we should raise an exception.
        RAISE too_many_operators;
    END IF;
END;
/

-- Bookings shouldn't be created in the past.
CREATE OR REPLACE TRIGGER trg_booking_future_validation
BEFORE INSERT ON booking_details
FOR EACH ROW
DECLARE invalid_timestamp EXCEPTION;
BEGIN
    -- If we are creating a new booking then the pickup time must be greater than
    -- or equal to the current timestamp. If that is not the case, raise an
    -- exception.
    IF (:new.pickup_time < CURRENT_TIMESTAMP) THEN
        RAISE invalid_timestamp;
    END IF;
END;
/


-- Validate that we are putting a valid employee on shift (i.e. one who is 
-- currently employed)
CREATE OR REPLACE TRIGGER trg_emp_shift_fk
BEFORE INSERT ON shift
FOR EACH ROW
DECLARE
    id_check int;
    invalid_employee EXCEPTION;
BEGIN
    -- Check that the employee_id on the shift that we are creating corresponds
    -- to an employee whose start_date and end_date overlaps with the shift.
    SELECT id
    INTO id_check
    -- Assume that we are creating shifts in the future, so we can use our
    -- employees view for validation.
    FROM employee
    WHERE id = :new.employee_id
    AND start_date <= :new.start_time
    AND (end_date IS NULL OR end_date >= :new.end_time);

    -- If no matching ID is found then the employee we are assigning to the 
    -- shift is invalid
    IF (id_check IS NULL) THEN
        RAISE invalid_employee;
    END IF;
END;
/

-- Validate that we are assigning a roadworthy car to an employee for their
-- shift
CREATE OR REPLACE TRIGGER trg_drv_shift_roadworthy
BEFORE INSERT ON shift
FOR EACH ROW
DECLARE
    car_status_check VARCHAR2(15);
    car_not_roadworthy EXCEPTION;
BEGIN
    -- Ignore shifts where the car registration is null (operator shifts)
    IF (:new.car_registration IS NOT NULL) THEN
        -- Find the status of the car being assigned
        SELECT car_status
        INTO car_status_check
        FROM car
        WHERE registration = :new.car_registration;

        -- If that car is not roadworthy, raise an exception
        IF (car_status_check <> 'roadworthy') THEN
            RAISE car_not_roadworthy;
        END IF;
    END IF;
END;
/


-- When assigning a driver to a booking, we need to check that driver is
-- on shift at the pickup time
CREATE OR REPLACE TRIGGER trg_booking_driver_shift
BEFORE INSERT OR UPDATE ON booking_details
FOR EACH ROW
DECLARE
    shift_time_check TIMESTAMP;
    driver_not_on_shift EXCEPTION;
BEGIN
    -- Ignore bookings where the driver has not been assigned yet.
    IF (:new.driver_id IS NOT NULL) THEN
        -- Find the shift for that driver whose start time is before the pickup
        -- time, and whose end time is after the pickup time.
        SELECT start_time
        INTO shift_time_check
        FROM shift
        WHERE employee_id = :new.driver_id
        AND start_time <= :new.pickup_time
        AND end_time >= :new.pickup_time;

        -- If no shift can be found, then that driver is an invalid assignment,
        -- so we should raise an exception.
        IF (shift_time_check IS NULL) THEN
            RAISE driver_not_on_shift;
        END IF;
    END IF;
END;
/
