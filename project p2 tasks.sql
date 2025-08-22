--Project P2 Tasks
--CRUD Operations 

--Task 1. Create a New Book Record -- '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

--Task 2: Update an Existing Member's Address.
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

--Task 3: Delete a Record from the Issued Status Table. 
--Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee.
--Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

--Task 5: List Members Who Have Issued More Than One Books.
--Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_member_id,
	   COUNT (issued_id) AS total_book_issued
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT (issued_id) > 1;

--CTAS
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
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
 
--Data Anakysis and Findings.
--Task 7: Retrieve All Books in a Specific Category.
SELECT * From books
WHERE category = 'Classic';

--Task 8: Find Total Rental Income by Category.
SELECT b.category,
	   SUM(b.rental_price),
	   COUNT(*)
FROM books AS b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1; 

--Task 9: List Members who Registered in the Last 180 Days.
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

--Task 10: List Employees with Their Branch Manager's Name and their branch details.
SELECT e1.*,
	   b.manager_id,
	   e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b
ON b.branch_id = e1.branch_id
JOIN employees AS e2
ON b.manager_id = e2.emp_id;

--Task 11: Create a Table of Books with Rental Price Above a Certain Threshold.
CREATE TABLE books_rental_price_greater_than_eight
AS
SELECT * FROM books
WHERE rental_price > 8.00;

SELECT * FROM books_rental_price_greater_than_eight;

--Task 12: Retrieve the List of Books Not Yet Returned.
SELECT DISTINCT issued_book_name FROM issued_status as ist
LEFT JOIN return_status AS rs ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NOT NULL;

--Advanced SQL Problems
/*
Task 13: Identify Members with Overdue Books.
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
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

/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
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


/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/
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

/*Task 16: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
*/
SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) AS no_book_issued
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
GROUP BY 1, 2;

