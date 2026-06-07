//
//  EndOfServiceCalculatorView.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-17.
//

import SwiftUI
import Foundation
import UIKit

struct EndOfServiceCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var salary: String = ""
    @State private var contractType: ContractType = .fixed
    @State private var endReason: EndReason = .employerTermination
    @State private var startDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()

    private var result: EndOfServiceCalculationResult? {
        calculateEndOfService()
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

    private var innerCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFC") : AppTheme.inputBackground
    }

    private var infoCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF7ED") : AppTheme.secondaryBackground
    }

    private var warningCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF7F7") : Color.red.opacity(0.10)
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
                        serviceDetailsCard(result)
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
            Image(systemName: "briefcase.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 58, height: 58)
                .background(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.10 : 0.16))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text("حاسبة نهاية الخدمة")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("تقدير مكافأة نهاية الخدمة وفق القواعد العامة لنظام العمل السعودي.")
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
            Text("بيانات العمل")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            calculatorInput(
                title: "الأجر الفعلي الأخير",
                placeholder: "مثال: 7500",
                value: $salary,
                suffix: "ر.س",
                icon: "banknote.fill"
            )

            segmentedPicker(
                title: "نوع العقد",
                selection: $contractType,
                options: ContractType.allCases
            )

            segmentedPicker(
                title: "سبب انتهاء العلاقة",
                selection: $endReason,
                options: EndReason.allCases
            )

            dateInput(
                title: "تاريخ بداية العمل",
                date: $startDate,
                icon: "calendar.badge.plus"
            )

            dateInput(
                title: "تاريخ نهاية العمل",
                date: $endDate,
                icon: "calendar.badge.minus"
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
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.18 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private var resultCard: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("مكافأة نهاية الخدمة")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(result.map { formatCurrency($0.finalReward) } ?? "—")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(result == nil ? AppTheme.secondaryText.opacity(0.55) : AppTheme.buttonOrange)
                .minimumScaleFactor(0.48)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(result == nil ? "أدخل الأجر والتواريخ لعرض التقدير." : "النتيجة تقديرية حسب البيانات المدخلة.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 172)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private func serviceDetailsCard(_ result: EndOfServiceCalculationResult) -> some View {
        VStack(alignment: .center, spacing: 14) {
            Text("تفاصيل الخدمة")
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
                EndOfServiceSummaryChip(title: "مدة الخدمة", value: result.serviceDurationText)
                EndOfServiceSummaryChip(title: "عدد السنوات", value: "\(formatNumber(Double(result.years))) سنة")
                EndOfServiceSummaryChip(title: "عدد الأشهر", value: "\(formatNumber(Double(result.months))) شهر")
                EndOfServiceSummaryChip(title: "الأجر الأخير", value: formatCurrency(result.salary))
                EndOfServiceSummaryChip(title: "نوع العقد", value: result.contractType.title)
                EndOfServiceSummaryChip(title: "سبب الانتهاء", value: result.endReason.title)
                EndOfServiceSummaryChip(title: "المكافأة الكاملة", value: formatCurrency(result.fullReward))
                EndOfServiceSummaryChip(title: "نسبة الاستحقاق", value: "\(formatNumber(result.entitlementRatio * 100))%", isHighlighted: true)
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

    private func shareCard(_ result: EndOfServiceCalculationResult) -> some View {
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
            Image(systemName: "briefcase.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)

            Text("جاهز للحساب")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("أدخل الأجر الفعلي وتاريخي بداية ونهاية العمل لعرض المكافأة التقديرية.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(18)
        .background(innerCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }

    private var descriptionSection: some View {
        infoCard(
            title: "وصف الحاسبة",
            text: "تقدّر مكافأة نهاية الخدمة بناءً على الأجر الأخير ومدة الخدمة وسبب انتهاء العلاقة.",
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

            Text("النتيجة تقديرية وقد تختلف حسب العقد والاستثناءات النظامية. يرجى الرجوع للجهة المختصة عند الحاجة.")
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
            text: "تُحسب المكافأة الكاملة حسب مدة الخدمة، ثم تطبّق نسبة الاستحقاق حسب سبب انتهاء العلاقة.",
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

    private func segmentedPicker<T: PickerOption>(
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

    private func dateInput(
        title: String,
        date: Binding<Date>,
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

                DatePicker("", selection: date, displayedComponents: .date)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "ar_SA"))
                    .tint(AppTheme.buttonOrange)
                    .frame(maxWidth: .infinity, alignment: .center)
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

    private func calculateEndOfService() -> EndOfServiceCalculationResult? {
        guard let salaryValue = parseNumber(salary),
              salaryValue > 0,
              endDate > startDate else {
            return nil
        }

        let calendar = Calendar.current
        let serviceComponents = calendar.dateComponents([.year, .month, .day], from: startDate, to: endDate)
        let years = serviceComponents.year ?? 0
        let months = serviceComponents.month ?? 0
        let days = serviceComponents.day ?? 0

        let totalDays = max(calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0, 0)
        let serviceYearsDecimal = Double(totalDays) / 365.0

        let firstFiveYears = min(serviceYearsDecimal, 5.0)
        let yearsAfterFive = max(serviceYearsDecimal - 5.0, 0)

        let firstFiveReward = firstFiveYears * salaryValue * 0.5
        let afterFiveReward = yearsAfterFive * salaryValue
        let fullReward = firstFiveReward + afterFiveReward

        let ratio = entitlementRatio(for: endReason, serviceYearsDecimal: serviceYearsDecimal)
        let finalReward = fullReward * ratio

        return EndOfServiceCalculationResult(
            salary: salaryValue,
            contractType: contractType,
            endReason: endReason,
            startDate: startDate,
            endDate: endDate,
            years: years,
            months: months,
            days: days,
            serviceYearsDecimal: serviceYearsDecimal,
            fullReward: fullReward,
            entitlementRatio: ratio,
            finalReward: finalReward
        )
    }

    private func entitlementRatio(for reason: EndReason, serviceYearsDecimal: Double) -> Double {
        switch reason {
        case .employerTermination:
            return 1.0

        case .resignation:
            if serviceYearsDecimal < 2 {
                return 0
            } else if serviceYearsDecimal <= 5 {
                return 1.0 / 3.0
            } else if serviceYearsDecimal < 10 {
                return 2.0 / 3.0
            } else {
                return 1.0
            }
        }
    }

    private func clearInputs() {
        salary = ""
        contractType = .fixed
        endReason = .employerTermination
        startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        endDate = Date()
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

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func shareText(for result: EndOfServiceCalculationResult) -> String {
        """
        نتيجة حاسبة نهاية الخدمة من احسبها:

        الأجر الفعلي الأخير: \(formatCurrency(result.salary))
        نوع العقد: \(result.contractType.title)
        سبب انتهاء العلاقة: \(result.endReason.title)
        تاريخ بداية العمل: \(formatDate(result.startDate))
        تاريخ نهاية العمل: \(formatDate(result.endDate))
        مدة الخدمة: \(result.serviceDurationText)

        المكافأة الكاملة قبل نسبة الاستحقاق: \(formatCurrency(result.fullReward))
        نسبة الاستحقاق: \(formatNumber(result.entitlementRatio * 100))%
        مكافأة نهاية الخدمة المستحقة تقديريًا: \(formatCurrency(result.finalReward))

        النتيجة تقديرية، وللحصول على نتيجة دقيقة أو مطالبة رسمية يرجى الرجوع إلى وزارة الموارد البشرية والتنمية الاجتماعية أو منصة قوى أو الجهة المختصة.
        """
    }

    @MainActor
    private func resultCardImage(for result: EndOfServiceCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة نهاية الخدمة",
            rows: [
                ResultCardRow(title: "الأجر الفعلي الأخير", value: formatCurrency(result.salary)),
                ResultCardRow(title: "نوع العقد", value: result.contractType.title),
                ResultCardRow(title: "سبب انتهاء العلاقة", value: result.endReason.title),
                ResultCardRow(title: "مدة الخدمة", value: result.serviceDurationText),
                ResultCardRow(title: "المكافأة الكاملة", value: formatCurrency(result.fullReward)),
                ResultCardRow(title: "نسبة الاستحقاق", value: "\(formatNumber(result.entitlementRatio * 100))%"),
                ResultCardRow(title: "المبلغ النهائي", value: formatCurrency(result.finalReward), valueColor: AppTheme.buttonOrange)
            ],
            note: "النتائج تقديرية، ويرجى الرجوع للجهة المختصة."
        )
    }
}

private protocol PickerOption: Identifiable, Hashable {
    var title: String { get }
}

private enum ContractType: String, CaseIterable, PickerOption {
    case fixed
    case unlimited

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fixed:
            return "محدد المدة"
        case .unlimited:
            return "غير محدد"
        }
    }
}

private enum EndReason: String, CaseIterable, PickerOption {
    case employerTermination
    case resignation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .employerTermination:
            return "انتهاء / إنهاء"
        case .resignation:
            return "استقالة"
        }
    }
}

private struct EndOfServiceCalculationResult {
    let salary: Double
    let contractType: ContractType
    let endReason: EndReason
    let startDate: Date
    let endDate: Date
    let years: Int
    let months: Int
    let days: Int
    let serviceYearsDecimal: Double
    let fullReward: Double
    let entitlementRatio: Double
    let finalReward: Double

    var serviceDurationText: String {
        "\(years) سنة، \(months) شهر، \(days) يوم"
    }
}

private struct EndOfServiceSummaryChip: View {
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
        EndOfServiceCalculatorView()
    }
}
