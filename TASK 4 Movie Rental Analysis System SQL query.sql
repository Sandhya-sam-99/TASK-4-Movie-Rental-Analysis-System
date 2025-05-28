-- Create rental_data table
CREATE TABLE rental_data (
    MOVIE_ID INTEGER,
    MOVIE_TITLE VARCHAR(100),
    CUSTOMER_ID INTEGER,
    CUSTOMER_NAME VARCHAR(100),
    GENRE VARCHAR(50),
    RENTAL_DATE DATE,
    RETURN_DATE DATE,
    RENTAL_FEE NUMERIC(5,2),
    PRIMARY KEY (MOVIE_ID, CUSTOMER_ID, RENTAL_DATE)
);

---Insert movie rental data of the year 2023---
INSERT INTO rental_data VALUES
(101, 'The Dark Knight', 1001, 'John Smith', 'Action', '2023-01-15', '2023-01-22', 3.99),
(102, 'Inception', 1002, 'Emma Johnson', 'Sci-Fi', '2023-02-05', '2023-02-12', 3.49),
(103, 'The Shawshank Redemption', 1003, 'Michael Brown', 'Drama', '2023-02-10', '2023-02-17', 2.99),
(104, 'Pulp Fiction', 1001, 'John Smith', 'Crime', '2023-03-01', '2023-03-08', 3.29),
(105, 'The Godfather', 1004, 'Sarah Davis', 'Crime', '2023-03-15', '2023-03-22', 3.99),
(106, 'Interstellar', 1002, 'Emma Johnson', 'Sci-Fi', '2023-04-10', '2023-04-17', 3.49),
(107, 'Fight Club', 1005, 'David Wilson', 'Drama', '2023-04-20', '2023-04-27', 2.99),
(108, 'The Matrix', 1003, 'Michael Brown', 'Action', '2023-05-05', '2023-05-12', 3.99),
(109, 'Parasite', 1006, 'Jennifer Lee', 'Drama', '2023-05-15', '2023-05-22', 3.29),
(110, 'John Wick', 1004, 'Sarah Davis', 'Action', '2023-06-01', '2023-06-08', 3.99),
(111, 'The Social Network', 1007, 'Robert Taylor', 'Drama', '2023-07-10', '2023-07-17', 2.99),
(112, 'Mad Max: Fury Road', 1005, 'David Wilson', 'Action', '2023-08-05', '2023-08-12', 3.99),
(113, 'La La Land', 1008, 'Olivia Martinez', 'Romance', '2023-08-15', '2023-08-22', 3.49),
(114, 'The Avengers', 1006, 'Jennifer Lee', 'Action', '2023-09-10', '2023-09-17', 3.99),
(115, 'Whiplash', 1009, 'James Anderson', 'Drama', '2023-10-01', '2023-10-08', 2.99);

---OLAP Operations---

---Drill Down: Analyze rentals from genre to individual movie level---

-- Starting with the genre summary---
SELECT GENRE, COUNT(*) AS rental_count, SUM(RENTAL_FEE) AS total_fees
FROM rental_data
GROUP BY GENRE
ORDER BY total_fees DESC;

-- Drill down to specific movies in Action genre
SELECT MOVIE_TITLE, COUNT(*) AS rental_count, SUM(RENTAL_FEE) AS total_fees
FROM rental_data
WHERE GENRE = 'Action'
GROUP BY MOVIE_TITLE
ORDER BY total_fees DESC;

---Rollup: Summarize total rental fees by genre and then overall---
SELECT 
    CASE WHEN GROUPING(GENRE) = 1 THEN 'ALL GENRES' ELSE GENRE END AS genre,
    SUM(RENTAL_FEE) AS total_fees
FROM rental_data
GROUP BY ROLLUP(GENRE)
ORDER BY GROUPING(GENRE), total_fees DESC;

---Cube: Analyze total rental fees across combinations of genre, rental date, and customers---
SELECT 
    GENRE,
    DATE_TRUNC('month', RENTAL_DATE) AS rental_month,
    CUSTOMER_NAME,
    SUM(RENTAL_FEE) AS total_fees
FROM rental_data
GROUP BY CUBE(GENRE, DATE_TRUNC('month', RENTAL_DATE), CUSTOMER_NAME)
ORDER BY GENRE, rental_month, CUSTOMER_NAME;

---Slice: Extract rentals only from the ‘Action’ genre---
SELECT MOVIE_TITLE, CUSTOMER_NAME, RENTAL_DATE, RETURN_DATE, RENTAL_FEE
FROM rental_data
WHERE GENRE = 'Action'
ORDER BY RENTAL_DATE DESC;

---Dice: Extract rentals where GENRE = 'Action' or 'Drama' and RENTAL_DATE is in the last 3 months---
SELECT MOVIE_TITLE, GENRE, CUSTOMER_ID, CUSTOMER_NAME, RENTAL_DATE, RENTAL_FEE
FROM rental_data
WHERE GENRE IN ('Action', 'Drama')
  AND RENTAL_DATE >= DATE '2023-10-31' - INTERVAL '3 months'
ORDER BY RENTAL_DATE DESC;
