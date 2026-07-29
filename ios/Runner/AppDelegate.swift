import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  private var liveActivityChannel: FlutterMethodChannel?
  
  // ✅ تتبع الـ Activities النشطة بـ orderId - استخدام Dictionary عادي
  private var activeOrderActivitiesStorage: [String: Any] = [:]
  
  // ✅ Lock لمنع إنشاء Activities متعددة في نفس الوقت
  private let activityLock = NSLock()
  private var isCreatingActivity = false
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    FirebaseApp.configure()
    setupLiveActivityChannel()
    
    // تنظيف الـ Activities القديمة عند بدء التطبيق
    if #available(iOS 16.2, *) {
      cleanupStaleActivities()
    }
    
    // Register for remote notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    }
    
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔗 Universal Links — تمرير الرابط لباكدج app_links
  // ───────────────────────────────────────────────────────────────────────
  // لازم نرجّع نتيجة super (اللي بتوزّع الـ activity على الـ plugins ومنهم
  // app_links) عشان iOS يعتبر إن التطبيق استهلك الـ Universal Link وميفتحش
  // Safari بعد ما يفتح التطبيق. من غير ده بيحصل لوب (تطبيق → ويب → ستور).
  // ═══════════════════════════════════════════════════════════════════════
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

  // 🔗 Custom scheme des:// — تمرير للـ plugins (app_links)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return super.application(app, open: url, options: options)
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🧹 Cleanup Stale Activities
  // ═══════════════════════════════════════════════════════════════════════
  
  @available(iOS 16.2, *)
  private func cleanupStaleActivities() {
    let activities = Activity<OrderTrackingAttributes>.activities
    print("🧹 Found \(activities.count) existing activities on app start")
    
    for activity in activities {
      // تخزين الـ Activities الموجودة
      activeOrderActivitiesStorage[activity.attributes.orderId] = activity
      print("   📦 Cached activity for order: \(activity.attributes.orderId)")
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 📱 Setup Method Channel
  // ═══════════════════════════════════════════════════════════════════════
  
  private func setupLiveActivityChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      print("❌ Failed to get FlutterViewController")
      return
    }
    
    liveActivityChannel = FlutterMethodChannel(
      name: "live_activities_plugin",
      binaryMessenger: controller.binaryMessenger
    )
    
    liveActivityChannel?.setMethodCallHandler { [weak self] (call, result) in
      self?.handleMethodCall(call, result: result)
    }
    
    print("✅ Live Activity channel setup complete")
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 Handle Method Calls
  // ═══════════════════════════════════════════════════════════════════════
  
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "areActivitiesEnabled":
      if #available(iOS 16.2, *) {
        let enabled = ActivityAuthorizationInfo().areActivitiesEnabled
        result(enabled)
      } else {
        result(false)
      }
      
    case "initialize":
      if #available(iOS 16.2, *) {
        cleanupStaleActivities()
      }
      result(true)
      
    case "createActivity":
      if #available(iOS 16.2, *) {
        createLiveActivity(arguments: call.arguments, result: result)
      } else {
        result(FlutterError(code: "UNAVAILABLE", message: "iOS 16.2+ required", details: nil))
      }
      
    case "updateActivity":
      if #available(iOS 16.2, *) {
        updateLiveActivity(arguments: call.arguments, result: result)
      } else {
        result(FlutterError(code: "UNAVAILABLE", message: "iOS 16.2+ required", details: nil))
      }
      
    case "endActivity":
      if #available(iOS 16.2, *) {
        endLiveActivity(arguments: call.arguments, result: result)
      } else {
        result(FlutterError(code: "UNAVAILABLE", message: "iOS 16.2+ required", details: nil))
      }
      
    case "endAllActivities":
      if #available(iOS 16.2, *) {
        endAllLiveActivities(result: result)
      } else {
        result(FlutterError(code: "UNAVAILABLE", message: "Live Activities require iOS 16.2+", details: nil))
      }
      
    case "getActiveActivities":
      if #available(iOS 16.2, *) {
        getActiveActivities(result: result)
      } else {
        result([])
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🚀 Create Live Activity - مُحسَّن لمنع التكرار
  // ═══════════════════════════════════════════════════════════════════════
  
  @available(iOS 16.2, *)
  private func createLiveActivity(arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let orderId = args["orderId"] as? String,
          let orderReference = args["orderReference"] as? String,
          let statusString = args["status"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
      return
    }
    
    let language = args["language"] as? String ?? "en"
    
    print("")
    print("🚀 ════════════════════════════════════════════")
    print("🚀 CREATE LIVE ACTIVITY REQUEST")
    print("🚀 ════════════════════════════════════════════")
    print("   Order ID: \(orderId)")
    print("   Reference: \(orderReference)")
    print("   Status: \(statusString)")
    print("   Language: \(language)")
    
    // ✅ Lock لمنع إنشاء متعدد
    activityLock.lock()
    defer { activityLock.unlock() }
    
    // ✅ التحقق من وجود Activity لنفس الطلب
    if let existingActivity = findExistingActivity(for: orderId) {
      print("⚠️ Activity already exists for order: \(orderId)")
      print("   Existing Activity ID: \(existingActivity.id)")
      print("   Will UPDATE instead of creating new one")
      
      // تحديث الـ Activity الموجود بدلاً من إنشاء جديد
      updateExistingActivity(existingActivity, with: args, result: result)
      return
    }
    
    // ✅ التحقق من أن اللغة لم تتغير (منع إنشاء Activity جديد عند تغيير اللغة)
    let allActivities = Activity<OrderTrackingAttributes>.activities
    print("   Total system activities: \(allActivities.count)")
    
    for activity in allActivities {
      print("   - Activity: \(activity.id), Order: \(activity.attributes.orderId)")
    }
    
    // ✅ إذا في أي Activity موجود لنفس الـ orderId، لا تنشئ جديد
    if allActivities.contains(where: { $0.attributes.orderId == orderId }) {
      print("⚠️ Found existing activity in system for order: \(orderId)")
      if let activity = allActivities.first(where: { $0.attributes.orderId == orderId }) {
        activeOrderActivitiesStorage[orderId] = activity
        result(activity.id)
      } else {
        result(false)
      }
      return
    }
    
    print("✅ No existing activity found, creating NEW one...")
    
    do {
      let status = OrderStatus.from(statusString)
      
      let attributes = OrderTrackingAttributes(
        orderId: orderId,
        orderReference: orderReference,
        storeName: "DES Trading",
        storeImageURL: nil,
        orderTotal: args["orderTotal"] as? String
      )
      
      let initialState = OrderTrackingAttributes.ContentState(
        status: status,
        estimatedTime: args["estimatedTime"] as? String,
        driverName: args["driverName"] as? String,
        driverPhone: args["driverPhone"] as? String,
        driverImageURL: nil,
        lastUpdate: Date(),
        additionalMessage: args["statusDescription"] as? String,
        language: language
      )
      
      let content = ActivityContent(state: initialState, staleDate: nil)
      
      let activity = try Activity.request(
        attributes: attributes,
        content: content,
        pushType: nil
      )
      
      // ✅ تخزين الـ Activity
      activeOrderActivitiesStorage[orderId] = activity
      
      print("✅ ════════════════════════════════════════════")
      print("✅ LIVE ACTIVITY CREATED SUCCESSFULLY!")
      print("   Activity ID: \(activity.id)")
      print("   Order: \(orderReference)")
      print("   Status: \(status.arabicText)")
      print("✅ ════════════════════════════════════════════")
      print("")
      
      result(activity.id)
      
    } catch {
      print("❌ Error creating Live Activity: \(error.localizedDescription)")
      result(FlutterError(
        code: "CREATE_FAILED",
        message: "Failed to create: \(error.localizedDescription)",
        details: nil
      ))
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🔍 Find Existing Activity
  // ═══════════════════════════════════════════════════════════════════════
  
  @available(iOS 16.2, *)
  private func findExistingActivity(for orderId: String) -> Activity<OrderTrackingAttributes>? {
    // أولاً: البحث في الـ cache
    if let cached = activeOrderActivitiesStorage[orderId] as? Activity<OrderTrackingAttributes> {
      // التحقق من أن الـ Activity لا يزال نشطاً
      if cached.activityState == .active || cached.activityState == .stale {
        return cached
      } else {
        // إزالة من الـ cache إذا انتهى
        activeOrderActivitiesStorage.removeValue(forKey: orderId)
      }
    }
    
    // ثانياً: البحث في الـ system activities
    let activities = Activity<OrderTrackingAttributes>.activities
    if let found = activities.first(where: { $0.attributes.orderId == orderId }) {
      activeOrderActivitiesStorage[orderId] = found
      return found
    }
    
    return nil
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Update Existing Activity (helper)
  // ═══════════════════════════════════════════════════════════════════════
  
  @available(iOS 16.2, *)
  private func updateExistingActivity(
    _ activity: Activity<OrderTrackingAttributes>,
    with args: [String: Any],
    result: @escaping FlutterResult
  ) {
    let statusString = args["status"] as? String ?? "pending"
    let language = args["language"] as? String ?? "en"
    let status = OrderStatus.from(statusString)
    
    print("🔄 Updating existing activity: \(activity.id)")
    print("   New Status: \(status.rawValue)")
    print("   Language: \(language)")
    
    let updatedState = OrderTrackingAttributes.ContentState(
      status: status,
      estimatedTime: args["estimatedTime"] as? String,
      driverName: args["driverName"] as? String,
      driverPhone: args["driverPhone"] as? String,
      driverImageURL: nil,
      lastUpdate: Date(),
      additionalMessage: args["statusDescription"] as? String,
      language: language
    )
    
    let content = ActivityContent(state: updatedState, staleDate: nil)
    
    Task {
      await activity.update(content)
      print("✅ Activity updated successfully")
      result(activity.id)
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🔄 Update Live Activity - مُحسَّن
  // ═══════════════════════════════════════════════════════════════════════
  
  @available(iOS 16.2, *)
  private func updateLiveActivity(arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let orderId = args["orderId"] as? String,
          let statusString = args["status"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
      return
    }
    
    let language = args["language"] as? String ?? "en"
    
    print("")
    print("🔄 ════════════════════════════════════════════")
    print("🔄 UPDATE LIVE ACTIVITY REQUEST")
    print("🔄 ════════════════════════════════════════════")
    print("   Order ID: \(orderId)")
    print("   Status: \(statusString)")
    print("   Language: \(language)")
    
    // ✅ البحث عن الـ Activity
    guard let activity = findExistingActivity(for: orderId) else {
      print("⚠️ No activity found for order: \(orderId)")
      print("   Creating new activity instead...")
      
      // إنشاء Activity جديد إذا لم يوجد
      createLiveActivity(arguments: arguments, result: result)
      return
    }
    
    print("   Found Activity ID: \(activity.id)")
    print("   Current State: \(activity.activityState)")
    
    let status = OrderStatus.from(statusString)
    
    print("   Parsed Status: \(status.rawValue)")
    print("   Is Delivered: \(status == .delivered)")
    print("   Is Cancelled: \(status == .cancelled)")
    
    // ═══════════════════════════════════════════════════════════════════════
    // ✅ مهم: عند التوصيل - نحدث فقط ولا ننهي!
    // ═══════════════════════════════════════════════════════════════════════
    
    let updatedState = OrderTrackingAttributes.ContentState(
      status: status,
      estimatedTime: status == .delivered ? nil : (args["estimatedTime"] as? String),
      driverName: args["driverName"] as? String,
      driverPhone: args["driverPhone"] as? String,
      driverImageURL: nil,
      lastUpdate: Date(),
      additionalMessage: args["statusDescription"] as? String,
      language: language
    )
    
    // ✅ للـ Delivered: نستخدم staleDate بعيد حتى يبقى ظاهراً
    let staleDate: Date? = (status == .delivered || status == .cancelled) 
        ? Calendar.current.date(byAdding: .hour, value: 24, to: Date()) 
        : nil
    
    let content = ActivityContent(state: updatedState, staleDate: staleDate)
    
    Task {
      // ✅ تحديث فقط - لا إنهاء
      await activity.update(content)
      
      print("✅ ════════════════════════════════════════════")
      print("✅ LIVE ACTIVITY UPDATED SUCCESSFULLY!")
      print("   Status: \(status.arabicText) / \(status.englishText)")
      print("   Language: \(language)")
      if status == .delivered {
        print("   📦 Order DELIVERED - Activity will stay visible!")
        print("   User must dismiss it manually")
      }
      print("✅ ════════════════════════════════════════════")
      print("")
      
      result(true)
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🛑 End Live Activity - يدوياً فقط
  // ═══════════════════════════════════════════════════════════════════════
  
  @available(iOS 16.2, *)
  private func endLiveActivity(arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let orderId = args["orderId"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing orderId", details: nil))
      return
    }
    
    // ✅ الحصول على سياسة الإنهاء من Flutter
    let dismissImmediately = args["dismissImmediately"] as? Bool ?? false
    
    print("🛑 Ending Live Activity for order: \(orderId)")
    print("   Dismiss Immediately: \(dismissImmediately)")
    
    guard let activity = findExistingActivity(for: orderId) else {
      print("⚠️ No active Live Activity found for order: \(orderId)")
      result(false)
      return
    }
    
    Task {
      // ✅ استخدام .default للسماح للمستخدم برؤية الحالة النهائية
      let policy: ActivityUIDismissalPolicy = dismissImmediately ? .immediate : .default
      
      await activity.end(nil, dismissalPolicy: policy)
      
      activeOrderActivitiesStorage.removeValue(forKey: orderId)
      
      print("✅ Live Activity ended with policy: \(policy)")
      result(true)
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 🛑 End All Live Activities
  // ═══════════════════════════════════════════════════════════════════════
  
  @available(iOS 16.2, *)
  private func endAllLiveActivities(result: @escaping FlutterResult) {
    print("🛑 Ending ALL Live Activities")
    
    let activities = Activity<OrderTrackingAttributes>.activities
    
    if activities.isEmpty {
      print("⚠️ No active Live Activities found")
      activeOrderActivitiesStorage.removeAll()
      result(true)
      return
    }
    
    print("📦 Found \(activities.count) active Live Activities")
    
    Task {
      for activity in activities {
        await activity.end(nil, dismissalPolicy: .immediate)
        print("   ✅ Ended: \(activity.attributes.orderId)")
      }
      
      activeOrderActivitiesStorage.removeAll()
      
      print("✅ All Live Activities ended")
      result(true)
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 📋 Get Active Activities
  // ═══════════════════════════════════════════════════════════════════════
  
  @available(iOS 16.2, *)
  private func getActiveActivities(result: @escaping FlutterResult) {
    let activities = Activity<OrderTrackingAttributes>.activities
    
    let activeIds = activities.map { activity -> [String: Any] in
      return [
        "id": activity.id,
        "orderId": activity.attributes.orderId,
        "orderReference": activity.attributes.orderReference,
        "state": String(describing: activity.activityState)
      ]
    }
    
    result(activeIds)
  }
  
  // ═══════════════════════════════════════════════════════════════════════
  // 📱 APNs
  // ═══════════════════════════════════════════════════════════════════════
  
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
  
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error)")
  }
}
