-- Fictional sample data; run after 01_schema.sql.
INSERT INTO categories (category_id,name) VALUES
(1,'Computers'),(2,'Accessories'),(3,'Networking');
INSERT INTO customers (customer_id,first_name,last_name,email,city,created_at) VALUES
(1,'Lucia','Gomez','lucia@example.test','Santa Fe','2026-01-10'),
(2,'Mateo','Ruiz','mateo@example.test','Rosario','2026-01-12'),
(3,'Sofia','Perez','sofia@example.test','Cordoba','2026-02-01'),
(4,'Nicolas','Diaz','nicolas@example.test','Santa Fe','2026-02-14'),
(5,'Valentina','Lopez','valentina@example.test','Parana','2026-03-01'),
(6,'Tomas','Fernandez','tomas@example.test','Rosario','2026-03-08');
INSERT INTO products (product_id,category_id,sku,name,unit_price,stock,active) VALUES
(1,1,'LAP-001','Laptop 14 inch',850000,12,1),
(2,2,'MOU-001','Wireless mouse',22000,40,1),
(3,2,'KEY-001','Mechanical keyboard',68000,18,1),
(4,3,'ROU-001','Wi-Fi router',95000,9,1),
(5,2,'MON-001','24 inch monitor',210000,14,1),
(6,3,'CAB-001','Ethernet cable',8500,80,1),
(7,2,'HUB-001','USB-C hub',45000,5,1),
(8,1,'LAP-002','Laptop 15 inch',1100000,4,1);
INSERT INTO orders (order_id,customer_id,order_date,status) VALUES
(1,1,'2026-01-15 10:30:00','paid'),(2,2,'2026-01-20 14:00:00','paid'),
(3,1,'2026-02-03 09:15:00','paid'),(4,3,'2026-02-18 11:00:00','paid'),
(5,4,'2026-03-05 16:00:00','paid'),(6,5,'2026-03-10 12:30:00','cancelled'),
(7,2,'2026-04-02 10:00:00','paid'),(8,6,'2026-04-15 17:45:00','pending'),
(9,3,'2026-05-08 08:40:00','paid'),(10,4,'2026-05-20 13:20:00','paid'),
(11,5,'2026-06-07 10:10:00','paid'),(12,1,'2026-06-21 15:00:00','pending');
INSERT INTO order_items (order_id,product_id,quantity,unit_price) VALUES
(1,1,1,850000),(1,2,2,22000),
(2,3,1,68000),(2,4,1,95000),
(3,5,1,210000),(3,6,3,8500),
(4,2,1,22000),(4,7,1,45000),
(5,8,1,1100000),(5,2,1,22000),
(6,1,1,850000),
(7,4,2,95000),(7,6,2,8500),
(8,3,1,68000),
(9,5,2,210000),
(10,7,2,45000),(10,6,4,8500),
(11,2,3,22000),(11,3,1,68000),
(12,8,1,1100000);
-- Payments exactly cover paid orders; pending/cancelled orders have none.
INSERT INTO payments (order_id,paid_at,amount,method) VALUES
(1,'2026-01-15 10:35:00',894000,'card'),
(2,'2026-01-20 14:10:00',163000,'transfer'),
(3,'2026-02-03 09:20:00',235500,'card'),
(4,'2026-02-18 11:05:00',67000,'cash'),
(5,'2026-03-05 16:10:00',1122000,'transfer'),
(7,'2026-04-02 10:10:00',207000,'card'),
(9,'2026-05-08 08:45:00',420000,'transfer'),
(10,'2026-05-20 13:25:00',124000,'cash'),
(11,'2026-06-07 10:15:00',134000,'card');
-- Historical sale movements for PAID orders only. Stock is a current snapshot.
INSERT INTO inventory_movements(product_id,order_id,movement_type,quantity_change,notes)
SELECT oi.product_id, oi.order_id, 'sale', -oi.quantity, 'Sample historical sale'
FROM order_items oi JOIN orders o ON o.order_id=oi.order_id WHERE o.status='paid';
