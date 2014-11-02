-- Delete everything without failing on foreign keys

DROP VIEW booking;
DROP SEQUENCE seq_booking_id;
DROP TABLE booking_details;
DROP VIEW employee;
DROP TABLE car;
DROP TABLE client;
DROP SEQUENCE seq_account_number;
DROP TABLE driver;
DROP TABLE operator;
DROP SEQUENCE seq_employee_id;

-- Create schema

CREATE TABLE driver (
    id int NOT NULL PRIMARY KEY,
    name VARCHAR2(150) NOT NULL,
    address NCLOB,
    phone_number VARCHAR2(20),
    start_date DATE NOT NULL,
    end_date DATE
);

CREATE TABLE operator (
    id int NOT NULL PRIMARY KEY,
    name VARCHAR2(150) NOT NULL,
    address NCLOB,
    phone_number VARCHAR2(20),
    start_date DATE NOT NULL,
    end_date DATE
);

CREATE SEQUENCE seq_employee_id;

-- Trigger: auto-increment employee ids
CREATE OR REPLACE TRIGGER trg_driver_id
BEFORE INSERT ON driver
FOR EACH ROW BEGIN
  SELECT seq_employee_id.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/

CREATE OR REPLACE TRIGGER trg_operator_id
BEFORE INSERT ON operator
FOR EACH ROW BEGIN
  SELECT seq_employee_id.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/

-- Trigger: before insert set start date to today's date if not already defined
CREATE OR REPLACE TRIGGER trg_drv_start_date
BEFORE INSERT ON driver
FOR EACH ROW BEGIN
  IF (:new.start_date IS NULL) THEN
    SELECT SYSDATE
    INTO   :new.start_date
    FROM   dual;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_op_start_date
BEFORE INSERT ON operator
FOR EACH ROW BEGIN
  IF (:new.start_date IS NULL) THEN
    SELECT SYSDATE
    INTO   :new.start_date
    FROM   dual;
  END IF;
END;
/

-- Hybrid view of all employees
CREATE VIEW employee AS
SELECT id, name, address, phone_number, start_date, 'driver' as job_type FROM driver WHERE end_date IS NULL OR end_date > SYSDATE
UNION ALL
SELECT id, name, address, phone_number, start_date, 'operator' as job_type FROM operator WHERE end_date IS NULL OR end_date > SYSDATE
ORDER BY id ASC;


CREATE TABLE client (
    account_number int NOT NULL PRIMARY KEY,
    name VARCHAR2(150) NOT NULL,
    phone_number VARCHAR2(20) NOT NULL,
    client_type VARCHAR2(9) NOT NULL,
    CONSTRAINT chk_client_type CHECK (client_type IN ('corporate', 'private')),
    CONSTRAINT unq_phone_number UNIQUE (phone_number)
);

-- Make account numbers look like "real" account numbers
CREATE SEQUENCE seq_account_number
  START WITH 182356
  INCREMENT BY 87
  NOMAXVALUE;

-- Trigger: auto-increment client ids
CREATE OR REPLACE TRIGGER trg_client_act
BEFORE INSERT ON client
FOR EACH ROW BEGIN
  SELECT seq_account_number.NEXTVAL
  INTO   :new.account_number
  FROM   dual;
END;
/

CREATE TABLE car (
    registration VARCHAR2(10) NOT NULL PRIMARY KEY,
    registration_date DATE NOT NULL,
    last_mot DATE,
    car_status VARCHAR2(15) DEFAULT 'roadworthy' NOT NULL,
    owner_id INT NOT NULL,
    CONSTRAINT chk_car_status CHECK (car_status IN ('roadworthy', 'in for service', 'awaiting repair', 'written off')),
    CONSTRAINT fk_car_owner FOREIGN KEY (owner_id) REFERENCES driver(id)
);

-- Trigger: before insert set registration date to Now() if not already defined
CREATE OR REPLACE TRIGGER trg_car_reg_date
BEFORE INSERT ON car
FOR EACH ROW BEGIN
  IF (:new.registration_date IS NULL) THEN
    SELECT SYSDATE
    INTO   :new.registration_date
    FROM   dual;
  END IF;
END;
/

-- Assumption: This is a UK-based minicab company, which means that, legally, 
-- all cars must be booked in advance, and prices agreed up-front.

CREATE TABLE booking_details (
    id int NOT NULL primary key,
    driver_id int NOT NULL,
    account_number int NULL,
    client_name VARCHAR2(150) NOT NULL,
    client_phone_number VARCHAR2(20) NOT NULL,
    pickup_location NCLOB NOT NULL,
    pickup_time TIMESTAMP NOT NULL,
    dropoff_location NCLOB NOT NULL,
    -- Assumption: price is in pence to avoid floating point maths.
    price int NOT NULL,
    payment_method VARCHAR2(7) NOT NULL,
    recurrence int NULL,
    CONSTRAINT chk_payment_method CHECK (payment_method IN ('account', 'cash', 'card')),
    CONSTRAINT fk_driver_id FOREIGN KEY (driver_id) REFERENCES driver (id),
    CONSTRAINT fk_account_number FOREIGN KEY (account_number) REFERENCES client (account_number)
);

CREATE SEQUENCE seq_booking_id;

-- Trigger: auto-increment booking ids
CREATE OR REPLACE TRIGGER trg_booking_id
BEFORE INSERT ON booking_details
FOR EACH ROW BEGIN
  SELECT seq_booking_id.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/

-- Trigger: before insert set pickup time to Now() if not already defined
CREATE OR REPLACE TRIGGER trg_booking_pickup_time
BEFORE INSERT ON booking_details
FOR EACH ROW BEGIN
  IF (:new.pickup_time IS NULL) THEN
    SELECT CURRENT_TIMESTAMP
    INTO   :new.pickup_time
    FROM   dual;
  END IF;
END;
/


-- TODO: join this to the shifts to get the car registration
CREATE VIEW booking AS
SELECT COALESCE(b.client_name, c.name) client_name, COALESCE(b.client_phone_number, c.phone_number) client_phone_number, pickup_location, pickup_time, d.name driver_name, price, payment_method
FROM booking_details b
JOIN client c
ON b.account_number = c.account_number
JOIN driver d
ON b.driver_id = d.id
WHERE pickup_time > SYSDATE
ORDER BY pickup_time ASC;

-- Assumption - drivers might be allocated different cars on different shifts
CREATE TABLE shift (
    driver_id int NOT NULL,
    car_registration VARCHAR2(10) NOT NULL ,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    CONSTRAINT fk_driver_shift FOREIGN KEY (driver_id) REFERENCES driver(id),
    CONSTRAINT fk_car_reg FOREIGN KEY (car_registration) REFERENCES car(registration)
);

CREATE VIEW drivers_on_shift AS
SELECT d.name, d.phone_number, car_registration, end_time
FROM shift s
JOIN driver d
ON s.driver_id = d.id
WHERE start_time < CURRENT_TIMESTAMP
AND end_time > CURRENT_TIMESTAMP;

-- FK employee_id references employee(id)

-- Queries
-- > Create booking for non-client
-- > Create booking for client
-- > Get today's bookings for driver
-- > Get drivers on shift for given date/time
-- > Get operators on shift for given date/time
-- > Take payment

-- Data! --

INSERT ALL 
  INTO operator (name, address, phone_number) VALUES ('James Jameson', '123 Road Street, London, N1 1NN', '0207123456')
  INTO operator (name, address, phone_number) VALUES ('Robert Robertson', 'Flat 1, Flat Street Apartments, Flat Street, London, E6 6EE', '07777777777')
  INTO operator (name, address, phone_number) VALUES ('Michael Michaels', 'The bungalow, Lane street, London, SW18 18WS', '+44208999999')
  INTO operator (name, address, phone_number) VALUES ('Andy Andrews', 'Our house, In the middle of our street', '+39728739992')
SELECT 1 FROM dual;

INSERT ALL
  INTO driver (name, address, phone_number) VALUES ('Bilbo Baggins', 'Bag End, Hobbiton, Middle Earth', '+897838792874')
  INTO driver (name, address, phone_number) VALUES ('Smaug', 'The lonely mountain', '+666666666')
  INTO driver (name, address, phone_number) VALUES ('Batman', 'Wayne Manor, Near Gotham', 'Red phone')
  INTO driver (name, address, phone_number) VALUES ('Superman', 'Fortress of solitude, The Arctic', '+1-800-SUPERMAN')
  INTO driver (name, address, phone_number) VALUES ('Wolverine', 'The Xavier School for Gifted Children', '01234567890')
  INTO driver (name, address, phone_number) VALUES ('Apocalypse', 'Egypt', '00000000000')
SELECT 1 FROM dual;

INSERT ALL
  INTO car (registration, registration_date, owner_id) VALUES ('AB14 ABC', TO_DATE('2014-05-01', 'yyyy-mm-dd'), 5)
  INTO car (registration, registration_date, last_mot, owner_id) VALUES ('RRRRRRRR', TO_DATE('2001-01-01', 'yyyy-mm-dd'), TO_DATE('2014-01-01', 'yyyy-mm-dd'), 6)
  INTO car (registration, registration_date, owner_id) VALUES ('BAT 1', null, 7)
  INTO car (registration, registration_date, owner_id) VALUES ('SUPES', null, 8)
  INTO car (registration, registration_date, last_mot, car_status, owner_id) VALUES   ('X12 XXX', TO_DATE('2012-04-06', 'yyyy-mm-dd'), TO_DATE('2014-03-31', 'yyyy-mm-dd'), 'awaiting repair', 9)
  INTO car (registration, registration_date, last_mot, owner_id) VALUES ('NS 4BANR', TO_DATE('1000-01-01', 'yyyy-mm-dd'), TO_DATE('2014-01-01', 'yyyy-mm-dd'), 10)
SELECT 1 FROM dual;


