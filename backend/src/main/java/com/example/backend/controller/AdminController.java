package com.example.backend.controller;

import com.example.backend.entity.User;
import com.example.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @PostMapping("/create-first-admin")
    public ResponseEntity<?> createFirstAdmin(@RequestBody AdminRequest request) {
        // Only allow if no admin exists
        if (userRepository.existsByRole(User.Role.ADMIN)) {
            return ResponseEntity.badRequest().body("Admin already exists");
        }
        
        User admin = new User();
        admin.setEmail(request.getEmail());
        admin.setName(request.getName());
        admin.setPassword(passwordEncoder.encode(request.getPassword()));
        admin.setRole(User.Role.ADMIN);
        
        return ResponseEntity.ok(userRepository.save(admin));
    }
    
    static class AdminRequest {
        private String email;
        private String password;
        private String name;
        
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
    }
}