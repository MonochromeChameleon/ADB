-- Delete everything without failing on foreign keys
-- Yes we could do ON DELETE CASCADE instead, but whatevs. We don't need to hand
-- this file in, after all...

DROP VIEW drivers_on_shift;
DROP VIEW operators_on_shift;
DROP VIEW booking;
DROP VIEW employee;


DROP TABLE payment;
DROP TABLE shift;
DROP TABLE booking_details;
DROP TABLE recurring_booking;
DROP TABLE client;
DROP TABLE car;
DROP TABLE operator;
DROP TABLE driver;


DROP SEQUENCE seq_employee_id;
DROP SEQUENCE seq_account_number;
DROP SEQUENCE seq_booking_id;

