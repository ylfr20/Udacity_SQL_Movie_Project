/*Query 1: codes to answer Question 1 from Problem Set 1*/
/*Note: this query returns 350 results instead of 361, as some movies that are never rented out is omitted from the results*/
WITH t1 AS (
    SELECT
        f.film_id,
        i.inventory_id,
        COUNT(*) AS rental_count_inv
    FROM
        film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY
        1,
        2),
t2 AS (
    SELECT
        t1.film_id,
        SUM(t1.rental_count_inv) AS rental_count
    FROM
        t1
    GROUP BY
        1
)
SELECT
    f.title film_title,
    c.name category,
    t2.rental_count
FROM
    t2
    JOIN film f ON t2.film_id = f.film_id
    JOIN film_category ON f.film_id = film_category.film_id
    JOIN category c ON film_category.category_id = c.category_id
WHERE
    c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY
    2,
    1;

/*Query 2: codes to answer Question 1 from Problem Set 2*/
WITH t1 AS (
    SELECT
        DATE_PART('month', r.rental_date) rental_month,
        DATE_PART('year', r.rental_date) rental_year,
        COUNT(*) count_rentals,
        r.staff_id
    FROM
        rental r
    GROUP BY
        1,
        2,
        4
)
SELECT
    st.store_id,
    t1.rental_month,
    t1.rental_year,
    SUM(t1.count_rentals) sum_rentals
FROM
    t1
    JOIN staff s ON t1.staff_id = s.staff_id
    JOIN store st ON s.staff_id = st.manager_staff_id
GROUP BY
    1,
    2,
    3
ORDER BY
    4 DESC;


/*Query 3: codes to answer Question 2 from Problem Set 2*/
WITH t1 AS (
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) fullname,
        SUM(p.amount) sum_payment,
        c.customer_id
    FROM
        customer c
        JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY
        1,
        3
    ORDER BY
        sum_payment DESC
    LIMIT 10),
t2 AS (
    SELECT
        DATE_TRUNC('month', p.payment_date) pay_mon,
        t1.fullname,
        COUNT(*) AS pay_countpermon,
        p.amount pay_amtperrent
    FROM
        payment p
        JOIN t1 ON p.customer_id = t1.customer_id
    GROUP BY
        1,
        2,
        4
    ORDER BY
        2,
        1
)
SELECT
    t2.pay_mon,
    t1.fullname,
    SUM(t2.pay_countpermon) sum_count,
SUM(t2.pay_countpermon * t2.pay_amtperrent) sum_payment
FROM
    t1
    JOIN t2 ON t1.fullname = t2.fullname
GROUP BY
    1,
    2
ORDER BY
    2,
    1;


/*Query 4: codes to answer Question 3 from Problem Set 2*/
/*Note: this query is built on the previous one. The deviation of adjacent customer names is deleted manually from the result table. For exmaple, the calculated difference between the payment of Ana Bradley in May and Clara Shaw in Feb does not make sense*/
WITH t1 AS (
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) fullname,
        SUM(p.amount) sum_payment,
        c.customer_id
    FROM
        customer c
        JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY
        1,
        3
    ORDER BY
        sum_payment DESC
    LIMIT 10),
t2 AS (
    SELECT
        DATE_TRUNC('month', p.payment_date) pay_mon,
        t1.fullname,
        COUNT(*) AS pay_countpermon,
        p.amount pay_amtperrent
    FROM
        payment p
        JOIN t1 ON p.customer_id = t1.customer_id
    GROUP BY
        1,
        2,
        4
    ORDER BY
        2,
        1),
t3 AS (
    SELECT
        t2.pay_mon,
        t1.fullname,
        SUM(t2.pay_countpermon) sum_count,
        SUM(t2.pay_countpermon * t2.pay_amtperrent) sum_payment
    FROM
        t1
        JOIN t2 ON t1.fullname = t2.fullname
    GROUP BY
        1,
        2
    ORDER BY
        2,
        1
)
SELECT
    pay_mon,
    fullname,
    sum_payment,
    LAG(sum_payment)
OVER (
ORDER BY
    fullname) AS lag,
sum_payment - LAG(sum_payment)
OVER (
ORDER BY
    fullname) AS lag_difference
FROM
    t3
GROUP BY
    1,
    2,
    3
ORDER BY
    2,
    1;
