//Package for Inventory Trigger
CREATE OR REPLACE PACKAGE inventory_trigger_pkg AS
    -- Package-level variables to store the relevant data
    v_drug_id INVENTORY.DRUG_ID%TYPE;
    v_drug_name INVENTORY.DRUG_NAME%TYPE;
END inventory_trigger_pkg;
/

//Trigger for update done if low level of quantity

CREATE OR REPLACE TRIGGER trg_low_inventory
FOR INSERT OR UPDATE OF INV_QUANTITY ON INVENTORY
COMPOUND TRIGGER

    -- Before statement trigger point
    BEFORE STATEMENT IS
    BEGIN
        NULL; -- Placeholder for any before statement logic
    END BEFORE STATEMENT;

    -- Before row trigger point
    BEFORE EACH ROW IS
    BEGIN
        NULL; -- Placeholder for any before row logic
    END BEFORE EACH ROW;

    -- After row trigger point
    AFTER EACH ROW IS
    BEGIN
        -- Check if the inventory quantity is below the threshold
        IF :NEW.INV_QUANTITY < :NEW.THRESHOLD_QUANTITY THEN
            -- Generate a unique ID for the notification
            DECLARE
                v_notification_id VARCHAR2(10);
            BEGIN
                LOOP
                    -- Attempt to generate a unique notification ID
                    v_notification_id := 'NOTIF' || LPAD(NOTIF_ID_SEQ.NEXTVAL, 3, '0');
                    
                    -- Attempt to insert the notification
                    BEGIN
                        INSERT INTO NOTIFICATION (NOTIF_ID, NOTIF_DATE, MESSAGE, DRUG_ID)
                        VALUES (v_notification_id, SYSDATE,  :NEW.DRUG_NAME || ' is running low in inventory. Restock needed.', :NEW.DRUG_ID);
                        EXIT; -- Exit the loop if the insert succeeds
                    EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                            NULL; -- Ignore the exception and continue the loop
                    END;
                END LOOP;
            END;
        END IF;
    END AFTER EACH ROW;

    -- After statement trigger point
    AFTER STATEMENT IS
    BEGIN
        NULL; -- Placeholder for any after statement logic
    END AFTER STATEMENT;

END trg_low_inventory;
/

//To drop Trigger
DROP TRIGGER PHARMACY.trg_low_inventory;

//Test Trigger
UPDATE INVENTORY SET INV_QUANTITY = 20 WHERE DRUG_ID = 'DRG013';


select * from INVENTORY;
select * from NOTIFICATION;


SELECT * FROM USER_ERRORS WHERE NAME = 'TRG_LOW_INVENTORY_TRIGGER';
