//
//  CivilRetirementCalculatorView.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-17.
//

import SwiftUI
import Foundation
import UIKit

struct CivilRetirementCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var basicSalary: String = ""
    @State private var years: String = ""
    @State private var months: String = ""
    @State private var retirementReason: CivilRetirementReason = .regularOrEarly

    private var result: CivilRetirementCalculationResult? {
        calculateCivilRetirement()
    }

    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }

    private var cardBackground: Color {
        colorScheme == .light ? Color.white : AppTheme.secondaryBackground
    }

    private var inputCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F7FBFF") : AppTheme.secondaryBackground
    }

    private var resultCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF8F0") : AppTheme.secondaryBackground
    }

    private var detailsCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F6FAF8") : AppTheme.secondaryBackground
    }

    private var infoCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF9F2") : AppTheme.secondaryBackground
    }

    private var warningCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF7F7") : Color.red.opacity(0.10)
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

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    headerSection
                    inputSection
                    resultCard

                    if let result {
                        detailsCard(result)
                        resultInsightsSection(result)
                        shareCard(result)
                    } else {
                        emptyStateSection
                    }

                    descriptionSection
                    warningSection
                    explanationSection
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
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "person.badge.shield.checkmark")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.blue)
                .frame(width: 58, height: 58)
                .background(Color.blue.opacity(colorScheme == .light ? 0.10 : 0.16))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text("حاسبة التقاعد المدني")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("تقدير المعاش التقاعدي للموظف المدني حسب البيانات المدخلة.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var inputSection: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("بيانات التقاعد")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            calculatorInput(
                title: "الراتب الأساسي الأخير",
                placeholder: "مثال: 12000",
                value: $basicSalary,
                suffix: "ر.س",
                icon: "banknote.fill"
            )

            calculatorInput(
                title: "سنوات الخدمة",
                placeholder: "مثال: 30",
                value: $years,
                suffix: "سنة",
                icon: "calendar"
            )

            calculatorInput(
                title: "أشهر إضافية",
                placeholder: "مثال: 6",
                value: $months,
                suffix: "شهر",
                icon: "calendar.badge.clock"
            )

            segmentedPicker(
                title: "سبب التقاعد أو التسوية",
                selection: $retirementReason,
                options: CivilRetirementReason.allCases
            )

            Button {
                clearInputs()
            } label: {
                Label("مسح", systemImage: "trash")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 50)
                    .background(Color.red.opacity(colorScheme == .light ? 0.08 : 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.red.opacity(0.18), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(inputCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.blue.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private var resultCard: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("المعاش الشهري التقديري")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(result.map { formatCurrency($0.monthlyPension) } ?? "—")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(result == nil ? AppTheme.secondaryText.opacity(0.55) : AppTheme.buttonOrange)
                .minimumScaleFactor(0.48)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(result == nil ? "أدخل الراتب ومدة الخدمة لعرض التقدير." : "النتيجة تقديرية وليست استحقاقًا رسميًا.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 172)
        .background(resultCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.18 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private func detailsCard(_ result: CivilRetirementCalculationResult) -> some View {
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
                CivilRetirementSummaryChip(title: "الراتب الأساسي الأخير", value: formatCurrency(result.basicSalary))
                CivilRetirementSummaryChip(title: "مدة الخدمة", value: result.serviceDurationText)
                CivilRetirementSummaryChip(title: "إجمالي أشهر الخدمة", value: "\(result.totalServiceMonths) شهر")
                CivilRetirementSummaryChip(title: "أشهر الخدمة المحتسبة", value: "\(result.countedServiceMonths) شهر")
                CivilRetirementSummaryChip(title: "سبب التقاعد أو التسوية", value: result.retirementReason.title)
                CivilRetirementSummaryChip(title: "نسبة المعاش من الراتب", value: "\(formatNumber(result.pensionPercentage))%", isHighlighted: true)
            }

            if result.wasCappedAtFullSalary {
                Text("تم احتساب المعاش بحد أقصى يعادل الراتب الأساسي الأخير.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 2)
            }
        }
        .padding(18)
        .background(detailsCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.green.opacity(colorScheme == .light ? 0.14 : 0.22), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private func resultInsightsSection(_ result: CivilRetirementCalculationResult) -> some View {
        VStack(alignment: .center, spacing: 12) {
            Text("تحليل مختصر")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            insightCard(
                title: "نسبة المعاش",
                message: "يمثل المعاش تقريبًا \(formatNumber(result.pensionPercentage))٪ من الراتب الأساسي الأخير.",
                icon: "percent",
                color: insightColor(for: result.pensionPercentage)
            )

            insightCard(
                title: serviceProgressTitle(for: result),
                message: serviceProgressMessage(for: result),
                icon: "calendar.badge.clock",
                color: serviceProgressColor(for: result)
            )
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.05) : .clear, radius: colorScheme == .light ? 7 : 0, x: 0, y: colorScheme == .light ? 3 : 0)
    }

    private func insightCard(
        title: String,
        message: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
                .frame(width: 42, height: 42)
                .background(color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(color.opacity(colorScheme == .light ? 0.07 : 0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(color.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private func shareCard(_ result: CivilRetirementCalculationResult) -> some View {
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

    private var emptyStateSection: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "person.badge.shield.checkmark")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)

            Text("جاهز للحساب")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("أدخل الراتب الأساسي ومدة الخدمة لعرض المعاش التقديري.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }

    private var descriptionSection: some View {
        infoCard(
            title: "وصف الحاسبة",
            text: "تقدّر المعاش المدني اعتمادًا على الراتب الأساسي الأخير ومدة الخدمة.",
            icon: "doc.text.fill",
            tint: .blue
        )
    }

    private var warningSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.red)

            Text("تنبيه مهم")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("النتيجة تقديرية وليست استحقاقًا رسميًا. يرجى الرجوع للجهة المختصة عند الحاجة.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(warningCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.red.opacity(0.16), lineWidth: 1)
        )
    }

    private var explanationSection: some View {
        infoCard(
            title: "طريقة الحساب",
            text: "المعاش التقديري = الراتب الأساسي الأخير × أشهر الخدمة المحتسبة ÷ 480.",
            icon: "function",
            tint: AppTheme.buttonOrange
        )
    }

    private func infoCard(title: String, text: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(tint)

            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(infoCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.16 : 0.22), lineWidth: 1)
        )
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
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppTheme.buttonOrange)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.10 : 0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                TextField(
                    "",
                    text: value,
                    prompt: Text(placeholder)
                        .foregroundColor(AppTheme.secondaryText.opacity(0.65))
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .tint(AppTheme.buttonOrange)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .center)

                Text(suffix)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.buttonOrange)
                    .frame(width: 44, alignment: .center)
            }
            .padding(.horizontal, 12)
            .frame(height: 56)
            .background(inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(cardBorder, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func segmentedPicker<T: CivilPickerOption>(
        title: String,
        selection: Binding<T>,
        options: [T]
    ) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Picker(title, selection: selection) {
                ForEach(options) { option in
                    Text(option.title)
                        .tag(option)
                }
            }
            .pickerStyle(.segmented)
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    private func insightColor(for pensionPercentage: Double) -> Color {
        if pensionPercentage >= 75 {
            return .green
        } else if pensionPercentage >= 50 {
            return .blue
        } else if pensionPercentage >= 30 {
            return AppTheme.buttonOrange
        } else {
            return .red
        }
    }

    private func serviceProgressColor(for result: CivilRetirementCalculationResult) -> Color {
        if result.countedServiceMonths >= 480 {
            return .green
        } else if result.countedServiceMonths >= 360 {
            return .blue
        } else if result.countedServiceMonths >= 240 {
            return AppTheme.buttonOrange
        } else {
            return .red
        }
    }

    private func serviceProgressTitle(for result: CivilRetirementCalculationResult) -> String {
        if result.countedServiceMonths >= 480 {
            return "خدمة مكتملة"
        } else if result.countedServiceMonths >= 360 {
            return "قريبة من الحد الأعلى"
        } else if result.countedServiceMonths >= 240 {
            return "مدة خدمة متوسطة"
        } else {
            return "مدة خدمة محدودة"
        }
    }

    private func serviceProgressMessage(for result: CivilRetirementCalculationResult) -> String {
        let remainingMonths = max(480 - result.countedServiceMonths, 0)
        let remainingYears = Double(remainingMonths) / 12.0
        let progress = (Double(result.countedServiceMonths) / 480.0) * 100.0

        if result.countedServiceMonths >= 480 {
            return "مدة الخدمة وصلت إلى 40 سنة أو أكثر، لذلك يظهر التقدير عند الحد الأعلى للمعادلة."
        }

        return "مدة الخدمة تعادل تقريبًا \(formatNumber(progress))٪ من حد 40 سنة. المتبقي يقارب \(formatNumber(remainingYears)) سنة."
    }

    private func pensionReadingTitle(for result: CivilRetirementCalculationResult) -> String {
        if result.pensionPercentage >= 75 {
            return "معاش قوي"
        } else if result.pensionPercentage >= 50 {
            return "معاش جيد"
        } else if result.pensionPercentage >= 30 {
            return "معاش متوسط"
        } else {
            return "معاش منخفض نسبيًا"
        }
    }

    private func pensionReadingMessage(for result: CivilRetirementCalculationResult) -> String {
        if result.pensionPercentage >= 75 {
            return "النسبة مرتفعة مقارنة بالراتب الأساسي الأخير، وهذا غالبًا يرتبط بمدة خدمة طويلة."
        } else if result.pensionPercentage >= 50 {
            return "النسبة جيدة، ومع زيادة مدة الخدمة تقترب النتيجة أكثر من الحد الأعلى للمعاش."
        } else if result.pensionPercentage >= 30 {
            return "النسبة متوسطة، وقد تكون مدة الخدمة لم تصل بعد إلى مستوى يعطي معاشًا قريبًا من الراتب الأساسي."
        } else {
            return "النسبة منخفضة نسبيًا، وغالبًا يرجع ذلك إلى قصر مدة الخدمة المحتسبة في المعادلة."
        }
    }

    private func calculateCivilRetirement() -> CivilRetirementCalculationResult? {
        guard let salaryValue = parseNumber(basicSalary),
              let yearsValue = parseNumber(years),
              salaryValue > 0,
              yearsValue >= 0 else {
            return nil
        }

        let monthsValue = parseNumber(months) ?? 0

        guard monthsValue >= 0 else {
            return nil
        }

        let totalMonths = Int((yearsValue * 12 + monthsValue).rounded())

        guard totalMonths > 0 else {
            return nil
        }

        let countedMonths = min(totalMonths, 480)
        let formulaPension = salaryValue * Double(countedMonths) / 480.0
        let minimumDisabilityOrDeath = salaryValue * 0.40

        let pensionBeforeCap: Double

        switch retirementReason {
        case .regularOrEarly:
            pensionBeforeCap = formulaPension

        case .disabilityOrDeathNonWork:
            pensionBeforeCap = max(formulaPension, minimumDisabilityOrDeath)
        }

        let monthlyPension = min(pensionBeforeCap, salaryValue)
        let percentage = (monthlyPension / salaryValue) * 100

        return CivilRetirementCalculationResult(
            basicSalary: salaryValue,
            years: Int(yearsValue),
            months: Int(monthsValue),
            totalServiceMonths: totalMonths,
            countedServiceMonths: countedMonths,
            retirementReason: retirementReason,
            monthlyPension: monthlyPension,
            pensionPercentage: percentage,
            wasCappedAtFullSalary: totalMonths > 480
        )
    }

    private func clearInputs() {
        basicSalary = ""
        years = ""
        months = ""
        retirementReason = .regularOrEarly
    }

    private func parseNumber(_ text: String) -> Double? {
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

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0

        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formatted) ر.س"
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func shareText(for result: CivilRetirementCalculationResult) -> String {
        """
        نتيجة حاسبة التقاعد المدني من احسبها:

        الراتب الأساسي الأخير: \(formatCurrency(result.basicSalary))
        مدة الخدمة: \(result.serviceDurationText)
        إجمالي أشهر الخدمة: \(result.totalServiceMonths) شهر
        سبب التقاعد أو التسوية: \(result.retirementReason.title)

        نسبة المعاش من الراتب: \(formatNumber(result.pensionPercentage))%
        المعاش الشهري التقديري: \(formatCurrency(result.monthlyPension))

        النتيجة تقديرية وليست استحقاقًا رسميًا. للحصول على نتيجة دقيقة وملزمة يرجى الرجوع إلى المؤسسة العامة للتأمينات الاجتماعية أو الجهة المختصة.
        """
    }

    @MainActor
    private func resultCardImage(for result: CivilRetirementCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة التقاعد المدني",
            rows: [
                ResultCardRow(title: "الراتب الأساسي الأخير", value: formatCurrency(result.basicSalary)),
                ResultCardRow(title: "مدة الخدمة", value: result.serviceDurationText),
                ResultCardRow(title: "إجمالي أشهر الخدمة", value: "\(result.totalServiceMonths) شهر"),
                ResultCardRow(title: "سبب التقاعد أو التسوية", value: result.retirementReason.title),
                ResultCardRow(title: "نسبة المعاش من الراتب", value: "\(formatNumber(result.pensionPercentage))%"),
                ResultCardRow(title: "المعاش الشهري التقديري", value: formatCurrency(result.monthlyPension), valueColor: AppTheme.buttonOrange)
            ],
            note: "النتيجة تقديرية وليست استحقاقًا رسميًا."
        )
    }
}

private protocol CivilPickerOption: Identifiable, Hashable {
    var title: String { get }
}

private enum CivilRetirementReason: String, CaseIterable, CivilPickerOption {
    case regularOrEarly
    case disabilityOrDeathNonWork

    var id: String { rawValue }

    var title: String {
        switch self {
        case .regularOrEarly:
            return "نظامي / مبكر"
        case .disabilityOrDeathNonWork:
            return "عجز / وفاة"
        }
    }
}

private struct CivilRetirementCalculationResult {
    let basicSalary: Double
    let years: Int
    let months: Int
    let totalServiceMonths: Int
    let countedServiceMonths: Int
    let retirementReason: CivilRetirementReason
    let monthlyPension: Double
    let pensionPercentage: Double
    let wasCappedAtFullSalary: Bool

    var serviceDurationText: String {
        "\(years) سنة، \(months) شهر"
    }
}

private struct CivilRetirementSummaryChip: View {
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
                .lineLimit(2)
                .minimumScaleFactor(0.55)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .center)
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
        CivilRetirementCalculatorView()
    }
}
