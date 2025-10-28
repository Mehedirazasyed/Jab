-- AFFILUXA Institute Database Schema
-- Database for managing students, courses, admissions, results, and certificates

-- Create Database
CREATE DATABASE IF NOT EXISTS affiluxa_db;
USE affiluxa_db;

-- ============================================
-- Table: users
-- Stores user authentication information
-- ============================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    user_type ENUM('student', 'admin', 'instructor') DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_user_type (user_type)
);

-- ============================================
-- Table: courses
-- Stores course information
-- ============================================
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(50) UNIQUE NOT NULL,
    course_name VARCHAR(255) NOT NULL,
    description TEXT,
    duration_months INT NOT NULL,
    theory_duration_months INT NOT NULL,
    practical_duration_months INT NOT NULL,
    course_fee DECIMAL(10, 2) NOT NULL,
    stipend_amount DECIMAL(10, 2) DEFAULT 0,
    eligibility VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_course_code (course_code)
);

-- ============================================
-- Table: students
-- Stores detailed student information
-- ============================================
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE,
    roll_number VARCHAR(50) UNIQUE NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(255),
    state VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    qualification VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    father_name VARCHAR(255),
    mother_name VARCHAR(255),
    enrollment_date DATE NOT NULL,
    status ENUM('active', 'completed', 'dropped', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_roll_number (roll_number),
    INDEX idx_phone (phone_number),
    INDEX idx_status (status)
);

-- ============================================
-- Table: admissions
-- Stores admission application information
-- ============================================
CREATE TABLE admissions (
    admission_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id VARCHAR(50) UNIQUE NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(255),
    state VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    qualification VARCHAR(100) NOT NULL,
    course_id INT NOT NULL,
    application_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'approved', 'rejected', 'enrolled') DEFAULT 'pending',
    remarks TEXT,
    processed_by INT,
    processed_date TIMESTAMP NULL,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (processed_by) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_application_id (application_id),
    INDEX idx_status (status),
    INDEX idx_phone (phone_number)
);

-- ============================================
-- Table: enrollments
-- Links students to courses
-- ============================================
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    theory_start_date DATE,
    theory_end_date DATE,
    practical_start_date DATE,
    practical_end_date DATE,
    company_name VARCHAR(255),
    status ENUM('theory', 'practical', 'completed', 'dropped') DEFAULT 'theory',
    completion_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    INDEX idx_student_course (student_id, course_id),
    INDEX idx_status (status)
);

-- ============================================
-- Table: payments
-- Stores payment information
-- ============================================
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    enrollment_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method ENUM('cash', 'online', 'cheque', 'upi') NOT NULL,
    transaction_id VARCHAR(255),
    installment_number INT,
    total_installments INT,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'completed',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    INDEX idx_student (student_id),
    INDEX idx_payment_date (payment_date),
    INDEX idx_status (payment_status)
);

-- ============================================
-- Table: results
-- Stores student results and grades
-- ============================================
CREATE TABLE results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    enrollment_id INT NOT NULL,
    theory_marks DECIMAL(5, 2),
    practical_marks DECIMAL(5, 2),
    total_marks DECIMAL(5, 2),
    percentage DECIMAL(5, 2),
    grade VARCHAR(10),
    result_status ENUM('pass', 'fail', 'pending') DEFAULT 'pending',
    remarks TEXT,
    result_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    INDEX idx_student (student_id),
    INDEX idx_result_status (result_status)
);

-- ============================================
-- Table: certificates
-- Stores certificate information
-- ============================================
CREATE TABLE certificates (
    certificate_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    enrollment_id INT NOT NULL,
    certificate_code VARCHAR(100) UNIQUE NOT NULL,
    certificate_type ENUM('course_completion', 'experience', 'recommendation') NOT NULL,
    issue_date DATE NOT NULL,
    valid_until DATE,
    certificate_url VARCHAR(500),
    is_verified BOOLEAN DEFAULT TRUE,
    issued_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    FOREIGN KEY (issued_by) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_certificate_code (certificate_code),
    INDEX idx_student (student_id),
    INDEX idx_type (certificate_type)
);

-- ============================================
-- Table: placements
-- Stores job placement information
-- ============================================
CREATE TABLE placements (
    placement_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    enrollment_id INT NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    job_title VARCHAR(255) NOT NULL,
    salary DECIMAL(10, 2),
    joining_date DATE,
    offer_letter_url VARCHAR(500),
    placement_status ENUM('offered', 'joined', 'rejected', 'left') DEFAULT 'offered',
    location VARCHAR(255),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    INDEX idx_student (student_id),
    INDEX idx_company (company_name),
    INDEX idx_status (placement_status)
);

-- ============================================
-- Table: contact_messages
-- Stores contact form submissions
-- ============================================
CREATE TABLE contact_messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status ENUM('new', 'read', 'replied', 'closed') DEFAULT 'new',
    replied_by INT,
    reply_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (replied_by) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);

-- ============================================
-- Insert Sample Data
-- ============================================

-- Insert default admin user (password: admin123 - should be hashed in production)
INSERT INTO users (email, password_hash, full_name, phone, user_type) VALUES
('admin@affiluxa.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin User', '924115130', 'admin');

-- Insert OFT Course
INSERT INTO courses (course_code, course_name, description, duration_months, theory_duration_months, practical_duration_months, course_fee, stipend_amount, eligibility) VALUES
('OFT-001', 'Optical Fibre Technician (OFT)', 'A comprehensive 6-month program designed to make you job-ready in the optical fibre industry. This course combines theoretical knowledge with extensive hands-on practical training.', 6, 2, 4, 10000.00, 14000.00, '10th Pass');

-- ============================================
-- Useful Views
-- ============================================

-- View: Student Complete Information
CREATE VIEW vw_student_details AS
SELECT 
    s.student_id,
    s.roll_number,
    s.student_name,
    s.phone_number,
    s.email,
    s.state,
    s.qualification,
    s.status,
    e.enrollment_id,
    c.course_name,
    c.course_code,
    e.status as enrollment_status,
    r.grade,
    r.percentage,
    r.result_status
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id
LEFT JOIN results r ON s.student_id = r.student_id AND e.enrollment_id = r.enrollment_id;

-- View: Certificate Verification
CREATE VIEW vw_certificate_verification AS
SELECT 
    c.certificate_code,
    s.roll_number,
    s.student_name,
    co.course_name,
    c.certificate_type,
    c.issue_date,
    r.grade,
    c.is_verified
FROM certificates c
JOIN students s ON c.student_id = s.student_id
JOIN enrollments e ON c.enrollment_id = e.enrollment_id
JOIN courses co ON e.course_id = co.course_id
LEFT JOIN results r ON s.student_id = r.student_id AND e.enrollment_id = r.enrollment_id;

-- View: Payment Summary
CREATE VIEW vw_payment_summary AS
SELECT 
    s.student_id,
    s.roll_number,
    s.student_name,
    c.course_name,
    c.course_fee,
    COALESCE(SUM(p.amount), 0) as total_paid,
    (c.course_fee - COALESCE(SUM(p.amount), 0)) as balance
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
LEFT JOIN payments p ON s.student_id = p.student_id AND e.enrollment_id = p.enrollment_id AND p.payment_status = 'completed'
GROUP BY s.student_id, s.roll_number, s.student_name, c.course_name, c.course_fee;

-- ============================================
-- Stored Procedures
-- ============================================

-- Procedure: Generate Roll Number
DELIMITER //
CREATE PROCEDURE sp_generate_roll_number(
    IN p_course_code VARCHAR(50),
    OUT p_roll_number VARCHAR(50)
)
BEGIN
    DECLARE v_count INT;
    DECLARE v_year VARCHAR(4);
    
    SET v_year = YEAR(CURDATE());
    
    SELECT COUNT(*) INTO v_count 
    FROM students 
    WHERE roll_number LIKE CONCAT('AFF', v_year, '%');
    
    SET p_roll_number = CONCAT('AFF', v_year, LPAD(v_count + 1, 4, '0'));
END //
DELIMITER ;

-- Procedure: Verify Certificate
DELIMITER //
CREATE PROCEDURE sp_verify_certificate(
    IN p_roll_number VARCHAR(50),
    IN p_cert_code VARCHAR(100),
    OUT p_is_valid BOOLEAN,
    OUT p_student_name VARCHAR(255),
    OUT p_course_name VARCHAR(255),
    OUT p_grade VARCHAR(10),
    OUT p_issue_date DATE
)
BEGIN
    SELECT 
        c.is_verified,
        s.student_name,
        co.course_name,
        r.grade,
        c.issue_date
    INTO 
        p_is_valid,
        p_student_name,
        p_course_name,
        p_grade,
        p_issue_date
    FROM certificates c
    JOIN students s ON c.student_id = s.student_id
    JOIN enrollments e ON c.enrollment_id = e.enrollment_id
    JOIN courses co ON e.course_id = co.course_id
    LEFT JOIN results r ON s.student_id = r.student_id AND e.enrollment_id = r.enrollment_id
    WHERE s.roll_number = p_roll_number 
    AND c.certificate_code = p_cert_code
    LIMIT 1;
    
    IF p_is_valid IS NULL THEN
        SET p_is_valid = FALSE;
    END IF;
END //
DELIMITER ;

-- ============================================
-- Indexes for Performance
-- ============================================

-- Additional composite indexes for common queries
CREATE INDEX idx_enrollment_student_course ON enrollments(student_id, course_id, status);
CREATE INDEX idx_payment_student_status ON payments(student_id, payment_status);
CREATE INDEX idx_result_student_status ON results(student_id, result_status);

-- ============================================
-- End of Database Schema
-- ============================================
