import SwiftUI
import UIKit

struct VATCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedMode: VATMode = .addVAT
    
    @State private var amount: String = ""
    @State private var vatRate: String = "15"
    
    private var amountValue: Double? {
        validNumber(amount)
    }
    
    private var vatRateValue: Double {
        validNumber(vatRate) ?? 15
    }
    
    private var vatAmount: Double? {
        guard let amountValue else { return nil }
        
        switch selectedMode {
        case .addVAT:
            return amountValue * vatRateValue / 100
            
        case .removeVAT:
            let baseAmount = amountValue / (1 + vatRateValue / 100)
            return amountValue - baseAmount
            
        case .vatOnly:
            return amountValue * vatRateValue / 100
        }
    }
    
    private var finalAmount: Double? {
        guard let amountValue else { return nil }
        
        switch selectedMode {
        case .addVAT:
            return amountValue + (amountValue * vatRateValue / 100)
            
        case .removeVAT:
            return amountValue / (1 + vatRateValue / 100)
            
        case .vatOnly:
            return amountValue * vatRateValue / 100
        }
    }
    
    private var result: VATCalculationResult? {
        guard let amountValue,
              let vatAmount,
              let finalAmount else {
            return nil
        }
        
        return VATCalculationResult(
            mode: selectedMode,
            amount: amountValue,
            vatRate: vatRateValue,
            vatAmount: vatAmount,
            finalAmount: finalAmount
        )
    }
    
    private func shareText(for result: VATCalculationResult) -> String {
        """
        حاسبة ضريبة القيمة المضافة - احسبها
        
        الوضع:
        \(result.mode.title)
        
        المبلغ:
        \(formatCurrency(result.amount))
        
        النسبة:
        \(formatPercent(result.vatRate))
        
        قيمة الضريبة:
        \(formatCurrency(result.vatAmount))
        
        الإجمالي أو الناتج:
        \(formatCurrency(result.finalAmount))
        """
    }
    
    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    headerSection
                    modeSelector
                    inputCard
                    resultCard
                    infoCard
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
            Text("حاسبة الضريبة")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("احسب ضريبة القيمة المضافة بإضافة الضريبة أو إزالتها من السعر.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var modeSelector: some View {
        HStack(spacing: 6) {
            ForEach(VATMode.allCases) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    Text(mode.segmentTitle)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(selectedMode == mode ? .white : AppTheme.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                    .background(
                        Capsule()
                            .fill(selectedMode == mode ? AppTheme.buttonOrange : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(cardBackground)
                .overlay(
                    Capsule()
                        .stroke(cardBorder, lineWidth: 1)
                )
                .shadow(color: cardShadow, radius: cardShadowRadius, x: 0, y: cardShadowY)
        )
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var inputCard: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("بيانات الضريبة")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            calculatorInput(title: selectedMode.amountTitle, placeholder: selectedMode.amountPlaceholder, value: $amount, suffix: "ر.س", icon: "banknote.fill")
            calculatorInput(title: "نسبة الضريبة", placeholder: "15", value: $vatRate, suffix: "%", icon: "percent")
            
            Text("النسبة الافتراضية في السعودية هي 15%. يمكنك تعديلها عند الحاجة.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
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
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var resultCard: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("النتيجة")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            if let result {
                VStack(spacing: 0) {
                    ForEach(Array(resultRows(for: result).enumerated()), id: \.offset) { index, row in
                        resultRow(title: row.title, value: row.value, isHighlighted: index == 0)
                        
                        if index < resultRows(for: result).count - 1 {
                            dividerLine
                        }
                    }
                }
                .background(innerCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(innerCardBorder, lineWidth: 1)
                )
                
                ShareResultButton(
                    text: shareText(for: result),
                    sharedImage: resultCardImage(for: result)
                )
            } else {
                emptyResultContent
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: cardShadowRadius, x: 0, y: cardShadowY)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var infoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .center, spacing: 8) {
                Text("معلومة")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("ضريبة القيمة المضافة المعتمدة في المملكة العربية السعودية هي 15٪ ويمكن تعديل النسبة حسب الحاجة.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Image(systemName: "info.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(infoCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(infoCardBorder, lineWidth: 1)
                )
        )
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var emptyResultContent: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "plus.forwardslash.minus")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
            
            Text("أدخل المبلغ لعرض النتيجة")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("أدخل المبلغ ونسبة الضريبة لبدء الحساب.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(innerCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private var amountText: String {
        guard let amountValue else { return "—" }
        return formatCurrency(amountValue)
    }
    
    private var finalAmountText: String {
        guard let finalAmount else { return "—" }
        return formatCurrency(finalAmount)
    }
    
    private var vatAmountText: String {
        guard let vatAmount else { return "—" }
        return formatCurrency(vatAmount)
    }

    private func calculatorInput(
        title: String,
        placeholder: String,
        value: Binding<String>,
        suffix: String,
        icon: String
    ) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
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
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
    
    private func resultRows(for result: VATCalculationResult) -> [VATDisplayRow] {
        switch result.mode {
        case .addVAT:
            return [
                VATDisplayRow(title: "المبلغ بعد الضريبة", value: formatCurrency(result.finalAmount)),
                VATDisplayRow(title: "المبلغ الأصلي", value: formatCurrency(result.amount)),
                VATDisplayRow(title: "قيمة الضريبة", value: formatCurrency(result.vatAmount)),
                VATDisplayRow(title: "نسبة الضريبة", value: formatPercent(result.vatRate))
            ]
        case .removeVAT:
            return [
                VATDisplayRow(title: "المبلغ شامل الضريبة", value: formatCurrency(result.amount)),
                VATDisplayRow(title: "المبلغ قبل الضريبة", value: formatCurrency(result.finalAmount)),
                VATDisplayRow(title: "قيمة الضريبة", value: formatCurrency(result.vatAmount)),
                VATDisplayRow(title: "نسبة الضريبة", value: formatPercent(result.vatRate))
            ]
        case .vatOnly:
            return [
                VATDisplayRow(title: "قيمة الضريبة", value: formatCurrency(result.vatAmount)),
                VATDisplayRow(title: "المبلغ", value: formatCurrency(result.amount)),
                VATDisplayRow(title: "نسبة الضريبة", value: formatPercent(result.vatRate))
            ]
        }
    }
    
    private func resultRow(title: String, value: String, isHighlighted: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.system(size: isHighlighted ? 16 : 15, weight: isHighlighted ? .bold : .medium, design: .rounded))
                .foregroundColor(isHighlighted ? AppTheme.primaryText : AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer(minLength: 12)
            
            Text(value)
                .font(.system(size: isHighlighted ? 22 : 16, weight: .bold, design: .rounded))
                .foregroundColor(isHighlighted ? AppTheme.buttonOrange : AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(minWidth: 120, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.vertical, isHighlighted ? 14 : 12)
        .environment(\.layoutDirection, .rightToLeft)
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
    
    private var infoCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF7ED") : AppTheme.secondaryBackground
    }
    
    private var infoCardBorder: Color {
        colorScheme == .light ? AppTheme.buttonOrange.opacity(0.18) : AppTheme.border
    }
    
    private var resultDescription: String {
        guard finalAmount != nil else {
            return "أدخل المبلغ ونسبة الضريبة لبدء الحساب."
        }
        
        return selectedMode.resultDescription
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
    private func resultCardImage(for result: VATCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة ضريبة القيمة المضافة - احسبها",
            rows: [
                ResultCardRow(title: "الوضع", value: result.mode.title),
                ResultCardRow(title: "المبلغ", value: formatCurrency(result.amount)),
                ResultCardRow(title: "النسبة", value: formatPercent(result.vatRate)),
                ResultCardRow(title: "قيمة الضريبة", value: formatCurrency(result.vatAmount)),
                ResultCardRow(title: "الإجمالي أو الناتج", value: formatCurrency(result.finalAmount), valueColor: AppTheme.buttonOrange)
            ],
            note: "النتائج تقديرية."
        )
    }
}

private struct VATCalculationResult {
    let mode: VATMode
    let amount: Double
    let vatRate: Double
    let vatAmount: Double
    let finalAmount: Double
}

private struct VATDisplayRow {
    let title: String
    let value: String
}

enum VATMode: String, CaseIterable, Identifiable {
    case addVAT
    case removeVAT
    case vatOnly
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .addVAT:
            return "إضافة الضريبة"
        case .removeVAT:
            return "إزالة الضريبة"
        case .vatOnly:
            return "قيمة الضريبة فقط"
        }
    }
    
    var segmentTitle: String {
        switch self {
        case .addVAT:
            return "إضافة الضريبة"
        case .removeVAT:
            return "إزالة الضريبة"
        case .vatOnly:
            return "قيمة الضريبة"
        }
    }
    
    var subtitle: String {
        switch self {
        case .addVAT:
            return "مثال: 100 ريال تصبح 115 ريال"
        case .removeVAT:
            return "مثال: 115 ريال أصلها 100 ريال"
        case .vatOnly:
            return "مثال: ضريبة 100 ريال = 15 ريال"
        }
    }
    
    var amountTitle: String {
        switch self {
        case .addVAT:
            return "المبلغ قبل الضريبة"
        case .removeVAT:
            return "المبلغ شامل الضريبة"
        case .vatOnly:
            return "المبلغ قبل الضريبة"
        }
    }
    
    var amountPlaceholder: String {
        switch self {
        case .addVAT:
            return "100"
        case .removeVAT:
            return "115"
        case .vatOnly:
            return "100"
        }
    }
    
    var resultTitle: String {
        switch self {
        case .addVAT:
            return "المبلغ بعد إضافة الضريبة"
        case .removeVAT:
            return "المبلغ قبل الضريبة"
        case .vatOnly:
            return "قيمة الضريبة"
        }
    }
    
    var inputDetailTitle: String {
        switch self {
        case .addVAT:
            return "المبلغ قبل الضريبة"
        case .removeVAT:
            return "المبلغ شامل الضريبة"
        case .vatOnly:
            return "المبلغ قبل الضريبة"
        }
    }
    
    var finalDetailTitle: String {
        switch self {
        case .addVAT:
            return "المبلغ بعد الضريبة"
        case .removeVAT:
            return "المبلغ قبل الضريبة"
        case .vatOnly:
            return "قيمة الضريبة"
        }
    }
    
    var cardFinalDetailTitle: String {
        switch self {
        case .addVAT:
            return "الإجمالي شامل الضريبة"
        case .removeVAT:
            return "المبلغ قبل الضريبة"
        case .vatOnly:
            return "قيمة الضريبة"
        }
    }
    
    var resultDescription: String {
        switch self {
        case .addVAT:
            return "تم حساب السعر النهائي بعد إضافة ضريبة القيمة المضافة."
        case .removeVAT:
            return "تم استخراج السعر الأساسي قبل ضريبة القيمة المضافة."
        case .vatOnly:
            return "تم حساب قيمة ضريبة القيمة المضافة فقط."
        }
    }
    
    var methodText: String {
        switch self {
        case .addVAT:
            return "المبلغ بعد الضريبة = المبلغ قبل الضريبة + المبلغ × نسبة الضريبة ÷ 100."
        case .removeVAT:
            return "المبلغ قبل الضريبة = المبلغ شامل الضريبة ÷ 1.15 عند استخدام ضريبة 15%. يتم تعديل المعادلة تلقائيًا حسب النسبة المدخلة."
        case .vatOnly:
            return "قيمة الضريبة = المبلغ قبل الضريبة × نسبة الضريبة ÷ 100."
        }
    }
}

struct VATInputField: View {
    let title: String
    let placeholder: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ZStack {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(AppTheme.inputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                
                if value.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.secondaryText)
                }
                
                TextField("", text: $value)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .tint(AppTheme.buttonOrange)
                    .padding(.vertical, 13)
            }
            .frame(height: 52)
        }
    }
}

struct VATDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
            
            Spacer()
            
            Text(title)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        VATCalculatorView()
    }
}
