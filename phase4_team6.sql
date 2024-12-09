-- CS4400: Introduction to Database Systems (Fall 2024)
-- Project Phase III: Stored Procedures SHELL [v3] Thursday, Nov 7, 2024

-- Team 6
-- Jayanth Vennamreddy (GT username: jvennamreddy3)

set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

use business_supply;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_owner()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new owner.  A new owner must have a unique
username. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_owner;
delimiter //
create procedure add_owner (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date)
sp_main: begin
	-- Check if any of the inputs are NULL
    IF ip_username IS NULL OR ip_first_name IS NULL OR ip_last_name IS NULL OR 
       ip_address IS NULL OR ip_birthdate IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- ensure new owner has a unique username
    if (ip_username not in (select username from users)) then
		-- Insert new owner into database
        insert into users values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
        insert into business_owners values (ip_username);
	end if;
end //
delimiter ;

-- [2] add_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new employee without any designated driver or
worker roles.  A new employee must have a unique username and a unique tax identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_employee;
delimiter //
create procedure add_employee (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date,
    in ip_taxID varchar(40), in ip_hired date, in ip_employee_experience integer,
    in ip_salary integer)
sp_main: begin
	-- Check if any of the inputs are NULL
    IF ip_username IS NULL OR ip_first_name IS NULL OR ip_last_name IS NULL OR 
       ip_address IS NULL OR ip_birthdate IS NULL OR ip_taxID IS NULL OR
       ip_hired IS NULL OR ip_employee_experience IS NULL OR ip_salary IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- ensure new owner has a unique username
    if (ip_username not in (select username from users) and
    -- ensure new employee has a unique tax identifier
    ip_taxID not in (select taxID from employees)) then
		-- Insert new employee into database
		insert into users values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
        insert into employees values (ip_username, ip_taxID, ip_hired, ip_employee_experience, ip_salary);
	end if;
end //
delimiter ;

-- [3] add_driver_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the driver role to an existing employee.  The
employee/new driver must have a unique license identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_driver_role;
delimiter //
create procedure add_driver_role (in ip_username varchar(40), in ip_licenseID varchar(40),
	in ip_license_type varchar(40), in ip_driver_experience integer)
sp_main: begin
	IF ip_username IS NULL OR ip_licenseID IS NULL OR ip_license_type IS NULL THEN
		LEAVE sp_main;
	END IF;
    -- ensure employee exists and is not a worker
    if (ip_username in (select username from employees)) and
    (ip_username not in (select username from workers)) and
    -- ensure new driver has a unique license identifier
    ip_licenseID not in (select licenseID from drivers) then
		-- Insert new driver into drivers table
		insert into drivers values (ip_username, ip_licenseID, ip_license_type, ip_driver_experience);
	end if;
end //
delimiter ;

-- [4] add_worker_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the worker role to an existing employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_worker_role;
delimiter //
create procedure add_worker_role (in ip_username varchar(40))
sp_main: begin
	IF ip_username IS NULL THEN
		LEAVE sp_main;
	END IF;
    -- ensure employee exists and is not a driver
    if (ip_username in (select username from employees) and 
		ip_username not in (select username from drivers)) then
		-- Insert new worker into workers table
		insert into workers values (ip_username);
	end if;
end //
delimiter ;

-- [5] add_product()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new product.  A new product must have a
unique barcode. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_product;
delimiter //
create procedure add_product (in ip_barcode varchar(40), in ip_name varchar(100),
	in ip_weight integer)
sp_main: begin
	-- Check if any of the inputs are NULL
    IF ip_barcode IS NULL OR ip_name IS NULL OR ip_weight IS NULL THEN
        LEAVE sp_main;
    END IF;
	-- ensure new product doesn't already exist
    if (ip_barcode not in (select barcode from products)) then
		-- Insert new product into products table
		insert into products values (ip_barcode, ip_name, ip_weight);
	end if;
end //
delimiter ;

-- [6] add_van()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new van.  A new van must be assigned 
to a valid delivery service and must have a unique tag.  Also, it must be driven
by a valid driver initially (i.e., driver works for the same service). And the van's starting
location will always be the delivery service's home base by default. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_van;
delimiter //
create procedure add_van (in ip_id varchar(40), in ip_tag integer, in ip_fuel integer,
	in ip_capacity integer, in ip_sales integer, in ip_driven_by varchar(40))
sp_main: begin
	declare vanHome varchar(40);
    -- Check if any of the inputs are NULL
    IF ip_id IS NULL OR ip_tag IS NULL OR ip_fuel IS NULL OR ip_capacity IS NULL OR
       ip_sales IS NULL OR ip_driven_by IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- ensure new van doesn't already exist
    if (select count(*) from vans where id = ip_id and tag = ip_tag) = 0 and
    -- ensure that the delivery service exists
    (ip_id in (select id from delivery_services)) and
    -- ensure that a valid driver will control the van
	(ip_driven_by in (select username from drivers)) then
		-- Insert new van into vans table
		select home_base into vanHome from delivery_services where id = ip_id;
        insert into vans values (ip_id, ip_tag, ip_fuel, ip_capacity, ip_sales, ip_driven_by, vanHome);
	end if;
end //
delimiter ;

-- [7] add_business()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new business.  A new business must have a
unique (long) name and must exist at a valid location, and have a valid rating.
And a restaurant is initially "independent" (i.e., no owner), but will be assigned
an owner later for funding purposes. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_business;
delimiter //
create procedure add_business (
    in ip_long_name varchar(40),
    in ip_rating integer,
    in ip_spent integer,
    in ip_location varchar(40)
)
sp_main: begin
	-- Check if any of the inputs are NULL
    IF ip_long_name IS NULL OR ip_rating IS NULL OR ip_spent IS NULL OR ip_location IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- ensure new business doesn't already exist
    if (ip_long_name not in (select long_name from businesses)) and 
       -- ensure that the location is valid
       (ip_location in (select label from locations)) and
       -- ensure that no other business exists at the given location (based on union EERD)
       (ip_location not in (select location from businesses)) and
       -- ensure that the rating is valid (i.e., between 1 and 5 inclusively)
       (ip_rating between 1 and 5) then
        -- Insert new business into the businesses table
        insert into businesses values (ip_long_name, ip_rating, ip_spent, ip_location);
    end if;
end //
delimiter ;


-- [8] add_service()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new delivery service.  A new service must have
a unique identifier, along with a valid home base and manager. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_service;
delimiter //
create procedure add_service (in ip_id varchar(40), in ip_long_name varchar(100),
	in ip_home_base varchar(40), in ip_manager varchar(40))
sp_main: begin
	-- Check if any of the inputs are NULL
    IF ip_id IS NULL OR ip_long_name IS NULL OR ip_home_base IS NULL OR ip_manager IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- Ensure new delivery service doesn't already exist
    IF NOT EXISTS (SELECT * FROM delivery_services WHERE id = ip_id) THEN
        -- Ensure that the home base location is valid
        IF EXISTS (SELECT * FROM locations WHERE label = ip_home_base) THEN
			-- Ensure that no other delivery service exists at the given home base (based on union EERD)
            IF NOT EXISTS (SELECT * FROM delivery_services WHERE home_base = ip_home_base) THEN
				-- Ensure that the manager is valid
				IF EXISTS (SELECT * FROM workers WHERE username = ip_manager) THEN
					-- Insert new deliver serverice into the delivery_services table
					INSERT INTO delivery_services (id, long_name, home_base, manager)
					VALUES (ip_id, ip_long_name, ip_home_base, ip_manager);
				END IF;
			END IF;
		END IF;
	END IF;
end //
delimiter ;

-- [9] add_location()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new location that becomes a new valid van
destination.  A new location must have a unique combination of coordinates. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_location;
delimiter //
create procedure add_location (in ip_label varchar(40), in ip_x_coord integer,
	in ip_y_coord integer, in ip_space integer)
sp_main: begin
	-- Check if any of the inputs are NULL
    IF ip_label IS NULL OR ip_x_coord IS NULL OR ip_y_coord IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- Ensure new location doesn't already exist
    IF NOT EXISTS (SELECT * FROM locations WHERE label = ip_label) THEN
        -- Ensure that the coordinate combination is distinct
        IF NOT EXISTS (SELECT * FROM locations WHERE x_coord = ip_x_coord AND y_coord = ip_y_coord) THEN
			-- Insert new location into the locations table
            INSERT INTO locations (label, x_coord, y_coord, space)
            VALUES (ip_label, ip_x_coord, ip_y_coord, ip_space);
        END IF;
    END IF;
end //
delimiter ;

-- [10] start_funding()
-- -----------------------------------------------------------------------------
/* This stored procedure opens a channel for a business owner to provide funds
to a business. The owner and business must be valid. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_funding;
delimiter //
create procedure start_funding (in ip_owner varchar(40), in ip_amount integer, in ip_long_name varchar(40), in ip_fund_date date)
sp_main: begin
	IF ip_owner IS NULL OR ip_long_name IS NULL OR ip_fund_date IS NULL THEN
		LEAVE sp_main;
	END IF;
    -- Ensure the owner and business are valid
    IF EXISTS (SELECT * FROM business_owners WHERE username = ip_owner) AND 
		EXISTS (SELECT * FROM businesses WHERE long_name = ip_long_name) THEN
        -- Add new funding record into the fund table
        INSERT INTO fund (username, invested, invested_date, business)
        VALUES (ip_owner, ip_amount, ip_fund_date, ip_long_name);
    END IF;
end //
delimiter ;

-- [11] hire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure hires a worker to work for a delivery service.
If a worker is actively serving as manager for a different service, then they are
not eligible to be hired.  Otherwise, the hiring is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists hire_employee;
delimiter //
create procedure hire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	IF ip_username IS NULL OR ip_id IS NULL THEN
		LEAVE sp_main;
	END IF;
    -- Ensure that the employee hasn't already been hired by the input service
    IF NOT EXISTS (SELECT * FROM work_for WHERE username = ip_username AND id = ip_id) THEN
        -- Ensure that the employee and delivery service are valid
        IF EXISTS (SELECT * FROM employees WHERE username = ip_username) AND 
			EXISTS (SELECT * FROM delivery_services WHERE id = ip_id) THEN
            -- Ensure that the employee isn't a manager for another service
            IF NOT EXISTS (SELECT * FROM delivery_services WHERE manager = ip_username) THEN
				-- Insert a new employment record into the work_for table
				INSERT INTO work_for (username, id)
				VALUES (ip_username, ip_id);
			END IF;
		END IF;
	END IF;
end //
delimiter ;

-- [12] fire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure fires a worker who is currently working for a delivery
service.  The only restriction is that the employee must not be serving as a manager 
for the service. Otherwise, the firing is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists fire_employee;
delimiter //
create procedure fire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	IF ip_username IS NULL OR ip_id IS NULL THEN
		LEAVE sp_main;
	END IF;
    -- Ensure that the employee is currently working for the service
    IF EXISTS (SELECT * FROM work_for WHERE username = ip_username AND id = ip_id) THEN
        -- Ensure that the employee isn't an active manager for the input service
        -- IF NOT EXISTS (SELECT * FROM delivery_services WHERE manager = ip_username and id = ip_id) THEN
		-- Ensure that the employee isn't an active manager
        IF NOT EXISTS (SELECT * FROM delivery_services WHERE manager = ip_username) THEN
			-- Remove the employee's employment record from the work_for table
			DELETE FROM work_for WHERE username = ip_username AND id = ip_id;
		END IF;
	END IF;
end //
delimiter ;

-- [13] manage_service()
-- -----------------------------------------------------------------------------
/* This stored procedure appoints a worker who is currently hired by a delivery
service as the new manager for that service.  The only restrictions is that
the worker must not be working for any other delivery service. Otherwise, the appointment 
to manager is permitted.  The current manager is simply replaced. */
-- -----------------------------------------------------------------------------
drop procedure if exists manage_service;
delimiter //
create procedure manage_service (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	IF ip_username IS NULL OR ip_id IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- Ensure that the employee is currently working for the service
    IF EXISTS (SELECT * FROM work_for WHERE username = ip_username AND id = ip_id) THEN
		-- Ensure that the employee isn't working for any other services
		IF NOT EXISTS (SELECT * FROM work_for WHERE username = ip_username AND id != ip_id) THEN
			-- Appoint the employee as the new manager by 
			-- updating the input service's record in the delivery_services table
			UPDATE delivery_services SET manager = ip_username WHERE id = ip_id;
		END IF;
	END IF;
end //
delimiter ;

-- [14] takeover_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a valid driver to take control of a van owned by 
the same delivery service. The current controller of the van is simply relieved 
of those duties. */
-- -----------------------------------------------------------------------------
drop procedure if exists takeover_van;
delimiter //
create procedure takeover_van (in ip_username varchar(40), in ip_id varchar(40),
	in ip_tag integer)
sp_main: begin
	IF ip_username IS NULL OR ip_id IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- Ensure that the driver is not driving for another service
    IF NOT EXISTS (SELECT * FROM vans WHERE driven_by = ip_username AND id != ip_id) THEN
        -- Ensure that the selected van is owned by the same service
        IF EXISTS (SELECT * FROM vans WHERE tag = ip_tag AND id = ip_id) THEN
			-- Ensure that the employee is a valid driver
			IF EXISTS (SELECT * FROM drivers WHERE username = ip_username) THEN
				-- Relieve current controller and assign new driver
				UPDATE vans SET driven_by = NULL WHERE id = ip_id AND tag = ip_tag;
				UPDATE vans SET driven_by = ip_username WHERE id = ip_id AND tag = ip_tag;
			END IF;
        END IF;
    END IF;
end //
delimiter ;

-- [15] load_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add some quantity of fixed-size packages of
a specific product to a van's payload so that we can sell them for some
specific price to other businesses.  The van can only be loaded if it's located
at its delivery service's home base, and the van must have enough capacity to
carry the increased number of items.

The change/delta quantity value must be positive, and must be added to the quantity
of the product already loaded onto the van as applicable.  And if the product
already exists on the van, then the existing price must not be changed. */
-- -----------------------------------------------------------------------------
drop procedure if exists load_van;
delimiter //
create procedure load_van (in ip_id varchar(40), in ip_tag integer, in ip_barcode varchar(40),
	in ip_more_packages integer, in ip_price integer)
sp_main: begin
    DECLARE current_quantity INTEGER DEFAULT 0;
    DECLARE current_capacity INTEGER DEFAULT 0;
    DECLARE service_home_base VARCHAR(40);
    IF ip_id IS NULL OR ip_tag IS NULL OR ip_barcode IS NULL OR ip_more_packages IS NULL OR ip_price IS NULL THEN
        LEAVE sp_main;
    END IF;
    SELECT vans.capacity, delivery_services.home_base INTO current_capacity, service_home_base FROM vans 
		JOIN delivery_services ON vans.id = delivery_services.id
		WHERE vans.id = ip_id AND vans.tag = ip_tag;
	SELECT ifnull(SUM(quantity), 0) INTO current_quantity FROM contain WHERE id = ip_id AND tag = ip_tag;
	-- Ensure that the van being loaded is owned by the service
    IF EXISTS (SELECT * FROM vans WHERE id = ip_id and tag = ip_tag) AND
    -- Ensure that the product is valid
    EXISTS (SELECT * FROM products WHERE barcode = ip_barcode) AND
    -- Ensure that the van is located at the service home base
    (service_home_base IS NOT NULL 
		AND service_home_base IN (SELECT located_at FROM vans WHERE id = ip_id AND tag = ip_tag)) AND
    -- Ensure that the quantity of new packages is greater than zero
    (ip_more_packages > 0) AND
    -- Ensure that the van has sufficient capacity to carry the new packages
	(current_capacity >= current_quantity + ip_more_packages) THEN
		-- Add more of the product to the van
        IF EXISTS (SELECT * FROM contain WHERE id = ip_id AND tag = ip_tag AND barcode = ip_barcode) THEN
			UPDATE contain SET quantity = (quantity + ip_more_packages)
				WHERE id = ip_id AND tag = ip_tag AND barcode = ip_barcode;
		ELSE
        -- Add a new product containment record into the contain table
			INSERT INTO contain (id, tag, barcode, quantity, price)
				VALUES (ip_id, ip_tag, ip_barcode, ip_more_packages, ip_price);
		END IF;
	END IF;
end //
delimiter ;

-- [16] refuel_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add more fuel to a van. The van can only
be refueled if it's located at the delivery service's home base. */
-- -----------------------------------------------------------------------------
drop procedure if exists refuel_van;
delimiter //
create procedure refuel_van (in ip_id varchar(40), in ip_tag integer, in ip_more_fuel integer)
sp_main: begin
    DECLARE service_home_base VARCHAR(40);
    IF ip_id IS NULL OR ip_tag IS NULL OR ip_more_fuel IS NULL THEN
        LEAVE sp_main;
    END IF;
    SELECT located_at INTO service_home_base FROM vans JOIN delivery_services ON vans.id = delivery_services.id
    WHERE vans.tag = ip_tag AND vans.id = ip_id AND delivery_services.home_base = vans.located_at;
    -- ensure that the van being switched is valid and owned by the service
    -- ensure that the van is located at the service home base
    IF (service_home_base IS NOT NULL) THEN 
    UPDATE vans SET fuel = (fuel + ip_more_fuel) WHERE tag = ip_tag and id = ip_id;
	END IF;
end //
delimiter ;

-- [17] drive_van()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to move a single van to a new
location (i.e., destination). This will also update the respective driver's 
experience and van's fuel. The main constraints on the van(s) being able to 
move to a new  location are fuel and space.  A van can only move to a destination
if it has enough fuel to reach the destination and still move from the destination
back to home base.  And a van can only move to a destination if there's enough
space remaining at the destination. */
-- -----------------------------------------------------------------------------
drop function if exists fuel_required;
delimiter //
create function fuel_required (ip_departure varchar(40), ip_arrival varchar(40))
	returns integer reads sql data
begin
	if (ip_departure = ip_arrival) then return 0;
    else return (select 1 + truncate(sqrt(power(arrival.x_coord - departure.x_coord, 2) + power(arrival.y_coord - departure.y_coord, 2)), 0) as fuel
		from (select x_coord, y_coord from locations where label = ip_departure) as departure,
        (select x_coord, y_coord from locations where label = ip_arrival) as arrival);
	end if;
end //
delimiter ;

drop procedure if exists drive_van;
delimiter //
create procedure drive_van (in ip_id varchar(40), in ip_tag integer, in ip_destination varchar(40))
sp_main: begin
    DECLARE current_fuel INTEGER;
    DECLARE van_location VARCHAR(40);
    DECLARE fuel_used INTEGER;
    DECLARE fuel_needed INTEGER;
    DECLARE destination_vans INTEGER;
    DECLARE driver_username VARCHAR(40);
    IF ip_id IS NULL OR ip_tag IS NULL OR ip_destination IS NULL THEN
        LEAVE sp_main;
    END IF;
    IF NOT EXISTS (SELECT located_at FROM vans WHERE id = ip_id AND tag = ip_tag) THEN LEAVE sp_main; END IF;
    SELECT fuel, located_at, driven_by INTO current_fuel, van_location, driver_username FROM vans WHERE id = ip_id AND tag = ip_tag;
    IF NOT EXISTS (SELECT * FROM locations WHERE label = ip_destination) THEN LEAVE sp_main; END IF;
    SET fuel_used = fuel_required(van_location, ip_destination);
    SET fuel_needed = fuel_used + fuel_required(ip_destination, (SELECT home_base FROM delivery_services WHERE id = ip_id));
    SELECT COUNT(*) INTO destination_vans FROM vans WHERE located_at = ip_destination;
    IF destination_vans >= (SELECT space FROM locations WHERE label = ip_destination) THEN LEAVE sp_main; END IF;
    IF current_fuel >= fuel_needed AND van_location != ip_destination THEN
        UPDATE vans SET located_at = ip_destination, fuel = current_fuel - fuel_used
        WHERE id = ip_id AND tag = ip_tag;
        UPDATE drivers SET successful_trips = successful_trips + 1 WHERE username = driver_username;
    END IF;
end //

delimiter ;

-- [18] purchase_product()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a business to purchase products from a van
at its current location.  The van must have the desired quantity of the product
being purchased.  And the business must have enough money to purchase the
products.  If the transaction is otherwise valid, then the van and business
information must be changed appropriately.  Finally, we need to ensure that all
quantities in the payload table (post transaction) are greater than zero. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_product;
delimiter //
create procedure purchase_product (in ip_long_name varchar(40), in ip_id varchar(40),
	in ip_tag integer, in ip_barcode varchar(40), in ip_quantity integer)
sp_main: begin
    DECLARE product_price INTEGER;
    DECLARE product_quantity INTEGER;
    DECLARE business_location VARCHAR(40);
    DECLARE van_location VARCHAR(40);
    IF ip_long_name IS NULL OR ip_id IS NULL OR ip_tag IS NULL OR ip_barcode IS NULL OR ip_quantity IS NULL THEN
        LEAVE sp_main;
    END IF;
    SELECT location INTO business_location FROM businesses WHERE long_name = ip_long_name;
    SELECT located_at INTO van_location FROM vans WHERE id = ip_id AND tag = ip_tag;
    -- Ensure that the business is valid
    IF (business_location IS NOT NULL) AND
    -- Ensure that the van is valid and exists at the business's location
    (van_location IS NOT NULL AND van_location = business_location) THEN
		SELECT quantity, price INTO product_quantity, product_price
        FROM contain WHERE tag = ip_tag and id = ip_id and barcode = ip_barcode;
        -- Ensure that the van has enough of the requested product
        IF (product_quantity >= ip_quantity) THEN
			-- Update the van's payload
			UPDATE contain SET quantity = (quantity - ip_quantity)
				WHERE barcode = ip_barcode AND tag = ip_tag and id = ip_id;
			-- Update the monies spent and gained for the van and business
			UPDATE vans SET sales = sales + (product_price * ip_quantity) WHERE id = ip_id AND tag = ip_tag;
            UPDATE businesses SET spent = spent + (product_price * ip_quantity) WHERE long_name = ip_long_name;
            -- Ensure all quantities in the contain table are greater than zero
            DELETE FROM contain WHERE id = ip_id AND tag = ip_tag AND barcode = ip_barcode AND quantity <= 0;
		END IF;
	END IF;
end //
delimiter ;

-- [19] remove_product()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a product from the system.  The removal can
occur if, and only if, the product is not being carried by any vans. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_product;
delimiter //
create procedure remove_product (in ip_barcode varchar(40))
sp_main: begin
	IF ip_barcode IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- Ensure that the product exists
    IF EXISTS (SELECT * FROM products WHERE barcode = ip_barcode) AND
    -- Ensure that the product is not being carried by any vans
	NOT EXISTS (SELECT * FROM contain WHERE barcode = ip_barcode) THEN
		-- Remove the selected product from the products table
		DELETE FROM products WHERE barcode = ip_barcode;
	END IF;
end //
delimiter ;

-- [20] remove_van()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a van from the system.  The removal can
occur if, and only if, the van is not carrying any products.*/
-- -----------------------------------------------------------------------------
drop procedure if exists remove_van;
delimiter //
create procedure remove_van (in ip_id varchar(40), in ip_tag integer)
sp_main: begin
	IF ip_id IS NULL OR ip_tag IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- Ensure that the van exists
    IF EXISTS (SELECT * FROM vans WHERE id = ip_id AND tag = ip_tag) AND 
    -- Ensure that the van is not carrying any products
    NOT EXISTS (SELECT * FROM contain WHERE id = ip_id AND tag = ip_tag) THEN
		-- Remove the selected van from the vans table
		DELETE FROM vans WHERE id = ip_id AND tag = ip_tag;
	END IF;
end //
delimiter ;

-- [21] remove_driver_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a driver from the system.  The removal can
occur if, and only if, the driver is not controlling any vans.  
The driver's information must be completely removed from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_driver_role;
delimiter //
create procedure remove_driver_role (in ip_username varchar(40))
sp_main: begin
	IF ip_username IS NULL THEN
        LEAVE sp_main;
    END IF;
    -- Ensure that the driver exists
    IF EXISTS (SELECT * FROM drivers where username = ip_username) AND
    -- Ensure that the driver is not controlling any vans
    (SELECT COUNT(*) FROM vans WHERE driven_by = ip_username) = 0 THEN
    -- Remove all remaining information
	DELETE FROM drivers WHERE username = ip_username;
	-- DELETE FROM workers WHERE username = ip_username;
	-- DELETE FROM employees WHERE username = ip_username;
	-- DELETE FROM business_owners WHERE username = ip_username;
	DELETE FROM users WHERE username = ip_username;
	END IF;
end //
delimiter ;

-- [22] display_owner_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an owner.
For each owner, it includes the owner's information, along with the number of
businesses for which they provide funds and the number of different places where
those businesses are located.  It also includes the highest and lowest ratings
for each of those businesses, as well as the total amount of debt based on the
monies spent purchasing products by all of those businesses. And if an owner
doesn't fund any businesses then display zeros for the highs, lows and debt. */
-- -----------------------------------------------------------------------------
create or replace view display_owner_view as
select o.username as business_owner, u.first_name as first_name, u.last_name as last_name, u.address as owner_address,
	count(business) as businesses_funded, count(distinct location) as locations, 
	ifnull(max(rating), 0) as highest_rating, ifnull(min(rating), 0) as lowest_rating, 
    ifnull(sum(spent), 0) as debt from business_owners o join users u on o.username = u.username 
    left join fund f on o.username = f.username left join businesses b on f.business = b.long_name group by o.username;

-- [23] display_employee_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an employee.
For each employee, it includes the username, tax identifier, salary, hiring date and
experience level, along with license identifer and driving experience (if applicable,
'n/a' if not), and a 'yes' or 'no' depending on the manager status of the employee. */
-- -----------------------------------------------------------------------------
create or replace view display_employee_view as
select e.username, e.taxID, e.salary, e.hired, e.experience, 
	ifnull(d.licenseID, 'n/a') as licenseID, ifnull(d.successful_trips, 'n/a') as driving_experience, 
	if(m.manager is not null, 'yes', 'no') as manager from employees e left join drivers d on e.username = d.username 
	left join delivery_services m on e.username = m.manager;

-- [24] display_driver_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a driver.
For each driver, it includes the username, licenseID and drivering experience, along
with the number of vans that they are controlling. */
-- -----------------------------------------------------------------------------
create or replace view display_driver_view as
select d.username as username, d.licenseID as licenseID, d.successful_trips as successful_trips,
	COUNT(driven_by) as num_vans from drivers d left join vans v on d.username = v.driven_by group by d.username;

-- [25] display_location_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a location.
For each location, it includes the label, x- and y- coordinates, along with the
name of the business or service at that location, the number of vans as well as 
the identifiers of the vans at the location (sorted by the tag), and both the 
total and remaining capacity at the location. */
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW display_location_view AS
SELECT 
    l.label, 
    CASE 
        WHEN b.long_name IS NOT NULL THEN b.long_name
        ELSE ds.long_name
    END AS long_name,
    l.x_coord, 
    l.y_coord, 
    l.space, 
    IFNULL(van_counts.num_vans, 0) AS num_vans,
    IFNULL(van_identifiers.van_identifiers, 'n/a') AS van_identifiers,
    l.space - IFNULL(van_counts.num_vans, 0) AS remaining_capacity
FROM 
    locations l
LEFT JOIN 
    businesses b ON l.label = b.location
LEFT JOIN 
    delivery_services ds ON l.label = ds.home_base
LEFT JOIN 
    (SELECT located_at, COUNT(*) AS num_vans 
     FROM vans 
     GROUP BY located_at) van_counts 
    ON l.label = van_counts.located_at
LEFT JOIN 
    (SELECT located_at, GROUP_CONCAT(CONCAT(id, tag) ORDER BY tag ASC SEPARATOR ', ') AS van_identifiers 
     FROM vans 
     GROUP BY located_at) van_identifiers 
    ON l.label = van_identifiers.located_at
WHERE 
    EXISTS (SELECT 1 FROM vans v WHERE v.located_at = l.label);

-- [26] display_product_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of the products.
For each product that is being carried by at least one van, it includes a list of
the various locations where it can be purchased, along with the total number of packages
that can be purchased and the lowest and highest prices at which the product is being
sold at that location. */
-- -----------------------------------------------------------------------------
create or replace view display_product_view as
select p.iname AS product_name, v.located_at AS location,
	SUM(c.quantity) AS total_num_packages, IFNULL(MIN(c.price), 0) AS lowest_price, IFNULL(MAX(c.price), 0) AS highest_price 
	from products p JOIN contain c ON p.barcode = c.barcode JOIN vans v ON c.id = v.id AND c.tag = v.tag 
    GROUP BY p.barcode, v.located_at ORDER BY product_name, location;

-- [27] display_service_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a delivery
service.  It includes the identifier, name, home base location and manager for the
service, along with the total sales from the vans.  It must also include the number
of unique products along with the total cost and weight of those products being
carried by the vans. */
-- -----------------------------------------------------------------------------
-- Helper Functions
DROP FUNCTION IF EXISTS get_total_sales;
DELIMITER //
CREATE FUNCTION get_total_sales(ip_id VARCHAR(40))
RETURNS INTEGER
READS SQL DATA
BEGIN
	DECLARE total_sales INTEGER DEFAULT 0;
    SELECT SUM(sales) INTO total_sales FROM vans WHERE id = ip_id;
	RETURN total_sales;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS get_unique_products_count;
DELIMITER //
CREATE FUNCTION get_unique_products_count(ip_id VARCHAR(40))
RETURNS INTEGER
READS SQL DATA
BEGIN
	DECLARE product_count INTEGER DEFAULT 0;
    SELECT (COUNT(DISTINCT barcode)) INTO product_count FROM contain WHERE id = ip_id;
    RETURN product_count;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS get_total_cost;
DELIMITER //
CREATE FUNCTION get_total_cost(ip_id VARCHAR(40))
RETURNS INTEGER
READS SQL DATA
BEGIN
	DECLARE cost_sum INTEGER DEFAULT 0;
    SELECT (SUM(quantity * price)) INTO cost_sum FROM contain WHERE id = ip_id;
    RETURN cost_sum;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS get_total_weight;
DELIMITER //
CREATE FUNCTION get_total_weight(ip_id VARCHAR(40))
RETURNS INTEGER
READS SQL DATA
BEGIN
	DECLARE weight_sum INTEGER DEFAULT 0;
    SELECT (SUM(c.quantity * p.weight)) INTO weight_sum 
		FROM contain c JOIN products p ON c.barcode = p.barcode WHERE c.id = ip_id;
    RETURN weight_sum;
END //
DELIMITER ;

create or replace view display_service_view as
select id AS service_id, long_name AS service_name, home_base AS service_home_base, manager AS service_manager,
	get_total_sales(id) AS total_sales, get_unique_products_count(id) AS unique_products,
	get_total_cost(id) AS total_cost, get_total_weight(id) AS total_weight
	from delivery_services;