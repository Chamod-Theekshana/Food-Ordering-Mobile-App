# Food Ordering App

A comprehensive food ordering application with Flutter frontend and Spring Boot backend, featuring modern UI, advanced functionality, and robust security.

## 🚀 Features

### 🔹 User Features

**Menu & Browsing:**
- Browse menu by categories (Starters, Main Course, Drinks, Desserts)
- Search items by name or keyword with real-time filtering
- View detailed food information with ratings and reviews
- Top-rated items showcase
- Beautiful card-based UI with images

**Shopping & Orders:**
- Advanced cart management with quantity updates
- Apply discount coupons and promo codes
- Multiple order options: Delivery or Takeaway
- Order tracking with real-time status updates (Pending → Preparing → Ready → Delivered)
- Comprehensive order history with reorder functionality

**Payment & Delivery:**
- Multiple payment options: Cash on Delivery (COD) & Online Payment
- Delivery address management
- Special instructions for orders

**User Experience:**
- Complete user profile management (name, email, phone, address)
- Wishlist/Favorites for loved dishes
- Ratings & feedback system for food items
- Push notifications for order updates and offers
- Modern, intuitive UI with smooth animations

### 🔹 Admin Features (Restaurant Owner/Manager)

**Dashboard & Analytics:**
- Comprehensive admin dashboard with key metrics
- Daily sales reports and statistics
- Real-time order monitoring
- Customer analytics

**Menu Management:**
- Complete menu management (Add/Edit/Delete items)
- Category management with images
- Price and stock quantity updates
- Item availability toggle
- Bulk operations support

**Order Management:**
- View all orders with detailed information
- Update order status in real-time
- Customer information access
- Order filtering and search

**Customer & Marketing:**
- Customer management and order history
- Discount & coupon management
- Promotional campaigns
- Review and rating monitoring

**Content Management:**
- Image upload for dishes
- Category organization
- Menu customization

## 🛠️ Technical Stack

### Backend (Spring Boot)
- **Framework:** Spring Boot 3.2.0
- **Security:** Spring Security with BCrypt password hashing
- **Database:** MySQL with JPA/Hibernate
- **Validation:** Jakarta Bean Validation
- **Architecture:** RESTful API with proper error handling

### Frontend (Flutter)
- **Framework:** Flutter with Material Design 3
- **State Management:** Provider pattern
- **HTTP Client:** Dart HTTP package
- **UI Components:** Custom widgets with modern design
- **Navigation:** Named routes with proper navigation flow

### Database Schema
- **Users:** Enhanced with profile fields and security
- **Categories:** Hierarchical menu organization
- **Food Items:** Rich metadata with ratings and stock
- **Orders:** Complete order lifecycle management
- **Coupons:** Flexible discount system
- **Ratings:** User feedback and review system
- **Wishlist:** User favorites management

## 🚀 Setup Instructions

### Prerequisites
- Java 21+
- MySQL 8.0+
- Flutter 3.7.2+
- Maven 3.6+

### Backend Setup
1. **Database Setup:**
   ```sql
   CREATE DATABASE food_ordering;
   CREATE USER 'food_user'@'localhost' IDENTIFIED BY 'your_password';
   GRANT ALL PRIVILEGES ON food_ordering.* TO 'food_user'@'localhost';
   ```

2. **Configuration:**
   Update `backend/src/main/resources/application.properties`:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/food_ordering
   spring.datasource.username=food_user
   spring.datasource.password=your_password
   ```

3. **Run Backend:**
   ```bash
   cd backend
   ./mvnw spring-boot:run
   ```

### Frontend Setup
1. **Install Dependencies:**
   ```bash
   cd front
   flutter pub get
   ```

2. **Run Application:**
   ```bash
   flutter run
   ```

## 📱 Application Screenshots

### User Interface
- **Home Screen:** Category-based browsing with search
- **Food Details:** Rich product information with reviews
- **Cart:** Advanced cart management with coupons
- **Checkout:** Multiple payment and delivery options
- **Profile:** Complete user profile management
- **Order History:** Detailed order tracking

### Admin Interface
- **Dashboard:** Comprehensive analytics and metrics
- **Menu Management:** Full CRUD operations for food items
- **Order Management:** Real-time order processing
- **Category Management:** Organize menu structure

## 🔐 Security Features

- **Password Security:** BCrypt hashing with salt
- **Input Validation:** Comprehensive server-side validation
- **SQL Injection Protection:** JPA/Hibernate ORM
- **CORS Configuration:** Proper cross-origin setup
- **Error Handling:** Secure error messages

## 📊 API Documentation

### Authentication
- `POST /api/auth/login` - User login with validation
- `POST /api/auth/register` - User registration with password hashing

### Categories
- `GET /api/categories` - Get all active categories
- `POST /api/categories` - Create new category (admin)
- `PUT /api/categories/{id}` - Update category (admin)
- `DELETE /api/categories/{id}` - Delete category (admin)

### Food Items
- `GET /api/food` - Get all available food items
- `GET /api/food/search?query={query}` - Search food items
- `GET /api/food/category/{categoryId}` - Get items by category
- `GET /api/food/top-rated` - Get top-rated items
- `POST /api/food` - Add food item (admin)
- `PUT /api/food/{id}` - Update food item (admin)
- `DELETE /api/food/{id}` - Delete food item (admin)

### Orders
- `POST /api/orders` - Create order with delivery options
- `GET /api/orders/user/{userId}` - Get user order history
- `GET /api/orders` - Get all orders (admin)
- `PUT /api/orders/{id}/status` - Update order status (admin)

### Coupons
- `GET /api/coupons` - Get active coupons
- `POST /api/coupons/validate` - Validate coupon code
- `POST /api/coupons` - Create coupon (admin)
- `PUT /api/coupons/{id}` - Update coupon (admin)

### Wishlist
- `GET /api/wishlist/user/{userId}` - Get user wishlist
- `POST /api/wishlist` - Add item to wishlist
- `DELETE /api/wishlist/user/{userId}/item/{itemId}` - Remove from wishlist

### Ratings
- `GET /api/ratings/food/{foodItemId}` - Get food ratings
- `POST /api/ratings` - Add/update rating

### Reports
- `GET /api/reports/dashboard` - Get dashboard statistics

## 🎨 UI/UX Features

- **Modern Design:** Material Design 3 with custom theming
- **Responsive Layout:** Optimized for different screen sizes
- **Smooth Animations:** Engaging user interactions
- **Intuitive Navigation:** Easy-to-use interface
- **Visual Feedback:** Loading states and success/error messages
- **Accessibility:** Screen reader support and proper contrast

## 🚀 Future Enhancements

- **Real-time Notifications:** WebSocket integration
- **Payment Gateway:** Stripe/PayPal integration
- **GPS Tracking:** Real-time delivery tracking
- **Multi-language Support:** Internationalization
- **Dark Mode:** Theme switching capability
- **Social Features:** Share favorites and reviews
- **Loyalty Program:** Points and rewards system

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Support

For support and questions, please open an issue in the GitHub repository.

---

**Built with ❤️ using Flutter and Spring Boot**