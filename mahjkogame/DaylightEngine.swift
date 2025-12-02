import Combine
import SwiftUI

enum DaylightPhase: String, CaseIterable {
    case morning
    case day
    case evening
    case night

    var label: String {
        switch self {
        case .morning:
            return "Morning light"
        case .day:
            return "Day glow"
        case .evening:
            return "Evening calm"
        case .night:
            return "Night focus"
        }
    }
}

final class DaylightEngine: ObservableObject {
    @Published private(set) var current: DaylightPhase = .day

    private let calendar = Calendar.current

    init() {
        current = phase(for: Date())
    }

    func refreshNow() {
        current = phase(for: Date())
    }

    func phaseLabel() -> String {
        current.label
    }

    func isEveningOrNight() -> Bool {
        switch current {
        case .evening, .night:
            return true
        default:
            return false
        }
    }

    private func phase(for date: Date) -> DaylightPhase {
        let hour = calendar.component(.hour, from: date)

        switch hour {
        case 5..<11:
            return .morning
        case 11..<18:
            return .day
        case 18..<22:
            return .evening
        default:
            return .night
        }
    }
}
