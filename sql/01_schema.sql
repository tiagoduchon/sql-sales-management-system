-- MySQL 8.0+ | Run inside a selected empty database in DBeaver.
-- Destructive reset of project tables (only in the selected database).
DROP VIEW IF EXISTS v_monthly_sales;
DROP VIEW IF EXISTS v_order_summary;
DROP VIEW IF EXISTS v_product_inventory;
DROP TABLE IF EXISTS inventory_movements;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
 customer_id INT AUTO_INCREMENT PRIMARY KEY,
 first_name VARCHAR(80) NOT NULL,
 last_name VARCHAR(80) NOT NULL,
 email VARCHAR(180) NOT NULL UNIQUE,
 city VARCHAR(100) NOT NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE categories (
 category_id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;
CREATE TABLE products (
 product_id INT AUTO_INCREMENT PRIMARY KEY,
 category_id INT NOT NULL,
 sku VARCHAR(40) NOT NULL UNIQUE,
 name VARCHAR(150) NOT NULL,
 unit_price DECIMAL(12,2) NOT NULL,
 stock INT NOT NULL DEFAULT 0,
 active BOOLEAN NOT NULL DEFAULT TRUE,
 CONSTRAINT ck_product_price CHECK (unit_price >= 0),
 CONSTRAINT ck_product_stock CHECK (stock >= 0),
 CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
) ENGINE=InnoDB;
CREATE TABLE orders (
 order_id INT AUTO_INCREMENT PRIMARY KEY,
 customer_id INT NOT NULL,
 order_date DATETIME NOT NULL,
 status ENUM('pending','paid','cancelled') NOT NULL DEFAULT 'pending',
 CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
 INDEX idx_order_date (order_date),
 INDEX idx_order_customer_status (customer_id,status)
) ENGINE=InnoDB;
CREATE TABLE order_items (
 order_id INT NOT NULL,
 product_id INT NOT NULL,
 quantity INT NOT NULL,
 unit_price DECIMAL(12,2) NOT NULL,
 PRIMARY KEY(order_id,product_id),
 CONSTRAINT ck_item_quantity CHECK (quantity > 0),
 CONSTRAINT ck_item_price CHECK (unit_price >= 0),
 CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
 CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;
CREATE TABLE payments (
 payment_id INT AUTO_INCREMENT PRIMARY KEY,
 order_id INT NOT NULL,
 paid_at DATETIME NOT NULL,
 amount DECIMAL(12,2) NOT NULL,
 method ENUM('card','transfer','cash') NOT NULL,
 CONSTRAINT ck_payment_amount CHECK (amount > 0),
 CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
 INDEX idx_payment_order (order_id)
) ENGINE=InnoDB;
CREATE TABLE inventory_movements (
 movement_id INT AUTO_INCREMENT PRIMARY KEY,
 product_id INT NOT NULL,
 order_id INT NULL,
 movement_type ENUM('purchase','sale','adjustment') NOT NULL,
 quantity_change INT NOT NULL,
 moved_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 notes VARCHAR(255),
 CONSTRAINT ck_movement_nonzero CHECK (quantity_change <> 0),
 CONSTRAINT fk_movement_product FOREIGN KEY (product_id) REFERENCES products(product_id),
 CONSTRAINT fk_movement_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB;
