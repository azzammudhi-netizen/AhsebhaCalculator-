import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    @State private var animateLogo = false
    @Environment(\.colorScheme) private var colorScheme

    private let totalPages = 4

    var body: some View {
        ZStack {
            backgroundView
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    calculatorsPage.tag(1)
                    featuresPage.tag(2)
                    shortcutsPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicators
                    .padding(.bottom, 18)

                Button {
                    if currentPage < totalPages - 1 {
                        withAnimation(.easeInOut(duration: 0.28)) {
                            currentPage += 1
                        }
                    } else {
                        hasSeenOnboarding = true
                    }
                } label: {
                    Text(currentPage < totalPages - 1 ? "التالي" : "ابدأ الآن")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(AppTheme.buttonOrange)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(colorScheme == .light ? 0.35 : 0.12), lineWidth: 1)
                        )
                        .shadow(color: AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.30 : 0.22), radius: 16, x: 0, y: 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                animateLogo = true
            }
        }
    }

    private var welcomePage: some View {
        onboardingPage(spacing: 22) {
            Spacer(minLength: 20)

            appLogoView
                .scaleEffect(animateLogo ? 1.025 : 0.985)

            VStack(spacing: 10) {
                Text("مرحباً بك في احسبها")
                    .font(.system(size: 31, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("حاسبات يومية وتعليمية ومالية بتجربة عربية سريعة وسهلة.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 18)
            }

            VStack(spacing: 10) {
                featurePill(text: "نتائج واضحة", icon: "checkmark.seal.fill", tint: softGreen)
                featurePill(text: "واجهة عربية", icon: "textformat", tint: softOrange)
            }
            .padding(.top, 4)

            Spacer(minLength: 18)
        }
    }

    private var calculatorsPage: some View {
        onboardingPage(spacing: 20) {
            Spacer(minLength: 12)

            pageIcon(systemName: "square.grid.2x2.fill", tint: softBlue)

            pageHeader(
                title: "حاسبات مهمة في مكان واحد",
                subtitle: "اختر ما تحتاجه بسرعة من أدوات تعليمية ومالية ويومية."
            )

            VStack(spacing: 11) {
                calculatorCard(title: "حاسبة المعدل التراكمي", icon: "graduationcap.fill", tint: softOrange)
                calculatorCard(title: "حاسبة النسبة الموزونة", icon: "chart.bar.fill", tint: softBlue)
                calculatorCard(title: "تحويل التاريخ", icon: "calendar.badge.clock", tint: softPurple)
                calculatorCard(title: "حاسبة الضريبة", icon: "percent", tint: softGreen)
            }

            Spacer(minLength: 12)
        }
    }

    private var featuresPage: some View {
        onboardingPage(spacing: 20) {
            Spacer(minLength: 12)

            pageIcon(systemName: "checkmark.seal.fill", tint: softGreen)

            pageHeader(
                title: "مصمم للاستخدام اليومي",
                subtitle: "تجربة خفيفة وواضحة تساعدك على إنجاز الحسابات بدون تعقيد."
            )

            VStack(spacing: 12) {
                featureRow(text: "بدون تسجيل دخول", icon: "person.crop.circle.badge.checkmark", tint: softGreen)
                featureRow(text: "نتائج فورية وواضحة", icon: "bolt.fill", tint: softOrange)
                featureRow(text: "واجهة عربية سهلة", icon: "textformat", tint: softBlue)
                featureRow(text: "مناسب للطلاب والأعمال اليومية", icon: "briefcase.fill", tint: softPurple)
            }

            Spacer(minLength: 12)
        }
    }

    private var shortcutsPage: some View {
        onboardingPage(spacing: 20) {
            Spacer(minLength: 12)

            ZStack(alignment: .topTrailing) {
                pageIcon(systemName: "sparkles", tint: softPurple)

                Text("جديد")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.buttonOrange)
                    .clipShape(Capsule())
                    .offset(x: -4, y: 2)
                    .shadow(color: AppTheme.buttonOrange.opacity(0.25), radius: 8, x: 0, y: 4)
            }

            pageHeader(
                title: "اختصارات وويدجت",
                subtitle: "وصول أسرع إلى أهم الحاسبات من الشاشة الرئيسية واختصارات التطبيق."
            )

            VStack(spacing: 12) {
                featureRow(text: "اختصارات سريعة من أيقونة التطبيق", icon: "hand.tap.fill", tint: softOrange)
                featureRow(text: "ويدجت للوصول السريع", icon: "rectangle.grid.1x2.fill", tint: softPurple)
                featureRow(text: "تجربة بسيطة وسريعة", icon: "timer", tint: softBlue)
            }

            finalRewardCard

            Spacer(minLength: 12)
        }
    }

    private func onboardingPage<Content: View>(spacing: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: spacing) {
            content()
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .padding(.bottom, 8)
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: colorScheme == .light
                ? [
                    Color(red: 0.98, green: 0.985, blue: 0.995),
                    Color(red: 1.0, green: 0.975, blue: 0.94),
                    Color(red: 0.965, green: 0.975, blue: 1.0)
                ]
                : [
                    AppTheme.background,
                    AppTheme.secondaryBackground,
                    AppTheme.background
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var pageIndicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? AppTheme.buttonOrange : indicatorInactiveColor)
                    .frame(width: index == currentPage ? 30 : 9, height: 9)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(colorScheme == .light ? 0.55 : 0.08), lineWidth: 1)
                    )
                    .animation(.spring(response: 0.32, dampingFraction: 0.82), value: currentPage)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(cardBackground.opacity(colorScheme == .light ? 0.86 : 0.72))
        )
        .overlay(
            Capsule()
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private var appLogoView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(cardBackground)
                .frame(width: 176, height: 176)
                .overlay(
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.20 : 0.30), lineWidth: 1.2)
                )
                .shadow(color: cardShadow.opacity(1.25), radius: 22, x: 0, y: 14)

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(logoPanelBackground)
                .frame(width: 142, height: 142)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(cardBorder, lineWidth: 1)
                )

            VStack(spacing: 11) {
                Text("احسبها")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.buttonOrange)
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        miniButton("+", tint: softOrange)
                        miniButton("−", tint: softBlue)
                        miniButton("×", tint: softPurple)
                    }

                    HStack(spacing: 8) {
                        miniButton("÷", tint: softGreen)
                        miniButton("%", tint: softOrange)
                        miniButton("=", tint: AppTheme.buttonOrange)
                    }
                }
            }
        }
    }

    private func miniButton(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundColor(text == "=" ? .black : AppTheme.primaryText)
            .frame(width: 32, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(text == "=" ? tint : tint.opacity(colorScheme == .light ? 0.16 : 0.22))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(tint.opacity(colorScheme == .light ? 0.18 : 0.30), lineWidth: 1)
            )
    }

    private func pageIcon(systemName: String, tint: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(tint.opacity(colorScheme == .light ? 0.14 : 0.22))
                .frame(width: 126, height: 126)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(tint.opacity(colorScheme == .light ? 0.20 : 0.34), lineWidth: 1)
                )
                .shadow(color: tint.opacity(colorScheme == .light ? 0.14 : 0.04), radius: 16, x: 0, y: 9)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(iconInnerBackground)
                .frame(width: 92, height: 92)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .light ? 0.65 : 0.10), lineWidth: 1)
                )

            Image(systemName: systemName)
                .font(.system(size: 47, weight: .bold))
                .foregroundColor(tint == AppTheme.buttonOrange ? AppTheme.buttonOrange : tint)
        }
    }

    private func pageHeader(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(subtitle)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 10)
        }
    }

    private func calculatorCard(title: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 42, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(tint.opacity(colorScheme == .light ? 0.13 : 0.20))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(tint.opacity(colorScheme == .light ? 0.16 : 0.28), lineWidth: 1)
                )

            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.trailing)

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func featureRow(text: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(tint.opacity(colorScheme == .light ? 0.13 : 0.20))
                )

            Text(text)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.trailing)

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }

    private func featurePill(text: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(tint)

            Text(text)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: 210)
        .background(
            Capsule()
                .fill(cardBackground)
        )
        .overlay(
            Capsule()
                .stroke(tint.opacity(colorScheme == .light ? 0.18 : 0.30), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 8, x: 0, y: 4)
    }

    private var finalRewardCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(softGreen)

            VStack(alignment: .trailing, spacing: 4) {
                Text("جاهز لتجربة أسرع")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)

                Text("ابدأ الآن واستخدم أدواتك من مكان واحد.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
            }

            Spacer(minLength: 0)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(softGreen.opacity(colorScheme == .light ? 0.10 : 0.16))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(softGreen.opacity(colorScheme == .light ? 0.18 : 0.28), lineWidth: 1)
        )
        .shadow(color: cardShadow, radius: 9, x: 0, y: 5)
    }

    private var cardBackground: Color {
        colorScheme == .light ? Color.white.opacity(0.94) : AppTheme.secondaryBackground
    }

    private var logoPanelBackground: Color {
        colorScheme == .light ? Color(red: 0.985, green: 0.988, blue: 0.995) : AppTheme.inputBackground
    }

    private var iconInnerBackground: Color {
        colorScheme == .light ? Color.white.opacity(0.88) : AppTheme.secondaryBackground.opacity(0.92)
    }

    private var cardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.055) : AppTheme.border.opacity(0.75)
    }

    private var cardShadow: Color {
        colorScheme == .light ? Color.black.opacity(0.075) : Color.clear
    }

    private var indicatorInactiveColor: Color {
        colorScheme == .light ? Color.black.opacity(0.15) : Color.white.opacity(0.22)
    }

    private var softOrange: Color {
        AppTheme.buttonOrange
    }

    private var softBlue: Color {
        Color(red: 0.22, green: 0.46, blue: 0.92)
    }

    private var softGreen: Color {
        Color(red: 0.10, green: 0.58, blue: 0.42)
    }

    private var softPurple: Color {
        Color(red: 0.48, green: 0.36, blue: 0.86)
    }
}

#Preview {
    OnboardingView()
}
