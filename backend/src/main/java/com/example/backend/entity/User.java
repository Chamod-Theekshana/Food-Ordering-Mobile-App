package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true)
    private String email;
    
    private String password;
    private String name;
    
    @Enumerated(EnumType.STRING)
    private Role role = Role.USER;
    
    public enum Role {
        USER, ADMIN
    }
}