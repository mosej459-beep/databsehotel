-- HotelPro RMS - Complete Database Schema

CREATE DATABASE IF NOT EXISTS hotelpro_rms;
USE hotelpro_rms;

-- Users and Roles
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (role_name, description) VALUES
('Administrator', 'Full system access'),
('Manager', 'Reports and supervision'),
('Receptionist', 'Reservations and guests'),
('Cashier', 'Payments and invoices'),
('Housekeeper', 'Cleaning tasks'),
('Restaurant Staff', 'POS functions'),
('Accountant', 'Financial reports');

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- Default admin user (password: admin123)
INSERT INTO users (username, password_hash, email, full_name, role_id) VALUES
('admin', '$2b$10$8K1p/a0dL1LXMIgoEDFrwOfMQkfAjkMBcGmFCeFHG5KzqJkF1qKq', 'admin@hotelpro.com', 'System Administrator', 1);

-- Guest Management
CREATE TABLE guests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    city VARCHAR(50),
    country VARCHAR(50),
    nationality VARCHAR(50),
    id_type ENUM('National ID', 'Passport', 'Driver License', 'Other') DEFAULT 'National ID',
    id_number VARCHAR(50),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    is_blacklisted BOOLEAN DEFAULT FALSE,
    notes TEXT,
    preferences TEXT,
    is_loyalty_member BOOLEAN DEFAULT FALSE,
    loyalty_points INT DEFAULT 0,
    total_stays INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Room Types
CREATE TABLE room_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL,
    max_adults INT DEFAULT 2,
    max_children INT DEFAULT 1,
    amenities TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO room_types (type_name, description, base_price, max_adults, max_children) VALUES
('Standard', 'Comfortable room with essential amenities', 1500.00, 2, 1),
('Deluxe', 'Spacious room with premium amenities', 2500.00, 2, 2),
('Suite', 'Luxury suite with separate living area', 4000.00, 3, 2),
('Executive', 'Top-floor executive room with city views', 3500.00, 2, 1),
('Family', 'Large room designed for families', 3000.00, 4, 3),
('Penthouse', 'Ultimate luxury penthouse suite', 8000.00, 4, 2);

-- Rooms
CREATE TABLE rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type_id INT NOT NULL,
    floor INT,
    status ENUM('Available', 'Occupied', 'Reserved', 'Under Maintenance', 'Cleaning') DEFAULT 'Available',
    description TEXT,
    price_modifier DECIMAL(10,2) DEFAULT 0.00,
    is_smoking BOOLEAN DEFAULT FALSE,
    view_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (room_type_id) REFERENCES room_types(id)
);

-- Insert sample rooms
INSERT INTO rooms (room_number, room_type_id, floor, status, view_type) VALUES
('101', 1, 1, 'Available', 'Garden'),
('102', 1, 1, 'Available', 'Garden'),
('103', 1, 1, 'Available', 'Pool'),
('104', 2, 1, 'Available', 'Pool'),
('105', 2, 1, 'Available', 'City'),
('201', 1, 2, 'Available', 'Garden'),
('202', 1, 2, 'Available', 'Garden'),
('203', 2, 2, 'Available', 'Pool'),
('204', 2, 2, 'Available', 'City'),
('205', 3, 2, 'Available', 'City'),
('301', 1, 3, 'Available', 'Garden'),
('302', 1, 3, 'Available', 'Garden'),
('303', 2, 3, 'Available', 'Pool'),
('304', 2, 3, 'Available', 'City'),
('305', 3, 3, 'Available', 'City'),
('401', 4, 4, 'Available', 'Panoramic'),
('402', 4, 4, 'Available', 'Panoramic'),
('403', 5, 4, 'Available', 'City'),
('501', 6, 5, 'Available', 'Panoramic'),
('502', 3, 5, 'Available', 'Panoramic');

-- Reservations
CREATE TABLE reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_number VARCHAR(20) UNIQUE NOT NULL,
    guest_id INT NOT NULL,
    room_id INT,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    adults INT DEFAULT 1,
    children INT DEFAULT 0,
    status ENUM('Pending', 'Confirmed', 'Checked In', 'Checked Out', 'Cancelled', 'No Show') DEFAULT 'Pending',
    booking_source ENUM('Direct', 'Online', 'Phone', 'Email', 'Walk-in', 'Agent') DEFAULT 'Direct',
    special_requests TEXT,
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    paid_amount DECIMAL(12,2) DEFAULT 0.00,
    balance DECIMAL(12,2) DEFAULT 0.00,
    is_group_booking BOOLEAN DEFAULT FALSE,
    group_id VARCHAR(50),
    created_by INT,
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES guests(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Check Ins / Check Outs
CREATE TABLE check_ins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_time DATETIME NOT NULL,
    expected_check_out DATETIME NOT NULL,
    actual_check_out DATETIME,
    id_verified BOOLEAN DEFAULT FALSE,
    deposit_amount DECIMAL(12,2) DEFAULT 0.00,
    payment_method_used VARCHAR(50),
    checked_in_by INT,
    checked_out_by INT,
    notes TEXT,
    status ENUM('Checked In', 'Checked Out', 'Extended') DEFAULT 'Checked In',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES reservations(id),
    FOREIGN KEY (guest_id) REFERENCES guests(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id),
    FOREIGN KEY (checked_in_by) REFERENCES users(id),
    FOREIGN KEY (checked_out_by) REFERENCES users(id)
);

-- Payments
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    payment_number VARCHAR(20) UNIQUE NOT NULL,
    reservation_id INT,
    guest_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM('Cash', 'Mobile Money', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Other') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    transaction_reference VARCHAR(100),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    received_by INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES reservations(id),
    FOREIGN KEY (guest_id) REFERENCES guests(id),
    FOREIGN KEY (received_by) REFERENCES users(id)
);

-- Invoices
CREATE TABLE invoices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(20) UNIQUE NOT NULL,
    reservation_id INT,
    guest_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    tax_rate DECIMAL(5,2) DEFAULT 15.00,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL,
    paid_amount DECIMAL(12,2) DEFAULT 0.00,
    balance DECIMAL(12,2) DEFAULT 0.00,
    status ENUM('Draft', 'Issued', 'Paid', 'Partially Paid', 'Overdue', 'Cancelled') DEFAULT 'Draft',
    notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES reservations(id),
    FOREIGN KEY (guest_id) REFERENCES guests(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Invoice Items
CREATE TABLE invoice_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    description VARCHAR(255) NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    item_type ENUM('Room Charge', 'Restaurant', 'Bar', 'Room Service', 'Laundry', 'Spa', 'Other') DEFAULT 'Room Charge',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
);

-- Housekeeping
CREATE TABLE housekeeping_tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    task_type ENUM('Daily Cleaning', 'Deep Cleaning', 'Turn Down', 'Maintenance Check', 'Inspection') DEFAULT 'Daily Cleaning',
    priority ENUM('Low', 'Medium', 'High', 'Urgent') DEFAULT 'Medium',
    assigned_to INT,
    status ENUM('Pending', 'In Progress', 'Completed', 'Verified') DEFAULT 'Pending',
    scheduled_date DATE,
    completed_at TIMESTAMP NULL,
    verified_by INT,
    notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES rooms(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id),
    FOREIGN KEY (verified_by) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Linen Tracking
CREATE TABLE linen_tracking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT,
    linen_type ENUM('Bedsheets', 'Towels', 'Pillowcases', 'Bathrobes', 'Duvets') NOT NULL,
    quantity INT NOT NULL,
    status ENUM('Clean', 'Dirty', 'In Laundry', 'Damaged') DEFAULT 'Clean',
    action ENUM('Issued', 'Collected', 'Damaged', 'Replaced') NOT NULL,
    handled_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES rooms(id),
    FOREIGN KEY (handled_by) REFERENCES users(id)
);

-- Employees
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    position VARCHAR(50),
    department ENUM('Front Office', 'Housekeeping', 'Restaurant', 'Kitchen', 'Maintenance', 'Management', 'Security', 'Other') NOT NULL,
    hire_date DATE,
    salary DECIMAL(10,2),
    emergency_contact VARCHAR(50),
    emergency_phone VARCHAR(20),
    address TEXT,
    id_number VARCHAR(50) UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Attendance
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    date DATE NOT NULL,
    check_in TIME,
    check_out TIME,
    status ENUM('Present', 'Absent', 'Late', 'Half Day', 'Holiday') DEFAULT 'Present',
    notes TEXT,
    recorded_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (recorded_by) REFERENCES users(id)
);

-- Shifts
CREATE TABLE shifts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    shift_date DATE NOT NULL,
    shift_type ENUM('Morning', 'Afternoon', 'Night', 'Full Day') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Absent', 'Swapped') DEFAULT 'Scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- Leave Management
CREATE TABLE leaves (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_type ENUM('Annual', 'Sick', 'Personal', 'Maternity', 'Paternity', 'Other') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    status ENUM('Pending', 'Approved', 'Rejected', 'Cancelled') DEFAULT 'Pending',
    approved_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- Inventory - Categories
CREATE TABLE inventory_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO inventory_categories (category_name, description) VALUES
('Cleaning Supplies', 'Cleaning agents and equipment'),
('Toiletries', 'Soap, shampoo, toilet paper etc.'),
('Linens', 'Bedsheets, towels, bathrobes'),
('Mini Bar', 'Beverages and snacks for mini bar'),
('Kitchen Supplies', 'Food ingredients and kitchen items'),
('Office Supplies', 'Stationery and office materials'),
('Maintenance', 'Tools and repair items'),
('Restaurant', 'Restaurant consumables');

-- Inventory Items
CREATE TABLE inventory_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    sku VARCHAR(50) UNIQUE,
    unit VARCHAR(20) NOT NULL,
    quantity DECIMAL(10,2) DEFAULT 0,
    minimum_quantity DECIMAL(10,2) DEFAULT 10,
    unit_price DECIMAL(10,2),
    supplier_id INT,
    location VARCHAR(50),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES inventory_categories(id)
);

-- Suppliers
CREATE TABLE suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    city VARCHAR(50),
    payment_terms VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stock Movements
CREATE TABLE stock_movements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    movement_type ENUM('Stock In', 'Stock Out', 'Adjustment', 'Damage', 'Return') NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2),
    total_cost DECIMAL(10,2),
    reference_type VARCHAR(50),
    reference_id INT,
    notes TEXT,
    performed_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES inventory_items(id),
    FOREIGN KEY (performed_by) REFERENCES users(id)
);

-- Purchase Orders
CREATE TABLE purchase_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    supplier_id INT NOT NULL,
    order_date DATE NOT NULL,
    expected_delivery DATE,
    status ENUM('Draft', 'Pending', 'Approved', 'Delivered', 'Cancelled') DEFAULT 'Draft',
    total_amount DECIMAL(12,2),
    notes TEXT,
    created_by INT,
    approved_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- Purchase Order Items
CREATE TABLE purchase_order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    received_quantity DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES inventory_items(id)
);

-- Restaurant / Bar - Menu Categories
CREATE TABLE menu_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO menu_categories (category_name) VALUES
('Breakfast'), ('Lunch'), ('Dinner'), ('Beverages'), ('Bar'), ('Snacks'), ('Desserts');

-- Menu Items
CREATE TABLE menu_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES menu_categories(id)
);

-- Restaurant Orders
CREATE TABLE restaurant_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    guest_id INT,
    room_id INT,
    table_number VARCHAR(10),
    order_type ENUM('Dine In', 'Takeaway', 'Room Service', 'Delivery') DEFAULT 'Dine In',
    status ENUM('Pending', 'Preparing', 'Ready', 'Served', 'Paid', 'Cancelled') DEFAULT 'Pending',
    subtotal DECIMAL(12,2) DEFAULT 0.00,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    payment_status ENUM('Pending', 'Paid', 'Partially Paid') DEFAULT 'Pending',
    notes TEXT,
    taken_by INT,
    served_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES guests(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id),
    FOREIGN KEY (taken_by) REFERENCES users(id),
    FOREIGN KEY (served_by) REFERENCES users(id)
);

-- Restaurant Order Items
CREATE TABLE restaurant_order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    notes TEXT,
    status ENUM('Pending', 'Preparing', 'Ready', 'Served', 'Cancelled') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_order_id) REFERENCES restaurant_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);

-- Expense Categories
CREATE TABLE expense_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO expense_categories (category_name, description) VALUES
('Utilities', 'Electricity, water, gas'),
('Salaries', 'Employee salaries and wages'),
('Food & Beverage', 'Restaurant supplies'),
('Maintenance', 'Repairs and maintenance'),
('Housekeeping', 'Cleaning supplies and linens'),
('Marketing', 'Advertising and promotions'),
('Administrative', 'Office expenses'),
('Taxes', 'Tax payments'),
('Other', 'Miscellaneous expenses');

-- Expenses
CREATE TABLE expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    expense_number VARCHAR(20) UNIQUE NOT NULL,
    category_id INT NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    expense_date DATE NOT NULL,
    payment_method ENUM('Cash', 'Bank Transfer', 'Credit Card', 'Cheque', 'Other') DEFAULT 'Cash',
    receipt_number VARCHAR(50),
    vendor_name VARCHAR(100),
    is_recurring BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_by INT,
    approved_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES expense_categories(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- Notifications Log
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipient_type ENUM('Guest', 'Staff', 'All') NOT NULL,
    recipient_id INT,
    notification_type ENUM('SMS', 'Email', 'System', 'WhatsApp') DEFAULT 'System',
    subject VARCHAR(255),
    message TEXT NOT NULL,
    status ENUM('Pending', 'Sent', 'Failed') DEFAULT 'Pending',
    sent_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit Log
CREATE TABLE audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    old_values TEXT,
    new_values TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- System Settings
CREATE TABLE system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_group VARCHAR(50) DEFAULT 'General',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO system_settings (setting_key, setting_value, setting_group) VALUES
('hotel_name', 'HotelPro RMS', 'General'),
('hotel_address', '123 Hotel Street', 'General'),
('hotel_phone', '+1234567890', 'General'),
('hotel_email', 'info@hotelpro.com', 'General'),
('tax_rate', '15', 'Finance'),
('currency', 'USD', 'Finance'),
('check_in_time', '14:00', 'Operations'),
('check_out_time', '11:00', 'Operations'),
('default_occupancy', '0', 'Dashboard'),
('smtp_host', '', 'Email'),
('smtp_port', '587', 'Email'),
('smtp_user', '', 'Email'),
('smtp_pass', '', 'Email'),
('sms_api_key', '', 'SMS'),
('sms_sender_id', 'HOTELPRO', 'SMS'),
('online_booking_enabled', 'false', 'Online'),
('multi_branch_enabled', 'false', 'System'),
('loyalty_enabled', 'false', 'System');

-- Indexes for performance
CREATE INDEX idx_reservation_dates ON reservations(check_in_date, check_out_date);
CREATE INDEX idx_reservation_status ON reservations(status);
CREATE INDEX idx_room_status ON rooms(status);
CREATE INDEX idx_payment_date ON payments(payment_date);
CREATE INDEX idx_invoice_status ON invoices(status);
CREATE INDEX idx_guest_phone ON guests(phone);
CREATE INDEX idx_guest_email ON guests(email);
CREATE INDEX idx_employee_department ON employees(department);
CREATE INDEX idx_inventory_category ON inventory_items(category_id);
CREATE INDEX idx_stock_movement_date ON stock_movements(created_at);