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
FOR EACH ROW
BEGIN
  SELECT seq_employee_id.NEXTVAL
  INTO   :new.id
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

-- On creating an employee (driver or operator), set start date to today's date
-- if it hasn't already been specified.
CREATE OR REPLACE TRIGGER trg_drv_start_date
BEFORE INSERT ON driver
FOR EACH ROW
BEGIN
  IF (:new.start_date IS NULL) THEN
    SELECT SYSDATE
    INTO   :new.start_date
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

    IF (operator_count > 8) THEN
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
    IF (:new.pickup_time < CURRENT_TIMESTAMP) THEN
        RAISE invalid_timestamp;
    END IF;
END;
/


-- Validate that we are putting a valid employee on shift (i.e. one who is 
-- currently employed) and, where appropriate, that they have been allocated a
-- roadworthy car
CREATE OR REPLACE TRIGGER trg_emp_shift_fk
BEFORE INSERT ON shift
FOR EACH ROW
DECLARE
    id_check int;
    invalid_employee EXCEPTION;
BEGIN
    SELECT id
    INTO id_check
    FROM employee
    WHERE id = :new.employee_id
    AND start_date <= :new.start_time
    AND (end_date IS NULL OR end_date >= :new.end_time);

    -- Assume that we are creating shifts in the future, so we can use our
    -- employees view for validation.
    IF (id_check IS NULL) THEN
        RAISE invalid_employee;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_drv_shift_roadworthy
BEFORE INSERT ON shift
FOR EACH ROW
DECLARE
    car_status_check VARCHAR2(15);
    car_not_roadworthy EXCEPTION;
BEGIN
    IF (:new.car_registration IS NOT NULL) THEN
        SELECT car_status
        INTO car_status_check
        FROM car
        WHERE registration = :new.car_registration;

        IF (car_status_check <> 'roadworthy') THEN
            RAISE car_not_roadworthy;
        END IF;
    END IF;
END;
/
