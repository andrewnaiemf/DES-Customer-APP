# 🚀 خطوات النشر النهائية - نظام الإشعارات الرمضانية

## ✅ ما تم إنجازه حتى الآن:

- ✅ إنشاء `ramadan_schedule_2026.js` (جدول كامل 30 يوم)
- ✅ إضافة Cloud Functions في `index.js`:
  - `sendDailyRamadanNotification`
  - `testRamadanNotification`
  - `getRamadanStats`
- ✅ إنشاء `setup_scheduler.js` (لإنشاء Cloud Scheduler Jobs)
- ✅ توثيق كامل في `RAMADAN_NOTIFICATIONS.md`
- ✅ تثبيت Dependencies

## 🔐 مشكلة الصلاحيات الحالية:

```
Error: Missing permissions required for functions deploy.
You must have permission iam.serviceAccounts.ActAs
```

---

## 📋 الخطوات المتبقية للنشر:

### **الخطوة 1: إصلاح الصلاحيات (يحتاج Owner)**

يجب على صاحب المشروع منحك صلاحية "Service Account User":

1. افتح: https://console.cloud.google.com/iam-admin/iam?project=driveshield-d5a37
2. ابحث عن حسابك
3. أضف Role: **"Service Account User"**
4. احفظ التغييرات

**أو عبر Terminal:**
```bash
gcloud projects add-iam-policy-binding driveshield-d5a37 \
  --member="user:YOUR_EMAIL@gmail.com" \
  --role="roles/iam.serviceAccountUser"
```

---

### **الخطوة 2: نشر Cloud Functions** ⏳

بعد إصلاح الصلاحيات:

```bash
cd /Users/omnianeil/Documents/Des/DES-Customer

# نشر Ramadan Functions فقط
firebase deploy --only functions:sendDailyRamadanNotification,functions:testRamadanNotification,functions:getRamadanStats

# أو نشر جميع Functions
firebase deploy --only functions
```

**الوقت المتوقع:** 3-5 دقائق

---

### **الخطوة 3: اختبار الإشعار** 🧪

```bash
# اختبار 1: استدعاء Function مباشرة
curl -X POST https://europe-west1-driveshield-d5a37.cloudfunctions.net/testRamadanNotification

# اختبار 2: عبر Firebase Console
firebase functions:shell
> testRamadanNotification()

# اختبار 3: التحقق من Logs
firebase functions:log --only testRamadanNotification
```

**المتوقع:** 
- رسالة نجاح: `"success": true`
- إشعار يصل للتطبيق على الجهاز

---

### **الخطوة 4: تفعيل Cloud Scheduler API** ⚙️

```bash
# تفعيل API
gcloud services enable cloudscheduler.googleapis.com

# التحقق من التفعيل
gcloud services list --enabled | grep scheduler
```

---

### **الخطوة 5: إنشاء Cloud Scheduler Jobs (30 job)** 📅

```bash
cd /Users/omnianeil/Documents/Des/DES-Customer/functions

# إنشاء جميع الـ 30 job
node setup_scheduler.js setup
```

**الوقت المتوقع:** 2-3 دقائق

**المتوقع:**
```
🌙 إعداد Cloud Scheduler Jobs لرمضان 2026
📅 [1/30] إنشاء Job لليوم 1 (2026-02-18 16:54)...
   ✅ تم إنشاء: ramadan-2026-day-01
📅 [2/30] إنشاء Job لليوم 2 (2026-02-19 16:55)...
   ✅ تم إنشاء: ramadan-2026-day-02
...
✅ نجح: 30
```

---

### **الخطوة 6: التحقق من Jobs** ✅

#### طريقة 1: Cloud Console
افتح: https://console.cloud.google.com/cloudscheduler?project=driveshield-d5a37

يجب أن ترى:
- `ramadan-2026-day-01` → Schedule: `54 16 18 02 *`
- `ramadan-2026-day-02` → Schedule: `55 16 19 02 *`
- ...
- `ramadan-2026-day-30` → Schedule: `23 17 19 03 *`

#### طريقة 2: CLI
```bash
gcloud scheduler jobs list --location=europe-west1 | grep ramadan
```

---

### **الخطوة 7: اختبار Job يدوياً** 🧪

```bash
# اختبار اليوم الأول
node setup_scheduler.js test 1

# أو عبر gcloud مباشرة
gcloud scheduler jobs run ramadan-2026-day-01 --location=europe-west1
```

**المتوقع:**
1. تشغيل Cloud Function
2. إرسال إشعار لجميع المستخدمين في topic "all_users"
3. حفظ log في Firestore collection: `ramadan_notifications_log`

---

### **الخطوة 8: مراقبة النظام** 📊

#### 1. عرض Logs في الوقت الفعلي:
```bash
firebase functions:log --only sendDailyRamadanNotification
```

#### 2. عرض الإحصائيات:
```bash
curl https://europe-west1-driveshield-d5a37.cloudfunctions.net/getRamadanStats
```

#### 3. فحص Firestore:
افتح Firebase Console → Firestore → Collection: `ramadan_notifications_log`

---

## 🔄 الخطوات اليومية (تلقائي)

بعد الإعداد الكامل، النظام سيعمل تلقائياً:

1. **الساعة 16:54 (اليوم الأول - 18 فبراير)**
   - Cloud Scheduler يطلق Job: `ramadan-2026-day-01`
   - Job يستدعي Cloud Function: `sendDailyRamadanNotification`
   - Function يرسل FCM notification لـ topic: "all_users"
   - جميع المستخدمين يستلمون إشعار

2. **الساعة 16:55 (اليوم الثاني - 19 فبراير)**
   - نفس العملية...

3. **... وهكذا لمدة 30 يوم**

---

## 📱 إعداد التطبيق (Flutter)

### الكود المطلوب في التطبيق:

```dart
// في ملف main.dart أو app initialization

import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> setupRamadanNotifications() async {
  // 1. الاشتراك في topic "all_users"
  await FirebaseMessaging.instance.subscribeToTopic('all_users');
  print('✅ تم الاشتراك في إشعارات رمضان');

  // 2. معالجة الإشعار عند وصوله
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('🌙 إشعار رمضاني: ${message.notification?.title}');
    
    if (message.data['type'] == 'ramadan_iftar_reminder') {
      // عرض الإشعار
      // أو التنقل إلى صفحة رمضان
      Navigator.pushNamed(context, '/ramadan_calendar');
    }
  });

  // 3. معالجة النقر على الإشعار
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data['type'] == 'ramadan_iftar_reminder') {
      Navigator.pushNamed(context, '/ramadan_calendar');
    }
  });
}
```

---

## ✅ Checklist النشر النهائي

- [ ] **إصلاح الصلاحيات** (Owner يضيف Service Account User role)
- [ ] **نشر Cloud Functions** (`firebase deploy --only functions`)
- [ ] **اختبار testRamadanNotification** (curl أو Firebase shell)
- [ ] **تفعيل Cloud Scheduler API** (`gcloud services enable`)
- [ ] **إنشاء 30 Cloud Scheduler Jobs** (`node setup_scheduler.js`)
- [ ] **التحقق من Jobs** (Cloud Console أو gcloud CLI)
- [ ] **اختبار job يدوياً** (`node setup_scheduler.js test 1`)
- [ ] **إضافة كود الاشتراك في Flutter** (subscribeToTopic)
- [ ] **اختبار الإشعار على device حقيقي**
- [ ] **مراقبة Logs أول 3 أيام**

---

## 🎯 الأوامر السريعة (Quick Reference)

```bash
# 1. نشر Functions
firebase deploy --only functions:sendDailyRamadanNotification,functions:testRamadanNotification,functions:getRamadanStats

# 2. تفعيل Cloud Scheduler
gcloud services enable cloudscheduler.googleapis.com

# 3. إنشاء جميع Jobs
cd functions && node setup_scheduler.js

# 4. اختبار إشعار
curl -X POST https://europe-west1-driveshield-d5a37.cloudfunctions.net/testRamadanNotification

# 5. عرض الإحصائيات
curl https://europe-west1-driveshield-d5a37.cloudfunctions.net/getRamadanStats

# 6. مراقبة Logs
firebase functions:log --only sendDailyRamadanNotification

# 7. اختبار job محدد
cd functions && node setup_scheduler.js test 1
```

---

## 🆘 المساعدة

إذا واجهت مشاكل:

1. **تحقق من Firebase Console Logs**
   https://console.firebase.google.com/project/driveshield-d5a37/functions/logs

2. **تحقق من Cloud Scheduler**
   https://console.cloud.google.com/cloudscheduler?project=driveshield-d5a37

3. **تحقق من Firestore Logs**
   Collection: `ramadan_notifications_log`

4. **راجع التوثيق الكامل**
   `/functions/RAMADAN_NOTIFICATIONS.md`

---

## 🎉 النتيجة النهائية

بعد إتمام جميع الخطوات:

✅ **30 إشعار تلقائي** طوال رمضان  
✅ **توقيت دقيق** (قبل ساعة من المغرب)  
✅ **لا تدخل يدوي** بعد الإعداد  
✅ **سجل كامل** في Firestore  
✅ **إحصائيات حية** عبر API  

**رمضان كريم! 🌙✨**

---

**تاريخ الإنشاء:** 17 فبراير 2026  
**الحالة:** جاهز للنشر (بعد إصلاح الصلاحيات)  
**آخر تحديث:** 17 فبراير 2026 - 23:30
