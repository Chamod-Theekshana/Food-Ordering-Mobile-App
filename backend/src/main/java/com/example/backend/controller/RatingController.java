package com.example.backend.controller;

import com.example.backend.entity.Rating;
import com.example.backend.entity.User;
import com.example.backend.entity.FoodItem;
import com.example.backend.repository.RatingRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.repository.FoodItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/ratings")
@CrossOrigin(origins = "*")
public class RatingController {
    
    @Autowired
    private RatingRepository ratingRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private FoodItemRepository foodItemRepository;
    
    @GetMapping("/food/{foodItemId}")
    public List<Rating> getFoodRatings(@PathVariable Long foodItemId) {
        FoodItem foodItem = foodItemRepository.findById(foodItemId).orElse(null);
        return foodItem != null ? ratingRepository.findByFoodItem(foodItem) : List.of();
    }
    
    @PostMapping
    public ResponseEntity<Rating> addRating(@RequestBody RatingRequest request) {
        User user = userRepository.findById(request.getUserId()).orElse(null);
        FoodItem foodItem = foodItemRepository.findById(request.getFoodItemId()).orElse(null);
        
        if (user == null || foodItem == null) {
            return ResponseEntity.badRequest().build();
        }
        
        Rating rating = ratingRepository.findByUserAndFoodItem(user, foodItem)
            .orElse(new Rating());
        
        rating.setUser(user);
        rating.setFoodItem(foodItem);
        rating.setRating(request.getRating());
        rating.setComment(request.getComment());
        
        Rating saved = ratingRepository.save(rating);
        
        // Update food item average rating
        updateFoodItemRating(foodItem);
        
        return ResponseEntity.ok(saved);
    }
    
    private void updateFoodItemRating(FoodItem foodItem) {
        Double avgRating = ratingRepository.getAverageRatingByFoodItem(foodItem);
        Integer ratingCount = ratingRepository.getRatingCountByFoodItem(foodItem);
        
        foodItem.setAverageRating(avgRating != null ? avgRating : 0.0);
        foodItem.setRatingCount(ratingCount != null ? ratingCount : 0);
        
        foodItemRepository.save(foodItem);
    }
    
    static class RatingRequest {
        private Long userId;
        private Long foodItemId;
        private Integer rating;
        private String comment;
        
        public Long getUserId() { return userId; }
        public void setUserId(Long userId) { this.userId = userId; }
        public Long getFoodItemId() { return foodItemId; }
        public void setFoodItemId(Long foodItemId) { this.foodItemId = foodItemId; }
        public Integer getRating() { return rating; }
        public void setRating(Integer rating) { this.rating = rating; }
        public String getComment() { return comment; }
        public void setComment(String comment) { this.comment = comment; }
    }
}