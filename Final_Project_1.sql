-- Procedure to drop foreign key constraints
CREATE OR REPLACE PROCEDURE drop_foreign_key_constraints IS
    v_constraint_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_constraint_exists
    FROM user_constraints
    WHERE constraint_name IN (
        'FK_PRESCRIPTION_CUSTOMER_ID',
        'FK_PRESCRIBED_DRUGS_PRESCRIPTION_ID',
        'FK_EMPLOYEE_ROLE_ID',
        'FK_ORDER_BILL_EMPLOYEE_ID',
        'FK_ORDER_BILL_PRESCRIPTION_ID',
        'FK_ORDERED_DRUGS_DRUG_ID',
        'FK_PAYMENT_BILL_ORDER_ID',
        'FK_PAYMENT_BILL_CUSTOMER_ID',
        'FK_ORDERED_DRUGS_ORDER_ID',
        'FK_NOTIFICATION_DRUG_ID',
        'FK_EMPLOYEE_NOTIFICATION_EMP_ID',
        'FK_EMPLOYEE_NOTIFICATION_NOTIF_ID'
    );

    IF v_constraint_exists > 0 THEN
        -- Drop foreign key constraints using dynamic SQL
        EXECUTE IMMEDIATE 'ALTER TABLE PRESCRIPTION DROP CONSTRAINT FK_PRESCRIPTION_CUSTOMER_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE PRESCRIBED_DRUGS DROP CONSTRAINT FK_PRESCRIBED_DRUGS_PRESCRIPTION_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE EMPLOYEE DROP CONSTRAINT FK_EMPLOYEE_ROLE_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE ORDER_BILL DROP CONSTRAINT FK_ORDER_BILL_EMPLOYEE_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE ORDER_BILL DROP CONSTRAINT FK_ORDER_BILL_PRESCRIPTION_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE PAYMENT_BILL DROP CONSTRAINT FK_PAYMENT_BILL_ORDER_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE PAYMENT_BILL DROP CONSTRAINT FK_PAYMENT_BILL_CUSTOMER_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE ORDERED_DRUGS DROP CONSTRAINT FK_ORDERED_DRUGS_DRUG_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE ORDERED_DRUGS DROP CONSTRAINT FK_ORDERED_DRUGS_ORDER_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE NOTIFICATION DROP CONSTRAINT FK_NOTIFICATION_DRUG_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE EMPLOYEE_NOTIFICATION DROP CONSTRAINT FK_EMPLOYEE_NOTIFICATION_EMP_ID';
        EXECUTE IMMEDIATE 'ALTER TABLE EMPLOYEE_NOTIFICATION DROP CONSTRAINT FK_EMPLOYEE_NOTIFICATION_NOTIF_ID';
    END IF;
END drop_foreign_key_constraints;
/

-- Procedure to drop all tables
CREATE OR REPLACE PROCEDURE drop_all_tables IS
    v_table_count NUMBER;
BEGIN
    -- Check if tables exist
    SELECT COUNT(*)
    INTO v_table_count
    FROM user_tables
    WHERE table_name IN (
        'CUSTOMER',
        'PRESCRIPTION',
        'PRESCRIBED_DRUGS',
        'ORDER_BILL',
        'PAYMENT_BILL',
        'ORDERED_DRUGS',
        'INVENTORY',
        'NOTIFICATION',
        'EMPLOYEE_NOTIFICATION',
        'EMPLOYEE',
        'ROLE'
    );

    -- Drop tables if they exist
    IF v_table_count > 0 THEN
        FOR tab IN (SELECT table_name FROM user_tables WHERE table_name IN (
            'INSURANCE',
            'CUSTOMER',
            'PRESCRIPTION',
            'PRESCRIBED_DRUGS',
            'ORDER_BILL',
            'PAYMENT_BILL',
            'ORDERED_DRUGS',
            'INVENTORY',
            'NOTIFICATION',
            'EMPLOYEE_NOTIFICATION',
            'EMPLOYEE',
            'ROLE'
        )) LOOP
            EXECUTE IMMEDIATE 'DROP TABLE ' || tab.table_name;
        END LOOP;
    END IF;
END drop_all_tables;
/


EXEC drop_foreign_key_constraints;
EXEC drop_all_tables;
----------------------------------------------------------------------------------------
-- CREATING NEW TABLES
----------------------------------------------------------------------------------------

CREATE TABLE CUSTOMER(
    CUSTOMER_ID VARCHAR(10),
    FIRST_NAME VARCHAR(25),
    LAST_NAME VARCHAR(25),
    GENDER VARCHAR(10),
    CITY VARCHAR(20),
    INSURANCE_BALANCE NUMBER(6,0),  -- Balance available in the insurance account
    INSURANCE_COMPANY VARCHAR(25),  -- Name of the insurance company
    INSURANCE_START_DATE DATE,      -- Start date of insurance coverage
    INSURANCE_END_DATE DATE,        -- End date of insurance coverage
    CONSTRAINT PK_CUSTOMER_ID PRIMARY KEY (CUSTOMER_ID)
);

CREATE TABLE PRESCRIPTION(
    CUSTOMER_ID VARCHAR(10),
    PRES_ID VARCHAR(10),
    PRES_DATE DATE,
    DOC_ID VARCHAR(10),
    CONSTRAINT PK_PRESCRIPTION_ID PRIMARY KEY (PRES_ID),
    CONSTRAINT FK_PRESCRIPTION_CUSTOMER_ID FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMER(CUSTOMER_ID) ON DELETE CASCADE
);

CREATE TABLE PRESCRIBED_DRUGS(
    PRES_ID VARCHAR(10),
    DRUG_NAME VARCHAR(25),
    QUANTITY NUMBER(3,0),
    CONSTRAINT PK_PRESCRIBED_DRUGS PRIMARY KEY (PRES_ID, DRUG_NAME),
    CONSTRAINT FK_PRESCRIBED_DRUGS_PRESCRIPTION_ID FOREIGN KEY (PRES_ID) REFERENCES PRESCRIPTION(PRES_ID) ON DELETE CASCADE
);

CREATE TABLE ROLE(
    ROLE_ID VARCHAR(10),
    ROLE_NAME VARCHAR(25),
    CONSTRAINT PK_ROLE_ID PRIMARY KEY(ROLE_ID),
    CONSTRAINT CHK_ROLE_NAME CHECK (ROLE_NAME IN ('Admin', 'Cashier', 'Inventory Manager')) -- Restricting entering of Role_name to just these 3 roles
);

CREATE TABLE EMPLOYEE(
    EMP_ID VARCHAR(10),
    FIRST_NAME VARCHAR(25),
    LAST_NAME VARCHAR(25),
    START_DATE DATE,
    END_DATE DATE,
    ROLE_ID VARCHAR(10),
    SALARY NUMERIC(6,0),
    CONSTRAINT PK_EMPLOYEE PRIMARY KEY (EMP_ID),
    CONSTRAINT FK_EMPLOYEE_ROLE_ID FOREIGN KEY (ROLE_ID) REFERENCES ROLE(ROLE_ID) ON DELETE CASCADE
);

CREATE TABLE INVENTORY(
    DRUG_ID VARCHAR(10),
    DRUG_NAME VARCHAR(25),
    MANUFACTURER VARCHAR(25),
    INV_QUANTITY NUMERIC(5,0),
    BUY_DATE DATE,
    EXPIRY_DATE DATE,
    PRICE NUMERIC(5,0),
    THRESHOLD_QUANTITY NUMERIC(5,0),
    RESTOCK_QUANTITY NUMERIC(5,0),
    CONSTRAINT PK_INVENTORY PRIMARY KEY (DRUG_ID)
);

CREATE TABLE ORDER_BILL(
    ORDER_ID VARCHAR(10),
    PRES_ID VARCHAR(10),
    EMP_ID VARCHAR(10),
    CONSTRAINT PK_ORDER_ID PRIMARY KEY (ORDER_ID),
    CONSTRAINT FK_ORDER_BILL_PRESCRIPTION_ID FOREIGN KEY (PRES_ID) REFERENCES PRESCRIPTION(PRES_ID) ON DELETE CASCADE,
    CONSTRAINT FK_ORDER_BILL_EMPLOYEE_ID FOREIGN KEY (EMP_ID) REFERENCES EMPLOYEE(EMP_ID) ON DELETE CASCADE
);

CREATE TABLE PAYMENT_BILL(
    BILL_ID VARCHAR(10),
    ORDER_ID VARCHAR(10),
    ORDER_DATE DATE,
    TOTAL_AMOUNT NUMERIC(5,0),
    CUSTOMER_PAY NUMERIC(5,0),
    INSURANCE_PAY NUMERIC(10),
    CONSTRAINT PK_PAYMENT_BILL_ID PRIMARY KEY (BILL_ID),
    CONSTRAINT FK_PAYMENT_BILL_ORDER_ID FOREIGN KEY (ORDER_ID) REFERENCES ORDER_BILL(ORDER_ID) ON DELETE CASCADE
);

--
--CREATE TABLE ORDER_BILL (
--    ORDER_ID VARCHAR(10),
--    PRES_ID VARCHAR(10),
--    EMP_ID VARCHAR(10),
--    ORDER_DATE DATE,
--    TOTAL_AMOUNT NUMERIC(5,0),
--    CUSTOMER_ID VARCHAR(10),
--    PATIENT_PAY NUMERIC(5,0),
--    INSURANCE_PAY NUMERIC(10),
--    CONSTRAINT PK_ORDER_BILL_ORDER_ID PRIMARY KEY (ORDER_ID),
--    CONSTRAINT FK_ORDER_BILL_PRESCRIPTION_ID FOREIGN KEY (PRES_ID) REFERENCES PRESCRIPTION(PRES_ID) ON DELETE CASCADE,
--    CONSTRAINT FK_ORDER_BILL_EMPLOYEE_ID FOREIGN KEY (EMP_ID) REFERENCES EMPLOYEE(EMP_ID) ON DELETE CASCADE,
--    CONSTRAINT FK_ORDER_BILL_CUSTOMER_ID FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMER(CUSTOMER_ID) ON DELETE CASCADE
--);

CREATE TABLE ORDERED_DRUGS(
    ORDER_ID VARCHAR(10),
    DRUG_ID VARCHAR(10),
    ORDER_QUANTITY NUMBER(5,0),
    CONSTRAINT PK_ORDERED_DRUGS PRIMARY KEY (ORDER_ID, DRUG_ID),
    CONSTRAINT FK_ORDERED_DRUGS_ORDER_ID FOREIGN KEY (ORDER_ID) REFERENCES ORDER_BILL(ORDER_ID) ON DELETE CASCADE,
    CONSTRAINT FK_ORDERED_DRUGS_DRUG_ID FOREIGN KEY (DRUG_ID) REFERENCES INVENTORY(DRUG_ID) ON DELETE CASCADE
);

CREATE TABLE NOTIFICATION(
    NOTIF_ID VARCHAR(10),
    NOTIF_DATE DATE,
    MESSAGE VARCHAR(100),
    DRUG_ID VARCHAR(10),
    CONSTRAINT PK_NOTIFICATION_ID PRIMARY KEY (NOTIF_ID),
    CONSTRAINT FK_NOTIFICATION_DRUG_ID FOREIGN KEY (DRUG_ID) REFERENCES INVENTORY(DRUG_ID) ON DELETE CASCADE
);

CREATE TABLE EMPLOYEE_NOTIFICATION(
    EMP_NOTIF_ID VARCHAR(15),
    NOTIF_ID VARCHAR(10),
    EMP_ID VARCHAR(10),
    CONSTRAINT PK_EMPLOYEE_NOTIFICATION_ID PRIMARY KEY (EMP_NOTIF_ID),
    CONSTRAINT FK_EMPLOYEE_NOTIFICATION_NOTIF_ID FOREIGN KEY (NOTIF_ID) REFERENCES NOTIFICATION(NOTIF_ID) ON DELETE CASCADE,
    CONSTRAINT FK_EMPLOYEE_NOTIFICATION_EMP_ID FOREIGN KEY (EMP_ID) REFERENCES EMPLOYEE(EMP_ID) ON DELETE CASCADE
);



----------------------------------------------------------------------------------------
-- Dropping all the Users and Roles when rerun entire code
----------------------------------------------------------------------------------------
BEGIN
    -- Drop role if it exists
    FOR role_rec IN (SELECT * FROM dba_roles WHERE role IN ('PHARMACY_ADMIN', 'CASHIER', 'INVENTORY_MANAGER')) LOOP
        EXECUTE IMMEDIATE 'DROP ROLE ' || role_rec.role;
    END LOOP;

    -- Drop user if it exists
    FOR user_rec IN (SELECT * FROM dba_users WHERE username IN ('ADMIN_USER1', 'CASHIER_USER1', 'INVENTORY_MANAGER_USER1')) LOOP
        EXECUTE IMMEDIATE 'DROP USER ' || user_rec.username || ' CASCADE';
    END LOOP;
END;
/

SELECT * FROM dba_users;

-- Creating Roles and assigning tables to roles, followed by assigning roles to users
CREATE ROLE Pharmacy_Admin;
CREATE ROLE Cashier;
CREATE ROLE Inventory_Manager;

-- Granting privileges to Admin role
BEGIN
    FOR tbl IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || tbl.table_name || ' TO Pharmacy_Admin';
    END LOOP;
END;
/

-- Role Admin & Cashier should only have access to order and pay bill tables
GRANT SELECT, INSERT, UPDATE, DELETE ON ORDER_BILL TO Cashier;
GRANT SELECT, INSERT, UPDATE, DELETE ON PAYMENT_BILL TO Cashier;

-- Grant INSERT privilege on additional tables for Cashier role
GRANT INSERT ON CUSTOMER TO Cashier;
GRANT INSERT ON PRESCRIPTION TO Cashier;
GRANT INSERT ON PRESCRIBED_DRUGS TO Cashier;

-- Role Inventory Manager should have access to inventory and notification tables
GRANT SELECT, INSERT, UPDATE, DELETE ON INVENTORY TO Inventory_Manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON NOTIFICATION TO Inventory_Manager;


-- Creating new users and granting resources to each
CREATE USER admin_user1 IDENTIFIED BY BostonSpring2024#;
CREATE USER cashier_user1 IDENTIFIED BY BostonSpring2024##;
CREATE USER inventory_manager_user1 IDENTIFIED BY BostonSpring2024###;

GRANT CONNECT, RESOURCE TO admin_user1;
GRANT CONNECT, RESOURCE TO cashier_user1;
GRANT CONNECT, RESOURCE TO inventory_manager_user1;

-- Assigning database quota for the users
ALTER USER admin_user1 QUOTA 50 M ON DATA;
ALTER USER cashier_user1 QUOTA 10 M ON DATA;
ALTER USER inventory_manager_user1 QUOTA 10 M ON DATA;

-- Assigning roles to users
GRANT Pharmacy_Admin TO admin_user1;
GRANT Cashier TO cashier_user1;
GRANT Inventory_Manager TO inventory_manager_user1;

---------------------------------------------------------------------------
-- ALL STORED PROCEDURES START HERE
---------------------------------------------------------------------------

SET SERVEROUTPUT ON;

---------------------------------------------------------------------------
-- STORED PROCEDURE FOR INSERTNIG | UPDATING & DELETING DATA INTO CUSTOMER
---------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE INSERT_CUSTOMER (
    v_customer_id IN VARCHAR2,
    v_first_name IN VARCHAR2,
    v_last_name IN VARCHAR2,
    v_gender IN VARCHAR2,
    v_city IN VARCHAR2,
    v_insurance_balance IN NUMBER,
    v_insurance_company IN VARCHAR2,
    v_insurance_start_date IN DATE,
    v_insurance_end_date IN DATE
) IS
    v_customer_count NUMBER;
BEGIN
    -- Check if CUSTOMER_ID already exists in the CUSTOMER table
    SELECT COUNT(*) INTO v_customer_count FROM CUSTOMER WHERE CUSTOMER_ID = v_customer_id;
    IF v_customer_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Customer with the same ID already exists.');
    END IF;

    IF NOT (v_customer_id IS NULL OR LENGTH(v_customer_id) <= 10) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data type for CUSTOMER_ID');
    END IF;
    
    IF NOT (v_first_name IS NULL OR LENGTH(v_first_name) <= 25) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data type for FIRST_NAME');
    END IF;
    
    IF NOT (v_last_name IS NULL OR LENGTH(v_last_name) <= 25) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data type for LAST_NAME');
    END IF;
    
    IF NOT (v_gender IS NULL OR LENGTH(v_gender) <= 10) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data type for GENDER');
    END IF;
    
    IF NOT (v_city IS NULL OR LENGTH(v_city) <= 20) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data type for CITY');
    END IF;
    
    -- Check if insurance end date is after start date
    IF v_insurance_end_date <= v_insurance_start_date THEN
        RAISE_APPLICATION_ERROR(-20006, 'Insurance end date must be after the start date.');
    END IF;

    -- Perform the insertion
    INSERT INTO CUSTOMER (CUSTOMER_ID, FIRST_NAME, LAST_NAME, GENDER, CITY, INSURANCE_BALANCE, INSURANCE_COMPANY, INSURANCE_START_DATE, INSURANCE_END_DATE)
    VALUES (v_customer_id, v_first_name, v_last_name, v_gender, v_city, v_insurance_balance, v_insurance_company, v_insurance_start_date, v_insurance_end_date);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20005, 'Duplicate CUSTOMER_ID found');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting data into CUSTOMER table: ' || SQLERRM);
END INSERT_CUSTOMER;
/

CREATE OR REPLACE PROCEDURE UPDATE_CUSTOMER (
    v_customer_id IN VARCHAR2,
    v_first_name IN VARCHAR2,
    v_last_name IN VARCHAR2,
    v_gender IN VARCHAR2,
    v_city IN VARCHAR2,
    v_insurance_balance IN NUMBER,
    v_insurance_company IN VARCHAR2,
    v_insurance_start_date IN DATE,
    v_insurance_end_date IN DATE
) IS
    v_customer_count NUMBER;
BEGIN
    IF NOT (v_customer_id IS NULL OR LENGTH(v_customer_id) <= 10) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data type for CUSTOMER_ID');
    END IF;
    
    IF NOT (v_first_name IS NULL OR LENGTH(v_first_name) <= 25) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data type for FIRST_NAME');
    END IF;
    
    IF NOT (v_last_name IS NULL OR LENGTH(v_last_name) <= 25) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data type for LAST_NAME');
    END IF;
    
    IF NOT (v_gender IS NULL OR LENGTH(v_gender) <= 10) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data type for GENDER');
    END IF;
    
    IF NOT (v_city IS NULL OR LENGTH(v_city) <= 20) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid data type for CITY');
    END IF;
    
    -- Check if insurance end date is after start date
    IF v_insurance_end_date <= v_insurance_start_date THEN
        RAISE_APPLICATION_ERROR(-20006, 'Insurance end date must be after the start date.');
    END IF;
    
    -- Check if CUSTOMER_ID exists in the CUSTOMER table
    SELECT COUNT(*) INTO v_customer_count FROM CUSTOMER WHERE CUSTOMER_ID = v_customer_id;
    IF v_customer_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'CUSTOMER_ID does not exist in the CUSTOMER table');
    END IF;

    UPDATE CUSTOMER
    SET FIRST_NAME = v_first_name,
        LAST_NAME = v_last_name,
        GENDER = v_gender,
        CITY = v_city,
        INSURANCE_BALANCE = v_insurance_balance,
        INSURANCE_COMPANY = v_insurance_company,
        INSURANCE_START_DATE = v_insurance_start_date,
        INSURANCE_END_DATE = v_insurance_end_date
    WHERE CUSTOMER_ID = v_customer_id;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating data in CUSTOMER table: ' || SQLERRM);
END UPDATE_CUSTOMER;
/

CREATE OR REPLACE PROCEDURE DELETE_CUSTOMER (
    v_customer_id IN VARCHAR2
) IS
    v_customer_count NUMBER;
BEGIN
    -- Check if the customer ID exists
    SELECT COUNT(*) INTO v_customer_count FROM CUSTOMER WHERE CUSTOMER_ID = v_customer_id;
    
    IF v_customer_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Customer ID does not exist in the CUSTOMER table.');
    END IF;

    -- If the customer ID exists, delete the record
    DELETE FROM CUSTOMER WHERE CUSTOMER_ID = v_customer_id;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error deleting data from CUSTOMER table: ' || SQLERRM);
END DELETE_CUSTOMER;
/

---------------------------------------------------------------------------
-- STORED PROCEDURE FOR INSERTNIG DATA INTO PRESCRIPTION & PRES DRUGS TABLE
---------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE INSERT_PRESCRIPTION (
    v_customer_id IN VARCHAR2,
    v_pres_id IN VARCHAR2,
    v_pres_date IN DATE,
    v_doc_id IN VARCHAR2
) IS
    v_customer_count NUMBER;
BEGIN
    -- Check if CUSTOMER_ID exists in the CUSTOMER table
    SELECT COUNT(*) INTO v_customer_count FROM CUSTOMER WHERE CUSTOMER_ID = v_customer_id;
    IF v_customer_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid CUSTOMER_ID entered');
    END IF;

    -- Check data type and length for PRESCRIPTION_ID
    IF NOT (v_pres_id IS NULL OR LENGTH(v_pres_id) <= 10) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid data type or length for PRES_ID');
    END IF;

    -- Check data type for PRESCRIPTION_DATE
    IF v_pres_date IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid data type for PRES_DATE');
    END IF;

    -- Check data type and length for DOCTOR_ID
    IF NOT (v_doc_id IS NULL OR LENGTH(v_doc_id) <= 10) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid data type or length for DOC_ID');
    END IF;

    INSERT INTO PRESCRIPTION (CUSTOMER_ID, PRES_ID, PRES_DATE, DOC_ID)
    VALUES (v_customer_id, v_pres_id, v_pres_date, v_doc_id);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20005, 'Duplicate PRES_ID found');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting data into PRESCRIPTION table: ' || SQLERRM);
END INSERT_PRESCRIPTION;
/

CREATE OR REPLACE PROCEDURE INSERT_PRESCRIBED_DRUGS (
    v_pres_id IN VARCHAR2,
    v_drug_name IN VARCHAR2,
    v_quantity IN NUMBER
) IS
    v_pres_count NUMBER;
BEGIN
    -- Check if PRES_ID exists in the PRESCRIPTION table
    SELECT COUNT(*) INTO v_pres_count FROM PRESCRIPTION WHERE PRES_ID = v_pres_id;
    IF v_pres_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'PRES_ID does not exist in the PRESCRIPTION table');
    END IF;

    -- Check data type and length for DRUG_NAME
    IF NOT (v_drug_name IS NULL OR LENGTH(v_drug_name) <= 25) THEN
        RAISE_APPLICATION_ERROR(-20007, 'Invalid data type or length for DRUG_NAME');
    END IF;

    -- Check if quantity is non-negative
    IF v_quantity < 0 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Quantity cannot be negative');
    END IF;

    -- Insert data into PRESCRIBED_DRUGS table
    INSERT INTO PRESCRIBED_DRUGS (PRES_ID, DRUG_NAME, QUANTITY)
    VALUES (v_pres_id, v_drug_name, v_quantity);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20009, 'Duplicate drug for the same prescription');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting data into PRESCRIBED_DRUGS table: ' || SQLERRM);
END INSERT_PRESCRIBED_DRUGS;
/

---------------------------------------------------------------------------
-- STORED PROCEDURE FOR INSERTNIG | UPDATING & DELETING DATA INTO INVENTORY
---------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE INSERT_INVENTORY (
    v_drug_id IN VARCHAR2,
    v_drug_name IN VARCHAR2,
    v_manufacturer IN VARCHAR2,
    v_inv_quantity IN NUMBER,
    v_buy_date IN DATE,
    v_expiry_date IN DATE,
    v_price IN NUMBER,
    v_threshold_quantity IN NUMBER,
    v_restock_quantity IN NUMBER
) IS
    v_count NUMBER;
BEGIN
    -- Check if DRUG_ID already exists
    SELECT COUNT(*) INTO v_count FROM INVENTORY WHERE DRUG_ID = v_drug_id;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'DRUG_ID already exists');
    END IF;
    
    -- Check if expiry date is after buy date
    IF v_expiry_date <= v_buy_date THEN
        RAISE_APPLICATION_ERROR(-20002, 'Expiry date must be after buy date');
    END IF;

    -- Check if threshold quantity is less than inventory quantity
    IF v_threshold_quantity >= v_inv_quantity THEN
        RAISE_APPLICATION_ERROR(-20003, 'Inventory quantity must be less than threshold quantity');
    END IF;
    
    INSERT INTO INVENTORY (DRUG_ID, DRUG_NAME, MANUFACTURER, INV_QUANTITY, BUY_DATE, EXPIRY_DATE, PRICE, THRESHOLD_QUANTITY, RESTOCK_QUANTITY)
    VALUES (v_drug_id, v_drug_name, v_manufacturer, v_inv_quantity, v_buy_date, v_expiry_date, v_price, v_threshold_quantity, v_restock_quantity);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting data into INVENTORY table: ' || SQLERRM);
END INSERT_INVENTORY;
/

-- Update data in inventory
CREATE OR REPLACE PROCEDURE UPDATE_INVENTORY (
    v_drug_id IN VARCHAR2,
    v_drug_name IN VARCHAR2,
    v_manufacturer IN VARCHAR2,
    v_inv_quantity IN NUMBER,
    v_buy_date IN DATE,
    v_expiry_date IN DATE,
    v_price IN NUMBER,
    v_threshold_quantity IN NUMBER,
    v_restock_quantity IN NUMBER
) IS
    v_drug_count NUMBER;
BEGIN
    -- Check if the drug ID exists in the INVENTORY table
    SELECT COUNT(*) INTO v_drug_count FROM INVENTORY WHERE DRUG_ID = v_drug_id;
    IF v_drug_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Drug ID does not exist in the INVENTORY table');
    END IF;

    -- Check if expiry date is after buy date
    IF v_expiry_date <= v_buy_date THEN
        RAISE_APPLICATION_ERROR(-20001, 'Expiry date must be after buy date');
    END IF;

    -- Check if threshold quantity is less than inventory quantity
    IF v_threshold_quantity >= v_inv_quantity THEN
        RAISE_APPLICATION_ERROR(-20002, 'Threshold quantity must be less than inventory quantity');
    END IF;

    UPDATE INVENTORY
    SET DRUG_NAME = v_drug_name,
        MANUFACTURER = v_manufacturer,
        INV_QUANTITY = v_inv_quantity,
        BUY_DATE = v_buy_date,
        EXPIRY_DATE = v_expiry_date,
        PRICE = v_price,
        THRESHOLD_QUANTITY = v_threshold_quantity,
        RESTOCK_QUANTITY = v_restock_quantity
    WHERE DRUG_ID = v_drug_id;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating data in INVENTORY table: ' || SQLERRM);
END UPDATE_INVENTORY;
/

-- Delete data from Inventory
CREATE OR REPLACE PROCEDURE DELETE_INVENTORY (
    v_drug_id IN VARCHAR2
) IS
    v_drug_count NUMBER;
BEGIN
    -- Check if the drug ID exists
    SELECT COUNT(*) INTO v_drug_count FROM INVENTORY WHERE DRUG_ID = v_drug_id;
    
    IF v_drug_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Drug ID does not exist in the INVENTORY table.');
    END IF;

    -- If the drug ID exists, delete the record
    DELETE FROM INVENTORY WHERE DRUG_ID = v_drug_id;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error deleting data from INVENTORY table: ' || SQLERRM);
END DELETE_INVENTORY;
/

---------------------------------------------------------------------------
-- STORED PROCEDURE FOR INSERTNIG DATA INTO ORDER_BILL
---------------------------------------------------------------------------
CREATE SEQUENCE order_id_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE INSERT_ORDER_BILL (
    v_pres_id IN VARCHAR2,
    v_emp_id IN VARCHAR2
) IS
    v_pres_count NUMBER;
    v_emp_count NUMBER;
    v_role_name VARCHAR2(50); -- Variable to store the role name
    v_order_id VARCHAR2(20); -- Variable to store the generated order_id
BEGIN
    -- Check if PRESCRIPTION_ID exists in the PRESCRIPTION table
    SELECT COUNT(*) INTO v_pres_count FROM PRESCRIPTION WHERE PRES_ID = v_pres_id;
    IF v_pres_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'PRESCRIPTION_ID does not exist in the PRESCRIPTION table.');
    END IF;

    -- Check if EMPLOYEE_ID exists in the EMPLOYEE table
    SELECT COUNT(*) INTO v_emp_count FROM EMPLOYEE WHERE EMP_ID = v_emp_id;
    IF v_emp_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'EMPLOYEE_ID does not exist in the EMPLOYEE table.');
    END IF;
    
    -- Check if the EMPLOYEE_ID is allocated to a role other than 'Cashier' or 'Admin'
    SELECT R.ROLE_NAME INTO v_role_name
    FROM EMPLOYEE E
    INNER JOIN ROLE R ON E.ROLE_ID = R.ROLE_ID
    WHERE E.EMP_ID = v_emp_id;
    
    IF v_role_name NOT IN ('Cashier', 'Admin') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Only Cashier or Admin can be allocated to order_bill.');
    END IF;
    
    -- Generate the numeric part of the ORDER_ID using the sequence
    DECLARE
        v_seq_num NUMBER;
    BEGIN
        SELECT order_id_seq.NEXTVAL INTO v_seq_num FROM DUAL;
        -- Pad the sequence number with leading zeros if necessary
        v_order_id := 'O' || LPAD(v_seq_num, 3, '0');
    END;
    
    -- Perform the insertion
    INSERT INTO ORDER_BILL (ORDER_ID, PRES_ID, EMP_ID)
    VALUES (v_order_id, v_pres_id, v_emp_id);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20003, 'Duplicate ORDER_ID found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting data into ORDER_BILL table: ' || SQLERRM);
END INSERT_ORDER_BILL;
/

---------------------------------------------------------------------------
-- STORED PROCEDURE FOR INSERTNIG DATA INTO ORDERED_DRUGS
---------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE INSERT_ORDERED_DRUGS (
    v_order_id IN VARCHAR2,
    v_drug_id IN VARCHAR2,
    v_order_quantity IN NUMBER
)
IS
    available_quantity NUMBER;
    updated_quantity NUMBER;
BEGIN
    -- Get available quantity from inventory
    SELECT INV_QUANTITY INTO available_quantity
    FROM INVENTORY
    WHERE DRUG_ID = v_drug_id;
    
    -- Calculate updated quantity based on availability
    IF available_quantity >= v_order_quantity THEN
        updated_quantity := v_order_quantity;
    ELSE
        updated_quantity := available_quantity;
    END IF;
    
    -- Insert data into ORDERED_DRUGS table
    INSERT INTO ORDERED_DRUGS (ORDER_ID, DRUG_ID, ORDER_QUANTITY)
    VALUES (v_order_id, v_drug_id, updated_quantity);
    
    -- Update inventory if necessary
    IF available_quantity < v_order_quantity THEN
        DBMS_OUTPUT.PUT_LINE('Inventory quantity is less than ordered quantity');
        UPDATE INVENTORY
        SET INV_QUANTITY = 0
        WHERE DRUG_ID = v_drug_id;
    ELSIF available_quantity >= v_order_quantity THEN
        UPDATE INVENTORY
        SET INV_QUANTITY = INV_QUANTITY - v_order_quantity
        WHERE DRUG_ID = v_drug_id;
    END IF;
    
    -- Call Insert_Payment_Bill procedure after inserting into ORDERED_DRUGS
    Insert_Payment_Bill(v_order_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found for drug_id: ' || v_drug_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END INSERT_ORDERED_DRUGS;
/

---------------------------------------------------------------------------
-- FUNCTION AND STORED PROCEDURE FOR PAYMENT_BILL
---------------------------------------------------------------------------
--FUNCTION CalculateTotalOrderAmount
CREATE OR REPLACE FUNCTION CalculateTotalOrderAmount(
    p_order_id IN VARCHAR2
)
RETURN NUMBER
IS
    v_total_amount NUMBER := 0;
BEGIN
    SELECT SUM(od.ORDER_QUANTITY * i.PRICE)
    INTO v_total_amount
    FROM ORDERED_DRUGS od
    JOIN INVENTORY i ON od.DRUG_ID = i.DRUG_ID
    WHERE od.ORDER_ID = p_order_id;
    RETURN v_total_amount;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No orders found for the given order ID.');
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END CalculateTotalOrderAmount;
/

--DECLARE
--    p_order_id VARCHAR2(10) := 'O013';
--    v_total_amount NUMBER;
--BEGIN
--    v_total_amount := CalculateTotalOrderAmount(p_order_id);
--    DBMS_OUTPUT.PUT_LINE('Total Order Amount: ' || v_total_amount);
--END;
--/

-- STORED PROCEDURE Insert_Payment_Bill
CREATE OR REPLACE PROCEDURE Insert_Payment_Bill(
    p_order_id IN VARCHAR2
)
IS
    v_total_amount NUMBER;
    v_customer_id VARCHAR2(10);
    v_insurance_balance NUMBER;
    v_insurance_pay NUMBER;
    v_customer_pay NUMBER;
    v_bill_id VARCHAR2(10);
    v_order_processed NUMBER := 0;
    v_insurance_company VARCHAR2(25);
BEGIN
    -- Enable DBMS_OUTPUT
    DBMS_OUTPUT.ENABLE(1000000);
    
    -- Get the total amount from the CalculateTotalOrderAmount function
    v_total_amount := CalculateTotalOrderAmount(p_order_id);
    
    -- Get the customer_id, insurance_balance, and insurance_company based on the order_id
    SELECT c.CUSTOMER_ID, c.INSURANCE_BALANCE, c.INSURANCE_COMPANY
    INTO v_customer_id, v_insurance_balance, v_insurance_company
    FROM ORDER_BILL ob
    JOIN PRESCRIPTION p ON ob.PRES_ID = p.PRES_ID
    JOIN CUSTOMER c ON p.CUSTOMER_ID = c.CUSTOMER_ID
    WHERE ob.ORDER_ID = p_order_id;
    
    -- Check if the order has already been processed
    SELECT COUNT(*) INTO v_order_processed
    FROM PAYMENT_BILL
    WHERE ORDER_ID = p_order_id;
    
    IF v_order_processed = 0 THEN
        -- Insert new payment bill
        INSERT INTO PAYMENT_BILL (
            BILL_ID, ORDER_ID, ORDER_DATE, TOTAL_AMOUNT, CUSTOMER_PAY, INSURANCE_PAY
        )
        VALUES (
            v_bill_id, p_order_id, SYSDATE, v_total_amount, v_customer_pay, v_insurance_pay
        );
        
        -- Update the insurance_balance in the CUSTOMER table
        UPDATE CUSTOMER
        SET INSURANCE_BALANCE = INSURANCE_BALANCE - v_insurance_pay
        WHERE CUSTOMER_ID = v_customer_id;
        
    ELSE
        -- Logic for updating an existing order
        -- Fetch existing bill details
        BEGIN
            SELECT CUSTOMER_PAY, INSURANCE_PAY
            INTO v_customer_pay, v_insurance_pay
            FROM PAYMENT_BILL
            WHERE ORDER_ID = p_order_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('No existing bill details found for order_id: ' || p_order_id);
                v_customer_pay := 0; -- Initialize with default value or handle as per your requirement
                v_insurance_pay := 0; -- Initialize with default value or handle as per your requirement
        END;
        
        -- Update the insurance_pay and customer_pay
        IF v_insurance_balance >= 0.1 * v_total_amount THEN
            v_insurance_pay := 0.1 * v_total_amount;
            v_customer_pay := v_total_amount - v_insurance_pay;
        ELSE
            v_insurance_pay := 0;
            v_customer_pay := v_total_amount;
            DBMS_OUTPUT.PUT_LINE('Insufficient insurance balance. Customer has to pay the whole amount');
        END IF;
        
        -- Update the bill with the new amounts
        UPDATE PAYMENT_BILL
        SET TOTAL_AMOUNT = v_total_amount,
            CUSTOMER_PAY = v_customer_pay,
            INSURANCE_PAY = v_insurance_pay
        WHERE ORDER_ID = p_order_id;
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

---------------------------------------------------------------------------
-- INSERTING DATA IN ALL TABLES VIA STORED PROCEDURES
---------------------------------------------------------------------------

EXEC INSERT_INVENTORY('D003', 'Ibuprofen', 'Johnson and Johnson', 200, TO_DATE('2024-04-11', 'YYYY-MM-DD'), TO_DATE('2025-04-11', 'YYYY-MM-DD'), 15.00, 30, 60);
EXEC INSERT_INVENTORY('D004', 'Amoxicillin', 'GlaxoSmithKline', 150, TO_DATE('2024-04-12', 'YYYY-MM-DD'), TO_DATE('2025-04-12', 'YYYY-MM-DD'), 20.00, 25, 70);
EXEC INSERT_INVENTORY('D005', 'Aspirin', 'Bayer', 300, TO_DATE('2024-04-13', 'YYYY-MM-DD'), TO_DATE('2025-04-13', 'YYYY-MM-DD'), 8.00, 15, 40);
EXEC INSERT_INVENTORY('D006', 'Loratadine', 'Merck', 250, TO_DATE('2024-04-14', 'YYYY-MM-DD'), TO_DATE('2025-04-14', 'YYYY-MM-DD'), 12.00, 35, 80);
EXEC INSERT_INVENTORY('D007', 'Omeprazole', 'Novartis', 180, TO_DATE('2024-04-15', 'YYYY-MM-DD'), TO_DATE('2025-04-15', 'YYYY-MM-DD'), 18.00, 40, 90);
EXEC INSERT_INVENTORY('D008', 'Simvastatin', 'AstraZeneca', 220, TO_DATE('2024-04-16', 'YYYY-MM-DD'), TO_DATE('2025-04-16', 'YYYY-MM-DD'), 25.00, 20, 55);
EXEC INSERT_INVENTORY('D009', 'Metformin', 'Bayer', 170, TO_DATE('2024-04-17', 'YYYY-MM-DD'), TO_DATE('2025-04-17', 'YYYY-MM-DD'), 22.00, 30, 65);
EXEC INSERT_INVENTORY('D010', 'Hydrochlorothiazide', 'Novartis', 190, TO_DATE('2024-04-18', 'YYYY-MM-DD'), TO_DATE('2025-04-18', 'YYYY-MM-DD'), 14.00, 25, 45);
EXEC INSERT_INVENTORY('D011', 'Atorvastatin', 'Abbott Laboratories', 270, TO_DATE('2024-04-19', 'YYYY-MM-DD'), TO_DATE('2025-04-19', 'YYYY-MM-DD'), 28.00, 35, 75);
EXEC INSERT_INVENTORY('D012', 'Acetaminophen', 'Johnson and Johnson', 230, TO_DATE('2024-04-20', 'YYYY-MM-DD'), TO_DATE('2025-04-20', 'YYYY-MM-DD'), 9.00, 22, 50);

EXEC INSERT_ROLE('R001', 'Admin');
EXEC INSERT_ROLE('R002', 'Cashier');
EXEC INSERT_ROLE('R003', 'Inventory Manager');


EXEC INSERT_EMPLOYEE('E001', 'John', 'Doe', TO_DATE('2024-04-10', 'YYYY-MM-DD'), TO_DATE('2025-04-10', 'YYYY-MM-DD'), 'R001', 50000);
EXEC INSERT_EMPLOYEE('E002', 'Jane', 'Smith', TO_DATE('2024-04-11', 'YYYY-MM-DD'), TO_DATE('2025-04-11', 'YYYY-MM-DD'), 'R002', 45000);
EXEC INSERT_EMPLOYEE('E003', 'Michael', 'Johnson', TO_DATE('2024-04-12', 'YYYY-MM-DD'), TO_DATE('2025-04-12', 'YYYY-MM-DD'), 'R003', 40000);
--EXEC INSERT_EMPLOYEE('E004', 'Emily', 'Brown', TO_DATE('2024-04-13', 'YYYY-MM-DD'), TO_DATE('2025-04-13', 'YYYY-MM-DD'), 'R001', 55000);
EXEC INSERT_EMPLOYEE('E005', 'David', 'Wilson', TO_DATE('2024-04-14', 'YYYY-MM-DD'), TO_DATE('2025-04-14', 'YYYY-MM-DD'), 'R002', 48000);
EXEC INSERT_EMPLOYEE('E006', 'Jennifer', 'Taylor', TO_DATE('2024-04-15', 'YYYY-MM-DD'), TO_DATE('2025-04-15', 'YYYY-MM-DD'), 'R003', 42000);


EXEC INSERT_CUSTOMER('C0001', 'John', 'Doe', 'Male', 'New York', 5000, 'LIC Insurance', TO_DATE('2024-04-11', 'YYYY-MM-DD'), TO_DATE('2025-04-11', 'YYYY-MM-DD'));
EXEC INSERT_CUSTOMER('C0002', 'Alice', 'Smith', 'Female', 'Los Angeles', 6000, 'XYZ Insurance Co.', TO_DATE('2024-04-12', 'YYYY-MM-DD'), TO_DATE('2025-04-12', 'YYYY-MM-DD'));
EXEC INSERT_CUSTOMER('C0003', 'Michael', 'Johnson', 'Male', 'Chicago', 7000, 'XYZ Insurance Co.', TO_DATE('2024-04-13', 'YYYY-MM-DD'), TO_DATE('2025-04-13', 'YYYY-MM-DD'));
EXEC INSERT_CUSTOMER('C0004', 'Emily', 'Brown', 'Female', 'Houston', 8000, 'LIC Insurance', TO_DATE('2024-04-14', 'YYYY-MM-DD'), TO_DATE('2025-04-14', 'YYYY-MM-DD'));
EXEC INSERT_CUSTOMER('C0005', 'David', 'Williams', 'Male', 'Phoenix', 9000, 'LIC Insurance', TO_DATE('2024-04-15', 'YYYY-MM-DD'), TO_DATE('2025-04-15', 'YYYY-MM-DD'));
EXEC INSERT_CUSTOMER('C0006', 'Sophia', 'Jones', 'Female', 'Philadelphia', 10000, 'METLIFE Insurance', TO_DATE('2024-04-16', 'YYYY-MM-DD'), TO_DATE('2025-04-16', 'YYYY-MM-DD'));


EXEC INSERT_PRESCRIPTION('C0001', 'P001', TO_DATE('2024-04-17', 'YYYY-MM-DD'), 'DOC001');
EXEC INSERT_PRESCRIPTION('C0002', 'P002', TO_DATE('2024-04-18', 'YYYY-MM-DD'), 'DOC002');
EXEC INSERT_PRESCRIPTION('C0003', 'P003', TO_DATE('2024-04-19', 'YYYY-MM-DD'), 'DOC003');
EXEC INSERT_PRESCRIPTION('C0004', 'P004', TO_DATE('2024-04-20', 'YYYY-MM-DD'), 'DOC004');
EXEC INSERT_PRESCRIPTION('C0001', 'P005', TO_DATE('2024-04-21', 'YYYY-MM-DD'), 'DOC005');
EXEC INSERT_PRESCRIPTION('C0002', 'P006', TO_DATE('2024-04-22', 'YYYY-MM-DD'), 'DOC006');
EXEC INSERT_PRESCRIPTION('C0001', 'P007', TO_DATE('2024-04-17', 'YYYY-MM-DD'), 'DOC001');
EXEC INSERT_PRESCRIPTION('C0002', 'P008', TO_DATE('2024-04-18', 'YYYY-MM-DD'), 'DOC002');
EXEC INSERT_PRESCRIPTION('C0003', 'P009', TO_DATE('2024-04-19', 'YYYY-MM-DD'), 'DOC003');
EXEC INSERT_PRESCRIPTION('C0004', 'P010', TO_DATE('2024-04-20', 'YYYY-MM-DD'), 'DOC004');
EXEC INSERT_PRESCRIPTION('C0005', 'P011', TO_DATE('2024-04-21', 'YYYY-MM-DD'), 'DOC005');
EXEC INSERT_PRESCRIPTION('C0006', 'P012', TO_DATE('2024-04-22', 'YYYY-MM-DD'), 'DOC006');


-- For the first prescription:
EXEC INSERT_PRESCRIBED_DRUGS('P001', 'Paracetamol', 2);
EXEC INSERT_PRESCRIBED_DRUGS('P001', 'Ibuprofen', 1);
EXEC INSERT_PRESCRIBED_DRUGS('P001', 'Aspirin', 1);

-- For the second prescription:
EXEC INSERT_PRESCRIBED_DRUGS('P002', 'Omeprazole', 3);
EXEC INSERT_PRESCRIBED_DRUGS('P002', 'Metformin', 1);
EXEC INSERT_PRESCRIBED_DRUGS('P002', 'Simvastatin', 2);
EXEC INSERT_PRESCRIBED_DRUGS('P002', 'Atorvastatin', 1);

-- For the third prescription:
EXEC INSERT_PRESCRIBED_DRUGS('P003', 'Amoxicillin', 1);

-- For the fifth prescription:
EXEC INSERT_PRESCRIBED_DRUGS('P005', 'Lisinopril', 1);

-- For the sixth prescription:
EXEC INSERT_PRESCRIBED_DRUGS('P006', 'Levothyroxine', 1);
EXEC INSERT_PRESCRIBED_DRUGS('P006', 'Metoprolol', 1);

-- For ORDER_BILL
EXEC INSERT_ORDER_BILL('P002', 'E002');
EXEC INSERT_ORDER_BILL('P003', 'E005');
--EXEC INSERT_ORDER_BILL('P004', 'E006'); // Only Cashier can be allocated to order_bill
EXEC INSERT_ORDER_BILL('P005', 'E002');
EXEC INSERT_ORDER_BILL('P006', 'E005');
EXEC INSERT_ORDER_BILL('P007', 'E002');
EXEC INSERT_ORDER_BILL('P008', 'E005');
EXEC INSERT_ORDER_BILL('P009', 'E005');
EXEC INSERT_ORDER_BILL('P010', 'E002');
EXEC INSERT_ORDER_BILL('P011', 'E002');

-- For ORDERED_DRUGS
EXEC INSERT_ORDERED_DRUGS('O013', 'D007', 5);
EXEC INSERT_ORDERED_DRUGS('O005', 'D004', 3);
EXEC INSERT_ORDERED_DRUGS('O006', 'D005', 2);

EXEC INSERT_ORDERED_DRUGS('O002', 'D006', 4);
EXEC INSERT_ORDERED_DRUGS('O002', 'D007', 3);
EXEC INSERT_ORDERED_DRUGS('O002', 'D008', 2);
EXEC INSERT_ORDERED_DRUGS('O002', 'D009', 1);

EXEC INSERT_ORDERED_DRUGS('O003', 'D010', 2);
EXEC INSERT_ORDERED_DRUGS('O003', 'D011', 3);

EXEC INSERT_ORDERED_DRUGS('O005', 'D012', 5);


---------------------------------------------------------------------------
-- CHECKING ALL TABLES WITH INSERTED DATA
---------------------------------------------------------------------------

-- INVENTORY Table
SELECT * FROM INVENTORY;

-- ROLE Table
SELECT * FROM ROLE;

-- EMPLOYEE Table
SELECT * FROM EMPLOYEE;

-- CUSTOMER Table
SELECT * FROM CUSTOMER;

-- PRESCRIPTION Table
SELECT * FROM PRESCRIPTION;

-- PRESCRIBED_DRUGS Table
SELECT * FROM PRESCRIBED_DRUGS;

-- ORDER_BILL Table
SELECT * FROM ORDER_BILL;

-- ORDERED_DRUGS Table
SELECT * FROM ORDERED_DRUGS;

-- PAYMENT_BILL Table
SELECT * FROM PAYMENT_BILL;
