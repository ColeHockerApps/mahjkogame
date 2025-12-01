import Combine
import SwiftUI

@main
struct MahjKoApp: App {
    @StateObject private var theme = KoTheme()
    @StateObject private var palette = KoPalette()
    @StateObject private var icons = KoIcons()
    @StateObject private var haptics = KoHaptics()
    @StateObject private var ledger = PathLedger()
    @StateObject private var echo = StarEcho()
    @StateObject private var flow = FlowLines()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(theme)
                .environmentObject(palette)
                .environmentObject(icons)
                .environmentObject(haptics)
                .environmentObject(ledger)
                .environmentObject(echo)
                .environmentObject(flow)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var flow: FlowLines
    @EnvironmentObject private var theme: KoTheme

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            switch flow.current {
            case .hub:
                HubScreen()
            case .board:
                BoardStage()
            case .settings:
                SettingsScreen()
            case .rules:
                RulesScreen()
            case .policy:
                PolicyScreen()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: flow.current)
    }
}
