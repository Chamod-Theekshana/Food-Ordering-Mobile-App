package com.example.backend.repository;

import com.example.backend.entity.Rating;
import com.example.backend.entity.User;
import com.example.backend.entity.FoodItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface RatingRepository extends JpaRepository<Rating, Long> {
    List<Rating> findByFoodItem(FoodItem foodItem);
    Optional<Rating> findByUserAndFoodItem(User user, FoodItem foodItem);
    
    @Query("SELECT AVG(r.rating) FROM Rating r WHERE r.foodItem = ?1")
    Double getAverageRatingByFoodItem(FoodItem foodItem);
    
    @Query("SELECT COUNT(r) FROM Rating r WHERE r.foodItem = ?1")
    Integer getRatingCountByFoodItem(FoodItem foodItem);
}