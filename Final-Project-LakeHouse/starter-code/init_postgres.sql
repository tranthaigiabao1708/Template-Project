-- ================================================================
-- VI DU, CU THE VOI BAI TOAN BOOKINGS (DAT PHONG KHACH SAN)
-- (Day la code mau huong dan, hoc vien can tuy chinh theo
--  bai toan va thiet ke cua minh)
-- ================================================================
-- FINAL PROJECT: LAKEHOUSE - PostgreSQL Source Database
-- Bookings Data Schema
-- ================================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    nationality VARCHAR(50),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS room_types (
    room_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    max_occupancy INT DEFAULT 2,
    amenities TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rooms (
    room_id SERIAL PRIMARY KEY,
    room_type_id INT REFERENCES room_types(room_type_id),
    room_number VARCHAR(10) NOT NULL UNIQUE,
    floor INT,
    status VARCHAR(20) DEFAULT 'available' 
        CHECK (status IN ('available', 'occupied', 'maintenance')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bookings (
    booking_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    room_id INT REFERENCES rooms(room_id),
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    num_guests INT DEFAULT 1,
    total_amount DECIMAL(12,2),
    status VARCHAR(20) DEFAULT 'confirmed'
        CHECK (status IN ('pending', 'confirmed', 'checked_in', 'checked_out', 'cancelled')),
    booking_channel VARCHAR(30),
    special_requests TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES bookings(booking_id),
    payment_method VARCHAR(30),
    amount DECIMAL(12,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'completed'
);

-- ============================================================
-- SEED DATA
-- ============================================================

-- Room Types
INSERT INTO room_types (type_name, base_price, max_occupancy, amenities) VALUES
('Standard', 80.00, 2, 'WiFi, TV, AC'),
('Deluxe', 150.00, 2, 'WiFi, TV, AC, Mini Bar, City View'),
('Suite', 280.00, 3, 'WiFi, TV, AC, Mini Bar, Living Room, Ocean View'),
('Family', 200.00, 4, 'WiFi, TV, AC, Two Beds, Kid-friendly'),
('Presidential', 500.00, 4, 'WiFi, TV, AC, Full Kitchen, Jacuzzi, Panorama View');

-- Rooms (20 rooms)
INSERT INTO rooms (room_type_id, room_number, floor) VALUES
(1, '101', 1), (1, '102', 1), (1, '103', 1), (1, '104', 1),
(2, '201', 2), (2, '202', 2), (2, '203', 2),
(2, '301', 3), (2, '302', 3),
(3, '401', 4), (3, '402', 4),
(3, '501', 5), (3, '502', 5),
(4, '601', 6), (4, '602', 6), (4, '603', 6),
(5, '701', 7), (5, '702', 7),
(1, '105', 1), (1, '106', 1);

-- Customers (sample 20)
INSERT INTO customers (full_name, email, phone, nationality, date_of_birth) VALUES
('Nguyen Van An', 'an.nguyen@email.com', '+84901234567', 'Vietnamese', '1990-05-15'),
('Tran Thi Binh', 'binh.tran@email.com', '+84912345678', 'Vietnamese', '1992-08-20'),
('John Smith', 'john.smith@email.com', '+1234567890', 'American', '1985-03-10'),
('Emma Wilson', 'emma.w@email.com', '+4412345678', 'British', '1988-11-25'),
('Tanaka Yuki', 'yuki.t@email.com', '+81901234567', 'Japanese', '1995-07-03'),
('Kim Min-jun', 'minjun.k@email.com', '+82101234567', 'Korean', '1991-01-15'),
('Le Hoang Cuong', 'cuong.le@email.com', '+84923456789', 'Vietnamese', '1993-04-20'),
('Sophie Martin', 'sophie.m@email.com', '+33612345678', 'French', '1987-09-08'),
('Wang Wei', 'wei.wang@email.com', '+86138123456', 'Chinese', '1994-12-01'),
('Pham Thi Dung', 'dung.pham@email.com', '+84934567890', 'Vietnamese', '1996-06-18'),
('Michael Brown', 'michael.b@email.com', '+61412345678', 'Australian', '1982-02-28'),
('Hoang Minh Duc', 'duc.hoang@email.com', '+84945678901', 'Vietnamese', '1989-10-12'),
('Lisa Anderson', 'lisa.a@email.com', '+14155551234', 'American', '1993-07-22'),
('Vo Thanh Tung', 'tung.vo@email.com', '+84956789012', 'Vietnamese', '1991-03-05'),
('Maria Garcia', 'maria.g@email.com', '+34612345678', 'Spanish', '1990-08-14'),
('Bui Van Hai', 'hai.bui@email.com', '+84967890123', 'Vietnamese', '1994-11-30'),
('Robert Taylor', 'robert.t@email.com', '+44207123456', 'British', '1986-05-09'),
('Do Thi Lan', 'lan.do@email.com', '+84978901234', 'Vietnamese', '1997-01-25'),
('David Johnson', 'david.j@email.com', '+12125551234', 'American', '1984-04-17'),
('Ngo Quang Huy', 'huy.ngo@email.com', '+84989012345', 'Vietnamese', '1992-09-03');

-- Bookings (sample 50 - TODO: Học viên thêm cho đủ 500+)
-- Sử dụng generate_series trong production
DO $$
DECLARE
    i INT;
    cust_id INT;
    rm_id INT;
    ci_date DATE;
    co_date DATE;
    channel VARCHAR;
    bk_status VARCHAR;
    amt DECIMAL;
BEGIN
    FOR i IN 1..50 LOOP
        cust_id := (i % 20) + 1;
        rm_id := (i % 20) + 1;
        ci_date := '2024-01-01'::DATE + (random() * 365)::INT;
        co_date := ci_date + (random() * 7 + 1)::INT;
        channel := (ARRAY['website', 'mobile_app', 'phone', 'walk_in', 'booking.com', 'agoda'])[floor(random() * 6 + 1)];
        bk_status := (ARRAY['confirmed', 'checked_in', 'checked_out', 'cancelled'])[floor(random() * 4 + 1)];
        amt := (random() * 2000 + 100)::DECIMAL(12,2);
        
        INSERT INTO bookings (customer_id, room_id, check_in_date, check_out_date, num_guests, total_amount, status, booking_channel)
        VALUES (cust_id, rm_id, ci_date, co_date, floor(random() * 3 + 1), amt, bk_status, channel);
    END LOOP;
END $$;

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_bookings_updated_at 
    BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
