import WidgetKit
import SwiftUI

let widgetDefaults = UserDefaults(
    suiteName: "group.com.soliman.ahsebha"
)!

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 60)))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct AhsebhaWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family
    
    private var favoriteTools: [String] {
        readTitles(forKey: "favoriteToolTitles")
            .map { displayName($0) }
            .prefix(3)
            .map { $0 }
    }
    
    private var recentTools: [String] {
        readTitles(forKey: "recentToolTitles")
            .map { displayName($0) }
            .prefix(3)
            .map { $0 }
    }
    
    private var fallbackTools: [String] {
        [
            "المعدل التراكمي",
            "النسبة الموزونة",
            "الضريبة"
        ]
    }
    
    private var widgetTools: [String] {
        if !favoriteTools.isEmpty {
            return favoriteTools
        }
        
        if !recentTools.isEmpty {
            return recentTools
        }
        
        return fallbackTools
    }
    
    var body: some View {
        if family == .systemSmall {
            smallWidget
        } else {
            mediumWidget
        }
    }
    
    private var smallWidget: some View {
        VStack(alignment: .trailing, spacing: 8) {
            header
            
            Text(favoriteTools.isEmpty ? "الأدوات السريعة" : "أدواتك المفضلة")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.76))
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .trailing, spacing: 7) {
                ForEach(widgetTools.prefix(3), id: \.self) { tool in
                    WidgetSmallToolRow(title: tool)
                }
            }
            
            Spacer(minLength: 2)
            
            Text("افتح أدواتك بسرعة")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.62))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.top, 22)
        .padding(.horizontal, 18)
        .padding(.bottom, 24)
    }
    
    private var mediumWidget: some View {
        VStack(alignment: .trailing, spacing: 12) {
            header
            
            Text(favoriteTools.isEmpty ? "اختصارات مقترحة" : "أدواتك المفضلة")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.72))
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            HStack(spacing: 10) {
                ForEach(widgetTools, id: \.self) { tool in
                    WidgetFavoriteBox(title: tool)
                }
            }
            
            Text("يتم تحديث الويدجت حسب المفضلة داخل التطبيق")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.62))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
    }
    
    private var header: some View {
        HStack {
            Image(systemName: "plus.forwardslash.minus")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("احسبها")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    private func readTitles(forKey key: String) -> [String] {
        let text = widgetDefaults.string(forKey: key) ?? ""
        
        if let data = text.data(using: .utf8),
           let titles = try? JSONDecoder().decode([String].self, from: data) {
            return titles
        }
        
        return text
            .split(separator: "|")
            .map { String($0) }
    }
    
    private func displayName(_ fullName: String) -> String {
        switch fullName {
        case "حاسبة المعدل التراكمي":
            return "المعدل التراكمي"
        case "حاسبة النسبة الموزونة":
            return "النسبة الموزونة"
        case "حاسبة النسبة المئوية":
            return "النسبة المئوية"
        case "حاسبة الخصم":
            return "الخصم"
        case "حاسبة الضريبة":
            return "الضريبة"
        case "حاسبة العمر":
            return "العمر"
        case "تحويل أسماء الأشهر":
            return "أسماء الأشهر"
        case "تحويل التاريخ":
            return "تحويل التاريخ"
        default:
            return fullName
        }
    }
}

struct WidgetSmallToolRow: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: iconName(for: title))
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(Color.white.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private func iconName(for title: String) -> String {
        switch title {
        case "المعدل التراكمي":
            return "graduationcap.fill"
        case "النسبة الموزونة":
            return "chart.bar.fill"
        case "النسبة المئوية":
            return "percent"
        case "الخصم":
            return "tag.fill"
        case "الضريبة":
            return "plus.forwardslash.minus"
        case "العمر":
            return "calendar"
        case "أسماء الأشهر":
            return "calendar.badge.clock"
        case "تحويل التاريخ":
            return "calendar.badge.clock"
        default:
            return "square.grid.2x2.fill"
        }
    }
}

struct WidgetFavoriteBox: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName(for: title))
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 78)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.22))
        )
    }
    
    private func iconName(for title: String) -> String {
        switch title {
        case "المعدل التراكمي":
            return "graduationcap.fill"
        case "النسبة الموزونة":
            return "chart.bar.fill"
        case "النسبة المئوية":
            return "percent"
        case "الخصم":
            return "tag.fill"
        case "الضريبة":
            return "plus.forwardslash.minus"
        case "العمر":
            return "calendar"
        case "أسماء الأشهر":
            return "calendar.badge.clock"
        case "تحويل التاريخ":
            return "calendar.badge.clock"
        default:
            return "square.grid.2x2.fill"
        }
    }
}

struct AhsebhaWidget: Widget {
    let kind: String = "AhsebhaWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            AhsebhaWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.08, blue: 0.14),
                            Color(red: 0.10, green: 0.14, blue: 0.23),
                            Color(red: 0.95, green: 0.50, blue: 0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("احسبها")
        .description("يعرض أدواتك المفضلة من تطبيق احسبها.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var preview: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🧮"
        return intent
    }
}

#Preview(as: .systemSmall) {
    AhsebhaWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .preview)
}

#Preview(as: .systemMedium) {
    AhsebhaWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .preview)
}
