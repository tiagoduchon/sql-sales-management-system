-- Reporting views: exclude cancelled and pending orders from recognized sales.
CREATE OR REPLACE VIEW v_order_summary AS
SELECT o.order_id, o.order_date, o.status,
 CONCAT(c.first_name,' ',c.last_name) AS customer,
 c.city,
 SUM(oi.quantity * oi.unit_price) AS order_total,
 COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.order_id=o.order_id),0) AS amount_paid
FROM orders o JOIN customers c ON c.customer_id=o.customer_id
JOIN order_items oi ON oi.order_id=o.order_id
GROUP BY o.order_id,o.order_date,o.status,c.first_name,c.last_name,c.city;

CREATE OR REPLACE VIEW v_monthly_sales AS
SELECT DATE_FORMAT(order_date,'%Y-%m') AS sales_month,
 COUNT(*) AS paid_orders,
 SUM(order_total) AS revenue
FROM v_order_summary WHERE status='paid'
GROUP BY DATE_FORMAT(order_date,'%Y-%m');

CREATE OR REPLACE VIEW v_product_inventory AS
SELECT p.product_id,p.sku,p.name,c.name AS category,p.stock,p.unit_price,
 CASE WHEN p.stock < 10 THEN 'LOW' ELSE 'OK' END AS stock_status
FROM products p JOIN categories c ON c.category_id=p.category_id;
