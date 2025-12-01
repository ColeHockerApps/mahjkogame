import Combine
import SwiftUI
import Foundation

final class PathLedger: ObservableObject {
    @Published var mainEntry: URL
    @Published var policyEntry: URL

    private let mainKey = "mahjko.main.entry"
    private let policyKey = "mahjko.policy.entry"
    private let trailKey = "mahjko.stored.trail"
    private let marksKey = "mahjko.stored.marks"

    init() {
        let defaults = UserDefaults.standard

        let defaultMain = "https://malikdanar.github.io/tilesaga/"
        let defaultPolicy = "https://malikdanar.github.io/app-privacy/privacy.html"

        if let stored = defaults.string(forKey: mainKey),
           let url = URL(string: stored) {
            mainEntry = url
        } else {
            mainEntry = URL(string: defaultMain)!
        }

        if let stored = defaults.string(forKey: policyKey),
           let url = URL(string: stored) {
            policyEntry = url
        } else {
            policyEntry = URL(string: defaultPolicy)!
        }
    }

    func updateMain(_ value: String) {
        guard let url = URL(string: value) else { return }
        mainEntry = url
        UserDefaults.standard.set(value, forKey: mainKey)
    }

    func updatePolicy(_ value: String) {
        guard let url = URL(string: value) else { return }
        policyEntry = url
        UserDefaults.standard.set(value, forKey: policyKey)
    }

    // MARK: - Trail

    func storeTrailIfNeeded(_ url: URL) {
        let current = UserDefaults.standard.string(forKey: trailKey)
        if current == nil {
            UserDefaults.standard.set(url.absoluteString, forKey: trailKey)
        }
    }

    func restoreStoredTrail() -> URL? {
        guard let stored = UserDefaults.standard.string(forKey: trailKey) else { return nil }
        return URL(string: stored)
    }

    // MARK: - Marks

    func saveMarks(_ items: [[String: Any]]) {
        UserDefaults.standard.set(items, forKey: marksKey)
    }

    func restoreMarks() -> [[String: Any]]? {
        UserDefaults.standard.array(forKey: marksKey) as? [[String: Any]]
    }
}
