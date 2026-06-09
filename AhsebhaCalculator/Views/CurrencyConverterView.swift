import SwiftUI
import UIKit

struct CurrencyConverterView: View {
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: Field?

    @State private var amountText: String = "100"
    @State private var fromCurrency: CurrencyInfo = .sar
    @State private var toCurrency: CurrencyInfo = .usd
    @State private var result: CurrencyConversionResult?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var cacheWarning: String?
    @State private var hasCalculatedOnce = false
    @State private var swapButtonPressed = false

    private enum Field {
        case amount
    }

    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }

    private var cardBackground: Color {
        colorScheme == .light ? Color(hex: "#FBFCFF") : AppTheme.secondaryBackground
    }

    private var amountCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF8EF") : AppTheme.secondaryBackground
    }

    private var sourceCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F4F9FF") : AppTheme.secondaryBackground
    }

    private var targetCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F3FBF7") : AppTheme.secondaryBackground
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

    private var errorCardBackground: Color {
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
                        inputsSection(proxy: proxy)
                        statusSection

                        if let result {
                            resultCard(result)
                                .id("currencyResultSection")
                            exchangeRateCard(result)
                            lastUpdateCard(result)
                            detailsCard(result)
                            shareSection(result)
                        } else {
                            emptyStateCard
                        }

                        noteCard
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
        .onChange(of: amountText) {
            handleInputChange()
        }
        .onChange(of: fromCurrency) {
            handleInputChange()
        }
        .onChange(of: toCurrency) {
            handleInputChange()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("محول العملات")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("حوّل بين العملات بأسعار محدثة")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func inputsSection(proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .center, spacing: 14) {
            amountInputCard
            currencyInputCard(title: "من عملة", icon: "arrow.up.circle.fill", tint: Color.blue, background: sourceCardBackground, selection: $fromCurrency)

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                    swapButtonPressed = true
                    swapCurrencies()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        swapButtonPressed = false
                    }
                }
                
                if parsedAmount != nil {
                    Task {
                        await calculateAndScroll(proxy: proxy)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.buttonOrange)
                    .frame(width: 52, height: 52)
                    .background(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.12 : 0.18))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.18 : 0.28), lineWidth: 1)
                    )
                    .shadow(color: AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.16 : 0.08), radius: 10, x: 0, y: 5)
                    .scaleEffect(swapButtonPressed ? 0.92 : 1.0)
            }
            .buttonStyle(.plain)

            currencyInputCard(title: "إلى عملة", icon: "arrow.down.circle.fill", tint: Color.green, background: targetCardBackground, selection: $toCurrency)

            HStack(spacing: 12) {
                Button {
                    Task {
                        await calculateAndScroll(proxy: proxy, forceRefresh: true)
                    }
                } label: {
                    secondaryButtonLabel(icon: "arrow.clockwise", title: "تحديث")
                }
                .buttonStyle(.plain)
                .disabled(isLoading)

                Button {
                    Task {
                        await calculateAndScroll(proxy: proxy)
                    }
                } label: {
                    primaryButtonLabel(title: "احسب التحويل")
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
            }
        }
    }

    private var amountInputCard: some View {
        VStack(alignment: .center, spacing: 10) {
            cardTitle(icon: "banknote.fill", title: "المبلغ", tint: AppTheme.buttonOrange)

            TextField("100", text: $amountText)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .amount)
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .tint(AppTheme.buttonOrange)
                .padding(.vertical, 13)
                .padding(.horizontal, 14)
                .background(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.08 : 0.14))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
                )
        }
        .padding(18)
        .background(amountCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func currencyInputCard(
        title: String,
        icon: String,
        tint: Color,
        background: Color,
        selection: Binding<CurrencyInfo>
    ) -> some View {
        VStack(alignment: .center, spacing: 10) {
            cardTitle(icon: icon, title: title, tint: tint)

            Menu {
                Section("الأكثر استخدامًا") {
                    ForEach(CurrencyInfo.commonCurrencies) { currency in
                        Button {
                            selection.wrappedValue = currency
                        } label: {
                            currencyRowText(currency)
                        }
                    }
                }

                Section("عملات أخرى") {
                    ForEach(CurrencyInfo.remainingCurrencies) { currency in
                        Button {
                            selection.wrappedValue = currency
                        } label: {
                            currencyRowText(currency)
                        }
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    VStack(alignment: .center, spacing: 5) {
                        Text(selection.wrappedValue.displayTitle)
                            .font(.system(size: 19, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.primaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(selection.wrappedValue.arabicName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(tint)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(tint.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func currencyRowText(_ currency: CurrencyInfo) -> Text {
        Text("\(currency.flag)  \(currency.code) — \(currency.arabicName)")
    }

    private func cardTitle(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)

            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(tint)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .multilineTextAlignment(.center)
    }

    private func primaryButtonLabel(title: String) -> some View {
        Text(title)
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(AppTheme.buttonOrange)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.25 : 0.16), radius: 12, x: 0, y: 6)
    }

    private func secondaryButtonLabel(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))

            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .foregroundColor(AppTheme.primaryText)
        .frame(width: 104)
        .frame(height: 54)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var statusSection: some View {
        if isLoading {
            statusCard(text: "جاري تحديث سعر الصرف...", icon: "clock.arrow.circlepath", tint: Color.blue, background: sourceCardBackground)
        } else if let cacheWarning {
            statusCard(text: cacheWarning, icon: "externaldrive.fill.badge.checkmark", tint: AppTheme.buttonOrange, background: noteCardBackground)
        } else if let errorMessage {
            statusCard(text: errorMessage, icon: "exclamationmark.triangle.fill", tint: Color.red, background: errorCardBackground)
        }
    }

    private func statusCard(text: String, icon: String, tint: Color, background: Color) -> some View {
        HStack(spacing: 10) {
            Text(text)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Image(systemName: icon)
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(tint)
        }
        .padding(15)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
    }

    private func resultCard(_ result: CurrencyConversionResult) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text("العملة الهدف")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("\(formatMoney(result.convertedAmount))")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.buttonOrange)
                .minimumScaleFactor(0.45)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(result.to.code)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .environment(\.layoutDirection, .leftToRight)

            Text(result.to.arabicName)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 208)
        .background(resultCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.indigo.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }
    
    private func exchangeRateCard(_ result: CurrencyConversionResult) -> some View {
        compactInfoCard(
            title: "سعر الصرف الحالي",
            value: rateBadgeText(result),
            icon: "chart.line.uptrend.xyaxis",
            tint: Color.blue,
            forceLeftToRight: true
        )
    }
    
    private func lastUpdateCard(_ result: CurrencyConversionResult) -> some View {
        compactInfoCard(
            title: "آخر تحديث",
            value: result.updateText,
            icon: "clock.fill",
            tint: Color.green,
            forceLeftToRight: false
        )
    }
    
    private func compactInfoCard(
        title: String,
        value: String,
        icon: String,
        tint: Color,
        forceLeftToRight: Bool
    ) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(tint)
            
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .center)
                .environment(\.layoutDirection, forceLeftToRight ? .leftToRight : .rightToLeft)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(tint.opacity(colorScheme == .light ? 0.075 : 0.13))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 7, x: 0, y: 3)
    }

    private func detailsCard(_ result: CurrencyConversionResult) -> some View {
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
                spacing: 10
            ) {
                CurrencySummaryChip(title: "المبلغ الأصلي", value: "\(formatMoney(result.amount)) \(result.from.code)", forceLeftToRight: true)
                CurrencySummaryChip(title: "من عملة", value: "\(result.from.code) — \(result.from.arabicName)")
                CurrencySummaryChip(title: "إلى عملة", value: "\(result.to.code) — \(result.to.arabicName)")
                CurrencySummaryChip(title: "مصدر الأسعار", value: "ExchangeRate-API")
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

    private func shareSection(_ result: CurrencyConversionResult) -> some View {
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
            Image(systemName: "coloncurrencysign.circle")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 58, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.12 : 0.20))
                )

            Text("جاهز للتحويل")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("أدخل المبلغ واختر العملات ثم اضغط احسب التحويل.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(detailsCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
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

            Text("أسعار العملات تقريبية وقد تختلف عن أسعار البنوك ومزودي خدمات التحويل.")
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

    private var parsedAmount: Double? {
        let normalized = amountText
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "٫", with: ".")
            .replacingOccurrences(of: "٬", with: "")
        return Double(normalized)
    }

    private func clearTransientState(resetCalculationState: Bool = true) {
        result = nil
        errorMessage = nil
        cacheWarning = nil
        if resetCalculationState {
            hasCalculatedOnce = false
        }
    }
    
    private func handleInputChange() {
        errorMessage = nil
        cacheWarning = nil
        
        guard hasCalculatedOnce else {
            result = nil
            return
        }
        
        Task {
            await recalculateSilently()
        }
    }

    private func swapCurrencies() {
        let shouldAutoRefresh = hasCalculatedOnce
        let oldFrom = fromCurrency
        fromCurrency = toCurrency
        toCurrency = oldFrom
        hasCalculatedOnce = shouldAutoRefresh
    }

    @MainActor
    private func calculateAndScroll(proxy: ScrollViewProxy, forceRefresh: Bool = false) async {
        dismissKeyboard()
        errorMessage = nil
        cacheWarning = nil

        guard let amount = parsedAmount, amount >= 0 else {
            result = nil
            errorMessage = "أدخل مبلغًا صحيحًا للتحويل."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let conversion = try await convert(amount: amount, from: fromCurrency, to: toCurrency, forceRefresh: forceRefresh)
            result = conversion
            hasCalculatedOnce = true
            cacheWarning = conversion.isCached ? "تم عرض آخر سعر محفوظ." : nil
            scrollToResult(proxy)
        } catch {
            if let cached = cachedResult(amount: amount, from: fromCurrency, to: toCurrency) {
                result = cached
                hasCalculatedOnce = true
                cacheWarning = "تم عرض آخر سعر محفوظ."
                scrollToResult(proxy)
            } else {
                result = nil
                errorMessage = "تعذر تحديث أسعار العملات، تحقق من الاتصال بالإنترنت."
            }
        }
    }
    
    @MainActor
    private func recalculateSilently() async {
        guard let amount = parsedAmount, amount >= 0 else {
            result = nil
            errorMessage = "أدخل مبلغًا صحيحًا للتحويل."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let conversion = try await convert(amount: amount, from: fromCurrency, to: toCurrency, forceRefresh: false)
            result = conversion
            cacheWarning = conversion.isCached ? "تم عرض آخر سعر محفوظ." : nil
        } catch {
            if let cached = cachedResult(amount: amount, from: fromCurrency, to: toCurrency) {
                result = cached
                cacheWarning = "تم عرض آخر سعر محفوظ."
            } else {
                result = nil
                errorMessage = "تعذر تحديث أسعار العملات، تحقق من الاتصال بالإنترنت."
            }
        }
    }

    private func scrollToResult(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                proxy.scrollTo("currencyResultSection", anchor: .center)
            }
        }
    }

    private func convert(amount: Double, from: CurrencyInfo, to: CurrencyInfo, forceRefresh: Bool) async throws -> CurrencyConversionResult {
        if from == to {
            return CurrencyConversionResult(
                amount: amount,
                convertedAmount: amount,
                rate: 1,
                from: from,
                to: to,
                updateText: localUpdateText(),
                isCached: false
            )
        }

        if !forceRefresh, let cached = cachedResult(amount: amount, from: from, to: to), cached.isFreshEnough {
            return cached
        }

        let response = try await fetchLatestRates(baseCode: from.code)

        guard let rate = response.rates[to.code], rate > 0 else {
            throw CurrencyConverterError.rateNotFound
        }

        let updateText = formattedAPIDate(response.timeLastUpdateUTC) ?? localUpdateText()
        let conversion = CurrencyConversionResult(
            amount: amount,
            convertedAmount: amount * rate,
            rate: rate,
            from: from,
            to: to,
            updateText: updateText,
            isCached: false
        )

        saveCache(rate: rate, updateText: updateText, from: from, to: to)
        return conversion
    }

    private func fetchLatestRates(baseCode: String) async throws -> ExchangeRateAPIResponse {
        guard let url = URL(string: "https://open.er-api.com/v6/latest/\(baseCode)") else {
            throw CurrencyConverterError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CurrencyConverterError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(ExchangeRateAPIResponse.self, from: data)

        guard decoded.result == "success" else {
            throw CurrencyConverterError.invalidResponse
        }

        return decoded
    }

    private func saveCache(rate: Double, updateText: String, from: CurrencyInfo, to: CurrencyInfo) {
        let cached = CurrencyConversionCache(
            fromCode: from.code,
            toCode: to.code,
            rate: rate,
            updateText: updateText,
            fetchedAt: Date()
        )

        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: cacheKey(from: from, to: to))
        }
    }

    private func cachedResult(amount: Double, from: CurrencyInfo, to: CurrencyInfo) -> CurrencyConversionResult? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey(from: from, to: to)),
              let cached = try? JSONDecoder().decode(CurrencyConversionCache.self, from: data),
              cached.fromCode == from.code,
              cached.toCode == to.code else {
            return nil
        }

        return CurrencyConversionResult(
            amount: amount,
            convertedAmount: amount * cached.rate,
            rate: cached.rate,
            from: from,
            to: to,
            updateText: cached.updateText,
            isCached: true,
            fetchedAt: cached.fetchedAt
        )
    }

    private func cacheKey(from: CurrencyInfo, to: CurrencyInfo) -> String {
        "CurrencyConverterCache.\(from.code).\(to.code)"
    }

    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func rateBadgeText(_ result: CurrencyConversionResult) -> String {
        "1 \(result.from.code) = \(formatRate(result.rate)) \(result.to.code)"
    }

    private func formatMoney(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatRate(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = value < 0.01 ? 8 : 6
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func localUpdateText() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    private func formattedAPIDate(_ value: String?) -> String? {
        guard let value, !value.isEmpty else {
            return nil
        }

        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"

        guard let date = parser.date(from: value) else {
            return value
        }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func shareText(for result: CurrencyConversionResult) -> String {
        """
        محول العملات - احسبها

        المبلغ الأصلي:
        \(formatMoney(result.amount)) \(result.from.code)

        العملة المحولة:
        \(result.to.code) - \(result.to.arabicName)

        سعر الصرف:
        \(rateBadgeText(result))

        النتيجة:
        \(formatMoney(result.convertedAmount)) \(result.to.code)

        آخر تحديث:
        \(result.updateText)

        مصدر الأسعار:
        ExchangeRate-API
        """
    }

    @MainActor
    private func resultCardImage(for result: CurrencyConversionResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "محول العملات",
            rows: [
                ResultCardRow(title: "المبلغ الأصلي", value: "\(formatMoney(result.amount)) \(result.from.code)"),
                ResultCardRow(title: "من عملة", value: "\(result.from.code) - \(result.from.arabicName)"),
                ResultCardRow(title: "إلى عملة", value: "\(result.to.code) - \(result.to.arabicName)"),
                ResultCardRow(title: "سعر الصرف", value: rateBadgeText(result)),
                ResultCardRow(title: "النتيجة", value: "\(formatMoney(result.convertedAmount)) \(result.to.code)", valueColor: AppTheme.buttonOrange),
                ResultCardRow(title: "آخر تحديث", value: result.updateText),
                ResultCardRow(title: "المصدر", value: "ExchangeRate-API")
            ],
            note: "أسعار العملات تقريبية وقد تختلف حسب مزود الخدمة."
        )
    }
}

private struct CurrencyInfo: Identifiable, Hashable, Codable {
    let code: String
    let arabicName: String
    let flag: String

    var id: String { code }

    var displayTitle: String {
        "\(flag) \(code)"
    }

    static let sar = CurrencyInfo(code: "SAR", arabicName: "الريال السعودي", flag: "🇸🇦")
    static let usd = CurrencyInfo(code: "USD", arabicName: "الدولار الأمريكي", flag: "🇺🇸")

    static let commonCurrencies: [CurrencyInfo] = [
        .sar,
        .usd,
        CurrencyInfo(code: "EUR", arabicName: "اليورو", flag: "🇪🇺"),
        CurrencyInfo(code: "GBP", arabicName: "الجنيه الإسترليني", flag: "🇬🇧"),
        CurrencyInfo(code: "AED", arabicName: "الدرهم الإماراتي", flag: "🇦🇪"),
        CurrencyInfo(code: "KWD", arabicName: "الدينار الكويتي", flag: "🇰🇼"),
        CurrencyInfo(code: "QAR", arabicName: "الريال القطري", flag: "🇶🇦"),
        CurrencyInfo(code: "BHD", arabicName: "الدينار البحريني", flag: "🇧🇭"),
        CurrencyInfo(code: "OMR", arabicName: "الريال العماني", flag: "🇴🇲"),
        CurrencyInfo(code: "EGP", arabicName: "الجنيه المصري", flag: "🇪🇬"),
        CurrencyInfo(code: "JPY", arabicName: "الين الياباني", flag: "🇯🇵"),
        CurrencyInfo(code: "CNY", arabicName: "اليوان الصيني", flag: "🇨🇳"),
        CurrencyInfo(code: "TRY", arabicName: "الليرة التركية", flag: "🇹🇷"),
        CurrencyInfo(code: "INR", arabicName: "الروبية الهندية", flag: "🇮🇳")
    ]

    static let remainingCurrencies: [CurrencyInfo] = [
        CurrencyInfo(code: "AUD", arabicName: "الدولار الأسترالي", flag: "🇦🇺"),
        CurrencyInfo(code: "CAD", arabicName: "الدولار الكندي", flag: "🇨🇦"),
        CurrencyInfo(code: "CHF", arabicName: "الفرنك السويسري", flag: "🇨🇭"),
        CurrencyInfo(code: "HKD", arabicName: "دولار هونغ كونغ", flag: "🇭🇰"),
        CurrencyInfo(code: "SGD", arabicName: "الدولار السنغافوري", flag: "🇸🇬"),
        CurrencyInfo(code: "MYR", arabicName: "الرينغيت الماليزي", flag: "🇲🇾"),
        CurrencyInfo(code: "IDR", arabicName: "الروبية الإندونيسية", flag: "🇮🇩"),
        CurrencyInfo(code: "PKR", arabicName: "الروبية الباكستانية", flag: "🇵🇰"),
        CurrencyInfo(code: "BDT", arabicName: "التاكا البنغلاديشي", flag: "🇧🇩"),
        CurrencyInfo(code: "PHP", arabicName: "البيزو الفلبيني", flag: "🇵🇭"),
        CurrencyInfo(code: "THB", arabicName: "البات التايلندي", flag: "🇹🇭"),
        CurrencyInfo(code: "KRW", arabicName: "الوون الكوري", flag: "🇰🇷"),
        CurrencyInfo(code: "NZD", arabicName: "الدولار النيوزيلندي", flag: "🇳🇿"),
        CurrencyInfo(code: "ZAR", arabicName: "الراند الجنوب أفريقي", flag: "🇿🇦"),
        CurrencyInfo(code: "MAD", arabicName: "الدرهم المغربي", flag: "🇲🇦"),
        CurrencyInfo(code: "TND", arabicName: "الدينار التونسي", flag: "🇹🇳"),
        CurrencyInfo(code: "DZD", arabicName: "الدينار الجزائري", flag: "🇩🇿"),
        CurrencyInfo(code: "JOD", arabicName: "الدينار الأردني", flag: "🇯🇴"),
        CurrencyInfo(code: "ILS", arabicName: "الشيكل", flag: "🇮🇱"),
        CurrencyInfo(code: "SEK", arabicName: "الكرونة السويدية", flag: "🇸🇪"),
        CurrencyInfo(code: "NOK", arabicName: "الكرونة النرويجية", flag: "🇳🇴"),
        CurrencyInfo(code: "DKK", arabicName: "الكرونة الدنماركية", flag: "🇩🇰"),
        CurrencyInfo(code: "PLN", arabicName: "الزلوتي البولندي", flag: "🇵🇱"),
        CurrencyInfo(code: "CZK", arabicName: "الكورونا التشيكية", flag: "🇨🇿"),
        CurrencyInfo(code: "HUF", arabicName: "الفورنت المجري", flag: "🇭🇺"),
        CurrencyInfo(code: "BRL", arabicName: "الريال البرازيلي", flag: "🇧🇷"),
        CurrencyInfo(code: "MXN", arabicName: "البيزو المكسيكي", flag: "🇲🇽")
    ]
}

private struct CurrencyConversionResult {
    let amount: Double
    let convertedAmount: Double
    let rate: Double
    let from: CurrencyInfo
    let to: CurrencyInfo
    let updateText: String
    let isCached: Bool
    var fetchedAt: Date = Date()

    var isFreshEnough: Bool {
        Date().timeIntervalSince(fetchedAt) < 60 * 60 * 12
    }
}

private struct CurrencyConversionCache: Codable {
    let fromCode: String
    let toCode: String
    let rate: Double
    let updateText: String
    let fetchedAt: Date
}

private struct ExchangeRateAPIResponse: Decodable {
    let result: String
    let timeLastUpdateUTC: String?
    let rates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case result
        case timeLastUpdateUTC = "time_last_update_utc"
        case rates
        case conversionRates = "conversion_rates"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        result = try container.decode(String.self, forKey: .result)
        timeLastUpdateUTC = try container.decodeIfPresent(String.self, forKey: .timeLastUpdateUTC)
        rates = try container.decodeIfPresent([String: Double].self, forKey: .rates)
            ?? container.decodeIfPresent([String: Double].self, forKey: .conversionRates)
            ?? [:]
    }
}

private enum CurrencyConverterError: Error {
    case invalidURL
    case invalidResponse
    case rateNotFound
}

private struct CurrencySummaryChip: View {
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
        CurrencyConverterView()
    }
}
