import SwiftUI
import UIKit

@main
struct AhsebhaCalculatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("lastSeenVersion") private var lastSeenVersion = ""
    @AppStorage(AppAppearance.storageKey) private var selectedAppearanceRawValue: String = AppAppearance.system.rawValue
    private let currentVersion = "1.1"
    
    var body: some Scene {
        WindowGroup {

            ContentView()
                .preferredColorScheme(AppAppearance.fromStoredValue(selectedAppearanceRawValue).colorScheme)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureQuickActions()
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            QuickActionStore.pendingAction = shortcutItem.type
        }
        
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    private func configureQuickActions() {
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(
                type: QuickActionType.gpa.rawValue,
                localizedTitle: "المعدل التراكمي",
                localizedSubtitle: "افتح حاسبة المعدل",
                icon: UIApplicationShortcutIcon(systemImageName: "graduationcap.fill")
            ),
            UIApplicationShortcutItem(
                type: QuickActionType.weighted.rawValue,
                localizedTitle: "النسبة الموزونة",
                localizedSubtitle: "احسب نسبة القبول",
                icon: UIApplicationShortcutIcon(systemImageName: "chart.bar.fill")
            ),
            UIApplicationShortcutItem(
                type: QuickActionType.age.rawValue,
                localizedTitle: "حاسبة العمر",
                localizedSubtitle: "ميلادي وهجري",
                icon: UIApplicationShortcutIcon(systemImageName: "calendar")
            ),
            UIApplicationShortcutItem(
                type: QuickActionType.dateConverter.rawValue,
                localizedTitle: "تحويل التاريخ",
                localizedSubtitle: "ميلادي ↔ هجري",
                icon: UIApplicationShortcutIcon(systemImageName: "calendar.badge.clock")
            )
        ]
    }
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        QuickActionStore.pendingAction = shortcutItem.type
        
        NotificationCenter.default.post(
            name: .quickActionSelected,
            object: shortcutItem.type
        )
        
        completionHandler(true)
    }
}

enum QuickActionType: String, Identifiable {
    case gpa = "quick.gpa"
    case weighted = "quick.weighted"
    case age = "quick.age"
    case dateConverter = "quick.dateConverter"
    
    var id: String { rawValue }
}

enum QuickActionStore {
    static var pendingAction: String? {
        get {
            UserDefaults.standard.string(forKey: "PendingQuickAction")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "PendingQuickAction")
        }
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: "PendingQuickAction")
    }
}

extension Notification.Name {
    static let quickActionSelected = Notification.Name("quickActionSelected")
}
