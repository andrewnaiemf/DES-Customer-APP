//
//  OrderTrackingAttributes.swift
//  OrderTrackingWidget
//
//  Created by Omnia Neil on 31/01/2026.
//  ✨ Enhanced Professional Version
//

import Foundation
import ActivityKit
import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Order Status Enum - Enhanced
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
public enum OrderStatus: String, Codable, Hashable, CaseIterable, Sendable {
    case pending = "pending"
    case confirmed = "confirmed"
    case preparing = "preparing"
    case ready = "ready"
    case outForDelivery = "out_for_delivery"
    case arriving = "arriving"
    case delivered = "delivered"
    case cancelled = "cancelled"
    
    // ═══════════════════════════════════════════════════════════════════════
    // 📝 Text Properties
    // ═══════════════════════════════════════════════════════════════════════
    
    public var arabicText: String {
        switch self {
        case .pending: return "في انتظار التأكيد"
        case .confirmed: return "تم تأكيد الطلب"
        case .preparing: return "جاري التحضير"
        case .ready: return "جاهز للتوصيل"
        case .outForDelivery: return "خرج للتوصيل"
        case .arriving: return "المندوب في الطريق إليك"
        case .delivered: return "تم التسليم"
        case .cancelled: return "تم الإلغاء"
        }
    }
    
    public var englishText: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .preparing: return "Preparing"
        case .ready: return "Ready"
        case .outForDelivery: return "On the way"
        case .arriving: return "Arriving"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }
    
    public var mainMessage: String {
        switch self {
        case .pending: return "Waiting for confirmation..."
        case .confirmed: return "Great! Your order is confirmed"
        case .preparing: return "Your order is being prepared "
        case .ready: return "Your order is ready for pickup!"
        case .outForDelivery: return "Delivery agent picked up your order"
        case .arriving: return "Almost there! Delivery agent is nearby"
        case .delivered: return "Your order has been delivered!"
        case .cancelled: return "Order has been cancelled"
        }
    }
    
    public var arabicMainMessage: String {
        switch self {
        case .pending: return "في انتظار التأكيد..."
        case .confirmed: return "رائع! تم تأكيد طلبك"
        case .preparing: return "يتم تحضير طلبك الآن"
        case .ready: return "طلبك جاهز للاستلام!"
        case .outForDelivery: return "المندوب استلم طلبك وفي الطريق"
        case .arriving: return "تقريباً وصل! المندوب قريب منك"
        case .delivered: return "تم تسليم طلبك بنجاح!"
        case .cancelled: return "تم إلغاء الطلب"
        }
    }
    
    public var shortMessage: String {
        switch self {
        case .pending: return "Confirming..."
        case .confirmed: return "Confirmed ✓"
        case .preparing: return "Preparing..."
        case .ready: return "Ready!"
        case .outForDelivery: return "On the way"
        case .arriving: return "Arriving soon"
        case .delivered: return "Delivered ✓"
        case .cancelled: return "Cancelled"
        }
    }
    
    public var arabicShortMessage: String {
        switch self {
        case .pending: return "جاري التأكيد..."
        case .confirmed: return "تم التأكيد ✓"
        case .preparing: return "جاري التحضير..."
        case .ready: return "جاهز!"
        case .outForDelivery: return "في الطريق"
        case .arriving: return "قريب جداً"
        case .delivered: return "تم التسليم ✓"
        case .cancelled: return "ملغي"
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🎨 Visual Properties
    // ═══════════════════════════════════════════════════════════════════════
    
    public var emoji: String {
        switch self {
        case .pending: return "⏳"
        case .confirmed: return "✅"
        case .preparing: return "�"
        case .ready: return "✓"
        case .outForDelivery: return "🚗"
        case .arriving: return "📍"
        case .delivered: return "🎉"
        case .cancelled: return "❌"
        }
    }
    
    public var sfSymbol: String {
        switch self {
        case .pending: return "clock.badge.questionmark"
        case .confirmed: return "checkmark.circle.fill"
        case .preparing: return "shippingbox.fill"
        case .ready: return "bag.fill"
        case .outForDelivery: return "car.fill"
        case .arriving: return "location.fill"
        case .delivered: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    public var swiftUIColor: Color {
        switch self {
        case .pending:
            return Color(hex: "#6842E2") // Purple
        case .confirmed:
            return Color(hex: "#7334D8") // Purple
        case .preparing:
            return Color(hex: "#6842E2") // Purple
        case .ready:
            return Color(hex: "#28E6C5") // Light Green
        case .outForDelivery:
            return Color(hex: "#6842E2") // Purple
        case .arriving:
            return Color(hex: "#00C88D") // Green
        case .delivered:
            return Color(hex: "#00C88D") // Green
        case .cancelled:
            return Color(hex: "#FF3B30") // Red
        }
    }
    
    public var gradientColors: [Color] {
        switch self {
        case .pending:
            return [Color(hex: "#FBBF4D"), Color(hex: "#F59E0B")]
        case .confirmed:
            return [Color(hex: "#D9B31D"), Color(hex: "#FBBF4D")]
        case .preparing:
            return [Color(hex: "#F97316"), Color(hex: "#FBBF4D")]
        case .ready:
            return [Color(hex: "#28E6C5"), Color(hex: "#10B981")]
        case .outForDelivery:
            return [Color(hex: "#6842E2"), Color(hex: "#8B5CF6")]
        case .arriving:
            return [Color(hex: "#00C88D"), Color(hex: "#10B981")]
        case .delivered:
            return [Color(hex: "#00C88D"), Color(hex: "#059669")]
        case .cancelled:
            return [Color(hex: "#FF3B30"), Color(hex: "#DC2626")]
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // 📊 Progress Properties
    // ═══════════════════════════════════════════════════════════════════════
    
    public var progress: Double {
        switch self {
        case .pending: return 1.10
        case .confirmed: return 0.25
        case .preparing: return 0.45
        case .ready: return 0.60
        case .outForDelivery: return 0.75
        case .arriving: return 0.90
        case .delivered: return 1.0
        case .cancelled: return 0.0
        }
    }
    
    public var progressPercent: Int {
        return Int(progress * 100)
    }
    
    public var stage: Int {
        switch self {
        case .pending: return 1
        case .confirmed: return 1
        case .preparing: return 2
        case .ready: return 2
        case .outForDelivery: return 3
        case .arriving: return 3
        case .delivered: return 4
        case .cancelled: return 0
        }
    }
    
    public var totalStages: Int {
        return 4
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🔍 State Properties
    // ═══════════════════════════════════════════════════════════════════════
    
    public var isActive: Bool {
        switch self {
        case .pending, .confirmed, .preparing, .ready, .outForDelivery, .arriving:
            return true
        case .delivered, .cancelled:
            return false
        }
    }
    
    public var isCompleted: Bool {
        return self == .delivered
    }
    
    public var isCancelled: Bool {
        return self == .cancelled
    }
    
    public var isDeliveryPhase: Bool {
        switch self {
        case .outForDelivery, .arriving:
            return true
        default:
            return false
        }
    }
    
    public var hasDriverInfo: Bool {
        return isDeliveryPhase
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🔄 Parsing - مُحسَّن للتعامل مع كل الحالات
    // ═══════════════════════════════════════════════════════════════════════
    
    public static func from(_ string: String) -> OrderStatus {
        let normalized = string.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
        
        print("🔍 Parsing status: '\(string)' -> normalized: '\(normalized)'")
        
        switch normalized {
        // Pending variations
        case "pending", "draft", "new", "awaiting", "معلق", "waiting":
            return .pending
            
        // Confirmed variations
        case "confirmed", "approved", "accepted", "مؤكد":
            return .confirmed
            
        // Preparing variations (includes "processing", "preparing")
        case "preparing", "processing", "in_progress", "inprogress", "جاري_التحضير", "cooking":
            return .preparing
            
        // Ready variations
        case "ready", "جاهز", "ready_for_pickup", "readyforpickup":
            return .ready
            
        // Shipped/Out for delivery variations
        case "shipped", "shipping", "dispatched", "in_transit", "intransit",
             "out_for_delivery", "outfordelivery", "out_delivery", 
             "on_the_way", "ontheway", "خرج_للتوصيل", "pickedup":
            return .outForDelivery
            
        // Arriving variations
        case "arriving", "فيالطريق", "في_الطريق", "nearby", "almost_there", "almostthere":
            return .arriving
            
        // Delivered variations
        case "delivered", "completed", "done", "received", "تم_التسليم":
            return .delivered
            
        // Cancelled variations
        case "cancelled", "canceled", "declined", "rejected", "failed", "ملغي":
            return .cancelled
            
        default:
            print("⚠️ Unknown status: '\(string)', defaulting to pending")
            // Try direct enum match as fallback
            return OrderStatus(rawValue: normalized) ?? .pending
        }
    }
    
    public var next: OrderStatus? {
        switch self {
        case .pending: return .confirmed
        case .confirmed: return .preparing
        case .preparing: return .ready
        case .ready: return .outForDelivery
        case .outForDelivery: return .arriving
        case .arriving: return .delivered
        case .delivered: return nil
        case .cancelled: return nil
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Activity Attributes - Enhanced
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
public struct OrderTrackingAttributes: ActivityAttributes, Sendable {
    
    // MARK: - Static Content (لا يتغير)
    public let orderId: String
    public let orderReference: String
    public let storeName: String
    public let storeImageURL: String?
    public let orderTotal: String?
    
    // MARK: - Dynamic Content State
    public struct ContentState: Codable, Hashable, Sendable {
        public let status: OrderStatus
        public let estimatedTime: String?
        public let driverName: String?
        public let driverPhone: String?
        public let driverImageURL: String?
        public let lastUpdate: Date
        public let additionalMessage: String?
        public let language: String? // "ar" or "en"
        
        // ═══════════════════════════════════════════════════════════════════
        // 🏗️ Initializers
        // ═══════════════════════════════════════════════════════════════════
        
        public init(
            status: OrderStatus,
            estimatedTime: String? = nil,
            driverName: String? = nil,
            driverPhone: String? = nil,
            driverImageURL: String? = nil,
            lastUpdate: Date = Date(),
            additionalMessage: String? = nil,
            language: String? = nil
        ) {
            self.status = status
            self.estimatedTime = estimatedTime
            self.driverName = driverName
            self.driverPhone = driverPhone
            self.driverImageURL = driverImageURL
            self.lastUpdate = lastUpdate
            self.additionalMessage = additionalMessage
            self.language = language
        }
        
        // ═══════════════════════════════════════════════════════════════════
        // 🏭 Factory Methods
        // ═══════════════════════════════════════════════════════════════════
        
        public static func defaultState() -> Self {
            return Self(status: .pending)
        }
        
        public static func from(
            statusString: String,
            estimatedTime: String? = nil,
            driverName: String? = nil,
            driverPhone: String? = nil,
            driverImageURL: String? = nil,
            additionalMessage: String? = nil,
            language: String? = nil
        ) -> Self {
            return Self(
                status: OrderStatus.from(statusString),
                estimatedTime: estimatedTime,
                driverName: driverName,
                driverPhone: driverPhone,
                driverImageURL: driverImageURL,
                additionalMessage: additionalMessage,
                language: language
            )
        }
        
        /// Create next state (for animation/transition)
        public func nextState() -> Self? {
            guard let nextStatus = status.next else { return nil }
            
            return Self(
                status: nextStatus,
                estimatedTime: estimatedTime,
                driverName: driverName,
                driverPhone: driverPhone,
                driverImageURL: driverImageURL,
                lastUpdate: Date(),
                additionalMessage: nil,
                language: language
            )
        }
        
        // ═══════════════════════════════════════════════════════════════════
        // 🌍 Localized Text Helpers
        // ═══════════════════════════════════════════════════════════════════
        
        /// Check if current language is Arabic
        public var isArabic: Bool {
            return language == "ar"
        }
        
        /// Get localized status text based on language
        public var localizedStatusText: String {
            return isArabic ? status.arabicText : status.englishText
        }
        
        /// Get localized main message based on language
        public var localizedMainMessage: String {
            return isArabic ? status.arabicMainMessage : status.mainMessage
        }
        
        /// Get localized short message based on language
        public var localizedShortMessage: String {
            return isArabic ? status.arabicShortMessage : status.shortMessage
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🏗️ Initializers
    // ═══════════════════════════════════════════════════════════════════════
    
    public init(
        orderId: String,
        orderReference: String,
        storeName: String = "DES",
        storeImageURL: String? = nil,
        orderTotal: String? = nil
    ) {
        self.orderId = orderId
        self.orderReference = orderReference
        self.storeName = storeName
        self.storeImageURL = storeImageURL
        self.orderTotal = orderTotal
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Color Extension for Hex Support - Enhanced
// ═══════════════════════════════════════════════════════════════════════════
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert Color to hex string
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // 🎨 Brand Colors - DES App Theme
    // ═══════════════════════════════════════════════════════════════════════
    struct Brand {
        // Primary Colors
        static let lightPurple = Color(red: 0.408, green: 0.259, blue: 0.886)      // #6842E2 (بنفسجي فاتح)
        static let darkPurple = Color(red: 0.329, green: 0.149, blue: 0.620)        // #54269E (بنفسجي غامق)
        static let purple = Color(red: 0.451, green: 0.204, blue: 0.847) // #7334D8
        
        // Backgrounds
        static let background = Color(red: 0.082, green: 0.094, blue: 0.137) // #151823
        static let dark = Color(red: 0.039, green: 0.051, blue: 0.078)       // #0A0D14
        static let cardBackground = Color(red: 0.118, green: 0.137, blue: 0.192) // #1E2331
        static let black = Color.black
        
        // Text Colors
        static let textPrimary = Color.white
        static let textSecondary = Color(red: 0.698, green: 0.706, blue: 0.733) // #B2B4BB
        static let darkGray = Color(red: 0.557, green: 0.565, blue: 0.584)      // #8E9095
        
        // Status Colors
        static let success = Color(red: 0.2, green: 0.78, blue: 0.35)     // #34C759
        static let lightGreen = Color(red: 0.565, green: 0.933, blue: 0.565) // #90EE90
        static let warning = Color(red: 1.0, green: 0.8, blue: 0.0)       // #FFCC00
        static let error = Color(red: 1.0, green: 0.231, blue: 0.188)     // #FF3B30
        static let info = Color(red: 0.0, green: 0.478, blue: 1.0)        // #007AFF
        
        // Gradients
        static let primaryGradient = [purple, lightPurple]
        static let backgroundGradient = [background, dark]
        static let purpleGradient = [purple, Color(red: 0.329, green: 0.149, blue: 0.620)] // #54269E
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Helper Extensions
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
extension OrderTrackingAttributes.ContentState {
    
    /// Formatted last update time
    public var formattedLastUpdate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }
    
    /// Check if state has driver info
    public var hasDriverInfo: Bool {
        return driverName != nil && !driverName!.isEmpty
    }
    
    /// Check if state has estimated time
    public var hasEstimatedTime: Bool {
        return estimatedTime != nil && !estimatedTime!.isEmpty
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌍 Localization Helper for OrderStatus
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
extension OrderStatus {
    /// Returns localized text based on system locale
    /// Supports Arabic and English
    public var localizedText: String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        
        if languageCode == "ar" {
            return arabicText
        } else {
            return englishText
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📝 Common Localized Strings Helper
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
struct LocalizedStrings {
    static func arrivesIn(language: String?) -> String {
        return language == "ar" ? "يصل خلال" : "Arrives in"
    }
    
    static func track(language: String?) -> String {
        return language == "ar" ? "تتبع" : "Track"
    }
    
    static func deliveryAgent(language: String?) -> String {
        return language == "ar" ? "مندوب التوصيل" : "Delivery Agent"
    }
    
    static func orderNumber(language: String?) -> String {
        return language == "ar" ? "طلب رقم" : "Order #"
    }
    
    // Fallback to old static properties for backward compatibility
    static var arrivesIn: String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return languageCode == "ar" ? "يصل خلال" : "Arrives in"
    }
    
    static var track: String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return languageCode == "ar" ? "تتبع" : "Track"
    }
    
    static var deliveryAgent: String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return languageCode == "ar" ? "مندوب التوصيل" : "Delivery Agent"
    }
}