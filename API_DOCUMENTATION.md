# GezaYo REST API & Backend Documentation

This document outlines the API endpoints, HTTP methods, headers, request structures, and response schemas implemented for the **GezaYo** mobile application backend service layer.

---

## Base URL & Headers

```
Base URL: https://api.gezayo.rw/v1
Content-Type: application/json
Authorization: Bearer <JWT_TOKEN>
```

---

## 1. Authentication Endpoints

### `POST /api/v1/auth/login`
Authenticates a user via Email and Password.

- **Request Body**:
```json
{
  "email": "user@gezayo.rw",
  "password": "password123"
}
```

- **Response (200 OK)**:
```json
{
  "statusCode": 200,
  "isSuccess": true,
  "message": "Logged in successfully.",
  "data": {
    "uid": "usr-12345",
    "fullName": "Jean-Paul N.",
    "email": "user@gezayo.rw",
    "phoneNumber": "+250 788 000 000",
    "role": "customer",
    "avatarUrl": "",
    "rating": 4.9,
    "totalDeliveries": 24,
    "isOnline": true
  }
}
```

### `POST /api/v1/auth/signup-phone`
Registers or authenticates a user using Phone OTP verification.

- **Request Body**:
```json
{
  "phoneNumber": "+250 788 000 000",
  "fullName": "Jean-Paul",
  "role": "customer"
}
```

- **Response (201 Created)**:
```json
{
  "statusCode": 201,
  "isSuccess": true,
  "message": "User registered via Phone OTP.",
  "data": {
    "uid": "usr-98765",
    "fullName": "Jean-Paul",
    "email": "788000000@gezayo.rw",
    "phoneNumber": "+250 788 000 000",
    "role": "customer",
    "rating": 5.0,
    "totalDeliveries": 0,
    "isOnline": true
  }
}
```

---

## 2. Delivery Request Endpoints

### `POST /api/v1/deliveries`
Creates a new package delivery request.

- **Request Body**:
```json
{
  "pickupAddress": "24 KN 59 St, Kigali",
  "dropoffAddress": "Mamba Club, Kimihurura",
  "packageType": "Parcel",
  "weightClass": "Light (<5kg)",
  "instructions": "Fragile items",
  "estimatedFareRwf": 2500.0
}
```

- **Response (201 Created)**:
```json
{
  "statusCode": 201,
  "isSuccess": true,
  "message": "Delivery request created.",
  "data": {
    "id": "GZ-8821",
    "pickupAddress": "24 KN 59 St, Kigali",
    "dropoffAddress": "Mamba Club, Kimihurura",
    "packageType": "Parcel",
    "weightClass": "Light (<5kg)",
    "estimatedFareRwf": 2500.0,
    "status": "searching",
    "createdAt": "2026-07-29T15:00:00Z"
  }
}
```

### `GET /api/v1/deliveries/active`
Retrieves the currently active delivery order for a customer.

- **Response (200 OK)**:
```json
{
  "statusCode": 200,
  "isSuccess": true,
  "data": {
    "id": "GZ-8821",
    "status": "onTheWay",
    "assignedRiderName": "Jean Bosco K.",
    "estimatedArrivalMins": 12
  }
}
```

### `PUT /api/v1/deliveries/:id/status`
Updates delivery status, assigned rider, tip amount, or user ratings.

- **Request Body**:
```json
{
  "status": "assigned",
  "assignedRiderName": "Jean Bosco K.",
  "assignedRiderRating": 4.9
}
```

---

## 3. Rider & Financial Ledger Endpoints

### `GET /api/v1/riders/nearby`
Fetches real-time available riders nearby in Kigali.

- **Response (200 OK)**:
```json
{
  "statusCode": 200,
  "isSuccess": true,
  "data": [
    {
      "id": "r1",
      "name": "Jean Bosco K.",
      "rating": 4.9,
      "completedJobs": 120,
      "vehicleType": "EV Motor (Eco)",
      "etaText": "3 min"
    }
  ]
}
```

### `POST /api/v1/withdrawals/momo`
Processes a instant payout withdrawal to MTN Mobile Money.

- **Request Body**:
```json
{
  "amount": 10000.0,
  "phone": "+250788000000"
}
```

- **Response (200 OK)**:
```json
{
  "statusCode": 200,
  "isSuccess": true,
  "message": "Withdrawal processed successfully.",
  "data": {
    "id": "tx-99120",
    "title": "Withdrawal to MTN MoMo",
    "amountRwf": 10000.0,
    "type": "withdrawal",
    "status": "completed"
  }
}
```
