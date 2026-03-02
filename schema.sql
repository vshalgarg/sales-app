CREATE TABLE transports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gst_no VARCHAR(50),
    contact_number VARCHAR(20) NOT NULL,
    city VARCHAR(100),
    address VARCHAR(255) NOT NULL,
    status TINYINT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL
            DEFAULT CURRENT_TIMESTAMP
            ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_transports_name UNIQUE (name),
    CONSTRAINT uk_transports_contact_number UNIQUE (contact_number),
    CONSTRAINT uk_transports_gst_no UNIQUE (gst_no),

    INDEX idx_transports_name (name),
        INDEX idx_transports_city (city),
        INDEX idx_transports_status (status),
        INDEX idx_transports_created_at (created_at)
);


CREATE TABLE transport_contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,

    contact_person VARCHAR(100),
    contact_number VARCHAR(15) NOT NULL,
    type VARCHAR(50) NULL,
    transport_id INT NOT NULL,

    CONSTRAINT fk_transport_contacts_transport
        FOREIGN KEY (transport_id)
        REFERENCES transports(id)
        ON DELETE CASCADE,
    CONSTRAINT uk_tc_transport_contact
            UNIQUE (transport_id, contact_number)
        INDEX idx_tc_transport_id (transport_id)
);



CREATE TABLE IF NOT EXISTS supplier (
    id INT AUTO_INCREMENT PRIMARY KEY,

    code VARCHAR(5) NOT NULL,
    name VARCHAR(50) NOT NULL,

    group_name VARCHAR(50),

    gst_no VARCHAR(15) NULL,

    commission_scheme VARCHAR(20),
    commission_rate DECIMAL(10,2),

    address_line1 VARCHAR(120),
    address_line2 VARCHAR(120),

    city VARCHAR(25),
    pin_code VARCHAR(8),
    msme VARCHAR(8),

    remark VARCHAR(150),

    status TINYINT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- UNIQUE CONSTRAINTS
    CONSTRAINT uk_supplier_code UNIQUE (code),
    CONSTRAINT uk_supplier_gst UNIQUE (gst_no),

    -- INDEXES
    INDEX idx_supplier_name (name),
    INDEX idx_supplier_gst (gst_no),
    INDEX idx_supplier_code (code)
);

CREATE TABLE IF NOT EXISTS supplier_preferred_transport (
    supplier_id INT NOT NULL,
    transport_id INT NOT NULL,

    PRIMARY KEY (supplier_id, transport_id),

    FOREIGN KEY (supplier_id)
        REFERENCES supplier(id)
        ON DELETE CASCADE,

    FOREIGN KEY (transport_id)
        REFERENCES transports(id)
        ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS customer (
    id INT AUTO_INCREMENT PRIMARY KEY,

    code VARCHAR(5) NOT NULL,
    name VARCHAR(50) NOT NULL,

    group_name VARCHAR(50),

    gst_no VARCHAR(15) NULL,

    referenced_by VARCHAR(50),

    address_line1 VARCHAR(120),
    address_line2 VARCHAR(120),

    city VARCHAR(50),
    pin_code VARCHAR(8),
    msme VARCHAR(8),

    remark VARCHAR(150),

    status TINYINT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- UNIQUE CONSTRAINTS
    CONSTRAINT uk_customer_code UNIQUE (code),
    CONSTRAINT uk_customer_gst UNIQUE (gst_no),

    -- INDEXES (as per @Table(indexes))
    INDEX idx_customer_name (name),
    INDEX idx_customer_gst (gst_no),
    INDEX idx_customer_code (code)
);

CREATE TABLE customer_preferred_transport (
    customer_id INT NOT NULL,
    transport_id INT NOT NULL,

    PRIMARY KEY (customer_id, transport_id),

    CONSTRAINT fk_cpt_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_cpt_transport
        FOREIGN KEY (transport_id)
        REFERENCES transports(id)
        ON DELETE CASCADE
);



CREATE TABLE purchase (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE,
    staff_id INT,
    supplier_id INT,
    customer_id INT,
    purchase_amount BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE purchase_images (
    id INT AUTO_INCREMENT PRIMARY KEY,

    image_url VARCHAR(500) NOT NULL,

    purchase_id INT NOT NULL,

    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,

    created_by BIGINT,
    updated_by BIGINT,

    CONSTRAINT fk_purchase_images_purchase
        FOREIGN KEY (purchase_id)
        REFERENCES purchase(id)
        ON DELETE CASCADE
);

CREATE TABLE purchase_customers (
    purchase_id INT NOT NULL,
    customer_id INT NOT NULL,

    PRIMARY KEY (purchase_id, customer_id),

    CONSTRAINT fk_pc_purchase
        FOREIGN KEY (purchase_id)
        REFERENCES purchase(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_pc_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(id)
        ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS staff (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(15) UNIQUE,
    joining_date DATE NOT NULL,
    status TINYINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS contact (
    id INT AUTO_INCREMENT PRIMARY KEY,
    person VARCHAR(255),
    mobile_number VARCHAR(20),
    phone VARCHAR(20),
    supplier_id INT,
    customer_id INT,

    CONSTRAINT fk_contact_supplier
        FOREIGN KEY (supplier_id) REFERENCES supplier(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_contact_customer
        FOREIGN KEY (customer_id) REFERENCES customer(id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS bill (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bill_number VARCHAR(50) UNIQUE,

    date DATE,
    received_date DATE,
    orders VARCHAR(100),

    taxable_value BIGINT,
    bill_amount BIGINT,

    transport_id INT,
    lr_number VARCHAR(20),
    remarks VARCHAR(100),

    supplier_id INT,
    customer_id INT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_bill_transport
        FOREIGN KEY (transport_id) REFERENCES transports(id)
        ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS bill_detail (
    id INT AUTO_INCREMENT PRIMARY KEY,

    pieces INT,
    gross_amount BIGINT,
    discount_percent INT,
    discount_amount BIGINT,
    add_on_amount BIGINT,
    ecr_amount BIGINT,
    gst_percent INT,
    gst_amount BIGINT,

    bill_entry_id INT,

    CONSTRAINT fk_bill_detail_bill
        FOREIGN KEY (bill_entry_id) REFERENCES bill(id)
        ON DELETE CASCADE
);

CREATE TABLE bill_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    bill_id INT NOT NULL,

    image_url VARCHAR(500) NOT NULL,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_bill_images_bill
        FOREIGN KEY (bill_id)
        REFERENCES bill(id)
        ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS credit (
    id INT AUTO_INCREMENT PRIMARY KEY,

    payment_type TINYINT,
    bill_number VARCHAR(50),
    date DATE,

    cheque_number VARCHAR(50),
    cheque_date DATE,

    received_amount BIGINT,
    supplier_current_balance BIGINT,
    customer_current_balance BIGINT,

    draw_type TINYINT,
    remark VARCHAR(150),

    slip_number INT,

    supplier_id INT,
    customer_id INT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_credit_supplier
        FOREIGN KEY (supplier_id) REFERENCES supplier(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_credit_customer
        FOREIGN KEY (customer_id) REFERENCES customer(id)
        ON DELETE SET NULL
);

ALTER TABLE credit
CHANGE cheque_number reference_number VARCHAR(100);

ALTER TABLE credit
CHANGE cheque_date reference_date DATE;

ALTER TABLE credit
MODIFY slip_number VARCHAR(30);


ALTER TABLE bill
ADD INDEX idx_bill_date (date),
ADD INDEX idx_bill_supplier (supplier_id),
ADD INDEX idx_bill_customer (customer_id);

ALTER TABLE bill
MODIFY remarks VARCHAR(255);

ALTER TABLE transports
DROP COLUMN contact_number;

ALTER TABLE transports
DROP COLUMN address;

ALTER TABLE transports
ADD COLUMN email VARCHAR(255) NULL,
ADD COLUMN state VARCHAR(50),
ADD COLUMN pin_code VARCHAR(50),
ADD COLUMN address_line1 VARCHAR(255),
ADD COLUMN address_line2 VARCHAR(255);

CREATE INDEX idx_tc_contact_number
ON transport_contacts(contact_number);


ALTER TABLE supplier
ADD COLUMN reference_by VARCHAR(100) NULL;

ALTER TABLE contact
ADD COLUMN type VARCHAR(50) NULL;

ALTER TABLE contact
DROP COLUMN phone;


ALTER TABLE supplier
ADD COLUMN email VARCHAR(255) NULL
AFTER name;

CREATE INDEX idx_supplier_email ON supplier(email);

ALTER TABLE customer
ADD COLUMN email VARCHAR(255);

ALTER TABLE purchase
DROP COLUMN customer_id;

ALTER TABLE purchase
MODIFY staff_id INT NULL,
MODIFY supplier_id INT NULL,
MODIFY purchase_amount BIGINT NULL;

ALTER TABLE supplier
ADD COLUMN state VARCHAR(255);

ALTER TABLE customer
ADD COLUMN state VARCHAR(255);

ALTER TABLE supplier
DROP INDEX uk_supplier_gst;

ALTER TABLE customer
DROP INDEX uk_customer_gst;

ALTER TABLE transports
DROP INDEX uk_transports_gst_no;

ALTER TABLE transports
MODIFY COLUMN gst_no TEXT NULL;

ALTER TABLE supplier
DROP INDEX idx_supplier_gst;

ALTER TABLE supplier
MODIFY COLUMN gst_no TEXT NULL;

ALTER TABLE customer
DROP INDEX idx_customer_gst;

ALTER TABLE customer
MODIFY COLUMN gst_no TEXT NULL;

ALTER TABLE transport_contacts
MODIFY COLUMN contact_number VARCHAR(15) NULL;

ALTER TABLE supplier
DROP CONSTRAINT uk_supplier_email;

ALTER TABLE transports
DROP CONSTRAINT uk_transports_email;

ALTER TABLE transport_contacts
MODIFY COLUMN contact_number VARCHAR(15) NULL;

ALTER TABLE transport_contacts
DROP INDEX uk_tc_transport_contact;

ALTER TABLE supplier
MODIFY COLUMN group_name VARCHAR(255);

ALTER TABLE customer
MODIFY COLUMN group_name VARCHAR(255);

ALTER TABLE supplier
MODIFY COLUMN name VARCHAR(255);

ALTER TABLE customer
MODIFY COLUMN name VARCHAR(255);

ALTER TABLE transports
MODIFY COLUMN gst_no VARCHAR(255);

ALTER TABLE supplier
MODIFY COLUMN gst_no VARCHAR(255);

ALTER TABLE customer
MODIFY COLUMN gst_no VARCHAR(255);

ALTER TABLE transports
ADD COLUMN created_by BIGINT NULL AFTER created_at,
ADD COLUMN updated_by BIGINT NULL AFTER updated_at;

ALTER TABLE transport_contacts
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD COLUMN created_by BIGINT NULL,
ADD COLUMN updated_by BIGINT NULL;

ALTER TABLE supplier
ADD COLUMN created_by BIGINT NULL AFTER created_at,
ADD COLUMN updated_by BIGINT NULL AFTER updated_at;


ALTER TABLE supplier_preferred_transport
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD COLUMN created_by BIGINT NULL,
ADD COLUMN updated_by BIGINT NULL;

ALTER TABLE customer
ADD COLUMN created_by BIGINT NULL AFTER created_at,
ADD COLUMN updated_by BIGINT NULL AFTER updated_at;

ALTER TABLE customer_preferred_transport
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD COLUMN created_by BIGINT NULL,
ADD COLUMN updated_by BIGINT NULL;

ALTER TABLE purchase
ADD COLUMN created_by BIGINT NULL AFTER created_at,
ADD COLUMN updated_by BIGINT NULL AFTER updated_at;


ALTER TABLE purchase_customers
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD COLUMN created_by BIGINT NULL,
ADD COLUMN updated_by BIGINT NULL;


ALTER TABLE staff
ADD COLUMN created_by BIGINT NULL AFTER created_at,
ADD COLUMN updated_by BIGINT NULL AFTER updated_at;

ALTER TABLE contact
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD COLUMN created_by BIGINT NULL,
ADD COLUMN updated_by BIGINT NULL;

ALTER TABLE bill
ADD COLUMN created_by BIGINT NULL AFTER created_at,
ADD COLUMN updated_by BIGINT NULL AFTER updated_at;

ALTER TABLE bill_detail
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD COLUMN created_by BIGINT NULL,
ADD COLUMN updated_by BIGINT NULL;

ALTER TABLE bill_images
ADD COLUMN created_by BIGINT NULL AFTER created_at,
ADD COLUMN updated_by BIGINT NULL AFTER updated_at;

ALTER TABLE credit
ADD COLUMN created_by BIGINT NULL AFTER created_at,
ADD COLUMN updated_by BIGINT NULL AFTER updated_at;

ALTER TABLE supplier MODIFY code VARCHAR(7);

ALTER TABLE customer MODIFY code VARCHAR(7);
UPDATE supplier
SET code = CONCAT('S', LPAD(SUBSTRING(code, 2), 6, '0'));

UPDATE customer
SET code = CONCAT('S', LPAD(SUBSTRING(code, 2), 6, '0'));


ALTER TABLE transports
MODIFY COLUMN gst_no varchar(255);

ALTER TABLE supplier
MODIFY COLUMN gst_no varchar(255);

ALTER TABLE customer
MODIFY COLUMN gst_no varchar(255);

ALTER TABLE purchase
DROP COLUMN supplier_id;

DROP TABLE purchase_customers;

ALTER TABLE purchase
ADD COLUMN customer_id INT NULL AFTER staff_id;

ALTER TABLE purchase
ADD CONSTRAINT fk_purchase_customer
FOREIGN KEY (customer_id)
REFERENCES customer(id)
ON DELETE SET NULL;

CREATE INDEX idx_purchase_customer ON purchase(customer_id);

CREATE TABLE purchase_suppliers (
    purchase_id INT NOT NULL,
    supplier_id INT NOT NULL,

    PRIMARY KEY (purchase_id, supplier_id),

    CONSTRAINT fk_ps_purchase
        FOREIGN KEY (purchase_id)
        REFERENCES purchase(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_ps_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES supplier(id)
        ON DELETE CASCADE
);


ALTER TABLE credit
DROP COLUMN supplier_current_balance;

ALTER TABLE credit
DROP COLUMN customer_current_balance;
ALTER TABLE purchase_images
CHANGE COLUMN image_url public_url VARCHAR(500);

ALTER TABLE purchase_images
ADD COLUMN object_key VARCHAR(500) NOT NULL AFTER id;

ALTER TABLE bill_images
CHANGE COLUMN image_url public_url VARCHAR(500);

ALTER TABLE bill_images
ADD COLUMN object_key VARCHAR(500) NOT NULL AFTER id;

ALTER TABLE credit
DROP COLUMN supplier_current_balance,
DROP COLUMN customer_current_balance;

ALTER TABLE transports
DROP INDEX uk_transports_gst_no;

ALTER TABLE transports
DROP INDEX uk_transports_email;