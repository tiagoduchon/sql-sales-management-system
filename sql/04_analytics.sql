-- Portfolio queries: MySQL 8.0+, run after views.
-- 1. Revenue by month (paid orders only).
SELECT * FROM v_monthly_sales ORDER BY sales_month;

-- 2. Top five products by paid revenue.
SELECT p.sku,p.name,SUM(oi.quantity) AS units_sold,
 SUM(oi.quantity*oi.unit_price) AS revenue
FROM order_items oi JOIN orders o ON o.order_id=oi.order_id
JOIN products p ON p.product_id=oi.product_id
WHERE o.status='paid'
GROUP BY p.product_id,p.sku,p.name
ORDER BY revenue DESC LIMIT 5;

-- 3. Customer lifetime value (paid orders only, including customers with no purchases).
SELECT c.customer_id,CONCAT(c.first_name,' ',c.last_name) AS customer,
 COALESCE(SUM(CASE WHEN o.status='paid' THEN oi.quantity*oi.unit_price ELSE 0 END),0) AS lifetime_value
FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
LEFT JOIN order_items oi ON oi.order_id=o.order_id
GROUP BY c.customer_id,c.first_name,c.last_name
ORDER BY lifetime_value DESC;

-- 4. Low stock inventory.
SELECT * FROM v_product_inventory WHERE stock_status='LOW' ORDER BY stock;

-- 5. Customers who have never placed a paid order.
SELECT c.customer_id,c.first_name,c.last_name
FROM customers c WHERE NOT EXISTS (
 SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id AND o.status='paid'
);

-- 6. Order payment reconciliation (paid orders must be fully paid).
SELECT order_id,order_total,amount_paid,(order_total-amount_paid) AS outstanding
FROM v_order_summary WHERE status='paid' AND ABS(order_total-amount_paid)>0.005;

-- 7. Rank customers by revenue using a window function.
WITH customer_sales AS (
 SELECT c.customer_id,CONCAT(c.first_name,' ',c.last_name) AS customer,
 SUM(oi.quantity*oi.unit_price) AS revenue
 FROM customers c JOIN orders o ON o.customer_id=c.customer_id AND o.status='paid'
 JOIN order_items oi ON oi.order_id=o.order_id
 GROUP BY c.customer_id,c.first_name,c.last_name
)
SELECT customer,revenue,DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM customer_sales ORDER BY revenue_rank;

-- 8. Revenue by category.
SELECT c.name AS category,SUM(oi.quantity*oi.unit_price) AS revenue
FROM categories c JOIN products p ON p.category_id=c.category_id
JOIN order_items oi ON oi.product_id=p.product_id
JOIN orders o ON o.order_id=oi.order_id AND o.status='paid'
GROUP BY c.category_id,c.name ORDER BY revenue DESC;

-- 9. Average order value.
SELECT ROUND(AVG(order_total),2) AS average_paid_order_value
FROM v_order_summary WHERE status='paid';

-- 10. Payment method share, based on payment amounts.
SELECT method,COUNT(*) AS payment_count,SUM(amount) AS amount,
 ROUND(100*SUM(amount)/(SELECT SUM(amount) FROM payments),2) AS pct_amount
FROM payments GROUP BY method ORDER BY amount DESC;
