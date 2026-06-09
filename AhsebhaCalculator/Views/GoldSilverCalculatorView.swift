import SwiftUI
import UIKit

struct GoldSilverCalculatorView: View {
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: Field?

    // TODO: Move this key to a secure configuration source before release.
    private let goldAPIKey = "goldapi-3e2e96cbeabf76d0b66df140a6cc3fe3-io"

    @State private var amountText = "1000"
    @State private var calculationMode: GoldSilverCalculationMode = .sarToMetal
    @State private var selectedAsset: PreciousMetalAsset = .gold24
    @State private var prices: PreciousMetalPrices?
    @State private var result: PreciousMetalCalculationResult?
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

    private var goldCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF8EF") : AppTheme.secondaryBackground
    }

    private var silverCardBackground: Color {
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
                        amountInputCard
                        assetSelectorCard
                        actionButtons(proxy: proxy)
                        statusSection

                        if let result {
                            resultCard(result)
                                .id("goldSilverResultSection")
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
            Text("حاسبة الذهب والفضة")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("احسب أسعار الذهب والفضة والكمية بالريال")
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
                priceSummaryCard(title: "ذهب 24", price: prices?.goldGram24, unit: "ر.س/جرام", tint: AppTheme.buttonOrange)
                priceSummaryCard(title: "ذهب 22", price: prices?.goldGram22, unit: "ر.س/جرام", tint: AppTheme.buttonOrange)
                priceSummaryCard(title: "ذهب 21", price: prices?.goldGram21, unit: "ر.س/جرام", tint: AppTheme.buttonOrange)
                priceSummaryCard(title: "ذهب 18", price: prices?.goldGram18, unit: "ر.س/جرام", tint: AppTheme.buttonOrange)
                priceSummaryCard(title: "أونصة الذهب", price: prices?.goldOunce, unit: "ر.س", tint: Color.orange)
                priceSummaryCard(title: "جرام الفضة", price: prices?.silverGram, unit: "ر.س/جرام", tint: Color.blue)
                priceSummaryCard(title: "أونصة الفضة", price: prices?.silverOunce, unit: "ر.س", tint: Color.blue)
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

    private func priceSummaryCard(title: String, price: Double?, unit: String, tint: Color) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            Text(price.map { formatCurrency($0, maximumFractionDigits: 2) } ?? "—")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(unit)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(tint)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 86)
        .background(tint.opacity(colorScheme == .light ? 0.08 : 0.14))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
    }

    private var modeSelectorCard: some View {
        HStack(spacing: 8) {
            ForEach(GoldSilverCalculationMode.allCases) { mode in
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
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
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

    private var amountInputCard: some View {
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

            if calculationMode == .metalToSAR {
                Text(selectedAsset.unitLabel)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(selectedAsset.tint)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 14)
                    .background(selectedAsset.tint.opacity(colorScheme == .light ? 0.10 : 0.18))
                    .clipShape(Capsule())
            }
        }
        .padding(18)
        .background(goldCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private var assetSelectorCard: some View {
        VStack(alignment: .center, spacing: 10) {
            sectionTitle(icon: "scalemass", title: "الأصل المختار", tint: selectedAsset.tint)

            Menu {
                ForEach(PreciousMetalAsset.allCases) { asset in
                    Button {
                        selectedAsset = asset
                    } label: {
                        Text(asset.title)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    VStack(alignment: .center, spacing: 5) {
                        Text(selectedAsset.title)
                            .font(.system(size: 19, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.primaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(selectedAsset.unitLabel)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.secondaryText)
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(selectedAsset.tint)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .background(selectedAsset.tint.opacity(colorScheme == .light ? 0.08 : 0.14))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(selectedAsset.tint.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(selectedAsset.isGold ? goldCardBackground : silverCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(selectedAsset.tint.opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func actionButtons(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    await fetchPrices()
                    if hasCalculatedOnce {
                        calculateQuantity(scrollProxy: proxy)
                    }
                }
            } label: {
                secondaryButtonLabel(icon: "arrow.clockwise", title: "تحديث الأسعار")
            }
            .buttonStyle(.plain)
            .disabled(isLoading)

            Button {
                calculateQuantity(scrollProxy: proxy)
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
            statusCard(text: "جاري تحديث أسعار الذهب والفضة...", icon: "clock.arrow.circlepath", tint: Color.blue, background: silverCardBackground)
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

    private func resultCard(_ result: PreciousMetalCalculationResult) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text(result.mode.resultTitle)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(primaryResultValue(result))
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundColor(result.asset.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(resultSubtitle(result))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .background(resultCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(result.asset.tint.opacity(colorScheme == .light ? 0.16 : 0.24), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func detailsCard(_ result: PreciousMetalCalculationResult) -> some View {
        VStack(alignment: .center, spacing: 14) {
            Text("تفاصيل الحساب")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(detailRows(for: result), id: \.title) { row in
                    GoldSilverSummaryChip(title: row.title, value: row.value, isHighlighted: row.isHighlighted)
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

    private func shareSection(_ result: PreciousMetalCalculationResult) -> some View {
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
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 58, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.12 : 0.20))
                )

            Text("جاهز لحساب الكمية")
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

            Text("أسعار الذهب والفضة استرشادية وقد تختلف حسب السوق المحلي ومحلات الذهب والمصنعية.")
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
                calculateQuantity(scrollProxy: nil, dismissKeyboard: false)
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
            if let cached = cachedPrices() {
                prices = cached
                cacheWarning = "تم عرض آخر سعر محفوظ."
            } else {
                errorMessage = errorMessage(for: error)
            }
        }
    }

    private func requestPrices() async throws -> PreciousMetalPrices {
        guard !goldAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GoldSilverError.missingAPIKey
        }

        async let goldResponse = fetchMetal(symbol: "XAU")
        async let silverResponse = fetchMetal(symbol: "XAG")
        let (gold, silver) = try await (goldResponse, silverResponse)

        #if DEBUG
        print("Gold decoded:", gold)
        print("Silver decoded:", silver)
        print("Gold price gram 24:", gold.priceGram24k ?? -1)
        print("Gold price ounce:", gold.price ?? -1)
        print("Silver price:", silver.price ?? -1)
        #endif

        guard let goldOunce = gold.price, goldOunce > 0,
              let silverOunce = silver.price, silverOunce > 0 else {
            throw GoldSilverError.invalidPrice
        }

        let updateDate: Date
        if let timestamp = gold.timestamp ?? silver.timestamp, timestamp > 0 {
            updateDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else {
            updateDate = Date()
        }
        let updateText = formatGregorianDate(updateDate)

        let livePrices = PreciousMetalPrices(
            goldOunce: goldOunce,
            goldGram24: gold.priceGram24k ?? goldOunce / PreciousMetalPrices.troyOunceGrams,
            goldGram22: gold.priceGram22k ?? (goldOunce / PreciousMetalPrices.troyOunceGrams) * (22.0 / 24.0),
            goldGram21: gold.priceGram21k ?? (goldOunce / PreciousMetalPrices.troyOunceGrams) * (21.0 / 24.0),
            goldGram18: gold.priceGram18k ?? (goldOunce / PreciousMetalPrices.troyOunceGrams) * (18.0 / 24.0),
            silverOunce: silverOunce,
            silverGram: silver.priceGram24k ?? silverOunce / PreciousMetalPrices.troyOunceGrams,
            updateText: updateText,
            fetchedAt: Date()
        )

        #if DEBUG
        print("Mapped gold 24:", livePrices.goldGram24)
        print("Mapped silver gram:", livePrices.silverGram)
        #endif

        return livePrices
    }

    private func fetchMetal(symbol: String) async throws -> GoldAPIResponse {
        guard let url = URL(string: "https://www.goldapi.io/api/\(symbol)/SAR") else {
            throw GoldSilverError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(goldAPIKey, forHTTPHeaderField: "x-access-token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        #if DEBUG
        print("GoldAPI request URL: \(url.absoluteString)")
        #endif

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GoldSilverError.invalidResponse
        }

        #if DEBUG
        print("GoldAPI HTTP status: \(httpResponse.statusCode)")
        #endif

        guard httpResponse.statusCode == 200 else {
            debugLogFailureBody(data)
            throw GoldSilverError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(GoldAPIResponse.self, from: data)
        } catch {
            #if DEBUG
            print("GoldAPI decoding error: \(error)")
            #endif
            debugLogFailureBody(data)
            throw GoldSilverError.decodingFailed
        }
    }

    private func errorMessage(for error: Error) -> String {
        if let goldSilverError = error as? GoldSilverError {
            return goldSilverError.localizedMessage
        }

        return "تعذر تحديث أسعار الذهب والفضة، تحقق من الاتصال بالإنترنت."
    }

    private func debugLogFailureBody(_ data: Data) {
        #if DEBUG
        if let body = String(data: data, encoding: .utf8), !body.isEmpty {
            print("GoldAPI response body: \(body)")
        }
        #endif
    }

    private func calculateQuantity(scrollProxy: ScrollViewProxy?, dismissKeyboard: Bool = true) {
        if dismissKeyboard {
            recalculationTask?.cancel()
        }

        if dismissKeyboard {
            focusedField = nil
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        guard let inputValue = parsedInput, inputValue > 0 else {
            result = nil
            errorMessage = "أدخل قيمة صحيحة لإتمام الحساب."
            return
        }

        guard let prices else {
            errorMessage = "تعذر قراءة السعر الحالي للأصل المختار."
            return
        }

        let assetPrice = selectedAsset.price(in: prices)
        guard assetPrice > 0 else {
            errorMessage = "تعذر قراءة السعر الحالي للأصل المختار."
            return
        }

        let outputValue: Double
        switch calculationMode {
        case .sarToMetal:
            outputValue = inputValue / assetPrice
        case .metalToSAR:
            outputValue = inputValue * assetPrice
        }

        let calculation = PreciousMetalCalculationResult(
            mode: calculationMode,
            inputValue: inputValue,
            asset: selectedAsset,
            price: assetPrice,
            outputValue: outputValue,
            updateText: prices.updateText
        )

        result = calculation
        hasCalculatedOnce = true
        errorMessage = nil

        if let scrollProxy {
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    scrollProxy.scrollTo("goldSilverResultSection", anchor: .center)
                }
            }
        }
    }

    private func saveCache(_ prices: PreciousMetalPrices) {
        if let data = try? JSONEncoder().encode(prices) {
            UserDefaults.standard.set(data, forKey: "GoldSilverCalculator.Prices")
        }
    }

    private func cachedPrices() -> PreciousMetalPrices? {
        guard let data = UserDefaults.standard.data(forKey: "GoldSilverCalculator.Prices") else {
            return nil
        }

        return try? JSONDecoder().decode(PreciousMetalPrices.self, from: data)
    }

    private func formatCurrency(_ value: Double, maximumFractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatQuantity(_ value: Double, asset: PreciousMetalAsset) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = asset.usesOunce ? 4 : (asset.isGold ? 3 : 2)
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formatted) \(asset.quantityUnit)"
    }

    private func formatWeight(_ value: Double, asset: PreciousMetalAsset) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = asset.usesOunce ? 4 : 3
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formatted) \(asset.unitLabel)"
    }

    private func formatGregorianDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func primaryResultValue(_ result: PreciousMetalCalculationResult) -> String {
        switch result.mode {
        case .sarToMetal:
            return formatQuantity(result.outputValue, asset: result.asset)
        case .metalToSAR:
            return "\(formatCurrency(result.outputValue, maximumFractionDigits: 2)) ر.س"
        }
    }

    private func resultSubtitle(_ result: PreciousMetalCalculationResult) -> String {
        switch result.mode {
        case .sarToMetal:
            return result.asset.title
        case .metalToSAR:
            return "\(formatWeight(result.inputValue, asset: result.asset)) \(result.asset.title)"
        }
    }

    private func detailRows(for result: PreciousMetalCalculationResult) -> [GoldSilverDetailRow] {
        switch result.mode {
        case .sarToMetal:
            return [
                GoldSilverDetailRow(title: "المبلغ بالريال", value: "\(formatCurrency(result.inputValue, maximumFractionDigits: 2)) ر.س"),
                GoldSilverDetailRow(title: "الأصل المختار", value: result.asset.title),
                GoldSilverDetailRow(title: "سعر الأصل", value: "\(formatCurrency(result.price, maximumFractionDigits: 2)) ر.س", isHighlighted: true),
                GoldSilverDetailRow(title: "الكمية الناتجة", value: formatQuantity(result.outputValue, asset: result.asset), isHighlighted: true),
                GoldSilverDetailRow(title: "مصدر الأسعار", value: "GoldAPI")
            ]
        case .metalToSAR:
            return [
                GoldSilverDetailRow(title: "الوزن المدخل", value: formatWeight(result.inputValue, asset: result.asset)),
                GoldSilverDetailRow(title: "الأصل المختار", value: result.asset.title),
                GoldSilverDetailRow(title: "سعر الأصل", value: "\(formatCurrency(result.price, maximumFractionDigits: 2)) ر.س", isHighlighted: true),
                GoldSilverDetailRow(title: "القيمة التقديرية", value: "\(formatCurrency(result.outputValue, maximumFractionDigits: 2)) ر.س", isHighlighted: true),
                GoldSilverDetailRow(title: "مصدر الأسعار", value: "GoldAPI")
            ]
        }
    }

    private func shareText(for result: PreciousMetalCalculationResult) -> String {
        let summary: String
        switch result.mode {
        case .sarToMetal:
            summary = "بمبلغ \(formatCurrency(result.inputValue, maximumFractionDigits: 2)) ر.س يمكنك شراء \(formatQuantity(result.outputValue, asset: result.asset))."
        case .metalToSAR:
            summary = "\(formatWeight(result.inputValue, asset: result.asset)) \(result.asset.title) تساوي تقريبًا \(formatCurrency(result.outputValue, maximumFractionDigits: 2)) ر.س."
        }

        return """
        حاسبة الذهب والفضة - احسبها

        نوع الحساب:
        \(result.mode.title)

        الأصل المختار:
        \(result.asset.title)

        سعر الأصل:
        \(formatCurrency(result.price, maximumFractionDigits: 2)) ر.س

        النتيجة:
        \(primaryResultValue(result))

        \(summary)

        آخر تحديث:
        \(result.updateText)

        مصدر الأسعار:
        GoldAPI
        """
    }

    @MainActor
    private func resultCardImage(for result: PreciousMetalCalculationResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "حاسبة الذهب والفضة",
            rows: [
                ResultCardRow(title: "نوع الحساب", value: result.mode.title),
                ResultCardRow(title: "الأصل المختار", value: result.asset.title),
                ResultCardRow(title: "سعر الأصل", value: "\(formatCurrency(result.price, maximumFractionDigits: 2)) ر.س"),
                ResultCardRow(title: result.mode.resultTitle, value: primaryResultValue(result), valueColor: AppTheme.buttonOrange),
                ResultCardRow(title: "آخر تحديث", value: result.updateText),
                ResultCardRow(title: "المصدر", value: "GoldAPI")
            ],
            note: "الأسعار استرشادية وقد تختلف حسب السوق والمصنعية."
        )
    }
}

private enum PreciousMetalAsset: String, CaseIterable, Identifiable {
    case gold24
    case gold22
    case gold21
    case gold18
    case goldOunce
    case silverGram
    case silverOunce

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gold24: return "ذهب 24 قيراط"
        case .gold22: return "ذهب 22 قيراط"
        case .gold21: return "ذهب 21 قيراط"
        case .gold18: return "ذهب 18 قيراط"
        case .goldOunce: return "أونصة الذهب"
        case .silverGram: return "جرام الفضة"
        case .silverOunce: return "أونصة الفضة"
        }
    }

    var unitLabel: String {
        usesOunce ? "أونصة" : "جرام"
    }

    var quantityUnit: String {
        switch self {
        case .gold24: return "جرام ذهب ٢٤"
        case .gold22: return "جرام ذهب ٢٢"
        case .gold21: return "جرام ذهب ٢١"
        case .gold18: return "جرام ذهب ١٨"
        case .goldOunce: return "أونصة ذهب"
        case .silverGram: return "جرام فضة"
        case .silverOunce: return "أونصة فضة"
        }
    }

    var usesOunce: Bool {
        self == .goldOunce || self == .silverOunce
    }

    var isGold: Bool {
        self == .gold24 || self == .gold22 || self == .gold21 || self == .gold18 || self == .goldOunce
    }

    var tint: Color {
        isGold ? AppTheme.buttonOrange : Color.blue
    }

    func price(in prices: PreciousMetalPrices) -> Double {
        switch self {
        case .gold24: return prices.goldGram24
        case .gold22: return prices.goldGram22
        case .gold21: return prices.goldGram21
        case .gold18: return prices.goldGram18
        case .goldOunce: return prices.goldOunce
        case .silverGram: return prices.silverGram
        case .silverOunce: return prices.silverOunce
        }
    }
}

private struct PreciousMetalPrices: Codable {
    static let troyOunceGrams = 31.1034768

    let goldOunce: Double
    let goldGram24: Double
    let goldGram22: Double
    let goldGram21: Double
    let goldGram18: Double
    let silverOunce: Double
    let silverGram: Double
    let updateText: String
    let fetchedAt: Date
}

private struct PreciousMetalCalculationResult {
    let mode: GoldSilverCalculationMode
    let inputValue: Double
    let asset: PreciousMetalAsset
    let price: Double
    let outputValue: Double
    let updateText: String
}

private enum GoldSilverCalculationMode: String, CaseIterable, Identifiable {
    case sarToMetal
    case metalToSAR

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sarToMetal: return "من الريال إلى المعدن"
        case .metalToSAR: return "من المعدن إلى الريال"
        }
    }

    var inputTitle: String {
        switch self {
        case .sarToMetal: return "المبلغ بالريال"
        case .metalToSAR: return "الوزن"
        }
    }

    var inputIcon: String {
        switch self {
        case .sarToMetal: return "banknote.fill"
        case .metalToSAR: return "scalemass.fill"
        }
    }

    var placeholder: String {
        switch self {
        case .sarToMetal: return "1000"
        case .metalToSAR: return "5"
        }
    }

    var buttonTitle: String {
        switch self {
        case .sarToMetal: return "احسب الكمية"
        case .metalToSAR: return "احسب القيمة"
        }
    }

    var resultTitle: String {
        switch self {
        case .sarToMetal: return "الكمية التي يمكن شراؤها"
        case .metalToSAR: return "القيمة التقديرية"
        }
    }

    var emptyStateText: String {
        switch self {
        case .sarToMetal:
            return "أدخل المبلغ واختر الأصل ثم اضغط احسب الكمية."
        case .metalToSAR:
            return "أدخل الوزن واختر الأصل ثم اضغط احسب القيمة."
        }
    }
}

private struct GoldSilverDetailRow {
    let title: String
    let value: String
    var isHighlighted = false
}

private struct GoldAPIResponse: Codable {
    let timestamp: Int?
    let metal: String?
    let currency: String?
    let price: Double?
    let priceGram24k: Double?
    let priceGram22k: Double?
    let priceGram21k: Double?
    let priceGram18k: Double?

    enum CodingKeys: String, CodingKey {
        case timestamp
        case metal
        case currency
        case price
        case priceGram24k = "price_gram_24k"
        case priceGram22k = "price_gram_22k"
        case priceGram21k = "price_gram_21k"
        case priceGram18k = "price_gram_18k"
    }
}

private enum GoldSilverError: Error {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed
    case invalidPrice

    var localizedMessage: String {
        switch self {
        case .missingAPIKey:
            return "مفتاح API غير صحيح أو لا يملك صلاحية."
        case .invalidURL, .invalidResponse:
            return "تعذر تحديث أسعار الذهب والفضة، تحقق من الاتصال بالإنترنت."
        case .httpStatus(let statusCode):
            switch statusCode {
            case 401, 403:
                return "مفتاح API غير صحيح أو لا يملك صلاحية."
            case 429:
                return "تم تجاوز حد الطلبات المجانية."
            case 500...599:
                return "تعذر الاتصال بمزود أسعار الذهب."
            default:
                return "تعذر تحديث أسعار الذهب والفضة، تحقق من الاتصال بالإنترنت."
            }
        case .decodingFailed:
            return "تعذر قراءة بيانات الأسعار من المزود."
        case .invalidPrice:
            return "تعذر قراءة سعر الذهب أو الفضة من المزود."
        }
    }
}

private struct GoldSilverSummaryChip: View {
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
        GoldSilverCalculatorView()
    }
}
