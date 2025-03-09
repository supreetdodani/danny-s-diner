--duplicate orders on the same day 
SELECT 
	a.customer_id, m.product_name, a.order_date, COUNT(a.product_id) FROM sales a
	JOIN menu m
ON m.product_id = a.product_id 
GROUP BY a.customer_id, m.product_name, a.order_date
HAVING COUNT(a.product_id) > 1;

--duplicate orders on diff days 
SELECT a.customer_id, m.product_name, COUNT(DISTINCT a.order_date) FROM sales a
JOIN menu m
ON m.product_id = a.product_id 
GROUP BY a.customer_id, m.product_name
HAVING COUNT(DISTINCT a.order_date)>1
ORDER BY a.customer_id;

--consecutive purchases of the same order 
SELECT a.customer_id, m.product_name, b.order_date AS first_purchase, MIN(a.order_date) as Second_purchase
FROM sales a
JOIN menu m
ON m.product_id = a.product_id 
JOIN sales b 
ON a.customer_id = b.customer_id 
AND a.product_id = b.product_id 
AND a.order_date > b.order_date 
GROUP BY a.customer_id, m.product_name, b.order_date
ORDER BY a.customer_id, b.order_date;

--spending pattern
WITH daily_spends AS (SELECT s.customer_id, s.order_date, SUM(m.price) AS total_spent FROM sales s 
                      JOIN menu m ON m.product_id = s.product_id
                     GROUP BY s.customer_id, s.order_date) 
      SELECT DISTINCT 
            a.customer_id, 
            a.total_spent AS previous_order_cost,
            b.total_spent AS next_order_cost 
      FROM daily_spends a
      	JOIN daily_spends b ON a.customer_id = b.customer_id  
        AND a.order_date < b.order_date
        AND a.total_spent < b.total_spent
        ;   

--first and last order for each customer 
SELECT customer_id, MIN(order_date) AS first_order, MAX(order_date) AS last_order
FROM sales 
GROUP BY customer_id
ORDER BY customer_id;

--total amount each customer spent at the restaurant 
SELECT s.customer_id, SUM(m.price) FROM sales s
	JOIN menu m 
    	ON m.product_id = s.product_id 
    GROUP BY s.customer_id
    ORDER BY customer_id;

--number of days a customer visited the restaurant (assuming every person who came in ordered) 
SELECT 
	customer_id, 
	COUNT(DISTINCT order_date) AS num_visits 
FROM sales 
GROUP BY customer_id;

--first item from the menu purchased by each customer 
SELECT customer_id, STRING_AGG(sales.product_id :: TEXT, ' , ') AS items_id,
STRING_AGG(m.product_name, ' , ') AS items_name
FROM sales 
JOIN menu m 
ON m.product_id = sales.product_id
WHERE order_date IN (SELECT MIN(order_date) FROM sales s
                     WHERE s.customer_id = sales.customer_id
                   		)
        GROUP BY customer_id;

--most purchased item on the menu and how many times was it purchased by all customers
WITH product_counts AS (
    SELECT product_id, COUNT(*) AS total_orders
    FROM sales
    GROUP BY product_id
)
SELECT p.product_id, m.product_name, p.total_orders
FROM product_counts p
JOIN menu m ON p.product_id = m.product_id
WHERE p.total_orders = (SELECT MAX(total_orders) FROM product_counts);

--most purchased item and how many times it was purchased by diff customers 
WITH most_purchased AS (
    SELECT product_id
    FROM sales
    GROUP BY product_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
SELECT s.customer_id, s.product_id, m.product_name, COUNT(*) AS customer_order_count, SUM(m.price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN most_purchased mp ON s.product_id = mp.product_id
GROUP BY s.customer_id, s.product_id, m.product_name
ORDER BY s.customer_id;


--most popular item for each customer 
WITH ranked_items AS (
  SELECT s.customer_id, s.product_id, COUNT(*) AS order_count,
          RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rnk 
                      FROM sales s
                      GROUP BY s.customer_id, s.product_id)
              SELECT 
              r.customer_id, m.product_name 
              FROM ranked_items r 
              JOIN menu m 
              ON r.product_id = m.product_id 
              WHERE r.rnk = 1
              ORDER BY customer_id;
              
                       
--first item purchased after becoming a member 
SELECT s.customer_id, me.product_name, s.order_date FROM sales s
JOIN menu me 
ON me.product_id = s.product_id
JOIN members m 
ON m.customer_id = s.customer_id 
WHERE 
 s.order_date IN (SELECT MIN(a.order_date) FROM sales a 
                     WHERE a.customer_id = s.customer_id
                 AND a.order_date > m.join_date)
         ;
        
 --item purchased before becoming a member 
 WITH orders AS (
   SELECT s.product_id, s.customer_id, s.order_date, m.product_name 
   FROM sales s
   JOIN menu m 
   ON s.product_id = m.product_id 
	JOIN members me
   ON me.customer_id = s.customer_id
   AND me.join_date > s.order_date)
 SELECT
 o.customer_id, o.order_date, o.product_name 
 FROM orders o 
 ORDER BY o.customer_id, o.order_date DESC;
 
 -- items purchased just before becoming a member
 SELECT s.customer_id AS customer, m.product_name AS dish
FROM menu m
JOIN sales s ON s.product_id = m.product_id 
JOIN members mb ON mb.customer_id = s.customer_id 
WHERE s.order_date = (
    SELECT MAX(b.order_date) 
    FROM sales b
    WHERE b.customer_id = s.customer_id 
    AND b.order_date < mb.join_date  
)
ORDER BY customer;

--total items and total amount spent before becoming a member 
SELECT DISTINCT s.customer_id, COUNT(s.product_id) AS total_items, SUM(m.price) AS total_price 
FROM sales s
JOIN menu m 
ON m.product_id = s.product_id 
JOIN members mb 
ON s.customer_id = mb.customer_id 
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, 
SUM(CASE WHEN s.product_id IN (2,3) THEN m.price*10
      ELSE m.price*20
END) AS points
FROM sales s
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id, 
SUM(CASE WHEN s.order_date = mb.join_date + INTERVAL '7Days' 
        				THEN m.price*2*10 
    	ELSE m.price*10 
      END) 
      		AS total_points
            FROM sales s
JOIN members mb ON mb.customer_id = s.customer_id 
JOIN menu m ON m.product_id = s.product_id
GROUP BY s.customer_id;