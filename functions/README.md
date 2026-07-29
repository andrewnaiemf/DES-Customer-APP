# 🔥 Firebase Cloud Functions - DES Customer

Automatic FCM notifications with Live Activity support for order tracking.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Deploy to Firebase
firebase deploy --only functions

# Watch logs
firebase functions:log --follow
```

## 📋 Functions Overview

### 1. `onOrderStatusChange` (Firestore Trigger)
- **Trigger:** When order status changes in Firestore
- **Action:** Automatically sends FCM notification to customer
- **Path:** `/orders/{orderId}`

### 2. `onDriverAssigned` (Firestore Trigger)
- **Trigger:** When driver is assigned to order
- **Action:** Sends driver info notification
- **Path:** `/orders/{orderId}`

### 3. `sendOrderNotification` (HTTP Endpoint)
- **Method:** POST
- **Body:** `{ orderId, customerId }`
- **Use:** Manually trigger notification

### 4. `testNotification` (HTTP Endpoint)
- **Method:** POST
- **Body:** `{ fcmToken, status }`
- **Use:** Quick testing

## 📦 Required Firestore Structure

### Collection: `orders`
```json
{
  "orderId": "12345",
  "customerId": "customer_123",
  "status": "in_transit",
  "orderReference": "ORD-001",
  "driverName": "أحمد محمد",
  "driverPhone": "+966501234567",
  "estimatedTime": "30",
  "customerAddress": "الرياض"
}
```

### Collection: `customers`
```json
{
  "customerId": "customer_123",
  "fcmToken": "fcm_token_here",
  "name": "محمد أحمد"
}
```

## 🔔 Supported Status Values

- `pending` - Order placed
- `confirmed` - Order confirmed
- `preparing` - Being prepared
- `ready` - Ready for pickup
- `shipped` - Shipped
- `in_transit` - In transit
- `out_for_delivery` - Out for delivery
- `delivered` - Delivered
- `cancelled` - Cancelled

## 🧪 Testing

### Test with curl:
```bash
curl -X POST \
  https://YOUR-REGION-driveshield-d5a37.cloudfunctions.net/testNotification \
  -H 'Content-Type: application/json' \
  -d '{
    "fcmToken": "YOUR_FCM_TOKEN",
    "status": "in_transit"
  }'
```

### Test with Firestore:
1. Open Firebase Console
2. Go to Firestore
3. Update any order's `status` field
4. Notification sent automatically! ✅

## 📊 Monitoring

```bash
# View logs
firebase functions:log

# Follow logs in real-time
firebase functions:log --follow

# View specific function logs
firebase functions:log --only onOrderStatusChange
```

## 💰 Pricing

**Free Tier (Spark Plan):**
- 2M invocations/month
- 400,000 GB-seconds
- 200,000 CPU-seconds

Your app will stay free unless you have millions of orders!

## 📚 Documentation

- Full guide: `../FIREBASE_FUNCTIONS_GUIDE_AR.md`
- Examples: `examples.js`
- FCM Guide: `../FCM_LIVE_ACTIVITY_GUIDE.md`

## 🔧 Development

```bash
# Run locally with emulator
firebase emulators:start --only functions

# Run linter
npm run lint

# View function URLs
firebase functions:list
```

## ✅ Checklist

- [x] Functions deployed
- [x] Firestore triggers configured
- [x] FCM tokens saved in customers collection
- [x] Test notification sent successfully
- [ ] Monitor logs for errors
- [ ] Update status in production order
- [ ] Verify Live Activity appears on device

---

**Last Updated:** February 1, 2026  
**Status:** ✅ Production Ready
