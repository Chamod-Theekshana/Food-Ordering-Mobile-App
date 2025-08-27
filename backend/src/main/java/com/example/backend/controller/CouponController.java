package com.example.backend.controller;

import com.example.backend.entity.Coupon;
import com.example.backend.repository.CouponRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/coupons")
@CrossOrigin(origins = "*")
public class CouponController {
    
    @Autowired
    private CouponRepository couponRepository;
    
    @GetMapping
    public List<Coupon> getAllCoupons() {
        return couponRepository.findByActiveTrue();
    }
    
    @PostMapping("/validate")
    public ResponseEntity<?> validateCoupon(@RequestBody CouponValidationRequest request) {
        Optional<Coupon> coupon = couponRepository.findByCodeAndActiveTrue(request.getCode());
        
        if (coupon.isEmpty()) {
            return ResponseEntity.badRequest().body("Invalid coupon code");
        }
        
        Coupon c = coupon.get();
        LocalDateTime now = LocalDateTime.now();
        
        if (c.getValidFrom() != null && now.isBefore(c.getValidFrom())) {
            return ResponseEntity.badRequest().body("Coupon not yet valid");
        }
        
        if (c.getValidTo() != null && now.isAfter(c.getValidTo())) {
            return ResponseEntity.badRequest().body("Coupon expired");
        }
        
        if (c.getUsageLimit() != null && c.getUsedCount() >= c.getUsageLimit()) {
            return ResponseEntity.badRequest().body("Coupon usage limit exceeded");
        }
        
        return ResponseEntity.ok(c);
    }
    
    @PostMapping
    public Coupon addCoupon(@RequestBody Coupon coupon) {
        return couponRepository.save(coupon);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Coupon> updateCoupon(@PathVariable Long id, @RequestBody Coupon coupon) {
        if (couponRepository.existsById(id)) {
            coupon.setId(id);
            return ResponseEntity.ok(couponRepository.save(coupon));
        }
        return ResponseEntity.notFound().build();
    }
    
    static class CouponValidationRequest {
        private String code;
        
        public String getCode() { return code; }
        public void setCode(String code) { this.code = code; }
    }
}