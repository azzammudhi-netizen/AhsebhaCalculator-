import SwiftUI

struct AhsebhaView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private let appShareText = """
    جرب تطبيق احسبها للحاسبات والأدوات العربية:
    https://www.ahsebha.com
    """
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 22) {
                        heroSection
                        featuresSection
                        websiteCard
                        noteCard
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
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
        VStack(alignment: .center, spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(colorScheme == .light ? Color.white.opacity(0.86) : AppTheme.secondaryBackground)
                    .frame(width: 104, height: 104)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.22 : 0.32), lineWidth: 1)
                    )
                    .shadow(color: cardShadow, radius: 16, x: 0, y: 8)
                
                VStack(spacing: 8) {
                    Image(systemName: "plus.forwardslash.minus")
                        .font(.system(size: 34, weight: .black))
                        .foregroundColor(AppTheme.buttonOrange)
                    
                    HStack(spacing: 5) {
                        heroMiniKey("٪")
                        heroMiniKey("=")
                        heroMiniKey("+")
                    }
                }
            }
            
            VStack(spacing: 8) {
                Text("احسبها")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("حاسبات عربية سريعة للحياة اليومية والدراسة والمال.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 10)
            }
            
            HStack(spacing: 12) {
                miniStat(icon: "gift.fill", title: "مجاني", value: "100%", tint: softOrange)
                miniStat(icon: "apps.iphone", title: "أدوات", value: "13", tint: softBlue)
                miniStat(icon: "globe", title: "عربي", value: "RTL", tint: softPurple)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(22)
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
    
    private func heroMiniKey(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundColor(text == "=" ? .black : AppTheme.primaryText)
            .frame(width: 24, height: 24)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(text == "=" ? AppTheme.buttonOrange : AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.13 : 0.22))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.18 : 0.28), lineWidth: 1)
            )
    }
    
    private func miniStat(icon: String, title: String, value: String, tint: Color) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(colorScheme == .light ? 0.12 : 0.20))
                )
            
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow.opacity(0.8), radius: 9, x: 0, y: 5)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("لماذا احسبها؟")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            AhsebhaFeatureRow(
                icon: "graduationcap.fill",
                title: "حاسبات تعليمية",
                subtitle: "المعدل التراكمي والنسبة الموزونة للطلاب.",
                tint: softBlue
            )
            
            AhsebhaFeatureRow(
                icon: "percent",
                title: "حاسبات يومية",
                subtitle: "النسبة، الخصم، وضريبة القيمة المضافة.",
                tint: softOrange
            )
            
            AhsebhaFeatureRow(
                icon: "wifi.slash",
                title: "تعمل بدون إنترنت",
                subtitle: "يمكن استخدام أغلب الأدوات مباشرة على الآيفون.",
                tint: softGreen
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var websiteCard: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "safari.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(softBlue)
                .frame(width: 58, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(softBlue.opacity(colorScheme == .light ? 0.12 : 0.20))
                )
            
            VStack(spacing: 7) {
                Text("المزيد على Ahsebha.com")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("تعرّف على مزيد من الحاسبات والمحتوى التعليمي من منصة احسبها.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 4)
            }
            
            Link(destination: URL(string: "https://www.ahsebha.com")!) {
                HStack(spacing: 8) {
                    Image(systemName: "safari.fill")
                    Text("زيارة الموقع")
                }
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .fill(AppTheme.buttonOrange)
                )
                .shadow(color: AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.26 : 0.18), radius: 12, x: 0, y: 6)
            }
            
            HStack(spacing: 12) {
                ShareLink(item: appShareText) {
                    secondaryActionLabel(icon: "square.and.arrow.up.fill", title: "شارك التطبيق")
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    AboutAppView()
                } label: {
                    secondaryActionLabel(icon: "info.circle.fill", title: "عن التطبيق")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(websiteBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 12, x: 0, y: 7)
    }
    
    private func secondaryActionLabel(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 16, weight: .bold, design: .rounded))
        .foregroundColor(AppTheme.primaryText)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }
    
    private var noteCard: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.12 : 0.20))
                )
            
            VStack(alignment: .center, spacing: 5) {
                Text("ملاحظة")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("التطبيق يركز على الحاسبات السريعة، بينما تتوفر بعض التفاصيل والمقالات عبر الموقع.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(17)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(noteBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }
    
    private var cardBackground: Color {
        colorScheme == .light ? Color.white.opacity(0.94) : AppTheme.secondaryBackground
    }
    
    private var heroBackground: Color {
        colorScheme == .light ? Color(red: 0.975, green: 0.965, blue: 1.0) : AppTheme.secondaryBackground
    }
    
    private var websiteBackground: Color {
        colorScheme == .light ? Color(red: 0.965, green: 0.982, blue: 1.0) : AppTheme.secondaryBackground
    }
    
    private var noteBackground: Color {
        colorScheme == .light ? Color(red: 1.0, green: 0.977, blue: 0.935) : AppTheme.secondaryBackground
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

struct AhsebhaFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 23, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(tint.opacity(colorScheme == .light ? 0.12 : 0.20))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(tint.opacity(colorScheme == .light ? 0.16 : 0.28), lineWidth: 1)
                )
            
            VStack(alignment: .center, spacing: 5) {
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(17)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(colorScheme == .light ? Color.white.opacity(0.94) : AppTheme.secondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.14 : 0.26), lineWidth: 1)
        )
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.065) : Color.clear, radius: 10, x: 0, y: 5)
    }
}

#Preview {
    AhsebhaView()
}
