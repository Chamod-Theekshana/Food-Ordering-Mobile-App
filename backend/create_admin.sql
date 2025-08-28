-- Create admin user directly in database
INSERT INTO users (email, password, name, role, active, created_at) 
VALUES (
    'admin@foodapp.com', 
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: 'admin123'
    'System Administrator', 
    'ADMIN', 
    true, 
    NOW()
);