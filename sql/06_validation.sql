-- Expected after running 01, 02, 03 (without modifying sample data).
SELECT (SELECT COUNT(*) FROM customers) AS customers_expected_6,
 (SELECT COUNT(*) FROM products) AS products_expected_8,
 (SELECT COUNT(*) FROM orders) AS orders_expected_12,
 (SELECT COUNT(*) FROM payments) AS payments_expected_9;
-- Expected: no rows (payment reconciliation).
SELECT * FROM v_order_summary WHERE status='paid' AND ABS(order_total-amount_paid)>0.005;
-- Expected total revenue: 3,366,500.00
SELECT SUM(order_total) AS paid_revenue FROM v_order_summary WHERE status='paid';
-- Expected: 9 paid, 2 pending, 1 cancelled.
SELECT status,COUNT(*) AS order_count FROM orders GROUP BY status;
-- Check no negative stock and no nonpositive quantities.
SELECT * FROM products WHERE stock<0;
SELECT * FROM order_items WHERE quantity<=0;
