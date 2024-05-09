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
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found for drug_id: ' || v_drug_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END INSERT_ORDERED_DRUGS;
/

---------------------------------------------------------------------------
-- AFTER TRIGGER FOR INSERTNIG DATA INTO PAYMENT_BILL
---------------------------------------------------------------------------



---------------------------------------------------------------------------
-- STORED PROCEDURE FOR INSERTNIG DATA INTO PAYMENT_BILL
---------------------------------------------------------------------------
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

    -- Calculate the insurance_pay and customer_pay
    IF v_insurance_balance >= 0.1 * v_total_amount AND v_insurance_company IS NOT NULL AND TRIM(v_insurance_company) <> '' THEN
        v_insurance_pay := 0.1 * v_total_amount;
        v_customer_pay := v_total_amount - v_insurance_pay;
    ELSIF v_insurance_balance < 0.1 * v_total_amount THEN
        v_insurance_pay := 0;
        v_customer_pay := v_total_amount;
        DBMS_OUTPUT.PUT_LINE('Insufficient insurance balance. Customer has to pay the whole amount');
    ELSE
        v_insurance_pay := NULL;
        v_customer_pay := v_total_amount;
        DBMS_OUTPUT.PUT_LINE("Customer doesn't have insurance. Customer has to pay the whole amount");
    END IF;

    -- Check if the order has already been processed
    SELECT COUNT(*) INTO v_order_processed
    FROM PAYMENT_BILL
    WHERE ORDER_ID = p_order_id;

    -- Update the insurance_balance in the CUSTOMER table only if the order is being processed for the first time
    IF v_order_processed = 0 THEN
        UPDATE CUSTOMER
        SET INSURANCE_BALANCE = INSURANCE_BALANCE - v_insurance_pay
        WHERE CUSTOMER_ID = v_customer_id;
    END IF;

    -- Generate the bill_id
    SELECT 'BILL' || LPAD(TO_CHAR(COUNT(*) + 1), 3, '0')
    INTO v_bill_id
    FROM PAYMENT_BILL;

    -- Insert the data into the Payment_bill table
    INSERT INTO PAYMENT_BILL (
        BILL_ID, ORDER_ID, ORDER_DATE, TOTAL_AMOUNT, CUSTOMER_PAY, INSURANCE_PAY
    )
    VALUES (
        v_bill_id, p_order_id, SYSDATE, v_total_amount, v_customer_pay, v_insurance_pay
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/