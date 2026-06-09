import SwiftUI
import UIKit

struct SaudiRetirementCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: Field?

    @State private var birthDate: Date = Calendar(identifier: .gregorian).date(byAdding: .year, value: -35, to: Date()) ?? Date()
    @State private var contributionYears = "10"
    @State private var contributionMonths = "0"
    @State private var averageSalary = ""
    @State private var selectedSystem: SaudiRetirementSystem = .gosi
    @State private var employmentStatus: SaudiEmploymentStatus = .active
    @State private var result: SaudiRetirementResult?

    private enum Field {
        case years
        case months
        case salary
    }

    private let gregorianCalendar = Calendar(identifier: .gregorian)

    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }

    private var cardBackground: Color {
        colorScheme == .light ? Color(hex: "#FBFCFF") : AppTheme.secondaryBackground
    }

    private var inputCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F4F9FF") : AppTheme.secondaryBackground
    }

    private var resultCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F5FF") : AppTheme.secondaryBackground
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
        colorScheme == .light ? Color.black.opacity(0.07) : .clear
    }

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    headerSection
                    inputSection
                    calculateButton

                    if let result {
                        resultCard(result)
                        quickSummarySection(result)
                        progressSection(result)
                        detailsCard(result)
                        shareSection(result)
                    } else {
                        emptyStateCard
                    }

                    officialNoteCard
                    conditionsNoteCard
                    professionalDisclaimer
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
        .onChange(of: birthDate) { clearResult() }
        .onChange(of: contributionYears) { clearResult() }
        .onChange(of: contributionMonths) { clearResult() }
        .onChange(of: averageSalary) { clearResult() }
        .onChange(of: selectedSystem) { clearResult() }
        .onChange(of: employmentStatus) { clearResult() }
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "person.crop.circle.badge.clock")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.indigo)
                .frame(width: 58, height: 58)
                .background(Color.indigo.opacity(colorScheme == .light ? 0.10 : 0.18))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text("حاسبة التقاعد التقديرية")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("تقدير الأهلية للتقاعد والراتب التقاعدي وفق البيانات المدخلة")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("بيانات التقاعد")
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)

            dateInput
            contributionInputRow
            salaryInput
            segmentedPicker(title: "نوع النظام", selection: $selectedSystem, options: SaudiRetirementSystem.allCases)
            segmentedPicker(title: "حالة العمل", selection: $employmentStatus, options: SaudiEmploymentStatus.allCases)
        }
        .padding(18)
        .background(inputCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.indigo.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private var dateInput: some View {
        VStack(alignment: .center, spacing: 8) {
            inputTitle("تاريخ الميلاد", icon: "calendar", tint: Color.indigo)

            DatePicker("", selection: $birthDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .environment(\.calendar, gregorianCalendar)
                .environment(\.locale, Locale(identifier: "ar_SA"))
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(innerInputBackground(Color.indigo))
        }
    }

    private var contributionInputRow: some View {
        HStack(spacing: 10) {
            numericInput(title: "سنوات الاشتراك", placeholder: "10", value: $contributionYears, field: .years, tint: Color.teal)
            numericInput(title: "أشهر إضافية", placeholder: "0", value: $contributionMonths, field: .months, tint: Color.teal)
        }
    }

    private var salaryInput: some View {
        numericInput(
            title: "متوسط الراتب الخاضع للاشتراك",
            placeholder: "اختياري",
            value: $averageSalary,
            field: .salary,
            tint: AppTheme.buttonOrange,
            suffix: "ر.س"
        )
    }

    private func numericInput(
        title: String,
        placeholder: String,
        value: Binding<String>,
        field: Field,
        tint: Color,
        suffix: String? = nil
    ) -> some View {
        VStack(alignment: .center, spacing: 8) {
            inputTitle(title, icon: "number", tint: tint)

            HStack(spacing: 6) {
                TextField(placeholder, text: value)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: field)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .tint(AppTheme.buttonOrange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                if let suffix {
                    Text(suffix)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(tint)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(innerInputBackground(tint))
        }
    }

    private func segmentedPicker<T: SaudiRetirementSegmentOption>(
        title: String,
        selection: Binding<T>,
        options: [T]
    ) -> some View {
        VStack(alignment: .center, spacing: 8) {
            inputTitle(title, icon: "slider.horizontal.3", tint: Color.indigo)

            HStack(spacing: 8) {
                ForEach(options) { option in
                    Button {
                        selection.wrappedValue = option
                    } label: {
                        Text(option.title)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(selection.wrappedValue.id == option.id ? .black : AppTheme.primaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.70)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .fill(selection.wrappedValue.id == option.id ? AppTheme.buttonOrange : AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.08 : 0.14))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .stroke(AppTheme.buttonOrange.opacity(selection.wrappedValue.id == option.id ? 0.30 : 0.14), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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

    private func innerInputBackground(_ tint: Color) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(colorScheme == .light ? Color.white.opacity(0.80) : AppTheme.inputBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(tint.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
            )
    }

    private var calculateButton: some View {
        Button {
            focusedField = nil
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            result = calculateResult()
        } label: {
            Text("احسب التقدير")
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

    private func resultCard(_ result: SaudiRetirementResult) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text(earlyRetirementResultTitle(for: result))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(result.status.color)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(earlyRetirementMainValue(for: result))
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.buttonOrange)
                .lineLimit(2)
                .minimumScaleFactor(0.52)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(earlyRetirementSubtitle(for: result))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .background(resultCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(result.status.color.opacity(colorScheme == .light ? 0.18 : 0.26), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func quickSummarySection(_ result: SaudiRetirementResult) -> some View {
        HStack(spacing: 10) {
            quickSummaryCard(
                label: "التقاعد المبكر",
                value: result.isEarlyEligible ? "متاح الآن" : "غير متاح",
                tint: result.isEarlyEligible ? .green : AppTheme.buttonOrange
            )

            quickSummaryCard(
                label: "المتبقي للنظامي",
                value: result.standardRemainingText,
                tint: result.isStandardEligible ? .green : Color.indigo
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func quickSummaryCard(label: String, value: String, tint: Color) -> some View {
        VStack(alignment: .center, spacing: 7) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(value)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundColor(tint)
                .lineLimit(2)
                .minimumScaleFactor(0.58)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .center)
        .background(tint.opacity(colorScheme == .light ? 0.075 : 0.14))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 8, x: 0, y: 4)
    }

    private func progressSection(_ result: SaudiRetirementResult) -> some View {
        VStack(alignment: .center, spacing: 12) {
            Text("مؤشرات التقدم")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)

            progressCard(title: "التقاعد النظامي", value: result.standardProgress, detail: result.standardRemainingText)
            progressCard(title: "التقاعد المبكر", value: result.earlyProgress, detail: result.earlyRemainingText)
            progressCard(title: "مدة الاشتراك", value: result.subscriptionProgress, detail: result.subscriptionProgress >= 1 ? "مكتملة" : "\(formatNumber(result.subscriptionProgress * 100))% من المرجع الإرشادي")
            if requiresLeavingWorkForEarlyRetirement(result) {
                progressCard(title: "شرط ترك العمل", value: 0, detail: "غير مكتمل", statusOverride: "غير مكتمل")
            }
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 9, x: 0, y: 4)
    }

    private func progressCard(title: String, value: Double, detail: String, statusOverride: String? = nil) -> some View {
        let tint = progressTint(value)
        let statusText = statusOverride ?? progressStatusText(title: title, value: value)

        return VStack(alignment: .center, spacing: 8) {
            HStack(spacing: 8) {
                Text(statusText)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer()

                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
            }
            .environment(\.layoutDirection, .leftToRight)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(tint.opacity(colorScheme == .light ? 0.12 : 0.18))

                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(tint)
                        .frame(width: geometry.size.width * min(max(value, 0), 1))
                }
            }
            .frame(height: 10)

            Text(detail)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(13)
        .background(tint.opacity(colorScheme == .light ? 0.065 : 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
    }

    private func detailsCard(_ result: SaudiRetirementResult) -> some View {
        VStack(alignment: .center, spacing: 14) {
            Text("تفاصيل التقدير")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                SaudiRetirementSummaryChip(title: "العمر الحالي", value: result.ageText)
                SaudiRetirementSummaryChip(title: "مدة الاشتراك", value: result.subscriptionProgress >= 1 ? "مكتملة" : result.contributionText, isHighlighted: result.subscriptionProgress >= 1)
                SaudiRetirementSummaryChip(title: "العمر عند التقاعد النظامي", value: "60 سنة")
                SaudiRetirementSummaryChip(title: "التقاعد المبكر", value: earlyRetirementDetailText(for: result), isHighlighted: result.isEarlyEligible)
                SaudiRetirementSummaryChip(title: "النظام المختار", value: result.system.title)
                if requiresLeavingWorkForEarlyRetirement(result) {
                    SaudiRetirementSummaryChip(title: "شرط ترك العمل", value: "غير مكتمل")
                }
                if let pensionText = result.estimatedPensionText {
                    SaudiRetirementSummaryChip(title: "راتب تقاعدي تقديري", value: pensionText, isHighlighted: true)
                }
            }
        }
        .padding(18)
        .background(detailsCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func shareSection(_ result: SaudiRetirementResult) -> some View {
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
            Image(systemName: "person.crop.circle.badge.clock")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(Color.indigo)
                .frame(width: 58, height: 58)
                .background(Color.indigo.opacity(colorScheme == .light ? 0.12 : 0.20))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text("جاهز لحساب التقدير")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)

            Text("أدخل تاريخ الميلاد ومدة الاشتراك لعرض حالة التقاعد التقديرية.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(detailsCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }

    private var officialNoteCard: some View {
        noteCard(
            title: "تنبيه مهم",
            text: "هذه الحاسبة تقديرية ولا تعد بديلاً عن الحساب الرسمي لدى المؤسسة العامة للتأمينات الاجتماعية أو الجهة المختصة.",
            tint: AppTheme.buttonOrange
        )
    }

    private var conditionsNoteCard: some View {
        noteCard(
            title: "معلومة",
            text: "قد تختلف الشروط حسب النظام، تاريخ الميلاد، مدة الاشتراك، وطبيعة الخدمة. قد توجد تعديلات تدريجية في سن التقاعد النظامي حسب الأنظمة الرسمية.",
            tint: Color.indigo
        )
    }

    private var professionalDisclaimer: some View {
        Text("النتائج تقديرية لأغراض التوعية فقط ولا تمثل استحقاقاً رسمياً، ويُرجع للأنظمة والجهات المختصة للتحقق النهائي.")
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(AppTheme.secondaryText)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 8)
    }

    private func noteCard(title: String, text: String, tint: Color) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)

            Text(text)
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
                .stroke(tint.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
    }

    private func calculateResult() -> SaudiRetirementResult {
        let ageComponents = gregorianCalendar.dateComponents([.year, .month], from: birthDate, to: Date())
        let ageYears = max(ageComponents.year ?? 0, 0)
        let ageMonths = max(ageComponents.month ?? 0, 0)
        let contributionMonthsValue = max(parseInt(contributionYears) * 12 + parseInt(contributionMonths), 0)
        let contributionYearsValue = contributionMonthsValue / 12
        let remainingContributionMonths = contributionMonthsValue % 12
        let salaryValue = parseDouble(averageSalary)

        let standardAgeMonths = 60 * 12
        let currentAgeMonths = ageYears * 12 + ageMonths
        let remainingAgeMonths = max(standardAgeMonths - currentAgeMonths, 0)
        let remainingStandardContribution = max(120 - contributionMonthsValue, 0)
        let standardRemaining = max(remainingAgeMonths, remainingStandardContribution)

        let remainingEarlyContribution = max(300 - contributionMonthsValue, 0)
        let gosiEarlyRequiresLeavingWork = selectedSystem == .gosi && employmentStatus == .active
        let earlyRemaining = gosiEarlyRequiresLeavingWork ? remainingEarlyContribution : remainingEarlyContribution

        let isStandardEligible = currentAgeMonths >= standardAgeMonths && contributionMonthsValue >= 120
        let isEarlyEligible: Bool
        switch selectedSystem {
        case .gosi:
            isEarlyEligible = contributionMonthsValue >= 300 && employmentStatus == .leftWork
        case .civil, .military:
            isEarlyEligible = contributionMonthsValue >= 300
        }

        let status: SaudiRetirementStatus
        let mainValue: String
        if isStandardEligible {
            status = .standardEligible
            mainValue = "مؤهل الآن"
        } else if isEarlyEligible {
            status = .earlyEligible
            mainValue = "مؤهل مبكرًا"
        } else if selectedSystem != .gosi {
            status = .reviewOfficial
            mainValue = "راجع الشروط الرسمية"
        } else {
            status = .notEligible
            mainValue = "متبقي \(formatDuration(standardRemaining))"
        }

        let estimatedPensionText: String?
        if let salaryValue, salaryValue > 0 {
            let pension = salaryValue * min(Double(contributionMonthsValue) / 480.0, 1.0)
            estimatedPensionText = "\(formatCurrency(pension)) ر.س"
        } else {
            estimatedPensionText = nil
        }

        return SaudiRetirementResult(
            status: status,
            mainValue: mainValue,
            system: selectedSystem,
            employmentStatus: employmentStatus,
            ageYears: ageYears,
            ageMonths: ageMonths,
            contributionMonths: contributionMonthsValue,
            contributionText: "\(contributionYearsValue) سنة و \(remainingContributionMonths) شهر",
            ageText: "\(ageYears) سنة و \(ageMonths) شهر",
            standardRemainingText: isStandardEligible ? "مؤهل الآن" : formatDuration(standardRemaining),
            earlyRemainingText: earlyEligibilityText(isEligible: isEarlyEligible, remainingMonths: earlyRemaining, gosiRequiresLeavingWork: gosiEarlyRequiresLeavingWork),
            isStandardEligible: isStandardEligible,
            isEarlyEligible: isEarlyEligible,
            standardProgress: min(min(Double(currentAgeMonths) / Double(standardAgeMonths), Double(contributionMonthsValue) / 120.0), 1.0),
            earlyProgress: min(Double(contributionMonthsValue) / 300.0, 1.0),
            subscriptionProgress: min(Double(contributionMonthsValue) / 300.0, 1.0),
            estimatedPensionText: estimatedPensionText
        )
    }

    private func earlyEligibilityText(isEligible: Bool, remainingMonths: Int, gosiRequiresLeavingWork: Bool) -> String {
        if isEligible {
            return "مؤهل الآن"
        }

        if gosiRequiresLeavingWork && remainingMonths == 0 {
            return "يتطلب ترك العمل"
        }

        return formatDuration(remainingMonths)
    }

    private func clearResult() {
        result = nil
    }

    private func requiresLeavingWorkForEarlyRetirement(_ result: SaudiRetirementResult) -> Bool {
        result.system == .gosi && result.employmentStatus == .active && result.contributionMonths >= 300 && !result.isEarlyEligible
    }

    private func earlyRetirementResultTitle(for result: SaudiRetirementResult) -> String {
        if result.isEarlyEligible {
            return "مؤهل للتقاعد المبكر"
        }

        if requiresLeavingWorkForEarlyRetirement(result) {
            return "غير مؤهل للتقاعد المبكر حالياً"
        }

        return "غير مؤهل للتقاعد المبكر"
    }

    private func earlyRetirementMainValue(for result: SaudiRetirementResult) -> String {
        if result.isEarlyEligible {
            return "متاح الآن"
        }

        if requiresLeavingWorkForEarlyRetirement(result) {
            return "شرط ترك العمل غير مكتمل"
        }

        return result.earlyRemainingText
    }

    private func earlyRetirementSubtitle(for result: SaudiRetirementResult) -> String {
        if result.isEarlyEligible {
            return "يمكنك التقدم بطلب التقاعد المبكر حسب البيانات المدخلة"
        }

        if requiresLeavingWorkForEarlyRetirement(result) {
            return "مدة الاشتراك مكتملة، لكن التقاعد المبكر يتطلب ترك العمل حسب البيانات المدخلة."
        }

        return "ما زالت هناك متطلبات أو مدة متبقية للوصول للأهلية"
    }

    private func earlyRetirementDetailText(for result: SaudiRetirementResult) -> String {
        requiresLeavingWorkForEarlyRetirement(result) ? "غير مؤهل حالياً" : result.earlyRemainingText
    }

    private func parseInt(_ text: String) -> Int {
        Int(parseDouble(text) ?? 0)
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

    private func formatDuration(_ months: Int) -> String {
        let years = max(months, 0) / 12
        let remainingMonths = max(months, 0) % 12
        if years == 0 {
            return "\(remainingMonths) شهر"
        }
        if remainingMonths == 0 {
            return "\(years) سنة"
        }
        return "\(years) سنة و \(remainingMonths) شهر"
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func progressTint(_ value: Double) -> Color {
        if value >= 1 {
            return .green
        } else if value >= 0.75 {
            return AppTheme.buttonOrange
        } else {
            return .blue
        }
    }

    private func progressStatusText(title: String, value: Double) -> String {
        if value >= 1 {
            return title == "مدة الاشتراك" ? "مكتمل" : "محقق"
        }

        let remainingPercent = max(0, 100 - (value * 100))
        return "متبقي \(formatNumber(remainingPercent))%"
    }

    private func shareText(for result: SaudiRetirementResult) -> String {
        """
        حاسبة التقاعد التقديرية - احسبها

        الحالة:
        \(result.status.title)

        النتيجة:
        \(result.mainValue)

        العمر الحالي:
        \(result.ageText)

        مدة الاشتراك:
        \(result.contributionText)

        النظام المختار:
        \(result.system.title)

        التقاعد النظامي:
        \(result.standardRemainingText)

        التقاعد المبكر:
        \(result.earlyRemainingText)

        \(result.estimatedPensionText.map { "راتب تقاعدي تقديري:\n\($0) ر.س" } ?? "")

        هذه النتيجة تقديرية وليست استحقاقًا رسميًا.
        """
    }

    @MainActor
    private func resultCardImage(for result: SaudiRetirementResult) -> UIImage? {
        var rows: [ResultCardRow] = [
            ResultCardRow(title: "الحالة", value: result.status.title),
            ResultCardRow(title: "النتيجة", value: result.mainValue, valueColor: AppTheme.buttonOrange),
            ResultCardRow(title: "العمر الحالي", value: result.ageText),
            ResultCardRow(title: "مدة الاشتراك", value: result.contributionText),
            ResultCardRow(title: "التقاعد النظامي", value: result.standardRemainingText),
            ResultCardRow(title: "التقاعد المبكر", value: result.earlyRemainingText),
            ResultCardRow(title: "النظام", value: result.system.title)
        ]

        if let pensionText = result.estimatedPensionText {
            rows.append(ResultCardRow(title: "راتب تقاعدي تقديري", value: "\(pensionText) ر.س"))
        }

        return ResultCardRenderer.render(
            title: "حاسبة التقاعد التقديرية",
            rows: rows,
            note: "تقدير إرشادي وليس استحقاقًا رسميًا."
        )
    }
}

private protocol SaudiRetirementSegmentOption: Identifiable, Hashable {
    var title: String { get }
}

private enum SaudiRetirementSystem: String, CaseIterable, SaudiRetirementSegmentOption {
    case gosi
    case civil
    case military

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gosi: return "التأمينات"
        case .civil: return "مدني"
        case .military: return "عسكري"
        }
    }
}

private enum SaudiEmploymentStatus: String, CaseIterable, SaudiRetirementSegmentOption {
    case active
    case leftWork

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active: return "على رأس العمل"
        case .leftWork: return "ترك العمل"
        }
    }
}

private enum SaudiRetirementStatus {
    case standardEligible
    case earlyEligible
    case notEligible
    case reviewOfficial

    var title: String {
        switch self {
        case .standardEligible: return "مؤهل للتقاعد النظامي"
        case .earlyEligible: return "مؤهل للتقاعد المبكر"
        case .notEligible: return "غير مؤهل بعد"
        case .reviewOfficial: return "يحتاج مراجعة الشروط الرسمية"
        }
    }

    var color: Color {
        switch self {
        case .standardEligible, .earlyEligible: return .green
        case .notEligible: return AppTheme.buttonOrange
        case .reviewOfficial: return .blue
        }
    }
}

private struct SaudiRetirementResult {
    let status: SaudiRetirementStatus
    let mainValue: String
    let system: SaudiRetirementSystem
    let employmentStatus: SaudiEmploymentStatus
    let ageYears: Int
    let ageMonths: Int
    let contributionMonths: Int
    let contributionText: String
    let ageText: String
    let standardRemainingText: String
    let earlyRemainingText: String
    let isStandardEligible: Bool
    let isEarlyEligible: Bool
    let standardProgress: Double
    let earlyProgress: Double
    let subscriptionProgress: Double
    let estimatedPensionText: String?
}

private struct SaudiRetirementSummaryChip: View {
    let title: String
    let value: String
    var isHighlighted = false

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
        SaudiRetirementCalculatorView()
    }
}
