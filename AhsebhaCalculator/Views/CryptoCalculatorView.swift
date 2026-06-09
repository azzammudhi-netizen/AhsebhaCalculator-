import SwiftUI
import UIKit

struct CryptoCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: Field?

    @State private var amountText = "1000"
    @State private var calculationMode: CryptoCalculationMode = .sarToCrypto
    @State private var selectedAsset: CryptoAsset = .bitcoin
    @State private var prices: CryptoPrices?
    @State private var result: CryptoCalculationResult?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var cacheWarning: String?
    @State private var hasCalculatedOnce = false
    @State private var recalculationTask: Task<Void, Never>?

    private enum Field {
        case amount
    }

    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }

    private var cardBackground: Color {
        colorScheme == .light ? Color(hex: "#FBFCFF") : AppTheme.secondaryBackground
    }

    private var inputCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF8EF") : AppTheme.secondaryBackground
    }

    private var selectorCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F6F3FF") : AppTheme.secondaryBackground
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
                        livePricesSection
                        modeSelectorCard
                        inputCard
                        cryptoSelectorCard
                        if calculationMode == .cryptoToSAR {
                            outputTargetCard
                        }
                        actionButtons(proxy: proxy)
                        statusSection

                        if let result {
                            resultCard(result)
                                .id("cryptoResultSection")
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
        .task {
            await fetchPrices()
        }
        .onChange(of: amountText) {
            handleInputChange()
        }
        .onChange(of: selectedAsset) {
            handleInputChange()
        }
        .onChange(of: calculationMode) {
            handleInputChange()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("حاسبة العملات الرقمية")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("تابع أسعار العملات الرقمية واحسب قيمتها بالريال")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var livePricesSection: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("الأسعار المباشرة")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(CryptoAsset.allCases) { asset in
                    cryptoPriceCard(asset: asset, price: prices?.price(for: asset))
                }
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

    private func cryptoPriceCard(asset: CryptoAsset, price: CryptoAssetPrice?) -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 6) {
                Text(asset.symbol)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(asset.color)
                    .environment(\.layoutDirection, .leftToRight)

                Image(systemName: asset.icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(asset.color)
            }

            Text(asset.name)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(price.map { "\(formatSAR($0.sar, maximumFractionDigits: asset.currencyFractionDigits)) ر.س" } ?? "—")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .multilineTextAlignment(.center)

            Text(price.map { formatChange($0.change24h) } ?? "—")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(changeColor(price?.change24h))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 96)
        .background(asset.color.opacity(colorScheme == .light ? 0.075 : 0.13))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(asset.color.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
    }

    private var modeSelectorCard: some View {
        HStack(spacing: 8) {
            ForEach(CryptoCalculationMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        calculationMode = mode
                    }
                } label: {
                    Text(mode.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(calculationMode == mode ? .black : AppTheme.primaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(calculationMode == mode ? AppTheme.buttonOrange : AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.08 : 0.14))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.buttonOrange.opacity(calculationMode == mode ? 0.30 : 0.14), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(noteCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 8, x: 0, y: 4)
    }

    private var inputCard: some View {
        VStack(alignment: .center, spacing: 10) {
            sectionTitle(icon: calculationMode.inputIcon, title: calculationMode.inputTitle, tint: AppTheme.buttonOrange)

            TextField(calculationMode.placeholder, text: $amountText)
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

            if calculationMode == .cryptoToSAR {
                Text(selectedAsset.symbol)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(selectedAsset.color)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 14)
                    .background(selectedAsset.color.opacity(colorScheme == .light ? 0.10 : 0.18))
                    .clipShape(Capsule())
                    .environment(\.layoutDirection, .leftToRight)
            }
        }
        .padding(18)
        .background(inputCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private var cryptoSelectorCard: some View {
        VStack(alignment: .center, spacing: 10) {
            sectionTitle(icon: selectedAsset.icon, title: "العملة المختارة", tint: selectedAsset.color)

            Menu {
                ForEach(CryptoAsset.allCases) { asset in
                    Button {
                        selectedAsset = asset
                    } label: {
                        Text("\(asset.symbol) — \(asset.name)")
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    VStack(alignment: .center, spacing: 5) {
                        Text(selectedAsset.symbol)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.primaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .environment(\.layoutDirection, .leftToRight)

                        Text(selectedAsset.name)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.secondaryText)
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(selectedAsset.color)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .background(selectedAsset.color.opacity(colorScheme == .light ? 0.08 : 0.14))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(selectedAsset.color.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(selectorCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(selectedAsset.color.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private var outputTargetCard: some View {
        VStack(alignment: .center, spacing: 8) {
            sectionTitle(icon: "arrow.down.circle.fill", title: "النتيجة إلى", tint: Color.green)

            VStack(alignment: .center, spacing: 4) {
                Text("SAR")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .environment(\.layoutDirection, .leftToRight)

                Text("الريال السعودي")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(colorScheme == .light ? 0.08 : 0.14))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.green.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
            )
        }
        .padding(16)
        .background(detailsCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.green.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 8, x: 0, y: 4)
    }

    private func actionButtons(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    await fetchPrices()
                    if hasCalculatedOnce {
                        calculate(scrollProxy: proxy)
                    }
                }
            } label: {
                secondaryButtonLabel(icon: "arrow.clockwise", title: "تحديث الأسعار")
            }
            .buttonStyle(.plain)
            .disabled(isLoading)

            Button {
                calculate(scrollProxy: proxy)
            } label: {
                primaryButtonLabel(title: calculationMode.buttonTitle)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
    }

    private func sectionTitle(icon: String, title: String, tint: Color) -> some View {
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
            Text(title)
        }
        .font(.system(size: 15, weight: .bold, design: .rounded))
        .foregroundColor(AppTheme.primaryText)
        .frame(width: 126)
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
            statusCard(text: "جاري تحديث أسعار العملات الرقمية...", icon: "clock.arrow.circlepath", tint: Color.blue, background: selectorCardBackground)
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

    private func resultCard(_ result: CryptoCalculationResult) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text(result.mode.resultTitle)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(resultNumberText(result))
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(result.asset.color)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(resultUnitText(result))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, .leftToRight)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .background(resultCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(result.asset.color.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func lastUpdateCard(_ result: CryptoCalculationResult) -> some View {
        VStack(alignment: .center, spacing: 6) {
            Text("آخر تحديث")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            Text(result.updateText)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.70)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(selectorCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }

    private func detailsCard(_ result: CryptoCalculationResult) -> some View {
        VStack(alignment: .center, spacing: 14) {
            Text("تفاصيل الحساب")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(detailRows(for: result), id: \.title) { row in
                    CryptoSummaryChip(title: row.title, value: row.value, isHighlighted: row.isHighlighted, forceLeftToRight: row.forceLeftToRight)
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

    private func shareSection(_ result: CryptoCalculationResult) -> some View {
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
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 58, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.12 : 0.20))
                )

            Text("جاهز لحساب العملات الرقمية")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)

            Text(calculationMode.emptyStateText)
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

    private var noteCard: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)

            Text("ملاحظة")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)

            Text("أسعار العملات الرقمية متغيرة بشكل كبير وهي استرشادية وليست توصية مالية.")
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

    private var parsedInput: Double? {
        let normalized = amountText
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: "٫", with: ".")
            .replacingOccurrences(of: "٬", with: "")
        return Double(normalized)
    }

    private func handleInputChange() {
        errorMessage = nil
        cacheWarning = nil

        guard hasCalculatedOnce else {
            result = nil
            return
        }

        recalculationTask?.cancel()
        recalculationTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                calculate(scrollProxy: nil, dismissKeyboard: false)
            }
        }
    }

    @MainActor
    private func fetchPrices() async {
        isLoading = true
        errorMessage = nil
        cacheWarning = nil
        defer { isLoading = false }

        do {
            let fetchedPrices = try await requestPrices()
            prices = fetchedPrices
            saveCache(fetchedPrices)
        } catch {
            #if DEBUG
            print("CoinGecko fetch error:", error)
            #endif

            if let cached = cachedPrices() {
                prices = cached
                cacheWarning = "تم عرض آخر سعر محفوظ."
            } else {
                errorMessage = "تعذر تحديث أسعار العملات الرقمية، تحقق من الاتصال بالإنترنت."
            }
        }
    }

    private func requestPrices() async throws -> CryptoPrices {
        var components = URLComponents(string: "https://api.coingecko.com/api/v3/simple/price")
        components?.queryItems = [
            URLQueryItem(name: "ids", value: CryptoAsset.allCases.map(\.id).joined(separator: ",")),
            URLQueryItem(name: "vs_currencies", value: "sar,usd"),
            URLQueryItem(name: "include_24hr_change", value: "true"),
            URLQueryItem(name: "include_last_updated_at", value: "true")
        ]

        guard let url = components?.url else {
            throw CryptoCalculatorError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CryptoCalculatorError.invalidResponse
        }

        let decoded = try JSONDecoder().decode([String: CoinGeckoPriceResponse].self, from: data)
        var mappedPrices: [String: CryptoAssetPrice] = [:]
        var newestUpdate = 0

        for asset in CryptoAsset.allCases {
            guard let response = decoded[asset.id],
                  let sar = response.sar,
                  sar > 0 else {
                continue
            }

            let updateTimestamp = response.lastUpdatedAt ?? Int(Date().timeIntervalSince1970)
            newestUpdate = max(newestUpdate, updateTimestamp)
            mappedPrices[asset.id] = CryptoAssetPrice(
                sar: sar,
                usd: response.usd,
                change24h: response.sar24hChange,
                lastUpdatedAt: updateTimestamp
            )
        }

        guard !mappedPrices.isEmpty else {
            throw CryptoCalculatorError.rateNotFound
        }

        let updateDate = newestUpdate > 0 ? Date(timeIntervalSince1970: TimeInterval(newestUpdate)) : Date()
        return CryptoPrices(
            prices: mappedPrices,
            updateText: formatGregorianDate(updateDate),
            fetchedAt: Date()
        )
    }

    private func calculate(scrollProxy: ScrollViewProxy?, dismissKeyboard: Bool = true) {
        if dismissKeyboard {
            recalculationTask?.cancel()
            focusedField = nil
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        guard let inputValue = parsedInput, inputValue > 0 else {
            result = nil
            errorMessage = "أدخل قيمة صحيحة لإتمام الحساب."
            return
        }

        guard let selectedPrice = prices?.price(for: selectedAsset), selectedPrice.sar > 0 else {
            errorMessage = "تعذر قراءة السعر الحالي للعملة المختارة."
            return
        }

        let outputValue: Double
        switch calculationMode {
        case .sarToCrypto:
            outputValue = inputValue / selectedPrice.sar
        case .cryptoToSAR:
            outputValue = inputValue * selectedPrice.sar
        }

        let calculation = CryptoCalculationResult(
            mode: calculationMode,
            inputValue: inputValue,
            asset: selectedAsset,
            price: selectedPrice,
            outputValue: outputValue,
            updateText: prices?.updateText ?? formatGregorianDate(Date())
        )

        result = calculation
        hasCalculatedOnce = true
        errorMessage = nil

        if let scrollProxy {
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    scrollProxy.scrollTo("cryptoResultSection", anchor: .center)
                }
            }
        }
    }

    private func saveCache(_ prices: CryptoPrices) {
        if let data = try? JSONEncoder().encode(prices) {
            UserDefaults.standard.set(data, forKey: "CryptoCalculator.Prices")
        }
    }

    private func cachedPrices() -> CryptoPrices? {
        guard let data = UserDefaults.standard.data(forKey: "CryptoCalculator.Prices") else {
            return nil
        }

        return try? JSONDecoder().decode(CryptoPrices.self, from: data)
    }

    private func formatSAR(_ value: Double, maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatCrypto(_ value: Double, asset: CryptoAsset) -> String {
        "\(formatCryptoNumber(value, asset: asset)) \(asset.symbol)"
    }

    private func formatCryptoNumber(_ value: Double, asset: CryptoAsset) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = asset.cryptoFractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatInputCrypto(_ value: Double, asset: CryptoAsset) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = asset.cryptoFractionDigits
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formatted) \(asset.symbol)"
    }

    private func formatChange(_ value: Double?) -> String {
        guard let value else {
            return "—"
        }

        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(formatSAR(value, maximumFractionDigits: 2))%"
    }

    private func changeColor(_ value: Double?) -> Color {
        guard let value else {
            return AppTheme.secondaryText
        }

        return value >= 0 ? .green : .red
    }

    private func formatGregorianDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func primaryResultValue(_ result: CryptoCalculationResult) -> String {
        switch result.mode {
        case .sarToCrypto:
            return formatCrypto(result.outputValue, asset: result.asset)
        case .cryptoToSAR:
            return "\(formatSAR(result.outputValue, maximumFractionDigits: 2)) ر.س"
        }
    }

    private func resultNumberText(_ result: CryptoCalculationResult) -> String {
        switch result.mode {
        case .sarToCrypto:
            return formatCryptoNumber(result.outputValue, asset: result.asset)
        case .cryptoToSAR:
            return formatSAR(result.outputValue, maximumFractionDigits: 2)
        }
    }

    private func resultUnitText(_ result: CryptoCalculationResult) -> String {
        switch result.mode {
        case .sarToCrypto:
            return result.asset.displayName
        case .cryptoToSAR:
            return "ر.س"
        }
    }

    private func shareInputTitle(_ result: CryptoCalculationResult) -> String {
        switch result.mode {
        case .sarToCrypto:
            return "المبلغ المدخل"
        case .cryptoToSAR:
            return "الكمية المدخلة"
        }
    }

    private func shareInputValue(_ result: CryptoCalculationResult) -> String {
        switch result.mode {
        case .sarToCrypto:
            return "\(formatSAR(result.inputValue, maximumFractionDigits: 2)) ر.س"
        case .cryptoToSAR:
            return formatInputCrypto(result.inputValue, asset: result.asset)
        }
    }

    private func shareCardInputValue(_ result: CryptoCalculationResult) -> String {
        switch result.mode {
        case .sarToCrypto:
            return "\(formatSAR(result.inputValue, maximumFractionDigits: 2)) ر.س"
        case .cryptoToSAR:
            return shareCardCryptoValue(result.inputValue, asset: result.asset)
        }
    }

    private func shareCardResultValue(_ result: CryptoCalculationResult) -> String {
        switch result.mode {
        case .sarToCrypto:
            return shareCardCryptoValue(result.outputValue, asset: result.asset)
        case .cryptoToSAR:
            return "\(formatSAR(result.outputValue, maximumFractionDigits: 2)) ر.س"
        }
    }

    private func shareCardCryptoValue(_ value: Double, asset: CryptoAsset) -> String {
        "\(formatCryptoNumber(value, asset: asset))\n\(asset.symbol)"
    }

    private func detailRows(for result: CryptoCalculationResult) -> [CryptoDetailRow] {
        switch result.mode {
        case .sarToCrypto:
            return [
                CryptoDetailRow(title: "المبلغ بالريال", value: "\(formatSAR(result.inputValue, maximumFractionDigits: 2)) ر.س"),
                CryptoDetailRow(title: "العملة المختارة", value: result.asset.displayName, forceLeftToRight: true),
                CryptoDetailRow(title: "سعر العملة", value: "\(formatSAR(result.price.sar, maximumFractionDigits: result.asset.currencyFractionDigits)) ر.س", isHighlighted: true),
                CryptoDetailRow(title: "الكمية الناتجة", value: formatCrypto(result.outputValue, asset: result.asset), isHighlighted: true, forceLeftToRight: true),
                CryptoDetailRow(title: "مصدر الأسعار", value: "CoinGecko", forceLeftToRight: true)
            ]
        case .cryptoToSAR:
            return [
                CryptoDetailRow(title: "الكمية المدخلة", value: formatInputCrypto(result.inputValue, asset: result.asset), forceLeftToRight: true),
                CryptoDetailRow(title: "العملة المختارة", value: result.asset.displayName, forceLeftToRight: true),
                CryptoDetailRow(title: "سعر العملة", value: "\(formatSAR(result.price.sar, maximumFractionDigits: result.asset.currencyFractionDigits)) ر.س", isHighlighted: true),
                CryptoDetailRow(title: "القيمة التقديرية", value: "\(formatSAR(result.outputValue, maximumFractionDigits: 2)) ر.س", isHighlighted: true),
                CryptoDetailRow(title: "مصدر الأسعار", value: "CoinGecko", forceLeftToRight: true)
            ]
        }
    }

    private func shareText(for result: CryptoCalculationResult) -> String {
        let summary: String
        switch result.mode {
        case .sarToCrypto:
            summary = "بمبلغ \(formatSAR(result.inputValue, maximumFractionDigits: 2)) ر.س يمكنك شراء \(formatCrypto(result.outputValue, asset: result.asset))."
        case .cryptoToSAR:
            summary = "\(formatInputCrypto(result.inputValue, asset: result.asset)) تساوي تقريبًا \(formatSAR(result.outputValue, maximumFractionDigits: 2)) ر.س."
        }

        return """
        حاسبة العملات الرقمية - احسبها

        نوع الحساب:
        \(result.mode.title)

        \(shareInputTitle(result)):
        \(shareInputValue(result))

        العملة المختارة:
        \(result.asset.displayName)

        سعر العملة:
        \(formatSAR(result.price.sar, maximumFractionDigits: result.asset.currencyFractionDigits)) ر.س

        النتيجة:
        \(primaryResultValue(result))

        \(summary)

        آخر تحديث:
        \(result.updateText)

        مصدر الأسعار:
        CoinGecko
        """
    }

    @MainActor
    private func resultCardImage(for result: CryptoCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة العملات الرقمية",
            rows: [
                ResultCardRow(title: "نوع الحساب", value: result.mode.title),
                ResultCardRow(title: shareInputTitle(result), value: shareCardInputValue(result)),
                ResultCardRow(title: "العملة المختارة", value: result.asset.displayName),
                ResultCardRow(title: "سعر العملة", value: "\(formatSAR(result.price.sar, maximumFractionDigits: result.asset.currencyFractionDigits)) ر.س"),
                ResultCardRow(title: result.mode.resultTitle, value: shareCardResultValue(result), valueColor: AppTheme.buttonOrange),
                ResultCardRow(title: "آخر تحديث", value: result.updateText),
                ResultCardRow(title: "المصدر", value: "CoinGecko")
            ],
            note: "الأسعار استرشادية ومتغيرة وليست توصية مالية."
        )
    }
}

private enum CryptoCalculationMode: String, CaseIterable, Identifiable {
    case sarToCrypto
    case cryptoToSAR

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sarToCrypto: return "من الريال إلى العملة الرقمية"
        case .cryptoToSAR: return "من العملة الرقمية إلى الريال"
        }
    }

    var inputTitle: String {
        switch self {
        case .sarToCrypto: return "المبلغ بالريال"
        case .cryptoToSAR: return "كمية العملة الرقمية"
        }
    }

    var inputIcon: String {
        switch self {
        case .sarToCrypto: return "banknote.fill"
        case .cryptoToSAR: return "bitcoinsign.circle.fill"
        }
    }

    var placeholder: String {
        switch self {
        case .sarToCrypto: return "1000"
        case .cryptoToSAR: return "0.5"
        }
    }

    var buttonTitle: String {
        switch self {
        case .sarToCrypto: return "احسب الكمية"
        case .cryptoToSAR: return "احسب القيمة"
        }
    }

    var resultTitle: String {
        switch self {
        case .sarToCrypto: return "الكمية التي يمكن شراؤها"
        case .cryptoToSAR: return "القيمة التقديرية"
        }
    }

    var emptyStateText: String {
        switch self {
        case .sarToCrypto:
            return "أدخل المبلغ واختر العملة الرقمية ثم اضغط احسب الكمية."
        case .cryptoToSAR:
            return "أدخل كمية العملة الرقمية ثم اضغط احسب القيمة."
        }
    }
}

private enum CryptoAsset: String, CaseIterable, Identifiable, Codable {
    case bitcoin
    case ethereum
    case solana
    case binancecoin
    case ripple

    var id: String { rawValue }

    var name: String {
        switch self {
        case .bitcoin: return "Bitcoin"
        case .ethereum: return "Ethereum"
        case .solana: return "Solana"
        case .binancecoin: return "BNB"
        case .ripple: return "XRP"
        }
    }

    var symbol: String {
        switch self {
        case .bitcoin: return "BTC"
        case .ethereum: return "ETH"
        case .solana: return "SOL"
        case .binancecoin: return "BNB"
        case .ripple: return "XRP"
        }
    }

    var displayName: String {
        "\(symbol) - \(name)"
    }

    var icon: String {
        switch self {
        case .bitcoin: return "bitcoinsign.circle.fill"
        case .ethereum: return "diamond.fill"
        case .solana: return "sparkles"
        case .binancecoin: return "b.circle.fill"
        case .ripple: return "x.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .bitcoin: return .orange
        case .ethereum: return .purple
        case .solana: return .teal
        case .binancecoin: return .yellow
        case .ripple: return .blue
        }
    }

    var cryptoFractionDigits: Int {
        switch self {
        case .bitcoin: return 8
        case .ethereum: return 6
        case .solana, .binancecoin: return 5
        case .ripple: return 3
        }
    }

    var currencyFractionDigits: Int {
        switch self {
        case .bitcoin, .ethereum: return 0
        case .solana, .binancecoin: return 2
        case .ripple: return 4
        }
    }
}

private struct CryptoPrices: Codable {
    let prices: [String: CryptoAssetPrice]
    let updateText: String
    let fetchedAt: Date

    func price(for asset: CryptoAsset) -> CryptoAssetPrice? {
        prices[asset.id]
    }
}

private struct CryptoAssetPrice: Codable {
    let sar: Double
    let usd: Double?
    let change24h: Double?
    let lastUpdatedAt: Int
}

private struct CryptoCalculationResult {
    let mode: CryptoCalculationMode
    let inputValue: Double
    let asset: CryptoAsset
    let price: CryptoAssetPrice
    let outputValue: Double
    let updateText: String
}

private struct CoinGeckoPriceResponse: Decodable {
    let sar: Double?
    let usd: Double?
    let sar24hChange: Double?
    let usd24hChange: Double?
    let lastUpdatedAt: Int?

    enum CodingKeys: String, CodingKey {
        case sar
        case usd
        case sar24hChange = "sar_24h_change"
        case usd24hChange = "usd_24h_change"
        case lastUpdatedAt = "last_updated_at"
    }
}

private struct CryptoDetailRow {
    let title: String
    let value: String
    var isHighlighted = false
    var forceLeftToRight = false
}

private enum CryptoCalculatorError: Error {
    case invalidURL
    case invalidResponse
    case rateNotFound
}

private struct CryptoSummaryChip: View {
    let title: String
    let value: String
    var isHighlighted = false
    var forceLeftToRight = false

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
        CryptoCalculatorView()
    }
}
