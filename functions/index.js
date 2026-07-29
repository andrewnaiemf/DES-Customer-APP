/**
 * ═══════════════════════════════════════════════════════════════════════════
 * 🚀 DES Customer - Firebase Cloud Functions
 * ═══════════════════════════════════════════════════════════════════════════
 *
 * Purpose: Automatically send FCM notifications with Live Activity data
 *          when order status changes in Firestore
 *
 * Features:
 * - ✅ Auto-trigger on order status update
 * - ✅ Send FCM with Live Activity payload
 * - ✅ Support Arabic & English
 * - ✅ Real-time tracking updates
 * - ✅ Driver assignment notifications
 *
 * Last Updated: February 1, 2026
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

// Initialize Firebase Admin
admin.initializeApp();

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Order Status Change Trigger
// ═══════════════════════════════════════════════════════════════════════════

/**
 * ═══════════════════════════════════════════════════════════════════════════
 * 📦 Order Status Change Trigger (Enhanced)
 * ═══════════════════════════════════════════════════════════════════════════
 *
 * Triggered when an order document is updated in Firestore
 * Path: /orders/{orderId}
 *
 * Features:
 * - ✅ Sends FCM with Live Activity data
 * - ✅ Supports 8-step delivery flow
 * - ✅ Logs all notifications
 * - ✅ Retry logic on failure
 */
exports.onOrderStatusChange = functions.firestore
    .document('orders/{orderId}')
    .onUpdate(async (change, context) => {
      try {
        const orderId = context.params.orderId;
        const beforeData = change.before.data();
        const afterData = change.after.data();

        console.log(`📦 Order ${orderId} updated`);
        console.log(`   Before: ${JSON.stringify(beforeData, null, 2)}`);
        console.log(`   After: ${JSON.stringify(afterData, null, 2)}`);

        // Check if status actually changed
        const statusField = 'shipping_status'; // or 'status'
        const beforeStatus = beforeData[statusField];
        const afterStatus = afterData[statusField];

        if (beforeStatus === afterStatus) {
          console.log('⏭️ Status unchanged, skipping notification');
          return null;
        }

        console.log(`📊 Status changed: ${beforeStatus} → ${afterStatus}`);

        // Get customer FCM token
        const customerId = afterData.customerId ||
                          afterData.customer_id ||
                          afterData.user_id;

        if (!customerId) {
          console.error('❌ No customer ID found in order');
          return null;
        }

        const customerDoc = await admin.firestore()
            .collection('customers')
            .doc(customerId)
            .get();

        if (!customerDoc.exists) {
          console.error(`❌ Customer ${customerId} not found`);
          return null;
        }

        const fcmToken = customerDoc.data().fcmToken ||
                        customerDoc.data().fcm_token ||
                        customerDoc.data().token;

        if (!fcmToken) {
          console.warn(`⚠️ No FCM token for customer ${customerId}`);
          return null;
        }

        console.log(`✅ FCM Token found for customer ${customerId}`);

        // Build FCM notification payload
        const notification = buildNotificationPayload(afterData, orderId);

        // Send FCM notification with retry
        let result = null;
        let attempts = 0;
        const maxAttempts = 3;

        while (attempts < maxAttempts) {
          attempts++;
          try {
            result = await sendFCMNotification(fcmToken, notification);
            console.log(`✅ Notification sent successfully on attempt ${attempts}`);

            // Log successful notification
            await admin.firestore().collection('notification_logs').add({
              orderId: orderId,
              customerId: customerId,
              status: afterStatus,
              success: true,
              attempt: attempts,
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });

            break;
          } catch (error) {
            console.error(`❌ Attempt ${attempts} failed: ${error.message}`);

            if (attempts >= maxAttempts) {
              // Log failed notification
              await admin.firestore().collection('notification_logs').add({
                orderId: orderId,
                customerId: customerId,
                status: afterStatus,
                success: false,
                error: error.message,
                attempts: attempts,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
              });

              throw error;
            }

            // Wait before retry (exponential backoff)
            await new Promise((resolve) => setTimeout(resolve, 1000 * attempts));
          }
        }

        return result;
      } catch (error) {
        console.error('❌ Error in onOrderStatusChange:', error);
        return null;
      }
    });

// ═══════════════════════════════════════════════════════════════════════════
// 🚚 Driver Assignment Trigger
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Triggered when driver is assigned to an order
 */
exports.onDriverAssigned = functions.firestore
    .document('orders/{orderId}')
    .onUpdate(async (change, context) => {
      try {
        const orderId = context.params.orderId;
        const beforeData = change.before.data();
        const afterData = change.after.data();

        // Check if driver was just assigned
        const driverBefore = beforeData.driverName || beforeData.driver_name;
        const driverAfter = afterData.driverName || afterData.driver_name;

        if (!driverBefore && driverAfter) {
          console.log(`🚚 Driver ${driverAfter} assigned to order ${orderId}`);

          // Get customer FCM token
          const customerId = afterData.customerId || afterData.customer_id;
          if (!customerId) return null;

          const customerDoc = await admin.firestore()
              .collection('customers')
              .doc(customerId)
              .get();

          if (!customerDoc.exists) return null;

          const fcmToken = customerDoc.data().fcmToken || customerDoc.data().fcm_token;
          if (!fcmToken) return null;

          // Build driver assignment notification
          const notification = {
            notification: {
              title: 'Driver Assigned',
              body: `${driverAfter} will deliver your order`,
            },
            data: buildOrderData(afterData, orderId),
          };

          await sendFCMNotification(fcmToken, notification);
          console.log(`✅ Driver assignment notification sent`);
        }

        return null;
      } catch (error) {
        console.error('❌ Error in onDriverAssigned:', error);
        return null;
      }
    });

// ═══════════════════════════════════════════════════════════════════════════
// 🔔 Manual Notification Trigger (HTTP Function)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * HTTP endpoint to manually send order notification
 *
 * POST /sendOrderNotification
 * Body: { orderId: "12345" }
 */
exports.sendOrderNotification = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  try {
    const { orderId, customerId } = req.body;

    if (!orderId || !customerId) {
      res.status(400).json({
        success: false,
        error: 'Missing orderId or customerId',
      });
      return;
    }

    // Get order data
    const orderDoc = await admin.firestore()
        .collection('orders')
        .doc(orderId)
        .get();

    if (!orderDoc.exists) {
      res.status(404).json({
        success: false,
        error: `Order ${orderId} not found`,
      });
      return;
    }

    // Get customer FCM token
    const customerDoc = await admin.firestore()
        .collection('customers')
        .doc(customerId)
        .get();

    if (!customerDoc.exists) {
      res.status(404).json({
        success: false,
        error: `Customer ${customerId} not found`,
      });
      return;
    }

    const fcmToken = customerDoc.data().fcmToken || customerDoc.data().fcm_token;
    if (!fcmToken) {
      res.status(400).json({
        success: false,
        error: 'Customer has no FCM token',
      });
      return;
    }

    // Build and send notification
    const notification = buildNotificationPayload(orderDoc.data(), orderId);
    const result = await sendFCMNotification(fcmToken, notification);

    res.status(200).json({
      success: true,
      message: 'Notification sent successfully',
      messageId: result,
    });
  } catch (error) {
    console.error('❌ Error in sendOrderNotification:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Helper Functions
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Build FCM notification payload
 */
function buildNotificationPayload(orderData, orderId) {
  const status = orderData.status || orderData.shipping_status || 'pending';
  const statusMessages = getStatusMessages(status);
  // eslint-disable-next-line no-unused-vars
  const orderReference = orderData.orderReference ||
                        orderData.order_reference ||
                        `ORD-${orderId}`;

  // Determine language (default to Arabic)
  const language = orderData.language || orderData.customer_language || 'ar';
  const isArabic = language === 'ar';

  return {
    notification: {
      title: isArabic ? statusMessages.titleAr : statusMessages.title,
      body: isArabic ? statusMessages.bodyAr : statusMessages.body,
      sound: 'default',
      badge: '1',
    },
    data: buildOrderData(orderData, orderId),
    apns: {
      headers: {
        'apns-priority': '10',
        'apns-push-type': 'alert',
      },
      payload: {
        aps: {
          'alert': {
            title: isArabic ? statusMessages.titleAr : statusMessages.title,
            body: isArabic ? statusMessages.bodyAr : statusMessages.body,
          },
          'sound': 'default',
          'badge': 1,
          'content-available': 1,
          'mutable-content': 1,
          'interruption-level': 'time-sensitive',
        },
      },
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'order_tracking_channel',
        priority: 'high',
        defaultSound: true,
        defaultVibrateTimings: true,
        visibility: 'public',
        sticky: false,
        localOnly: false,
      },
    },
  };
}

/**
 * Build order data payload for FCM
 */
function buildOrderData(orderData, orderId) {
  return {
    // Required fields
    order_id: orderId,
    order_reference: orderData.orderReference || orderData.order_reference || `ORD-${orderId}`,
    shipping_status: orderData.status || orderData.shipping_status || 'pending',

    // Optional fields
    driver_name: orderData.driverName || orderData.driver_name || '',
    driver_phone: orderData.driverPhone || orderData.driver_phone || '',
    estimated_time: orderData.estimatedTime || orderData.estimated_time || '',
    customer_address: orderData.customerAddress || orderData.customer_address || '',

    // Additional metadata
    timestamp: new Date().toISOString(),
    notification_type: 'order_update',
  };
}

/**
 * Get localized status messages (Updated with 8 steps)
 */
function getStatusMessages(status) {
  const messages = {
    // Step 1: Pending
    pending: {
      title: '⏳ Pending Confirmation',
      titleAr: '⏳ في انتظار التأكيد',
      body: 'Your order is being reviewed and will be confirmed soon',
      bodyAr: 'طلبك قيد المراجعة وسيتم تأكيده قريباً',
    },

    // Step 2: Confirmed
    confirmed: {
      title: '✅ Order Confirmed',
      titleAr: '✅ تم تأكيد الطلب',
      body: 'Your order has been confirmed and will be prepared soon',
      bodyAr: 'تم تأكيد طلبك وسيبدأ التحضير قريباً',
    },

    // Step 3: Preparing
    preparing: {
      title: '👨‍🍳 Preparing Your Order',
      titleAr: '👨‍🍳 جاري تحضير طلبك',
      body: 'Your order is being carefully prepared',
      bodyAr: 'يتم تحضير طلبك الآن بعناية',
    },

    // Step 4: Ready
    ready: {
      title: '📦 Order Ready',
      titleAr: '📦 الطلب جاهز',
      body: 'Your order is ready and waiting for driver',
      bodyAr: 'طلبك جاهز وينتظر السائق',
    },

    // Step 5: Picked Up
    picked_up: {
      title: '🚗 Driver Picked Up',
      titleAr: '🚗 السائق استلم طلبك',
      body: 'Driver has picked up your order from the store',
      bodyAr: 'السائق استلم طلبك من المتجر',
    },

    // Step 6: On The Way
    on_the_way: {
      title: '🛵 On The Way',
      titleAr: '🛵 طلبك في الطريق',
      body: 'Your order is on the way to you',
      bodyAr: 'طلبك في الطريق إليك الآن',
    },

    // Step 7: Arrived
    arrived: {
      title: '📍 Driver Arrived!',
      titleAr: '📍 السائق وصل!',
      body: 'Driver has arrived at your location!',
      bodyAr: 'السائق وصل إلى موقعك!',
    },

    // Step 8: Delivered
    delivered: {
      title: '🎉 Delivered Successfully',
      titleAr: '🎉 تم التسليم بنجاح',
      body: 'Your order has been delivered successfully. Thank you!',
      bodyAr: 'تم تسليم طلبك بنجاح. شكراً لك!',
    },

    // Cancelled
    cancelled: {
      title: '❌ Order Cancelled',
      titleAr: '❌ تم إلغاء الطلب',
      body: 'Order has been cancelled',
      bodyAr: 'تم إلغاء الطلب',
    },

    // Legacy aliases for backward compatibility
    shipped: {
      title: '🛵 On The Way',
      titleAr: '🛵 طلبك في الطريق',
      body: 'Your order is on the way to you',
      bodyAr: 'طلبك في الطريق إليك الآن',
    },
    in_transit: {
      title: '🛵 On The Way',
      titleAr: '🛵 طلبك في الطريق',
      body: 'Your order is on the way to you',
      bodyAr: 'طلبك في الطريق إليك الآن',
    },
    out_for_delivery: {
      title: '🛵 On The Way',
      titleAr: '🛵 طلبك في الطريق',
      body: 'Your order is on the way to you',
      bodyAr: 'طلبك في الطريق إليك الآن',
    },
  };

  // Normalize status for matching
  const normalizedStatus = status.toLowerCase().replace(/-/g, '_').replace(/ /g, '_');

  // Status mapping for legacy values
  const statusMapping = {
    'order_placed': 'pending',
    'orderplaced': 'pending',
    'pickedup': 'picked_up',
    'ontheway': 'on_the_way',
    'arriving': 'arrived',
  };

  const mappedStatus = statusMapping[normalizedStatus] || normalizedStatus;

  return messages[mappedStatus] || messages.pending;
}

/**
 * Send FCM notification
 */
async function sendFCMNotification(fcmToken, payload) {
  try {
    const message = {
      token: fcmToken,
      ...payload,
    };

    const response = await admin.messaging().send(message);
    console.log('✅ FCM sent successfully:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending FCM:', error);
    throw error;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Test Function (for debugging)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Test function to send sample notification
 *
 * POST /testNotification
 * Body: { fcmToken: "xxx", status: "in_transit" }
 */
exports.testNotification = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  try {
    const { fcmToken, status } = req.body;

    if (!fcmToken) {
      res.status(400).json({ error: 'fcmToken required' });
      return;
    }

    const testOrder = {
      status: status || 'in_transit',
      orderReference: 'TEST-001',
      driverName: 'أحمد محمد',
      driverPhone: '+966501234567',
      estimatedTime: '30',
      customerAddress: 'الرياض - حي النخيل',
    };

    const notification = buildNotificationPayload(testOrder, 'TEST-123');
    const result = await sendFCMNotification(fcmToken, notification);

    res.status(200).json({
      success: true,
      message: 'Test notification sent',
      messageId: result,
    });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// 🌙 RAMADAN NOTIFICATIONS - مواعيد دقيقة من Aladhan API
// ═══════════════════════════════════════════════════════════════════════════

/**
 * 🕌 جلب مواعيد الصلاة من Aladhan API (طريقة أم القرى)
 * @param {string} dateStr - التاريخ بصيغة YYYY-MM-DD
 * @returns {Promise<Object|null>} مواعيد الصلاة + بيانات التاريخ الهجري
 */
async function getPrayerTimes(dateStr) {
  try {
    const [year, month, day] = dateStr.split('-');
    const formattedDate = `${day}-${month}-${year}`;

    const response = await axios.get(
        `https://api.aladhan.com/v1/timings/${formattedDate}`, {
          params: {
            latitude: 24.7136,
            longitude: 46.6753,
            method: 4, // أم القرى (السعودية الرسمية)
            school: 0,
            timezonestring: 'Asia/Riyadh',
          },
          timeout: 10000,
        },
    );

    const timings = response.data.data.timings;
    const hijriDate = response.data.data.date.hijri;

    return {
      fajr: timings.Fajr.split(' ')[0],
      sunrise: timings.Sunrise.split(' ')[0],
      dhuhr: timings.Dhuhr.split(' ')[0],
      asr: timings.Asr.split(' ')[0],
      maghrib: timings.Maghrib.split(' ')[0],
      isha: timings.Isha.split(' ')[0],
      hijriMonth: hijriDate.month.en,
      hijriDay: hijriDate.day,
      isRamadan: hijriDate.month.number === 9,
    };
  } catch (error) {
    console.error('❌ خطأ في جلب مواعيد الصلاة:', error.message);
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🕌 إشعار الإفطار - وقت أذان المغرب بالضبط (Aladhan API)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * 💥 إشعار مدفع الإفطار - يُرسل وقت أذان المغرب بالضبط
 * يجلب وقت المغرب من Aladhan API (طريقة أم القرى)
 * يقارن الوقت الحالي بوقت المغرب - إذا تطابق يرسل الإشعار
 */
exports.sendIftarNotification = functions
    .region('europe-west1')
    .pubsub
    .schedule('* 17-19 * 2-3 *')
    .timeZone('Asia/Riyadh')
    .onRun(async (context) => {
      try {
        const now = new Date();
        const riyadhTime = new Date(
            now.toLocaleString('en-US', { timeZone: 'Asia/Riyadh' }),
        );
        const year = riyadhTime.getFullYear();
        const month = String(riyadhTime.getMonth() + 1).padStart(2, '0');
        const day = String(riyadhTime.getDate()).padStart(2, '0');
        const today = `${year}-${month}-${day}`;
        const currentHour = String(riyadhTime.getHours())
            .padStart(2, '0');
        const currentMinute = String(riyadhTime.getMinutes())
            .padStart(2, '0');
        const currentTime = `${currentHour}:${currentMinute}`;

        console.log(`🕐 الوقت الحالي (الرياض): ${currentTime}`);
        console.log(`📅 التاريخ: ${today}`);

        // ═══ جلب المواعيد من Aladhan API ═══
        const prayerTimes = await getPrayerTimes(today);

        if (!prayerTimes) {
          console.log('❌ فشل جلب المواعيد من API');
          return null;
        }

        const maghribTime = prayerTimes.maghrib;
        const hijriDay = prayerTimes.hijriDay;
        const isRamadan = prayerTimes.isRamadan;

        console.log(`✅ API: المغرب=${maghribTime}` +
            `, رمضان=${isRamadan}, يوم=${hijriDay}`);

        // ═══ التحقق: هل نحن في رمضان؟ ═══
        if (!isRamadan) {
          console.log('⚠️ ليس شهر رمضان');
          return null;
        }

        // ═══ هل حان وقت المغرب؟ ═══
        if (currentTime !== maghribTime) {
          return null;
        }

        // ═══ فحص التكرار ═══
        const logRef = admin.firestore()
            .collection('ramadan_iftar_notifications_log')
            .doc(today);
        const logDoc = await logRef.get();

        if (logDoc.exists) {
          console.log('⚠️ تم إرسال إشعار الإفطار اليوم مسبقاً');
          return null;
        }

        console.log('💥 ════════════════════════════════════════');
        console.log(`🕌 حان وقت أذان المغرب! (${maghribTime})`);
        console.log(`📅 اليوم ${hijriDay} من رمضان`);
        console.log('💥 ════════════════════════════════════════');

        // 🎯 رسالة مدفع الإفطار
        const iftarMessage = {
          topic: 'all_users',
          notification: {
            title: '💥 حان الآن وقت الإفطار وأذان المغرب 🌙',
            body: 'تقبّل الله صيامكم، رمضان مبارك\n\n' +
                  'DES Team',
          },
          data: {
            type: 'ramadan_iftar_now',
            day: hijriDay,
            maghribTime: maghribTime,
            date: today,
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            screen: 'ramadan_calendar',
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'iftar_channel',
              sound: 'default',
              priority: 'max',
              defaultVibrateTimings: true,
              notificationCount: 1,
              icon: 'ic_launcher',
            },
          },
          apns: {
            headers: {
              'apns-priority': '10',
              'apns-push-type': 'alert',
            },
            payload: {
              aps: {
                'sound': 'default',
                'badge': 1,
                'mutable-content': 1,
                'content-available': 1,
                'alert': {
                  title: '💥 حان الآن وقت الإفطار' +
                      ' وأذان المغرب 🌙',
                  body: 'تقبّل الله صيامكم، رمضان مبارك' +
                      '\n\nDES Team',
                },
              },
            },
          },
        };

        // 📤 إرسال الإشعار
        const response = await admin.messaging().send(iftarMessage);
        console.log('✅ تم إرسال إشعار الإفطار:', response);

        // 📝 تسجيل الإرسال
        await logRef.set({
          day: hijriDay,
          date: today,
          maghribTime: maghribTime,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          responseId: response,
          status: 'sent',
          type: 'iftar_now',
          source: 'aladhan_api',
        });

        console.log('📝 تم تسجيل الإرسال في Firestore');
        return null;
      } catch (error) {
        console.error('❌ خطأ في إرسال إشعار الإفطار:', error);
        return null;
      }
    });

// ═══════════════════════════════════════════════════════════════════════════
// 🧪 اختبار إشعار الإفطار (للاختبار فقط)
// ═══════════════════════════════════════════════════════════════════════════

/**
 * 🧪 إرسال إشعار إفطار تجريبي
 *
 * لجهاز واحد (بالتوكن):
 * curl "https://europe-west1-driveshield-d5a37.cloudfunctions.net/testIftarNotification?token=FCM_TOKEN"
 *
 * لجميع المستخدمين:
 * curl "https://europe-west1-driveshield-d5a37.cloudfunctions.net/testIftarNotification"
 */
exports.testIftarNotification = functions
    .region('europe-west1')
    .https
    .onRequest(async (req, res) => {
      res.set('Access-Control-Allow-Origin', '*');

      try {
        console.log('🧪 اختبار إشعار الإفطار...');

        const fcmToken = req.query.token || req.body.token;

        const notifData = {
          notification: {
            title: '💥 حان الآن وقت الإفطار وأذان المغرب 🌙',
            body: 'تقبّل الله صيامكم، رمضان مبارك\n\n' +
                  'DES Team',
          },
          data: {
            type: 'ramadan_iftar_now',
            day: '2',
            maghribTime: '17:50',
            date: '2026-02-19',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            screen: 'ramadan_calendar',
            isTest: 'true',
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'iftar_channel',
              sound: 'default',
              priority: 'max',
              defaultVibrateTimings: true,
              icon: 'ic_launcher',
            },
          },
          apns: {
            headers: {
              'apns-priority': '10',
            },
            payload: {
              aps: {
                'sound': 'default',
                'badge': 1,
                'mutable-content': 1,
                'alert': {
                  title: '💥 حان الآن وقت الإفطار' +
                      ' وأذان المغرب 🌙',
                  body: 'تقبّل الله صيامكم، رمضان مبارك' +
                      '\n\nDES Team',
                },
              },
            },
          },
        };

        let response;
        let target;

        if (fcmToken) {
          // ═══ إرسال لجهاز واحد فقط ═══
          console.log(`📱 إرسال لجهاز: ${fcmToken.substring(0, 20)}...`);
          notifData.token = fcmToken;
          response = await admin.messaging().send(notifData);
          target = 'جهاز واحد';
        } else {
          // ═══ إرسال لكل المستخدمين ═══
          console.log('📢 إرسال لجميع المستخدمين');
          notifData.topic = 'all_users';
          response = await admin.messaging().send(notifData);
          target = 'all_users topic';
        }

        res.status(200).json({
          success: true,
          message: `✅ تم إرسال إشعار الإفطار التجريبي (${target})`,
          responseId: response,
          sentTo: target,
          notificationPreview: {
            title: '💥 حان الآن وقت الإفطار وأذان المغرب 🌙',
            body: 'تقبّل الله صيامكم، رمضان مبارك\n\nDES Team',
          },
        });
      } catch (error) {
        console.error('❌ خطأ:', error);
        res.status(500).json({ error: error.message });
      }
    });

// ═══════════════════════════════════════════════════════════════════════════
// 🧪 اختبار API مواعيد الصلاة
// ═══════════════════════════════════════════════════════════════════════════

/**
 * 🧪 اختبار Aladhan API - يعرض مواعيد الصلاة لتاريخ معين
 *
 * الاستخدام:
 * curl "https://europe-west1-driveshield-d5a37.cloudfunctions.net/testPrayerTimesAPI"
 * curl "https://europe-west1-driveshield-d5a37.cloudfunctions.net/testPrayerTimesAPI?date=2026-02-19"
 */
exports.testPrayerTimesAPI = functions
    .region('europe-west1')
    .https
    .onRequest(async (req, res) => {
      res.set('Access-Control-Allow-Origin', '*');

      try {
        const now = new Date();
        const riyadhTime = new Date(
            now.toLocaleString('en-US', { timeZone: 'Asia/Riyadh' }),
        );
        const yr = riyadhTime.getFullYear();
        const mo = String(riyadhTime.getMonth() + 1).padStart(2, '0');
        const dy = String(riyadhTime.getDate()).padStart(2, '0');
        const defaultDate = `${yr}-${mo}-${dy}`;

        const testDate = req.query.date || defaultDate;
        console.log(`🧪 اختبار API لتاريخ: ${testDate}`);

        const prayerTimes = await getPrayerTimes(testDate);

        if (!prayerTimes) {
          res.status(500).json({
            error: 'فشل في جلب مواعيد الصلاة من API',
          });
          return;
        }

        // حساب وقت التذكير (قبل ساعة من المغرب)
        const [mH, mM] = prayerTimes.maghrib.split(':').map(Number);
        const rH = mH - 1 < 0 ? 23 : mH - 1;
        const reminderTime = `${String(rH).padStart(2, '0')}` +
            `:${String(mM).padStart(2, '0')}`;

        res.status(200).json({
          success: true,
          date: testDate,
          location: 'الرياض، السعودية',
          method: 'أم القرى (الطريقة السعودية الرسمية)',
          prayerTimes: {
            fajr: prayerTimes.fajr,
            sunrise: prayerTimes.sunrise,
            dhuhr: prayerTimes.dhuhr,
            asr: prayerTimes.asr,
            maghrib: prayerTimes.maghrib,
            isha: prayerTimes.isha,
          },
          hijriDate: {
            day: prayerTimes.hijriDay,
            month: prayerTimes.hijriMonth,
            isRamadan: prayerTimes.isRamadan,
          },
          notificationSchedule: {
            reminderTime: reminderTime,
            iftarTime: prayerTimes.maghrib,
          },
        });
      } catch (error) {
        console.error('❌ خطأ:', error);
        res.status(500).json({ error: error.message });
      }
    });

/**
 * 🌙 إرسال تهنئة رمضان بالعربية فوراً
 *
 * الاستخدام من المتصفح:
 * https://europe-west1-driveshield-d5a37.cloudfunctions.net/sendRamadanGreetingArabic
 *
 * يرسل الإشعار بالعربية لجميع المستخدمين، ثم يجدول الرسالة الإنجليزية بعد 30 دقيقة
 */
exports.sendRamadanGreetingArabic = functions
    .region('europe-west1')
    .https
    .onRequest(async (req, res) => {
      try {
        console.log('🌙 إرسال تهنئة رمضان بالعربية...');

        // الرسالة العربية
        const arabicMessage = {
          topic: 'all_users',
          notification: {
            title: '🌙 رمضان مبارك',
            body: 'يسرّ شركة DES أن تتقدم إليكم بأصدق التهاني والتبريكات بمناسبة حلول شهر رمضان المبارك 🌙',
          },
          data: {
            type: 'ramadan_greeting_arabic',
            screen: 'home',
            language: 'ar',
            full_message: 'يسرّ شركة DES أن تتقدم إليكم بأصدق التهاني والتبريكات ' +
              'بمناسبة حلول شهر رمضان المبارك 🌙\n\n' +
              'سائلين الله أن يجعله شهر خير وبركة عليكم، وأن يعيده عليكم بالصحة والنجاح والازدهار.\n\n' +
              'نثمّن ثقتكم وتعاونكم الدائم معنا، ونتطلع إلى استمرار شراكتنا ' +
              'وتحقيق المزيد من النجاحات معكم خلال هذا العام.\n\n' +
              'رمضان مبارك، وكل عام وأنتم بخير.\n\nDES Team',
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'high_importance_channel',
              sound: 'default',
              priority: 'max',
            },
          },
          apns: {
            headers: {
              'apns-priority': '10',
            },
            payload: {
              aps: {
                sound: 'default',
                badge: 1,
                contentAvailable: true,
              },
            },
          },
        };

        console.log('📤 إرسال الإشعار العربي...');
        const arabicResponse = await admin.messaging().send(arabicMessage);

        console.log('✅ تم إرسال الإشعار العربي بنجاح!');
        console.log(`📊 Response: ${arabicResponse}`);

        // حفظ السجل في Firestore
        const arabicLog = await admin.firestore()
            .collection('ramadan_notifications_log')
            .add({
              type: 'ramadan_greeting_arabic',
              sent_at: admin.firestore.FieldValue.serverTimestamp(),
              date: new Date().toISOString(),
              status: 'sent',
              response: arabicResponse,
              message: 'Ramadan greeting (Arabic) sent to all users',
              language: 'ar',
            });

        // جدولة الرسالة الإنجليزية بعد 30 دقيقة
        const englishScheduleTime = new Date(Date.now() + 30 * 60 * 1000); // 30 دقيقة
        console.log(`⏰ جدولة الرسالة الإنجليزية في: ${englishScheduleTime.toISOString()}`);

        await admin.firestore()
            .collection('scheduled_notifications')
            .add({
              type: 'ramadan_greeting_english',
              scheduled_time: admin.firestore.Timestamp.fromDate(englishScheduleTime),
              created_at: admin.firestore.FieldValue.serverTimestamp(),
              status: 'scheduled',
              arabic_log_id: arabicLog.id,
            });

        res.json({
          success: true,
          message: '✅ تم إرسال تهنئة رمضان بالعربية! الرسالة الإنجليزية ستُرسل بعد 30 دقيقة',
          details: {
            arabic: {
              topic: 'all_users',
              messageId: arabicResponse,
              timestamp: new Date().toISOString(),
            },
            english: {
              scheduled_for: englishScheduleTime.toISOString(),
              status: 'scheduled',
            },
          },
        });
      } catch (error) {
        console.error('❌ خطأ في إرسال الإشعار:', error);
        res.status(500).json({
          success: false,
          error: error.message,
          details: error.stack,
        });
      }
    });

/**
 * 🌙 إرسال تهنئة رمضان بالإنجليزية (مجدولة تلقائياً)
 *
 * يتم تشغيلها تلقائياً كل دقيقة للتحقق من الإشعارات المجدولة
 */
exports.sendScheduledRamadanGreeting = functions
    .region('europe-west1')
    .pubsub
    .schedule('every 1 minutes')
    .onRun(async (context) => {
      try {
        console.log('⏰ التحقق من الإشعارات المجدولة...');

        const now = admin.firestore.Timestamp.now();

        // البحث عن الإشعارات المجدولة التي حان وقتها
        const scheduledNotifications = await admin.firestore()
            .collection('scheduled_notifications')
            .where('status', '==', 'scheduled')
            .where('scheduled_time', '<=', now)
            .limit(10)
            .get();

        if (scheduledNotifications.empty) {
          console.log('✅ لا توجد إشعارات مجدولة الآن');
          return null;
        }

        console.log(`📬 وجدت ${scheduledNotifications.size} إشعارات جاهزة للإرسال`);

        for (const doc of scheduledNotifications.docs) {
          const notification = doc.data();

          if (notification.type === 'ramadan_greeting_english') {
            console.log('🇬🇧 إرسال تهنئة رمضان بالإنجليزية...');

            // الرسالة الإنجليزية
            const englishMessage = {
              topic: 'all_users',
              notification: {
                title: '🌙 Ramadan Mubarak',
                body: 'DES is delighted to extend our warmest greetings on the occasion of the Holy Month of Ramadan.',
              },
              data: {
                type: 'ramadan_greeting_english',
                screen: 'home',
                language: 'en',
                full_message: 'DES is delighted to extend our warmest greetings ' +
                  'on the occasion of the Holy Month of Ramadan.\n\n' +
                  'May this blessed month bring you prosperity, success, and continued wellbeing.\n\n' +
                  'We truly value your trust and partnership, ' +
                  'and we look forward to achieving more successes together.\n\n' +
                  'Ramadan Mubarak.',
              },
              android: {
                priority: 'high',
                notification: {
                  channelId: 'high_importance_channel',
                  sound: 'default',
                  priority: 'max',
                },
              },
              apns: {
                headers: {
                  'apns-priority': '10',
                },
                payload: {
                  aps: {
                    sound: 'default',
                    badge: 1,
                    contentAvailable: true,
                  },
                },
              },
            };

            const englishResponse = await admin.messaging().send(englishMessage);
            console.log('✅ تم إرسال الإشعار الإنجليزي!');

            // تحديث حالة الإشعار المجدول
            await doc.ref.update({
              status: 'sent',
              sent_at: admin.firestore.FieldValue.serverTimestamp(),
              response: englishResponse,
            });

            // حفظ السجل
            await admin.firestore()
                .collection('ramadan_notifications_log')
                .add({
                  type: 'ramadan_greeting_english',
                  sent_at: admin.firestore.FieldValue.serverTimestamp(),
                  date: new Date().toISOString(),
                  status: 'sent',
                  response: englishResponse,
                  message: 'Ramadan greeting (English) sent to all users',
                  language: 'en',
                  scheduled_notification_id: doc.id,
                });

            console.log(`✅ تم إرسال الإشعار المجدول: ${doc.id}`);
          }
        }

        return null;
      } catch (error) {
        console.error('❌ خطأ في إرسال الإشعارات المجدولة:', error);
        return null;
      }
    });

/**
 * 📊 مراقبة إحصائيات تهنئة رمضان المباشرة
 *
 * الاستخدام:
 * https://europe-west1-driveshield-d5a37.cloudfunctions.net/getRamadanGreetingStats
 */
exports.getRamadanGreetingStats = functions
    .region('europe-west1')
    .https
    .onRequest(async (req, res) => {
      try {
        console.log('📊 جلب إحصائيات تهنئة رمضان...');

        // جلب سجلات الإشعارات
        const logs = await admin.firestore()
            .collection('ramadan_notifications_log')
            .where('type', 'in', ['ramadan_greeting_arabic', 'ramadan_greeting_english'])
            .orderBy('sent_at', 'desc')
            .limit(10)
            .get();

        // جلب الإشعارات المجدولة
        const scheduled = await admin.firestore()
            .collection('scheduled_notifications')
            .where('type', '==', 'ramadan_greeting_english')
            .orderBy('scheduled_time', 'desc')
            .limit(5)
            .get();

        const sentLogs = logs.docs.map((doc) => {
          const data = doc.data();
          return {
            id: doc.id,
            type: data.type,
            language: data.language,
            status: data.status,
            message_id: data.response,
            sent_at: data.sent_at?.toDate().toISOString() || 'N/A',
          };
        });

        const scheduledLogs = scheduled.docs.map((doc) => {
          const data = doc.data();
          return {
            id: doc.id,
            type: data.type,
            scheduled_time: data.scheduled_time?.toDate().toISOString() || 'N/A',
            status: data.status,
            created_at: data.created_at?.toDate().toISOString() || 'N/A',
          };
        });

        // حساب الإحصائيات
        const arabicSent = sentLogs.filter((l) => l.language === 'ar').length;
        const englishSent = sentLogs.filter((l) => l.language === 'en').length;
        const pendingEnglish = scheduledLogs.filter((l) => l.status === 'scheduled').length;

        // إنشاء صفحة HTML لعرض النتائج
        const html = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📊 إحصائيات تهنئة رمضان - DES</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            background: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            margin-bottom: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        .header h1 {
            color: #667eea;
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .stat-card .icon {
            font-size: 3em;
            margin-bottom: 10px;
        }
        .stat-card .number {
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
        }
        .stat-card .label {
            color: #666;
            margin-top: 5px;
            font-size: 1.1em;
        }
        .section {
            background: white;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 20px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        .section h2 {
            color: #667eea;
            margin-bottom: 20px;
            font-size: 1.8em;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
        }
        .log-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 10px;
            border-left: 4px solid #667eea;
        }
        .log-item.arabic { border-left-color: #28a745; }
        .log-item.english { border-left-color: #007bff; }
        .log-item.scheduled { border-left-color: #ffc107; }
        .log-item .title {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
            font-size: 1.1em;
        }
        .log-item .details {
            color: #666;
            font-size: 0.9em;
        }
        .badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: bold;
            margin-left: 10px;
        }
        .badge.success { background: #28a745; color: white; }
        .badge.pending { background: #ffc107; color: #333; }
        .badge.ar { background: #28a745; color: white; }
        .badge.en { background: #007bff; color: white; }
        .refresh-btn {
            background: #667eea;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 10px;
            cursor: pointer;
            font-size: 1.1em;
            display: block;
            margin: 20px auto;
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
            transition: all 0.3s;
        }
        .refresh-btn:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 7px 20px rgba(102, 126, 234, 0.4);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌙 إحصائيات تهنئة رمضان</h1>
            <p>DES Customer Notification System</p>
            <p style="color: #999; margin-top: 10px;">آخر تحديث: ${new Date().toLocaleString('ar-EG')}</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="icon">🇸🇦</div>
                <div class="number">${arabicSent}</div>
                <div class="label">إشعار عربي مُرسل</div>
            </div>
            <div class="stat-card">
                <div class="icon">🇬🇧</div>
                <div class="number">${englishSent}</div>
                <div class="label">إشعار إنجليزي مُرسل</div>
            </div>
            <div class="stat-card">
                <div class="icon">⏰</div>
                <div class="number">${pendingEnglish}</div>
                <div class="label">إشعارات مجدولة</div>
            </div>
            <div class="stat-card">
                <div class="icon">✅</div>
                <div class="number">${arabicSent + englishSent}</div>
                <div class="label">إجمالي المُرسل</div>
            </div>
        </div>

        <div class="section">
            <h2>📤 الإشعارات المُرسلة</h2>
            ${sentLogs.length > 0 ? sentLogs.map((log) => `
                <div class="log-item ${log.language}">
                    <div class="title">
                        ${log.language === 'ar' ? '🇸🇦 تهنئة رمضان بالعربية' : '🇬🇧 Ramadan Greeting (English)'}
                        <span class="badge ${log.language}">${log.language === 'ar' ? 'عربي' : 'English'}</span>
                        <span class="badge success">مُرسل</span>
                    </div>
                    <div class="details">
                        📅 تم الإرسال: ${log.sent_at}<br>
                        🆔 Message ID: ${log.message_id}
                    </div>
                </div>
            `).join('') : '<p style="color: #999; text-align: center;">لا توجد إشعارات مُرسلة</p>'}
        </div>

        <div class="section">
            <h2>⏰ الإشعارات المجدولة</h2>
            ${scheduledLogs.length > 0 ? scheduledLogs.map((log) => `
                <div class="log-item scheduled">
                    <div class="title">
                        🇬🇧 Ramadan Greeting (English)
                        <span class="badge pending">مجدول</span>
                    </div>
                    <div class="details">
                        ⏰ موعد الإرسال: ${log.scheduled_time}<br>
                        📅 تم الجدولة: ${log.created_at}<br>
                        📊 الحالة: ${log.status === 'scheduled' ? 'في الانتظار' : 'مُرسل'}
                    </div>
                </div>
            `).join('') : '<p style="color: #999; text-align: center;">لا توجد إشعارات مجدولة</p>'}
        </div>

        <button class="refresh-btn" onclick="location.reload()">🔄 تحديث</button>
    </div>
</body>
</html>
        `;

        res.set('Content-Type', 'text/html; charset=utf-8');
        res.send(html);
      } catch (error) {
        console.error('❌ خطأ:', error);
        res.status(500).json({
          success: false,
          error: error.message,
        });
      }
    });

/**
 * 📊 Function للحصول على إحصائيات الإشعارات الرمضانية
 *
 * الاستخدام:
 * https://europe-west1-driveshield-d5a37.cloudfunctions.net/getRamadanStats
 */
exports.getRamadanStats = functions
    .region('europe-west1')
    .https
    .onRequest(async (req, res) => {
      try {
        console.log('📊 جلب إحصائيات الإشعارات الرمضانية...');

        const logs = await admin.firestore()
            .collection('ramadan_notifications_log')
            .orderBy('date', 'desc')
            .limit(50)
            .get();

        const stats = logs.docs.map((doc) => {
          const data = doc.data();
          return {
            id: doc.id,
            date: data.date,
            day: data.day,
            maghrib_time: data.maghrib_time,
            notification_time: data.notification_time,
            sent: data.success_count || 0,
            failed: data.failure_count || 0,
            status: data.status,
            sent_at: data.sent_at,
          };
        });

        const totalSent = stats.reduce((sum, s) => sum + (s.sent || 0), 0);
        const totalFailed = stats.reduce((sum, s) => sum + (s.failed || 0), 0);
        const successfulDays = stats.filter((s) => s.status === 'sent').length;

        res.json({
          success: true,
          summary: {
            total_days: stats.length,
            successful_days: successfulDays,
            total_sent: totalSent,
            total_failed: totalFailed,
            success_rate: totalSent > 0 ? ((totalSent / (totalSent + totalFailed)) * 100).toFixed(2) + '%' : '0%',
          },
          logs: stats,
        });
      } catch (error) {
        console.error('❌ خطأ:', error);
        res.status(500).json({
          success: false,
          error: error.message,
        });
      }
    });

/**
 * 📝 تسجيل استلام الإشعار من التطبيق
 *
 * يتم استدعاؤها من Flutter عندما يستلم المستخدم الإشعار
 *
 * الاستخدام من Flutter:
 * FirebaseFunctions.instance
 *   .httpsCallable('trackNotificationReceived')
 *   .call({
 *     'notification_type': 'ramadan_greeting_arabic',
 *     'user_id': userId,
 *     'timestamp': DateTime.now().toIso8601String()
 *   });
 */
exports.trackNotificationReceived = functions
    .region('europe-west1')
    .https
    .onCall(async (data, context) => {
      try {
        const userId = data.user_id || context.auth?.uid;
        const notificationType = data.notification_type;
        const timestamp = data.timestamp || new Date().toISOString();

        if (!userId) {
          throw new functions.https.HttpsError('invalid-argument', 'User ID is required');
        }

        // حفظ سجل الاستلام
        await admin.firestore()
            .collection('notification_tracking')
            .add({
              user_id: userId,
              notification_type: notificationType,
              action: 'received',
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
              client_timestamp: timestamp,
              device_info: data.device_info || {},
            });

        console.log(`✅ تم تسجيل استلام الإشعار للمستخدم: ${userId}`);

        return { success: true, message: 'Tracked successfully' };
      } catch (error) {
        console.error('❌ خطأ في تتبع الإشعار:', error);
        throw new functions.https.HttpsError('internal', error.message);
      }
    });

/**
 * 📝 تسجيل فتح الإشعار من التطبيق
 */
exports.trackNotificationOpened = functions
    .region('europe-west1')
    .https
    .onCall(async (data, context) => {
      try {
        const userId = data.user_id || context.auth?.uid;
        const notificationType = data.notification_type;

        if (!userId) {
          throw new functions.https.HttpsError('invalid-argument', 'User ID is required');
        }

        await admin.firestore()
            .collection('notification_tracking')
            .add({
              user_id: userId,
              notification_type: notificationType,
              action: 'opened',
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });

        console.log(`✅ تم تسجيل فتح الإشعار للمستخدم: ${userId}`);

        return { success: true, message: 'Tracked successfully' };
      } catch (error) {
        console.error('❌ خطأ:', error);
        throw new functions.https.HttpsError('internal', error.message);
      }
    });

/**
 * 📊 إحصائيات تفصيلية لمن استلم الإشعار
 */
exports.getNotificationTrackingStats = functions
    .region('europe-west1')
    .https
    .onRequest(async (req, res) => {
      try {
        const notificationType = req.query.type || 'ramadan_greeting_arabic';

        // جلب كل من استلم الإشعار
        const received = await admin.firestore()
            .collection('notification_tracking')
            .where('notification_type', '==', notificationType)
            .where('action', '==', 'received')
            .get();

        // جلب كل من فتح الإشعار
        const opened = await admin.firestore()
            .collection('notification_tracking')
            .where('notification_type', '==', notificationType)
            .where('action', '==', 'opened')
            .get();

        // جلب معلومات المستخدمين
        const receivedUsers = await Promise.all(
            received.docs.slice(0, 100).map(async (doc) => {
              const data = doc.data();
              const userDoc = await admin.firestore()
                  .collection('customers')
                  .doc(data.user_id)
                  .get();

              const userData = userDoc.exists ? userDoc.data() : {};

              return {
                user_id: data.user_id,
                name: userData.name || userData.full_name || 'غير معروف',
                phone: userData.phone || 'N/A',
                received_at: data.timestamp?.toDate().toISOString() || 'N/A',
              };
            }),
        );

        const openedUserIds = new Set(opened.docs.map((doc) => doc.data().user_id));

        const html = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📊 تتبع من استلم الإشعار - DES</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        .container { max-width: 1400px; margin: 0 auto; }
        .header {
            background: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            margin-bottom: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        .header h1 { color: #667eea; font-size: 2.5em; margin-bottom: 10px; }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            text-align: center;
        }
        .stat-card .icon { font-size: 3em; margin-bottom: 10px; }
        .stat-card .number { font-size: 2.5em; font-weight: bold; color: #667eea; }
        .stat-card .label { color: #666; margin-top: 5px; font-size: 1.1em; }
        .section {
            background: white;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 20px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        .section h2 { color: #667eea; margin-bottom: 20px; font-size: 1.8em; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        th, td {
            padding: 12px;
            text-align: right;
            border-bottom: 1px solid #ddd;
        }
        th {
            background: #667eea;
            color: white;
            font-weight: bold;
        }
        tr:hover { background: #f8f9fa; }
        .badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: bold;
        }
        .badge.received { background: #28a745; color: white; }
        .badge.opened { background: #007bff; color: white; }
        .badge.not-opened { background: #ffc107; color: #333; }
        .refresh-btn {
            background: #667eea;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 10px;
            cursor: pointer;
            font-size: 1.1em;
            display: block;
            margin: 20px auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 تتبع من استلم إشعار رمضان</h1>
            <p>آخر تحديث: ${new Date().toLocaleString('ar-EG')}</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="icon">📱</div>
                <div class="number">${received.size}</div>
                <div class="label">استلموا الإشعار</div>
            </div>
            <div class="stat-card">
                <div class="icon">👁️</div>
                <div class="number">${opened.size}</div>
                <div class="label">فتحوا الإشعار</div>
            </div>
            <div class="stat-card">
                <div class="icon">📊</div>
                <div class="number">${received.size > 0 ? ((opened.size / received.size) * 100).toFixed(1) : 0}%</div>
                <div class="label">معدل الفتح</div>
            </div>
        </div>

        <div class="section">
            <h2>👥 قائمة المستخدمين (أول 100)</h2>
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>الاسم</th>
                        <th>رقم الهاتف</th>
                        <th>وقت الاستلام</th>
                        <th>الحالة</th>
                    </tr>
                </thead>
                <tbody>
                    ${receivedUsers.map((user, index) => `
                        <tr>
                            <td>${index + 1}</td>
                            <td>${user.name}</td>
                            <td>${user.phone}</td>
                            <td>${user.received_at}</td>
                            <td>
                                <span class="badge received">استلم</span>
                                ${openedUserIds.has(user.user_id) ?
                                '<span class="badge opened">فتح</span>' :
                                '<span class="badge not-opened">لم يفتح</span>'}
                            </td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
            ${receivedUsers.length === 0 ?
                '<p style="text-align: center; color: #999; margin-top: 20px;">لا توجد بيانات بعد. ' +
                'يجب إضافة كود التتبع في التطبيق أولاً.</p>' : ''}
        </div>

        <button class="refresh-btn" onclick="location.reload()">🔄 تحديث</button>
    </div>
</body>
</html>
        `;

        res.set('Content-Type', 'text/html; charset=utf-8');
        res.send(html);
      } catch (error) {
        console.error('❌ خطأ:', error);
        res.status(500).send('Error: ' + error.message);
      }
    });

console.log('🚀 Firebase Functions initialized successfully!');
console.log('🌙 Ramadan notification system ready!');

// ═══════════════════════════════════════════════════════════════════════════
// 📲 App Update Notification - إشعار تحديث التطبيق
// ═══════════════════════════════════════════════════════════════════════════

/**
 * إرسال إشعار لجميع المستخدمين عند نزول تحديث جديد
 *
 * الاستخدام:
 * curl -X POST \
 *   "https://europe-west1-driveshield-d5a37.cloudfunctions.net/sendAppUpdateNotification" \
 *   -H "Content-Type: application/json" \
 *   -d '{"version":"2.1.0","featuresAr":"تحسينات","featuresEn":"Improvements"}'
 */
exports.sendAppUpdateNotification = functions
    .region('europe-west1')
    .https.onRequest(async (req, res) => {
      try {
        // CORS
        res.set('Access-Control-Allow-Origin', '*');
        if (req.method === 'OPTIONS') {
          res.set('Access-Control-Allow-Methods', 'POST');
          res.set('Access-Control-Allow-Headers', 'Content-Type');
          res.status(204).send('');
          return;
        }

        if (req.method !== 'POST') {
          res.status(405).send({ error: 'Method not allowed. Use POST.' });
          return;
        }

        const { version, featuresAr: featAr, featuresEn: featEn } = req.body;

        if (!version) {
          res.status(400).send({ error: 'version is required' });
          return;
        }

        console.log('📲 ════════════════════════════════════════════');
        console.log(`📲 إرسال إشعار تحديث التطبيق - النسخة: ${version}`);
        console.log('📲 ════════════════════════════════════════════');

        const featuresAr = featAr || 'تحسينات وإصلاحات جديدة';
        const featuresEn = featEn || 'New improvements and fixes';

        // 🔥 إشعار عربي (الأساسي لأن أغلب المستخدمين عرب)
        const notificationPayload = {
          notification: {
            title: `🚀 تحديث جديد متاح - v${version}`,
            body: `📲 ${featuresAr}\nحدّث التطبيق الآن للحصول على أحدث الميزات!`,
            sound: 'default',
            badge: '1',
          },
          data: {
            type: 'app_update',
            version: version,
            features_ar: featuresAr,
            features_en: featuresEn,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            android_store_url: 'https://play.google.com/store/apps/details?id=com.DES.DESUserApp',
            ios_store_url: 'https://apps.apple.com/app/des/id6476924627',
          },
        };

        // 🎯 إرسال لجميع المستخدمين
        const topic = 'all_users';
        const response = await admin.messaging().sendToTopic(topic, notificationPayload);

        console.log('✅ ════════════════════════════════════════════');
        console.log(`✅ تم إرسال إشعار التحديث بنجاح!`);
        console.log(`📊 النسخة: ${version}`);
        console.log(`📊 نجاح: ${response.successCount} | فشل: ${response.failureCount}`);
        console.log('✅ ════════════════════════════════════════════');

        // 📝 حفظ سجل
        await admin.firestore().collection('app_update_notifications_log').add({
          version: version,
          features_ar: featuresAr,
          features_en: featuresEn,
          sent_at: admin.firestore.FieldValue.serverTimestamp(),
          success_count: response.successCount,
          failure_count: response.failureCount,
          status: 'sent',
          topic: topic,
        });

        res.status(200).send({
          success: true,
          message: `تم إرسال إشعار التحديث v${version} لجميع المستخدمين`,
          sent: response.successCount,
          failed: response.failureCount,
        });
      } catch (error) {
        console.error('❌ خطأ في إرسال إشعار التحديث:', error);

        try {
          await admin.firestore().collection('app_update_notifications_log').add({
            sent_at: admin.firestore.FieldValue.serverTimestamp(),
            status: 'failed',
            error: error.message,
          });
        } catch (logError) {
          console.error('❌ فشل حفظ سجل الخطأ:', logError);
        }

        res.status(500).send({ error: error.message });
      }
    });

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Diagnostic Function - تشخيص مشاكل الإشعارات
// ═══════════════════════════════════════════════════════════════════════════

/**
 * يعرض تقرير شامل عن حالة الإشعارات والمستخدمين
 *
 * الاستخدام:
 * curl "https://europe-west1-driveshield-d5a37.cloudfunctions.net/diagnoseNotifications"
 */
exports.diagnoseNotifications = functions
    .region('europe-west1')
    .https
    .onRequest(async (req, res) => {
      res.set('Access-Control-Allow-Origin', '*');

      try {
        // 1. عدد المستخدمين الذين لديهم FCM Token
        const customersSnapshot = await admin.firestore()
            .collection('customers')
            .get();

        let totalCustomers = 0;
        let withToken = 0;
        let withoutToken = 0;
        let androidUsers = 0;
        let iosUsers = 0;
        let staleTokens = 0;

        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const usersWithoutTokens = [];

        customersSnapshot.forEach((doc) => {
          totalCustomers++;
          const data = doc.data();
          const fcmToken = data.fcmToken || data.fcm_token || data.token;

          if (fcmToken) {
            withToken++;
            if (data.platform === 'android') androidUsers++;
            else if (data.platform === 'ios') iosUsers++;

            const lastUpdate = data.lastTokenUpdate?.toDate();
            if (lastUpdate && lastUpdate < thirtyDaysAgo) {
              staleTokens++;
            }
          } else {
            withoutToken++;
            usersWithoutTokens.push({
              id: doc.id,
              name: data.name || data.customerName || 'Unknown',
            });
          }
        });

        // 2. آخر إشعار مُرسل
        const lastNotification = await admin.firestore()
            .collection('ramadan_notifications_log')
            .orderBy('sent_at', 'desc')
            .limit(1)
            .get();

        let lastNotifInfo = null;
        if (!lastNotification.empty) {
          const data = lastNotification.docs[0].data();
          lastNotifInfo = {
            date: data.date,
            success_count: data.success_count,
            failure_count: data.failure_count,
            sent_at: data.sent_at?.toDate(),
          };
        }

        // 3. آخر إشعار تحديث
        const lastUpdateNotif = await admin.firestore()
            .collection('app_update_notifications_log')
            .orderBy('sent_at', 'desc')
            .limit(1)
            .get();

        let lastUpdateInfo = null;
        if (!lastUpdateNotif.empty) {
          const data = lastUpdateNotif.docs[0].data();
          lastUpdateInfo = {
            version: data.version,
            success_count: data.success_count,
            failure_count: data.failure_count,
            sent_at: data.sent_at?.toDate(),
          };
        }

        const report = {
          timestamp: new Date().toISOString(),
          summary: {
            total_customers: totalCustomers,
            with_fcm_token: withToken,
            without_fcm_token: withoutToken,
            coverage_percentage: totalCustomers > 0 ?
                ((withToken / totalCustomers) * 100).toFixed(1) + '%' :
                '0%',
          },
          platform_breakdown: {
            android: androidUsers,
            ios: iosUsers,
            unknown: withToken - androidUsers - iosUsers,
          },
          token_health: {
            fresh_tokens: withToken - staleTokens,
            stale_tokens_30_days: staleTokens,
          },
          users_without_tokens: usersWithoutTokens.slice(0, 20),
          last_general_notification: lastNotifInfo,
          last_update_notification: lastUpdateInfo,
          recommendations: [],
        };

        if (withoutToken > 0) {
          report.recommendations.push(
              `⚠️ ${withoutToken} users have no FCM token - they need to open the app`,
          );
        }
        if (staleTokens > 0) {
          report.recommendations.push(
              `⚠️ ${staleTokens} users have tokens older than 30 days - may be inactive`,
          );
        }
        if (withToken === 0) {
          report.recommendations.push(
              '❌ No users have FCM tokens! Make sure the app saves tokens to Firestore',
          );
        }

        res.status(200).json(report);
      } catch (error) {
        res.status(500).json({ error: error.message });
      }
    });
