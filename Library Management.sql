CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;

CREATE TABLE members (
    member_id    INT PRIMARY KEY AUTO_INCREMENT,
    full_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(100) UNIQUE,
    phone        VARCHAR(15),
    join_date    DATE NOT NULL
);

CREATE TABLE books (
    book_id          INT PRIMARY KEY AUTO_INCREMENT,
    title            VARCHAR(150) NOT NULL,
    author           VARCHAR(100) NOT NULL,
    category         VARCHAR(50),
    price            DECIMAL(8,2),
    total_copies     INT DEFAULT 1,
    available_copies INT DEFAULT 1
);

CREATE TABLE borrowings (
    borrow_id    INT PRIMARY KEY AUTO_INCREMENT,
    member_id    INT NOT NULL,
    book_id      INT NOT NULL,
    borrow_date  DATE NOT NULL,
    due_date     DATE NOT NULL,
    return_date  DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id)   REFERENCES books(book_id)
);


INSERT INTO members (full_name, email, phone, join_date) VALUES
('Arun Kumar',   'arun@example.com',   '9876543210', '2025-01-10'),
('Priya Sharma', 'priya@example.com',  '9876501234', '2025-02-15'),
('Rahul Verma',  'rahul@example.com',  '9123456780', '2025-03-20'),
('Divya Nair',   'divya@example.com',  '9988776655', '2025-05-05'),
('Karthik Raj',  'karthik@example.com','9090909090', '2025-06-18');

INSERT INTO books (title, author, category, price, total_copies, available_copies) VALUES
('Wings of Fire',          'A.P.J. Abdul Kalam', 'Biography', 350.00, 5, 3),
('The Alchemist',          'Paulo Coelho',       'Fiction',   299.00, 4, 3),
('Python Crash Course',    'Eric Matthes',       'Technology',799.00, 3, 2),
('Atomic Habits',          'James Clear',        'Self-Help', 499.00, 6, 5),
('Clean Code',             'Robert C. Martin',   'Technology',899.00, 2, 1),
('Ponniyin Selvan',        'Kalki Krishnamurthy','Fiction',   650.00, 3, 3);

INSERT INTO borrowings (member_id, book_id, borrow_date, due_date, return_date) VALUES
(1, 1, '2025-09-01', '2025-09-15', '2025-09-12'),
(1, 3, '2025-10-01', '2025-10-15', NULL),
(2, 2, '2025-09-10', '2025-09-24', '2025-09-30'),
(3, 5, '2025-10-05', '2025-10-19', NULL),
(4, 4, '2025-10-10', '2025-10-24', '2025-10-20'),
(5, 1, '2025-10-12', '2025-10-26', NULL);


SELECT * FROM books;

SELECT title, author, price
FROM books
WHERE category = 'Technology';

SELECT title, price
FROM books
WHERE price > 500
ORDER BY price DESC;

-- 4.4 Members who joined in 2025
SELECT full_name, join_date
FROM members
WHERE YEAR(join_date) = 2025;

SELECT m.full_name, b.title, br.borrow_date, br.due_date
FROM borrowings br
JOIN members m ON br.member_id = m.member_id
JOIN books   b ON br.book_id   = b.book_id
ORDER BY br.borrow_date;

SELECT m.full_name, b.title, br.due_date
FROM borrowings br
JOIN members m ON br.member_id = m.member_id
JOIN books   b ON br.book_id   = b.book_id
WHERE br.return_date IS NULL;

SELECT m.full_name
FROM members m
LEFT JOIN borrowings br ON m.member_id = br.member_id
WHERE br.borrow_id IS NULL;

SELECT category, COUNT(*) AS total_titles, SUM(total_copies) AS total_copies
FROM books
GROUP BY category;

SELECT b.title, COUNT(br.borrow_id) AS times_borrowed
FROM books b
JOIN borrowings br ON b.book_id = br.book_id
GROUP BY b.title
ORDER BY times_borrowed DESC;

SELECT m.full_name, COUNT(br.borrow_id) AS books_borrowed
FROM members m
LEFT JOIN borrowings br ON m.member_id = br.member_id
GROUP BY m.full_name
ORDER BY books_borrowed DESC;

SELECT ROUND(AVG(price), 2) AS avg_price FROM books;


SELECT m.full_name,
       b.title,
       br.due_date,
       br.return_date,
       DATEDIFF(br.return_date, br.due_date)       AS days_late,
       DATEDIFF(br.return_date, br.due_date) * 5   AS fine_amount
FROM borrowings br
JOIN members m ON br.member_id = m.member_id
JOIN books   b ON br.book_id   = b.book_id
WHERE br.return_date > br.due_date;

SELECT title, price
FROM books
WHERE price > (SELECT AVG(price) FROM books);



CREATE VIEW pending_returns AS
SELECT m.full_name, m.phone, b.title, br.due_date
FROM borrowings br
JOIN members m ON br.member_id = m.member_id
JOIN books   b ON br.book_id   = b.book_id
WHERE br.return_date IS NULL;

SELECT * FROM pending_returns;


UPDATE borrowings
SET return_date = '2025-10-25'
WHERE borrow_id = 6;

UPDATE books
SET available_copies = available_copies + 1
WHERE book_id = 1;

DELIMITER //

CREATE PROCEDURE borrow_book(
    IN p_member_id INT,
    IN p_book_id   INT
)
BEGIN
    IF (SELECT available_copies FROM books WHERE book_id = p_book_id) > 0 THEN
        INSERT INTO borrowings (member_id, book_id, borrow_date, due_date)
        VALUES (p_member_id, p_book_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));

        UPDATE books
        SET available_copies = available_copies - 1
        WHERE book_id = p_book_id;

        SELECT 'Book issued successfully' AS message;
    ELSE
        SELECT 'Sorry, no copies available' AS message;
    END IF;
END //

DELIMITER ;
