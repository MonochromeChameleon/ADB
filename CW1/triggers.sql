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

-- Driver and Operator tables run off the same ID sequence so that we won't end
-- up with duplicate IDs across the two tables. 
CREATE OR REPLACE TRIGGER trg_driver_id
BEFORE INSERT ON driver
FOR EACH ROW BEGIN
  SELECT seq_employee_id.NEXTVAL
  INTO   :new.id
  FROM   DUAL;
END;
/

CREATE OR REPLACE TRIGGER trg_operator_id
BEFORE INSERT ON operator
FOR EACH ROW BEGIN
  SELECT seq_employee_id.NEXTVAL
  INTO   :new.id
  FROM   DUAL;
END;
/

--

CREATE OR REPLACE TRIGGER trg_client_act
BEFORE INSERT ON client
FOR EACH ROW BEGIN
  SELECT seq_account_number.NEXTVAL
  INTO   :new.account_number
  FROM   DUAL;
END;
/

--

CREATE OR REPLACE TRIGGER trg_booking_id
BEFORE INSERT ON booking_details
FOR EACH ROW BEGIN
  SELECT seq_booking_id.NEXTVAL
  INTO   :new.id
  FROM   DUAL;
END;
/

-- ------------------------------------------------- --
-- Triggers to handle defaults on Date / Time fields --
-- ------------------------------------------------- --

-- On creating an employee (driver or operator), set start date to today's date
-- if it hasn't already been specified.
CREATE OR REPLACE TRIGGER trg_drv_start_date
BEFORE INSERT ON driver
FOR EACH ROW BEGIN
  IF (:new.start_date IS NULL) THEN
    SELECT SYSDATE
    INTO   :new.start_date
    FROM   DUAL;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_op_start_date
BEFORE INSERT ON operator
FOR EACH ROW BEGIN
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
FOR EACH ROW BEGIN
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
FOR EACH ROW BEGIN
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
FOR EACH ROW BEGIN
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
-- TODO: WHY THE HELL CAN'T I MAKE THIS WORK?
CREATE OR REPLACE TRIGGER trg_max_operators
BEFORE INSERT ON operator
FOR EACH ROW BEGIN
    IF (SELECT count(id)
        FROM operator
        -- Check dates overlap
        WHERE (start_date <= :new.start_date AND end_date >= :new.start_date)
        OR (end_date >= :new.end_date AND start_date <= :new.end_date) > 8) THEN
        RAISE;
    END IF;
END;
/

-- Bookings shouldn't be created in the past.
-- TODO: WHY THE HELL CAN'T I MAKE THIS WORK?
CREATE OR REPLACE TRIGGER trg_booking_future_validation
BEFORE INSERT ON booking_details
FOR EACH ROW BEGIN
    IF (:new.pickup_time < CURRENT_TIMESTAMP) THEN
        RAISE;
    END IF;
END;
/







-- Trigger: validate employee id here as we can't use a foreign key to a view
-- TODO: I mean this one obviously wasn't going to work if the previous two don't.
CREATE OR REPLACE TRIGGER trg_emp_shift_fk
BEFORE INSERT ON shift
FOR EACH ROW BEGIN
    IF (:new.employee_id IN 
        SELECT id 
        FROM drivers 
        WHERE start_date <= :new.start_time 
        AND (end_date IS NULL OR end_date > :new.end_time)) THEN
        IF ('roadworthy' IN 
            SELECT car_status 
            FROM car 
            WHERE registration = :new.car_registration) THEN
            RAISE; -- enforce that drivers need allocated car that is roadworthy
        END IF;
    ELSE IF (:new.employee_id IN
        SELECT id 
        FROM operators
        WHERE start_date <= :new.start_time 
        AND (end_date IS NULL OR end_date > :new.end_time))
        -- no-op
    ELSE
        RAISE; -- enforce FK to employee who will be employed during this shift
    END IF;
END;
/
