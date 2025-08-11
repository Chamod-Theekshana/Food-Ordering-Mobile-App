package com.example.backend.repository;

import com.example.backend.entity.FoodItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface FoodItemRepository extends JpaRepository<FoodItem, Long> {
    List<FoodItem> findByAvailableTrue();
    List<FoodItem> findByCategory(String category);
}