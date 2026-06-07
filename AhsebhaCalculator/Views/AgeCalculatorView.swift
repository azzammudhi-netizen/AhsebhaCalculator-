import SwiftUI
import UIKit

struct AgeCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedCalendar: AgeCalendarType = .gregorian

    @State private var gregorianBirthDate: Date = Calendar.current.date(
        byAdding: .year,
        value: -20,
        to: Date()
    ) ?? Date()

    @State private var hijriBirthDate: Date = Calendar(identifier: .islamicUmmAlQura).date(
        byAdding: .year,
        value: -20,
        to: Date()
    ) ?? Date()

    private var selectedBirthDate: Date {
        selectedCalendar == .gregorian ? gregorianBirthDate : hijriBirthDate
    }

    private var calculationCalendar: Calendar {
        selectedCalendar == .gregorian
        ? Calendar(identifier: .gregorian)
        : Calendar(identifier: .islamicUmmAlQura)
    }

    private var ageComponents: DateComponents {
        calculationCalendar.dateComponents(
            [.year, .month, .day],
            from: selectedBirthDate,
            to: Date()
        )
    }

    private var totalDays: Int {
        Calendar(identifier: .gregorian).dateComponents(
            [.day],
            from: selectedBirthDate,
            to: Date()
        ).day ?? 0
    }

    private var totalMonths: Int {
        calculationCalendar.dateComponents(
            [.month],
            from: selectedBirthDate,
            to: Date()
        ).month ?? 0
    }

    private var totalHours: Int {
        totalDays * 24
    }

    private var yearsText: String {
        "\(ageComponents.year ?? 0) سنة"
    }

    private var remainingAgeText: String {
        "\(ageComponents.month ?? 0) شهر • \(ageComponents.day ?? 0) يوم"
    }

    private var mainAgeText: String {
        let years = ageComponents.year ?? 0
        let months = ageComponents.month ?? 0
        let days = ageComponents.day ?? 0

        return "\(years) سنة، \(months) شهر، \(days) يوم"
    }

    private var result: AgeCalculationResult {
        AgeCalculationResult(
            birthDate: formatDate(selectedBirthDate),
            years: ageComponents.year ?? 0,
            totalMonths: totalMonths,
            totalDays: totalDays,
            fullAge: mainAgeText,
            calendarType: selectedCalendar
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

    private var inputBackground: Color {
        colorScheme == .light ? Color(hex: "#FBFCFE") : AppTheme.inputBackground
    }

    private var detailBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFC") : AppTheme.inputBackground
    }

    private var infoCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF7ED") : AppTheme.secondaryBackground
    }

    private var infoCardBorder: Color {
        colorScheme == .light ? AppTheme.buttonOrange.opacity(0.18) : AppTheme.border
    }

    private func shareText(for result: AgeCalculationResult) -> String {
        """
        حاسبة العمر - احسبها

        تاريخ الميلاد:
        \(result.birthDate)

        العمر:
        \(result.fullAge)

        بالأشهر تقريبًا:
        \(formattedInteger(result.totalMonths)) شهر

        بالأيام تقريبًا:
        \(formattedInteger(result.totalDays)) يوم

        نوع التقويم:
        \(result.calendarType.title)
        """
    }

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    headerSection
                    calendarSelector
                    datePickerCard
                    resultCard
                    detailsCard
                    shareCard
                    infoCard
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
            Text("حاسبة العمر")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("اختر نوع التاريخ ثم أدخل تاريخ الميلاد لحساب العمر.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var calendarSelector: some View {
        HStack(spacing: 10) {
            ForEach(AgeCalendarType.allCases) { type in
                Button {
                    selectedCalendar = type
                } label: {
                    VStack(spacing: 7) {
                        Image(systemName: type.icon)
                            .font(.system(size: 21, weight: .semibold))

                        Text(type.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundColor(selectedCalendar == type ? AppTheme.buttonOrange : AppTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(selectedCalendar == type ? AppTheme.buttonOrange.opacity(0.12) : cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(
                                        selectedCalendar == type ? AppTheme.buttonOrange.opacity(0.35) : cardBorder,
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private var datePickerCard: some View {
        VStack(alignment: .center, spacing: 14) {
            Text(selectedCalendar.datePickerTitle)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(inputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(cardBorder, lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.12 : 0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.24 : 0.32), lineWidth: 1)
                    )
                    .frame(height: 44)
                    .padding(.horizontal, 12)

                if selectedCalendar == .gregorian {
                    DatePicker(
                        "",
                        selection: $gregorianBirthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.calendar, Calendar(identifier: .gregorian))
                    .environment(\.locale, Locale(identifier: "ar"))
                } else {
                    DatePicker(
                        "",
                        selection: $hijriBirthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.calendar, Calendar(identifier: .islamicUmmAlQura))
                    .environment(\.locale, Locale(identifier: "ar_SA"))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 174)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text(selectedCalendar.helperText)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
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
            Text("عمرك الآن")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(yearsText)
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.buttonOrange)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(remainingAgeText)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("تم الحساب باستخدام التقويم \(selectedCalendar.title) حسب الاختيار.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 10 : 0, x: 0, y: colorScheme == .light ? 5 : 0)
    }

    private var detailsCard: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("تفاصيل العمر")
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
                AgeDetailChip(title: "بالسنوات", value: "\(formattedInteger(ageComponents.year ?? 0)) سنة")
                AgeDetailChip(title: "بالأشهر تقريبًا", value: "\(formattedInteger(totalMonths)) شهر")
                AgeDetailChip(title: "بالأيام تقريبًا", value: "\(formattedInteger(totalDays)) يوم")
                AgeDetailChip(title: "بالساعات تقريبًا", value: "\(formattedInteger(totalHours)) ساعة")
                AgeDetailChip(title: "نوع التقويم", value: selectedCalendar.title)
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

    private var infoCard: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("معلومة")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("يتم حساب العمر بناءً على التاريخ المدخل وحتى تاريخ اليوم.")
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

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.calendar = calculationCalendar
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formattedInteger(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    @MainActor
    private func resultCardImage(for result: AgeCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة العمر",
            rows: [
                ResultCardRow(title: "تاريخ الميلاد", value: result.birthDate),
                ResultCardRow(title: "العمر بالسنوات", value: "\(formattedInteger(result.years)) سنة"),
                ResultCardRow(title: "الأشهر", value: "\(formattedInteger(result.totalMonths)) شهر"),
                ResultCardRow(title: "الأيام", value: "\(formattedInteger(result.totalDays)) يوم"),
                ResultCardRow(title: "العمر الكامل", value: result.fullAge, valueColor: AppTheme.buttonOrange)
            ],
            note: "النتائج تقديرية حسب التاريخ المدخل."
        )
    }
}

private struct AgeCalculationResult {
    let birthDate: String
    let years: Int
    let totalMonths: Int
    let totalDays: Int
    let fullAge: String
    let calendarType: AgeCalendarType
}

enum AgeCalendarType: String, CaseIterable, Identifiable {
    case gregorian
    case ummAlQura

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gregorian:
            return "ميلادي"
        case .ummAlQura:
            return "هجري أم القرى"
        }
    }

    var icon: String {
        switch self {
        case .gregorian:
            return "calendar"
        case .ummAlQura:
            return "moon.stars.fill"
        }
    }

    var color: Color {
        switch self {
        case .gregorian:
            return Color.cyan
        case .ummAlQura:
            return Color.green
        }
    }

    var datePickerTitle: String {
        switch self {
        case .gregorian:
            return "تاريخ الميلاد الميلادي"
        case .ummAlQura:
            return "تاريخ الميلاد الهجري"
        }
    }

    var helperText: String {
        switch self {
        case .gregorian:
            return "اختر تاريخ الميلاد بالتقويم الميلادي."
        case .ummAlQura:
            return "اختر تاريخ الميلاد حسب تقويم أم القرى."
        }
    }
}

private struct AgeDetailChip: View {
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
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 68, alignment: .center)
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
        AgeCalculatorView()
    }
}
