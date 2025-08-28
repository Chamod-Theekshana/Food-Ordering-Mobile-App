package com.example.backend.controller;

import com.example.backend.entity.FoodItem;
import com.example.backend.entity.Category;
import com.example.backend.dto.FoodItemRequest;
import com.example.backend.repository.FoodItemRepository;
import com.example.backend.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/food")
@CrossOrigin(origins = "*")
public class FoodController {
    
    @Autowired
    private FoodItemRepository foodItemRepository;
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    @GetMapping
    public List<FoodItem> getAllFood() {
        return foodItemRepository.findByAvailableTrue();
    }
    
    @GetMapping("/search")
    public List<FoodItem> searchFood(@RequestParam String query) {
        return foodItemRepository.findByNameContainingIgnoreCaseAndAvailableTrue(query);
    }
    
    @GetMapping("/category/{categoryId}")
    public List<FoodItem> getFoodByCategory(@PathVariable Long categoryId) {
        Category category = categoryRepository.findById(categoryId).orElse(null);
        return category != null ? foodItemRepository.findByCategory(category) : List.of();
    }
    
    @GetMapping("/top-rated")
    public List<FoodItem> getTopRatedFood() {
        return foodItemRepository.findTopRatedItems();
    }
    
    @PostMapping
    public ResponseEntity<?> addFood(@Valid @RequestBody FoodItemRequest request) {
        try {
            Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found"));
            
            FoodItem foodItem = new FoodItem();
            foodItem.setName(request.getName());
            foodItem.setDescription(request.getDescription());
            foodItem.setPrice(request.getPrice());
            foodItem.setImageUrl(request.getImageUrl());
            foodItem.setCategory(category);
            foodItem.setStockQuantity(request.getStockQuantity());
            foodItem.setAvailable(request.getAvailable());
            
            return ResponseEntity.ok(foodItemRepository.save(foodItem));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error creating food item: " + e.getMessage());
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<?> updateFood(@PathVariable Long id, @Valid @RequestBody FoodItemRequest request) {
        try {
            Optional<FoodItem> existingFood = foodItemRepository.findById(id);
            if (existingFood.isPresent()) {
                Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("Category not found"));
                
                FoodItem foodItem = existingFood.get();
                foodItem.setName(request.getName());
                foodItem.setDescription(request.getDescription());
                foodItem.setPrice(request.getPrice());
                foodItem.setImageUrl(request.getImageUrl());
                foodItem.setCategory(category);
                foodItem.setStockQuantity(request.getStockQuantity());
                foodItem.setAvailable(request.getAvailable());
                
                return ResponseEntity.ok(foodItemRepository.save(foodItem));
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error updating food item: " + e.getMessage());
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteFood(@PathVariable Long id) {
        if (foodItemRepository.existsById(id)) {
            foodItemRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}