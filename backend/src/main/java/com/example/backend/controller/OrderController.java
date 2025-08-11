package com.example.backend.controller;

import com.example.backend.entity.Order;
import com.example.backend.entity.OrderItem;
import com.example.backend.entity.User;
import com.example.backend.repository.OrderRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.repository.FoodItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private FoodItemRepository foodItemRepository;
    
    @PostMapping
    public ResponseEntity<Order> createOrder(@RequestBody OrderRequest request) {
        User user = userRepository.findById(request.getUserId()).orElse(null);
        if (user == null) return ResponseEntity.badRequest().build();
        
        Order order = new Order();
        order.setUser(user);
        
        BigDecimal total = BigDecimal.ZERO;
        for (OrderItem item : request.getItems()) {
            item.setOrder(order);
            total = total.add(item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
        }
        
        order.setItems(request.getItems());
        order.setTotalAmount(total);
        
        return ResponseEntity.ok(orderRepository.save(order));
    }
    
    @GetMapping("/user/{userId}")
    public List<Order> getUserOrders(@PathVariable Long userId) {
        User user = userRepository.findById(userId).orElse(null);
        return user != null ? orderRepository.findByUserOrderByCreatedAtDesc(user) : List.of();
    }
    
    @GetMapping
    public List<Order> getAllOrders() {
        return orderRepository.findAllByOrderByCreatedAtDesc();
    }
    
    @PutMapping("/{id}/status")
    public ResponseEntity<Order> updateOrderStatus(@PathVariable Long id, @RequestBody StatusRequest request) {
        Order order = orderRepository.findById(id).orElse(null);
        if (order != null) {
            order.setStatus(request.getStatus());
            return ResponseEntity.ok(orderRepository.save(order));
        }
        return ResponseEntity.notFound().build();
    }
    
    static class OrderRequest {
        private Long userId;
        private List<OrderItem> items;
        
        public Long getUserId() { return userId; }
        public void setUserId(Long userId) { this.userId = userId; }
        public List<OrderItem> getItems() { return items; }
        public void setItems(List<OrderItem> items) { this.items = items; }
    }
    
    static class StatusRequest {
        private Order.Status status;
        
        public Order.Status getStatus() { return status; }
        public void setStatus(Order.Status status) { this.status = status; }
    }
}