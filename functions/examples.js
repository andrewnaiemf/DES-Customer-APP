/**
 * ═══════════════════════════════════════════════════════════════════════════
 * 📋 Examples: How to Update Orders in Firestore
 * ═══════════════════════════════════════════════════════════════════════════
 *
 * هذا الملف يحتوي على أمثلة لكيفية تحديث الطلبات في Firestore
 * من Admin Panel أو Backend API
 */

const admin = require('firebase-admin');

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 تهيئة Firebase Admin (في ملفك الخاص)
// ═══════════════════════════════════════════════════════════════════════════

// في Node.js Backend
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ═══════════════════════════════════════════════════════════════════════════
// 📝 مثال 1: تحديث حالة الطلب (سيُرسل إشعار تلقائياً)
// ═══════════════════════════════════════════════════════════════════════════

async function updateOrderStatus(orderId, newStatus) {
  try {
    await db.collection('orders').doc(orderId).update({
      status: newStatus,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ Order ${orderId} updated to ${newStatus}`);
    console.log('📱 Notification will be sent automatically!');
  } catch (error) {
    console.error('Error updating order:', error);
  }
}

// استخدام:
// updateOrderStatus('12345', 'in_transit');

// ═══════════════════════════════════════════════════════════════════════════
// 📝 مثال 2: تعيين مندوب توصيل
// ═══════════════════════════════════════════════════════════════════════════

async function assignDriver(orderId, driverData) {
  try {
    await db.collection('orders').doc(orderId).update({
      driverName: driverData.name,
      driverPhone: driverData.phone,
      status: 'out_for_delivery',
      assignedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ Driver ${driverData.name} assigned to order ${orderId}`);
    console.log('📱 Customer will receive notification with driver info!');
  } catch (error) {
    console.error('Error assigning driver:', error);
  }
}

// استخدام:
// assignDriver('12345', {
//   name: 'أحمد محمد',
//   phone: '+966501234567'
// });

// ═══════════════════════════════════════════════════════════════════════════
// 📝 مثال 3: تحديث كامل للطلب مع كل التفاصيل
// ═══════════════════════════════════════════════════════════════════════════

async function updateOrderComplete(orderId, updates) {
  try {
    const updateData = {
      ...updates,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection('orders').doc(orderId).update(updateData);

    console.log(`✅ Order ${orderId} updated successfully`);
    console.log('Updated fields:', Object.keys(updates).join(', '));
  } catch (error) {
    console.error('Error updating order:', error);
  }
}

// استخدام:
// updateOrderComplete('12345', {
//   status: 'in_transit',
//   driverName: 'أحمد محمد',
//   driverPhone: '+966501234567',
//   estimatedTime: '30',
//   customerAddress: 'الرياض - حي النخيل'
// });

// ═══════════════════════════════════════════════════════════════════════════
// 📝 مثال 4: إنشاء طلب جديد
// ═══════════════════════════════════════════════════════════════════════════

async function createNewOrder(customerId, orderData) {
  try {
    const orderRef = db.collection('orders').doc();
    const orderId = orderRef.id;

    const newOrder = {
      orderId: orderId,
      orderReference: orderData.reference || `ORD-${Date.now()}`,
      customerId: customerId,
      status: 'pending',

      // بيانات الطلب
      items: orderData.items || [],
      totalAmount: orderData.totalAmount || 0,

      // عنوان التوصيل
      customerAddress: orderData.address || '',

      // تواريخ
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await orderRef.set(newOrder);

    console.log(`✅ New order created: ${orderId}`);
    console.log(`📱 Customer will receive confirmation notification`);

    return orderId;
  } catch (error) {
    console.error('Error creating order:', error);
    throw error;
  }
}

// استخدام:
// const newOrderId = await createNewOrder('customer_123', {
//   reference: 'ORD-2024-001',
//   items: [
//     { name: 'Product 1', quantity: 2, price: 50 },
//     { name: 'Product 2', quantity: 1, price: 100 }
//   ],
//   totalAmount: 200,
//   address: 'الرياض - حي النخيل'
// });

// ═══════════════════════════════════════════════════════════════════════════
// 📝 مثال 5: Express.js API Endpoint
// ═══════════════════════════════════════════════════════════════════════════

const express = require('express');
const app = express();
app.use(express.json());

// POST /api/orders/:orderId/status
app.post('/api/orders/:orderId/status', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;

    // التحقق من الحالة
    const validStatuses = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'shipped',
      'in_transit',
      'out_for_delivery',
      'delivered',
      'cancelled',
    ];

    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid status',
      });
    }

    // تحديث الطلب
    await db.collection('orders').doc(orderId).update({
      status: status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      success: true,
      message: 'Order status updated',
      orderId: orderId,
      newStatus: status,
    });

    console.log(`✅ Order ${orderId} updated via API to ${status}`);
    console.log('📱 Notification sent automatically via Cloud Function');
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// POST /api/orders/:orderId/driver
app.post('/api/orders/:orderId/driver', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { driverName, driverPhone, estimatedTime } = req.body;

    await db.collection('orders').doc(orderId).update({
      driverName: driverName,
      driverPhone: driverPhone,
      estimatedTime: estimatedTime,
      status: 'out_for_delivery',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      success: true,
      message: 'Driver assigned successfully',
    });

    console.log(`✅ Driver assigned to order ${orderId}`);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// app.listen(3000, () => {
//   console.log('API server running on port 3000');
// });

// ═══════════════════════════════════════════════════════════════════════════
// 📝 مثال 6: Batch Update (تحديث عدة طلبات)
// ═══════════════════════════════════════════════════════════════════════════

async function batchUpdateOrders(orderIds, newStatus) {
  try {
    const batch = db.batch();

    orderIds.forEach((orderId) => {
      const orderRef = db.collection('orders').doc(orderId);
      batch.update(orderRef, {
        status: newStatus,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();

    console.log(`✅ ${orderIds.length} orders updated to ${newStatus}`);
    console.log('📱 Notifications sent to all customers!');
  } catch (error) {
    console.error('Error in batch update:', error);
  }
}

// استخدام:
// batchUpdateOrders(['12345', '12346', '12347'], 'shipped');

// ═══════════════════════════════════════════════════════════════════════════
// 📝 مثال 7: Scheduled Status Update (تحديث مجدول)
// ═══════════════════════════════════════════════════════════════════════════

async function scheduleStatusUpdate(orderId, newStatus, delayMinutes) {
  try {
    const updateTime = new Date();
    updateTime.setMinutes(updateTime.getMinutes() + delayMinutes);

    // حفظ التحديث المجدول
    await db.collection('scheduled_updates').add({
      orderId: orderId,
      newStatus: newStatus,
      scheduledTime: updateTime,
      executed: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`📅 Scheduled update for order ${orderId}`);
    console.log(`Will change to ${newStatus} at ${updateTime}`);

    // ملاحظة: تحتاج Cloud Function منفصلة لتنفيذ التحديثات المجدولة
  } catch (error) {
    console.error('Error scheduling update:', error);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📝 مثال 8: Get Order and Send Manual Notification
// ═══════════════════════════════════════════════════════════════════════════

async function sendManualNotification(orderId) {
  try {
    // Get order data
    const orderDoc = await db.collection('orders').doc(orderId).get();

    if (!orderDoc.exists) {
      console.error('Order not found');
      return;
    }

    const orderData = orderDoc.data();

    // Get customer FCM token
    const customerDoc = await db.collection('customers')
        .doc(orderData.customerId)
        .get();

    if (!customerDoc.exists) {
      console.error('Customer not found');
      return;
    }

    const fcmToken = customerDoc.data().fcmToken;

    if (!fcmToken) {
      console.error('No FCM token');
      return;
    }

    // Send notification
    const message = {
      token: fcmToken,
      notification: {
        title: 'Order Update',
        body: `Your order is ${orderData.status}`,
      },
      data: {
        order_id: orderId,
        shipping_status: orderData.status,
        order_reference: orderData.orderReference,
      },
    };

    const response = await admin.messaging().send(message);
    console.log('✅ Notification sent:', response);
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📝 Export Functions
// ═══════════════════════════════════════════════════════════════════════════

module.exports = {
  updateOrderStatus,
  assignDriver,
  updateOrderComplete,
  createNewOrder,
  batchUpdateOrders,
  scheduleStatusUpdate,
  sendManualNotification,
};

// ═══════════════════════════════════════════════════════════════════════════
// 📚 Usage Examples Summary
// ═══════════════════════════════════════════════════════════════════════════

/*

1. تحديث حالة بسيط:
   updateOrderStatus('12345', 'in_transit');

2. تعيين مندوب:
   assignDriver('12345', {
     name: 'أحمد محمد',
     phone: '+966501234567'
   });

3. تحديث كامل:
   updateOrderComplete('12345', {
     status: 'delivered',
     deliveredAt: new Date(),
     notes: 'تم التسليم بنجاح'
   });

4. إنشاء طلب جديد:
   const orderId = await createNewOrder('customer_123', {
     reference: 'ORD-001',
     items: [...],
     totalAmount: 200
   });

5. تحديث دفعة:
   batchUpdateOrders(['id1', 'id2', 'id3'], 'shipped');

النتيجة: إشعار FCM يُرسل تلقائياً! ✅

*/
