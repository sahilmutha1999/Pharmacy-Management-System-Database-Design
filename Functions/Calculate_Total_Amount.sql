--FUNCTION to Calculate Total Order Amount
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
