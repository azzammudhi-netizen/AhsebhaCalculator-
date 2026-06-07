import SwiftUI
import Foundation
import UIKit

struct PersonalLoanCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var loanAmount: String = ""
    @State private var annualProfitRate: String = ""
    @State private var years: String = ""
    
    private var result: LoanCalculationResult? {
        calculateLoan()
    }
    
    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .trailing, spacing: 22) {
                    headerSection
                    inputSection
                    
                    if let result {
                        resultSection(result)
                        insightSection(result)
                        ShareResultButton(
                            text: shareText(for: result),
                            sharedImage: resultCardImage(for: result)
                        )
                    } else {
                        emptyStateSection
                    }
                    
                    descriptionSection
                    warningSection
                    explanationSection
                }
                .padding(20)
                .padding(.bottom, 80)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            Spacer(minLength: 0)
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("حاسبة التمويل الشخصي")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.green.opacity(0.22))
                    .frame(width: 78, height: 78)
                
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(AppTheme.primaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private var inputSection: some View {
        sectionCard(icon: "doc.text.fill", iconColor: AppTheme.buttonOrange) {
            VStack(alignment: .trailing, spacing: 16) {
                Text("أدخل بيانات التمويل")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                calculatorInput(
                    title: "مبلغ القرض",
                    placeholder: "مثال: ٥٠٣٠٠",
                    value: $loanAmount,
                    suffix: "ر.س",
                    icon: "banknote.fill"
                )
                
                calculatorInput(
                    title: "نسبة الأرباح السنوية",
                    placeholder: "مثال: ٣",
                    value: $annualProfitRate,
                    suffix: "%",
                    icon: "percent"
                )
                
                calculatorInput(
                    title: "مدة السداد بالسنوات",
                    placeholder: "مثال: ٥",
                    value: $years,
                    suffix: "سنة",
                    icon: "calendar"
                )
                
                Button {
                    clearInputs()
                } label: {
                    HStack(spacing: 10) {
                        Spacer()
                        Text("مسح")
                        Image(systemName: "trash")
                        Spacer()
                    }
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(clearButtonBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.red.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text("وصف الحاسبة")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("احسب القسط الشهري بناءً على مبلغ القرض، نسبة الأرباح السنوية، ومدة السداد. تساعدك هذه الحاسبة على تقدير إجمالي الأرباح وإجمالي المبلغ المطلوب سداده قبل اتخاذ قرار التمويل.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(cardBorder, lineWidth: 1)
                )
        )
        .shadow(color: cardShadow, radius: cardShadowRadius, x: 0, y: cardShadowY)
    }
    
    private func calculatorInput(
        title: String,
        placeholder: String,
        value: Binding<String>,
        suffix: String,
        icon: String
    ) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            HStack(spacing: 10) {
                Text(suffix)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.buttonOrange)
                    .frame(width: 44, alignment: .center)
                
                HStack(spacing: 10) {
                    TextField(
                        text: value,
                        prompt: Text(placeholder)
                            .foregroundColor(AppTheme.secondaryText.opacity(colorScheme == .light ? 0.72 : 0.62))
                    ) {
                        Text(placeholder)
                    }
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .tint(AppTheme.buttonOrange)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.buttonOrange)
                        .frame(width: 42, height: 42)
                        .background(iconBadgeBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 12)
                .frame(height: 54)
                .background(inputFieldBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(inputFieldBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }
    
    private func resultSection(_ result: LoanCalculationResult) -> some View {
        sectionCard(icon: "chart.bar.xaxis", iconColor: .green) {
            VStack(alignment: .trailing, spacing: 16) {
                Text("النتيجة")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                mainResultCard(
                    title: "القسط الشهري",
                    value: formatCurrency(result.monthlyPayment)
                )
                
                VStack(spacing: 0) {
                    resultLine(title: "مبلغ القرض", value: formatCurrency(result.loanAmount))
                    dividerLine
                    resultLine(title: "نسبة الأرباح السنوية", value: "\(formatNumber(result.annualProfitRate))%")
                    dividerLine
                    resultLine(title: "مبلغ الأرباح", value: formatCurrency(result.profitAmount))
                    dividerLine
                    resultLine(title: "إجمالي المطلوب سداده", value: formatCurrency(result.totalRequired))
                    dividerLine
                    resultLine(title: "مدة السداد", value: "\(result.months) شهر")
                }
                .background(innerCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(innerCardBorder, lineWidth: 1)
                )
            }
        }
    }
    

    private func insightSection(_ result: LoanCalculationResult) -> some View {
        let profitPercentage = result.loanAmount > 0 ? (result.profitAmount / result.loanAmount) * 100 : 0
        let monthlyToLoanPercentage = result.loanAmount > 0 ? (result.monthlyPayment / result.loanAmount) * 100 : 0

        let level: PersonalLoanInsightLevel
        let summary: String

        if profitPercentage <= 10 {
            level = .excellent
            summary = "تكلفة التمويل منخفضة نسبيًا مقارنة بمبلغ القرض، وهذا يعطي انطباعًا جيدًا عن إجمالي تكلفة التمويل."
        } else if profitPercentage <= 20 {
            level = .good
            summary = "تكلفة التمويل ضمن نطاق جيد ومقبول غالبًا، مع أهمية مقارنة العروض قبل اتخاذ القرار."
        } else if profitPercentage <= 35 {
            level = .attention
            summary = "تكلفة التمويل تحتاج مراجعة، خصوصًا إذا كانت مدة السداد طويلة أو توجد التزامات شهرية أخرى."
        } else {
            level = .high
            summary = "تكلفة التمويل مرتفعة نسبيًا، ويُفضّل مراجعة مدة السداد أو نسبة الأرباح أو مقارنة عروض تمويلية أخرى."
        }

        return sectionCard(icon: "sparkles", iconColor: level.color) {
            VStack(alignment: .trailing, spacing: 16) {
                HStack(spacing: 10) {
                    Text(level.badgeTitle)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(level.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(level.color.opacity(0.15))
                        .clipShape(Capsule())
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Text("تحليل النتيجة")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .multilineTextAlignment(.trailing)
                }
                .environment(\.layoutDirection, .leftToRight)

                scoreIndicatorCard(
                    title: "مؤشر التمويل",
                    level: level,
                    score: level.score,
                    detail: level.detailText
                )

                Text(summary)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                VStack(spacing: 10) {
                    insightRow(
                        icon: "percent",
                        title: "نسبة الأرباح إلى مبلغ القرض",
                        value: "\(formatNumber(profitPercentage))%",
                        color: level.color
                    )

                    insightRow(
                        icon: "calendar",
                        title: "مدة السداد",
                        value: "\(result.months) شهر",
                        color: AppTheme.buttonOrange
                    )

                    insightRow(
                        icon: "creditcard.fill",
                        title: "القسط مقابل مبلغ القرض",
                        value: "\(formatNumber(monthlyToLoanPercentage))% شهريًا",
                        color: .blue
                    )
                }

                VStack(alignment: .trailing, spacing: 10) {
                    smartNote("كلما زادت مدة السداد انخفض القسط غالبًا، لكن إجمالي الأرباح يزيد.")
                    smartNote("قارن بين أكثر من جهة تمويلية قبل اتخاذ القرار، خصوصًا إذا كانت نسبة الأرباح مرتفعة.")
                    smartNote("هذه القراءة تحليلية تقديرية ولا تعني قبولًا أو رفضًا تمويليًا.")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func scoreIndicatorCard(
        title: String,
        level: PersonalLoanInsightLevel,
        score: Double,
        detail: String
    ) -> some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack(spacing: 10) {
                Text("\(Int(score * 100))%")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(level.color)

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .multilineTextAlignment(.trailing)

                    Text(detail)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .environment(\.layoutDirection, .leftToRight)

            GeometryReader { geometry in
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(progressTrackBackground)
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(level.color)
                        .frame(width: max(12, geometry.size.width * score), height: 10)
                }
            }
            .frame(height: 10)
        }
        .padding(14)
        .background(innerCardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(innerCardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func insightRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(color)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(12)
        .background(innerCardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(innerCardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .environment(\.layoutDirection, .leftToRight)
    }

    private func smartNote(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(text)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .padding(.top, 2)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func mainResultCard(title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(value)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.buttonOrange)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            
            Spacer()
            
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.trailing)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.buttonOrange.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.buttonOrange.opacity(0.26), lineWidth: 1)
                )
        )
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private func resultLine(title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            
            Spacer()
            
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private var dividerLine: some View {
        Rectangle()
            .fill(innerCardBorder)
            .frame(height: 1)
    }
    
    private var warningSection: some View {
        sectionCard(icon: "exclamationmark.triangle", iconColor: .red, isWarning: true) {
            VStack(alignment: .trailing, spacing: 10) {
                Text("تنبيه مهم")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("النتائج تقديرية وتعتمد على الأرقام التي تدخلها فقط. قد تختلف طريقة احتساب البنك حسب الرسوم الإدارية، التأمين، الاستقطاع، أو شروط التمويل.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private var explanationSection: some View {
        sectionCard(icon: "function", iconColor: AppTheme.buttonOrange) {
            VStack(alignment: .trailing, spacing: 14) {
                Text("طريقة الحساب")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("تعتمد هذه الطريقة على حساب الأرباح السنوية بشكل مبسط، ثم ضربها في عدد سنوات السداد، وبعد ذلك يتم تقسيم إجمالي المطلوب سداده على عدد الأشهر.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(alignment: .trailing, spacing: 10) {
                    bullet("مبلغ الأرباح = مبلغ القرض × نسبة الأرباح السنوية × عدد السنوات.")
                    bullet("إجمالي المطلوب سداده = مبلغ القرض + مبلغ الأرباح.")
                    bullet("القسط الشهري = إجمالي المطلوب سداده ÷ عدد أشهر السداد.")
                    bullet("مثال: ٥٠٣٠٠ × ٣٪ × ٥ سنوات = ٧٥٤٥ ر.س.")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(text)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Circle()
                .fill(AppTheme.buttonOrange)
                .frame(width: 7, height: 7)
                .padding(.top, 7)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.forwardslash.minus")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
            
            Text("أدخل البيانات للحساب التلقائي")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
            
            Text("مثال: مبلغ القرض ٥٠٣٠٠ ريال، نسبة الأرباح السنوية ٣٪، مدة السداد ٥ سنوات.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: cardShadowRadius, x: 0, y: cardShadowY)
    }
    
    private func sectionCard<Content: View>(
        icon: String,
        iconColor: Color,
        isWarning: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .trailing, spacing: 0) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            Image(systemName: icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(iconColor)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(sectionCardBackground(isWarning: isWarning))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(sectionCardBorder(isWarning: isWarning), lineWidth: 1)
                )
        )
        .shadow(color: cardShadow, radius: cardShadowRadius, x: 0, y: cardShadowY)
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private func calculateLoan() -> LoanCalculationResult? {
        guard let loan = parseNumber(loanAmount),
              let annualRate = parseNumber(annualProfitRate),
              let yearsValue = parseNumber(years),
              loan > 0,
              annualRate >= 0,
              yearsValue > 0 else {
            return nil
        }
        
        let months = max(Int((yearsValue * 12).rounded()), 1)
        let profitAmount = loan * (annualRate / 100) * yearsValue
        let totalRequired = loan + profitAmount
        let monthlyPayment = totalRequired / Double(months)
        
        return LoanCalculationResult(
            loanAmount: loan,
            annualProfitRate: annualRate,
            years: yearsValue,
            months: months,
            profitAmount: profitAmount,
            totalRequired: totalRequired,
            monthlyPayment: monthlyPayment
        )
    }
    
    private func clearInputs() {
        loanAmount = ""
        annualProfitRate = ""
        years = ""
    }
    
    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }
    
    private var cardBackground: Color {
        colorScheme == .light ? Color.white : AppTheme.secondaryBackground
    }
    
    private var cardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : AppTheme.buttonGray.opacity(0.7)
    }
    
    private var cardShadow: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : Color.clear
    }
    
    private var cardShadowRadius: CGFloat {
        colorScheme == .light ? 10 : 0
    }
    
    private var cardShadowY: CGFloat {
        colorScheme == .light ? 5 : 0
    }
    
    private var inputFieldBackground: Color {
        colorScheme == .light ? Color.white : AppTheme.buttonDark
    }
    
    private var inputFieldBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : AppTheme.buttonGray.opacity(0.7)
    }
    
    private var iconBadgeBackground: Color {
        colorScheme == .light ? AppTheme.buttonOrange.opacity(0.10) : AppTheme.buttonDark
    }
    
    private var innerCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFC") : AppTheme.buttonDark
    }
    
    private var innerCardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : AppTheme.buttonGray.opacity(0.7)
    }
    
    private var clearButtonBackground: Color {
        colorScheme == .light ? Color.red.opacity(0.07) : AppTheme.buttonDark
    }
    
    private var progressTrackBackground: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : AppTheme.buttonGray
    }
    
    private func sectionCardBackground(isWarning: Bool) -> Color {
        if isWarning {
            return colorScheme == .light ? Color(hex: "#FFF7F5") : Color.red.opacity(0.12)
        }
        
        return cardBackground
    }
    
    private func sectionCardBorder(isWarning: Bool) -> Color {
        if isWarning {
            return colorScheme == .light ? Color.red.opacity(0.16) : Color.red.opacity(0.35)
        }
        
        return cardBorder
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
    
    private func shareText(for result: LoanCalculationResult) -> String {
        """
        نتيجة حاسبة التمويل الشخصي من احسبها:
        
        مبلغ القرض: \(formatCurrency(result.loanAmount))
        نسبة الأرباح السنوية: \(formatNumber(result.annualProfitRate))%
        مدة السداد: \(formatNumber(result.years)) سنة
        
        مبلغ الأرباح: \(formatCurrency(result.profitAmount))
        إجمالي المطلوب سداده: \(formatCurrency(result.totalRequired))
        القسط الشهري: \(formatCurrency(result.monthlyPayment))
        
        النتائج تقديرية.
        """
    }

    @MainActor
    private func resultCardImage(for result: LoanCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة التمويل الشخصي",
            rows: [
                ResultCardRow(title: "مبلغ القرض", value: formatCurrency(result.loanAmount)),
                ResultCardRow(title: "مبلغ الأرباح", value: formatCurrency(result.profitAmount)),
                ResultCardRow(title: "إجمالي المطلوب سداده", value: formatCurrency(result.totalRequired)),
                ResultCardRow(title: "القسط الشهري", value: formatCurrency(result.monthlyPayment), valueColor: AppTheme.buttonOrange)
            ],
            note: "النتائج تقديرية."
        )
    }
}


private enum PersonalLoanInsightLevel {
    case excellent
    case good
    case attention
    case high

    var title: String {
        switch self {
        case .excellent:
            return "ممتاز"
        case .good:
            return "جيد"
        case .attention:
            return "يحتاج مراجعة"
        case .high:
            return "مرتفع"
        }
    }

    var badgeTitle: String {
        switch self {
        case .excellent:
            return "🟢 ممتاز"
        case .good:
            return "🔵 جيد"
        case .attention:
            return "🟠 يحتاج مراجعة"
        case .high:
            return "🔴 مرتفع"
        }
    }

    var color: Color {
        switch self {
        case .excellent:
            return .green
        case .good:
            return .blue
        case .attention:
            return AppTheme.buttonOrange
        case .high:
            return .red
        }
    }

    var score: Double {
        switch self {
        case .excellent:
            return 0.90
        case .good:
            return 0.72
        case .attention:
            return 0.50
        case .high:
            return 0.25
        }
    }

    var detailText: String {
        switch self {
        case .excellent:
            return "تكلفة التمويل منخفضة ومريحة نسبيًا."
        case .good:
            return "النتيجة مناسبة مع أهمية مقارنة العروض."
        case .attention:
            return "يفضل مراجعة مدة السداد ونسبة الأرباح."
        case .high:
            return "تحتاج النتيجة إلى حذر ومراجعة إضافية."
        }
    }
}

private struct LoanCalculationResult {
    let loanAmount: Double
    let annualProfitRate: Double
    let years: Double
    let months: Int
    let profitAmount: Double
    let totalRequired: Double
    let monthlyPayment: Double
}

#Preview {
    NavigationStack {
        PersonalLoanCalculatorView()
    }
}
