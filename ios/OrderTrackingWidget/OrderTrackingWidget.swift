//
//  OrderTrackingWidget.swift
//  OrderTrackingWidget
//
//  Created by Omnia Neil on 31/01/2026.
//  ✨ Enhanced Professional Version
//

import WidgetKit
import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Timeline Provider
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
struct OrderWidgetProvider: TimelineProvider {
    
    typealias Entry = OrderWidgetEntry
    
    // Placeholder for widget gallery
    func placeholder(in context: Context) -> OrderWidgetEntry {
        OrderWidgetEntry.placeholder
    }
    
    // Snapshot for widget gallery preview
    func getSnapshot(in context: Context, completion: @escaping (OrderWidgetEntry) -> ()) {
        completion(OrderWidgetEntry.snapshot)
    }
    
    // Timeline for actual updates
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Fetch current order status from UserDefaults (shared with app)
        let entry = fetchCurrentOrderEntry()
        
        // Refresh timeline after 5 minutes
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        
        completion(timeline)
    }
    
    // Fetch order data from shared UserDefaults
    private func fetchCurrentOrderEntry() -> OrderWidgetEntry {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.des.app"),
              let orderData = sharedDefaults.dictionary(forKey: "current_order") else {
            return OrderWidgetEntry.noActiveOrder
        }
        
        let orderId = orderData["orderId"] as? String ?? ""
        let orderReference = orderData["orderReference"] as? String ?? ""
        let storeName = orderData["storeName"] as? String ?? "DES"
        let statusString = orderData["status"] as? String ?? "pending"
        let estimatedTime = orderData["estimatedTime"] as? String
        
        let status = OrderStatus.from(statusString)
        
        return OrderWidgetEntry(
            date: Date(),
            hasActiveOrder: true,
            orderId: orderId,
            orderReference: orderReference,
            storeName: storeName,
            status: status,
            estimatedTime: estimatedTime
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Widget Entry
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
struct OrderWidgetEntry: TimelineEntry {
    let date: Date
    let hasActiveOrder: Bool
    let orderId: String
    let orderReference: String
    let storeName: String
    let status: OrderStatus
    let estimatedTime: String?
    
    // Placeholder entry
    static var placeholder: OrderWidgetEntry {
        OrderWidgetEntry(
            date: Date(),
            hasActiveOrder: true,
            orderId: "12345",
            orderReference: "DES-001",
            storeName: "DES Trading",
            status: .preparing,
            estimatedTime: "15 min"
        )
    }
    
    // Snapshot entry
    static var snapshot: OrderWidgetEntry {
        OrderWidgetEntry(
            date: Date(),
            hasActiveOrder: true,
            orderId: "12345",
            orderReference: "DES-001",
            storeName: "DES Trading",
            status: .outForDelivery,
            estimatedTime: "8 min"
        )
    }
    
    // No active order
    static var noActiveOrder: OrderWidgetEntry {
        OrderWidgetEntry(
            date: Date(),
            hasActiveOrder: false,
            orderId: "",
            orderReference: "",
            storeName: "DES",
            status: .pending,
            estimatedTime: nil
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Widget Entry View
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
struct OrderTrackingWidgetEntryView: View {
    var entry: OrderWidgetProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            if entry.hasActiveOrder {
                activeOrderView
            } else {
                noOrderView
            }
        }
    }
    
    // MARK: - Active Order View
    private var activeOrderView: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.Brand.background,
                    Color.Brand.dark
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: family == .systemSmall ? 8 : 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.storeName)
                            .font(.system(size: family == .systemSmall ? 13 : 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        if family != .systemSmall {
                            Text("#\(entry.orderReference)")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(Color.Brand.darkGray.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Status Emoji with Glow
                    ZStack {
                        Circle()
                            .fill(entry.status.swiftUIColor.opacity(0.2))
                            .frame(width: family == .systemSmall ? 28 : 36, height: family == .systemSmall ? 28 : 36)
                        
                        Text(entry.status.emoji)
                            .font(.system(size: family == .systemSmall ? 14 : 18))
                    }
                }
                
                Spacer()
                
                // Status
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.status.shortMessage)
                        .font(.system(size: family == .systemSmall ? 12 : 14, weight: .semibold))
                        .foregroundColor(entry.status.swiftUIColor)
                    
                    if family != .systemSmall {
                        Text(entry.status.mainMessage)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                }
                
                // Progress Bar
                HStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                entry.status.stage > index
                                ? entry.status.swiftUIColor
                                : Color.white.opacity(0.2)
                            )
                            .frame(height: 4)
                    }
                }
                
                // Estimated Time
                if let time = entry.estimatedTime, family != .systemSmall {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.Brand.purple)
                        
                        Text(time)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(family == .systemSmall ? 12 : 16)
        }
    }
    
    // MARK: - No Order View
    private var noOrderView: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.Brand.background,
                    Color.Brand.dark
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 12) {
                Image(systemName: "bag.fill")
                    .font(.system(size: family == .systemSmall ? 24 : 32))
                    .foregroundColor(Color.Brand.purple)
                
                Text("No Active Orders")
                    .font(.system(size: family == .systemSmall ? 12 : 14, weight: .semibold))
                    .foregroundColor(.white)
                
                if family != .systemSmall {
                    Text("Order something delicious!")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.Brand.darkGray.opacity(0.7))
                }
            }
            .padding()
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Widget Configuration
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 16.1, *)
struct OrderTrackingWidget: Widget {
    let kind: String = "OrderTrackingWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: OrderWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                OrderTrackingWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color.Brand.background
                    }
            } else {
                OrderTrackingWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Order Tracking")
        .description("Track your current order status at a glance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Preview
// ═══════════════════════════════════════════════════════════════════════════
@available(iOS 17.0, *)
#Preview("Small", as: .systemSmall) {
    OrderTrackingWidget()
} timeline: {
    OrderWidgetEntry.placeholder
    OrderWidgetEntry.snapshot
}

@available(iOS 17.0, *)
#Preview("Medium", as: .systemMedium) {
    OrderTrackingWidget()
} timeline: {
    OrderWidgetEntry.placeholder
    OrderWidgetEntry.snapshot
    OrderWidgetEntry.noActiveOrder
}
