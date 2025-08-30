@echo off
echo Testing Backend Endpoints...
echo.

echo Testing Categories Admin Endpoint:
curl -X GET "http://localhost:8080/api/categories/admin" -H "Content-Type: application/json"
echo.
echo.

echo Testing Food Admin Endpoint:
curl -X GET "http://localhost:8080/api/food/admin" -H "Content-Type: application/json"
echo.
echo.

echo Testing Orders Endpoint:
curl -X GET "http://localhost:8080/api/orders" -H "Content-Type: application/json"
echo.
echo.

echo Testing Dashboard Stats Endpoint:
curl -X GET "http://localhost:8080/api/reports/dashboard" -H "Content-Type: application/json"
echo.
echo.

echo Testing Regular Categories Endpoint:
curl -X GET "http://localhost:8080/api/categories" -H "Content-Type: application/json"
echo.
echo.

pause