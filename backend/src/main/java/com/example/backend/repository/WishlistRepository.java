package com.example.backend.repository;

import com.example.backend.entity.Wishlist;
import com.example.backend.entity.User;
import com.example.backend.entity.FoodItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface WishlistRepository extends JpaRepository<Wishlist, Long> {
    List<Wishlist> findByUser(User user);
    Optional<Wishlist> findByUserAndFoodItem(User user, FoodItem foodItem);
    void deleteByUserAndFoodItem(User user, FoodItem foodItem);
}