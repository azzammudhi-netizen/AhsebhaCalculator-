import SwiftUI
import UIKit

struct PercentageCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedMode: PercentageMode = .partOfWhole

    @State private var partValue: String = ""
    @State private var wholeValue: String = ""

    @State private var originalValue: String = ""
    @State private var newValue: String = ""

    @State private var baseValue: String = ""
    @State private var percentageValue: String = ""

    private var resultText: String {
        switch selectedMode {
        case .partOfWhole:
            guard let part = validNumber(partValue),
                  let whole = validNumber(wholeValue),
                  whole != 0 else { return "—" }
            return formatPercent((part / whole) * 100)

        case .change:
            guard let original = validNumber(originalValue),
                  let new = validNumber(newValue),
                  original != 0 else { return "—" }
            return formatPercent(((new - original) / original) * 100)

        case .addPercentage:
            guard let base = validNumber(baseValue),
                  let percentage = validNumber(percentageValue) else { return "—" }
            return formatNumber(base + (base * percentage / 100))
        }
    }

    private var hasValidResult: Bool {
        resultText != "—"
    }

    private var result: PercentageCalculationResult? {
        guard hasValidResult else { return nil }

        switch selectedMode {
        case .partOfWhole:
            return PercentageCalculationResult(
                mode: selectedMode,
                primaryTitle: "القيمة",
                primaryValue: displayNumber(partValue),
                secondaryTitle: "من أصل",
                secondaryValue: displayNumber(wholeValue),
                baseNumberValue: displayNumber(wholeValue),
                percentageValue: resultText,
                resultValue: resultText,
                adjustmentTitle: nil,
                adjustmentValue: nil
            )

        case .change:
            return PercentageCalculationResult(
                mode: selectedMode,
                primaryTitle: "القيمة القديمة",
                primaryValue: displayNumber(originalValue),
                secondaryTitle: "القيمة الجديدة",
                secondaryValue: displayNumber(newValue),
                baseNumberValue: displayNumber(originalValue),
                percentageValue: resultText,
                resultValue: resultText,
                adjustmentTitle: nil,
                adjustmentValue: nil
            )

        case .addPercentage:
            let adjustmentAmount = (validNumber(baseValue) ?? 0) * (validNumber(percentageValue) ?? 0) / 100

            return PercentageCalculationResult(
                mode: selectedMode,
                primaryTitle: "الرقم الأساسي",
                primaryValue: displayNumber(baseValue),
                secondaryTitle: "النسبة",
                secondaryValue: displayPercent(percentageValue),
                baseNumberValue: displayNumber(baseValue),
                percentageValue: displayPercent(percentageValue),
                resultValue: resultText,
                adjustmentTitle: adjustmentAmount < 0 ? "قيمة النقصان" : "قيمة الزيادة",
                adjustmentValue: formatNumber(abs(adjustmentAmount))
            )
        }
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
        colorScheme == .light ? Color.black.opacity(0.08) : .clear
    }

    private var inputBackground: Color {
        colorScheme == .light ? Color.white : AppTheme.inputBackground
    }

    private var inputBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : AppTheme.border
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

    private func shareText(for result: PercentageCalculationResult) -> String {
        """
        حاسبة النسبة المئوية - احسبها

        نوع العملية:
        \(result.mode.title)

        الرقم الأساسي:
        \(result.baseNumberValue)

        النسبة:
        \(result.percentageValue)

        الناتج:
        \(result.resultValue)
        """
    }

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    headerSection
                    modeSelector
                    inputSection
                    resultCard
                    infoCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("حاسبة النسبة المئوية")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(selectedMode.description)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var modeSelector: some View {
        VStack(alignment: .center, spacing: 8) {
            ForEach(PercentageMode.allCases) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    VStack(alignment: .center, spacing: 4) {
                        Text(mode.title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(selectedMode == mode ? AppTheme.buttonOrange : AppTheme.primaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(mode.subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(selectedMode == mode ? AppTheme.buttonOrange.opacity(0.12) : innerCardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(
                                        selectedMode == mode ? AppTheme.buttonOrange.opacity(0.35) : innerCardBorder,
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    @ViewBuilder
    private var inputSection: some View {
        switch selectedMode {
        case .partOfWhole:
            inputCard(title: "كم تمثل قيمة من قيمة؟") {
                calculatorInput(title: "القيمة", placeholder: "25", value: $partValue, icon: "percent")
                calculatorInput(title: "من أصل", placeholder: "200", value: $wholeValue, icon: "number")
            }

        case .change:
            inputCard(title: "نسبة الزيادة أو النقصان") {
                calculatorInput(title: "القيمة القديمة", placeholder: "100", value: $originalValue, icon: "arrow.down.backward")
                calculatorInput(title: "القيمة الجديدة", placeholder: "120", value: $newValue, icon: "arrow.up.forward")
            }

        case .addPercentage:
            inputCard(title: "إضافة نسبة إلى رقم") {
                calculatorInput(title: "الرقم الأساسي", placeholder: "100", value: $baseValue, icon: "number")
                calculatorInput(title: "النسبة %", placeholder: "15", value: $percentageValue, icon: "percent")
            }
        }
    }

    private var resultCard: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("النتيجة")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(resultText)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.buttonOrange)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(selectedMode.resultHint)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)

            if let result {
                resultSummary(result)

                ShareResultButton(
                    text: shareText(for: result),
                    sharedImage: resultCardImage(for: result)
                )
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private var infoCard: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("معلومة")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("يمكن استخدام الحاسبة لمعرفة النسبة أو التغير أو ناتج إضافة نسبة إلى رقم.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(infoCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(infoCardBorder, lineWidth: 1)
                )
        )
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.05) : .clear, radius: colorScheme == .light ? 7 : 0, x: 0, y: colorScheme == .light ? 3 : 0)
    }

    private func inputCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .center, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .center, spacing: 12) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private func calculatorInput(
        title: String,
        placeholder: String,
        value: Binding<String>,
        icon: String
    ) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.buttonOrange)
                    .frame(width: 34, height: 34)
                    .background(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.10 : 0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                TextField(
                    "",
                    text: value,
                    prompt: Text(placeholder)
                        .foregroundColor(AppTheme.secondaryText.opacity(0.65))
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .tint(AppTheme.buttonOrange)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 12)
            .frame(height: 56)
            .background(inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(inputBorder, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func resultSummary(_ result: PercentageCalculationResult) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]

        return LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            percentageSummaryChip(title: "نوع العملية", value: result.mode.title)
            percentageSummaryChip(title: result.primaryTitle, value: result.primaryValue)
            percentageSummaryChip(title: result.secondaryTitle, value: result.secondaryValue)

            if let adjustmentTitle = result.adjustmentTitle,
               let adjustmentValue = result.adjustmentValue {
                percentageSummaryChip(title: adjustmentTitle, value: adjustmentValue)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(innerCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(innerCardBorder, lineWidth: 1)
                )
        )
    }

    private func percentageSummaryChip(title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(innerCardBorder, lineWidth: 1)
                )
        )
    }

    private func validNumber(_ text: String) -> Double? {
        let normalized = normalizeArabicNumbers(text)
            .replacingOccurrences(of: "٫", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let commaCount = normalized.filter { $0 == "," }.count
        let parsedText: String

        if commaCount == 1,
           !normalized.contains("."),
           let decimalPart = normalized.split(separator: ",").last,
           decimalPart.count <= 4 {
            parsedText = normalized.replacingOccurrences(of: ",", with: ".")
        } else {
            parsedText = normalized
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: "٬", with: "")
        }

        return Double(parsedText)
    }

    private func displayNumber(_ text: String) -> String {
        guard let value = validNumber(text) else { return "—" }
        return formatNumber(value)
    }

    private func displayPercent(_ text: String) -> String {
        guard let value = validNumber(text) else { return "—" }
        return formatPercent(value)
    }

    private func formatPercent(_ value: Double) -> String {
        "\(formatNumber(value))%"
    }

    private func formatNumber(_ value: Double) -> String {
        guard value.isFinite else { return "—" }

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
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

    @MainActor
    private func resultCardImage(for result: PercentageCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة النسبة المئوية",
            rows: [
                ResultCardRow(title: "نوع العملية", value: result.mode.title),
                ResultCardRow(title: "الرقم الأساسي", value: result.baseNumberValue),
                ResultCardRow(title: "النسبة", value: result.percentageValue),
                ResultCardRow(title: "الناتج", value: result.resultValue, valueColor: AppTheme.buttonOrange)
            ],
            note: "النتائج تقديرية."
        )
    }
}

private struct PercentageCalculationResult {
    let mode: PercentageMode
    let primaryTitle: String
    let primaryValue: String
    let secondaryTitle: String
    let secondaryValue: String
    let baseNumberValue: String
    let percentageValue: String
    let resultValue: String
    let adjustmentTitle: String?
    let adjustmentValue: String?
}

enum PercentageMode: String, CaseIterable, Identifiable {
    case partOfWhole
    case change
    case addPercentage

    var id: String { rawValue }

    var title: String {
        switch self {
        case .partOfWhole: return "نسبة رقم من رقم"
        case .change: return "الزيادة أو النقصان"
        case .addPercentage: return "إضافة نسبة"
        }
    }

    var subtitle: String {
        switch self {
        case .partOfWhole: return "مثال: كم تمثل 25 من 200؟"
        case .change: return "مثال: من 100 إلى 120"
        case .addPercentage: return "مثال: 100 + 15%"
        }
    }

    var description: String {
        switch self {
        case .partOfWhole: return "احسب كم تمثل قيمة من قيمة أخرى."
        case .change: return "احسب نسبة الزيادة أو النقصان بين رقمين."
        case .addPercentage: return "احسب ناتج إضافة نسبة مئوية إلى رقم."
        }
    }

    var resultHint: String {
        switch self {
        case .partOfWhole: return "هذه هي النسبة التي تمثلها القيمة من الأصل."
        case .change: return "القيمة الموجبة تعني زيادة، والسالبة تعني نقصان."
        case .addPercentage: return "هذه هي القيمة بعد إضافة النسبة."
        }
    }
}

#Preview {
    NavigationStack {
        PercentageCalculatorView()
    }
}
