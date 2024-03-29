INSERT INTO operator (name, address, phone_number) VALUES ('James Jameson', '123 Road Street, London, N1 1NN', '0207123456');
INSERT INTO operator (name, address, phone_number) VALUES ('Robert Robertson', 'Flat 1, Flat Street Apartments, Flat Street, London, E6 6EE', '07777777777');
INSERT INTO operator (name, address, phone_number) VALUES ('Michael Michaels', 'The bungalow, Lane street, London, SW18 18WS', '+44208999999');
INSERT INTO operator (name, address, phone_number) VALUES ('Andy Andrews', 'Our house, In the middle of our street', '+39728739992');

INSERT INTO driver (name, address, phone_number, payment_method, payment_rate) VALUES ('Bilbo Baggins', 'Bag End, Hobbiton, Middle Earth', '+897838792874', 'percent', 15);
INSERT INTO driver (name, address, phone_number, payment_method, payment_rate) VALUES ('Smaug', 'The lonely mountain', '+666666666', 'percent', 12);
INSERT INTO driver (name, address, phone_number, payment_method, payment_rate) VALUES ('Batman', 'Wayne Manor, Near Gotham', 'Red phone', 'percent', 20);
INSERT INTO driver (name, address, phone_number, payment_method, payment_rate) VALUES ('Superman', 'Fortress of solitude, The Arctic', '+1-800-SUPERMAN', 'hourly', 750);
INSERT INTO driver (name, address, phone_number, payment_method, payment_rate) VALUES ('Wolverine', 'The Xavier School for Gifted Children', '01234567890', 'hourly', 700);
INSERT INTO driver (name, address, phone_number, payment_method, payment_rate) VALUES ('Apocalypse', 'Egypt', '00000000000', 'hourly', 900);

INSERT INTO car (registration, registration_date, owner_id) VALUES ('AB14 ABC', TO_DATE('2014-05-01', 'yyyy-mm-dd'), 5);
INSERT INTO car (registration, registration_date, last_mot, owner_id) VALUES ('RRRRRRRR', TO_DATE('2001-01-01', 'yyyy-mm-dd'), TO_DATE('2014-01-01', 'yyyy-mm-dd'), 6);
INSERT INTO car (registration, registration_date, owner_id) VALUES ('BAT 1', null, 7);
INSERT INTO car (registration, registration_date, owner_id) VALUES ('SUPES', null, 8);
INSERT INTO car (registration, registration_date, last_mot, car_status, owner_id) VALUES ('X12 XXX', TO_DATE('2012-04-06', 'yyyy-mm-dd'), TO_DATE('2014-03-31', 'yyyy-mm-dd'), 'awaiting repair', 9);
INSERT INTO car (registration, registration_date, last_mot, owner_id) VALUES ('NS 4BANR', TO_DATE('1000-01-01', 'yyyy-mm-dd'), TO_DATE('2014-01-01', 'yyyy-mm-dd'), 10);

INSERT INTO shift (employee_id, start_time, end_time) VALUES (1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '8' HOUR);
INSERT INTO shift (employee_id, start_time, end_time) VALUES (2, CURRENT_TIMESTAMP + INTERVAL '4' HOUR, CURRENT_TIMESTAMP + INTERVAL '12' HOUR);
INSERT INTO shift (employee_id, start_time, end_time) VALUES (3, CURRENT_TIMESTAMP + INTERVAL '8' HOUR, CURRENT_TIMESTAMP + INTERVAL '16' HOUR);
INSERT INTO shift (employee_id, start_time, end_time) VALUES (4, CURRENT_TIMESTAMP + INTERVAL '12' HOUR, CURRENT_TIMESTAMP + INTERVAL '20' HOUR);
INSERT INTO shift (employee_id, start_time, end_time) VALUES (1, CURRENT_TIMESTAMP + INTERVAL '16' HOUR, CURRENT_TIMESTAMP + INTERVAL '24' HOUR);
INSERT INTO shift (employee_id, start_time, end_time) VALUES (2, CURRENT_TIMESTAMP + INTERVAL '20' HOUR, CURRENT_TIMESTAMP + INTERVAL '28' HOUR);
INSERT INTO shift (employee_id, start_time, end_time) VALUES (3, CURRENT_TIMESTAMP + INTERVAL '24' HOUR, CURRENT_TIMESTAMP + INTERVAL '32' HOUR);
INSERT INTO shift (employee_id, start_time, end_time) VALUES (4, CURRENT_TIMESTAMP + INTERVAL '28' HOUR, CURRENT_TIMESTAMP + INTERVAL '36' HOUR);

INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '8' HOUR, 'AB14 ABC');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (6, CURRENT_TIMESTAMP + INTERVAL '2' HOUR, CURRENT_TIMESTAMP + INTERVAL '10' HOUR, 'RRRRRRRR');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (7, CURRENT_TIMESTAMP + INTERVAL '4' HOUR, CURRENT_TIMESTAMP + INTERVAL '12' HOUR, 'BAT 1');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (8, CURRENT_TIMESTAMP + INTERVAL '6' HOUR, CURRENT_TIMESTAMP + INTERVAL '14' HOUR, 'SUPES');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (9, CURRENT_TIMESTAMP + INTERVAL '8' HOUR, CURRENT_TIMESTAMP + INTERVAL '16' HOUR, 'AB14 ABC');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (10, CURRENT_TIMESTAMP + INTERVAL '10' HOUR, CURRENT_TIMESTAMP + INTERVAL '18' HOUR, 'RRRRRRRR');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (5, CURRENT_TIMESTAMP + INTERVAL '12' HOUR, CURRENT_TIMESTAMP + INTERVAL '20' HOUR, 'BAT 1');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (6, CURRENT_TIMESTAMP + INTERVAL '14' HOUR, CURRENT_TIMESTAMP + INTERVAL '22' HOUR, 'SUPES');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (7, CURRENT_TIMESTAMP + INTERVAL '16' HOUR, CURRENT_TIMESTAMP + INTERVAL '24' HOUR, 'AB14 ABC');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (8, CURRENT_TIMESTAMP + INTERVAL '18' HOUR, CURRENT_TIMESTAMP + INTERVAL '26' HOUR, 'RRRRRRRR');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (9, CURRENT_TIMESTAMP + INTERVAL '20' HOUR, CURRENT_TIMESTAMP + INTERVAL '28' HOUR, 'BAT 1');
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (10, CURRENT_TIMESTAMP + INTERVAL '22' HOUR, CURRENT_TIMESTAMP + INTERVAL '30' HOUR, 'SUPES');


INSERT INTO client (name, phone_number, client_type) VALUES ('Ted Bundy', '07654321098', 'corporate');
INSERT INTO client (name, phone_number, client_type) VALUES ('Dennis Rader', '0202020202', 'corporate');
INSERT INTO client (name, phone_number, client_type) VALUES ('Gary Ridgway', '01234567890', 'corporate');
INSERT INTO client (name, phone_number, client_type) VALUES ('David Berkowitz', '07421763187', 'private');

INSERT INTO recurring_booking (client_account, pickup_location, dropoff_location, next_occurrence, price, recurrence, notes)
    VALUES (182356, 'British Library', 'King''s Cross Station', CURRENT_TIMESTAMP + INTERVAL '7' DAY, 500, 7, 'weekly on Fridays');

INSERT INTO booking_details (client_name, client_phone_number, pickup_location, pickup_time, dropoff_location, price, payment_method, driver_id)
    VALUES ('Tom', '02498379237', 'Somewhere over the rainbow', CURRENT_TIMESTAMP + INTERVAL '5' HOUR, 'Way up high', 2000, 'cash', 7);

INSERT INTO booking_details (client_name, client_phone_number, pickup_location, pickup_time, dropoff_location, price, payment_method, driver_id)
    VALUES ('Jerry', '02498379237', 'Never never land', CURRENT_TIMESTAMP + INTERVAL '1' HOUR, 'Hyde park', 1000, 'cash', 5);

