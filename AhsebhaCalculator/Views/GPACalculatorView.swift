import SwiftUI
import UIKit

struct GPACalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var yearOneTermOne: String = ""
    @State private var yearOneTermTwo: String = ""

    @State private var yearTwoTermOne: String = ""
    @State private var yearTwoTermTwo: String = ""

    @State private var yearThreeTermOne: String = ""
    @State private var yearThreeTermTwo: String = ""

    @State private var yearOneWeight: String = "20"
    @State private var yearTwoWeight: String = "40"
    @State private var yearThreeWeight: String = "40"

    private var years: [GPAYearConfig] {
        [
            GPAYearConfig(title: "أول ثانوي", weight: validWeight(from: yearOneWeight) ?? 0, color: AppTheme.buttonOrange),
            GPAYearConfig(title: "ثاني ثانوي", weight: validWeight(from: yearTwoWeight) ?? 0, color: .teal),
            GPAYearConfig(title: "ثالث ثانوي", weight: validWeight(from: yearThreeWeight) ?? 0, color: .purple)
        ]
    }

    private var yearResults: [GPAYearResult] {
        [
            calculateYearResult(config: years[0], termOne: yearOneTermOne, termTwo: yearOneTermTwo),
            calculateYearResult(config: years[1], termOne: yearTwoTermOne, termTwo: yearTwoTermTwo),
            calculateYearResult(config: years[2], termOne: yearThreeTermOne, termTwo: yearThreeTermTwo)
        ]
    }

    private var cumulativeGPA: Double? {
        guard weightsAreValid else { return nil }

        let validYears = yearResults.filter { $0.average != nil }
        let totalWeight = validYears.reduce(0.0) { $0 + $1.config.weight }

        guard totalWeight > 0 else { return nil }

        let weightedTotal = validYears.reduce(0.0) { partialResult, year in
            partialResult + ((year.average ?? 0) * year.config.weight)
        }

        return weightedTotal / totalWeight
    }

    private var countedTerms: Int {
        yearResults.reduce(0) { $0 + $1.countedTerms }
    }

    private var countedYears: Int {
        yearResults.filter { $0.average != nil }.count
    }

    private var totalWeight: Double {
        (validWeight(from: yearOneWeight) ?? 0) +
        (validWeight(from: yearTwoWeight) ?? 0) +
        (validWeight(from: yearThreeWeight) ?? 0)
    }

    private var weightsAreDefault: Bool {
        yearOneWeight == "20" &&
        yearTwoWeight == "40" &&
        yearThreeWeight == "40"
    }

    private var weightsAreValid: Bool {
        validWeight(from: yearOneWeight) != nil &&
        validWeight(from: yearTwoWeight) != nil &&
        validWeight(from: yearThreeWeight) != nil &&
        totalWeight > 0
    }

    private var weightValidationMessage: String? {
        guard validWeight(from: yearOneWeight) != nil,
              validWeight(from: yearTwoWeight) != nil,
              validWeight(from: yearThreeWeight) != nil else {
            return "أدخل أوزانًا صحيحة بين 0 و 100 لكل سنة."
        }

        guard totalWeight > 0 else {
            return "يجب أن يكون مجموع الأوزان أكبر من صفر."
        }

        if totalWeight != 100 {
            return "مجموع الأوزان \(format(totalWeight))%، وسيتم الحساب بناءً على هذا المجموع."
        }

        return nil
    }

    private var result: GPACalculationResult? {
        guard let cumulativeGPA else { return nil }

        return GPACalculationResult(
            cumulativeGPA: cumulativeGPA,
            gradeText: overallGradeText,
            yearResults: yearResults,
            countedYears: countedYears,
            countedTerms: countedTerms
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

    private func shareText(for result: GPACalculationResult) -> String {
        """
        حاسبة المعدل التراكمي - احسبها

        المعدل التراكمي:
        \(format(result.cumulativeGPA))

        التقدير:
        \(result.gradeText)

        أول ثانوي:
        \(formatAverage(result.yearResults[0].average))

        ثاني ثانوي:
        \(formatAverage(result.yearResults[1].average))

        ثالث ثانوي:
        \(formatAverage(result.yearResults[2].average))

        السنوات المحتسبة:
        \(result.countedYears)/3

        الفصول المحتسبة:
        \(result.countedTerms)/6
        """
    }

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    headerSection

                    GPAYearCardView(
                        title: years[0].title,
                        officialWeightText: "\(format(yearResults[0].config.weight))%",
                        termOne: $yearOneTermOne,
                        termTwo: $yearOneTermTwo,
                        result: yearResults[0],
                        accentColor: years[0].color
                    )

                    GPAYearCardView(
                        title: years[1].title,
                        officialWeightText: "\(format(yearResults[1].config.weight))%",
                        termOne: $yearTwoTermOne,
                        termTwo: $yearTwoTermTwo,
                        result: yearResults[1],
                        accentColor: years[1].color
                    )

                    GPAYearCardView(
                        title: years[2].title,
                        officialWeightText: "\(format(yearResults[2].config.weight))%",
                        termOne: $yearThreeTermOne,
                        termTwo: $yearThreeTermTwo,
                        result: yearResults[2],
                        accentColor: years[2].color
                    )

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
            Text("حاسبة المعدل التراكمي")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("أدخل معدلات الفصلين لكل سنة. الفارغ لا يُحسب كصفر.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var weightsCard: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("أوزان السنوات")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("المجموع: \(format(totalWeight))%")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(totalWeight == 100 ? .green : AppTheme.buttonOrange)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(alignment: .center, spacing: 8) {
                GPAWeightInputField(title: "أول ثانوي", value: $yearOneWeight)
                GPAWeightInputField(title: "ثاني ثانوي", value: $yearTwoWeight)
                GPAWeightInputField(title: "ثالث ثانوي", value: $yearThreeWeight)
            }
            .frame(maxWidth: .infinity, alignment: .center)

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
            Text(cumulativeGPA == nil ? "النتيجة" : "المعدل التراكمي")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(resultText)
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundColor(cumulativeGPA == nil ? AppTheme.secondaryText.opacity(0.55) : AppTheme.buttonOrange)
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

    private func detailsCard(for result: GPACalculationResult) -> some View {
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
                GPASummaryChip(title: "أول ثانوي", value: formatAverage(result.yearResults[0].average))
                GPASummaryChip(title: "ثاني ثانوي", value: formatAverage(result.yearResults[1].average))
                GPASummaryChip(title: "ثالث ثانوي", value: formatAverage(result.yearResults[2].average))
                GPASummaryChip(title: "السنوات المحتسبة", value: "\(result.countedYears)/3")
                GPASummaryChip(title: "الفصول المحتسبة", value: "\(result.countedTerms)/6")
                GPASummaryChip(title: "المعدل التراكمي", value: format(result.cumulativeGPA), isHighlighted: true)
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

    private func shareCard(for result: GPACalculationResult) -> some View {
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

            Text("يتم حساب متوسط كل سنة من الفصول المدخلة، ثم حساب المعدل حسب أوزان السنوات.")
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

    private var resultText: String {
        guard let cumulativeGPA else { return "—" }
        return format(cumulativeGPA)
    }

    private var resultDescription: String {
        guard cumulativeGPA != nil else {
            return weightsAreValid ? "أدخل معدلاتك لعرض المعدل التراكمي." : "راجع أوزان السنوات قبل الحساب."
        }

        return "\(overallGradeText) • السنوات \(countedYears)/3 • الفصول \(countedTerms)/6"
    }

    private func calculateYearResult(
        config: GPAYearConfig,
        termOne: String,
        termTwo: String
    ) -> GPAYearResult {
        let values = [
            validGrade(from: termOne),
            validGrade(from: termTwo)
        ].compactMap { $0 }

        guard !values.isEmpty else {
            return GPAYearResult(config: config, average: nil, countedTerms: 0)
        }

        let average = values.reduce(0, +) / Double(values.count)

        return GPAYearResult(
            config: config,
            average: average,
            countedTerms: values.count
        )
    }

    private func validGrade(from text: String) -> Double? {
        validNumber(from: text)
    }

    private func validWeight(from text: String) -> Double? {
        validNumber(from: text)
    }

    private func validNumber(from text: String) -> Double? {
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

        let arabicDigits = ["٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4", "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9"]
        let persianDigits = ["۰": "0", "۱": "1", "۲": "2", "۳": "3", "۴": "4", "۵": "5", "۶": "6", "۷": "7", "۸": "8", "۹": "9"]

        for (arabic, english) in arabicDigits {
            result = result.replacingOccurrences(of: arabic, with: english)
        }

        for (persian, english) in persianDigits {
            result = result.replacingOccurrences(of: persian, with: english)
        }

        return result
    }

    private func format(_ value: Double) -> String {
        guard value.isFinite else { return "—" }

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatAverage(_ value: Double?) -> String {
        guard let value else { return "—" }
        return format(value)
    }

    private var overallGradeText: String {
        guard let cumulativeGPA else { return "لا يوجد تقدير عام بعد" }
        return gradeDescription(for: cumulativeGPA)
    }

    private func gradeDescription(for value: Double) -> String {
        switch value {
        case 95...100: return "ممتاز مرتفع"
        case 90..<95: return "ممتاز"
        case 85..<90: return "جيد جدًا مرتفع"
        case 80..<85: return "جيد جدًا"
        case 75..<80: return "جيد مرتفع"
        case 70..<75: return "جيد"
        case 65..<70: return "مقبول مرتفع"
        case 60..<65: return "مقبول"
        default: return "يحتاج إلى تحسين"
        }
    }

    private func resetDefaultWeights() {
        yearOneWeight = "20"
        yearTwoWeight = "40"
        yearThreeWeight = "40"
    }

    @MainActor
    private func resultCardImage(for result: GPACalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة المعدل التراكمي",
            rows: [
                ResultCardRow(title: "أول ثانوي", value: formatAverage(result.yearResults[0].average)),
                ResultCardRow(title: "ثاني ثانوي", value: formatAverage(result.yearResults[1].average)),
                ResultCardRow(title: "ثالث ثانوي", value: formatAverage(result.yearResults[2].average)),
                ResultCardRow(title: "السنوات المحتسبة", value: "\(result.countedYears)/3"),
                ResultCardRow(title: "الفصول المحتسبة", value: "\(result.countedTerms)/6"),
                ResultCardRow(title: "المعدل التراكمي الجديد", value: format(result.cumulativeGPA), valueColor: AppTheme.buttonOrange)
            ],
            note: "النتائج تقديرية حسب البيانات المدخلة."
        )
    }
}

private struct GPACalculationResult {
    let cumulativeGPA: Double
    let gradeText: String
    let yearResults: [GPAYearResult]
    let countedYears: Int
    let countedTerms: Int
}

struct GPAYearConfig {
    let title: String
    let weight: Double
    let color: Color
}

struct GPAYearResult: Identifiable {
    let id = UUID()
    let config: GPAYearConfig
    let average: Double?
    let countedTerms: Int

    var averageText: String {
        guard let average else { return "—" }

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: average)) ?? "\(average)"
    }

    var gradeText: String {
        guard let average else { return "لم يُدخل بعد" }

        switch average {
        case 95...100: return "ممتاز مرتفع"
        case 90..<95: return "ممتاز"
        case 85..<90: return "جيد جدًا مرتفع"
        case 80..<85: return "جيد جدًا"
        case 75..<80: return "جيد مرتفع"
        case 70..<75: return "جيد"
        case 65..<70: return "مقبول مرتفع"
        case 60..<65: return "مقبول"
        default: return "يحتاج إلى تحسين"
        }
    }
}

struct GPAYearCardView: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let officialWeightText: String
    @Binding var termOne: String
    @Binding var termTwo: String
    let result: GPAYearResult
    let accentColor: Color

    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            VStack(alignment: .center, spacing: 5) {
                Capsule()
                    .fill(accentColor.opacity(colorScheme == .light ? 0.38 : 0.55))
                    .frame(width: 46, height: 5)
                    .padding(.bottom, 3)

                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("وزن السنة: \(officialWeightText)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            HStack(spacing: 12) {
                GPATermInputField(title: "الفصل الأول", value: $termOne)
                GPATermInputField(title: "الفصل الثاني", value: $termTwo)
            }

            HStack(spacing: 10) {
                GPAMiniStatus(title: "المتوسط", value: result.averageText, isHighlighted: result.average != nil)
                GPAMiniStatus(title: "التقدير", value: result.gradeText)
                GPAMiniStatus(title: "الفصول", value: "\(result.countedTerms)/2")
            }
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(colorScheme == .light ? Color.white : AppTheme.secondaryBackground)

                if colorScheme == .light {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(accentColor.opacity(0.10))
                } else {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(accentColor.opacity(0.08))
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(colorScheme == .light ? accentColor.opacity(0.20) : AppTheme.border, lineWidth: 1)
        )
        .shadow(color: colorScheme == .light ? accentColor.opacity(0.08) : .clear, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.04) : .clear, radius: colorScheme == .light ? 6 : 0, x: 0, y: colorScheme == .light ? 3 : 0)
    }
}

struct GPATermInputField: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            TextField(
                "",
                text: $value,
                prompt: Text("95")
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

private struct GPAWeightInputField: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .frame(maxWidth: .infinity, alignment: .center)

            TextField("", text: $value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .tint(AppTheme.buttonOrange)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .padding(.horizontal, 6)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(colorScheme == .light ? Color.white : AppTheme.inputBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(colorScheme == .light ? Color.black.opacity(0.08) : AppTheme.border, lineWidth: 1)
                        )
                )
        }
        .layoutPriority(1)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct GPAMiniStatus: View {
    let title: String
    let value: String
    var isHighlighted: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(isHighlighted ? AppTheme.buttonOrange : AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.inputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        )
    }
}

private struct GPASummaryChip: View {
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
        GPACalculatorView()
    }
}
