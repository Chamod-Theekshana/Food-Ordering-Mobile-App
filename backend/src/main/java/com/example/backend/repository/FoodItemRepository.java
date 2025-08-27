package com.example.backend.repository;

import com.example.backend.entity.FoodItem;
import com.example.backend.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface FoodItemRepository extends JpaRepository<FoodItem, Long> {
    List<FoodItem> findByAvailableTrue();
    List<FoodItem> findByCategory(Category category);
    List<FoodItem> findByNameContainingIgnoreCaseAndAvailableTrue(String name);
    
    @Query("SELECT f FROM FoodItem f WHERE f.available = true ORDER BY f.averageRating DESC")
    List<FoodItem> findTopRatedItems();
}