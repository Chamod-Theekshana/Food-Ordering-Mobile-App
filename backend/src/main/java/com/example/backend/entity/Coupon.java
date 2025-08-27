package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "coupons")
public class Coupon {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String code;
    private String description;
    private BigDecimal discountAmount;
    private BigDecimal discountPercentage;
    private BigDecimal minOrderAmount;
    private LocalDateTime validFrom;
    private LocalDateTime validTo;
    private Boolean active = true;
    private Integer usageLimit;
    private Integer usedCount = 0;
}