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