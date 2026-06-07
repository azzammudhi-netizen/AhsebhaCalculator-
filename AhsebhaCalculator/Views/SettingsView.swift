//
//  SettingsView.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-17.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.requestReview) private var requestReview
    
    @AppStorage(AppAppearance.storageKey) private var selectedAppearanceRawValue: String = AppAppearance.system.rawValue
    
    private var selectedAppearance: AppAppearance {
        AppAppearance.fromStoredValue(selectedAppearanceRawValue)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .trailing, spacing: 22) {
                        headerSection
                        aboutAppCard
                        appearanceSection
                        appActionsSection
                        appSection
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.buttonOrange.opacity(0.20))
                    .frame(width: 78, height: 78)
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(AppTheme.buttonOrange)
            }

            VStack(alignment: .center, spacing: 8) {
                Text("الإعدادات")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("خصص مظهر التطبيق وخيارات الاستخدام العامة.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var appearanceSection: some View {
        settingsCard(icon: "circle.lefthalf.filled", iconColor: AppTheme.buttonOrange) {
            VStack(alignment: .trailing, spacing: 16) {
                VStack(alignment: .trailing, spacing: 6) {
                    Text("المظهر")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text("اختر مظهر التطبيق المناسب لك.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                VStack(spacing: 12) {
                    ForEach(AppAppearance.allCases) { appearance in
                        appearanceOption(appearance)
                    }
                }
            }
        }
    }
    
    private var aboutAppCard: some View {
        settingsCard(icon: "app.badge.fill", iconColor: AppTheme.buttonOrange) {
            VStack(alignment: .trailing, spacing: 10) {
                Text("احسبها | Ahsebha")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Text("حاسبات يومية وتعليمية ومالية\nبتجربة عربية سريعة وسهلة.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                HStack(spacing: 8) {
                    Text(appVersionText)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.buttonOrange)
                    
                    Text("الإصدار")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.secondaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.buttonOrange.opacity(0.10))
                .clipShape(Capsule())
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private var appActionsSection: some View {
        settingsCard(icon: "square.grid.2x2.fill", iconColor: AppTheme.accent) {
            VStack(alignment: .trailing, spacing: 12) {
                Text("روابط التطبيق")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                ShareLink(item: appShareText) {
                    actionRowContent(title: "مشاركة التطبيق", value: "أرسل احسبها لمن يحتاجه", icon: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                
                dividerLine
                
                Button {
                    requestReview()
                } label: {
                    actionRowContent(title: "قيّم التطبيق", value: "ادعمنا بتقييمك في المتجر", icon: "star.fill")
                }
                .buttonStyle(.plain)
                
                dividerLine
                
                Link(destination: privacyPolicyURL) {
                    actionRowContent(title: "سياسة الخصوصية", value: "اطّلع على طريقة التعامل مع البيانات", icon: "lock.shield.fill")
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var appSection: some View {
        settingsCard(icon: "iphone", iconColor: AppTheme.accent) {
            VStack(alignment: .trailing, spacing: 14) {
                Text("التطبيق")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                infoRow(title: "الإصدار", value: appVersionText, icon: "number")
                dividerLine
                infoRow(title: "المظهر الحالي", value: selectedAppearance.title, icon: selectedAppearance.icon)
            }
        }
    }
    
    private func appearanceOption(_ appearance: AppAppearance) -> some View {
        let isSelected = selectedAppearanceRawValue == appearance.rawValue
        
        return Button {
            selectedAppearanceRawValue = appearance.rawValue
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isSelected ? AppTheme.buttonOrange : AppTheme.secondaryText)
                
                Spacer(minLength: 0)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(appearance.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(appearance.subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Image(systemName: appearance.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.buttonOrange)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.buttonOrange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isSelected ? AppTheme.buttonOrange.opacity(0.12) : optionBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(isSelected ? AppTheme.buttonOrange.opacity(0.35) : AppTheme.secondaryText.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private func infoRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            
            Spacer(minLength: 0)
            
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
            
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 36, height: 36)
                .background(AppTheme.buttonOrange.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private func actionRowContent(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "chevron.left")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.secondaryText.opacity(0.70))
            
            Spacer(minLength: 0)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Text(value)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 38, height: 38)
                .background(AppTheme.buttonOrange.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(actionRowBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(actionRowBorder, lineWidth: 1)
                )
        )
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private func settingsCard<Content: View>(
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .trailing, spacing: 0) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            Image(systemName: icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(iconColor)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(settingsCardBackground(for: icon))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(settingsCardBorder, lineWidth: 1)
                )
        )
        .shadow(color: settingsCardShadow, radius: colorScheme == .light ? 10 : 12, x: 0, y: colorScheme == .light ? 5 : 6)
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private var dividerLine: some View {
        Rectangle()
            .fill(AppTheme.secondaryText.opacity(0.12))
            .frame(height: 1)
    }
    
    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    private func settingsCardBackground(for icon: String) -> Color {
        guard colorScheme == .light else {
            return AppTheme.secondaryBackground
        }
        
        switch icon {
        case "app.badge.fill":
            return Color(hex: "#FFF8EF")
        case "circle.lefthalf.filled":
            return Color(hex: "#F5F3FF")
        case "square.grid.2x2.fill":
            return Color(hex: "#F3FAFF")
        case "iphone":
            return Color(hex: "#F7FBF7")
        default:
            return Color(hex: "#FAFBFD")
        }
    }
    
    private var settingsCardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : AppTheme.secondaryText.opacity(0.12)
    }
    
    private var settingsCardShadow: Color {
        colorScheme == .light ? Color.black.opacity(0.065) : AppTheme.shadow
    }
    
    private var actionRowBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFC") : AppTheme.background.opacity(0.70)
    }

    private var optionBackground: Color {
        colorScheme == .light ? Color.white.opacity(0.72) : AppTheme.background.opacity(0.70)
    }
    
    private var actionRowBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.05) : AppTheme.secondaryText.opacity(0.12)
    }
    
    private var appShareText: String {
        """
        احسبها | Ahsebha Calculator
        حاسبات تعليمية ومالية وعامة بتجربة عربية سهلة.
        https://www.ahsebha.com
        """
    }
    
    private var privacyPolicyURL: URL {
        URL(string: "https://www.ahsebha.com/privacy")!
    }
}

#Preview {
    SettingsView()
}
