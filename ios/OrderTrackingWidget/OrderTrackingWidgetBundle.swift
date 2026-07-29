//
//  OrderTrackingWidgetBundle.swift
//  OrderTrackingWidget
//
//  Created by Omnia Neil on 31/01/2026.
//  ✨ Enhanced Professional Version
//

import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
@main
struct OrderTrackingWidgetBundle: WidgetBundle {
    
    var body: some Widget {
        // 🏠 Home Screen Widget
        OrderTrackingWidget()
        
        // 📱 Live Activity Widget
        OrderTrackingWidgetLiveActivity()
    }
}

// Note: Brand colors are defined in BrandColors.swift

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 Widget Utilities
// ═══════════════════════════════════════════════════════════════════════════
struct WidgetUtils {
    
    /// Format time remaining
    static func formatTimeRemaining(_ minutes: Int) -> String {
        if minutes < 1 {
            return "Any moment"
        } else if minutes == 1 {
            return "1 min"
        } else if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) hr"
            }
            return "\(hours) hr \(remainingMinutes) min"
        }
    }
    
    /// Parse estimated time string to minutes
    static func parseEstimatedTime(_ timeString: String) -> Int? {
        let numbers = timeString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
        
        if numbers.count >= 2 {
            // Range like "15-20 min" - return average
            return (numbers[0] + numbers[1]) / 2
        } else if numbers.count == 1 {
            return numbers[0]
        }
        return nil
    }
}
