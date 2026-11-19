import SwiftUI
import UIKit

struct WaterConnectionCalculatorView: View {
    @State private var selectedSector: SaudiWaterConnectionSector = .residential
    @State private var selectedService: SaudiWaterConnectionService = .both
    @State private var buildingAreaText = "675"
    @State private var residentialUnitsText = "1"
    @State private var includeVat = true

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .trailing, spacing: 20) {
                    headerSection
                    introductoryNotice
                    inputSection
                    directPricingSection

                    if let validationMessage {
                        validationCard(message: validationMessage)
                    } else if let calculationResult {
                        resultContent(calculationResult)
                    }
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
            Image(systemName: "house.lodge.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 72, height: 72)
                .background(AppTheme.buttonOrange.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            Text("حاسبة رسوم توصيل المياه والصرف الصحي")
                .font(.system(size: 27, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text("تقدير رسوم التوصيل الجديد لخدمات المياه والصرف الصحي إلى العقار.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    private var introductoryNotice: some View {
        noticeCard(
            title: "تنبيه مهم",
            message: "هذه الحاسبة مخصصة لرسوم توصيل الخدمة لأول مرة إلى العقار، وليست لحساب فاتورة الاستهلاك الشهري. تعتمد النتائج على تصنيف العقار ومساحة البناء ونوع الخدمة وعدد الوحدات السكنية عند انطباقها."
        )
    }

    private var inputSection: some View {
        calculatorCard {
            VStack(alignment: .trailing, spacing: 16) {
                sectionHeading("بيانات التوصيل")

                selectionRow(title: "تصنيف العقار", icon: "building.2.fill") {
                    Picker("تصنيف العقار", selection: $selectedSector) {
                        ForEach(SaudiWaterConnectionSector.allCases) { sector in
                            Text(sector.rawValue).tag(sector)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppTheme.buttonOrange)
                }

                selectionRow(title: "نوع الخدمة المطلوبة", icon: "water.waves") {
                    Picker("نوع الخدمة المطلوبة", selection: $selectedService) {
                        ForEach(SaudiWaterConnectionService.allCases) { service in
                            Text(service.rawValue).tag(service)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppTheme.buttonOrange)
                }

                inputRow(
                    title: "مساحة البناء (م²)",
                    icon: "square.dashed",
                    placeholder: "675",
                    text: $buildingAreaText,
                    keyboardType: .decimalPad,
                    helperText: "أدخل مساحة البناء بالمتر المربع، وليس مساحة الأرض."
                )

                if selectedSector == .residential {
                    inputRow(
                        title: "عدد الوحدات السكنية",
                        icon: "house.fill",
                        placeholder: "1",
                        text: $residentialUnitsText,
                        keyboardType: .numberPad,
                        helperText: "إجمالي الوحدات السكنية المشمولة بطلب التوصيل."
                    )
                }

                Toggle(isOn: $includeVat) {
                    labelContent(
                        title: "احتساب ضريبة القيمة المضافة (15%)",
                        icon: "percent"
                    )
                }
                .tint(AppTheme.buttonOrange)
                .environment(\.layoutDirection, .rightToLeft)

                Button(action: resetInputs) {
                    Label("إعادة تعيين", systemImage: "arrow.counterclockwise")
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

    private var directPricingSection: some View {
        calculatorCard {
            VStack(alignment: .trailing, spacing: 10) {
                sectionHeading("حدود التسعير المباشر")

                limitRow(
                    title: "الحد الأقصى للمساحة المحتسبة",
                    value: formatArea(selectedSector.maximumCalculatedAreaM2)
                )

                Text("تجاوز هذا الحد يتطلب تحديد تكلفة التنفيذ الفعلية وفق متطلبات التوصيل والأحكام التنظيمية.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    @ViewBuilder
    private func resultContent(_ result: SaudiWaterConnectionCalculationResult) -> some View {
        switch result {
        case .calculated(let calculation):
            calculatedResultSection(calculation)
            ShareResultButton(
                text: shareText(for: calculation),
                sharedImage: resultCardImage(for: calculation)
            )
            noticeCard(
                title: "ملاحظة",
                message: "هذه الرسوم تقديرية، وقد تختلف الرسوم الفعلية بحسب متطلبات التوصيل والأحكام التنظيمية. لا تحدد الحاسبة أهلية طلب التوصيل، ولا تمثل عرض سعر أو فاتورة رسمية من مقدم الخدمة، ولا تشمل الحالات الخاصة بالمطور العقاري أو العقارات المختلطة التي تتطلب تحديدًا تنظيميًا إضافيًا."
            )
        case .requiresQuote(let quote):
            quoteWarning(message: quote.message)
        }
    }

    private func calculatedResultSection(
        _ calculation: SaudiWaterConnectionCalculatedResult
    ) -> some View {
        calculatorCard {
            VStack(spacing: 16) {
                Text("إجمالي رسوم التوصيل التقديرية")
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

                VStack(alignment: .trailing, spacing: 0) {
                    sectionHeading("تفاصيل رسوم التوصيل")

                    if selectedService.includesWater {
                        resultRow(
                            title: "رسوم توصيل المياه حسب المساحة",
                            value: formatCurrency(calculation.waterFee)
                        )
                    }

                    if selectedService.includesSewer {
                        resultRow(
                            title: "رسوم توصيل الصرف الصحي حسب المساحة",
                            value: formatCurrency(calculation.sewerFee)
                        )
                    }

                    if calculation.additionalWaterFee > 0 {
                        resultRow(
                            title: "رسوم المياه للوحدات الإضافية",
                            value: formatCurrency(calculation.additionalWaterFee)
                        )
                    }

                    if calculation.additionalSewerFee > 0 {
                        resultRow(
                            title: "رسوم الصرف للوحدات الإضافية",
                            value: formatCurrency(calculation.additionalSewerFee)
                        )
                    }

                    resultRow(
                        title: "الإجمالي قبل الضريبة",
                        value: formatCurrency(calculation.beforeVat)
                    )

                    if includeVat {
                        resultRow(
                            title: "ضريبة القيمة المضافة 15%",
                            value: formatCurrency(calculation.vatAmount)
                        )
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private func quoteWarning(message: String) -> some View {
        calculatorCard {
            VStack(alignment: .trailing, spacing: 12) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppTheme.buttonOrange)
                    Text("يلزم تحديد تكلفة التنفيذ الفعلية")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .multilineTextAlignment(.trailing)
                }
                .environment(\.layoutDirection, .leftToRight)

                Text(message)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text("لن تعرض الحاسبة مبلغًا افتراضيًا في هذه الحالة، لأن الرسوم لا يمكن تحديدها بدقة من جدول المساحات وحده.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func validationCard(message: String) -> some View {
        calculatorCard {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(AppTheme.buttonOrange)
                Text(message)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(4)
                Spacer(minLength: 0)
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }

    private func noticeCard(title: String, message: String) -> some View {
        calculatorCard {
            VStack(alignment: .trailing, spacing: 8) {
                sectionHeading(title)
                Text(message)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
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
        helperText: String
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

            Text(helperText)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
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
        .padding(.vertical, 11)
        .environment(\.layoutDirection, .leftToRight)
    }

    private func limitRow(title: String, value: String) -> some View {
        resultRow(title: title, value: value)
            .background(AppTheme.inputBackground.opacity(0.62))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var validationMessage: String? {
        guard let area = parsedBuildingArea else {
            return "أدخل مساحة بناء صالحة أكبر من صفر."
        }

        guard area.isFinite, area > 0 else {
            return "يجب أن تكون مساحة البناء رقمًا منتهيًا وأكبر من صفر."
        }

        if selectedSector == .residential {
            guard let units = parsedResidentialUnits else {
                return "أدخل عدد وحدات سكنية صحيحًا."
            }

            guard units >= 1 else {
                return "يجب أن يكون عدد الوحدات السكنية واحدًا أو أكثر."
            }
        }

        return nil
    }

    private var calculationResult: SaudiWaterConnectionCalculationResult? {
        guard validationMessage == nil, let area = parsedBuildingArea else {
            return nil
        }

        let units = selectedSector == .residential ? (parsedResidentialUnits ?? 1) : 1

        return try? SaudiWaterConnectionCalculator.calculate(
            sector: selectedSector,
            service: selectedService,
            buildingAreaM2: area,
            residentialUnits: units,
            includeVat: includeVat
        )
    }

    private var parsedBuildingArea: Double? {
        parseDouble(buildingAreaText)
    }

    private var parsedResidentialUnits: Int? {
        let normalized = normalizeDigits(residentialUnitsText)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else { return nil }
        guard let decimal = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")) else {
            return nil
        }

        let integer = NSDecimalNumber(decimal: decimal)
        guard integer == NSDecimalNumber(value: integer.intValue),
              integer.intValue >= 1 else {
            return nil
        }

        return integer.intValue
    }

    private func parseDouble(_ text: String) -> Double? {
        let normalized = normalizeDigits(text)
            .replacingOccurrences(of: "٫", with: ".")
            .replacingOccurrences(of: "٬", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else { return nil }
        return Double(normalized)
    }

    private func normalizeDigits(_ text: String) -> String {
        let arabicDigits = "٠١٢٣٤٥٦٧٨٩"
        let persianDigits = "۰۱۲۳۴۵۶۷۸۹"
        let englishDigits = "0123456789"

        var result = ""
        for character in text {
            if let index = arabicDigits.firstIndex(of: character) {
                result.append(englishDigits[englishDigits.index(englishDigits.startIndex, offsetBy: arabicDigits.distance(from: arabicDigits.startIndex, to: index))])
            } else if let index = persianDigits.firstIndex(of: character) {
                result.append(englishDigits[englishDigits.index(englishDigits.startIndex, offsetBy: persianDigits.distance(from: persianDigits.startIndex, to: index))])
            } else {
                result.append(character)
            }
        }
        return result
    }

    private func formatArea(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        return "\(formatter.string(from: NSNumber(value: value)) ?? "\(value)") م²"
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return "\(formatter.string(from: NSNumber(value: value)) ?? "\(value)") ر.س"
    }

    private func resetInputs() {
        selectedSector = .residential
        selectedService = .both
        buildingAreaText = "675"
        residentialUnitsText = "1"
        includeVat = true
    }

    private func shareText(for calculation: SaudiWaterConnectionCalculatedResult) -> String {
        var lines = [
            "نتيجة حاسبة رسوم توصيل المياه والصرف الصحي من احسبها:",
            "",
            "تصنيف العقار: \(selectedSector.rawValue)",
            "نوع الخدمة: \(selectedService.rawValue)",
            "مساحة البناء: \(buildingAreaText) م²"
        ]

        if selectedSector == .residential {
            lines.append("عدد الوحدات السكنية: \(residentialUnitsText)")
        }

        lines.append("ضريبة القيمة المضافة: \(includeVat ? "محتسبة" : "غير محتسبة")")
        lines.append("")

        if selectedService.includesWater {
            lines.append("رسوم المياه حسب المساحة: \(formatCurrency(calculation.waterFee))")
        }
        if selectedService.includesSewer {
            lines.append("رسوم الصرف الصحي حسب المساحة: \(formatCurrency(calculation.sewerFee))")
        }
        if calculation.additionalWaterFee > 0 {
            lines.append("رسوم المياه للوحدات الإضافية: \(formatCurrency(calculation.additionalWaterFee))")
        }
        if calculation.additionalSewerFee > 0 {
            lines.append("رسوم الصرف للوحدات الإضافية: \(formatCurrency(calculation.additionalSewerFee))")
        }

        lines.append("الإجمالي قبل الضريبة: \(formatCurrency(calculation.beforeVat))")
        if includeVat {
            lines.append("ضريبة القيمة المضافة: \(formatCurrency(calculation.vatAmount))")
        }
        lines.append("الإجمالي: \(formatCurrency(calculation.total))")
        return lines.joined(separator: "\n")
    }

    @MainActor
    private func resultCardImage(for calculation: SaudiWaterConnectionCalculatedResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة رسوم توصيل المياه والصرف الصحي",
            rows: resultRows(for: calculation),
            note: "هذه رسوم تقديرية وليست عرض سعر أو فاتورة رسمية."
        )
    }

    private func resultRows(
        for calculation: SaudiWaterConnectionCalculatedResult
    ) -> [ResultCardRow] {
        var rows = [
            ResultCardRow(
                title: "الإجمالي",
                value: formatCurrency(calculation.total),
                valueColor: AppTheme.buttonOrange
            )
        ]

        if selectedService.includesWater {
            rows.append(ResultCardRow(
                title: "رسوم المياه حسب المساحة",
                value: formatCurrency(calculation.waterFee)
            ))
        }
        if selectedService.includesSewer {
            rows.append(ResultCardRow(
                title: "رسوم الصرف الصحي حسب المساحة",
                value: formatCurrency(calculation.sewerFee)
            ))
        }
        if calculation.additionalWaterFee > 0 {
            rows.append(ResultCardRow(
                title: "رسوم المياه للوحدات الإضافية",
                value: formatCurrency(calculation.additionalWaterFee)
            ))
        }
        if calculation.additionalSewerFee > 0 {
            rows.append(ResultCardRow(
                title: "رسوم الصرف للوحدات الإضافية",
                value: formatCurrency(calculation.additionalSewerFee)
            ))
        }
        rows.append(ResultCardRow(
            title: "قبل الضريبة",
            value: formatCurrency(calculation.beforeVat)
        ))
        if includeVat {
            rows.append(ResultCardRow(
                title: "ضريبة القيمة المضافة",
                value: formatCurrency(calculation.vatAmount)
            ))
        }
        return rows
    }

    private func sectionHeading(_ title: String) -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
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

    private func calculatorCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(AppTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow, radius: 12, x: 0, y: 6)
    }
}
