import Combine
import SwiftUI

enum KoRoute: Equatable {
    case hub
    case board
    case settings
    case rules
    case policy
}

final class FlowLines: ObservableObject {
    @Published var current: KoRoute = .hub

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

    func closeCurrent() {
        current = .hub
    }
}
