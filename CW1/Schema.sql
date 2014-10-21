CREATE TABLE drivers (
	id int auto_increment primary key,
	address text, -- Oracle: nclob
	phone_number varchar(20),
	start_date date not null,
	end_date date
);

-- Trigger: before insert set start date to Now() if not already defined

CREATE TABLE cars (
	registration varchar(10) not null primary key,
	registration_date date not null,
	last_mot date,
	car_status ENUM('roadworthy', 'in for service', 'awaiting repair', 'written off'),
	owner_id int not null
);

-- Trigger: before insert set start date to Now() if not already defined

