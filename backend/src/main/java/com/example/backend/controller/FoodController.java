package com.example.backend.controller;

import com.example.backend.entity.FoodItem;
import com.example.backend.repository.FoodItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/food")
@CrossOrigin(origins = "*")
public class FoodController {
    
    @Autowired
    private FoodItemRepository foodItemRepository;
    
    @GetMapping
    public List<FoodItem> getAllFood() {
        return foodItemRepository.findByAvailableTrue();
    }
    
    @PostMapping
    public FoodItem addFood(@RequestBody FoodItem foodItem) {
        return foodItemRepository.save(foodItem);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<FoodItem> updateFood(@PathVariable Long id, @RequestBody FoodItem foodItem) {
        if (foodItemRepository.existsById(id)) {
            foodItem.setId(id);
            return ResponseEntity.ok(foodItemRepository.save(foodItem));
        }
        return ResponseEntity.notFound().build();
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