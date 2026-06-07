import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var selectedTab: MainTab = .calculator
    @State private var selectedQuickAction: QuickActionType?
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage("appOpenCount") private var appOpenCount = 0
    @AppStorage("hasRequestedAppReview") private var hasRequestedAppReview = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalculatorView()
                .tabItem {
                    Image(systemName: "plus.forwardslash.minus")
                    Text("الحاسبة")
                }
                .tag(MainTab.calculator)
            
            ToolsView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("الأدوات")
                }
                .tag(MainTab.tools)
            
            AhsebhaView()
                .tabItem {
                    Image(systemName: "safari")
                    Text("احسبها")
                }
                .tag(MainTab.ahsebha)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("الإعدادات")
                }
                .tag(MainTab.settings)
        }
        .tint(AppTheme.buttonOrange)
        .onAppear {
            trackAppOpenAndRequestReviewIfNeeded()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                handlePendingQuickAction()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    handlePendingQuickAction()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .quickActionSelected)) { notification in
            guard let type = notification.object as? String else { return }
            openQuickAction(type)
        }
        .sheet(item: $selectedQuickAction) { action in
            NavigationStack {
                quickActionDestination(for: action)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("إغلاق") {
                                selectedQuickAction = nil
                            }
                            .foregroundColor(AppTheme.buttonOrange)
                        }
                    }
            }
        }
    }
    
    private func trackAppOpenAndRequestReviewIfNeeded() {
        guard !hasRequestedAppReview else { return }
        
        appOpenCount += 1
        
        guard appOpenCount >= 5 else { return }
        
        hasRequestedAppReview = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            requestAppReview()
        }
    }
    
    private func requestAppReview() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            return
        }
        
        SKStoreReviewController.requestReview(in: windowScene)
    }
    
    private func handlePendingQuickAction() {
        guard let type = QuickActionStore.pendingAction else {
            return
        }
        
        QuickActionStore.clear()
        openQuickAction(type)
    }
    
    private func openQuickAction(_ type: String) {
        guard let action = QuickActionType(rawValue: type) else {
            return
        }
        
        selectedTab = .tools
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            selectedQuickAction = action
        }
    }
    
    @ViewBuilder
    private func quickActionDestination(for action: QuickActionType) -> some View {
        switch action {
        case .gpa:
            GPACalculatorView()
        case .weighted:
            WeightedPercentageView()
        case .age:
            AgeCalculatorView()
        case .dateConverter:
            DateConverterView()
        }
    }
}

enum MainTab {
    case calculator
    case tools
    case ahsebha
    case settings
}

#Preview {
    ContentView()
}
