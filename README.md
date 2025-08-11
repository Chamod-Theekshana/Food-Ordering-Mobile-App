# Food Ordering App

A minimal food ordering application with Flutter frontend and Spring Boot backend.

## Features

### For Users:
- View restaurant menu
- Browse food items
- Add items to cart
- Place orders
- Login/Signup

### For Admin:
- Manage food items (add/edit/delete)
- View all orders
- Manage order status

## Setup

### Backend (Spring Boot)
1. Install MySQL and create database `food_ordering`
2. Update database credentials in `backend/src/main/resources/application.properties`
3. Run: `cd backend && ./mvnw spring-boot:run`

### Frontend (Flutter)
1. Install Flutter dependencies: `cd front && flutter pub get`
2. Run: `flutter run`

## Default Admin Account
Create an admin user by registering with any email and manually updating the role to 'ADMIN' in the database.

## API Endpoints
- POST `/api/auth/login` - User login
- POST `/api/auth/register` - User registration
- GET `/api/food` - Get all food items
- POST `/api/food` - Add food item (admin)
- PUT `/api/food/{id}` - Update food item (admin)
- DELETE `/api/food/{id}` - Delete food item (admin)
- POST `/api/orders` - Create order
- GET `/api/orders/user/{userId}` - Get user orders
- GET `/api/orders` - Get all orders (admin)
- PUT `/api/orders/{id}/status` - Update order status (admin)