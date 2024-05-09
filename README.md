# Pharmacy Management System

## Introduction

This repository contains the code for a Pharmacy Management System. The system is designed to manage various aspects of a pharmacy, including inventory, customer records, prescriptions, billing, and employee management.

## Setup Instructions

To set up the Pharmacy Management System database, follow these steps:

1. Execute the provided SQL script in your SQL database management system.
2. Run each section of the script sequentially to create tables, insert sample data, manage roles and permissions, and create views.

## Database Schema

The database schema includes tables for various entities such as `Employee`, `Customer`, `Role`, `Prescription`, `Inventory`, `Order_Bill`, and `Ordered_Drugs`. These tables store information related to employees, customers, roles, prescriptions, drug inventory, customer orders, and ordered drugs.

## Sample Data

Sample data is provided for each table to demonstrate database functionality, including customer details, prescription information, drug inventory records, employee information, payment details, and system notifications.

## Roles and Permissions

Roles are defined to manage database access:

- `Pharmacy_Admin`: Full access to all database tables, user account management, and role assignment.
- `Cashier`: Access to billing-related information, including customer orders and billing, but restricted from drug inventory and sensitive employee data.
- `Inventory_Manager`: Access to drug inventory management, including viewing and updating inventory details, with restrictions on customer and billing information.

Users are assigned to roles with appropriate privileges to ensure proper access control.


## Views

Several views provide simplified access to specific database data:

Several views provide simplified access to specific database data:

1. **Low Inventory Drugs Status:**
   - **Objective:** To identify drugs that are running low in inventory based on a specified threshold quantity.
   - **Justification:** Timely restocking of drugs helps prevent stockouts and ensures uninterrupted availability for customers, thereby improving customer satisfaction and retention.
   - **SQL Command/View:**
     ```sql
     CREATE OR REPLACE VIEW Low_Inventory_Drugs AS
     SELECT DRUG_ID,
            DRUG_NAME,
            MANUFACTURER,
            INV_QUANTITY,
            THRESHOLD_QUANTITY
     FROM INVENTORY
     WHERE INV_QUANTITY < THRESHOLD_QUANTITY
     ORDER BY INV_QUANTITY ASC;
     ```

2. **Top-5 Customers By Order Value:**
   - **Objective:** To identify the top 5 customers based on their total order value.
   - **Justification:** Recognizing high-value customers allows targeted marketing strategies and personalized offers, which can enhance customer loyalty and increase revenue.
   - **SQL Command/View:**
     ```sql
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
     ```

3. **Employee Duration and Salary Views:**
   - **Objective:** To display employee details along with their role, salary, and duration of employment.
   - **Justification:** Understanding employee tenure and compensation helps in evaluating workforce productivity and ensuring fair remuneration, which can boost employee morale and retention.
   - **SQL Command/View:**
     ```sql
     CREATE OR REPLACE VIEW EMPLOYEE_VIEW AS
     SELECT E.FIRST_NAME,E.LAST_NAME,R.ROLE_NAME,E.SALARY,TRUNC(MONTHS_BETWEEN(NVL(E.END_DATE, SYSDATE), E.START_DATE) / 12) || '&' || MOD(TRUNC(MONTHS_BETWEEN(NVL(E.END_DATE, SYSDATE), E.START_DATE)), 12) AS YEARS_MONTHS_WORKED
     FROM EMPLOYEE E
     JOIN ROLE R
     ON E.ROLE_ID = R.ROLE_ID;
     ```

4. **Customers Ordering Maximum Times:**
   - **Objective:** To identify customers who have placed the maximum number of orders.
   - **Justification:** Recognizing frequent customers helps in tailoring marketing strategies and loyalty programs to retain valuable customers and drive repeat business.
   - **SQL Command/View:**
     ```sql
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
     ```

5. **Top-performing Employees in Terms of Sales:**
   - **Objective:** To highlight employees who have generated the highest sales revenue.
   - **Justification:** Recognizing top-performing employees can inform incentive programs and performance evaluations, motivating employees to achieve sales targets and drive revenue growth.
   - **SQL Command/View:**
     ```sql
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
     ```

These views offer convenient data retrieval for relevant stakeholders, enhancing system usability and efficiency.

## Triggers

- `Low Inventory Trigger`: Notifies the system when inventory levels fall below a certain threshold.
- `Employee Notification Trigger`: Sends notifications to employees with admin or inventory manager roles when new system notifications are inserted.

## Functions and Procedures

The code includes stored procedures for various tasks such as inserting, updating, and deleting records from the database. Each procedure is designed to perform a specific action within the system, such as inserting a new employee or updating an existing customer record.

## Package: Order Management

This package provides functionalities related to managing customer orders.

### Description

The Order Management package includes procedures for creating, updating, and deleting customer orders.

#### Procedures:

- `INSERT_ORDER_BILL`: Inserts a new customer order into the database.
- `UPDATE_ORDER_BILL`: Updates an existing customer order in the database.
- `DELETE_ORDER_BILL`: Deletes a customer order from the database.

### How to Execute

To execute the Order Management package, follow these steps:


1. `Final_Project.sql`
2. `Triggers_Low_Inventory.sql`
3. `Triggers_Sending_Notif_to_emp.sql`
4. `Data_insertion_in_all_tables.sql`
5. `Pharmacy_Admin_User1.sql`

These scripts will create the necessary database objects, insert sample data, and set up user accounts for the Pharmacy Management System.


## Package: User Management

This package provides functionalities for managing user accounts and permissions.

### Description

The User Management package includes procedures for creating and deleting customer records.

#### Procedures:

- `CREATE_CUSTOMER`: Creates a new customer record in the database.
- `DELETE_CUSTOMER`: Deletes an existing customer record from the database.

### How to Execute

To execute the User Management package, follow these steps:

1. Open SQL Developer or any other SQL execution tool.
2. Run the script `Package/Role_and_Emp_Creation_Package.sql` to create the package specifications and body.
3. To execute the package, run the script in order above.

## How to Run

Execute the provided SQL scripts in a SQL database management system to set up the Pharmacy Management System and perform various tasks such as creating tables, inserting sample data, managing roles and permissions, and executing stored procedures.
