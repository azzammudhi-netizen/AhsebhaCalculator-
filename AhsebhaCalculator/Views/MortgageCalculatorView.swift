//
//  MortgageCalculatorView.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-17.
//

//
//  MortgageCalculatorView.swift
//  AhsebhaCalculator
//
//  Created by Soliman Harbi on 1447-12-17.
//

import SwiftUI
import Foundation
import UIKit

struct MortgageCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var propertyPrice: String = ""
    @State private var downPayment: String = ""
    @State private var annualProfitRate: String = ""
    @State private var years: String = ""
    
    private var result: MortgageCalculationResult? {
        calculateMortgage()
    }
    
    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .trailing, spacing: 22) {
                    headerSection
                    inputSection
                    
                    if let result {
                        let generatedImage = resultCardImage(for: result)
                        
                        resultSection(result)
                        insightSection(result)
                        ShareResultButton(
                            text: shareText(for: result),
                            sharedImage: generatedImage
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
                Text("حاسبة التمويل العقاري")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Text("تقدير القسط الشهري بطريقة الرصيد المتناقص")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.blue.opacity(0.22))
                    .frame(width: 78, height: 78)
                
                Image(systemName: "house.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
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
                    title: "سعر العقار",
                    placeholder: "مثال: ٨٥٠٠٠٠",
                    value: $propertyPrice,
                    suffix: "ر.س",
                    icon: "house.fill"
                )
                
                calculatorInput(
                    title: "الدفعة الأولى",
                    placeholder: "مثال: ١٥٠٠٠٠",
                    value: $downPayment,
                    suffix: "ر.س",
                    icon: "banknote.fill"
                )
                
                calculatorInput(
                    title: "نسبة الأرباح السنوية",
                    placeholder: "مثال: ٤.٥",
                    value: $annualProfitRate,
                    suffix: "%",
                    icon: "percent"
                )
                
                calculatorInput(
                    title: "مدة التمويل بالسنوات",
                    placeholder: "مثال: ٢٠",
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
            
            Text("تساعدك حاسبة التمويل العقاري على تقدير مبلغ التمويل بعد خصم الدفعة الأولى، ثم حساب القسط الشهري وإجمالي الأرباح وإجمالي المبلغ المتوقع سداده بطريقة الرصيد المتناقص.")
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
    
    private func resultSection(_ result: MortgageCalculationResult) -> some View {
        sectionCard(icon: "chart.bar.xaxis", iconColor: .blue) {
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
                    resultLine(title: "سعر العقار", value: formatCurrency(result.propertyPrice))
                    dividerLine
                    resultLine(title: "الدفعة الأولى", value: formatCurrency(result.downPayment))
                    dividerLine
                    resultLine(title: "مبلغ التمويل", value: formatCurrency(result.financeAmount))
                    dividerLine
                    resultLine(title: "نسبة الأرباح السنوية", value: "\(formatNumber(result.annualProfitRate))%")
                    dividerLine
                    resultLine(title: "إجمالي الأرباح", value: formatCurrency(result.profitAmount))
                    dividerLine
                    resultLine(title: "إجمالي السداد", value: formatCurrency(result.totalRequired))
                    dividerLine
                    resultLine(title: "مدة التمويل", value: "\(result.months) شهر")
                    dividerLine
                    resultLine(title: "متوسط الأرباح شهرياً", value: formatCurrency(result.monthlyProfitAverage))
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
    

    private func insightSection(_ result: MortgageCalculationResult) -> some View {
        let downPaymentPercentage = result.propertyPrice > 0 ? (result.downPayment / result.propertyPrice) * 100 : 0
        let financePercentage = result.ltvPercentage
        let profitToFinancePercentage = result.financeAmount > 0 ? (result.profitAmount / result.financeAmount) * 100 : 0
        let ltvStatus = ltvAnalysis(for: financePercentage)
        let downPaymentStatus = downPaymentAnalysis(for: downPaymentPercentage)
        let profitStatus = profitAnalysis(for: profitToFinancePercentage)
        let durationStatus = durationAnalysis(for: result.months)

        let level: MortgageInsightLevel
        let summary: String

        if downPaymentPercentage >= 30 {
            level = .excellent
            summary = "الدفعة الأولى قوية وتساعد على تقليل مبلغ التمويل وإجمالي الأرباح."
        } else if downPaymentPercentage >= 20 {
            level = .good
            summary = "الدفعة الأولى جيدة وتمنح التمويل بداية أكثر توازنًا."
        } else if downPaymentPercentage >= 10 {
            level = .attention
            summary = "الدفعة الأولى مقبولة لكنها ترفع مبلغ التمويل، ومن الأفضل دراسة زيادتها إن أمكن."
        } else {
            level = .high
            summary = "الدفعة الأولى منخفضة، وقد يؤدي ذلك إلى ارتفاع مبلغ التمويل وإجمالي الأرباح."
        }

        return sectionCard(icon: "sparkles", iconColor: level.color) {
            VStack(alignment: .trailing, spacing: 16) {
                HStack(spacing: 10) {
                    Text(level.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(level.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(level.color.opacity(0.15))
                        .clipShape(Capsule())

                    Spacer()

                    Text("تحليل النتيجة")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .multilineTextAlignment(.center)
                }
                .environment(\.layoutDirection, .leftToRight)

                Text(summary)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ltvAnalysisCard(
                    percentage: financePercentage,
                    title: ltvStatus.title,
                    detail: ltvStatus.detail,
                    color: ltvStatus.color
                )

                VStack(spacing: 10) {
                    insightRow(
                        icon: "banknote.fill",
                        title: "نسبة الدفعة الأولى",
                        value: "\(formatNumber(downPaymentPercentage))%",
                        color: downPaymentStatus.color,
                        badge: downPaymentStatus.title
                    )

                    insightRow(
                        icon: "house.fill",
                        title: "نسبة التمويل من قيمة العقار",
                        value: "\(formatNumber(financePercentage))%",
                        color: ltvStatus.color,
                        badge: ltvStatus.title
                    )

                    insightRow(
                        icon: "percent",
                        title: "الأرباح إلى مبلغ التمويل",
                        value: "\(formatNumber(profitToFinancePercentage))%",
                        color: profitStatus.color,
                        badge: profitStatus.title
                    )

                    insightRow(
                        icon: "calendar",
                        title: "مدة التمويل",
                        value: "\(result.months) شهر",
                        color: durationStatus.color,
                        badge: durationStatus.title
                    )
                }

                VStack(alignment: .trailing, spacing: 10) {
                    smartNote("زيادة الدفعة الأولى تقلل مبلغ التمويل وقد تخفض إجمالي الأرباح.")
                    smartNote("مدة التمويل الأطول تخفض القسط الشهري غالبًا، لكنها قد ترفع التكلفة الإجمالية.")
                    smartNote("هذه القراءة تقديرية ولا تغني عن عرض تمويلي رسمي من الجهة المختصة.")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private func ltvAnalysisCard(percentage: Double, title: String, detail: String, color: Color) -> some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack(spacing: 10) {
                Text("\(formatNumber(percentage))%")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(color)

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("تحليل نسبة التمويل (LTV)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .multilineTextAlignment(.trailing)

                    Text("\(title) - \(detail)")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .environment(\.layoutDirection, .leftToRight)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(innerCardBorder)
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color)
                        .frame(width: max(12, geometry.size.width * min(max(percentage / 100, 0), 1)), height: 10)
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

    private func insightRow(icon: String, title: String, value: String, color: Color, badge: String) -> some View {
        HStack(spacing: 12) {
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(badge)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.13))
                    .clipShape(Capsule())
                
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.trailing)
            }

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
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(minHeight: 56, alignment: .center)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.buttonOrange.opacity(0.14))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppTheme.buttonOrange.opacity(0.30), lineWidth: 1)
                )
        )
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private func resultLine(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 138, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
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
                
                Text("النتائج تقديرية وليست عرضًا تمويليًا نهائيًا. قد تختلف النتيجة الفعلية حسب جهة التمويل، نوع المنتج، الرسوم الإدارية، التأمين، الدعم السكني، مدة التمويل، الدفعة الأولى، وسياسة احتساب معدل النسبة السنوي.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
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
                
                Text("تعتمد هذه الحاسبة على معادلة القسط الشهري للتمويل على الرصيد المتناقص، وهي أدق من طريقة ضرب مبلغ التمويل في النسبة السنوية وعدد السنوات، خصوصًا في التمويل العقاري طويل الأجل.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(alignment: .trailing, spacing: 10) {
                    bullet("مبلغ التمويل = سعر العقار - الدفعة الأولى.")
                    bullet("النسبة الشهرية = نسبة الأرباح السنوية ÷ ١٢.")
                    bullet("عدد الأشهر = مدة التمويل بالسنوات × ١٢.")
                    bullet("القسط الشهري يحسب بمعادلة الرصيد المتناقص.")
                    bullet("إجمالي المطلوب سداده = القسط الشهري × عدد الأشهر.")
                    bullet("مبلغ الأرباح = إجمالي المطلوب سداده - مبلغ التمويل.")
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
            Image(systemName: "house.and.flag.fill")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
            
            Text("أدخل البيانات للحساب التلقائي")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
            
            Text("مثال: سعر العقار ٨٥٠٠٠٠ ريال، الدفعة الأولى ١٥٠٠٠٠ ريال، نسبة الأرباح ٤.٥٪، مدة التمويل ٢٠ سنة.")
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
    
    private func calculateMortgage() -> MortgageCalculationResult? {
        guard let price = parseNumber(propertyPrice),
              let down = parseNumber(downPayment),
              let annualRate = parseNumber(annualProfitRate),
              let yearsValue = parseNumber(years),
              price > 0,
              down >= 0,
              down < price,
              annualRate >= 0,
              yearsValue > 0 else {
            return nil
        }
        
        let financeAmount = price - down
        let months = max(Int((yearsValue * 12).rounded()), 1)
        let monthlyRate = (annualRate / 100) / 12
        
        let monthlyPayment: Double
        
        if monthlyRate == 0 {
            monthlyPayment = financeAmount / Double(months)
        } else {
            monthlyPayment = financeAmount * monthlyRate / (1 - pow(1 + monthlyRate, Double(-months)))
        }
        
        let totalRequired = monthlyPayment * Double(months)
        let profitAmount = max(totalRequired - financeAmount, 0)
        
        return MortgageCalculationResult(
            propertyPrice: price,
            downPayment: down,
            financeAmount: financeAmount,
            annualProfitRate: annualRate,
            years: yearsValue,
            months: months,
            profitAmount: profitAmount,
            totalRequired: totalRequired,
            monthlyPayment: monthlyPayment
        )
    }
    
    private func clearInputs() {
        propertyPrice = ""
        downPayment = ""
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
        colorScheme == .light ? Color.black.opacity(0.06) : AppTheme.border
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
        colorScheme == .light ? Color.white : AppTheme.inputBackground
    }
    
    private var inputFieldBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : AppTheme.border
    }
    
    private var iconBadgeBackground: Color {
        colorScheme == .light ? AppTheme.buttonOrange.opacity(0.10) : AppTheme.buttonDark
    }
    
    private var innerCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFC") : AppTheme.inputBackground
    }
    
    private var innerCardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : AppTheme.border
    }
    
    private var clearButtonBackground: Color {
        colorScheme == .light ? Color.red.opacity(0.07) : AppTheme.inputBackground
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
    
    private func ltvAnalysis(for percentage: Double) -> MortgageMetricStatus {
        if percentage < 70 {
            return MortgageMetricStatus(title: "ممتاز", detail: "أقل من 70%", color: .green)
        } else if percentage <= 80 {
            return MortgageMetricStatus(title: "جيد", detail: "70% - 80%", color: .blue)
        } else if percentage <= 90 {
            return MortgageMetricStatus(title: "مرتفع", detail: "80% - 90%", color: AppTheme.buttonOrange)
        } else {
            return MortgageMetricStatus(title: "مرتفع جداً", detail: "أكثر من 90%", color: .red)
        }
    }
    
    private func downPaymentAnalysis(for percentage: Double) -> MortgageMetricStatus {
        if percentage >= 30 {
            return MortgageMetricStatus(title: "ممتاز", detail: "", color: .green)
        } else if percentage >= 20 {
            return MortgageMetricStatus(title: "جيد", detail: "", color: .blue)
        } else if percentage >= 10 {
            return MortgageMetricStatus(title: "متوسط", detail: "", color: AppTheme.buttonOrange)
        } else {
            return MortgageMetricStatus(title: "منخفض", detail: "", color: .red)
        }
    }
    
    private func profitAnalysis(for percentage: Double) -> MortgageMetricStatus {
        if percentage <= 30 {
            return MortgageMetricStatus(title: "جيد", detail: "", color: .green)
        } else if percentage <= 60 {
            return MortgageMetricStatus(title: "متوسط", detail: "", color: .blue)
        } else if percentage <= 100 {
            return MortgageMetricStatus(title: "مرتفع", detail: "", color: AppTheme.buttonOrange)
        } else {
            return MortgageMetricStatus(title: "مرتفع جداً", detail: "", color: .red)
        }
    }
    
    private func durationAnalysis(for months: Int) -> MortgageMetricStatus {
        if months <= 180 {
            return MortgageMetricStatus(title: "قصيرة", detail: "", color: .green)
        } else if months <= 240 {
            return MortgageMetricStatus(title: "متوسطة", detail: "", color: .blue)
        } else if months <= 300 {
            return MortgageMetricStatus(title: "طويلة", detail: "", color: AppTheme.buttonOrange)
        } else {
            return MortgageMetricStatus(title: "طويلة جداً", detail: "", color: .red)
        }
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
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formatted) ر.س"
    }
    
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    private func shareText(for result: MortgageCalculationResult) -> String {
        """
        حاسبة التمويل العقاري - احسبها
        
        سعر العقار:
        \(formatCurrency(result.propertyPrice))
        
        الدفعة الأولى:
        \(formatCurrency(result.downPayment))
        
        مبلغ التمويل:
        \(formatCurrency(result.financeAmount))
        
        القسط الشهري:
        \(formatCurrency(result.monthlyPayment))
        
        إجمالي الأرباح:
        \(formatCurrency(result.profitAmount))
        
        إجمالي السداد:
        \(formatCurrency(result.totalRequired))
        
        مدة التمويل:
        \(result.months) شهر
        
        تم الحساب بطريقة الرصيد المتناقص، والنتائج تقديرية.
        """
    }

    @MainActor
    private func resultCardImage(for result: MortgageCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة التمويل العقاري - احسبها",
            rows: [
                ResultCardRow(title: "سعر العقار", value: formatCurrency(result.propertyPrice)),
                ResultCardRow(title: "الدفعة الأولى", value: formatCurrency(result.downPayment)),
                ResultCardRow(title: "مبلغ التمويل", value: formatCurrency(result.financeAmount)),
                ResultCardRow(title: "القسط الشهري", value: formatCurrency(result.monthlyPayment), valueColor: AppTheme.buttonOrange),
                ResultCardRow(title: "إجمالي الأرباح", value: formatCurrency(result.profitAmount)),
                ResultCardRow(title: "إجمالي السداد", value: formatCurrency(result.totalRequired)),
                ResultCardRow(title: "مدة التمويل", value: "\(result.months) شهر")
            ],
            note: "النتائج تقديرية."
        )
    }
}


private enum MortgageInsightLevel {
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
            return "يحتاج انتباه"
        case .high:
            return "مرتفع"
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
}

private struct MortgageMetricStatus {
    let title: String
    let detail: String
    let color: Color
}

private struct MortgageCalculationResult {
    let propertyPrice: Double
    let downPayment: Double
    let financeAmount: Double
    let annualProfitRate: Double
    let years: Double
    let months: Int
    let profitAmount: Double
    let totalRequired: Double
    let monthlyPayment: Double
    
    var monthlyProfitAverage: Double {
        guard months > 0 else { return 0 }
        return profitAmount / Double(months)
    }
    
    var ltvPercentage: Double {
        guard propertyPrice > 0 else { return 0 }
        return financeAmount / propertyPrice * 100
    }
}

#Preview {
    NavigationStack {
        MortgageCalculatorView()
    }
}
