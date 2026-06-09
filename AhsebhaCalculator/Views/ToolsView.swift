import SwiftUI
import WidgetKit

let ahsebhaSharedDefaults = UserDefaults(suiteName: "group.com.soliman.ahsebha")!

struct ToolsView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var searchText: String = ""
    
    @AppStorage("recentToolTitles", store: ahsebhaSharedDefaults) private var recentToolTitlesData: String = ""
    @AppStorage("favoriteToolTitles", store: ahsebhaSharedDefaults) private var favoriteToolTitlesData: String = ""
    
    private let educationTools: [ToolItem] = [
        ToolItem(
            title: "حاسبة المعدل التراكمي",
            subtitle: "احسب المعدل التراكمي للثانوية أو الجامعة",
            icon: "graduationcap.fill",
            color: .blue
        ),
        ToolItem(
            title: "حاسبة النسبة الموزونة",
            subtitle: "احسب النسبة المطلوبة للقبول الجامعي",
            icon: "chart.bar.fill",
            color: .purple
        )
    ]
    
    private let financeTools: [ToolItem] = [
        ToolItem(
            title: "حاسبة التمويل الشخصي",
            subtitle: "احسب القسط الشهري وإجمالي الفائدة",
            icon: "banknote.fill",
            color: .green
        ),
        ToolItem(
            title: "حاسبة التمويل العقاري",
            subtitle: "احسب قسط العقار بطريقة الرصيد المتناقص",
            icon: "house.fill",
            color: .blue
        ),
        ToolItem(
            title: "محول العملات",
            subtitle: "حوّل بين العملات بأسعار محدثة",
            icon: "coloncurrencysign.circle",
            color: .teal
        ),
        ToolItem(
            title: "حاسبة الذهب والفضة",
            subtitle: "احسب أسعار الذهب والفضة مباشرة",
            icon: "sparkles",
            color: .orange
        ),
        ToolItem(
            title: "حاسبة نهاية الخدمة",
            subtitle: "احسب مكافأة نهاية الخدمة وفق نظام العمل السعودي",
            icon: "briefcase.fill",
            color: .orange
        ),
        ToolItem(
            title: "حاسبة التقاعد المدني",
            subtitle: "قدّر المعاش التقاعدي للموظف المدني",
            icon: "person.badge.shield.checkmark",
            color: .blue
        ),
        ToolItem(
            title: "حاسبة التقاعد العسكري",
            subtitle: "قدّر المعاش التقاعدي للعسكري",
            icon: "shield.lefthalf.filled",
            color: .red
        ),
        ToolItem(
            title: "حاسبة الضريبة",
            subtitle: "احسب ضريبة القيمة المضافة بسرعة",
            icon: "plus.forwardslash.minus",
            color: .teal
        ),
        ToolItem(
            title: "حاسبة الخصم",
            subtitle: "احسب السعر بعد الخصم والعروض",
            icon: "tag.fill",
            color: .orange
        )
    ]
    
    private let generalTools: [ToolItem] = [
        ToolItem(
            title: "حاسبة النسبة المئوية",
            subtitle: "احسب النسب والزيادات بسهولة",
            icon: "percent",
            color: .green
        ),
        ToolItem(
            title: "حاسبة العمر",
            subtitle: "احسب عمرك بالسنوات والأشهر والأيام",
            icon: "calendar",
            color: .cyan
        ),
        ToolItem(
            title: "تحويل أسماء الأشهر",
            subtitle: "اعرف أسماء الشهر في تقاويم وثقافات مختلفة",
            icon: "calendar.badge.clock",
            color: .indigo
        ),
        ToolItem(
            title: "تحويل التاريخ",
            subtitle: "حوّل بين الميلادي والهجري وفق أم القرى",
            icon: "calendar.badge.clock",
            color: .indigo
        ),
        ToolItem(
            title: "حاسبة الفرق بين تاريخين",
            subtitle: "احسب المدة بين تاريخين بالميلادي أو الهجري",
            icon: "calendar.badge.clock",
            color: .purple
        )
    ]
    
    private var allTools: [ToolItem] {
        educationTools + financeTools + generalTools
    }
    
    private var recentToolTitles: [String] {
        decodeTitles(from: recentToolTitlesData)
    }
    
    private var favoriteToolTitles: [String] {
        decodeTitles(from: favoriteToolTitlesData)
    }
    
    private var recentTools: [ToolItem] {
        recentToolTitles.compactMap { title in
            allTools.first { $0.title == title }
        }
    }
    
    private var favoriteTools: [ToolItem] {
        favoriteToolTitles.compactMap { title in
            allTools.first { $0.title == title }
        }
    }
    
    private var filteredTools: [ToolItem] {
        let query = normalizedSearchText(searchText)
        
        guard !query.isEmpty else {
            return []
        }
        
        return allTools.filter { tool in
            let searchableText = normalizedSearchText(
                [
                    tool.title,
                    tool.subtitle,
                    smartKeywords(for: tool)
                ].joined(separator: " ")
            )
            
            return searchableText.contains(query)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 22) {
                        headerSection
                        searchSection
                        
                        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            toolSection(title: "نتائج البحث", icon: "magnifyingglass", tools: filteredTools)
                        } else {
                            if !favoriteTools.isEmpty {
                                favoriteSection
                            }
                            
                            if !recentTools.isEmpty {
                                toolSection(title: "آخر استخداماتك", icon: "clock.fill", tools: recentTools)
                            }
                            
                            toolSection(title: "الحاسبات التعليمية", icon: "graduationcap.fill", tools: educationTools)
                            toolSection(title: "الحاسبات المالية", icon: "banknote.fill", tools: financeTools)
                            toolSection(title: "الحاسبات العامة", icon: "square.grid.2x2.fill", tools: generalTools)
                            ahsebhaCard
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("أدوات احسبها")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("حاسبات تعليمية ومالية وعامة بتصميم سريع ومناسب للايفون.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 12) {
                statCard(number: "\(allTools.count)", title: "أدوات", tint: AppTheme.buttonOrange)
                statCard(number: "\(favoriteTools.count)", title: "مفضلة", tint: Color(hex: "#7C5CE6"))
                statCard(number: "\(recentTools.count)", title: "آخر استخدام", tint: Color(hex: "#1E88E5"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func statCard(number: String, title: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.system(size: 21, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
            
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(colorScheme == .light ? tint.opacity(0.09) : AppTheme.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(colorScheme == .light ? tint.opacity(0.15) : AppTheme.primaryText.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: colorScheme == .light ? Color.black.opacity(0.045) : Color.clear, radius: 7, x: 0, y: 4)
        )
    }
    
    private var searchSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.secondaryText)
            
            TextField("ابحث عن حاسبة، مثال: تقاعد، نهاية الخدمة، عقار، قرض", text: $searchText)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .tint(AppTheme.buttonOrange)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(searchBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(searchBorder, lineWidth: 1)
                )
        )
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.045) : Color.clear, radius: 8, x: 0, y: 4)
    }
    
    private var favoriteSection: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack(spacing: 10) {
                VStack(alignment: .trailing, spacing: 4) {
                    sectionTitle("أدواتك المفضلة", icon: "star.fill")
                    
                    Text("وصول سريع للحاسبات التي تستخدمها كثيرًا.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.trailing)
                }
                
                ZStack {
                    Circle()
                        .fill(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.13 : 0.18))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppTheme.buttonOrange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            ForEach(favoriteTools) { tool in
                toolCard(for: tool)
            }
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(favoriteBackground)
                
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.18 : 0.24), lineWidth: 1)
            }
        )
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.055) : Color.clear, radius: 10, x: 0, y: 5)
    }
    
    private func toolSection(title: String, icon: String, tools: [ToolItem]) -> some View {
        VStack(alignment: .trailing, spacing: 16) {
            sectionTitle(title, icon: icon)
            
            if tools.isEmpty {
                emptySearchState
            } else {
                ForEach(tools) { tool in
                    toolCard(for: tool)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(sectionShouldHaveSurface(title) ? 18 : 0)
        .background(
            Group {
                if sectionShouldHaveSurface(title) {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(sectionBackground(for: title))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(sectionBorder(for: title), lineWidth: 1)
                        )
                        .shadow(color: colorScheme == .light ? Color.black.opacity(0.045) : Color.clear, radius: 8, x: 0, y: 4)
                }
            }
        )
    }
    
    private func sectionTitle(_ title: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.trailing)
            
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(sectionTint(for: title))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(sectionTint(for: title).opacity(colorScheme == .light ? 0.12 : 0.20))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(sectionTint(for: title).opacity(colorScheme == .light ? 0.14 : 0.24), lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .environment(\.layoutDirection, .leftToRight)
    }
    
    private func toolCard(for tool: ToolItem) -> some View {
        ToolCardView(
            tool: tool,
            isFavorite: favoriteToolTitles.contains(tool.title),
            onToggleFavorite: {
                toggleFavorite(tool)
            },
            onOpen: {
                recordToolUse(tool)
            }
        )
    }
    
    private var ahsebhaCard: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .center, spacing: 6) {
                    Text("اكتشف المزيد في احسبها")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(ahsebhaCardTitleColor)
                    
                    Text("الموقع يحتوي على المزيد من الحاسبات والمقالات التعليمية.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(ahsebhaCardSubtitleColor)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(ahsebhaBadgeBackground)
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: "globe")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(AppTheme.buttonOrange)
                }
            }
            
            Link(destination: URL(string: "https://www.ahsebha.com")!) {
                HStack(spacing: 8) {
                    Text("زيارة الموقع")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    
                    Image(systemName: "safari.fill")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(ahsebhaButtonTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(ahsebhaButtonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: ahsebhaCardGradient,
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(ahsebhaCardBorder, lineWidth: 1)
                )
                .shadow(color: colorScheme == .light ? Color.black.opacity(0.08) : Color.clear, radius: 12, x: 0, y: 6)
        )
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var ahsebhaCardGradient: [Color] {
        if colorScheme == .light {
            return [
                Color(hex: "#FFF7ED"),
                Color(hex: "#F8FAFC")
            ]
        }
        
        return [
            AppTheme.secondaryBackground,
            AppTheme.buttonOrange.opacity(0.16)
        ]
    }
    
    private var ahsebhaCardBorder: Color {
        colorScheme == .light ? AppTheme.buttonOrange.opacity(0.18) : AppTheme.buttonOrange.opacity(0.25)
    }
    
    private var ahsebhaCardTitleColor: Color {
        colorScheme == .light ? AppTheme.primaryText : .white
    }
    
    private var ahsebhaCardSubtitleColor: Color {
        colorScheme == .light ? AppTheme.secondaryText : AppTheme.secondaryText
    }
    
    private var ahsebhaBadgeBackground: Color {
        colorScheme == .light ? Color.white : AppTheme.inputBackground
    }
    
    private var ahsebhaButtonBackground: some ShapeStyle {
        if colorScheme == .light {
            return AnyShapeStyle(AppTheme.buttonOrange)
        }
        
        return AnyShapeStyle(
            LinearGradient(
                colors: [
                    AppTheme.buttonOrange,
                    AppTheme.buttonOrange.opacity(0.82)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        )
    }
    
    private var ahsebhaButtonTextColor: Color {
        .white
    }
    
    private var emptySearchState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.buttonOrange)
                .frame(width: 52, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.12 : 0.20))
                )
            
            Text("لا توجد نتائج مطابقة")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
            
            Text("جرّب البحث بكلمة أبسط مثل: ضريبة، تقاعد، عقار، أو معدل.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(searchBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(searchBorder, lineWidth: 1)
                )
        )
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.045) : Color.clear, radius: 8, x: 0, y: 4)
    }
    
    private var searchBackground: Color {
        colorScheme == .light ? Color(hex: "#F6F3FF") : AppTheme.secondaryBackground
    }
    
    private var searchBorder: Color {
        colorScheme == .light ? Color(hex: "#7C5CE6").opacity(0.13) : AppTheme.primaryText.opacity(0.06)
    }
    
    private var favoriteBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF8EF") : AppTheme.secondaryBackground
    }
    
    private func sectionShouldHaveSurface(_ title: String) -> Bool {
        title == "الحاسبات التعليمية" || title == "الحاسبات المالية" || title == "الحاسبات العامة"
    }
    
    private func sectionBackground(for title: String) -> Color {
        guard colorScheme == .light else {
            return AppTheme.secondaryBackground.opacity(0.55)
        }
        
        switch title {
        case "الحاسبات التعليمية":
            return Color(hex: "#F4F7FF")
        case "الحاسبات المالية":
            return Color(hex: "#F3FBF7")
        case "الحاسبات العامة":
            return Color(hex: "#F8F5FF")
        default:
            return Color.clear
        }
    }
    
    private func sectionBorder(for title: String) -> Color {
        colorScheme == .light ? sectionTint(for: title).opacity(0.11) : AppTheme.primaryText.opacity(0.06)
    }
    
    private func sectionTint(for title: String) -> Color {
        switch title {
        case "الحاسبات التعليمية":
            return Color(hex: "#3B73E6")
        case "الحاسبات المالية":
            return Color(hex: "#1A936F")
        case "الحاسبات العامة":
            return Color(hex: "#7C5CE6")
        case "أدواتك المفضلة":
            return AppTheme.buttonOrange
        case "آخر استخداماتك":
            return Color(hex: "#1E88E5")
        case "نتائج البحث":
            return Color(hex: "#7C5CE6")
        default:
            return AppTheme.buttonOrange
        }
    }
    
    private func smartKeywords(for tool: ToolItem) -> String {
        switch tool.title {
        case "حاسبة المعدل التراكمي":
            return "معدل تراكمي GPA جي بي اي جامعة جامعي ثانوي ثانوية درجات نتيجة فصل ترم نقاط مواد تعليم دراسة"

        case "حاسبة النسبة الموزونة":
            return "نسبة موزونة قبول جامعة جامعات قدرات تحصيلي ثانوي ثانوية مسار مسارات قبول جامعي تعليم قياس"

        case "حاسبة التمويل الشخصي":
            return "تمويل شخصي قرض شخصي قسط شهري فائدة سنوية اجمالي الفائدة مبلغ القرض مدة السداد بنك بنوك اقساط personal loan finance monthly payment"

        case "حاسبة التمويل العقاري":
            return "تمويل عقاري قرض عقاري عقار منزل بيت فيلا شقة شراء منزل قسط عقاري رصيد متناقص نسبة سنوية ارباح دفعة اولى دفعة مقدمة بنك بنوك سكني mortgage home finance real estate monthly payment"
            
        case "محول العملات":
            return "محول العملات تحويل عملات صرف عملة سعر الصرف ريال دولار يورو درهم دينار currency converter exchange rate sar usd eur aed kwd fiat"
            
        case "حاسبة الذهب والفضة":
            return "ذهب فضة سعر الذهب سعر الفضة جرام ذهب اونصة ذهب جرام فضة اونصة فضة عيار قيراط سبائك gold silver xau xag precious metals"

        case "حاسبة نهاية الخدمة":
            return "نهاية الخدمة مكافأة نهاية الخدمة حقوق العامل حقوق الموظف نظام العمل السعودي استقالة انتهاء عقد انهاء عقد عقد محدد غير محدد راتب اجر فعلي وزارة الموارد البشرية قوى labor end service benefit eosb resignation termination"

        case "حاسبة التقاعد المدني":
            return "تقاعد مدني معاش تقاعدي الراتب الأساسي مدة الخدمة سنوات الخدمة أشهر الخدمة موظف حكومي مدني المؤسسة العامة للتأمينات الاجتماعية التقاعد المدني pension civil retirement gosi"

        case "حاسبة التقاعد العسكري":
            return "تقاعد عسكري معاش تقاعدي عسكري الراتب الأساسي مدة الخدمة سنوات الخدمة أشهر الخدمة جهة عسكرية عجز وفاة بسبب العمل المؤسسة العامة للتأمينات الاجتماعية pension military retirement gosi"

        case "حاسبة الضريبة":
            return "ضريبة القيمة المضافة VAT vat tax زكاة دخل فاتورة سعر شامل غير شامل 15 خمسة عشر مالية"

        case "حاسبة الخصم":
            return "خصم تخفيض عرض عروض كوبون سعر قبل بعد discount sale توفير نسبة الخصم تسوق متجر"

        case "حاسبة النسبة المئوية":
            return "نسبة مئوية بالمئة في المئة percent percentage زيادة نقصان فرق حساب النسبة"

        case "حاسبة العمر":
            return "عمر ميلاد تاريخ الميلاد سنوات اشهر أيام birthday age مواليد كم عمري"

        case "تحويل أسماء الأشهر":
            return "اشهر شهور اسماء الشهور كانون شباط اذار يناير فبراير مارس تقاويم ثقافات سرياني قبطي أمازيغي"

        case "تحويل التاريخ":
            return "تاريخ تحويل التاريخ ميلادي هجري ام القرى أم القرى تقويم calendar date hijri gregorian"
            
        case "حاسبة الفرق بين تاريخين":
            return "فرق بين تاريخين مدة بين تاريخين عدد الايام سنوات اشهر ايام ميلادي هجري ام القرى date difference duration days calendar"

        default:
            return ""
        }
    }

    private func normalizedSearchText(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "أ", with: "ا")
            .replacingOccurrences(of: "إ", with: "ا")
            .replacingOccurrences(of: "آ", with: "ا")
            .replacingOccurrences(of: "ى", with: "ي")
            .replacingOccurrences(of: "ة", with: "ه")
            .replacingOccurrences(of: "ؤ", with: "و")
            .replacingOccurrences(of: "ئ", with: "ي")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func recordToolUse(_ tool: ToolItem) {
        var titles = recentToolTitles
        
        titles.removeAll { $0 == tool.title }
        titles.insert(tool.title, at: 0)
        titles = Array(titles.prefix(3))
        
        recentToolTitlesData = encodeTitles(titles)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func toggleFavorite(_ tool: ToolItem) {
        var titles = favoriteToolTitles
        
        if titles.contains(tool.title) {
            titles.removeAll { $0 == tool.title }
        } else {
            titles.insert(tool.title, at: 0)
        }
        
        favoriteToolTitlesData = encodeTitles(titles)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func decodeTitles(from text: String) -> [String] {
        guard let data = text.data(using: .utf8),
              let titles = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        
        return titles
    }
    
    private func encodeTitles(_ titles: [String]) -> String {
        guard let data = try? JSONEncoder().encode(titles),
              let encoded = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        
        return encoded
    }
}

#Preview {
    ToolsView()
}
