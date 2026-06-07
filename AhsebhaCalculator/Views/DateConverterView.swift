//
//  DateConverterView.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-13.
//

import SwiftUI
import UIKit

struct DateConverterView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedMode: DateConversionMode = .gregorianToHijri

    @State private var gregorianDate: Date = Date()
    @State private var hijriDate: Date = Date()

    private var selectedDate: Date {
        selectedMode == .gregorianToHijri ? gregorianDate : hijriDate
    }

    private var resultTitle: String {
        selectedMode == .gregorianToHijri ? "التاريخ الهجري" : "التاريخ الميلادي"
    }

    private var resultText: String {
        selectedMode == .gregorianToHijri
        ? formatHijriDate(gregorianDate)
        : formatGregorianDate(hijriDate)
    }

    private var secondaryResultText: String {
        selectedMode == .gregorianToHijri
        ? formatGregorianDate(gregorianDate)
        : formatHijriDate(hijriDate)
    }

    private var numericResultText: String {
        selectedMode == .gregorianToHijri
        ? formatNumericHijriDate(gregorianDate)
        : formatNumericGregorianDate(hijriDate)
    }

    private var result: DateConversionResult {
        DateConversionResult(
            inputDate: secondaryResultText,
            conversionType: selectedMode.title,
            convertedDate: resultText,
            numericConvertedDate: numericResultText
        )
    }

    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }

    private var cardBackground: Color {
        colorScheme == .light ? Color.white : AppTheme.secondaryBackground
    }

    private var modeCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFF") : AppTheme.secondaryBackground
    }

    private var pickerCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F5FF") : AppTheme.secondaryBackground
    }

    private var resultCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F4F9FF") : AppTheme.secondaryBackground
    }

    private var detailsCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFC") : AppTheme.secondaryBackground
    }

    private var noteCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF9F2") : AppTheme.secondaryBackground
    }

    private var cardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : AppTheme.border
    }

    private var cardShadow: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : .clear
    }

    private func shareText(for result: DateConversionResult) -> String {
        """
        تحويل التاريخ - احسبها

        نوع التحويل:
        \(result.conversionType)

        التاريخ المدخل:
        \(result.inputDate)

        التاريخ الناتج:
        \(result.convertedDate)

        التاريخ الرقمي:
        \(result.numericConvertedDate)
        """
    }

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    headerSection
                    modeSelector
                    pickerCard
                    resultCard
                    detailsCard
                    shareCard
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
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("تحويل التاريخ")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("حوّل التاريخ بين الميلادي والهجري وفق تقويم أم القرى.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var modeSelector: some View {
        HStack(spacing: 10) {
            ForEach(DateConversionMode.allCases) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    VStack(spacing: 7) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 21, weight: .semibold))

                        Text(mode.shortTitle)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundColor(selectedMode == mode ? AppTheme.buttonOrange : AppTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(selectedMode == mode ? AppTheme.buttonOrange.opacity(0.12) : cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(
                                        selectedMode == mode ? AppTheme.buttonOrange.opacity(0.35) : cardBorder,
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(modeCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.indigo.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private var pickerCard: some View {
        VStack(alignment: .center, spacing: 14) {
            Text(selectedMode.inputTitle)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.indigo.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.indigo.opacity(colorScheme == .light ? 0.10 : 0.16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.indigo.opacity(colorScheme == .light ? 0.20 : 0.28), lineWidth: 1)
                    )
                    .frame(height: 44)
                    .padding(.horizontal, 12)

                if selectedMode == .gregorianToHijri {
                    DatePicker(
                        "",
                        selection: $gregorianDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.calendar, Calendar(identifier: .gregorian))
                    .environment(\.locale, Locale(identifier: "ar"))
                } else {
                    DatePicker(
                        "",
                        selection: $hijriDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.calendar, Calendar(identifier: .islamicUmmAlQura))
                    .environment(\.locale, Locale(identifier: "ar_SA"))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 176)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text(selectedMode.helperText)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(18)
        .background(pickerCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.indigo.opacity(colorScheme == .light ? 0.18 : 0.26), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private var resultCard: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(resultTitle)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(resultText)
                .font(.system(size: 27, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.buttonOrange)
                .minimumScaleFactor(0.48)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(numericResultText)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .minimumScaleFactor(0.65)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .environment(\.layoutDirection, .leftToRight)

            Text("التاريخ الناتج بعد التحويل")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 178)
        .background(resultCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.blue.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private var detailsCard: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("تفاصيل التحويل")
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
                DateConversionSummaryChip(title: "التاريخ المدخل", value: result.inputDate)
                DateConversionSummaryChip(title: "نوع التحويل", value: result.conversionType)
                DateConversionSummaryChip(title: "التاريخ الناتج", value: result.convertedDate, isHighlighted: true)
                DateConversionSummaryChip(title: "التاريخ الرقمي", value: result.numericConvertedDate, forceLeftToRight: true)
            }
        }
        .padding(18)
        .background(detailsCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private var shareCard: some View {
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

    private var noteCard: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)

            Text("ملاحظة")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("يعتمد التحويل الهجري على تقويم أم القرى المتوفر في iOS، وقد تختلف بعض النتائج حسب التقويم المستخدم.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(noteCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.16 : 0.22), lineWidth: 1)
        )
    }

    private func formatGregorianDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ar")
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    private func formatHijriDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    private func formatNumericGregorianDate(_ date: Date) -> String {
        formatNumericDate(date, calendar: Calendar(identifier: .gregorian))
    }

    private func formatNumericHijriDate(_ date: Date) -> String {
        formatNumericDate(date, calendar: Calendar(identifier: .islamicUmmAlQura))
    }

    private func formatNumericDate(_ date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    @MainActor
    private func resultCardImage(for result: DateConversionResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "تحويل التاريخ",
            rows: [
                ResultCardRow(title: "التاريخ المدخل", value: result.inputDate),
                ResultCardRow(title: "نوع التحويل", value: result.conversionType),
                ResultCardRow(title: "التاريخ المحوّل", value: result.convertedDate, valueColor: AppTheme.buttonOrange),
                ResultCardRow(title: "التاريخ الرقمي", value: result.numericConvertedDate)
            ],
            note: "النتائج تقديرية حسب التقويم المستخدم."
        )
    }
}

private struct DateConversionResult {
    let inputDate: String
    let conversionType: String
    let convertedDate: String
    let numericConvertedDate: String
}

enum DateConversionMode: String, CaseIterable, Identifiable {
    case gregorianToHijri
    case hijriToGregorian

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gregorianToHijri:
            return "من الميلادي إلى الهجري"
        case .hijriToGregorian:
            return "من الهجري إلى الميلادي"
        }
    }

    var shortTitle: String {
        switch self {
        case .gregorianToHijri:
            return "ميلادي ← هجري"
        case .hijriToGregorian:
            return "هجري ← ميلادي"
        }
    }

    var icon: String {
        switch self {
        case .gregorianToHijri:
            return "calendar"
        case .hijriToGregorian:
            return "moon.stars.fill"
        }
    }

    var inputTitle: String {
        switch self {
        case .gregorianToHijri:
            return "اختر التاريخ الميلادي"
        case .hijriToGregorian:
            return "اختر التاريخ الهجري"
        }
    }

    var helperText: String {
        switch self {
        case .gregorianToHijri:
            return "سيتم تحويل التاريخ الميلادي المختار إلى التاريخ الهجري وفق أم القرى."
        case .hijriToGregorian:
            return "سيتم تحويل التاريخ الهجري المختار إلى التاريخ الميلادي."
        }
    }
}

private struct DateConversionSummaryChip: View {
    let title: String
    let value: String
    var isHighlighted: Bool = false
    var forceLeftToRight: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(value)
                .font(.system(size: isHighlighted ? 15 : 14, weight: .bold, design: .rounded))
                .foregroundColor(isHighlighted ? AppTheme.buttonOrange : AppTheme.primaryText)
                .lineLimit(3)
                .minimumScaleFactor(0.55)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .environment(\.layoutDirection, forceLeftToRight ? .leftToRight : .rightToLeft)
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
        DateConverterView()
    }
}
