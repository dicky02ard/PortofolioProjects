-- 1. How many users/customers are listed in the application

SELECT COUNT(distinct customer_unique_id) as "Total of Customer" FROM olist_customers_dataset;
-- The total of customers is 96096

-- 2. The percentage of growth over the years

SELECT 
	year,
    total_customers,
	CONCAT(ROUND((total_customers - LAG(total_customers) OVER (ORDER BY year ASC))/LAG (total_customers) OVER (ORDER BY year ASC)*100,2), '%') AS percentage_growth
FROM (
	SELECT YEAR(order_purchase_timestamp) as year,
		COUNT(distinct oc.customer_unique_id) as total_customers
	FROM olist_customers_dataset oc
     JOIN olist_orders_dataset oo ON oo.customer_id = oc.customer_id
	GROUP BY Year
) as growth;
-- The largest growth in the number of customers occurred in 2017 which was 13308.90%

-- 3. On which state should they build the warehouse?

SELECT c.customer_state as Warehouse_state,
		COUNT(order_id) as Total_orders
FROM olist_customers_dataset c
	JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY Total_orders DESC
limit 1;
-- SP state has the highest total of orders

-- 4. can you help them determine the second highest selling product?

-- Top selling product category by total volume
SELECT p.product_category_name as Product_category,
		COUNT(order_id) as Total_orders
FROM olist_products_dataset p
	 JOIN olist_order_items_dataset oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY Total_orders DESC
LIMIT 2;
-- 'beleza_saude' is the second highest selling product

-- 5. how many products arrived late (exceeding the delivery estimated date)

SELECT COUNT(order_id) AS Product_arrived_late
FROM olist_orders_dataset 
WHERE order_delivered_customer_date > order_estimated_delivery_date;
-- As many as 7827 products have arrived late

-- 6. the percentage of orders that are delivered on time in accordance to the estimated date.

SELECT 
	ontime,
    late,
	CONCAT(100 - ROUND(late/ontime*100,2), '%') AS Percentage_of_ontime_order
FROM (
	SELECT COUNT(order_id) AS late
    FROM olist_orders_dataset 
	WHERE order_delivered_customer_date > order_estimated_delivery_date
) AS late_delivered_order,
(
	SELECT COUNT(order_id) AS ontime
	FROM olist_orders_dataset 
	WHERE order_delivered_customer_date < order_estimated_delivery_date
) AS ontime_order;
-- The percentage of ontime orders is 91,46%

-- 7. Whether the late delivery affects the star rating given on that late product.

WITH ontime AS (
	SELECT COUNT(o.order_id) AS "ontime/late_delivery",
			ROUND(AVG(review_score),1) AS "ontime/late_score"
	FROM olist_orders_dataset AS o
		JOIN olist_order_reviews_dataset ro ON o.order_id = ro.order_id
	WHERE order_delivered_customer_date < order_estimated_delivery_date
),
late AS(
	SELECT COUNT(o.order_id) AS late_delivery,
			ROUND(AVG(review_score),1)
    FROM olist_orders_dataset o
		JOIN olist_order_reviews_dataset ro ON ro.order_id = o.order_id
	WHERE order_delivered_customer_date > order_estimated_delivery_date
)
SELECT * from ontime
UNION
SELECT * from late
-- The number of orders that can be reviewed from customers is 48,544 orders.
-- A total of 44757 orders arrived on time and 3787 orders arrived late to customers.
-- Orders that arrive on time get an average rating score 4.2 and orders that arrive late get an average rating score 2.5.
-- And the conclusion is, the orders that arrive late have greatly affect the rating score of customers.




