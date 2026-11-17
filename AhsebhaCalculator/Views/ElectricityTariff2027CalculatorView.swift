import SwiftUI
import UIKit

struct ElectricityTariff2027CalculatorView: View {
    @State private var selectedSector: ElectricitySector2027 = .residential
    @State private var selectedBreakerCategory: ElectricityBreakerCategory2027 = .upTo100Amps
    @State private var consumptionText = "3000"
    @State private var billingDaysText = "30"
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
            Image(systemName: "bolt.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 72, height: 72)
                .background(AppTheme.buttonOrange.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            Text("حاسبة فاتورة الكهرباء 2027")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text("احسب فاتورتك وفق التعرفة السعودية الجديدة لعام 2027.")
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
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Text("بيانات الفاتورة")
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .multilineTextAlignment(.trailing)
                }
                .environment(\.layoutDirection, .leftToRight)
                .frame(maxWidth: .infinity, alignment: .trailing)

                selectionRow(
                    title: "القطاع",
                    icon: "building.2.fill"
                ) {
                    Picker("القطاع", selection: $selectedSector) {
                        ForEach(ElectricitySector2027.allCases) { sector in
                            Text(sector.rawValue)
                                .tag(sector)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppTheme.buttonOrange)
                }

                selectionRow(
                    title: "سعة القاطع",
                    icon: "bolt.horizontal.fill"
                ) {
                    Picker("سعة القاطع", selection: $selectedBreakerCategory) {
                        ForEach(ElectricityBreakerCategory2027.allCases) { category in
                            Text(category.label)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppTheme.buttonOrange)
                }

                inputRow(
                    title: "الاستهلاك بالكيلوواط ساعة",
                    icon: "gauge.with.dots.needle.67percent",
                    placeholder: "3000",
                    text: $consumptionText,
                    keyboardType: .decimalPad
                )

                inputRow(
                    title: "عدد أيام الفاتورة",
                    icon: "calendar",
                    placeholder: "30",
                    text: $billingDaysText,
                    keyboardType: .numberPad
                )

                Toggle(isOn: $includeVat) {
                    HStack(spacing: 10) {
                        Image(systemName: "percent")
                            .foregroundColor(AppTheme.buttonOrange)

                        Text("احتساب ضريبة القيمة المضافة 15%")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.primaryText)
                            .multilineTextAlignment(.trailing)
                    }
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
        keyboardType: UIKeyboardType
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
        }
    }

    private func resultSection(_ calculation: ElectricityTariff2027CalculationResult) -> some View {
        calculatorCard {
            VStack(spacing: 16) {
                Text("إجمالي فاتورة الكهرباء التقديرية")
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
                    resultRow(title: "تكلفة الشريحة الأولى", value: formatCurrency(calculation.firstTierCost))
                    if calculation.secondTierKwh > 0 {
                        divider
                        resultRow(title: "تكلفة الشريحة الثانية", value: formatCurrency(calculation.secondTierCost))
                    }
                    divider
                    resultRow(title: "إجمالي تكلفة الاستهلاك", value: formatCurrency(calculation.consumptionCost))
                    divider
                    resultRow(title: "التعرفة الثابتة حسب سعة القاطع", value: formatCurrency(calculation.fixedTariff))
                    divider
                    resultRow(title: "الإجمالي قبل الضريبة", value: formatCurrency(calculation.beforeVat))
                    divider
                    resultRow(title: "ضريبة القيمة المضافة", value: formatCurrency(calculation.vatAmount))
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

    private var divider: some View {
        Divider()
            .background(AppTheme.border)
    }

    private var explanatoryNotice: some View {
        calculatorCard {
            VStack(alignment: .trailing, spacing: 10) {
                Label("تنبيه مهم", systemImage: "info.circle.fill")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.buttonOrange)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text("النتائج تقديرية بناءً على تعرفة 2027. تتم مواءمة الرسوم الثابتة حسب عدد أيام الفاتورة مقسومًا على 30.")
                Text("يحافظ الحساب الحالي على حد 6,000 كيلوواط ساعة دون تغيير للفترات غير المكونة من 30 يومًا، إلى حين تأكيد المعالجة الرسمية.")
                Text("لا تشمل النتائج التعديلات أو الأرصدة السابقة أو الرسوم الخاصة.")
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(AppTheme.secondaryText)
            .multilineTextAlignment(.trailing)
            .lineSpacing(4)
        }
    }

    private var validationMessage: String? {
        guard let consumption = parsedConsumption else {
            return "أدخل استهلاكًا صالحًا من صفر فأعلى."
        }

        guard consumption.isFinite, consumption >= 0 else {
            return "يجب أن يكون الاستهلاك رقمًا منتهيًا وغير سالب."
        }

        guard let billingDays = parsedBillingDays else {
            return "أدخل عدد أيام صحيحًا من 1 إلى 365."
        }

        guard (1...365).contains(billingDays) else {
            return "يجب أن يكون عدد أيام الفاتورة بين 1 و365."
        }

        return nil
    }

    private var calculation: ElectricityTariff2027CalculationResult? {
        guard validationMessage == nil,
              let consumption = parsedConsumption,
              let billingDays = parsedBillingDays else {
            return nil
        }

        return try? ElectricityTariff2027Calculator.calculate(
            sector: selectedSector,
            consumptionKwh: consumption,
            breakerCategory: selectedBreakerCategory,
            billingDays: billingDays,
            includeVat: includeVat
        )
    }

    private var parsedConsumption: Double? {
        Double(normalizedNumberText(consumptionText))
    }

    private var parsedBillingDays: Int? {
        Int(normalizedNumberText(billingDaysText))
    }

    private func normalizedNumberText(_ text: String) -> String {
        let digitMap: [Character: Character] = [
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9",
            "۰": "0", "۱": "1", "۲": "2", "۳": "3", "۴": "4",
            "۵": "5", "۶": "6", "۷": "7", "۸": "8", "۹": "9"
        ]

        return String(
            text
                .map { digitMap[$0] ?? $0 }
        )
        .replacingOccurrences(of: "٬", with: "")
        .replacingOccurrences(of: ",", with: "")
        .replacingOccurrences(of: "٫", with: ".")
        .replacingOccurrences(of: " ", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func resetInputs() {
        selectedSector = .residential
        selectedBreakerCategory = .upTo100Amps
        consumptionText = "3000"
        billingDaysText = "30"
        includeVat = true
    }

    private func formatCurrency(_ value: Double) -> String {
        guard value.isFinite else {
            return "0.00 ر.س"
        }

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .halfUp

        let fallback = String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), value)
        let formatted = formatter.string(from: NSNumber(value: value)) ?? fallback
        return "\(formatted) ر.س"
    }

    private func shareText(for calculation: ElectricityTariff2027CalculationResult) -> String {
        var lines = [
            "نتيجة حاسبة فاتورة الكهرباء 2027 من احسبها:",
            "",
            "القطاع: \(selectedSector.rawValue)",
            "سعة القاطع: \(selectedBreakerCategory.label)",
            "الاستهلاك: \(formatQuantity(calculation.firstTierKwh + calculation.secondTierKwh)) كيلوواط ساعة",
            "عدد الأيام: \(billingDaysText)",
            "",
            "تكلفة الشريحة الأولى: \(formatCurrency(calculation.firstTierCost))"
        ]

        if calculation.secondTierKwh > 0 {
            lines.append("تكلفة الشريحة الثانية: \(formatCurrency(calculation.secondTierCost))")
        }

        lines.append(contentsOf: [
            "إجمالي تكلفة الاستهلاك: \(formatCurrency(calculation.consumptionCost))",
            "التعرفة الثابتة: \(formatCurrency(calculation.fixedTariff))",
            "الإجمالي قبل الضريبة: \(formatCurrency(calculation.beforeVat))",
            "ضريبة القيمة المضافة: \(formatCurrency(calculation.vatAmount))",
            "الإجمالي: \(formatCurrency(calculation.total))",
            "",
            "النتائج تقديرية ولا تشمل التعديلات أو الأرصدة السابقة أو الرسوم الخاصة."
        ])

        return lines.joined(separator: "\n")
    }

    private func formatQuantity(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    @MainActor
    private func resultCardImage(for calculation: ElectricityTariff2027CalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة فاتورة الكهرباء 2027",
            rows: resultRows(for: calculation),
            note: "النتائج تقديرية بناءً على تعرفة 2027. الرسوم الثابتة محسوبة حسب عدد الأيام."
        )
    }

    private func resultRows(for calculation: ElectricityTariff2027CalculationResult) -> [ResultCardRow] {
        var rows = [
            ResultCardRow(title: "تكلفة الشريحة الأولى", value: formatCurrency(calculation.firstTierCost)),
        ]

        if calculation.secondTierKwh > 0 {
            rows.append(
                ResultCardRow(title: "تكلفة الشريحة الثانية", value: formatCurrency(calculation.secondTierCost))
            )
        }

        rows.append(contentsOf: [
            ResultCardRow(title: "إجمالي تكلفة الاستهلاك", value: formatCurrency(calculation.consumptionCost)),
            ResultCardRow(title: "التعرفة الثابتة", value: formatCurrency(calculation.fixedTariff)),
            ResultCardRow(title: "الإجمالي قبل الضريبة", value: formatCurrency(calculation.beforeVat)),
            ResultCardRow(
                title: "ضريبة القيمة المضافة",
                value: formatCurrency(calculation.vatAmount)
            ),
            ResultCardRow(
                title: "الإجمالي",
                value: formatCurrency(calculation.total),
                valueColor: AppTheme.buttonOrange
            )
        ])

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
}

#Preview {
    NavigationStack {
        ElectricityTariff2027CalculatorView()
    }
}
