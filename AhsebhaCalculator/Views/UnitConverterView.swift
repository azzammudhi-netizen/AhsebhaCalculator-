import SwiftUI
import UIKit

struct UnitConverterView: View {
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: Field?

    @State private var selectedCategory: UnitCategory = .length
    @State private var inputValue = "1"
    @State private var fromUnit: UnitDefinition = UnitCategory.length.units[0]
    @State private var toUnit: UnitDefinition = UnitCategory.length.units[1]
    @State private var result: UnitConversionResult?
    @State private var errorMessage: String?
    @State private var hasCalculated = false

    private enum Field {
        case value
    }

    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }

    private var cardBackground: Color {
        colorScheme == .light ? Color(hex: "#FBFCFF") : AppTheme.secondaryBackground
    }

    private var inputBackground: Color {
        colorScheme == .light ? Color(hex: "#F6FAFF") : AppTheme.secondaryBackground
    }

    private var resultBackground: Color {
        colorScheme == .light ? Color(hex: "#F4FBF8") : AppTheme.secondaryBackground
    }

    private var cardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : AppTheme.border
    }

    private var cardShadow: Color {
        colorScheme == .light ? Color.black.opacity(0.07) : .clear
    }

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    headerSection
                    categorySelector
                    inputSection
                    actionButtons

                    if let errorMessage {
                        warningCard(errorMessage)
                    }

                    if let result {
                        resultCard(result)
                        detailsCard(result)
                        shareSection(result)
                    } else {
                        emptyStateCard
                    }

                    noteCard
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
        .onChange(of: selectedCategory) { _, newCategory in
            fromUnit = newCategory.units[0]
            toUnit = newCategory.units[min(1, newCategory.units.count - 1)]
            recalculateIfNeeded()
        }
        .onChange(of: inputValue) { _, _ in
            if hasCalculated {
                recalculateIfNeeded()
            } else {
                clearCurrentResult()
            }
        }
        .onChange(of: fromUnit) { _, _ in recalculateIfNeeded() }
        .onChange(of: toUnit) { _, _ in recalculateIfNeeded() }
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "ruler")
                .font(.system(size: 29, weight: .bold))
                .foregroundColor(.teal)
                .frame(width: 58, height: 58)
                .background(Color.teal.opacity(colorScheme == .light ? 0.11 : 0.18))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text("محول الوحدات")
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("حوّل بين وحدات الطول والوزن والمساحة والحجم والحرارة بسهولة.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var categorySelector: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("نوع الوحدة")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(UnitCategory.allCases) { category in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.84)) {
                            selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: category.icon)
                                .font(.system(size: 15, weight: .bold))

                            Text(category.title)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundColor(selectedCategory == category ? .black : AppTheme.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedCategory == category ? AppTheme.buttonOrange : category.tint.opacity(colorScheme == .light ? 0.085 : 0.15))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(category.tint.opacity(selectedCategory == category ? 0.32 : 0.16), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 9, x: 0, y: 4)
    }

    private var inputSection: some View {
        VStack(alignment: .center, spacing: 14) {
            amountInputCard
            unitSelectionRow
        }
        .padding(16)
        .background(inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(selectedCategory.tint.opacity(colorScheme == .light ? 0.15 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private var amountInputCard: some View {
        VStack(alignment: .center, spacing: 9) {
            inputTitle("القيمة", icon: "number", tint: AppTheme.buttonOrange)

            TextField("أدخل القيمة", text: $inputValue)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .tint(AppTheme.buttonOrange)
                .padding(.vertical, 13)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity)
                .background(innerBackground(AppTheme.buttonOrange))
        }
    }

    private var unitSelectionRow: some View {
        ZStack {
            HStack(spacing: 10) {
                unitPickerCard(title: "من وحدة", unit: $fromUnit, tint: .blue)
                unitPickerCard(title: "إلى وحدة", unit: $toUnit, tint: .teal)
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                    let currentFrom = fromUnit
                    fromUnit = toUnit
                    toUnit = currentFrom
                    recalculateIfNeeded()
                }
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.black)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.buttonOrange)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.75), lineWidth: 2))
                    .shadow(color: AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.28 : 0.16), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
    }

    private func unitPickerCard(title: String, unit: Binding<UnitDefinition>, tint: Color) -> some View {
        VStack(alignment: .center, spacing: 8) {
            inputTitle(title, icon: "chevron.down.circle.fill", tint: tint)

            Picker(title, selection: unit) {
                ForEach(selectedCategory.units) { option in
                    Text(option.name).tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(innerBackground(tint))
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        Button {
            focusedField = nil
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            hasCalculated = true
            calculateConversion()
        } label: {
            Text("احسب التحويل")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppTheme.buttonOrange)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.25 : 0.16), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private func resultCard(_ result: UnitConversionResult) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text("نتيجة التحويل")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(selectedCategory.tint)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(result.formattedResult)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.buttonOrange)
                .lineLimit(1)
                .minimumScaleFactor(0.48)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(result.toUnit.name)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .background(resultBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(selectedCategory.tint.opacity(colorScheme == .light ? 0.18 : 0.26), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func detailsCard(_ result: UnitConversionResult) -> some View {
        VStack(alignment: .center, spacing: 14) {
            Text("تفاصيل التحويل")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                UnitSummaryChip(title: "الفئة", value: result.category.title)
                UnitSummaryChip(title: "القيمة المدخلة", value: "\(formatNumber(result.input)) \(result.fromUnit.name)")
                UnitSummaryChip(title: "من وحدة", value: result.fromUnit.name)
                UnitSummaryChip(title: "إلى وحدة", value: result.toUnit.name)
            }
        }
        .padding(18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func shareSection(_ result: UnitConversionResult) -> some View {
        ShareResultButton(
            text: shareText(for: result),
            sharedImage: resultCardImage(for: result)
        )
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 8, x: 0, y: 4)
    }

    private var emptyStateCard: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "ruler")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(selectedCategory.tint)
                .frame(width: 58, height: 58)
                .background(selectedCategory.tint.opacity(colorScheme == .light ? 0.12 : 0.20))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text("جاهز للتحويل")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)

            Text("أدخل القيمة واختر الوحدات ثم اضغط احسب التحويل.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }

    private func warningCard(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(AppTheme.buttonOrange)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(14)
            .background(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.08 : 0.13))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.18 : 0.26), lineWidth: 1)
            )
    }

    private var noteCard: some View {
        Text("تستخدم هذه الأداة معاملات تحويل معيارية للوحدات الشائعة، وقد تختلف بعض الوحدات المحلية حسب السياق.")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(AppTheme.secondaryText)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(16)
            .background(selectedCategory.tint.opacity(colorScheme == .light ? 0.07 : 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(selectedCategory.tint.opacity(colorScheme == .light ? 0.15 : 0.24), lineWidth: 1)
            )
    }

    private func inputTitle(_ title: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 7) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)

            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(tint)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func innerBackground(_ tint: Color) -> some View {
        RoundedRectangle(cornerRadius: 17, style: .continuous)
            .fill(colorScheme == .light ? Color.white.opacity(0.82) : AppTheme.inputBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .stroke(tint.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
            )
    }

    private func calculateConversion() {
        guard let input = parseDouble(inputValue), input.isFinite else {
            result = nil
            errorMessage = "أدخل قيمة صحيحة لإتمام التحويل."
            return
        }

        let converted = convert(input, from: fromUnit, to: toUnit, category: selectedCategory)
        guard converted.isFinite else {
            result = nil
            errorMessage = "تعذر تحويل هذه القيمة."
            return
        }

        result = UnitConversionResult(
            category: selectedCategory,
            input: input,
            converted: converted,
            fromUnit: fromUnit,
            toUnit: toUnit
        )
        errorMessage = nil
    }

    private func recalculateIfNeeded() {
        guard hasCalculated else {
            clearCurrentResult()
            return
        }
        calculateConversion()
    }

    private func clearCurrentResult() {
        result = nil
        errorMessage = nil
    }

    private func convert(_ value: Double, from: UnitDefinition, to: UnitDefinition, category: UnitCategory) -> Double {
        if category == .temperature {
            return convertTemperature(value, from: from.symbol, to: to.symbol)
        }

        let baseValue = value * from.factor
        return baseValue / to.factor
    }

    private func convertTemperature(_ value: Double, from: String, to: String) -> Double {
        let celsius: Double
        switch from {
        case "F":
            celsius = (value - 32) * 5 / 9
        case "K":
            celsius = value - 273.15
        default:
            celsius = value
        }

        switch to {
        case "F":
            return (celsius * 9 / 5) + 32
        case "K":
            return celsius + 273.15
        default:
            return celsius
        }
    }

    private func parseDouble(_ text: String) -> Double? {
        let cleaned = normalizeDigits(text)
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "٬", with: "")
            .replacingOccurrences(of: "٫", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(cleaned)
    }

    private func normalizeDigits(_ text: String) -> String {
        let digitMap: [Character: Character] = [
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9",
            "۰": "0", "۱": "1", "۲": "2", "۳": "3", "۴": "4",
            "۵": "5", "۶": "6", "۷": "7", "۸": "8", "۹": "9"
        ]
        return String(text.map { digitMap[$0] ?? $0 })
    }

    private func formatNumber(_ value: Double) -> String {
        formatUnitNumber(value)
    }

    private func shareText(for result: UnitConversionResult) -> String {
        """
        محول الوحدات - احسبها

        الفئة:
        \(result.category.title)

        القيمة المدخلة:
        \(formatNumber(result.input)) \(result.fromUnit.name)

        النتيجة:
        \(result.formattedResult) \(result.toUnit.name)

        """
    }

    @MainActor
    private func resultCardImage(for result: UnitConversionResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "محول الوحدات",
            rows: [
                ResultCardRow(title: "الفئة", value: result.category.title),
                ResultCardRow(title: "القيمة المدخلة", value: "\(formatNumber(result.input)) \(result.fromUnit.name)"),
                ResultCardRow(title: "من وحدة", value: result.fromUnit.name),
                ResultCardRow(title: "إلى وحدة", value: result.toUnit.name),
                ResultCardRow(title: "النتيجة", value: "\(result.formattedResult) \(result.toUnit.name)", valueColor: AppTheme.buttonOrange)
            ],
            note: "تم التحويل باستخدام محول الوحدات من احسبها."
        )
    }
}

private enum UnitCategory: String, CaseIterable, Identifiable {
    case length
    case weight
    case area
    case volume
    case temperature

    var id: String { rawValue }

    var title: String {
        switch self {
        case .length: return "الطول"
        case .weight: return "الوزن"
        case .area: return "المساحة"
        case .volume: return "الحجم"
        case .temperature: return "الحرارة"
        }
    }

    var icon: String {
        switch self {
        case .length: return "ruler"
        case .weight: return "scalemass"
        case .area: return "square.on.square"
        case .volume: return "drop.degreesign"
        case .temperature: return "thermometer.medium"
        }
    }

    var tint: Color {
        switch self {
        case .length: return .teal
        case .weight: return .blue
        case .area: return .purple
        case .volume: return .cyan
        case .temperature: return .orange
        }
    }

    var units: [UnitDefinition] {
        switch self {
        case .length:
            return [
                UnitDefinition(name: "متر", symbol: "m", factor: 1),
                UnitDefinition(name: "كيلومتر", symbol: "km", factor: 1_000),
                UnitDefinition(name: "سنتيمتر", symbol: "cm", factor: 0.01),
                UnitDefinition(name: "مليمتر", symbol: "mm", factor: 0.001),
                UnitDefinition(name: "ميل", symbol: "mi", factor: 1_609.344),
                UnitDefinition(name: "ياردة", symbol: "yd", factor: 0.9144),
                UnitDefinition(name: "قدم", symbol: "ft", factor: 0.3048),
                UnitDefinition(name: "بوصة", symbol: "in", factor: 0.0254)
            ]
        case .weight:
            return [
                UnitDefinition(name: "كيلوجرام", symbol: "kg", factor: 1),
                UnitDefinition(name: "جرام", symbol: "g", factor: 0.001),
                UnitDefinition(name: "مليجرام", symbol: "mg", factor: 0.000001),
                UnitDefinition(name: "طن", symbol: "t", factor: 1_000),
                UnitDefinition(name: "رطل", symbol: "lb", factor: 0.45359237),
                UnitDefinition(name: "أونصة", symbol: "oz", factor: 0.028349523125)
            ]
        case .area:
            return [
                UnitDefinition(name: "متر مربع", symbol: "m2", factor: 1),
                UnitDefinition(name: "كيلومتر مربع", symbol: "km2", factor: 1_000_000),
                UnitDefinition(name: "سنتيمتر مربع", symbol: "cm2", factor: 0.0001),
                UnitDefinition(name: "هكتار", symbol: "ha", factor: 10_000),
                UnitDefinition(name: "فدان", symbol: "acre", factor: 4_046.8564224),
                UnitDefinition(name: "قدم مربع", symbol: "ft2", factor: 0.09290304)
            ]
        case .volume:
            return [
                UnitDefinition(name: "لتر", symbol: "L", factor: 1),
                UnitDefinition(name: "مليلتر", symbol: "mL", factor: 0.001),
                UnitDefinition(name: "متر مكعب", symbol: "m3", factor: 1_000),
                UnitDefinition(name: "جالون", symbol: "gal", factor: 3.785411784),
                UnitDefinition(name: "كوب", symbol: "cup", factor: 0.24)
            ]
        case .temperature:
            return [
                UnitDefinition(name: "مئوية", symbol: "C", factor: 1),
                UnitDefinition(name: "فهرنهايت", symbol: "F", factor: 1),
                UnitDefinition(name: "كلفن", symbol: "K", factor: 1)
            ]
        }
    }
}

private struct UnitDefinition: Identifiable, Hashable {
    let name: String
    let symbol: String
    let factor: Double

    var id: String { symbol }
}

private struct UnitConversionResult {
    let category: UnitCategory
    let input: Double
    let converted: Double
    let fromUnit: UnitDefinition
    let toUnit: UnitDefinition

    var formattedResult: String {
        formatUnitNumber(converted)
    }
}

private func formatUnitNumber(_ value: Double) -> String {
    let absoluteValue = abs(value)
    let maximumFractionDigits: Int

    if absoluteValue >= 100 {
        maximumFractionDigits = 2
    } else if absoluteValue >= 1 {
        maximumFractionDigits = 3
    } else {
        maximumFractionDigits = 6
    }

    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "ar_SA")
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = true
    formatter.maximumFractionDigits = maximumFractionDigits
    formatter.minimumFractionDigits = 0
    formatter.roundingMode = .halfUp

    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

private struct UnitSummaryChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(3)
                .minimumScaleFactor(0.55)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .center)
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
        UnitConverterView()
    }
}
