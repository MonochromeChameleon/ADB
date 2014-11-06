-- Create schema

-- Design decision: We could have a single table for employees with their
-- employee type (driver/operator) as a field. There's lots of situations where
-- we want to have a foreign key referencing drivers though, and splitting into
-- two tables allows us to use a basic foreign key without needing to enforce
-- that the employee to which that foreign key refers is a driver.

-- In a real system, there may well also be additional fields on a driver that
-- aren't necessarily relevant for other employees e.g. driving license details.

-- SPEC
-- Drivers: including details of where they live, their other contact details 
-- and information about their employment record with the Company.

-- Assume address, phone number and start/end dates are sufficient to meet that 
-- specification.

CREATE TABLE driver (
    id int NOT NULL PRIMARY KEY,
    name VARCHAR2(150) NOT NULL,
    address NCLOB,
    phone_number VARCHAR2(20),
    start_date DATE NOT NULL,
    end_date DATE
);


-- SPEC
-- Operators: the taxi firm employs 8 operators who take and allocate bookings 
-- to drivers.

-- Assume same table structure as drivers. 8 operators is enforced as a DB 
-- trigger
CREATE TABLE operator (
    id int NOT NULL PRIMARY KEY,
    name VARCHAR2(150) NOT NULL,
    address NCLOB,
    phone_number VARCHAR2(20),
    start_date DATE NOT NULL,
    end_date DATE
);


-- SPEC
-- Cars: details of the registration number, age, date of last MOT test, 
-- status of cars: e.g. roadworthy, in for service, awaiting repair, written off
-- details of who owns the car.

-- Assume owner is a driver, so those details can be defined by a foreign key.
CREATE TABLE car (
    registration VARCHAR2(10) NOT NULL PRIMARY KEY,
    registration_date DATE NOT NULL, -- Defines age of car
    last_mot DATE,                   -- Null for a new car
    car_status VARCHAR2(15) DEFAULT 'roadworthy' NOT NULL,
    owner_id INT NOT NULL,
    CONSTRAINT chk_car_status CHECK (car_status IN ('roadworthy', 'in for service', 'awaiting repair', 'written off')),
    CONSTRAINT fk_car_owner FOREIGN KEY (owner_id) REFERENCES driver(id)
);


-- SPEC
-- Clients: in addition to taking whatever bookings come in via the phone, the
-- Company has a number of registered clients who have regular bookings. there
-- are two types of client, corporate and private. Clients can make regular 
-- bookings, the details of which must be stored. This may be for example daily 
-- bookings, once a week, etc.

CREATE TABLE client (
    account_number int NOT NULL PRIMARY KEY,
    name VARCHAR2(150) NOT NULL,
    phone_number VARCHAR2(20) NOT NULL,
    client_type VARCHAR2(9) NOT NULL,
    CONSTRAINT chk_client_type CHECK (client_type IN ('corporate', 'private')),
    CONSTRAINT unq_phone_number UNIQUE (phone_number)
);


-- Assume that recurrent bookings are converted into actual bookings based on a
-- scheduled job. That scheduled job should output details of the bookings it
-- creates for each run and those results would be checked - i.e. if a job is 
-- scheduled to be monthly on the fourth, the recurrence should be set to 30 and 
-- the notes would be used to record the exact specification for manual 
-- verification.
-- Each time that job runs, it should update the next occurrence.

-- Because a recurrent booking would be converted into an 'actual' booking each
-- time that it occurs, there's no referential integrity / financial accounting 
-- concerns with just deleting or modifying this record as and when a client 
-- cancels or changes their booking.

-- TODO: This is an ill-thought-out mess.
CREATE TABLE recurring_booking (
    client_account int NOT NULL,
    pickup_location NCLOB NOT NULL,
    dropoff_location NCLOB NOT NULL,
    next_occurence TIMESTAMP NOT NULL,
    price int NOT NULL,
    recurrence int NOT NULL,
    notes NCLOB,
    CONSTRAINT fk_client_recurrent_booking FOREIGN KEY (client_account) REFERENCES client(account_number)
);


-- SPEC
-- Bookings: details of bookings taken over the phone

-- Assume that this is a UK-based minicab company, which means that, legally, 
-- all cars must be booked in advance, and prices agreed up-front.

-- Booking may or may not be associated with an account, but assume that account
-- bookings and non-account bookings go into the same table.

CREATE TABLE booking_details (
    id int NOT NULL primary key,
    driver_id int NOT NULL,
    account_number int NULL,
    client_name VARCHAR2(150) NOT NULL,
    client_phone_number VARCHAR2(20) NOT NULL,
    pickup_location NCLOB NOT NULL,
    pickup_time TIMESTAMP NOT NULL,
    dropoff_location NCLOB NOT NULL,
    price int NOT NULL, -- price is in pence to avoid floating point maths
    payment_method VARCHAR2(7) NOT NULL,
    CONSTRAINT chk_payment_method CHECK (payment_method IN ('account', 'cash', 'card')),
    CONSTRAINT fk_driver_id FOREIGN KEY (driver_id) REFERENCES driver (id),
    CONSTRAINT fk_account_number FOREIGN KEY (account_number) REFERENCES client (account_number)
);


-- SPEC
-- Shifts: the drivers work a shift system in order to ensure the Company is 
-- effective over 24 hours. You need to be able to track which drivers are on 
-- which shift. Similarly the operators work a shift system to cover each 24 
-- hour period

-- Assumption - drivers might be allocated different cars on different shifts.
-- We can use the same underlying table for all shifts, whether they are operator
-- or driver ones.
CREATE TABLE shift (
    employee_id int NOT NULL,
    car_registration VARCHAR2(10) NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    CONSTRAINT fk_car_reg FOREIGN KEY (car_registration) REFERENCES car(registration)
);

-- SPEC
-- Revenue: you need to be able to record the amount of money earned by drivers 
-- and the amount paid by them to the Company (to cover costs of car maintainance,
-- salaries of operators, lighting, heating etc of the taxi office). Drivers can
-- be employed by the Company either on a fixed-fee or percentage-of-receipts
-- basis.
CREATE TABLE payment (
    driver_id int NOT NULL,
    amount int NOT NULL, -- assume pence again to avoid floating-point maths
    notes NCLOB,
    payment_date DATE NOT NULL
);

