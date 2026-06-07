import SwiftUI
import UIKit

struct DiscountCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var originalPrice: String = ""
    @State private var discountPercentage: String = ""
    
    private var originalPriceValue: Double? {
        validNumber(originalPrice)
    }
    
    private var discountPercentageValue: Double? {
        validNumber(discountPercentage)
    }
    
    private var discountAmount: Double? {
        guard let price = originalPriceValue,
              let discount = discountPercentageValue else {
            return nil
        }
        
        return price * discount / 100
    }
    
    private var finalPrice: Double? {
        guard let price = originalPriceValue,
              let discountAmount else {
            return nil
        }
        
        return max(price - discountAmount, 0)
    }
    
    private var result: DiscountCalculationResult? {
        guard let originalPriceValue,
              let discountPercentageValue,
              let discountAmount,
              let finalPrice else {
            return nil
        }
        
        return DiscountCalculationResult(
            originalPrice: originalPriceValue,
            discountPercentage: discountPercentageValue,
            discountAmount: discountAmount,
            finalPrice: finalPrice
        )
    }
    
    private func shareText(for result: DiscountCalculationResult) -> String {
        """
        حاسبة الخصم - احسبها
        
        السعر الأصلي:
        \(formatCurrency(result.originalPrice))
        
        نسبة الخصم:
        \(formatPercent(result.discountPercentage))
        
        قيمة التوفير:
        \(formatCurrency(result.discountAmount))
        
        السعر بعد الخصم:
        \(formatCurrency(result.finalPrice))
        """
    }
    
    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    headerSection
                    inputCard
                    resultCard
                    shareCard
                    detailsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("حاسبة الخصم")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("احسب السعر بعد الخصم وقيمة التوفير مباشرة.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var inputCard: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("بيانات الخصم")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            calculatorInput(title: "السعر الأصلي", placeholder: "250", value: $originalPrice, suffix: "ر.س", icon: "tag.fill")
            calculatorInput(title: "نسبة الخصم", placeholder: "15", value: $discountPercentage, suffix: "%", icon: "percent")
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(cardBorder, lineWidth: 1)
                )
        )
        .shadow(color: cardShadow, radius: cardShadowRadius, x: 0, y: cardShadowY)
    }
    
    private var resultCard: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(finalPriceText)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.buttonOrange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .center, spacing: 6) {
                    Text(finalPrice == nil ? "أدخل السعر والخصم" : "السعر بعد الخصم")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .multilineTextAlignment(.center)
                    
                    if let discountPercentageValue {
                        Text("وفرت \(formatPercent(discountPercentageValue))")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.buttonOrange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppTheme.buttonOrange.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                .frame(width: 132, alignment: .center)
            }
            .environment(\.layoutDirection, .leftToRight)
            
            Text(resultDescription)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(resultCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.20 : 0.28), lineWidth: 1)
                )
        )
        .shadow(color: cardShadow, radius: cardShadowRadius, x: 0, y: cardShadowY)
    }
    
    private var shareCard: some View {
        Group {
            if let result {
                ShareResultButton(
                    text: shareText(for: result),
                    sharedImage: resultCardImage(for: result)
                )
                .padding(16)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(cardBorder, lineWidth: 1)
                )
                .shadow(color: cardShadow, radius: cardShadowRadius, x: 0, y: cardShadowY)
            }
        }
    }
    
    private var detailsCard: some View {
        VStack(alignment: .trailing, spacing: 14) {
            HStack(spacing: 8) {
                Text("التوفير: \(discountPercentageText)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.buttonOrange)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(AppTheme.buttonOrange.opacity(0.12))
                    .clipShape(Capsule())
                
                Spacer()
                
                Text("تفاصيل الحساب")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
            }
            .environment(\.layoutDirection, .leftToRight)
            
            VStack(spacing: 0) {
                detailRow(title: "السعر الأصلي", value: originalPriceText)
                dividerLine
                detailRow(title: "نسبة الخصم", value: discountPercentageText)
                dividerLine
                detailRow(title: "قيمة التوفير", value: discountAmountText)
                dividerLine
                detailRow(title: "السعر بعد الخصم", value: finalPriceText, isHighlighted: true)
            }
            .background(innerCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(innerCardBorder, lineWidth: 1)
            )
        }
        .padding(18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: cardShadowRadius, x: 0, y: cardShadowY)
    }
    
    private func detailRow(title: String, value: String, isHighlighted: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.system(size: isHighlighted ? 16 : 15, weight: isHighlighted ? .bold : .medium, design: .rounded))
                .foregroundColor(isHighlighted ? AppTheme.primaryText : AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Spacer(minLength: 12)
            
            Text(value)
                .font(.system(size: isHighlighted ? 18 : 16, weight: .bold, design: .rounded))
                .foregroundColor(isHighlighted ? AppTheme.buttonOrange : AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(minWidth: 112, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, isHighlighted ? 13 : 11)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var finalPriceText: String {
        guard let finalPrice else { return "—" }
        return formatCurrency(finalPrice)
    }
    
    private var originalPriceText: String {
        guard let originalPriceValue else { return "—" }
        return formatCurrency(originalPriceValue)
    }
    
    private var discountPercentageText: String {
        guard let discountPercentageValue else { return "—" }
        return formatPercent(discountPercentageValue)
    }
    
    private var discountAmountText: String {
        guard let discountAmount else { return "—" }
        return formatCurrency(discountAmount)
    }
    
    private var resultDescription: String {
        guard finalPrice != nil else {
            return "أدخل السعر الأصلي ونسبة الخصم لبدء الحساب."
        }
        
        return "تم حساب السعر النهائي وقيمة التوفير بناءً على نسبة الخصم المدخلة."
    }
    
    private func calculatorInput(
        title: String,
        placeholder: String,
        value: Binding<String>,
        suffix: String,
        icon: String
    ) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)

            HStack(spacing: 10) {
                Text(suffix)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.buttonOrange)
                    .frame(width: 44, alignment: .center)

                HStack(spacing: 10) {
                    TextField(
                        text: value,
                        prompt: Text(placeholder)
                            .foregroundColor(AppTheme.secondaryText.opacity(colorScheme == .light ? 0.72 : 0.62))
                    ) {
                        Text(placeholder)
                    }
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .tint(AppTheme.buttonOrange)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.buttonOrange)
                        .frame(width: 42, height: 42)
                        .background(iconBadgeBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 12)
                .frame(height: 54)
                .background(inputFieldBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(inputFieldBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .environment(\.layoutDirection, .leftToRight)
            }
            .environment(\.layoutDirection, .leftToRight)
        }
        .frame(maxWidth: 560, alignment: .trailing)
    }
    
    private var dividerLine: some View {
        Rectangle()
            .fill(innerCardBorder)
            .frame(height: 1)
    }
    
    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }
    
    private var cardBackground: Color {
        colorScheme == .light ? Color.white : AppTheme.secondaryBackground
    }
    
    private var cardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : AppTheme.border
    }
    
    private var cardShadow: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : Color.clear
    }
    
    private var cardShadowRadius: CGFloat {
        colorScheme == .light ? 10 : 0
    }
    
    private var cardShadowY: CGFloat {
        colorScheme == .light ? 5 : 0
    }
    
    private var inputFieldBackground: Color {
        colorScheme == .light ? Color.white : AppTheme.inputBackground
    }
    
    private var inputFieldBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : AppTheme.border
    }
    
    private var iconBadgeBackground: Color {
        colorScheme == .light ? AppTheme.buttonOrange.opacity(0.10) : AppTheme.inputBackground
    }
    
    private var innerCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFC") : AppTheme.inputBackground
    }
    
    private var innerCardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : AppTheme.border
    }
    
    private var resultCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF7ED") : AppTheme.secondaryBackground
    }
    
    private func validNumber(_ text: String) -> Double? {
        let normalized = normalizeArabicNumbers(text)
            .replacingOccurrences(of: "٫", with: ".")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "٬", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let value = Double(normalized),
              value >= 0 else {
            return nil
        }
        
        return value
    }
    
    private func normalizeArabicNumbers(_ text: String) -> String {
        var result = text
        
        let arabicDigits = [
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9"
        ]
        
        let persianDigits = [
            "۰": "0", "۱": "1", "۲": "2", "۳": "3", "۴": "4",
            "۵": "5", "۶": "6", "۷": "7", "۸": "8", "۹": "9"
        ]
        
        for (arabic, english) in arabicDigits {
            result = result.replacingOccurrences(of: arabic, with: english)
        }
        
        for (persian, english) in persianDigits {
            result = result.replacingOccurrences(of: persian, with: english)
        }
        
        return result
    }
    
    private func formatCurrency(_ value: Double) -> String {
        "\(formatNumber(value)) ر.س"
    }
    
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    private func formatPercent(_ value: Double) -> String {
        "\(formatNumber(value))%"
    }
    
    @MainActor
    private func resultCardImage(for result: DiscountCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة الخصم - احسبها",
            rows: [
                ResultCardRow(title: "السعر الأصلي", value: formatCurrency(result.originalPrice)),
                ResultCardRow(title: "نسبة الخصم", value: formatPercent(result.discountPercentage)),
                ResultCardRow(title: "قيمة التوفير", value: formatCurrency(result.discountAmount)),
                ResultCardRow(title: "السعر بعد الخصم", value: formatCurrency(result.finalPrice), valueColor: AppTheme.buttonOrange)
            ],
            note: "النتائج تقديرية."
        )
    }
}

private struct DiscountCalculationResult {
    let originalPrice: Double
    let discountPercentage: Double
    let discountAmount: Double
    let finalPrice: Double
}

#Preview {
    NavigationStack {
        DiscountCalculatorView()
    }
}
