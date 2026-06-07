import SwiftUI
import UIKit

struct CalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedMode: CalculatorMode = .basic
    @State private var angleMode: AngleMode = .degrees
    @State private var expressionValue: String = ""
    @State private var resultValue: String = "0"
    
    @State private var currentNumber: Double = 0
    @State private var storedNumber: Double?
    @State private var selectedOperation: String?
    @State private var shouldStartNewNumber = false
    @State private var memoryValue: Double = 0
    @State private var isSecondMode = false
    @State private var activeUtilitySheet: CalculatorUtilitySheet?
    @State private var discountInput: String = ""
    @State private var utilityValidationMessage: String?
    @State private var utilityBreakdown: [CalculatorBreakdownRow] = []
    @State private var utilityShareText: String?
    @State private var showCopyConfirmation = false
    
    private let buttons: [[String]] = [
        ["AC", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]

    private let scientificButtons: [[String]] = [
        ["(", ")", "mc", "m+", "m-", "mr"],
        ["2nd", "x²", "x³", "xʸ", "eˣ", "10ˣ"],
        ["1/x", "²√x", "³√x", "ʸ√x", "ln", "log"],
        ["x!", "sin", "cos", "tan", "e", "π"],
        ["AC", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["تحويل", "0", ".", "="]
    ]

    private var hasExpressionPreview: Bool {
        !expressionValue.isEmpty && expressionValue != resultValue
    }
    
    private var hasUtilityBreakdown: Bool {
        !utilityBreakdown.isEmpty
    }
    
    private var shareText: String {
        utilityShareText ?? "Result = \(resultValue)"
    }
    
    private var copyText: String {
        shareText
    }
    
    private var isLightMode: Bool {
        colorScheme == .light
    }
    
    private var calculatorBackground: Color {
        isLightMode ? Color(hex: "#F7F9FC") : AppTheme.background
    }
    
    private var displayCardBackground: Color {
        isLightMode ? Color.white : AppTheme.secondaryBackground
    }
    
    private var premiumBorder: Color {
        isLightMode ? Color(hex: "#E3E8F0") : AppTheme.border
    }
    
    private var premiumInputBackground: Color {
        isLightMode ? Color(hex: "#F4F7FB") : AppTheme.inputBackground
    }
    
    private var lightNumberButtonBackground: Color {
        isLightMode ? Color.white : AppTheme.buttonDark
    }
    
    private var lightFunctionButtonBackground: Color {
        isLightMode ? Color(hex: "#F0F4F8") : AppTheme.buttonGray
    }
    
    var body: some View {
        ZStack {
            calculatorBackground.ignoresSafeArea()
            
            VStack(spacing: selectedMode == .scientific ? 8 : (hasExpressionPreview ? 16 : 20)) {
                displayCard
                    .padding(.horizontal, 16)
                    .padding(.top, selectedMode == .scientific ? 12 : 18)
                
                VStack(spacing: selectedMode == .scientific ? 8 : 12) {
                    if selectedMode == .scientific {
                        scientificModeControls
                        scientificGrid
                    } else {
                        utilityRow
                        basicKeypad
                    }
                    
                    if hasUtilityBreakdown {
                        utilityBreakdownCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, hasUtilityBreakdown ? 56 : (selectedMode == .scientific ? 38 : 88))
                .animation(.spring(response: 0.28, dampingFraction: 0.86), value: selectedMode)
                .animation(.spring(response: 0.24, dampingFraction: 0.9), value: hasUtilityBreakdown)
                
                Spacer(minLength: 0)
            }
        }
        .sheet(item: $activeUtilitySheet) { sheet in
            utilitySheetContent(for: sheet)
                .presentationDetents([.height(sheet == .discount ? 250 : 520)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var displayCard: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(spacing: 8) {
                shareButton
                copyButton
                
                Spacer()
                
                if showCopyConfirmation {
                    Text("تم نسخ النتيجة")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.secondaryText)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity)
            .environment(\.layoutDirection, .leftToRight)
            
            Text(hasExpressionPreview ? expressionValue : " ")
                .font(.system(size: selectedMode == .scientific ? 18 : 20, weight: .regular, design: .rounded))
                .foregroundColor(hasExpressionPreview ? AppTheme.secondaryText.opacity(0.75) : Color.clear)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: selectedMode == .scientific ? 20 : 22, maxHeight: selectedMode == .scientific ? 20 : 22, alignment: .trailing)
            
            Text(resultValue)
                .font(.system(size: selectedMode == .scientific ? 42 : 56, weight: .light, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .minimumScaleFactor(0.28)
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: selectedMode == .scientific ? 44 : 58, maxHeight: selectedMode == .scientific ? 44 : 58, alignment: .trailing)
        }
        .padding(.horizontal, 18)
        .padding(.top, selectedMode == .scientific ? 10 : 12)
        .padding(.bottom, selectedMode == .scientific ? 12 : 16)
        .frame(maxWidth: .infinity)
        .frame(height: selectedMode == .scientific ? 128 : 148)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(displayCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(premiumBorder, lineWidth: 1)
                )
                .shadow(color: isLightMode ? Color.black.opacity(0.04) : Color.clear, radius: 16, x: 0, y: 8)
        )
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var shareButton: some View {
        ShareLink(item: shareText) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(premiumInputBackground)
                        .overlay(
                            Circle()
                                .stroke(premiumBorder, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    private var copyButton: some View {
        Button {
            copyCurrentResult()
        } label: {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(premiumInputBackground)
                        .overlay(
                            Circle()
                                .stroke(premiumBorder, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private var utilityRow: some View {
        HStack(spacing: 8) {
            utilityButton("ضريبة") {
                triggerHaptic(.heavy)
                applyVAT()
            }
            
            utilityButton("خصم") {
                triggerHaptic(.heavy)
                discountInput = ""
                utilityValidationMessage = nil
                activeUtilitySheet = .discount
            }
            
            utilityButton("تحويل") {
                triggerHaptic(.heavy)
                utilityValidationMessage = nil
                activeUtilitySheet = .conversion
            }
            
            utilityButton(selectedMode.toggleTitle) {
                triggerHaptic(.heavy)
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    selectedMode.toggle()
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(isLightMode ? Color.white : AppTheme.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .stroke(premiumBorder, lineWidth: 1)
                )
                .shadow(color: isLightMode ? Color.black.opacity(0.035) : Color.clear, radius: 10, x: 0, y: 5)
        )
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var basicKeypad: some View {
        VStack(spacing: 12) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        PremiumCalculatorButton(
                            title: button,
                            backgroundColor: buttonColor(for: button),
                            foregroundColor: buttonTextColor(for: button),
                            isLightMode: isLightMode
                        ) {
                            handleButtonTap(button)
                        }
                    }
                }
            }
        }
    }
    
    private var scientificModeControls: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
                    angleMode.toggle()
                }
            } label: {
                HStack(spacing: 2) {
                    angleModeSegment(.degrees)
                    angleModeSegment(.radians)
                }
                .padding(3)
                .background(
                    Capsule()
                        .fill(premiumInputBackground)
                        .overlay(
                            Capsule()
                                .stroke(premiumBorder, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            utilityButton(selectedMode.toggleTitle) {
                triggerHaptic(.heavy)
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    selectedMode.toggle()
                }
            }
            .frame(width: 86)
        }
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private var scientificGrid: some View {
        VStack(spacing: 7) {
            ForEach(scientificButtons, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { button in
                        compactCalculatorButton(button)
                    }
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private func utilityButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(title == selectedMode.toggleTitle ? AppTheme.buttonOrange : AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(utilityButtonBackground(for: title))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(title == selectedMode.toggleTitle ? AppTheme.buttonOrange.opacity(isLightMode ? 0.45 : 0.38) : (isLightMode ? Color.clear : AppTheme.border), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    private func utilityButtonBackground(for title: String) -> Color {
        if title == selectedMode.toggleTitle {
            return isLightMode ? AppTheme.buttonOrange.opacity(0.10) : AppTheme.secondaryBackground
        }
        
        return isLightMode ? Color.clear : AppTheme.secondaryBackground
    }
    
    private var utilityBreakdownCard: some View {
        VStack(alignment: .trailing, spacing: 6) {
            ForEach(Array(utilityBreakdown.enumerated()), id: \.element.id) { index, row in
                let isResultRow = index == utilityBreakdown.count - 1
                
                HStack(alignment: .firstTextBaseline, spacing: 14) {
                    Text(row.value)
                        .font(breakdownFont(isResultRow: isResultRow))
                        .foregroundColor(isResultRow ? AppTheme.primaryText : AppTheme.secondaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(row.label)
                        .font(breakdownFont(isResultRow: isResultRow))
                        .foregroundColor(isResultRow ? AppTheme.primaryText : AppTheme.secondaryText)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 142, alignment: .trailing)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .leftToRight)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isLightMode ? Color.white : AppTheme.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(premiumBorder, lineWidth: 1)
                )
                .shadow(color: isLightMode ? Color.black.opacity(0.035) : Color.clear, radius: 12, x: 0, y: 6)
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func breakdownFont(isResultRow: Bool) -> Font {
        .system(size: isResultRow ? 15 : 14, weight: isResultRow ? .bold : .medium, design: .rounded)
    }
    
    @ViewBuilder
    private func utilitySheetContent(for sheet: CalculatorUtilitySheet) -> some View {
        switch sheet {
        case .discount:
            discountSheet
        case .conversion:
            conversionSheet
        }
    }
    
    private var discountSheet: some View {
        VStack(alignment: .trailing, spacing: 16) {
            Text("نسبة الخصم")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            TextField("مثال: 20 أو 7.5", text: $discountInput)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .tint(AppTheme.buttonOrange)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.inputBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                )
            
            if let utilityValidationMessage {
                Text(utilityValidationMessage)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Button {
                triggerHaptic(.heavy)
                applyDiscountFromSheet()
            } label: {
                Text("تطبيق الخصم")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.buttonOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(AppTheme.background)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var conversionSheet: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 16) {
                Text("تحويل")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                conversionSection(
                    title: "الطول",
                    options: [
                        .init(title: "متر ⇄ قدم", forwardLabel: "متر إلى قدم", reverseLabel: "قدم إلى متر", forwardMultiplier: 3.280839895, reverseMultiplier: 1 / 3.280839895),
                        .init(title: "سم ⇄ إنش", forwardLabel: "سم إلى إنش", reverseLabel: "إنش إلى سم", forwardMultiplier: 1 / 2.54, reverseMultiplier: 2.54),
                        .init(title: "كم ⇄ ميل", forwardLabel: "كم إلى ميل", reverseLabel: "ميل إلى كم", forwardMultiplier: 0.6213711922, reverseMultiplier: 1 / 0.6213711922)
                    ]
                )
                
                conversionSection(
                    title: "الوزن",
                    options: [
                        .init(title: "كجم ⇄ رطل", forwardLabel: "كجم إلى رطل", reverseLabel: "رطل إلى كجم", forwardMultiplier: 2.2046226218, reverseMultiplier: 1 / 2.2046226218),
                        .init(title: "جرام ⇄ أونصة", forwardLabel: "جرام إلى أونصة", reverseLabel: "أونصة إلى جرام", forwardMultiplier: 1 / 28.349523125, reverseMultiplier: 28.349523125)
                    ]
                )
                
                conversionSection(
                    title: "العملة",
                    options: [
                        .init(title: "ر.س ⇄ دولار", forwardLabel: "ر.س إلى دولار", reverseLabel: "دولار إلى ر.س", forwardMultiplier: 1 / 3.75, reverseMultiplier: 3.75),
                        .init(title: "ر.س ⇄ درهم", forwardLabel: "ر.س إلى درهم", reverseLabel: "درهم إلى ر.س", forwardMultiplier: 1 / 1.02, reverseMultiplier: 1.02),
                        .init(title: "ر.س ⇄ يورو", forwardLabel: "ر.س إلى يورو", reverseLabel: "يورو إلى ر.س", forwardMultiplier: 1 / 4.10, reverseMultiplier: 4.10)
                    ]
                )
                
                Text("تحويل العملات تقديري وقد يختلف حسب سعر الصرف.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 2)
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func conversionSection(title: String, options: [ConversionOption]) -> some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            ForEach(options) { option in
                VStack(spacing: 8) {
                    Text(option.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    HStack(spacing: 8) {
                        conversionButton(option.forwardLabel) {
                            triggerHaptic(.heavy)
                            applyConversion(label: option.forwardLabel, multiplier: option.forwardMultiplier)
                        }
                        
                        conversionButton(option.reverseLabel) {
                            triggerHaptic(.heavy)
                            applyConversion(label: option.reverseLabel, multiplier: option.reverseMultiplier)
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.secondaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                )
            }
        }
    }
    
    private func conversionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(AppTheme.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    private func angleModeSegment(_ mode: AngleMode) -> some View {
        Text(mode.title)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundColor(angleMode == mode ? .white : AppTheme.secondaryText)
            .frame(width: 36, height: 24)
            .background(
                Capsule()
                    .fill(angleMode == mode ? AppTheme.buttonOrange : Color.clear)
            )
    }

    private func compactCalculatorButton(_ title: String) -> some View {
        Button {
            handleButtonTap(title)
        } label: {
            Text(title)
                .font(.system(size: compactFontSize(for: title), weight: .bold, design: .rounded))
                .foregroundColor(compactButtonTextColor(for: title))
                .minimumScaleFactor(0.75)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .frame(height: 39)
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(compactButtonColor(for: title))
                        .overlay(
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .stroke(AppTheme.border.opacity(0.65), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    private func compactFontSize(for button: String) -> CGFloat {
        button.count > 3 ? 12 : 14
    }

    private func buttonTextColor(for button: String) -> Color {
        if ["÷", "×", "-", "+", "="].contains(button) {
            return .white
        }
        
        return AppTheme.primaryText
    }

    private func buttonColor(for button: String) -> Color {
        if ["÷", "×", "-", "+", "="].contains(button) {
            return AppTheme.buttonOrange
        }
        
        if ["AC", "±", "%"].contains(button) {
            return lightFunctionButtonBackground
        }
        
        return lightNumberButtonBackground
    }
    
    private func compactButtonTextColor(for button: String) -> Color {
        if ["÷", "×", "-", "+", "="].contains(button) {
            return .white
        }
        
        if button == "تحويل" {
            return AppTheme.buttonOrange
        }
        
        return AppTheme.primaryText
    }
    
    private func compactButtonColor(for button: String) -> Color {
        if ["÷", "×", "-", "+", "="].contains(button) {
            return AppTheme.buttonOrange
        }
        
        if ["AC", "±", "%"].contains(button) {
            return lightFunctionButtonBackground
        }
        
        if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."].contains(button) {
            return lightNumberButtonBackground
        }
        
        return lightFunctionButtonBackground
    }
    
    private func handleButtonTap(_ button: String) {
        if button == "AC" {
            triggerHaptic(.medium)
            clearCalculator()
        } else if button == "±" {
            triggerHaptic(.medium)
            toggleSign()
        } else if button == "%" {
            triggerHaptic(.medium)
            applyPercentage()
        } else if button == "تحويل" {
            triggerHaptic(.heavy)
            utilityValidationMessage = nil
            activeUtilitySheet = .conversion
        } else if ["mc", "m+", "m-", "mr"].contains(button) {
            triggerHaptic(.medium)
            handleMemoryButton(button)
        } else if button == "2nd" {
            triggerHaptic(.medium)
            isSecondMode.toggle()
        } else if ["√", "²√x", "³√x", "x²", "x³", "π", "e", "sin", "cos", "tan", "ln", "log", "10ˣ", "eˣ", "1/x", "x!"].contains(button) {
            triggerHaptic(.medium)
            applyScientificOperation(button)
        } else if ["(", ")"].contains(button) {
            triggerHaptic(.medium)
            // TODO: Add full expression parser support for parentheses.
            return
        } else if button == "xʸ" {
            triggerHaptic(.medium)
            selectOperation(button)
        } else if button == "ʸ√x" {
            triggerHaptic(.medium)
            selectOperation(button)
        } else if ["+", "-", "×", "÷"].contains(button) {
            triggerHaptic(.medium)
            selectOperation(button)
        } else if button == "=" {
            triggerHaptic(.heavy)
            calculateResult()
        } else {
            triggerHaptic(.light)
            enterNumber(button)
        }
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    private func copyCurrentResult() {
        triggerHaptic(.light)
        UIPasteboard.general.string = copyText
        
        withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
            showCopyConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeOut(duration: 0.2)) {
                showCopyConfirmation = false
            }
        }
    }
    
    private func handleMemoryButton(_ button: String) {
        guard let value = currentDisplayNumber else { return }
        
        switch button {
        case "mc":
            memoryValue = 0
        case "m+":
            memoryValue += value
        case "m-":
            memoryValue -= value
        case "mr":
            clearUtilityShareContext()
            currentNumber = memoryValue
            resultValue = formatNumber(memoryValue)
            expressionValue = "mr"
            shouldStartNewNumber = true
        default:
            return
        }
    }
    
    private func applyVAT() {
        guard let amount = currentDisplayNumber else { return }
        
        let vatAmount = amount * 0.15
        let total = amount + vatAmount
        let amountText = formatNumber(amount)
        let vatAmountText = formatNumber(vatAmount)
        let totalText = formatNumber(total)
        
        setUtilityResult(
            total,
            breakdown: [
                .init(label: "المبلغ", value: amountText),
                .init(label: "الضريبة 15%", value: vatAmountText),
                .init(label: "الإجمالي", value: totalText)
            ],
            shareText: """
            احسبها | Ahsebha Calculator
            
            المبلغ:
            \(amountText)
            
            الضريبة:
            \(vatAmountText)
            
            الإجمالي:
            \(totalText)
            """
        )
    }
    
    private func applyDiscountFromSheet() {
        guard let price = currentDisplayNumber else {
            utilityValidationMessage = "لا توجد قيمة صالحة للتطبيق."
            return
        }
        
        guard let discountPercent = parseUtilityNumber(discountInput),
              discountPercent >= 0 else {
            utilityValidationMessage = "أدخل نسبة خصم صحيحة."
            return
        }
        
        let discountAmount = price * discountPercent / 100
        let finalPrice = price - discountAmount
        let priceText = formatNumber(price)
        let discountPercentText = formatNumber(discountPercent)
        let discountAmountText = formatNumber(discountAmount)
        let finalPriceText = formatNumber(finalPrice)
        
        setUtilityResult(
            finalPrice,
            breakdown: [
                .init(label: "السعر الأصلي", value: priceText),
                .init(label: "الخصم", value: "\(discountPercentText)% = \(discountAmountText)"),
                .init(label: "السعر بعد الخصم", value: finalPriceText)
            ],
            shareText: """
            احسبها | Ahsebha Calculator
            
            السعر الأصلي:
            \(priceText)
            
            الخصم:
            \(discountPercentText)% = \(discountAmountText)
            
            السعر بعد الخصم:
            \(finalPriceText)
            """
        )
        
        activeUtilitySheet = nil
        utilityValidationMessage = nil
    }
    
    private func applyConversion(label: String, multiplier: Double) {
        guard let value = currentDisplayNumber else { return }
        
        let convertedValue = value * multiplier
        let valueText = formatNumber(value)
        let convertedValueText = formatNumber(convertedValue)
        let conversionParts = conversionDirectionParts(from: label)
        
        setUtilityResult(
            convertedValue,
            breakdown: [
                .init(label: "القيمة الأصلية", value: valueText),
                .init(label: "من", value: conversionParts.from),
                .init(label: "إلى", value: conversionParts.to),
                .init(label: "النتيجة", value: convertedValueText)
            ],
            shareText: """
            احسبها | Ahsebha Calculator
            
            القيمة الأصلية:
            \(valueText)
            
            من:
            \(conversionParts.from)
            
            إلى:
            \(conversionParts.to)
            
            النتيجة:
            \(convertedValueText)
            """
        )
        
        activeUtilitySheet = nil
    }
    
    private func setUtilityResult(_ value: Double, breakdown: [CalculatorBreakdownRow], shareText: String) {
        currentNumber = value
        resultValue = formatNumber(value)
        expressionValue = ""
        utilityBreakdown = breakdown
        utilityShareText = shareText
        storedNumber = nil
        selectedOperation = nil
        shouldStartNewNumber = true
    }
    
    private func conversionDirectionParts(from label: String) -> (from: String, to: String) {
        let parts = label.components(separatedBy: " إلى ")
        
        guard parts.count == 2 else {
            return (label, "")
        }
        
        return (parts[0], parts[1])
    }

    private func applyScientificOperation(_ operation: String) {
        clearUtilityShareContext()
        
        if resultValue == "خطأ" {
            clearCalculator()
        }

        let input = currentNumber
        let result: Double
        let expression: String
        let angleInput = angleMode == .degrees ? input * .pi / 180 : input

        switch operation {
        case "π":
            result = Double.pi
            expression = "π"
        case "e":
            result = 2.718281828459045
            expression = "e"
        case "√", "²√x":
            guard input >= 0 else {
                showError("لا يمكن حساب الجذر لرقم سالب")
                return
            }
            result = sqrt(input)
            expression = "√(\(formatNumber(input)))"
        case "³√x":
            result = input >= 0 ? pow(input, 1.0 / 3.0) : -pow(abs(input), 1.0 / 3.0)
            expression = "³√(\(formatNumber(input)))"
        case "x²":
            result = input * input
            expression = "(\(formatNumber(input)))²"
        case "x³":
            result = input * input * input
            expression = "(\(formatNumber(input)))³"
        case "eˣ":
            result = exp(input)
            expression = "e^\(formatNumber(input))"
        case "10ˣ":
            result = pow(10, input)
            expression = "10^\(formatNumber(input))"
        case "sin":
            result = sin(angleInput)
            expression = "sin(\(formatNumber(input)) \(angleMode.title))"
        case "cos":
            result = cos(angleInput)
            expression = "cos(\(formatNumber(input)) \(angleMode.title))"
        case "tan":
            result = tan(angleInput)
            expression = "tan(\(formatNumber(input)) \(angleMode.title))"
        case "log":
            guard input > 0 else {
                showError("لا يمكن حساب اللوغاريتم لهذا الرقم")
                return
            }
            result = log10(input)
            expression = "log(\(formatNumber(input)))"
        case "ln":
            guard input > 0 else {
                showError("لا يمكن حساب اللوغاريتم لهذا الرقم")
                return
            }
            result = log(input)
            expression = "ln(\(formatNumber(input)))"
        case "1/x":
            guard input != 0 else {
                showError("لا يمكن القسمة على صفر")
                return
            }
            result = 1 / input
            expression = "1/(\(formatNumber(input)))"
        case "x!":
            guard input >= 0,
                  input.rounded() == input,
                  input <= 170 else {
                showError("لا يمكن حساب العامل لهذا الرقم")
                return
            }
            result = factorial(Int(input))
            expression = "(\(formatNumber(input)))!"
        default:
            return
        }

        currentNumber = result
        resultValue = formatNumber(result)
        expressionValue = expression
        storedNumber = nil
        selectedOperation = nil
        shouldStartNewNumber = true
    }
    
    private func factorial(_ value: Int) -> Double {
        guard value > 1 else { return 1 }
        return (2...value).reduce(1.0) { $0 * Double($1) }
    }
    
    private func enterNumber(_ value: String) {
        clearUtilityShareContext()
        
        if shouldStartNewNumber {
            resultValue = value == "." ? "0." : value
            shouldStartNewNumber = false
        } else {
            if value == "." {
                if !resultValue.contains(".") {
                    resultValue += "."
                }
            } else {
                resultValue = resultValue == "0" ? value : resultValue + value
            }
        }
        
        currentNumber = Double(resultValue) ?? 0
        updateExpressionPreview()
    }
    
    private func selectOperation(_ operation: String) {
        clearUtilityShareContext()
        storedNumber = currentNumber
        selectedOperation = operation
        shouldStartNewNumber = true
        expressionValue = "\(formatNumber(currentNumber)) \(operation)"
    }
    
    private func calculateResult() {
        guard let storedNumber = storedNumber,
              let operation = selectedOperation else { return }
        
        let secondNumber = currentNumber
        let result: Double
        
        switch operation {
        case "+":
            result = storedNumber + secondNumber
        case "-":
            result = storedNumber - secondNumber
        case "×":
            result = storedNumber * secondNumber
        case "÷":
            if secondNumber == 0 {
                resultValue = "خطأ"
                expressionValue = "لا يمكن القسمة على صفر"
                resetCalculationState()
                return
            }
            result = storedNumber / secondNumber
        case "xʸ":
            result = pow(storedNumber, secondNumber)
        case "ʸ√x":
            guard storedNumber != 0 else {
                resultValue = "خطأ"
                expressionValue = "لا يمكن استخدام جذر بدرجة صفر"
                resetCalculationState()
                return
            }
            if secondNumber < 0 && storedNumber.truncatingRemainder(dividingBy: 2) == 0 {
                resultValue = "خطأ"
                expressionValue = "لا يمكن حساب هذا الجذر"
                resetCalculationState()
                return
            }
            result = secondNumber >= 0
                ? pow(secondNumber, 1 / storedNumber)
                : -pow(abs(secondNumber), 1 / storedNumber)
        default:
            return
        }
        
        expressionValue = "\(formatNumber(storedNumber)) \(operation) \(formatNumber(secondNumber))"
        resultValue = formatNumber(result)
        clearUtilityShareContext()
        
        currentNumber = result
        self.storedNumber = nil
        selectedOperation = nil
        shouldStartNewNumber = true
    }
    
    private func toggleSign() {
        if resultValue == "0" || resultValue == "خطأ" { return }
        clearUtilityShareContext()
        resultValue = resultValue.hasPrefix("-") ? String(resultValue.dropFirst()) : "-" + resultValue
        currentNumber = Double(resultValue) ?? 0
        updateExpressionPreview()
    }
    
    private func applyPercentage() {
        clearUtilityShareContext()
        currentNumber = currentNumber / 100
        resultValue = formatNumber(currentNumber)
        updateExpressionPreview()
    }
    
    private func clearCalculator() {
        expressionValue = ""
        resultValue = "0"
        utilityBreakdown = []
        utilityShareText = nil
        utilityValidationMessage = nil
        currentNumber = 0
        storedNumber = nil
        selectedOperation = nil
        shouldStartNewNumber = false
    }
    
    private func resetCalculationState() {
        currentNumber = 0
        storedNumber = nil
        selectedOperation = nil
        shouldStartNewNumber = true
    }

    private func showError(_ message: String) {
        clearUtilityShareContext()
        resultValue = "خطأ"
        expressionValue = message
        resetCalculationState()
    }
    
    private func clearUtilityShareContext() {
        utilityBreakdown = []
        utilityShareText = nil
    }
    
    private func updateExpressionPreview() {
        if let storedNumber = storedNumber, let selectedOperation = selectedOperation {
            expressionValue = "\(formatNumber(storedNumber)) \(selectedOperation) \(resultValue)"
        } else {
            expressionValue = ""
        }
    }
    
    private var currentDisplayNumber: Double? {
        resultValue == "خطأ" ? nil : currentNumber
    }
    
    private func parseUtilityNumber(_ text: String) -> Double? {
        let normalized = normalizeDigits(text)
            .replacingOccurrences(of: "٫", with: ".")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Double(normalized)
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
    
    private func formatNumber(_ number: Double) -> String {
        guard number.isFinite else {
            return "خطأ"
        }

        let normalizedNumber = number == -0 ? 0 : number
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: normalizedNumber)) ?? "\(normalizedNumber)"
    }
}

private enum CalculatorMode: String, CaseIterable, Identifiable {
    case basic
    case scientific

    var id: String { rawValue }

    var title: String {
        switch self {
        case .basic:
            return "عادية"
        case .scientific:
            return "علمية"
        }
    }
    
    var toggleTitle: String {
        switch self {
        case .basic:
            return "علمية"
        case .scientific:
            return "أساسية"
        }
    }
    
    mutating func toggle() {
        self = self == .basic ? .scientific : .basic
    }
}

private enum AngleMode: String {
    case degrees
    case radians
    
    var title: String {
        switch self {
        case .degrees:
            return "DEG"
        case .radians:
            return "RAD"
        }
    }
    
    mutating func toggle() {
        self = self == .degrees ? .radians : .degrees
    }
}

private enum CalculatorUtilitySheet: String, Identifiable, Equatable {
    case discount
    case conversion
    
    var id: String { rawValue }
}

private struct ConversionOption: Identifiable {
    let id = UUID()
    let title: String
    let forwardLabel: String
    let reverseLabel: String
    let forwardMultiplier: Double
    let reverseMultiplier: Double
}

private struct CalculatorBreakdownRow: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

private struct PremiumCalculatorButton: View {
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let isLightMode: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isLightMode ? Color(hex: "#E5EAF2") : Color.white.opacity(0.06), lineWidth: 1)
                
                if !isLightMode {
                    VStack(spacing: 0) {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 22)
                        
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                
                Text(title)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .shadow(
                color: shadowColor,
                radius: isPressed ? 3 : (isLightMode ? 7 : 12),
                x: 0,
                y: isPressed ? 2 : (isLightMode ? 4 : 8)
            )
            .animation(.spring(response: 0.22, dampingFraction: 0.75), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
    
    private var gradientColors: [Color] {
        if isLightMode {
            return [
                backgroundColor,
                backgroundColor.opacity(0.96)
            ]
        }
        
        return [
            backgroundColor.opacity(1.0),
            backgroundColor.opacity(0.88)
        ]
    }
    
    private var shadowColor: Color {
        isLightMode
            ? Color.black.opacity(isPressed ? 0.045 : 0.075)
            : Color.black.opacity(isPressed ? 0.18 : 0.32)
    }
}

#Preview {
    CalculatorView()
}
