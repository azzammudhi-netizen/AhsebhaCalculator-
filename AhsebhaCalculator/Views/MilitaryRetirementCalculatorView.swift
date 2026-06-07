//
//  MilitaryRetirementCalculatorView.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-17.
//

import SwiftUI
import Foundation
import UIKit

struct MilitaryRetirementCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var basicSalary: String = ""
    @State private var years: String = ""
    @State private var months: String = ""
    @State private var retirementReason: MilitaryRetirementReason = .regularOrEarly

    private var result: MilitaryRetirementCalculationResult? {
        calculateMilitaryRetirement()
    }

    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }

    private var cardBackground: Color {
        colorScheme == .light ? Color.white : AppTheme.secondaryBackground
    }

    private var inputCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F6FAFD") : AppTheme.secondaryBackground
    }

    private var resultCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F4FBF8") : AppTheme.secondaryBackground
    }

    private var detailsCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F8F6FF") : AppTheme.secondaryBackground
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
                        insightsSection(result)
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
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.teal)
                .frame(width: 58, height: 58)
                .background(Color.teal.opacity(colorScheme == .light ? 0.10 : 0.16))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text("حاسبة التقاعد العسكري")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("تقدير المعاش التقاعدي للعسكري حسب الراتب الأساسي ومدة الخدمة.")
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
            Text("بيانات الخدمة")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            calculatorInput(
                title: "الراتب الأساسي الأخير",
                placeholder: "مثال: 14000",
                value: $basicSalary,
                suffix: "ر.س",
                icon: "banknote.fill"
            )

            calculatorInput(
                title: "سنوات الخدمة",
                placeholder: "مثال: 25",
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
                options: MilitaryRetirementReason.allCases
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
            Text("المعاش العسكري التقديري")
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
                .stroke(Color.teal.opacity(colorScheme == .light ? 0.18 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private func detailsCard(_ result: MilitaryRetirementCalculationResult) -> some View {
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
                MilitaryRetirementSummaryChip(title: "الراتب الأساسي", value: formatCurrency(result.basicSalary))
                MilitaryRetirementSummaryChip(title: "مدة الخدمة", value: result.serviceDurationText)
                MilitaryRetirementSummaryChip(title: "إجمالي أشهر الخدمة", value: "\(result.totalServiceMonths) شهر")
                MilitaryRetirementSummaryChip(title: "الرتبة أو الفئة", value: "حسب الراتب المدخل")
                MilitaryRetirementSummaryChip(title: "نسبة الاستحقاق", value: "\(formatNumber(result.pensionPercentage))%", isHighlighted: true)
                MilitaryRetirementSummaryChip(title: "طريقة الاحتساب", value: result.retirementReason.title)
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
                .stroke(Color.purple.opacity(colorScheme == .light ? 0.14 : 0.22), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private func insightsSection(_ result: MilitaryRetirementCalculationResult) -> some View {
        VStack(alignment: .center, spacing: 12) {
            Text("تحليل مختصر")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            insightCard(
                title: result.pensionPercentage >= 80 ? "استحقاق قوي" : "قراءة المعاش",
                text: "يمثل المعاش التقديري نحو \(formatNumber(result.pensionPercentage))٪ من الراتب الأساسي الأخير.",
                icon: "percent",
                color: result.pensionPercentage >= 80 ? .green : AppTheme.buttonOrange
            )

            insightCard(
                title: "مدة الخدمة",
                text: result.totalServiceMonths >= 360 ? "مدة خدمة مرتفعة وقريبة من الحد الكامل للمعاش العسكري." : "زيادة مدة الخدمة ترفع نسبة المعاش التقديري.",
                icon: "calendar.badge.clock",
                color: result.totalServiceMonths >= 360 ? .green : .blue
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

    private func insightCard(title: String, text: String, icon: String, color: Color) -> some View {
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

            Text(text)
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

    private func shareCard(_ result: MilitaryRetirementCalculationResult) -> some View {
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
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)

            Text("جاهز للحساب")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("أدخل الراتب الأساسي ومدة الخدمة لعرض المعاش العسكري التقديري.")
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
            text: "تقدّر المعاش العسكري اعتمادًا على الراتب الأساسي الأخير ومدة الخدمة وسبب التسوية.",
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

            Text("النتيجة تقديرية وليست استحقاقًا رسميًا. يرجى الرجوع للجهة العسكرية أو المختصة عند الحاجة.")
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
            text: "المعاش العسكري التقديري = الراتب الأساسي الأخير × أشهر الخدمة المحتسبة ÷ 420، مع تطبيق حالات العجز أو الوفاة حسب السبب.",
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

    private func segmentedPicker<T: MilitaryPickerOption>(
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

    private func calculateMilitaryRetirement() -> MilitaryRetirementCalculationResult? {
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

        let countedMonths = min(totalMonths, 420)
        let formulaPension = salaryValue * Double(countedMonths) / 420.0

        let pensionBeforeCap: Double

        switch retirementReason {
        case .regularOrEarly:
            pensionBeforeCap = formulaPension

        case .disabilityOrDeathNonWork:
            pensionBeforeCap = max(formulaPension, salaryValue * 0.70)

        case .disabilityOrDeathWork:
            pensionBeforeCap = salaryValue * 0.80
        }

        let monthlyPension = min(pensionBeforeCap, salaryValue)
        let percentage = (monthlyPension / salaryValue) * 100

        return MilitaryRetirementCalculationResult(
            basicSalary: salaryValue,
            years: Int(yearsValue),
            months: Int(monthsValue),
            totalServiceMonths: totalMonths,
            countedServiceMonths: countedMonths,
            retirementReason: retirementReason,
            monthlyPension: monthlyPension,
            pensionPercentage: percentage,
            wasCappedAtFullSalary: totalMonths > 420
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

    private func shareText(for result: MilitaryRetirementCalculationResult) -> String {
        """
        نتيجة حاسبة التقاعد العسكري من احسبها:

        الراتب الأساسي الأخير: \(formatCurrency(result.basicSalary))
        مدة الخدمة: \(result.serviceDurationText)
        إجمالي أشهر الخدمة: \(result.totalServiceMonths) شهر
        سبب التقاعد أو التسوية: \(result.retirementReason.title)

        نسبة المعاش من الراتب: \(formatNumber(result.pensionPercentage))%
        المعاش الشهري التقديري: \(formatCurrency(result.monthlyPension))

        النتيجة تقديرية وليست استحقاقًا رسميًا. للحصول على نتيجة دقيقة وملزمة يرجى الرجوع إلى المؤسسة العامة للتأمينات الاجتماعية أو الجهة العسكرية المختصة.
        """
    }

    @MainActor
    private func resultCardImage(for result: MilitaryRetirementCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة التقاعد العسكري",
            rows: [
                ResultCardRow(title: "الراتب الأساسي الأخير", value: formatCurrency(result.basicSalary)),
                ResultCardRow(title: "مدة الخدمة", value: result.serviceDurationText),
                ResultCardRow(title: "إجمالي أشهر الخدمة", value: "\(result.totalServiceMonths) شهر"),
                ResultCardRow(title: "سبب التقاعد أو التسوية", value: result.retirementReason.title),
                ResultCardRow(title: "نسبة المعاش من الراتب", value: "\(formatNumber(result.pensionPercentage))%"),
                ResultCardRow(title: "المعاش العسكري التقديري", value: formatCurrency(result.monthlyPension), valueColor: AppTheme.buttonOrange)
            ],
            note: "النتيجة تقديرية وليست استحقاقًا رسميًا."
        )
    }
}

private protocol MilitaryPickerOption: Identifiable, Hashable {
    var title: String { get }
}

private enum MilitaryRetirementReason: String, CaseIterable, MilitaryPickerOption {
    case regularOrEarly
    case disabilityOrDeathNonWork
    case disabilityOrDeathWork

    var id: String { rawValue }

    var title: String {
        switch self {
        case .regularOrEarly:
            return "نظامي / مبكر"
        case .disabilityOrDeathNonWork:
            return "عجز / وفاة"
        case .disabilityOrDeathWork:
            return "بسبب العمل"
        }
    }
}

private struct MilitaryRetirementCalculationResult {
    let basicSalary: Double
    let years: Int
    let months: Int
    let totalServiceMonths: Int
    let countedServiceMonths: Int
    let retirementReason: MilitaryRetirementReason
    let monthlyPension: Double
    let pensionPercentage: Double
    let wasCappedAtFullSalary: Bool

    var serviceDurationText: String {
        "\(years) سنة، \(months) شهر"
    }
}

private struct MilitaryRetirementSummaryChip: View {
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
        MilitaryRetirementCalculatorView()
    }
}
