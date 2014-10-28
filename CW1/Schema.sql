CREATE TABLE employee (
    id int auto_increment primary key,
    name varchar(150) not null,
    address text, -- Oracle: nclob
    phone_number varchar(20),
    start_date date not null,
    end_date date,
    job ENUM('driver', 'operator')
);

-- Trigger: before insert set start date to Now() if not already defined
-- Validation constraint: max 8 operators

CREATE TABLE client (
    id int auto_increment primary key,
    name varchar(150) not null,
    phone_number varchar(20) not null,
    client_type ENUM('corporate', 'private')
);

CREATE TABLE car (
    registration varchar(10) not null primary key,
    registration_date date not null,
    last_mot date,
    car_status ENUM('roadworthy', 'in for service', 'awaiting repair', 'written off'),
    owner_id int not null
);

-- Trigger: before insert set registration date to Now() if not already defined
-- FK owner_id should reference a person.

CREATE TABLE booking (
    id int auto_increment primary key,
    driver_id int not null,
    client_id int null,
    client_name varchar(150) not null,
    client_phone_number varchar(20) not null,
    pickup_location text not null,
    pickup_time datetime not null default CURRENT_TIMESTAMP,
    recurrence int null
);

-- FK driver_id references employee
-- Validation constraint - driver_id must not reference an operator
-- FK client_id references client
-- Trigger when client_id is not null, client_name/phone_number populates from client table
-- Validation constraint: recurrence must be null unless client_id is not null

CREATE TABLE payment (
    booking_id int not null,
    payment_method enum('cash', 'account'),
    amount int not null
);

-- Assumption: amount is in pence/cents/whatever to avoid floating point maths.
-- Validation: account only permitted when booking has a client_id
-- Trigger: on creation, if booking has a not-null recurrence, create a new booking for the next instance

CREATE TABLE shift (
    employee_id int not null,
    start_time datetime not null,
    end_time datetime not null
);

-- FK employee_id references employee(id)

-- Queries
-- > Create booking for non-client
-- > Create booking for client
-- > Get today's bookings for driver
-- > Get drivers on shift for given date/time
-- > Get operators on shift for given date/time
-- > Take payment

-- Data! --

INSERT INTO employee (name, address, phone_number, job) VALUES
  ('James Jameson', '123 Road Street, London, N1 1NN', '0207123456', 'operator'),
  ('Robert Robertson', 'Flat 1, Flat Street Apartments, Flat Street, London, E6 6EE', '07777777777', 'operator'),
  ('Michael Michaels', 'The bungalow, Lane street, London, SW18 18WS', '+44208999999', 'operator'),
  ('Andy Andrews', 'Our house, In the middle of our street', '+39728739992', 'operator'),
  
  ('Bilbo Baggins', 'Bag End, Hobbiton, Middle Earth', '+897838792874', 'driver'),
  ('Smaug', 'The lonely mountain', '+666666666', 'driver'),
  ('Batman', 'Wayne Manor, Near Gotham', 'Red phone', 'driver'),
  ('Superman', 'Fortress of solitude, The Arctic', '+1-800-SUPERMAN', 'driver'),
  ('Wolverine', 'The Xavier School for Gifted Children', '01234567890', 'driver'),
  ('Apocalypse', 'Egypt', '00000000000', 'driver');

INSERT INTO car (registration, registration_date, last_mot, car_status, owner_id) VALUES
  ('AB14 ABC', TO_DATE('2014-05-01'), null, 'roadworthy', 5),
  ('RRRRRRRR', TO_DATE('2001-01-01'), TO_DATE('2014-01-01'), 'roadworthy', 6),
  ('BAT 1', null, null, 'roadworthy', 7),
  ('SUPES', null, null, 'roadworthy', 8),
  ('X12 XXX', TO_DATE('2012-04-06'), TO_DATE('2014-03-31'), 'awaiting repair', 9),
  ('NS 4BANR', TO_DATE('0000-01-01'), TO_DATE('2014-01-01'), 'roadworthy', 10);


