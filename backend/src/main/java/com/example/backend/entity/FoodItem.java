package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;

@Entity
@Data
@Table(name = "food_items")
public class FoodItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    private String description;
    private BigDecimal price;
    private String imageUrl;
    
    @ManyToOne
    private Category category;
    
    private Boolean available = true;
    private Integer stockQuantity = 0;
    private Double averageRating = 0.0;
    private Integer ratingCount = 0;
}