CREATE TABLE IF NOT EXISTS staff(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    joining_date DATE NOT NULL,
    status TINYINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(5) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    group_name VARCHAR(50) NOT NULL,
    gst_no VARCHAR(15) NOT NULL UNIQUE,
    referenced_by VARCHAR(50) NOT NULL,
    address_line1 VARCHAR(120) NOT NULL,
    address_line2 VARCHAR(120) NOT NULL,
    state VARCHAR
    city VARCHAR(50) NOT NULL,
    pin_code VARCHAR(8) NOT NULL,
    msme VARCHAR(8) NOT NULL,
    preferred_transport VARCHAR(150) NOT NULL,
    remark VARCHAR(150),
    status TINYINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE supplier (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(5) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    group_name VARCHAR(50) NOT NULL,
    gst_no VARCHAR(15) NOT NULL UNIQUE,
    commission_scheme VARCHAR(20) NOT NULL,
    commission_rate DECIMAL(10,2) NOT NULL,
    address_line1 VARCHAR(120) NOT NULL,
    address_line2 VARCHAR(120) NOT NULL,
    city VARCHAR(25) NOT NULL,
    pin_code VARCHAR(8) NOT NULL,
    msme VARCHAR(8) NOT NULL,
    preferred_transport VARCHAR(150) NOT NUll,
    remark VARCHAR(150),
    status TINYINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE contact (
    id INT AUTO_INCREMENT PRIMARY KEY,
    person VARCHAR(255) NOT NULL UNIQUE,
    mobile_number VARCHAR(20) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    supplier_id INT,
    customer_id INT,
    CONSTRAINT fk_contact_supplier FOREIGN KEY (supplier_id)
        REFERENCES Supplier(id) ON DELETE CASCADE,
    CONSTRAINT fk_contact_customer FOREIGN KEY (customer_id)
        REFERENCES Customer(id) ON DELETE CASCADE
);

CREATE TABLE bill (
    id INT PRIMARY KEY AUTO_INCREMENT,
    bill_number VARCHAR(50) NOT NULL UNIQUE,
    date DATE NOT NULL,
    received_date DATE NOT NULL,
    orders VARCHAR(100) NOT NULL,
    pieces INT NOT NULL,
    gross_amount BIGINT NOT NULL,
    discount INT NOT NULL,
    discount_amount BIGINT NOT NULL,
    gst_percentage INT NOT NULL,
    gst_amount BIGINT NOT NULL,
    bill_amount BIGINT NOT NULL,
    add_on_amount BIGINT NOT NULL,
    taxable_value BIGINT NOT NULL,
    transport VARCHAR(50) NOT NULL,
    lr_number VARCHAR(20) NOT NULL UNIQUE,
    ecr_amount BIGINT NOT NULL,
    remarks VARCHAR(100),
    supplier_id INT,
    customer_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE credit (
    id INT PRIMARY KEY AUTO_INCREMENT,
    payment_type TINYINT NOT NULL,
    bill_number VARCHAR(50) NOT NULL UNIQUE,
    date DATE NOT NULL,
    cheque_number VARCHAR(10) NOT NULL UNIQUE,
    cheque_date DATE NOT NULL,
    received_amount BIGINT NOT NULL,
    supplier_current_balance BIGINT,
    customer_current_balance BIGINT,
    draw_type TINYINT,
    remark VARCHAR(150),
    supplierId INT,
    customer_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


