import SwiftUI
import UIKit

struct WaterBill2027CalculatorView: View {
    @State private var selectedSector: SaudiWaterSector2027 = .residential
    @State private var consumptionText = "30"
    @State private var residentialUnitsText = "1"
    @State private var selectedMeterCategory: SaudiWaterMeterCategory2027 = .upTo20Millimeters
    @State private var hasSewer = true
    @State private var includeVat = true

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .trailing, spacing: 20) {
                    headerSection
                    inputSection

                    if let validationMessage {
                        validationCard(message: validationMessage)
                    }

                    if let calculation {
                        resultSection(calculation)
                        tierDetailsSection(calculation)
                        ShareResultButton(
                            text: shareText(for: calculation),
                            sharedImage: resultCardImage(for: calculation)
                        )
                    }

                    explanatoryNotice
                }
                .padding(20)
                .padding(.bottom, 80)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "drop.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 72, height: 72)
                .background(AppTheme.buttonOrange.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            Text("حاسبة فاتورة المياه 2027")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text("احسب فاتورة المياه والصرف الصحي وفق التعرفة السعودية الجديدة لعام 2027.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    private var inputSection: some View {
        calculatorCard {
            VStack(alignment: .trailing, spacing: 16) {
                headingText("بيانات الفاتورة")

                selectionRow(title: "تصنيف العقار", icon: "building.2.fill") {
                    Picker("تصنيف العقار", selection: $selectedSector) {
                        ForEach(SaudiWaterSector2027.allCases) { sector in
                            Text(sector.rawValue).tag(sector)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppTheme.buttonOrange)
                }

                inputRow(
                    title: "كمية استهلاك المياه (م³)",
                    icon: "drop.fill",
                    placeholder: "30",
                    text: $consumptionText,
                    keyboardType: .decimalPad
                )

                if selectedSector == .residential {
                    inputRow(
                        title: "عدد الوحدات السكنية المسجلة",
                        icon: "house.fill",
                        placeholder: "1",
                        text: $residentialUnitsText,
                        keyboardType: .numberPad,
                        helperText: "عدد الوحدات التي يخدمها العداد نفسه."
                    )
                }

                if selectedSector != .government {
                    selectionRow(title: "قطر عداد المياه", icon: "circle.dotted") {
                        Picker("قطر عداد المياه", selection: $selectedMeterCategory) {
                            ForEach(SaudiWaterMeterCategory2027.allCases) { category in
                                Text(category.label).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppTheme.buttonOrange)
                    }
                }

                Toggle(isOn: $hasSewer) {
                    labelContent(title: "تتوفر خدمة الصرف الصحي", icon: "water.waves")
                }
                .tint(AppTheme.buttonOrange)
                .environment(\.layoutDirection, .rightToLeft)

                Toggle(isOn: $includeVat) {
                    labelContent(title: "احتساب ضريبة القيمة المضافة (15%)", icon: "percent")
                }
                .tint(AppTheme.buttonOrange)
                .environment(\.layoutDirection, .rightToLeft)

                Button(action: resetInputs) {
                    Label("إعادة ضبط البيانات", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.buttonOrange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppTheme.buttonOrange.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func headingText(_ title: String) -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            Text(title)
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.trailing)
        }
        .environment(\.layoutDirection, .leftToRight)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func labelContent(title: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Spacer(minLength: 0)
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.trailing)
            Image(systemName: icon)
                .foregroundColor(AppTheme.buttonOrange)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func selectionRow<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 8) {
                Spacer(minLength: 0)
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.buttonOrange)
            }
            .environment(\.layoutDirection, .leftToRight)
            .frame(maxWidth: .infinity, alignment: .trailing)

            HStack(spacing: 0) {
                Spacer(minLength: 0)
                content()
            }
            .environment(\.layoutDirection, .leftToRight)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundColor(AppTheme.primaryText)
            .lineLimit(2)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 12)
            .frame(minHeight: 50, alignment: .trailing)
            .background(AppTheme.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }

    private func inputRow(
        title: String,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType,
        helperText: String? = nil
    ) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 8) {
                Spacer(minLength: 0)
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.buttonOrange)
            }
            .environment(\.layoutDirection, .leftToRight)
            .frame(maxWidth: .infinity, alignment: .trailing)

            TextField(placeholder, text: text)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.leading)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(AppTheme.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .environment(\.layoutDirection, .leftToRight)

            if let helperText {
                Text(helperText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func resultSection(_ calculation: SaudiWaterBill2027CalculationResult) -> some View {
        calculatorCard {
            VStack(spacing: 16) {
                Text("إجمالي فاتورة المياه التقديرية")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Text(formatCurrency(calculation.total))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.buttonOrange)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .environment(\.layoutDirection, .leftToRight)

                VStack(spacing: 0) {
                    resultRow(title: "قيمة استهلاك المياه", value: formatCurrency(calculation.waterConsumptionCost))

                    if hasSewer {
                        divider
                        resultRow(title: "قيمة استهلاك الصرف الصحي", value: formatCurrency(calculation.sewerConsumptionCost))
                    }

                    divider
                    resultRow(title: "الرسم الشهري الثابت للمياه", value: formatCurrency(calculation.waterFixedFee))

                    if hasSewer {
                        divider
                        resultRow(title: "الرسم الشهري الثابت للصرف الصحي", value: formatCurrency(calculation.sewerFixedFee))
                    }

                    if calculation.additionalUnitsWaterFee > 0 {
                        divider
                        resultRow(title: "رسوم مياه الوحدات الإضافية", value: formatCurrency(calculation.additionalUnitsWaterFee))
                    }

                    if calculation.additionalUnitsSewerFee > 0 {
                        divider
                        resultRow(title: "رسوم صرف الوحدات الإضافية", value: formatCurrency(calculation.additionalUnitsSewerFee))
                    }

                    divider
                    resultRow(title: "الإجمالي قبل الضريبة", value: formatCurrency(calculation.beforeVat))

                    if includeVat {
                        divider
                        resultRow(title: "ضريبة القيمة المضافة 15%", value: formatCurrency(calculation.vatAmount))
                    }
                }
                .background(AppTheme.inputBackground.opacity(0.62))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            }
        }
    }

    private func resultRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .environment(\.layoutDirection, .leftToRight)
    }

    private func tierDetailsSection(_ calculation: SaudiWaterBill2027CalculationResult) -> some View {
        calculatorCard {
            VStack(alignment: .trailing, spacing: 12) {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Text("تفاصيل شرائح الاستهلاك")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .multilineTextAlignment(.trailing)
                }
                .environment(\.layoutDirection, .leftToRight)
                .frame(maxWidth: .infinity, alignment: .trailing)

                if calculation.tiers.contains(where: { $0.quantityM3 > 0 }) {
                    if selectedSector == .residential {
                        ForEach(calculation.tiers.filter { $0.quantityM3 > 0 }, id: \.tierNumber) { tier in
                            tierRow(tier)
                        }
                    } else {
                        Text("تعرفة الاستهلاك الموحدة")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.buttonOrange)
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        ForEach(calculation.tiers.filter { $0.quantityM3 > 0 }, id: \.tierNumber) { tier in
                            tierRow(tier)
                        }
                    }
                } else {
                    Text("لا يوجد استهلاك مياه، لكن الرسوم الشهرية الثابتة تظل مستحقة.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }

    private func tierRow(_ tier: SaudiWaterBill2027TierResult) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                Text(tierTitle(tier.tierNumber))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
            }
            .environment(\.layoutDirection, .leftToRight)
            .frame(maxWidth: .infinity, alignment: .trailing)

            tierDetailRow(title: "الكمية", value: "\(formatQuantity(tier.quantityM3)) م³")
            tierDetailRow(title: "السعر لكل م³", value: formatCurrency(tier.waterRate))
            tierDetailRow(title: "قيمة المياه", value: formatCurrency(tier.waterCost))

            if hasSewer {
                tierDetailRow(title: "قيمة الصرف الصحي", value: formatCurrency(tier.sewerCost))
            }
        }
        .padding(.bottom, 8)
    }

    private func tierDetailRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func tierTitle(_ number: Int) -> String {
        switch number {
        case 1: return "الشريحة الأولى"
        case 2: return "الشريحة الثانية"
        case 3: return "الشريحة الثالثة"
        case 4: return "الشريحة الرابعة"
        default: return "الشريحة \(number)"
        }
    }

    private var explanatoryNotice: some View {
        calculatorCard {
            VStack(alignment: .trailing, spacing: 10) {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Text("تنبيه مهم")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.buttonOrange)
                        .multilineTextAlignment(.trailing)
                }
                .environment(\.layoutDirection, .leftToRight)
                .frame(maxWidth: .infinity, alignment: .trailing)

                Text("النتائج تقديرية وفق تعرفة المياه السعودية الجديدة التي يبدأ تطبيقها في 1 يناير 2027. تعتمد الحاسبة على استهلاك شهري ورسوم شهرية كاملة، ولا تشمل التسويات أو الأرصدة السابقة أو الفترات الانتقالية التي تتداخل مع التعرفة السابقة. قد تختلف الفاتورة الفعلية بحسب بيانات الحساب وفترة الاستهلاك.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(4)
            }
        }
    }

    private var validationMessage: String? {
        guard let consumption = parsedConsumption else {
            return "أدخل كمية استهلاك مياه صالحة من صفر فأعلى."
        }

        guard consumption.isFinite, consumption >= 0 else {
            return "يجب أن تكون كمية الاستهلاك رقمًا منتهيًا وغير سالب."
        }

        if selectedSector == .residential {
            guard let units = parsedResidentialUnits else {
                return "أدخل عددًا صحيحًا للوحدات السكنية."
            }

            guard units >= 1 else {
                return "يجب أن يكون عدد الوحدات السكنية واحدًا أو أكثر."
            }
        }

        return nil
    }

    private var calculation: SaudiWaterBill2027CalculationResult? {
        guard validationMessage == nil,
              let consumption = parsedConsumption else {
            return nil
        }

        let units = selectedSector == .residential ? (parsedResidentialUnits ?? 1) : 1

        return try? SaudiWaterBill2027Calculator.calculate(
            sector: selectedSector,
            consumptionM3: consumption,
            meterCategory: selectedMeterCategory,
            residentialUnits: units,
            hasSewer: hasSewer,
            includeVat: includeVat
        )
    }

    private var parsedConsumption: Double? {
        Double(normalizedNumberText(consumptionText))
    }

    private var parsedResidentialUnits: Int? {
        Int(normalizedNumberText(residentialUnitsText))
    }

    private func normalizedNumberText(_ text: String) -> String {
        let digitMap: [Character: Character] = [
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9",
            "۰": "0", "۱": "1", "۲": "2", "۳": "3", "۴": "4",
            "۵": "5", "۶": "6", "۷": "7", "۸": "8", "۹": "9"
        ]

        return String(text.map { digitMap[$0] ?? $0 })
            .replacingOccurrences(of: "٬", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "٫", with: ".")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func resetInputs() {
        selectedSector = .residential
        consumptionText = "30"
        residentialUnitsText = "1"
        selectedMeterCategory = .upTo20Millimeters
        hasSewer = true
        includeVat = true
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .halfUp

        let fallback = String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), value)
        return "\(formatter.string(from: NSNumber(value: value)) ?? fallback) ر.س"
    }

    private func formatQuantity(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func shareText(for calculation: SaudiWaterBill2027CalculationResult) -> String {
        var lines = [
            "نتيجة حاسبة فاتورة المياه 2027 من احسبها:",
            "",
            "تصنيف العقار: \(selectedSector.rawValue)",
            "الاستهلاك: \(formatQuantity(calculation.tiers.reduce(0) { $0 + $1.quantityM3 })) م³",
            "خدمة الصرف الصحي: \(hasSewer ? "متوفرة" : "غير متوفرة")",
            "ضريبة القيمة المضافة: \(includeVat ? "محتسبة" : "غير محتسبة")",
            "",
            "قيمة استهلاك المياه: \(formatCurrency(calculation.waterConsumptionCost))"
        ]

        if hasSewer {
            lines.append("قيمة استهلاك الصرف الصحي: \(formatCurrency(calculation.sewerConsumptionCost))")
        }

        lines.append(contentsOf: [
            "الرسم الشهري الثابت للمياه: \(formatCurrency(calculation.waterFixedFee))",
            "الإجمالي قبل الضريبة: \(formatCurrency(calculation.beforeVat))"
        ])

        if includeVat {
            lines.append("ضريبة القيمة المضافة 15%: \(formatCurrency(calculation.vatAmount))")
        }

        lines.append("الإجمالي: \(formatCurrency(calculation.total))")
        return lines.joined(separator: "\n")
    }

    @MainActor
    private func resultCardImage(for calculation: SaudiWaterBill2027CalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة فاتورة المياه 2027",
            rows: resultRows(for: calculation),
            note: "النتائج تقديرية وفق تعرفة المياه السعودية الجديدة التي يبدأ تطبيقها في 1 يناير 2027."
        )
    }

    private func resultRows(for calculation: SaudiWaterBill2027CalculationResult) -> [ResultCardRow] {
        var rows = [
            ResultCardRow(title: "الإجمالي", value: formatCurrency(calculation.total), valueColor: AppTheme.buttonOrange),
            ResultCardRow(title: "قيمة استهلاك المياه", value: formatCurrency(calculation.waterConsumptionCost))
        ]

        if hasSewer {
            rows.append(ResultCardRow(title: "قيمة استهلاك الصرف الصحي", value: formatCurrency(calculation.sewerConsumptionCost)))
        }

        rows.append(ResultCardRow(title: "الرسم الثابت للمياه", value: formatCurrency(calculation.waterFixedFee)))

        if hasSewer {
            rows.append(ResultCardRow(title: "الرسم الثابت للصرف الصحي", value: formatCurrency(calculation.sewerFixedFee)))
        }

        if calculation.additionalUnitsWaterFee > 0 {
            rows.append(ResultCardRow(title: "رسوم مياه الوحدات الإضافية", value: formatCurrency(calculation.additionalUnitsWaterFee)))
        }

        if calculation.additionalUnitsSewerFee > 0 {
            rows.append(ResultCardRow(title: "رسوم صرف الوحدات الإضافية", value: formatCurrency(calculation.additionalUnitsSewerFee)))
        }

        rows.append(ResultCardRow(title: "الإجمالي قبل الضريبة", value: formatCurrency(calculation.beforeVat)))

        if includeVat {
            rows.append(ResultCardRow(title: "ضريبة القيمة المضافة 15%", value: formatCurrency(calculation.vatAmount)))
        }

        return rows
    }

    private func calculatorCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(AppTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow.opacity(0.45), radius: 12, x: 0, y: 6)
    }

    private func validationCard(message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)

            Text(message)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color.red.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.red.opacity(0.22), lineWidth: 1)
        )
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var divider: some View {
        Divider()
            .background(AppTheme.border)
    }
}

#Preview {
    NavigationStack {
        WaterBill2027CalculatorView()
    }
}
