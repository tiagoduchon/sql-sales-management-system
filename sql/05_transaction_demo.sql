-- OPTIONAL demonstration. Run on the seeded database; it creates an example paid order.
-- This is a manual transactional workflow; stock is NOT automatically maintained by triggers.
-- Ensure the chosen product exists and has sufficient stock before running.
START TRANSACTION;
SET @product_id := 2;
SET @qty := 1;
SET @price := (SELECT unit_price FROM products WHERE product_id=@product_id);
-- Guarded stock decrement: inspect ROW_COUNT() before proceeding in a real application.
UPDATE products SET stock=stock-@qty WHERE product_id=@product_id AND stock>=@qty;
-- IMPORTANT: This script is illustrative; if UPDATE affected 0 rows, ROLLBACK instead of continuing.
INSERT INTO orders(customer_id,order_date,status) VALUES (1,NOW(),'paid');
SET @new_order_id := LAST_INSERT_ID();
INSERT INTO order_items(order_id,product_id,quantity,unit_price)
VALUES(@new_order_id,@product_id,@qty,@price);
INSERT INTO payments(order_id,paid_at,amount,method)
VALUES(@new_order_id,NOW(),@qty*@price,'card');
INSERT INTO inventory_movements(product_id,order_id,movement_type,quantity_change,notes)
VALUES(@product_id,@new_order_id,'sale',-@qty,'Transaction demo');
-- Review changes and COMMIT manually only after checking the guarded update.
SELECT @new_order_id AS new_order_id, @price AS unit_price;
ROLLBACK; -- Safe default: this example does not persist any changes.
