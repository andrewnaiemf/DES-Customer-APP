//
//  OrderTrackingWidgetLiveActivity.swift
//  OrderTrackingWidget
//
//  Created by Omnia Neil on 31/01/2026.
//  ✨ Enhanced Professional Version
//

import ActivityKit
import WidgetKit
import SwiftUI
import Foundation

// Note: Brand colors are defined in OrderTrackingAttributesV2.swift
// Import OrderTrackingAttributes and related types

// ═══════════════════════════════════════════════════════════════════════════
// 🏠 Main Live Activity Widget
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.2, *)
struct OrderTrackingWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderTrackingAttributes.self) { context in
            // 🔒 Lock Screen Content - Professional Design
            EnhancedLockScreenView(context: context)
                .activityBackgroundTint(Color.Brand.background)
                .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            // 🏝️ Dynamic Island - Enhanced
            DynamicIsland {
                // ═══════════════════════════════════════════════════════════
                // 📱 Expanded Regions
                // ═══════════════════════════════════════════════════════════
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(context: context)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
                
            } compactLeading: {
                // 🔵 Compact Leading
                CompactLeadingView(context: context)
                
            } compactTrailing: {
                // 🔵 Compact Trailing
                CompactTrailingView(context: context)
                
            } minimal: {
                // 🔴 Minimal View
                MinimalView(context: context)
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔒 Enhanced Lock Screen View
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
struct EnhancedLockScreenView: View {
    let context: ActivityViewContext<OrderTrackingAttributes>
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // 🎨 Gradient Background
            backgroundGradient
            
            VStack(alignment: .leading, spacing: 8) {  // ✅ تقليل spacing من 16 لـ 8
                // 📍 Header Row
                headerSection
                
                // 📝 Status Message
                statusMessageSection
                
                // ⏱️ Estimated Time
                if let estimatedTime = context.state.estimatedTime {
                    estimatedTimeSection(estimatedTime)
                }
                
                // 📊 Progress Bar
                enhancedProgressBar
                
                // 👤 Delivery Agent Info (if available)
                if let driverName = context.state.driverName {
                    driverInfoSection(driverName: driverName)
                }
            }
            .padding(16)  // ✅ تقليل padding من 20 لـ 16
        }
        // ✅ تطبيق RTL/LTR على كل الـ View بناءً على اللغة
        .environment(\.layoutDirection, context.state.isArabic ? .rightToLeft : .leftToRight)
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.Brand.background,
                Color.Brand.dark.opacity(0.95),
                Color.Brand.black
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 10) {  // ✅ تقليل spacing من 12 لـ 10
            // Store Icon with Glow Effect
            ZStack {
                Circle()
                    .fill(context.state.status.swiftUIColor.opacity(0.2))
                    .frame(width: 38, height: 38)  // ✅ تصغير من 44 لـ 38
                
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                context.state.status.swiftUIColor,
                                context.state.status.swiftUIColor.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)  // ✅ تصغير من 36 لـ 32
                    .shadow(color: context.state.status.swiftUIColor.opacity(0.5), radius: 6, x: 0, y: 3)
                
                Text(context.state.status.emoji)
                    .font(.system(size: 16))  // ✅ تصغير من 18 لـ 16
            }
            
            VStack(alignment: .leading, spacing: 1) {  // ✅ تقليل spacing من 2 لـ 1
                HStack(spacing: 5) {  // ✅ تقليل spacing من 6 لـ 5
                    // Company Logo
                    Image("logoicon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)  // ✅ تصغير من 20 لـ 18
                    
                    Text(context.attributes.storeName)
                        .font(.system(size: 15, weight: .bold, design: .rounded))  // ✅ تصغير من 17 لـ 15
                        .foregroundColor(.white)
                }
                
                Text("\(orderNumber(language: context.state.language))\(context.attributes.orderReference)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))  // ✅ تصغير من 12 لـ 11
                    .foregroundColor(Color.Brand.darkGray.opacity(0.7))
            }
            
            Spacer()
            
            // Status Badge with Animation Feel
            statusBadge
        }
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        HStack(spacing: 5) {  // ✅ تقليل spacing من 6 لـ 5
            // Pulsing Dot
            Circle()
                .fill(context.state.status == .cancelled ? Color.Brand.error : Color.white)
                .frame(width: 5, height: 5)  // ✅ تصغير من 6 لـ 5
            
            Text(context.state.localizedStatusText)
                .font(.system(size: 10, weight: .bold, design: .rounded))  // ✅ تصغير من 11 لـ 10
                .foregroundColor(
                    context.state.status == .cancelled ? .white : Color.Brand.black
                )
        }
        .padding(.horizontal, 10)  // ✅ تقليل من 12 لـ 10
        .padding(.vertical, 6)  // ✅ تقليل من 8 لـ 6
        .background(
            Capsule()
                .fill(
                    context.state.status == .cancelled
                    ? Color.Brand.error
                    : context.state.status.swiftUIColor
                )
                .shadow(color: context.state.status.swiftUIColor.opacity(0.4), radius: 6, x: 0, y: 3)  // ✅ تقليل shadow
        )
    }
    
    // MARK: - Status Message Section
    private var statusMessageSection: some View {
        VStack(alignment: .leading, spacing: 3) {  // ✅ تقليل spacing من 4 لـ 3
            Text(context.state.localizedMainMessage)
                .font(.system(size: 13, weight: .medium))  // ✅ تصغير من 15 لـ 13
                .foregroundColor(.white.opacity(0.95))
                .lineLimit(2)  // ✅ تحديد عدد الأسطر
            
            // ✅ رسالة خاصة عند التوصيل
            if context.state.status == .delivered {
                deliveredSuccessMessage
            } else if context.state.status == .outForDelivery || context.state.status == .arriving {
                Text(context.state.isArabic ? "طلبك في الطريق إليك! 🚀" : "Your order is on its way to you! 🚀")
                    .font(.system(size: 12, weight: .regular))  // ✅ تصغير من 13 لـ 12
                    .foregroundColor(Color.Brand.lightGreen)
            }
        }
    }
    
    // ✅ رسالة النجاح عند التوصيل - مُحسَّنة
    private var deliveredSuccessMessage: some View {
        HStack(spacing: 8) {  // ✅ تقليل spacing من 10 لـ 8
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16))  // ✅ تصغير من 20 لـ 16
                .foregroundColor(Color.Brand.lightGreen)
            
            VStack(alignment: .leading, spacing: 1) {  // ✅ تقليل spacing من 2 لـ 1
                Text(context.state.isArabic ? "تم التوصيل بنجاح!" : "Successfully Delivered!")
                    .font(.system(size: 12, weight: .semibold))  // ✅ تصغير من 14 لـ 12
                    .foregroundColor(Color.Brand.lightGreen)
                
                Text(context.state.isArabic ? "شكراً لتسوقك معنا 💚" : "Thank you for shopping with us 💚")
                    .font(.system(size: 10, weight: .regular))  // ✅ تصغير من 12 لـ 10
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 6)  // ✅ تقليل من 10 لـ 6
        .padding(.horizontal, 10)  // ✅ تقليل من 14 لـ 10
        .background(
            RoundedRectangle(cornerRadius: 10)  // ✅ تقليل من 12 لـ 10
                .fill(Color.Brand.lightGreen.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.Brand.lightGreen.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Estimated Time Section
    private func estimatedTimeSection(_ time: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.Brand.purple)
            
            Text(arrivesIn(language: context.state.language))
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.Brand.darkGray.opacity(0.8))
            
            Text(time)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Enhanced Progress Bar
    private var enhancedProgressBar: some View {
        VStack(spacing: 6) {  // ✅ تقليل spacing من 10 لـ 6
            // Progress Segments
            HStack(spacing: 5) {  // ✅ تقليل spacing من 6 لـ 5
                ForEach(0..<4, id: \.self) { index in
                    EnhancedProgressSegment(
                        index: index,
                        currentStage: context.state.status.stage,
                        status: context.state.status
                    )
                }
            }
            .frame(height: 6)  // ✅ تصغير من 8 لـ 6
            
            // Stage Labels - with RTL support
            HStack {
                Text(stageLabel(for: 1))
                    .font(.system(size: 8, weight: .medium))  // ✅ تصغير من 9 لـ 8
                    .foregroundColor(stageColor(for: 1))
                
                Spacer()
                
                Text(stageLabel(for: 2))
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(stageColor(for: 2))
                
                Spacer()
                
                Text(stageLabel(for: 3))
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(stageColor(for: 3))
                
                Spacer()
                
                Text(stageLabel(for: 4))
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(stageColor(for: 4))
            }
            .environment(\.layoutDirection, context.state.isArabic ? .rightToLeft : .leftToRight)
        }
        .padding(.vertical, 2)  // ✅ تقليل من 4 لـ 2
    }
    
    private func stageLabel(for stage: Int) -> String {
        let isArabic = context.state.isArabic
        switch stage {
        case 1: return isArabic ? "تم التأكيد" : "Confirmed"
        case 2: return isArabic ? "جاري التحضير" : "Preparing"
        case 3: return isArabic ? "في الطريق" : "On the way"
        case 4: return isArabic ? "تم التسليم" : "Delivered"
        default: return ""
        }
    }
    
    private func stageColor(for stage: Int) -> Color {
        if context.state.status.stage >= stage {
            return context.state.status.swiftUIColor
        }
        return Color.white.opacity(0.4)
    }
    
    // MARK: - Delivery Agent Info Section
    private func driverInfoSection(driverName: String) -> some View {
        HStack(spacing: 12) {
            // Delivery Agent Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.Brand.purple,
                                Color.Brand.purple.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(deliveryAgent(language: context.state.language))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.Brand.darkGray.opacity(0.7))
                
                Text(driverName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Call Button
            if context.state.driverPhone != nil {
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color.Brand.lightGreen)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.Brand.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Enhanced Progress Segment
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
struct EnhancedProgressSegment: View {
    let index: Int
    let currentStage: Int
    let status: OrderStatus
    
    private var isActive: Bool {
        return currentStage > index
    }
    
    private var isCurrent: Bool {
        return currentStage == index + 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.15))
                
                // Active Fill with Gradient
                if isActive {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    segmentColor,
                                    segmentColor.opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: segmentColor.opacity(0.5), radius: 4, x: 0, y: 2)
                }
                
                // Current Stage Indicator (Animated feel)
                if isCurrent {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    segmentColor.opacity(0.6),
                                    segmentColor.opacity(0.3)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
        }
    }
    
    private var segmentColor: Color {
        if status == .cancelled {
            return Color.Brand.error
        }
        
        if index < 2 {
            return Color.Brand.purple
        } else {
            return Color.Brand.success
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🏝️ Dynamic Island Components
// ═══════════════════════════════════════════════════════════════════════════

// MARK: - Expanded Leading View
@available(iOS 16.1, *)
struct ExpandedLeadingView: View {
    let context: ActivityViewContext<OrderTrackingAttributes>
    
    var body: some View {
        HStack(spacing: 10) {
            // Animated Emoji Container
            ZStack {
                Circle()
                    .fill(context.state.status.swiftUIColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Text(context.state.status.emoji)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.storeName)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(context.state.localizedStatusText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(context.state.status.swiftUIColor)
            }
        }
    }
}

// MARK: - Expanded Trailing View
@available(iOS 16.1, *)
struct ExpandedTrailingView: View {
    let context: ActivityViewContext<OrderTrackingAttributes>
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Progress Percentage with Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: context.state.status.progress)
                    .stroke(
                        context.state.status.swiftUIColor,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                Text("\(context.state.status.progressPercent)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            if let estimatedTime = context.state.estimatedTime {
                Text(estimatedTime)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Expanded Center View
@available(iOS 16.1, *)
struct ExpandedCenterView: View {
    let context: ActivityViewContext<OrderTrackingAttributes>
    
    var body: some View {
        VStack(spacing: 4) {
            Text(context.state.localizedMainMessage)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Expanded Bottom View
@available(iOS 16.1, *)
struct ExpandedBottomView: View {
    let context: ActivityViewContext<OrderTrackingAttributes>
    
    var body: some View {
        VStack(spacing: 10) {
            // Mini Progress Bar
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            context.state.status.stage > index
                            ? context.state.status.swiftUIColor
                            : Color.white.opacity(0.2)
                        )
                        .frame(height: 4)
                }
            }
            
            // Delivery Agent Info (if available)
            if let driverName = context.state.driverName {
                HStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color.Brand.lightGreen)
                    
                    Text(driverName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(trackText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.Brand.purple)
                }
            }
        }
    }
    
    private var trackText: String {
        return context.state.isArabic ? "تتبع" : "Track"
    }
}

// MARK: - Compact Leading View
@available(iOS 16.1, *)
struct CompactLeadingView: View {
    let context: ActivityViewContext<OrderTrackingAttributes>
    
    var body: some View {
        HStack(spacing: 6) {
            Text(context.state.status.emoji)
                .font(.system(size: 16))
            
            Text(context.state.status.localizedText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(context.state.status.swiftUIColor)
                .lineLimit(1)
        }
    }
}

// MARK: - Compact Trailing View
@available(iOS 16.1, *)
struct CompactTrailingView: View {
    let context: ActivityViewContext<OrderTrackingAttributes>
    
    var body: some View {
        ZStack {
            // Background Ring
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2.5)
                .frame(width: 24, height: 24)
            
            // Progress Ring
            Circle()
                .trim(from: 0, to: context.state.status.progress)
                .stroke(
                    context.state.status.swiftUIColor,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Minimal View
@available(iOS 16.1, *)
struct MinimalView: View {
    let context: ActivityViewContext<OrderTrackingAttributes>
    
    var body: some View {
        ZStack {
            Circle()
                .fill(context.state.status.swiftUIColor.opacity(0.3))
                .frame(width: 24, height: 24)
            
            Text(context.state.status.emoji)
                .font(.system(size: 14))
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Preview Provider
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 17.0, *)
#Preview("Lock Screen", as: .content, using: OrderTrackingAttributes.preview) {
    OrderTrackingWidgetLiveActivity()
} contentStates: {
    OrderTrackingAttributes.ContentState.previewPreparing
    OrderTrackingAttributes.ContentState.previewOnTheWay
    OrderTrackingAttributes.ContentState.previewDelivered
}

// Preview Helpers
@available(iOS 16.1, *)
extension OrderTrackingAttributes {
    static var preview: OrderTrackingAttributes {
        OrderTrackingAttributes(
            orderId: "12345",
            orderReference: "DES-2024-001",
            storeName: "DES Trading"
        )
    }
}

@available(iOS 16.1, *)
extension OrderTrackingAttributes.ContentState {
    static var previewPreparing: OrderTrackingAttributes.ContentState {
        .init(
            status: .preparing,
            estimatedTime: "15-20 min",
            driverName: nil,
            driverPhone: nil
        )
    }
    
    static var previewOnTheWay: OrderTrackingAttributes.ContentState {
        .init(
            status: .outForDelivery,
            estimatedTime: "8 min",
            driverName: "Ahmed M.",
            driverPhone: "+966500000000",
            language: "en"
        )
    }
    
    static var previewDelivered: OrderTrackingAttributes.ContentState {
        .init(
            status: .delivered,
            estimatedTime: nil,
            driverName: "Ahmed M.",
            driverPhone: nil,
            language: "en"
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🌍 Localization Helpers for Widget
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
extension EnhancedLockScreenView {
    func arrivesIn(language: String?) -> String {
        return language == "ar" ? "يصل خلال" : "Arrives in"
    }
    
    func deliveryAgent(language: String?) -> String {
        return language == "ar" ? "مندوب التوصيل" : "Delivery Agent"
    }
    
    func orderNumber(language: String?) -> String {
        return language == "ar" ? "طلب رقم" : "Order #"
    }
    
    func track(language: String?) -> String {
        return language == "ar" ? "تتبع" : "Track"
    }
}