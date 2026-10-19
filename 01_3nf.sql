-- Лабораторная работа № 1. Вариант 15.
-- Система учета проката на лыжной базе.
-- Реляционная модель в третьей нормальной форме (3НФ).
-- PostgreSQL 17. Всего 8 таблиц.
--
-- Запускайте после подключения к нужной базе данных, например ski_rental_db.
-- Скрипт не удаляет существующие объекты.

BEGIN;

-- 1. Клиенты лыжной базы.
CREATE TABLE customer (
    customer_id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- 2. Сотрудники, оформляющие прокат и обслуживающие снаряжение.
CREATE TABLE employee (
    employee_id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    position_name VARCHAR(80) NOT NULL,
    phone VARCHAR(20)
);

-- 3. Категории прокатного снаряжения (лыжи, ботинки, палки и т.д.).
CREATE TABLE equipment_category (
    category_id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(200)
);

-- 4. Отдельные единицы инвентаря.
CREATE TABLE equipment (
    equipment_id BIGSERIAL PRIMARY KEY,
    category_id BIGINT NOT NULL,
    inventory_number VARCHAR(50) NOT NULL UNIQUE,
    brand VARCHAR(80),
    model VARCHAR(80),
    size VARCHAR(20),
    condition VARCHAR(30),
    daily_price NUMERIC(10, 2) NOT NULL CHECK (daily_price >= 0),
    CONSTRAINT fk_equipment_category
        FOREIGN KEY (category_id) REFERENCES equipment_category(category_id)
);

-- 5. Выдачи инвентаря клиентам.
CREATE TABLE rental (
    rental_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    rental_date TIMESTAMP NOT NULL,
    planned_return TIMESTAMP NOT NULL,
    actual_return TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT fk_rental_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_rental_employee
        FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT chk_planned_return
        CHECK (planned_return >= rental_date),
    CONSTRAINT chk_actual_return
        CHECK (actual_return IS NULL OR actual_return >= rental_date)
);

-- 6. Состав выдачи: какое снаряжение было выдано по каждому прокату.
-- daily_price фиксирует цену на момент выдачи, независимо от ее изменения в equipment.
CREATE TABLE rental_item (
    rental_item_id BIGSERIAL PRIMARY KEY,
    rental_id BIGINT NOT NULL,
    equipment_id BIGINT NOT NULL,
    daily_price NUMERIC(10, 2) NOT NULL CHECK (daily_price >= 0),
    CONSTRAINT fk_rental_item_rental
        FOREIGN KEY (rental_id) REFERENCES rental(rental_id),
    CONSTRAINT fk_rental_item_equipment
        FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id),
    CONSTRAINT uq_rental_item
        UNIQUE (rental_id, equipment_id)
);

-- 7. Обслуживание и ремонт оборудования.
CREATE TABLE maintenance (
    maintenance_id BIGSERIAL PRIMARY KEY,
    equipment_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    service_date DATE NOT NULL,
    description VARCHAR(200),
    cost NUMERIC(10, 2) NOT NULL CHECK (cost >= 0),
    CONSTRAINT fk_maintenance_equipment
        FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id),
    CONSTRAINT fk_maintenance_employee
        FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

-- 8. Платежи за прокат.
CREATE TABLE payment (
    payment_id BIGSERIAL PRIMARY KEY,
    rental_id BIGINT NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(30) NOT NULL,
    CONSTRAINT fk_payment_rental
        FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
);

COMMIT;

-- Проверка: должны существовать все 8 таблиц реляционной модели.
-- Считает только таблицы 3НФ (без таблиц Data Vault).
SELECT COUNT(*) AS nf3_table_count
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
  AND table_name IN (
      'customer', 'employee', 'equipment_category', 'equipment',
      'rental', 'rental_item', 'maintenance', 'payment'
  );
