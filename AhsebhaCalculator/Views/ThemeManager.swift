//
//  ThemeManager.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-17.
//

import SwiftUI

/// Controls the app-wide appearance choice.
/// Values are stored in AppStorage using `AppAppearance.storageKey`.
enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case dark
    case light
    
    var id: String { rawValue }
    
    static let storageKey = "selectedAppearance"
    
    var title: String {
        switch self {
        case .system:
            return "مطابق للجهاز"
        case .dark:
            return "الوضع الداكن"
        case .light:
            return "الوضع الفاتح"
        }
    }
    
    var subtitle: String {
        switch self {
        case .system:
            return "يتبع إعدادات iPhone تلقائيًا"
        case .dark:
            return "مظهر داكن مناسب للاستخدام الليلي"
        case .light:
            return "مظهر فاتح وواضح في الإضاءة العالية"
        }
    }
    
    var icon: String {
        switch self {
        case .system:
            return "iphone"
        case .dark:
            return "moon.fill"
        case .light:
            return "sun.max.fill"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
    
    static func fromStoredValue(_ value: String) -> AppAppearance {
        AppAppearance(rawValue: value) ?? .system
    }
}
