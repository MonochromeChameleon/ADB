INSERT INTO operator (name, address, phone_number) VALUES ('James Jameson', '123 Road Street, London, N1 1NN', '0207123456');
INSERT INTO operator (name, address, phone_number) VALUES ('Robert Robertson', 'Flat 1, Flat Street Apartments, Flat Street, London, E6 6EE', '07777777777');
INSERT INTO operator (name, address, phone_number) VALUES ('Michael Michaels', 'The bungalow, Lane street, London, SW18 18WS', '+44208999999');
INSERT INTO operator (name, address, phone_number) VALUES ('Andy Andrews', 'Our house, In the middle of our street', '+39728739992');

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
INSERT INTO shift (employee_id, start_time, end_time, car_registration) VALUES (10, CURRENT_TIMESTAMP + INTERVAL '22' HOUR, CURRENT_TIMESTAMP + INTERVAL '20' HOUR, 'SUPES');

