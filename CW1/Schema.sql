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

-- Trigger: before insert set start date to Now() if not already defined
-- FK owner_id should reference a person.

CREATE TABLE booking (
	id int auto_increment primary key,
	driver_id int not null,
	client_id int null,
	client_name varchar(150) not null,
	client_phone_number varchar(20) not null,
	pickup_location text not null,
	pickup_time datetime not null default CURRENT_TIMESTAMP
);

-- FK driver_id references employee
-- Validation constraing - driver_id must not reference an operator
-- FK client_id references client
-- Trigger when client_id is not null, client_name/phone_number populates from client table

CREATE TABLE payment (
	booking_id int not null,
	payment_method enum('cash', 'account')
);

-- Validation: account only permitted when booking has a client_id


