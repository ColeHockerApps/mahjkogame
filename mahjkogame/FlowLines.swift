import Combine
import SwiftUI

enum KoRoute: Equatable {
    case onboarding
    case hub
    case board
    case settings
    case rules
    case policy
    case tutorial
    case dailyPopup
}

final class FlowLines: ObservableObject {
    @Published var current: KoRoute

    init() {
        let seen = UserDefaults.standard.bool(forKey: "onboarding.seen")
        current = seen ? .hub : .onboarding
    }

    func startOnboarding() {
        current = .onboarding
    }

    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboarding.seen")
        current = .hub
    }

    func goHub() {
        current = .hub
    }

    func goBoard() {
        current = .board
    }

    func goSettings() {
        current = .settings
    }

    func goRules() {
        current = .rules
    }

    func goPolicy() {
        current = .policy
    }

    func goTutorial() {
        current = .tutorial
    }

    func goDailyPopup() {
        current = .dailyPopup
    }

    func closeCurrent() {
        current = .hub
    }
}
