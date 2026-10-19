-- Вариант 15. Система учета проката на лыжной базе.
-- PostgreSQL 17. Data Vault: 7 hubs + 7 satellites + 5 links = 19 tables.
-- Создайте базу ski_rental_db отдельно, затем выполняйте скрипт в ней.

-- HUBS: бизнес-ключи сущностей
CREATE TABLE h_customer (
    customer_hk CHAR(64) PRIMARY KEY,
    customer_id VARCHAR(30) NOT NULL UNIQUE,
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

CREATE TABLE h_employee (
    employee_hk CHAR(64) PRIMARY KEY,
    employee_id VARCHAR(30) NOT NULL UNIQUE,
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

CREATE TABLE h_category (
    category_hk CHAR(64) PRIMARY KEY,
    category_id VARCHAR(30) NOT NULL UNIQUE,
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

CREATE TABLE h_equipment (
    equipment_hk CHAR(64) PRIMARY KEY,
    equipment_id VARCHAR(30) NOT NULL UNIQUE,
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

CREATE TABLE h_rental (
    rental_hk CHAR(64) PRIMARY KEY,
    rental_id VARCHAR(30) NOT NULL UNIQUE,
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

CREATE TABLE h_payment (
    payment_hk CHAR(64) PRIMARY KEY,
    payment_id VARCHAR(30) NOT NULL UNIQUE,
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

CREATE TABLE h_maintenance (
    maintenance_hk CHAR(64) PRIMARY KEY,
    maintenance_id VARCHAR(30) NOT NULL UNIQUE,
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITES: изменяемые атрибуты с историей загрузки
CREATE TABLE s_customer (
    customer_hk CHAR(64) NOT NULL REFERENCES h_customer(customer_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hashdiff CHAR(64) NOT NULL,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    middle_name VARCHAR(50),
    birth_date DATE,
    phone VARCHAR(20),
    email VARCHAR(100),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_hk, load_dt)
);

CREATE TABLE s_employee (
    employee_hk CHAR(64) NOT NULL REFERENCES h_employee(employee_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hashdiff CHAR(64) NOT NULL,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    middle_name VARCHAR(50),
    position VARCHAR(30),
    phone VARCHAR(20),
    email VARCHAR(100),
    hire_date DATE,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (employee_hk, load_dt)
);

CREATE TABLE s_category (
    category_hk CHAR(64) NOT NULL REFERENCES h_category(category_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hashdiff CHAR(64) NOT NULL,
    category_name VARCHAR(50),
    description VARCHAR(200),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (category_hk, load_dt)
);

CREATE TABLE s_equipment (
    equipment_hk CHAR(64) NOT NULL REFERENCES h_equipment(equipment_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hashdiff CHAR(64) NOT NULL,
    brand VARCHAR(50),
    model VARCHAR(50),
    size VARCHAR(20),
    inventory_number VARCHAR(50),
    condition VARCHAR(20),
    daily_price NUMERIC(10,2),
    is_available BOOLEAN,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (equipment_hk, load_dt)
);

CREATE TABLE s_rental (
    rental_hk CHAR(64) NOT NULL REFERENCES h_rental(rental_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hashdiff CHAR(64) NOT NULL,
    rental_date DATE,
    planned_return_date DATE,
    actual_return_date DATE,
    total_cost NUMERIC(10,2),
    status VARCHAR(20),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (rental_hk, load_dt)
);

CREATE TABLE s_payment (
    payment_hk CHAR(64) NOT NULL REFERENCES h_payment(payment_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hashdiff CHAR(64) NOT NULL,
    payment_date DATE,
    amount NUMERIC(10,2),
    method VARCHAR(20),
    status VARCHAR(20),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (payment_hk, load_dt)
);

CREATE TABLE s_maintenance (
    maintenance_hk CHAR(64) NOT NULL REFERENCES h_maintenance(maintenance_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hashdiff CHAR(64) NOT NULL,
    maintenance_date DATE,
    type VARCHAR(50),
    description VARCHAR(200),
    cost NUMERIC(10,2),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (maintenance_hk, load_dt)
);

-- LINKS: связи между бизнес-сущностями
CREATE TABLE l_rental_transaction (
    rental_transaction_hk CHAR(64) PRIMARY KEY,
    rental_hk CHAR(64) NOT NULL REFERENCES h_rental(rental_hk),
    customer_hk CHAR(64) NOT NULL REFERENCES h_customer(customer_hk),
    employee_hk CHAR(64) NOT NULL REFERENCES h_employee(employee_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (rental_hk, customer_hk, employee_hk)
);

CREATE TABLE l_equipment_category (
    equipment_category_hk CHAR(64) PRIMARY KEY,
    equipment_hk CHAR(64) NOT NULL REFERENCES h_equipment(equipment_hk),
    category_hk CHAR(64) NOT NULL REFERENCES h_category(category_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (equipment_hk, category_hk)
);

CREATE TABLE l_rental_item (
    rental_item_hk CHAR(64) PRIMARY KEY,
    rental_hk CHAR(64) NOT NULL REFERENCES h_rental(rental_hk),
    equipment_hk CHAR(64) NOT NULL REFERENCES h_equipment(equipment_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (rental_hk, equipment_hk)
);

CREATE TABLE l_payment_rental (
    payment_rental_hk CHAR(64) PRIMARY KEY,
    payment_hk CHAR(64) NOT NULL REFERENCES h_payment(payment_hk),
    rental_hk CHAR(64) NOT NULL REFERENCES h_rental(rental_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (payment_hk, rental_hk)
);

CREATE TABLE l_maintenance_equipment (
    maintenance_equipment_hk CHAR(64) PRIMARY KEY,
    maintenance_hk CHAR(64) NOT NULL REFERENCES h_maintenance(maintenance_hk),
    equipment_hk CHAR(64) NOT NULL REFERENCES h_equipment(equipment_hk),
    employee_hk CHAR(64) NOT NULL REFERENCES h_employee(employee_hk),
    load_dt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (maintenance_hk, equipment_hk, employee_hk)
);

-- Проверка числа таблиц в схеме public:
SELECT COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
