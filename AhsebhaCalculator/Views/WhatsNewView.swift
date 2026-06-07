//
//  WhatsNewView.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-13.
//

import SwiftUI

struct WhatsNewView: View {
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            backgroundView
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 22) {
                        heroSection
                        updatesSection
                        highlightsSection
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 34)
                    .padding(.bottom, 24)
                }

                Button {
                    onContinue()
                } label: {
                    Text("متابعة")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(AppTheme.buttonOrange)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(colorScheme == .light ? 0.35 : 0.12), lineWidth: 1)
                        )
                        .shadow(color: AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.30 : 0.20), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, 22)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: colorScheme == .light
                ? [
                    Color(red: 0.98, green: 0.985, blue: 0.995),
                    Color(red: 1.0, green: 0.977, blue: 0.948),
                    Color(red: 0.968, green: 0.975, blue: 1.0)
                ]
                : [
                    AppTheme.background,
                    AppTheme.secondaryBackground,
                    AppTheme.background
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var heroSection: some View {
        VStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(heroIconBackground)
                    .frame(width: 112, height: 112)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.20 : 0.32), lineWidth: 1)
                    )
                    .shadow(color: cardShadow, radius: 16, x: 0, y: 8)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(cardBackground)
                    .frame(width: 78, height: 78)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(cardBorder, lineWidth: 1)
                    )

                Image(systemName: "sparkles")
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(AppTheme.buttonOrange)
            }

            VStack(spacing: 8) {
                Text("ما الجديد؟")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("أحدث التحسينات والإضافات في احسبها")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(heroBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 14, x: 0, y: 8)
    }

    private var updatesSection: some View {
        VStack(alignment: .center, spacing: 13) {
            Text("التحديثات الرئيسية")
                .font(.system(size: 23, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            updateItem(
                icon: "percent",
                title: "إضافة حاسبة الضريبة",
                subtitle: "حساب الضريبة والإجمالي بتصميم أوضح.",
                tint: softOrange
            )

            updateItem(
                icon: "rectangle.grid.1x2",
                title: "تحسين الويدجت",
                subtitle: "وصول أسرع إلى الأدوات من الشاشة الرئيسية.",
                tint: softBlue
            )

            updateItem(
                icon: "bolt.fill",
                title: "تحسين الأداء والاستقرار",
                subtitle: "تجربة أسرع وأكثر سلاسة أثناء الاستخدام.",
                tint: softGreen
            )

            updateItem(
                icon: "wand.and.stars",
                title: "تحسين شاشة الترحيب",
                subtitle: "تصميم أحدث وأقرب لهوية احسبها الجديدة.",
                tint: softPurple
            )
        }
    }

    private var highlightsSection: some View {
        VStack(alignment: .center, spacing: 13) {
            Text("تحسينات إضافية")
                .font(.system(size: 23, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                highlightCard(icon: "paintbrush.pointed.fill", title: "تحسين تصميم الحاسبات", tint: softPurple)
                highlightCard(icon: "plus.app.fill", title: "أدوات جديدة", tint: softOrange)
                highlightCard(icon: "hand.tap.fill", title: "تحسين تجربة الاستخدام", tint: softBlue)
                highlightCard(icon: "speedometer", title: "تحسينات الأداء", tint: softGreen)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(highlightSectionBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 12, x: 0, y: 7)
    }

    private func updateItem(
        icon: String,
        title: String,
        subtitle: String,
        tint: Color
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 52, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(tint.opacity(colorScheme == .light ? 0.12 : 0.20))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .stroke(tint.opacity(colorScheme == .light ? 0.16 : 0.28), lineWidth: 1)
                )

            VStack(alignment: .trailing, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Spacer(minLength: 0)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.13 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func highlightCard(icon: String, title: String, tint: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 46, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(tint.opacity(colorScheme == .light ? 0.12 : 0.20))
                )

            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 112)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.12 : 0.24), lineWidth: 1)
        )
    }

    private var cardBackground: Color {
        colorScheme == .light ? Color.white.opacity(0.94) : AppTheme.secondaryBackground
    }

    private var heroBackground: Color {
        colorScheme == .light ? Color(red: 0.975, green: 0.965, blue: 1.0) : AppTheme.secondaryBackground
    }

    private var heroIconBackground: Color {
        colorScheme == .light ? Color(red: 1.0, green: 0.966, blue: 0.905) : AppTheme.inputBackground
    }

    private var highlightSectionBackground: Color {
        colorScheme == .light ? Color(red: 0.965, green: 0.982, blue: 1.0) : AppTheme.secondaryBackground
    }

    private var cardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.055) : AppTheme.border.opacity(0.75)
    }

    private var cardShadow: Color {
        colorScheme == .light ? Color.black.opacity(0.07) : Color.clear
    }

    private var softOrange: Color {
        AppTheme.buttonOrange
    }

    private var softBlue: Color {
        Color(red: 0.22, green: 0.46, blue: 0.92)
    }

    private var softGreen: Color {
        Color(red: 0.10, green: 0.58, blue: 0.42)
    }

    private var softPurple: Color {
        Color(red: 0.48, green: 0.36, blue: 0.86)
    }
}

#Preview {
    WhatsNewView {}
}
