package com.example.backend.config;

import com.example.backend.entity.User;
import com.example.backend.entity.Category;
import com.example.backend.entity.FoodItem;
import com.example.backend.repository.UserRepository;
import com.example.backend.repository.CategoryRepository;
import com.example.backend.repository.FoodItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import java.math.BigDecimal;

@Component
public class DataInitializer implements CommandLineRunner {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    @Autowired
    private FoodItemRepository foodItemRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Override
    public void run(String... args) throws Exception {
        // Create default admin if none exists
        if (!userRepository.existsByRole(User.Role.ADMIN)) {
            User admin = new User();
            admin.setEmail("admin@foodapp.com");
            admin.setName("System Administrator");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRole(User.Role.ADMIN);
            
            userRepository.save(admin);
            System.out.println("Default admin created: admin@foodapp.com / admin123");
        }
        
        // Create sample categories if none exist
        if (categoryRepository.count() == 0) {
            Category starters = new Category();
            starters.setName("Starters");
            starters.setDescription("Appetizers and small plates");
            starters.setActive(true);
            categoryRepository.save(starters);
            
            Category mains = new Category();
            mains.setName("Main Course");
            mains.setDescription("Main dishes and entrees");
            mains.setActive(true);
            categoryRepository.save(mains);
            
            Category drinks = new Category();
            drinks.setName("Drinks");
            drinks.setDescription("Beverages and refreshments");
            drinks.setActive(true);
            categoryRepository.save(drinks);
            
            Category desserts = new Category();
            desserts.setName("Desserts");
            desserts.setDescription("Sweet treats and desserts");
            desserts.setActive(true);
            categoryRepository.save(desserts);
            
            System.out.println("Sample categories created");
            
            // Create sample food items
            FoodItem pizza = new FoodItem();
            pizza.setName("Margherita Pizza");
            pizza.setDescription("Classic pizza with tomato, mozzarella, and basil");
            pizza.setPrice(new BigDecimal("12.99"));
            pizza.setCategory(mains);
            pizza.setAvailable(true);
            pizza.setStockQuantity(50);
            pizza.setAverageRating(4.5);
            pizza.setRatingCount(25);
            foodItemRepository.save(pizza);
            
            FoodItem burger = new FoodItem();
            burger.setName("Classic Burger");
            burger.setDescription("Beef patty with lettuce, tomato, and cheese");
            burger.setPrice(new BigDecimal("9.99"));
            burger.setCategory(mains);
            burger.setAvailable(true);
            burger.setStockQuantity(30);
            burger.setAverageRating(4.2);
            burger.setRatingCount(18);
            foodItemRepository.save(burger);
            
            FoodItem salad = new FoodItem();
            salad.setName("Caesar Salad");
            salad.setDescription("Fresh romaine lettuce with caesar dressing");
            salad.setPrice(new BigDecimal("7.99"));
            salad.setCategory(starters);
            salad.setAvailable(true);
            salad.setStockQuantity(25);
            salad.setAverageRating(4.0);
            salad.setRatingCount(12);
            foodItemRepository.save(salad);
            
            FoodItem coke = new FoodItem();
            coke.setName("Coca Cola");
            coke.setDescription("Refreshing cola drink");
            coke.setPrice(new BigDecimal("2.99"));
            coke.setCategory(drinks);
            coke.setAvailable(true);
            coke.setStockQuantity(100);
            coke.setAverageRating(4.3);
            coke.setRatingCount(45);
            foodItemRepository.save(coke);
            
            FoodItem cake = new FoodItem();
            cake.setName("Chocolate Cake");
            cake.setDescription("Rich chocolate cake with frosting");
            cake.setPrice(new BigDecimal("5.99"));
            cake.setCategory(desserts);
            cake.setAvailable(true);
            cake.setStockQuantity(15);
            cake.setAverageRating(4.7);
            cake.setRatingCount(22);
            foodItemRepository.save(cake);
            
            System.out.println("Sample food items created");
        }
    }
}