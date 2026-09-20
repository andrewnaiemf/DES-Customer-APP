import Foundation
import ActivityKit
import UIKit

/// Updates the lock-screen Live Activity from an APNs/FCM payload
/// without waiting for Flutter to come to the foreground.
enum LiveActivityRemoteUpdater {
  static func update(from userInfo: [AnyHashable: Any]) {
    if #available(iOS 16.2, *) {
      updateActivities(from: flatten(userInfo))
    }
  }

  @available(iOS 16.2, *)
  private static func updateActivities(from payload: [String: String]) {
    let screen = payload["screen"] ?? ""
    let shipping = payload["shipping_status"] ?? payload["shippingStatus"] ?? ""
    let status = shippingStep(screen: screen, shipping: shipping, generic: payload["status"] ?? "")
    guard !status.isEmpty else { return }

    let orderId = payload["order_id"] ?? payload["orderId"] ?? payload["id"] ?? ""
    let parsed = OrderStatus.from(status)
    let language = payload["language"] ?? payload["locale"] ?? "ar"

    let activities = Activity<OrderTrackingAttributes>.activities
    let matches = activities.filter { activity in
      orderId.isEmpty
        || activity.attributes.orderId == orderId
        || activity.attributes.orderReference == orderId
    }
    guard !matches.isEmpty else {
      print("⚠️ LiveActivityRemoteUpdater: no activity for order \(orderId) status \(status)")
      return
    }

    let state = OrderTrackingAttributes.ContentState(
      status: parsed,
      estimatedTime: payload["estimated_delivery"] ?? payload["estimatedTime"],
      driverName: payload["driver_name"] ?? payload["driverName"],
      driverPhone: payload["driver_phone"] ?? payload["driverPhone"],
      driverImageURL: nil,
      lastUpdate: Date(),
      additionalMessage: payload["statusDescription"],
      language: language
    )
    let staleDate: Date? = (parsed == .delivered || parsed == .cancelled)
      ? Calendar.current.date(byAdding: .hour, value: 24, to: Date())
      : nil
    let content = ActivityContent(state: state, staleDate: staleDate)

    Task {
      for activity in matches {
        await activity.update(content)
        print("✅ LiveActivityRemoteUpdater updated \(activity.attributes.orderId) → \(parsed.rawValue)")
      }
    }
  }

  private static func shippingStep(screen: String, shipping: String, generic: String) -> String {
    let orderLevel: Set<String> = ["approved", "draft", "pending", "declined", "rejected"]
    let steps: Set<String> = [
      "received", "processing", "delivery", "delivered",
      "canceled", "cancelled", "approved"
    ]
    let screenNorm = screen.lowercased()
    let shippingNorm = shipping.lowercased()
    if !screen.isEmpty && steps.contains(screenNorm) {
      return screen
    }
    if !shipping.isEmpty && !orderLevel.contains(shippingNorm) {
      return shipping
    }
    if !screen.isEmpty { return screen }
    if !generic.isEmpty && !orderLevel.contains(generic.lowercased()) {
      return generic
    }
    return shipping.isEmpty ? screen : shipping
  }

  private static func flatten(_ userInfo: [AnyHashable: Any]) -> [String: String] {
    var out: [String: String] = [:]
    func walk(_ value: Any, prefix: String?) {
      if let dict = value as? [AnyHashable: Any] {
        for (key, nested) in dict {
          let name = String(describing: key)
          walk(nested, prefix: name)
        }
        return
      }
      guard let prefix else { return }
      if let str = value as? String, !str.isEmpty {
        out[prefix] = str
      } else if let num = value as? NSNumber {
        out[prefix] = num.stringValue
      }
    }
    walk(userInfo, prefix: nil)
    return out
  }

  static func hexToken(_ data: Data) -> String {
    data.map { String(format: "%02x", $0) }.joined()
  }
}
