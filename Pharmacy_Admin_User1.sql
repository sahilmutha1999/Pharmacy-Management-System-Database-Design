set serveroutput on;

CREATE OR REPLACE PACKAGE UserManagementPackage AS
  PROCEDURE CreateUser(p_username IN VARCHAR2, p_password IN VARCHAR2, p_role IN VARCHAR2);
END UserManagementPackage;
/

CREATE OR REPLACE PACKAGE BODY UserManagementPackage AS
  PROCEDURE CreateUser(p_username IN VARCHAR2, p_password IN VARCHAR2, p_role IN VARCHAR2) IS
  BEGIN
    
    -- Check if the role is valid
    IF p_role NOT IN ('Cashier', 'Inventory_Manager') THEN
      RAISE_APPLICATION_ERROR(-20001, 'Invalid role. Role must be either "Cashier" or "Inventory_Manager".');
    END IF;
    
    -- Check if the user already exists
    FOR user_exists IN (SELECT username FROM all_users WHERE username = UPPER(p_username)) LOOP
      DBMS_OUTPUT.PUT_LINE('User ' || p_username || ' already exists.');
      RETURN;
    END LOOP;

    -- Create the user
    EXECUTE IMMEDIATE 'CREATE USER ' || p_username || ' IDENTIFIED BY ' || p_password;

    -- Grant privileges directly based on the role
    IF p_role = 'Cashier' THEN
      EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON admin.ORDER_BILL TO ' || p_username;
      EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON admin.PAYMENT_BILL TO ' || p_username;
      EXECUTE IMMEDIATE 'GRANT INSERT ON admin.CUSTOMER TO ' || p_username;
      EXECUTE IMMEDIATE 'GRANT INSERT ON admin.PRESCRIPTION TO ' || p_username;
      EXECUTE IMMEDIATE 'GRANT INSERT ON admin.PRESCRIBED_DRUGS TO ' || p_username;
      EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO '|| p_username;
    ELSIF p_role = 'Inventory_Manager' THEN
      EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON admin.INVENTORY TO ' || p_username;
      EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON admin.NOTIFICATION TO ' || p_username;
      EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO '|| p_username;
    END IF;

    DBMS_OUTPUT.PUT_LINE('User ' || p_username || ' created successfully.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error creating user ' || p_username || ': ' || SQLERRM);
  END CreateUser;
END UserManagementPackage;
/


BEGIN
  UserManagementPackage.CreateUser('cashier_user1', 'BostonSpring2024##', 'Cashier');
  UserManagementPackage.CreateUser('inventory_manager_user1', 'BostonSpring2024###', 'Inventory_Manager');
END;
/
