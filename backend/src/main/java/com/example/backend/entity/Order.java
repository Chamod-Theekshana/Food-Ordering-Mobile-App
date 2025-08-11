package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private User user;
    
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderItem> items;
    
    private BigDecimal totalAmount;
    
    @Enumerated(EnumType.STRING)
    private Status status = Status.PENDING;
    
    private LocalDateTime createdAt = LocalDateTime.now();
    
    public enum Status {
        PENDING, CONFIRMED, PREPARING, READY, DELIVERED, CANCELLED
    }
}