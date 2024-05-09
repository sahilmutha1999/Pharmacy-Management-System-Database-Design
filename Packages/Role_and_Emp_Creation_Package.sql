CREATE OR REPLACE PACKAGE EMPLOYEE_ROLE_MANAGEMENT_PKG AS

    -- Role Procedures
    PROCEDURE INSERT_ROLE (
        v_role_id IN VARCHAR2,
        v_role_name IN VARCHAR2
    );

    -- Employee Procedures
    PROCEDURE INSERT_EMPLOYEE (
        v_emp_id IN VARCHAR2,
        v_first_name IN VARCHAR2,
        v_last_name IN VARCHAR2,
        v_start_date IN DATE,
        v_end_date IN DATE DEFAULT NULL,
        v_role_id IN VARCHAR2,
        v_salary IN NUMBER
    );

    PROCEDURE UPDATE_EMPLOYEE (
        v_emp_id IN VARCHAR2,
        v_first_name IN VARCHAR2,
        v_last_name IN VARCHAR2,
        v_start_date IN DATE,
        v_end_date IN DATE DEFAULT NULL,
        v_role_id IN VARCHAR2,
        v_salary IN NUMBER
    );

    PROCEDURE DELETE_EMPLOYEE (
        v_emp_id IN VARCHAR2
    );

END EMPLOYEE_ROLE_MANAGEMENT_PKG;
/


CREATE OR REPLACE PACKAGE BODY EMPLOYEE_ROLE_MANAGEMENT_PKG AS

    -- Role Procedures
    PROCEDURE INSERT_ROLE (
        v_role_id IN VARCHAR2,
        v_role_name IN VARCHAR2
    ) IS
        v_admin_count NUMBER;
    BEGIN
        -- Check data type and length for ROLE_ID
        IF NOT (v_role_id IS NULL OR LENGTH(v_role_id) <= 10) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid data type or length for ROLE_ID.');
        END IF;

        -- Check if ROLE_NAME is one of the allowed values
        IF NOT (v_role_name IN ('Admin', 'Cashier', 'Inventory Manager')) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invalid ROLE_NAME. Role must be one of: Admin, Cashier, Inventory Manager.');
        END IF;
        
        -- Check if ROLE_NAME 'Admin' already exists
        IF v_role_name = 'Admin' THEN
            SELECT COUNT(*) INTO v_admin_count FROM ROLE WHERE ROLE_NAME = 'Admin';
            IF v_admin_count > 0 THEN
                RAISE_APPLICATION_ERROR(-20003, 'Only one role with the name Admin can exist in the ROLE table.');
            END IF;
        END IF;
        
        -- Perform the insertion
        INSERT INTO ROLE (ROLE_ID, ROLE_NAME)
        VALUES (v_role_id, v_role_name);
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20003, 'Duplicate ROLE_ID found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inserting data into ROLE table: ' || SQLERRM);
    END INSERT_ROLE;

    -- Employee Procedures
    PROCEDURE INSERT_EMPLOYEE (
        v_emp_id IN VARCHAR2,
        v_first_name IN VARCHAR2,
        v_last_name IN VARCHAR2,
        v_start_date IN DATE,
        v_end_date IN DATE DEFAULT NULL,
        v_role_id IN VARCHAR2,
        v_salary IN NUMBER
    ) IS
        v_role_admin_count NUMBER;
        v_role_emp_count NUMBER;
    BEGIN
        -- Check data type and length for EMP_ID
        IF NOT (v_emp_id IS NULL OR LENGTH(v_emp_id) <= 10) THEN
            RAISE_APPLICATION_ERROR(-20004, 'Invalid data type or length for EMP_ID.');
        END IF;

        -- Check if ROLE_ID exists in the ROLE table
        SELECT COUNT(*) INTO v_role_admin_count FROM ROLE WHERE ROLE_ID = v_role_id AND ROLE_NAME = 'Admin';
        IF v_role_admin_count = 1 THEN
            -- Check if an employee is already assigned to the 'Admin' role
            SELECT COUNT(*) INTO v_role_emp_count FROM EMPLOYEE WHERE ROLE_ID = v_role_id;
            IF v_role_emp_count > 0 THEN
                RAISE_APPLICATION_ERROR(-20005, 'The role being inserted is allocated to an admin.');
            END IF;
        END IF;
        
        -- Check if END_DATE is not null, then ensure it's greater than START_DATE
        IF v_end_date IS NOT NULL AND v_end_date <= v_start_date THEN
            RAISE_APPLICATION_ERROR(-20007, 'END_DATE must be greater than START_DATE.');
        END IF;
        
        -- Perform the insertion
        INSERT INTO EMPLOYEE (EMP_ID, FIRST_NAME, LAST_NAME, START_DATE, END_DATE, ROLE_ID, SALARY)
        VALUES (v_emp_id, v_first_name, v_last_name, v_start_date, v_end_date, v_role_id, v_salary);
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20006, 'Duplicate EMP_ID found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inserting data into EMPLOYEE table: ' || SQLERRM);
    END INSERT_EMPLOYEE;

    PROCEDURE UPDATE_EMPLOYEE (
        v_emp_id IN VARCHAR2,
        v_first_name IN VARCHAR2,
        v_last_name IN VARCHAR2,
        v_start_date IN DATE,
        v_end_date IN DATE DEFAULT NULL,
        v_role_id IN VARCHAR2,
        v_salary IN NUMBER
    ) IS
        v_emp_count NUMBER;
        v_role_count NUMBER;
        v_role_name VARCHAR2(50);  -- Variable to store the role name
    BEGIN
        -- Check if EMP_ID exists
        SELECT COUNT(*) INTO v_emp_count FROM EMPLOYEE WHERE EMP_ID = v_emp_id;
        IF v_emp_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20009, 'EMP_ID does not exist in the EMPLOYEE table.');
        END IF;

        -- Check if ROLE_ID exists in the ROLE table
        SELECT COUNT(*) INTO v_role_count FROM ROLE WHERE ROLE_ID = v_role_id;
        IF v_role_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20008, 'ROLE_ID does not exist in the ROLE table.');
        END IF;
        
        -- Fetch the role name based on the role id
        SELECT ROLE_NAME INTO v_role_name FROM ROLE WHERE ROLE_ID = v_role_id;
    
        -- Check if the new ROLE_NAME is 'Admin' and throw an error
        IF v_role_name = 'Admin' THEN
            RAISE_APPLICATION_ERROR(-20010, 'Admin role cannot be allocated.');
        END IF;
        -- Check if END_DATE is not null, then ensure it's greater than START_DATE
        IF v_end_date IS NOT NULL AND v_end_date <= v_start_date THEN
            RAISE_APPLICATION_ERROR(-20007, 'END_DATE must be greater than START_DATE.');
        END IF;
        
        -- Update employee details
        UPDATE EMPLOYEE
        SET FIRST_NAME = v_first_name,
            LAST_NAME = v_last_name,
            START_DATE = v_start_date,
            END_DATE = v_end_date,
            ROLE_ID = v_role_id,
            SALARY = v_salary
        WHERE EMP_ID = v_emp_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error updating data in EMPLOYEE table: ' || SQLERRM);
    END UPDATE_EMPLOYEE;

    PROCEDURE DELETE_EMPLOYEE (
        v_emp_id IN VARCHAR2
    ) IS
        v_emp_count NUMBER;
    BEGIN
        -- Check if EMP_ID exists
        SELECT COUNT(*) INTO v_emp_count FROM EMPLOYEE WHERE EMP_ID = v_emp_id;
        IF v_emp_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'EMP_ID does not exist in the EMPLOYEE table.');
        END IF;

        -- Delete employee
        DELETE FROM EMPLOYEE WHERE EMP_ID = v_emp_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error deleting data from EMPLOYEE table: ' || SQLERRM);
    END DELETE_EMPLOYEE;

END EMPLOYEE_ROLE_MANAGEMENT_PKG;
/


