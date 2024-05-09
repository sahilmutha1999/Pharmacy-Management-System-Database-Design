---------------------------------------------------------------------------
-- VIEWS
---------------------------------------------------------------------------

-- View 1 => Low Inventory Drugs Status:

CREATE OR REPLACE VIEW Low_Inventory_Drugs AS
SELECT DRUG_ID,
       DRUG_NAME,
       MANUFACTURER,
       INV_QUANTITY,
       THRESHOLD_QUANTITY
FROM INVENTORY
WHERE INV_QUANTITY < THRESHOLD_QUANTITY
ORDER BY INV_QUANTITY ASC;


SELECT * FROM Low_Inventory_Drugs;


-- View 2 => Top-5 Customers BY ORDER VALUE
    
CREATE OR REPLACE VIEW Top_5_Customers_By_Order_Value AS
SELECT c.CUSTOMER_ID,
       c.FIRST_NAME,
       c.LAST_NAME,
       SUM(pb.TOTAL_AMOUNT) AS TOTAL_ORDER_VALUE
FROM CUSTOMER c
JOIN PRESCRIPTION p ON c.CUSTOMER_ID = p.CUSTOMER_ID
JOIN ORDER_BILL ob ON p.PRES_ID = ob.PRES_ID
JOIN PAYMENT_BILL pb ON ob.ORDER_ID = pb.ORDER_ID
GROUP BY c.CUSTOMER_ID, c.FIRST_NAME, c.LAST_NAME, c.CITY
ORDER BY TOTAL_ORDER_VALUE DESC
FETCH FIRST 5 ROWS ONLY;


SELECT * FROM Top_5_Customers_By_Order_Value;

-- View 3 => Employee Duration and Salary Views

CREATE OR REPLACE VIEW EMPLOYEE_VIEW AS
SELECT E.FIRST_NAME,E.LAST_NAME,R.ROLE_NAME,E.SALARY,TRUNC(MONTHS_BETWEEN(NVL(E.END_DATE, SYSDATE), E.START_DATE) / 12) || '&' || MOD(TRUNC(MONTHS_BETWEEN(NVL(E.END_DATE, SYSDATE), E.START_DATE)), 12) AS YEARS_MONTHS_WORKED
FROM EMPLOYEE E
JOIN ROLE R
ON E.ROLE_ID = R.ROLE_ID;

SELECT * FROM EMPLOYEE_VIEW;


-- View 4 => Customers Ordering maximum times:

CREATE OR REPLACE VIEW Customers_With_Max_Orders AS
SELECT c.CUSTOMER_ID,
       c.FIRST_NAME,
       c.LAST_NAME,
       c.CITY,
       COUNT(p.PRES_ID) AS NUM_ORDERS
FROM CUSTOMER c
JOIN PRESCRIPTION p ON c.CUSTOMER_ID = p.CUSTOMER_ID
JOIN ORDER_BILL ob ON p.PRES_ID = ob.PRES_ID
GROUP BY c.CUSTOMER_ID, c.FIRST_NAME, c.LAST_NAME, c.CITY
HAVING COUNT(p.PRES_ID) = (
    SELECT MAX(order_count)
    FROM (
        SELECT COUNT(p.PRES_ID) AS order_count
        FROM PRESCRIPTION p
        GROUP BY p.CUSTOMER_ID
    )
)
ORDER BY NUM_ORDERS DESC;

SELECT * FROM Customers_With_Max_Orders;


--  View 5 => top-performing employees in terms of sales

CREATE OR REPLACE VIEW Employee_Sales_Summary AS
SELECT e.EMP_ID,
       e.FIRST_NAME,
       e.LAST_NAME,
       SUM(pb.TOTAL_AMOUNT) AS TOTAL_SALES_AMOUNT
FROM EMPLOYEE e
JOIN ORDER_BILL ob ON e.EMP_ID = ob.EMP_ID
JOIN PAYMENT_BILL pb ON ob.ORDER_ID = pb.ORDER_ID
GROUP BY e.EMP_ID, e.FIRST_NAME, e.LAST_NAME
ORDER BY TOTAL_SALES_AMOUNT DESC;

SELECT * FROM Employee_Sales_Summary;