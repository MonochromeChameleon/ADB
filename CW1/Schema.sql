CREATE TABLE drivers (
	id int auto_increment primary key,
	address text, -- Oracle: nclob
	phone_number varchar(20),
	start_date date not null default CURRENT_TIMESTAMP,
	end_date date
);

CREATE TABLE cars (
	registration varchar(10) not null primary key,
	registration_date date not null default CURRENT_DATE,
	last_mot date,
	car_status ENUM('roadworthy', 'in for service', 'awaiting repair', 'written off'),
	owner_id int not null
);

