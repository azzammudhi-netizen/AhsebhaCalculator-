import SwiftUI
import UIKit

struct WeightedPercentageView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var highSchoolScore: String = ""
    @State private var aptitudeScore: String = ""
    @State private var achievementScore: String = ""

    @State private var highSchoolWeight: String = "30"
    @State private var aptitudeWeight: String = "30"
    @State private var achievementWeight: String = "40"

    private var weightedResult: Double? {
        guard let highSchool = validNumber(highSchoolScore),
              let aptitude = validNumber(aptitudeScore),
              let achievement = validNumber(achievementScore),
              let highWeight = validNumber(highSchoolWeight),
              let aptitudeWeight = validNumber(aptitudeWeight),
              let achievementWeight = validNumber(achievementWeight) else {
            return nil
        }

        let totalWeight = highWeight + aptitudeWeight + achievementWeight
        guard totalWeight > 0 else { return nil }

        return (highSchool * highWeight + aptitude * aptitudeWeight + achievement * achievementWeight) / totalWeight
    }

    private var totalWeight: Double {
        (validNumber(highSchoolWeight) ?? 0) +
        (validNumber(aptitudeWeight) ?? 0) +
        (validNumber(achievementWeight) ?? 0)
    }

    private var weightsAreDefault: Bool {
        highSchoolWeight == "30" &&
        aptitudeWeight == "30" &&
        achievementWeight == "40"
    }

    private var weightsAreValid: Bool {
        validNumber(highSchoolWeight) != nil &&
        validNumber(aptitudeWeight) != nil &&
        validNumber(achievementWeight) != nil &&
        totalWeight > 0
    }

    private var weightValidationMessage: String? {
        guard validNumber(highSchoolWeight) != nil,
              validNumber(aptitudeWeight) != nil,
              validNumber(achievementWeight) != nil else {
            return "أدخل أوزانًا صحيحة بين 0 و 100 لكل خانة."
        }

        guard totalWeight > 0 else {
            return "يجب أن يكون مجموع الأوزان أكبر من صفر."
        }

        if totalWeight != 100 {
            return "مجموع الأوزان \(formatWeight(totalWeight))%، وسيتم الحساب بناءً على هذا المجموع."
        }

        return nil
    }

    private var result: WeightedPercentageCalculationResult? {
        guard let weightedResult,
              let highSchool = validNumber(highSchoolScore),
              let aptitude = validNumber(aptitudeScore),
              let achievement = validNumber(achievementScore),
              let highWeight = validNumber(highSchoolWeight),
              let aptitudeWeight = validNumber(aptitudeWeight),
              let achievementWeight = validNumber(achievementWeight) else {
            return nil
        }

        return WeightedPercentageCalculationResult(
            highSchoolScore: highSchool,
            aptitudeScore: aptitude,
            achievementScore: achievement,
            highSchoolWeight: highWeight,
            aptitudeWeight: aptitudeWeight,
            achievementWeight: achievementWeight,
            weightedResult: weightedResult
        )
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

    private var innerCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFC") : AppTheme.inputBackground
    }

    private var infoCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF7ED") : AppTheme.secondaryBackground
    }

    private var infoCardBorder: Color {
        colorScheme == .light ? AppTheme.buttonOrange.opacity(0.18) : AppTheme.border
    }

    private func shareText(for result: WeightedPercentageCalculationResult) -> String {
        """
        حاسبة النسبة الموزونة - احسبها

        النسبة الموزونة:
        \(formatScore(result.weightedResult))%

        نسبة الثانوية:
        \(formatScore(result.highSchoolScore))%

        درجة القدرات:
        \(formatScore(result.aptitudeScore))

        درجة التحصيلي:
        \(formatScore(result.achievementScore))

        وزن الثانوية:
        \(formatWeight(result.highSchoolWeight))%

        وزن القدرات:
        \(formatWeight(result.aptitudeWeight))%

        وزن التحصيلي:
        \(formatWeight(result.achievementWeight))%
        """
    }

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    headerSection
                    scoresCard
                    weightsCard
                    resultCard

                    if let result {
                        detailsCard(for: result)
                        shareCard(for: result)
                    }

                    methodCard
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
            Text("حاسبة النسبة الموزونة")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("أدخل درجاتك وعدّل الأوزان حسب الجامعة أو التخصص.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var scoresCard: some View {
        inputCard(title: "الدرجات") {
            WeightedInputField(title: "الثانوية", placeholder: "95", value: $highSchoolScore)
            WeightedInputField(title: "القدرات", placeholder: "85", value: $aptitudeScore)
            WeightedInputField(title: "التحصيلي", placeholder: "90", value: $achievementScore)
        }
    }

    private var weightsCard: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("الأوزان")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("المجموع: \(formatWeight(totalWeight))%")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(totalWeight == 100 ? .green : AppTheme.buttonOrange)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .center, spacing: 12) {
                WeightedSmallInputField(title: "الثانوية", value: $highSchoolWeight)
                WeightedSmallInputField(title: "القدرات", value: $aptitudeWeight)
                WeightedSmallInputField(title: "التحصيلي", value: $achievementWeight)
            }

            Button {
                resetDefaultWeights()
            } label: {
                Text("إعادة الأوزان الافتراضية")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(weightsAreDefault ? AppTheme.secondaryText : AppTheme.buttonOrange)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(weightsAreDefault ? innerCardBackground : AppTheme.buttonOrange.opacity(0.10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(weightsAreDefault ? cardBorder : AppTheme.buttonOrange.opacity(0.28), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .disabled(weightsAreDefault)

            if let weightValidationMessage {
                Text(weightValidationMessage)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(weightsAreValid ? AppTheme.secondaryText : AppTheme.buttonOrange)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.08 : 0.12))
                    )
            }

            Text("الأوزان الافتراضية: الثانوية 30%، القدرات 30%، التحصيلي 40%.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
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

    private var resultCard: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(weightedResult == nil ? "النتيجة" : "النسبة الموزونة")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(weightedResult == nil ? "—" : "\(resultText)%")
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundColor(weightedResult == nil ? AppTheme.secondaryText.opacity(0.55) : AppTheme.buttonOrange)
                .minimumScaleFactor(0.55)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(resultDescription)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 178)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private func detailsCard(for result: WeightedPercentageCalculationResult) -> some View {
        VStack(alignment: .center, spacing: 14) {
            Text("تفاصيل الحساب")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                alignment: .center,
                spacing: 10
            ) {
                WeightedSummaryChip(
                    title: "الثانوية",
                    value: "\(formatScore(result.highSchoolScore)) × \(formatWeight(result.highSchoolWeight))%"
                )
                WeightedSummaryChip(
                    title: "القدرات",
                    value: "\(formatScore(result.aptitudeScore)) × \(formatWeight(result.aptitudeWeight))%"
                )
                WeightedSummaryChip(
                    title: "التحصيلي",
                    value: "\(formatScore(result.achievementScore)) × \(formatWeight(result.achievementWeight))%"
                )
                WeightedSummaryChip(
                    title: "النسبة الموزونة",
                    value: "\(formatScore(result.weightedResult))%",
                    isHighlighted: true
                )
            }
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

    private func shareCard(for result: WeightedPercentageCalculationResult) -> some View {
        let generatedImage = resultCardImage(for: result)

        return VStack(alignment: .center, spacing: 12) {
            ShareResultButton(
                text: shareText(for: result),
                sharedImage: generatedImage
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 8 : 0, x: 0, y: colorScheme == .light ? 4 : 0)
    }

    private var methodCard: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("معلومة")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("يتم حساب النسبة بضرب كل درجة في وزنها، ثم قسمة المجموع على مجموع الأوزان.")
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

    private var resultText: String {
        guard let weightedResult else { return "—" }
        return formatScore(weightedResult)
    }

    private var resultDescription: String {
        guard weightedResult != nil else {
            return "أدخل الدرجات والأوزان الصحيحة لعرض النتيجة."
        }

        if totalWeight != 100 {
            return "تم الحساب حسب مجموع الأوزان الحالي \(formatWeight(totalWeight))%."
        }

        return "تم الحساب بناءً على الأوزان المدخلة ومجموعها 100%."
    }

    private func resetDefaultWeights() {
        highSchoolWeight = "30"
        aptitudeWeight = "30"
        achievementWeight = "40"
    }

    private func validNumber(_ text: String) -> Double? {
        let normalized = normalizeArabicNumbers(text)
            .replacingOccurrences(of: "٫", with: ".")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let value = Double(normalized),
              value >= 0,
              value <= 100 else {
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

    private func formatWeight(_ value: Double) -> String {
        formatNumber(value, maximumFractionDigits: 2)
    }

    private func formatScore(_ value: Double) -> String {
        formatNumber(value, maximumFractionDigits: 2)
    }

    private func formatNumber(_ value: Double, maximumFractionDigits: Int) -> String {
        guard value.isFinite else { return "—" }

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maximumFractionDigits

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    @MainActor
    private func resultCardImage(for result: WeightedPercentageCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة النسبة الموزونة",
            rows: [
                ResultCardRow(title: "نسبة الثانوية", value: formatScore(result.highSchoolScore)),
                ResultCardRow(title: "درجة القدرات", value: formatScore(result.aptitudeScore)),
                ResultCardRow(title: "درجة التحصيلي", value: formatScore(result.achievementScore)),
                ResultCardRow(title: "وزن الثانوية", value: "\(formatWeight(result.highSchoolWeight))%"),
                ResultCardRow(title: "وزن القدرات", value: "\(formatWeight(result.aptitudeWeight))%"),
                ResultCardRow(title: "وزن التحصيلي", value: "\(formatWeight(result.achievementWeight))%"),
                ResultCardRow(title: "النسبة الموزونة", value: "\(formatScore(result.weightedResult))%", valueColor: AppTheme.buttonOrange)
            ],
            note: "النتائج تقديرية حسب الأوزان المدخلة."
        )
    }
}

private struct WeightedPercentageCalculationResult {
    let highSchoolScore: Double
    let aptitudeScore: Double
    let achievementScore: Double
    let highSchoolWeight: Double
    let aptitudeWeight: Double
    let achievementWeight: Double
    let weightedResult: Double
}

struct WeightedInputField: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let placeholder: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            TextField(
                "",
                text: $value,
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
            .padding(.horizontal, 12)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(colorScheme == .light ? Color.white : AppTheme.inputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(colorScheme == .light ? Color.black.opacity(0.08) : AppTheme.border, lineWidth: 1)
                    )
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct WeightedSmallInputField: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            TextField("", text: $value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .tint(AppTheme.buttonOrange)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 12)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(colorScheme == .light ? Color.white : AppTheme.inputBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(colorScheme == .light ? Color.black.opacity(0.08) : AppTheme.border, lineWidth: 1)
                        )
                )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct WeightedSummaryChip: View {
    let title: String
    let value: String
    var isHighlighted: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(value)
                .font(.system(size: isHighlighted ? 17 : 15, weight: .bold, design: .rounded))
                .foregroundColor(isHighlighted ? AppTheme.buttonOrange : AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.inputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        WeightedPercentageView()
    }
}
