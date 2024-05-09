//Sequence_ID generation for emp_Notification
CREATE SEQUENCE employee_notification_seq START WITH 1 INCREMENT BY 1;

//Trigger for inserting in emp_notification Table
CREATE OR REPLACE TRIGGER trg_insert_employee_notification
AFTER INSERT ON NOTIFICATION
FOR EACH ROW
BEGIN
    -- Insert records into employee_notification for employees with admin or inventory manager role
    INSERT INTO employee_notification (EMP_NOTIF_ID, NOTIF_ID, EMP_ID)
    SELECT 'EMP_NOTIF' || LPAD(employee_notification_seq.NEXTVAL, 3, '0'), :NEW.NOTIF_ID, e.EMP_ID
    FROM EMPLOYEE e
    JOIN ROLE r ON e.ROLE_ID = r.ROLE_ID
    WHERE r.ROLE_NAME IN ('Admin', 'Inventory Manager');
END;
/

//Test Trigger
UPDATE INVENTORY SET INV_QUANTITY = 20 WHERE DRUG_ID = 'DRG013';

select * from EMPLOYEE_NOTIFICATION;
select * from EMPLOYEE;

select * from role;
SELECT trigger_name, status FROM user_triggers WHERE table_name = 'NOTIFICATION';
