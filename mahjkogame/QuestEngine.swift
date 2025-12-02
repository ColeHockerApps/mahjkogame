import Combine
import SwiftUI

enum QuestKind: String, Codable {
    case openBoards
    case calmMinutes
    case streakDays
}

struct DailyQuest: Identifiable, Codable, Equatable {
    let id: String
    let kind: QuestKind
    let title: String
    let detail: String
    let target: Int
    var progress: Int

    var isCompleted: Bool {
        progress >= target
    }

    var progressRatio: Double {
        guard target > 0 else { return 0 }
        let value = min(progress, target)
        return Double(value) / Double(target)
    }
}

final class QuestEngine: ObservableObject {
    @Published private(set) var quests: [DailyQuest] = []

    private let dayKey = "quests.day.token"
    private let dataKey = "quests.data.payload"

    private let calendar = Calendar.current

    init() {
        restore()
        ensureToday()
    }

    func registerBoardOpened() {
        updateQuest(kind: .openBoards) { quest in
            var copy = quest
            copy.progress += 1
            return copy
        }
    }

    func registerMinutes(_ deltaSeconds: TimeInterval) {
        guard deltaSeconds > 0 else { return }
        let minutes = Int(deltaSeconds / 60.0)
        guard minutes > 0 else { return }

        updateQuest(kind: .calmMinutes) { quest in
            var copy = quest
            copy.progress += minutes
            return copy
        }
    }

    func syncStreakValue(_ streak: Int) {
        guard streak > 0 else { return }

        updateQuest(kind: .streakDays) { quest in
            var copy = quest
            copy.progress = min(streak, quest.target)
            return copy
        }
    }

    func resetForToday() {
        let token = dayToken(for: Date())
        UserDefaults.standard.set(token, forKey: dayKey)
        quests = makeQuests(for: token)
        persist()
    }

    func clearAll() {
        quests = []
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: dayKey)
        defaults.removeObject(forKey: dataKey)
    }

    // MARK: - Private

    private func ensureToday() {
        let defaults = UserDefaults.standard
        let todayToken = dayToken(for: Date())
        let storedToken = defaults.integer(forKey: dayKey)

        if storedToken == 0 || storedToken != todayToken {
            defaults.set(todayToken, forKey: dayKey)
            quests = makeQuests(for: todayToken)
            persist()
        }
    }

    private func updateQuest(kind: QuestKind, transform: (DailyQuest) -> DailyQuest) {
        guard quests.isEmpty == false else { return }

        var changed = quests
        var didChange = false

        for index in changed.indices {
            if changed[index].kind == kind, changed[index].isCompleted == false {
                let updated = transform(changed[index])
                if updated != changed[index] {
                    changed[index] = updated
                    didChange = true
                }
            }
        }

        if didChange {
            quests = changed
            persist()
        }
    }

    private func restore() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: dataKey) else { return }

        do {
            let decoded = try JSONDecoder().decode([DailyQuest].self, from: data)
            quests = decoded
        } catch {
            quests = []
        }
    }

    private func persist() {
        let defaults = UserDefaults.standard
        do {
            let data = try JSONEncoder().encode(quests)
            defaults.set(data, forKey: dataKey)
        } catch {
            // ignore encoding issues for now
        }
    }

    private func dayToken(for date: Date) -> Int {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        return y * 10_000 + m * 100 + d
    }

    private func makeQuests(for token: Int) -> [DailyQuest] {
        let seed = token % 7

        let sessionsTarget: Int
        let minutesTarget: Int
        let streakTarget: Int

        switch seed {
        case 0:
            sessionsTarget = 2
            minutesTarget = 5
            streakTarget = 3
        case 1:
            sessionsTarget = 3
            minutesTarget = 8
            streakTarget = 3
        case 2:
            sessionsTarget = 2
            minutesTarget = 10
            streakTarget = 4
        case 3:
            sessionsTarget = 3
            minutesTarget = 12
            streakTarget = 5
        case 4:
            sessionsTarget = 4
            minutesTarget = 10
            streakTarget = 3
        case 5:
            sessionsTarget = 2
            minutesTarget = 15
            streakTarget = 4
        default:
            sessionsTarget = 3
            minutesTarget = 7
            streakTarget = 3
        }

        let q1 = DailyQuest(
            id: "openBoards",
            kind: .openBoards,
            title: "Start a few boards",
            detail: "Open the board \(sessionsTarget) times today.",
            target: sessionsTarget,
            progress: 0
        )

        let q2 = DailyQuest(
            id: "calmMinutes",
            kind: .calmMinutes,
            title: "Calm play time",
            detail: "Stay in the board for \(minutesTarget) minutes total.",
            target: minutesTarget,
            progress: 0
        )

        let q3 = DailyQuest(
            id: "streakDays",
            kind: .streakDays,
            title: "Keep your streak",
            detail: "Reach a streak of \(streakTarget) days.",
            target: streakTarget,
            progress: 0
        )

        return [q1, q2, q3]
    }
}
