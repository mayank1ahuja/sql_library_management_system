# Library Management System using SQL Project

## 📖Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `sql_project_p2`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library](https://github.com/mayank1ahuja/sql_library_management_system/blob/9c892056b58c9e05af1572a2bc9621b74d857436/library.jpg)

## 📌Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## 📂Project Structure

### 1. Database Setup
![ERD](https://github.com/mayank1ahuja/sql_library_management_system/blob/9c892056b58c9e05af1572a2bc9621b74d857436/library_erd.png)

- **Database Creation**: Created a database named `sql_project_p2`.
```sql
CREATE DATABASE sql_project_p2;
```

- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
--Creating Branch Table
CREATE TABLE branch 
(
			branch_id VARCHAR(10) PRIMARY KEY,
			manager_id VARCHAR(10),
			branch_address VARCHAR(55),
			contact_number VARCHAR(10)
);


--Creating Employee Table
CREATE TABLE employees 
(
			emp_id VARCHAR(10) PRIMARY KEY,
			emp_name VARCHAR(25),
			position VARCHAR(15),
			salary INT,
			branch_id VARCHAR(25)
);

--Creating Books Table
CREATE TABLE books
(
			isbn VARCHAR(20) PRIMARY KEY, 
			book_title VARCHAR(75), 
			category VARCHAR(10),
			rental_price FLOAT,
			status VARCHAR(15),
			author VARCHAR(35),
			publisher VARCHAR(55)
);

--Creating Members Table
CREATE TABLE members
(
			member_id VARCHAR(10) PRIMARY KEY, 
			member_name	VARCHAR(25),
			member_address VARCHAR(75),	
			reg_date DATE
);

--Creating Issued Status Table
CREATE TABLE issued_status
(
			issued_id VARCHAR(10) PRIMARY KEY,
			issued_member_id VARCHAR(10),	
			issued_book_name VARCHAR(75),
			issued_date	DATE, 
			issued_book_isbn VARCHAR(25), 
			issued_emp_id VARCHAR(10)
);

--Creating Return Status Table
CREATE TABLE return_status
(
			return_id VARCHAR(10) PRIMARY KEY,
			issued_id VARCHAR(10), 
			return_book_name VARCHAR(75), 
			return_date	DATE,
			return_book_isbn VARCHAR(20)
);
```

- **Adding Constraints**: Added Foreign Key Constraints for the required columns.
```sql
--Adding FOREIGN KEY Constraints
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id) REFERENCES members(member_id);

ALTER TABLE issued_status 
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn); 

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id); 

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id) REFERENCES branch(branch_id); 

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id); 
```

### 2. 📝CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT issued_member_id,
	   COUNT (issued_id) AS total_book_issued
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT (issued_id) > 1;
```

### 3. 🗄️CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_counts
AS
SELECT b.isbn,
	   b.book_title,
	   COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2; 

SELECT * FROM book_counts;
 ```


### 4. 📊Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * From books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT b.category,
	   SUM(b.rental_price),
	   COUNT(*)
FROM books AS b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1; 
```

9. **Task 9: List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

10. **Task 10: List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT e1.*,
	   b.manager_id,
	   e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b
ON b.branch_id = e1.branch_id
JOIN employees AS e2
ON b.manager_id = e2.emp_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE books_rental_price_greater_than_eight
AS
SELECT * FROM books
WHERE rental_price > 8.00;

SELECT * FROM books_rental_price_greater_than_eight;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT DISTINCT issued_book_name FROM issued_status as ist
LEFT JOIN return_status AS rs ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NOT NULL;

```

## ⚙️Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
/*Approach: 1. ((issued_status == members)== books) == return_status
		  2. filter out the returned books
		  3. check for overdue > 30 days
*/
SELECT
	   ist.issued_member_id,
       mem.member_name,
       b.book_title,
       ist.issued_date,
       CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status AS ist
JOIN members AS mem ON mem.member_id = ist.issued_member_id
JOIN books AS b ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE 
	rs.return_date IS NULL
	AND
	(CURRENT_DATE - ist.issued_date) > 30
ORDER BY ist;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql
CREATE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all the logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$


-- Testing FUNCTION add_return_records

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135');

-- calling function 
CALL add_return_records('RS148', 'IS140');
```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS number_book_issued,
    COUNT(rs.return_id) AS number_of_book_return,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN 
employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
LEFT JOIN
return_status AS rs ON rs.issued_id = ist.issued_id
JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;
```

**Task 16: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) AS no_book_issued
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
GROUP BY 1, 2;
```

## 📑Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## 🔎Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


## Author - Mayank Ahuja

This project showcases SQL skills essential for database management and analysis. 
