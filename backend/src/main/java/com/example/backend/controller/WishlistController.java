package com.example.backend.controller;

import com.example.backend.entity.Wishlist;
import com.example.backend.entity.User;
import com.example.backend.entity.FoodItem;
import com.example.backend.repository.WishlistRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.repository.FoodItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/wishlist")
@CrossOrigin(origins = "*")
public class WishlistController {
    
    @Autowired
    private WishlistRepository wishlistRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private FoodItemRepository foodItemRepository;
    
    @GetMapping("/user/{userId}")
    public List<Wishlist> getUserWishlist(@PathVariable Long userId) {
        User user = userRepository.findById(userId).orElse(null);
        return user != null ? wishlistRepository.findByUser(user) : List.of();
    }
    
    @PostMapping
    public ResponseEntity<Wishlist> addToWishlist(@RequestBody WishlistRequest request) {
        User user = userRepository.findById(request.getUserId()).orElse(null);
        FoodItem foodItem = foodItemRepository.findById(request.getFoodItemId()).orElse(null);
        
        if (user == null || foodItem == null) {
            return ResponseEntity.badRequest().build();
        }
        
        if (wishlistRepository.findByUserAndFoodItem(user, foodItem).isPresent()) {
            return ResponseEntity.badRequest().build(); // Already in wishlist
        }
        
        Wishlist wishlist = new Wishlist();
        wishlist.setUser(user);
        wishlist.setFoodItem(foodItem);
        
        return ResponseEntity.ok(wishlistRepository.save(wishlist));
    }
    
    @DeleteMapping("/user/{userId}/item/{foodItemId}")
    public ResponseEntity<?> removeFromWishlist(@PathVariable Long userId, @PathVariable Long foodItemId) {
        User user = userRepository.findById(userId).orElse(null);
        FoodItem foodItem = foodItemRepository.findById(foodItemId).orElse(null);
        
        if (user != null && foodItem != null) {
            wishlistRepository.deleteByUserAndFoodItem(user, foodItem);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
    
    static class WishlistRequest {
        private Long userId;
        private Long foodItemId;
        
        public Long getUserId() { return userId; }
        public void setUserId(Long userId) { this.userId = userId; }
        public Long getFoodItemId() { return foodItemId; }
        public void setFoodItemId(Long foodItemId) { this.foodItemId = foodItemId; }
    }
}