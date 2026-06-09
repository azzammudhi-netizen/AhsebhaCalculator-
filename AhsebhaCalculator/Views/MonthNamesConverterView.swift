import SwiftUI
import UIKit

struct MonthNamesConverterView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedMonthIndex: Int = 2
    
    private let months: [MonthNameItem] = [
        MonthNameItem(
            number: 1,
            gregorianArabic: "يناير",
            gregorianEnglish: "January",
            syriac: "كانون الثاني",
            maghreb: "يناير",
            amazigh: "Yennayer",
            coptic: "طوبة",
            babylonian: "نيسانو",
            persian: "Farvardin",
            turkish: "Ocak",
            oldYemeni: "كانون"
        ),
        MonthNameItem(
            number: 2,
            gregorianArabic: "فبراير",
            gregorianEnglish: "February",
            syriac: "شباط",
            maghreb: "فبراير",
            amazigh: "Furar",
            coptic: "أمشير",
            babylonian: "آيارو",
            persian: "Ordibehesht",
            turkish: "Şubat",
            oldYemeni: "شباط"
        ),
        MonthNameItem(
            number: 3,
            gregorianArabic: "مارس",
            gregorianEnglish: "March",
            syriac: "آذار",
            maghreb: "مارس",
            amazigh: "Meɣres",
            coptic: "برمهات",
            babylonian: "سيمانو",
            persian: "Khordad",
            turkish: "Mart",
            oldYemeni: "آذار"
        ),
        MonthNameItem(
            number: 4,
            gregorianArabic: "أبريل",
            gregorianEnglish: "April",
            syriac: "نيسان",
            maghreb: "أبريل",
            amazigh: "Ibrir",
            coptic: "برمودة",
            babylonian: "تموزو",
            persian: "Tir",
            turkish: "Nisan",
            oldYemeni: "نيسان"
        ),
        MonthNameItem(
            number: 5,
            gregorianArabic: "مايو",
            gregorianEnglish: "May",
            syriac: "أيار",
            maghreb: "ماي",
            amazigh: "Mayyu",
            coptic: "بشنس",
            babylonian: "آبو",
            persian: "Mordad",
            turkish: "Mayıs",
            oldYemeni: "أيار"
        ),
        MonthNameItem(
            number: 6,
            gregorianArabic: "يونيو",
            gregorianEnglish: "June",
            syriac: "حزيران",
            maghreb: "يونيو",
            amazigh: "Yunyu",
            coptic: "بؤونة",
            babylonian: "أيلولو",
            persian: "Shahrivar",
            turkish: "Haziran",
            oldYemeni: "حزيران"
        ),
        MonthNameItem(
            number: 7,
            gregorianArabic: "يوليو",
            gregorianEnglish: "July",
            syriac: "تموز",
            maghreb: "يوليوز",
            amazigh: "Yulyuz",
            coptic: "أبيب",
            babylonian: "تشريتو",
            persian: "Mehr",
            turkish: "Temmuz",
            oldYemeni: "تموز"
        ),
        MonthNameItem(
            number: 8,
            gregorianArabic: "أغسطس",
            gregorianEnglish: "August",
            syriac: "آب",
            maghreb: "غشت",
            amazigh: "ɣuct",
            coptic: "مسرى",
            babylonian: "أراخسمنو",
            persian: "Aban",
            turkish: "Ağustos",
            oldYemeni: "آب"
        ),
        MonthNameItem(
            number: 9,
            gregorianArabic: "سبتمبر",
            gregorianEnglish: "September",
            syriac: "أيلول",
            maghreb: "شتنبر",
            amazigh: "Cutanbir",
            coptic: "توت",
            babylonian: "كيسليمو",
            persian: "Azar",
            turkish: "Eylül",
            oldYemeni: "أيلول"
        ),
        MonthNameItem(
            number: 10,
            gregorianArabic: "أكتوبر",
            gregorianEnglish: "October",
            syriac: "تشرين الأول",
            maghreb: "أكتوبر",
            amazigh: "Ktuber",
            coptic: "بابه",
            babylonian: "تيبيتو",
            persian: "Dey",
            turkish: "Ekim",
            oldYemeni: "تشرين"
        ),
        MonthNameItem(
            number: 11,
            gregorianArabic: "نوفمبر",
            gregorianEnglish: "November",
            syriac: "تشرين الثاني",
            maghreb: "نونبر",
            amazigh: "Nwanbir",
            coptic: "هاتور",
            babylonian: "شباطو",
            persian: "Bahman",
            turkish: "Kasım",
            oldYemeni: "تشرين الثاني"
        ),
        MonthNameItem(
            number: 12,
            gregorianArabic: "ديسمبر",
            gregorianEnglish: "December",
            syriac: "كانون الأول",
            maghreb: "دجنبر",
            amazigh: "Dujanbir",
            coptic: "كيهك",
            babylonian: "آدارو",
            persian: "Esfand",
            turkish: "Aralık",
            oldYemeni: "كانون الأول"
        )
    ]
    
    private var selectedMonth: MonthNameItem {
        months[selectedMonthIndex]
    }
    
    private var result: MonthNamesConversionResult {
        MonthNamesConversionResult(month: selectedMonth)
    }

    private var pageBackground: Color {
        colorScheme == .light ? Color(hex: "#F7F9FC") : AppTheme.background
    }

    private var pickerCardBackground: Color {
        colorScheme == .light ? Color(hex: "#F8FAFF") : AppTheme.inputBackground.opacity(0.72)
    }

    private var noteCardBackground: Color {
        colorScheme == .light ? Color(hex: "#FFF9F2") : AppTheme.secondaryBackground.opacity(0.9)
    }

    private var cardBorder: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : AppTheme.border
    }

    private var cardShadow: Color {
        colorScheme == .light ? Color.black.opacity(0.08) : .clear
    }
    
    private func shareText(for result: MonthNamesConversionResult) -> String {
        """
        تحويل أسماء الأشهر:
        رقم الشهر: \(formatMonthNumber(result.month.number))
        الشهر الميلادي: \(result.month.gregorianArabic) - \(result.month.gregorianEnglish)

        السرياني / الشامي: \(result.month.syriac)
        المغرب العربي: \(result.month.maghreb)
        الأمازيغي: \(result.month.amazigh)
        القبطي: \(result.month.coptic)
        البابلي / الآشوري: \(result.month.babylonian)
        الفارسي: \(result.month.persian)
        التركي: \(result.month.turkish)
        اليمني القديم: \(result.month.oldYemeni)

        تم بواسطة تطبيق احسبها
        https://www.ahsebha.com
        """
    }
    
    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 20) {
                    headerSection
                    pickerCard
                    namesGrid
                    shareSection
                    noteCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var headerSection: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("تحويل أسماء الأشهر")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("اختر شهرًا ميلاديًا لعرض رقمه وأسمائه في تقاويم وثقافات مختلفة.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var pickerCard: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("اختر الشهر")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.indigo.opacity(colorScheme == .light ? 0.15 : 0.22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.indigo.opacity(colorScheme == .light ? 0.28 : 0.36), lineWidth: 1)
                    )
                    .frame(height: 50)
                    .allowsHitTesting(false)

                Picker("الشهر", selection: $selectedMonthIndex) {
                    ForEach(months.indices, id: \.self) { index in
                        Text("\(formatMonthNumber(months[index].number))  \(months[index].gregorianArabic)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.primaryText)
                            .tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .environment(\.locale, Locale(identifier: "ar"))
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 172)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(colorScheme == .light ? Color.white.opacity(0.74) : AppTheme.inputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.indigo.opacity(colorScheme == .light ? 0.12 : 0.22), lineWidth: 1)
                    )
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(pickerCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.indigo.opacity(colorScheme == .light ? 0.22 : 0.30), lineWidth: 1)
                )
        )
        .shadow(color: colorScheme == .light ? Color.indigo.opacity(0.10) : .clear, radius: colorScheme == .light ? 12 : 0, x: 0, y: colorScheme == .light ? 6 : 0)
        .shadow(color: cardShadow, radius: colorScheme == .light ? 8 : 0, x: 0, y: colorScheme == .light ? 3 : 0)
    }
    
    private var shareSection: some View {
        let generatedImage = resultCardImage(for: result)
        
        return ShareResultButton(
            text: shareText(for: result),
            sharedImage: generatedImage
        )
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(colorScheme == .light ? Color(hex: "#F8FAFC") : AppTheme.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(cardBorder, lineWidth: 1)
                )
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 8 : 0, x: 0, y: colorScheme == .light ? 4 : 0)
    }
    
    private var namesGrid: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("الأسماء المقابلة")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ],
                spacing: 8
            ) {
                MonthNameRow(title: "السرياني", value: selectedMonth.syriac, color: .blue)
                MonthNameRow(title: "المغرب", value: selectedMonth.maghreb, color: .orange)
                MonthNameRow(title: "الأمازيغي", value: selectedMonth.amazigh, color: .green)
                MonthNameRow(title: "القبطي", value: selectedMonth.coptic, color: .purple)
                MonthNameRow(title: "البابلي", value: selectedMonth.babylonian, color: .teal)
                MonthNameRow(title: "الفارسي", value: selectedMonth.persian, color: .pink)
                MonthNameRow(title: "التركي", value: selectedMonth.turkish, color: .cyan)
                MonthNameRow(title: "اليمني", value: selectedMonth.oldYemeni, color: .yellow)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(colorScheme == .light ? Color(hex: "#FBFCFF") : AppTheme.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(cardBorder, lineWidth: 1)
                )
        )
        .shadow(color: cardShadow, radius: colorScheme == .light ? 8 : 0, x: 0, y: colorScheme == .light ? 4 : 0)
    }
    
    private var noteCard: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("ملاحظة")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
            
            Text("قد تختلف بعض المسميات أو طريقة كتابتها حسب البلد أو المصدر التاريخي، لذلك تُعرض هذه الأسماء كمرجع مبسط للمقارنة.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(noteCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppTheme.buttonOrange.opacity(colorScheme == .light ? 0.16 : 0.22), lineWidth: 1)
                )
        )
    }

    private func formatMonthNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumIntegerDigits = 2
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    @MainActor
    private func resultCardImage(for result: MonthNamesConversionResult) -> UIImage? {
        ResultCardRenderer.render(
            title: "تحويل أسماء الأشهر",
            rows: [
                ResultCardRow(title: "الشهر المدخل", value: "\(formatMonthNumber(result.month.number)) - \(result.month.gregorianArabic)"),
                ResultCardRow(title: "رقم الشهر", value: formatMonthNumber(result.month.number)),
                ResultCardRow(title: "الميلادي", value: "\(result.month.gregorianArabic) - \(result.month.gregorianEnglish)", valueColor: AppTheme.buttonOrange),
                ResultCardRow(title: "السرياني / الشامي", value: result.month.syriac),
                ResultCardRow(title: "المغرب العربي", value: result.month.maghreb),
                ResultCardRow(title: "القبطي", value: result.month.coptic),
                ResultCardRow(title: "الفارسي", value: result.month.persian)
            ],
            note: "النتائج حسب جدول أسماء الأشهر المستخدم في التطبيق."
        )
    }
}

private struct MonthNamesConversionResult {
    let month: MonthNameItem
}

struct MonthNameItem {
    let number: Int
    let gregorianArabic: String
    let gregorianEnglish: String
    let syriac: String
    let maghreb: String
    let amazigh: String
    let coptic: String
    let babylonian: String
    let persian: String
    let turkish: String
    let oldYemeni: String
}

struct MonthNameRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.65)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.55)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(color.opacity(colorScheme == .light ? 0.075 : 0.11))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(color.opacity(colorScheme == .light ? 0.20 : 0.28), lineWidth: 1)
                )
        )
        .shadow(color: colorScheme == .light ? color.opacity(0.05) : .clear, radius: colorScheme == .light ? 5 : 0, x: 0, y: colorScheme == .light ? 2 : 0)
    }
}

#Preview {
    NavigationStack {
        MonthNamesConverterView()
    }
}
