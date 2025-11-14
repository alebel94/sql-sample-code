/* Q1 Recent rentals with customer & film
List the 20 most recent rentals along with:
customer’s first and last name
film title
rental date
Order by most recent rental first.
*/

WITH recent_rentals AS (
    SELECT
        rental_id,
        customer_id,
        inventory_id,
        rental_date
    FROM rental
    ORDER BY rental_date DESC
    LIMIT 20
)
SELECT
    c.first_name,
    c.last_name,
    f.title,
    r.rental_date
FROM customer c
JOIN recent_rentals r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
ORDER BY rental_date DESC

-- Concepts: simple join, ORDER BY, LIMIT
;

/* Q2 Films rented by one customer
Show all films MAURENN LITTLE (Assume only one exists) has rented, including:
film title
rental date
return date
Sort by rental date.
*/

SELECT 
    f.title,
    r.rental_date,
    r.return_date
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE c.first_name = 'MAUREEN' AND c.last_name = 'LITTLE'
ORDER BY rental_date

-- Concepts: join, WHERE filter
;

/* Q3 Revenue by film category
For each film category, find:
total revenue
number of payments
Order by total revenue descending.
*/

SELECT 
    cat.name AS film_category,
    SUM(p.amount) AS total_revenue,
    COUNT(p.payment_id) AS number_of_payments
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
GROUP BY cat.name
ORDER BY total_revenue DESC

-- Note: used JOINs as all categories should have some revenue (verified with left joins)    
-- Concepts: multi-join, GROUP BY, SUM
;

/*
Q4 Store performance (rentals)
For each store, find:
number of rentals
number of distinct customers who rented there
Order by store id.
*/

SELECT 
    s.store_id,
    COUNT(r.rental_id) AS number_of_rentals,
    COUNT(DISTINCT c.customer_id) AS distinct_customers
FROM store s
LEFT JOIN customer c ON s.store_id = c.store_id
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY s.store_id
ORDER BY s.store_id

-- Note: LEFT JOIN to include stores with zero rentals
-- Concepts: multi-join, GROUP BY, COUNT DISTINCT
;

/* Q5 Top 15 customers by total spend
Find the top 15 customers by total amount spent.
Show:
customer id
full name
total amount paid
Sort by total spent, descending.
*/

SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    SUM(p.amount) AS total_amount_paid
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, full_name
ORDER BY total_amount_paid DESC
LIMIT 15

-- Note: limit happens after aggregation; no CTE needed
-- Concepts: GROUP BY, aggregation


/* Q6 High-value customers
Find customers whose total payments exceed a $150 threshold.
Show:
customer id
full name
total amount paid
Order by total amount paid descending.
*/

SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    SUM(p.amount) AS total_amount_paid
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, full_name
HAVING SUM(p.amount) > 150
ORDER BY total_amount_paid DESC
-- Concepts: GROUP BY, HAVING
;

/* Q7 Top 5 films by total revenue
Using a CTE, compute total revenue per film, then return the top 5 films by revenue.
Show:
film id
title
total revenue
*/

WITH films_by_rev AS(
    SELECT f.film_id,
        f.title,
        SUM(p.amount) AS total_revenue
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY f.film_id, f.title
)
SELECT film_id,
    title,
    total_revenue
FROM films_by_rev
ORDER BY total_revenue DESC
LIMIT 5
-- Concepts: CTE, aggregation, multi-join
;

/* Q8 Monthly revenue
Show monthly revenue:
month of payment (e.g. 2022-01-01 style)
total revenue for that month
number of payments
Order chronologically.
*/

SELECT 
    DATE_TRUNC('month', payment_date) AS payment_month,
    SUM(amount) AS total_monthly_revenue,
    COUNT(payment_id) AS number_of_payments
FROM payment
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY payment_month
-- Concepts: DATE_TRUNC, GROUP BY, aggregation
;

/* Q9 Rank customers by revenue (per store)
For each store, rank customers by total amount spent using a window function.
Return:
store id
customer id
customer name
total amount spent
rank within that store
Order by store id, then rank.
*/

WITH customer_rev_per_store AS (
SELECT 
    s.store_id,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(p.amount) AS total_amount_spent
FROM store s
JOIN customer c ON s.store_id = c.store_id
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY s.store_id, c.customer_id, customer_name
)
SELECT 
    store_id,
    customer_id,
    customer_name,
    total_amount_spent,
    RANK() OVER (PARTITION BY store_id ORDER BY total_amount_spent DESC) AS customer_rank_by_store
FROM customer_rev_per_store
ORDER BY store_id, customer_name, customer_rank_by_store
LIMIT 20

-- Concepts: GROUP BY, window function (RANK() OVER (PARTITION BY ...))
;

/*
Q10 Running total of daily revenue
Compute daily revenue and a running total over time.
Return:
day (date)
daily revenue
cumulative revenue up to that day
Order by day.
*/

SELECT 
    CAST (payment_date AS DATE) AS payment_day,
    SUM(amount) AS daily_revenue,
    SUM(SUM(amount)) OVER (ORDER BY CAST (payment_date AS DATE)) AS running_sum_revenue
FROM payment
GROUP BY CAST (payment_date AS DATE)
ORDER BY payment_day
LIMIT 20
-- Concepts: window function (SUM(...) OVER (ORDER BY ...)), date casting / truncation
;