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
    
    private BigDecimal subtotal;
    private BigDecimal discountAmount = BigDecimal.ZERO;
    private BigDecimal totalAmount;
    
    @ManyToOne
    private Coupon coupon;
    
    @Enumerated(EnumType.STRING)
    private Status status = Status.PENDING;
    
    @Enumerated(EnumType.STRING)
    private OrderType orderType = OrderType.DELIVERY;
    
    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod = PaymentMethod.COD;
    
    private String deliveryAddress;
    private String notes;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public enum Status {
        PENDING, CONFIRMED, PREPARING, READY, DELIVERED, CANCELLED
    }
    
    public enum OrderType {
        DELIVERY, TAKEAWAY
    }
    
    public enum PaymentMethod {
        COD, ONLINE
    }
}