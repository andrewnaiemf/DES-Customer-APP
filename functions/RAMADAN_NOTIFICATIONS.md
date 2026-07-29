# 🌙 نظام الإشعارات الرمضانية - رمضان 2026

نظام تلقائي لإرسال إشعارات FCM يومية لجميع مستخدمي التطبيق قبل ساعة من أذان المغرب طوال شهر رمضان.

## 📅 معلومات رمضان 2026

- **بداية رمضان**: 18 فبراير 2026 (1 رمضان 1447 هـ)
- **نهاية رمضان**: 19 مارس 2026 (30 رمضان 1447 هـ)
- **عدد الأيام**: 30 يوم
- **المدينة**: الرياض، المملكة العربية السعودية

## 🏗️ البنية التقنية

### الملفات:

1. **`ramadan_schedule_2026.js`** - جدول مواعيد أذان المغرب (30 يوم)
2. **`index.js`** - Cloud Functions للإشعارات
3. **`setup_scheduler.js`** - سكريبت إنشاء Cloud Scheduler Jobs

### Cloud Functions:

- `sendDailyRamadanNotification` - إرسال الإشعار اليومي
- `testRamadanNotification` - اختبار الإشعار
- `getRamadanStats` - إحصائيات الإشعارات

## 🚀 التنفيذ السريع

### 1️⃣ المتطلبات

```bash
# تثبيت Firebase CLI
npm install -g firebase-tools

# تسجيل الدخول
firebase login

# تفعيل Cloud Scheduler API
gcloud services enable cloudscheduler.googleapis.com
```

### 2️⃣ نشر Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

### 3️⃣ إنشاء Cloud Scheduler Jobs

```bash
# إنشاء جميع الـ 30 job
node setup_scheduler.js setup

# أو ببساطة:
node setup_scheduler.js
```

### 4️⃣ التحقق

افتح [Cloud Scheduler Console](https://console.cloud.google.com/cloudscheduler?project=driveshield-d5a37)

يجب أن ترى 30 job:
- `ramadan-2026-day-01`
- `ramadan-2026-day-02`
- ...
- `ramadan-2026-day-30`

## 🧪 الاختبار

### اختبار إشعار تجريبي:

```bash
# عبر curl
curl -X POST https://europe-west1-driveshield-d5a37.cloudfunctions.net/testRamadanNotification

# عبر Firebase Console
firebase functions:shell
testRamadanNotification()
```

### اختبار Cloud Scheduler Job:

```bash
# اختبار اليوم الأول
node setup_scheduler.js test 1

# اختبار أي يوم آخر
node setup_scheduler.js test 15
```

### عرض الإحصائيات:

```bash
# في المتصفح
open https://europe-west1-driveshield-d5a37.cloudfunctions.net/getRamadanStats

# أو عبر curl
curl https://europe-west1-driveshield-d5a37.cloudfunctions.net/getRamadanStats
```

## 📊 مراقبة النظام

### 1. Firebase Console Logs

```bash
firebase functions:log --only sendDailyRamadanNotification
```

### 2. Firestore Logs Collection

البيانات المحفوظة في: `ramadan_notifications_log`

```javascript
{
  date: "2026-02-18",
  day: 1,
  maghrib_time: "17:54",
  notification_time: "16:54",
  sent_at: Timestamp,
  success_count: 1250,
  failure_count: 5,
  status: "sent"
}
```

### 3. Cloud Scheduler Console

[عرض جميع Jobs](https://console.cloud.google.com/cloudscheduler?project=driveshield-d5a37)

## 🛠️ الأوامر المفيدة

### إدارة Scheduler Jobs:

```bash
# إنشاء جميع Jobs
node setup_scheduler.js setup

# حذف جميع Jobs (للتنظيف)
node setup_scheduler.js delete

# اختبار job محدد
node setup_scheduler.js test 1

# عرض المساعدة
node setup_scheduler.js help
```

### إدارة Cloud Functions:

```bash
# نشر فقط Ramadan functions
firebase deploy --only functions:sendDailyRamadanNotification,functions:testRamadanNotification,functions:getRamadanStats

# عرض logs
firebase functions:log

# حذف function
firebase functions:delete sendDailyRamadanNotification
```

## 📱 إعداد التطبيق (Flutter)

### 1. الاشتراك في Topic

يجب أن يشترك كل مستخدم في topic "all_users":

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> subscribeToRamadanNotifications() async {
  await FirebaseMessaging.instance.subscribeToTopic('all_users');
  print('✅ تم الاشتراك في إشعارات رمضان');
}
```

### 2. إنشاء Notification Channel (Android)

```dart
const AndroidNotificationChannel ramadanChannel = AndroidNotificationChannel(
  'ramadan_notifications',
  'Ramadan Reminders',
  description: 'Daily reminders before Iftar time',
  importance: Importance.high,
  sound: RawResourceAndroidNotificationSound('notification_sound'),
);
```

### 3. معالجة الإشعار

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (message.data['type'] == 'ramadan_iftar_reminder') {
    // عرض الإشعار
    // التنقل إلى صفحة رمضان
  }
});
```

## 💰 التكلفة المتوقعة

| الخدمة | الاستخدام | التكلفة |
|--------|----------|---------|
| Cloud Functions | 30 invocations | $0.00 |
| Cloud Scheduler | 30 jobs × 30 days = 900 executions | ~$0.90 |
| FCM Messages | ~30,000 messages | $0.00 |
| Firestore Operations | ~60 writes | $0.00 |
| **الإجمالي** | | **~$1.00** |

## ⚠️ نصائح مهمة

### ✅ يُنصح به:

1. ✅ اختبر النظام قبل رمضان بأسبوع
2. ✅ راقب Logs يومياً أول 3 أيام
3. ✅ احتفظ بنسخة احتياطية من الجداول
4. ✅ أضف monitoring alerts
5. ✅ اختبر على devices حقيقية

### ❌ تجنب:

1. ❌ لا تعدل المواعيد يدوياً بعد النشر
2. ❌ لا تحذف Jobs أثناء رمضان
3. ❌ لا ترسل إشعارات متكررة (spam)
4. ❌ لا تنسى تحديث التوقيت حسب رؤية الهلال

## 🔧 استكشاف الأخطاء

### المشكلة: لم يتم إرسال الإشعار

**الحلول:**
1. تحقق من Cloud Scheduler Job status
2. افحص Firebase Functions logs
3. تأكد من وجود مستخدمين في topic "all_users"
4. تحقق من صلاحيات FCM

### المشكلة: الوقت غير صحيح

**الحلول:**
1. تحقق من timezone في Cloud Scheduler
2. تأكد من التاريخ في `ramadan_schedule_2026.js`
3. راجع CRON expression

### المشكلة: فشل إنشاء Jobs

**الحلول:**
```bash
# تأكد من تفعيل API
gcloud services enable cloudscheduler.googleapis.com

# تأكد من الصلاحيات
gcloud auth login

# تأكد من المشروع
gcloud config set project driveshield-d5a37
```

## 📞 الدعم

للأسئلة أو المشاكل:
1. تحقق من Firebase Console Logs
2. راجع Firestore collection: `ramadan_notifications_log`
3. افحص Cloud Scheduler Jobs status

## 🎉 رمضان كريم!

تم تصميم هذا النظام بعناية لخدمة مستخدمي التطبيق في شهر رمضان المبارك.

تقبل الله منا ومنكم صالح الأعمال 🤲

---

**آخر تحديث**: 17 فبراير 2026  
**الإصدار**: 1.0.0  
**الحالة**: جاهز للنشر 🚀
