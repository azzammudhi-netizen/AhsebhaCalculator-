import SwiftUI
import UIKit

struct DateDifferenceCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedCalendar: DateDifferenceCalendarType = .gregorian
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var result: DateDifferenceResult?
    @State private var validationMessage: String?
    @State private var isDatePickerExpanded = true

    private var activeCalendar: Calendar {
        selectedCalendar.calendar
    }

    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }

    private var cardBackground: Color {
        colorScheme == .light ? Color(hex: "#FBFCFF") : AppTheme.secondaryBackground
    }

    private var selectorBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F5FF") : AppTheme.secondaryBackground
    }

    private var pickerCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F4F9FF") : AppTheme.secondaryBackground
    }

    private var resultCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF8EF") : AppTheme.secondaryBackground
    }

    private var detailsCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFC") : AppTheme.secondaryBackground
    }

    private var infoCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F3FBF7") : AppTheme.secondaryBackground
    }

    private var warningBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF3F2") : AppTheme.secondaryBackground
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

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 18) {
                        headerSection
                        calendarSelector
                        dateInputsCard
                        calculateButton(proxy: proxy)

                        if let validationMessage {
                            warningCard(validationMessage)
                        }

                        if let result {
                            resultCard(result)
                                .id("resultSection")
                            detailsCard(result)
                            shareCard(result)
                        } else {
                            emptyStateCard
                        }

                        infoCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
        .onChange(of: selectedCalendar) {
            result = nil
            validationMessage = nil
            isDatePickerExpanded = true
        }
        .onChange(of: startDate) {
            result = nil
            validationMessage = nil
        }
        .onChange(of: endDate) {
            result = nil
            validationMessage = nil
        }
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("حاسبة الفرق بين تاريخين")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("احسب المدة بين تاريخين بالسنوات والأشهر والأيام.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var calendarSelector: some View {
        HStack(spacing: 10) {
            ForEach(DateDifferenceCalendarType.allCases) { calendarType in
                Button {
                    selectedCalendar = calendarType
                } label: {
                    VStack(spacing: 7) {
                        Image(systemName: calendarType.icon)
                            .font(.system(size: 20, weight: .semibold))

                        Text(calendarType.shortTitle)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundColor(selectedCalendar == calendarType ? AppTheme.buttonOrange : AppTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(selectedCalendar == calendarType ? AppTheme.buttonOrange.opacity(0.12) : cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(
                                        selectedCalendar == calendarType ? AppTheme.buttonOrange.opacity(0.35) : cardBorder,
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(selectorBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.indigo.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private var dateInputsCard: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("اختر التاريخين")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            if isDatePickerExpanded {
                compactDateSummaryRow
                datePickerBlock(title: "تاريخ البداية", icon: "play.circle.fill", selection: $startDate, tint: Color.indigo)
                datePickerBlock(title: "تاريخ النهاية", icon: "flag.checkered.circle.fill", selection: $endDate, tint: AppTheme.buttonOrange)
            } else {
                collapsedDateSummary
            }
        }
        .padding(18)
        .background(pickerCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.blue.opacity(colorScheme == .light ? 0.14 : 0.22), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private func datePickerBlock(title: String, icon: String, selection: Binding<Date>, tint: Color) -> some View {
        VStack(alignment: .center, spacing: 8) {
            VStack(alignment: .center, spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(tint)

                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(selectedCalendar.shortTitle)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(tint.opacity(colorScheme == .light ? 0.07 : 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(tint.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(colorScheme == .light ? 0.09 : 0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(tint.opacity(colorScheme == .light ? 0.18 : 0.26), lineWidth: 1)
                    )
                    .frame(height: 42)
                    .padding(.horizontal, 12)

                DatePicker("", selection: selection, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.calendar, activeCalendar)
                    .environment(\.locale, selectedCalendar.locale)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(tint.opacity(colorScheme == .light ? 0.055 : 0.10))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.18 : 0.28), lineWidth: 1)
        )
    }

    private var collapsedDateSummary: some View {
        VStack(spacing: 12) {
            compactDateSummaryRow
            
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isDatePickerExpanded = true
                    result = nil
                    validationMessage = nil
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 15, weight: .bold))
                    
                    Text("تعديل التواريخ")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(cardBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var compactDateSummaryRow: some View {
        HStack(alignment: .top, spacing: 10) {
            compactDateRow(title: "تاريخ البداية", icon: "play.circle.fill", date: startDate, tint: Color.indigo)
            compactDateRow(title: "تاريخ النهاية", icon: "flag.checkered.circle.fill", date: endDate, tint: AppTheme.buttonOrange)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func compactDateRow(title: String, icon: String, date: Date, tint: Color) -> some View {
        VStack(alignment: .center, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(tint)

            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(selectedCalendar.shortTitle)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            
            Text(formatDate(date))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.62)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(formatNumericDate(date))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(tint)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
                .frame(maxWidth: .infinity, alignment: .center)
                .environment(\.layoutDirection, .leftToRight)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .center)
        .background(tint.opacity(colorScheme == .light ? 0.065 : 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.18 : 0.28), lineWidth: 1)
        )
    }

    private func calculateButton(proxy: ScrollViewProxy) -> some View {
        Button {
            if calculateDifference() {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isDatePickerExpanded = false
                }
                
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        proxy.scrollTo("resultSection", anchor: .center)
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 17, weight: .bold))

                Text("احسب الفرق")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(AppTheme.buttonOrange)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.25 : 0.16), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private func warningCard(_ message: String) -> some View {
        HStack(spacing: 10) {
            Text(message)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.red)
        }
        .padding(15)
        .background(warningBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.red.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
    }

    private func resultCard(_ result: DateDifferenceResult) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text("الفرق بين التاريخين")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(result.mainResult)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.buttonOrange)
                .minimumScaleFactor(0.55)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("إجمالي الأيام: \(formatNumber(result.totalDays)) يوم")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 154)
        .background(resultCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private func detailsCard(_ result: DateDifferenceResult) -> some View {
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
                DateDifferenceSummaryChip(title: "التقويم المستخدم", value: selectedCalendar.title)
                DateDifferenceSummaryChip(title: "إجمالي الأيام", value: "\(formatNumber(result.totalDays)) يوم", isHighlighted: true)
                DateDifferenceSummaryChip(title: "تاريخ البداية", value: formatDate(startDate))
                DateDifferenceSummaryChip(title: "تاريخ النهاية", value: formatDate(endDate))
                DateDifferenceSummaryChip(title: "البداية رقميًا", value: formatNumericDate(startDate), forceLeftToRight: true)
                DateDifferenceSummaryChip(title: "النهاية رقميًا", value: formatNumericDate(endDate), forceLeftToRight: true)
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

    private func shareCard(_ result: DateDifferenceResult) -> some View {
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

    private var emptyStateCard: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.12 : 0.20))
                )

            Text("اختر التاريخين ثم اضغط احسب الفرق")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("ستظهر المدة بالسنوات والأشهر والأيام مع إجمالي الأيام.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(18)
        .background(detailsCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }

    private var infoCard: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.green)

            Text("معلومة")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("تساعدك هذه الحاسبة على معرفة الفرق بين تاريخين بالسنوات والأشهر والأيام، مع إمكانية استخدام التقويم الميلادي أو الهجري أم القرى.")
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
                .stroke(Color.green.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
    }

    @discardableResult
    private func calculateDifference() -> Bool {
        validationMessage = nil
        result = nil

        let start = activeCalendar.startOfDay(for: startDate)
        let end = activeCalendar.startOfDay(for: endDate)

        guard end >= start else {
            validationMessage = "تاريخ النهاية يجب أن يكون بعد تاريخ البداية"
            isDatePickerExpanded = true
            return false
        }

        let components = activeCalendar.dateComponents([.year, .month, .day], from: start, to: end)
        let totalDays = activeCalendar.dateComponents([.day], from: start, to: end).day ?? 0

        result = DateDifferenceResult(
            years: max(components.year ?? 0, 0),
            months: max(components.month ?? 0, 0),
            days: max(components.day ?? 0, 0),
            totalDays: max(totalDays, 0)
        )
        
        return true
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = activeCalendar
        formatter.locale = selectedCalendar.locale
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    private func formatNumericDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = activeCalendar
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func shareText(for result: DateDifferenceResult) -> String {
        """
        حاسبة الفرق بين تاريخين - احسبها

        التقويم المستخدم:
        \(selectedCalendar.title)

        تاريخ البداية:
        \(formatDate(startDate))
        \(formatNumericDate(startDate))

        تاريخ النهاية:
        \(formatDate(endDate))
        \(formatNumericDate(endDate))

        النتيجة:
        \(result.mainResult)

        إجمالي الأيام:
        \(formatNumber(result.totalDays)) يوم
        """
    }

    @MainActor
    private func resultCardImage(for result: DateDifferenceResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة الفرق بين تاريخين",
            rows: [
                ResultCardRow(title: "التقويم المستخدم", value: selectedCalendar.title),
                ResultCardRow(title: "تاريخ البداية", value: formatDate(startDate)),
                ResultCardRow(title: "تاريخ النهاية", value: formatDate(endDate)),
                ResultCardRow(title: "النتيجة", value: result.mainResult, valueColor: AppTheme.buttonOrange),
                ResultCardRow(title: "إجمالي الأيام", value: "\(formatNumber(result.totalDays)) يوم")
            ],
            note: "النتيجة حسب التقويم المختار."
        )
    }
}

private enum DateDifferenceCalendarType: String, CaseIterable, Identifiable {
    case gregorian
    case hijri

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gregorian:
            return "التقويم الميلادي"
        case .hijri:
            return "التقويم الهجري أم القرى"
        }
    }

    var shortTitle: String {
        switch self {
        case .gregorian:
            return "ميلادي"
        case .hijri:
            return "هجري أم القرى"
        }
    }

    var icon: String {
        switch self {
        case .gregorian:
            return "calendar"
        case .hijri:
            return "moon.stars.fill"
        }
    }

    var calendar: Calendar {
        switch self {
        case .gregorian:
            return Calendar(identifier: .gregorian)
        case .hijri:
            return Calendar(identifier: .islamicUmmAlQura)
        }
    }

    var locale: Locale {
        switch self {
        case .gregorian:
            return Locale(identifier: "ar")
        case .hijri:
            return Locale(identifier: "ar_SA")
        }
    }
}

private struct DateDifferenceResult {
    let years: Int
    let months: Int
    let days: Int
    let totalDays: Int

    var mainResult: String {
        "\(formatted(years)) سنة، \(formatted(months)) أشهر، \(formatted(days)) يوم"
    }

    private func formatted(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

private struct DateDifferenceSummaryChip: View {
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
        DateDifferenceCalculatorView()
    }
}
