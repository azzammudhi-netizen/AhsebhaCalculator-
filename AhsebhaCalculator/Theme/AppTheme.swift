//
//  AppTheme.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-11.
//

import SwiftUI
import UIKit

struct AppTheme {

    // MARK: - Backgrounds

    static let background = Color.dynamic(
        light: UIColor(hex: "#F4F6FA"),
        dark: UIColor(hex: "#0D0F14")
    )
    
    static let secondaryBackground = Color.dynamic(
        light: UIColor(hex: "#FFFFFF"),
        dark: UIColor(hex: "#1A1D26")
    )

    static let inputBackground = Color.dynamic(
        light: UIColor(hex: "#EEF2F7"),
        dark: UIColor(hex: "#22252E")
    )

    static let border = Color.dynamic(
        light: UIColor(hex: "#D8DEE9"),
        dark: UIColor(hex: "#2E323D")
    )

    // MARK: - Calculator Buttons

    static let buttonDark = Color.dynamic(
        light: UIColor(hex: "#E8ECF3"),
        dark: UIColor(hex: "#22252E")
    )
    
    static let buttonGray = Color.dynamic(
        light: UIColor(hex: "#D8DEE9"),
        dark: UIColor(hex: "#2E323D")
    )
    
    static let buttonOrange = Color(hex: "#FF9F0A")

    // MARK: - Text Colors

    static let primaryText = Color.dynamic(
        light: UIColor(hex: "#111827"),
        dark: UIColor(hex: "#FFFFFF")
    )
    
    static let secondaryText = Color.dynamic(
        light: UIColor(hex: "#6B7280"),
        dark: UIColor(hex: "#9CA3AF")
    )

    // MARK: - Accent

    static let accent = Color.dynamic(
        light: UIColor(hex: "#007AFF"),
        dark: UIColor(hex: "#5AC8FA")
    )

    // MARK: - Shadows

    static let shadow = Color.dynamic(
        light: UIColor.black.withAlphaComponent(0.10),
        dark: UIColor.black.withAlphaComponent(0.35)
    )
}

// MARK: - Dynamic Color Support

extension Color {
    static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}

// MARK: - Hex Color Support

extension Color {
    init(hex: String) {

        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64

        switch hex.count {
        case 3:
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )

        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        
        switch hex.count {
        case 3:
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
            
        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
            
        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
            
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
