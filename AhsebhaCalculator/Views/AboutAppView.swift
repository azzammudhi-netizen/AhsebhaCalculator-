import SwiftUI

struct AboutAppView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private let shareText = """
    جرّب تطبيق احسبها:
    حاسبات تعليمية ومالية وعامة بتصميم عربي سريع ومناسب للايفون.

    https://www.ahsebha.com
    """
    
    var body: some View {
        ZStack {
            backgroundView.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 22) {
                    heroSection
                    featuresSection
                    actionsCard
                    noteCard
                }
                .padding(20)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(iconOuterBackground)
                    .frame(width: 104, height: 104)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.22 : 0.34), lineWidth: 1)
                    )
                    .shadow(color: cardShadow, radius: 16, x: 0, y: 8)
                
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(cardBackground)
                    .frame(width: 74, height: 74)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(cardBorder, lineWidth: 1)
                    )
                
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(AppTheme.buttonOrange)
            }
            
            VStack(spacing: 8) {
                Text("عن التطبيق")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("احسبها يجمع حاسبات تعليمية ومالية ويومية في تجربة عربية سريعة ومنظمة.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 8)
            }
            
            HStack(spacing: 10) {
                heroPill("تعليمي")
                heroPill("مالي")
                heroPill("يومي")
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
    
    private func heroPill(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(AppTheme.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(cardBackground)
            )
            .overlay(
                Capsule()
                    .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.16 : 0.26), lineWidth: 1)
            )
    }
    
    private var featuresSection: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("المزايا الحالية")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            AboutFeatureRow(
                icon: "graduationcap.fill",
                title: "الحاسبات التعليمية",
                subtitle: "المعدل التراكمي والنسبة الموزونة للطلاب."
            )
            
            AboutFeatureRow(
                icon: "banknote.fill",
                title: "الحاسبات المالية",
                subtitle: "التمويل، الضريبة، الخصم، التقاعد، ونهاية الخدمة."
            )
            
            AboutFeatureRow(
                icon: "calendar.badge.clock",
                title: "أدوات التاريخ والتحويل",
                subtitle: "العمر، تحويل التاريخ، الفرق بين تاريخين، وأسماء الأشهر."
            )
            
            AboutFeatureRow(
                icon: "star.fill",
                title: "المفضلة وآخر استخدام",
                subtitle: "وصول أسرع للأدوات التي تحتاجها كثيرًا."
            )
            
            AboutFeatureRow(
                icon: "square.and.arrow.up",
                title: "مشاركة النتائج",
                subtitle: "مشاركة النتائج كنص أو بطاقة حسب الحاسبة."
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var actionsCard: some View {
        VStack(alignment: .center, spacing: 16) {
            VStack(spacing: 6) {
                Text("روابط مهمة")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("تابع احسبها أو شارك التطبيق مع من يحتاجه.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Link(destination: URL(string: "https://www.ahsebha.com")!) {
                actionButtonContent(icon: "safari.fill", title: "زيارة موقع احسبها", isPrimary: true)
            }
            
            ShareLink(item: shareText) {
                actionButtonContent(icon: "square.and.arrow.up", title: "مشاركة التطبيق", isPrimary: false)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(actionsBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 12, x: 0, y: 7)
    }
    
    private func actionButtonContent(icon: String, title: String, isPrimary: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 17, weight: .bold, design: .rounded))
        .foregroundColor(isPrimary ? .black : AppTheme.primaryText)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isPrimary ? AppTheme.buttonOrange : cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isPrimary ? Color.white.opacity(colorScheme == .light ? 0.30 : 0.10) : cardBorder, lineWidth: 1)
        )
        .shadow(color: isPrimary ? AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.24 : 0.16) : Color.clear, radius: 12, x: 0, y: 6)
    }
    
    private var noteCard: some View {
        VStack(alignment: .center, spacing: 14) {
            Image(systemName: "map.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(softPurple)
                .frame(width: 54, height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(softPurple.opacity(colorScheme == .light ? 0.12 : 0.20))
                )
            
            VStack(spacing: 7) {
                Text("تطوير مستمر")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("احسبها يتطور تدريجيًا بإضافة أدوات جديدة وتحسين الويدجت وتجربة المشاركة بما يخدم الاستخدام اليومي.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(19)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(noteBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(softPurple.opacity(colorScheme == .light ? 0.14 : 0.26), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }
    
    private var cardBackground: Color {
        colorScheme == .light ? Color.white.opacity(0.94) : AppTheme.secondaryBackground
    }
    
    private var heroBackground: Color {
        colorScheme == .light ? Color(red: 0.975, green: 0.965, blue: 1.0) : AppTheme.secondaryBackground
    }
    
    private var iconOuterBackground: Color {
        colorScheme == .light ? Color(red: 1.0, green: 0.966, blue: 0.905) : AppTheme.inputBackground
    }
    
    private var actionsBackground: Color {
        colorScheme == .light ? Color(red: 0.965, green: 0.982, blue: 1.0) : AppTheme.secondaryBackground
    }
    
    private var noteBackground: Color {
        colorScheme == .light ? Color(red: 0.972, green: 0.965, blue: 1.0) : AppTheme.secondaryBackground
    }
    
    private var cardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.055) : AppTheme.border.opacity(0.75)
    }
    
    private var cardShadow: Color {
        colorScheme == .light ? Color.black.opacity(0.07) : Color.clear
    }
    
    private var softPurple: Color {
        Color(red: 0.48, green: 0.36, blue: 0.86)
    }
}

struct AboutFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(17)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.14 : 0.26), lineWidth: 1)
        )
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.065) : Color.clear, radius: 10, x: 0, y: 5)
    }
    
    private var cardBackground: Color {
        colorScheme == .light ? featureBackground : AppTheme.secondaryBackground
    }
    
    private var featureBackground: Color {
        switch icon {
        case "graduationcap.fill":
            return Color(red: 0.955, green: 0.972, blue: 1.0)
        case "banknote.fill":
            return Color(red: 0.950, green: 0.985, blue: 0.965)
        case "calendar.badge.clock":
            return Color(red: 0.970, green: 0.960, blue: 1.0)
        case "star.fill":
            return Color(red: 1.0, green: 0.975, blue: 0.930)
        default:
            return Color(red: 0.950, green: 0.985, blue: 0.995)
        }
    }
    
    private var tint: Color {
        switch icon {
        case "graduationcap.fill":
            return Color(red: 0.22, green: 0.46, blue: 0.92)
        case "banknote.fill":
            return Color(red: 0.10, green: 0.58, blue: 0.42)
        case "calendar.badge.clock":
            return Color(red: 0.48, green: 0.36, blue: 0.86)
        case "star.fill":
            return AppTheme.buttonOrange
        default:
            return Color(red: 0.16, green: 0.55, blue: 0.72)
        }
    }
}

#Preview {
    NavigationStack {
        AboutAppView()
    }
}
