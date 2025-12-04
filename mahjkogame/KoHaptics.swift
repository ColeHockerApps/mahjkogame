import Combine
import SwiftUI
import UIKit

final class KoHaptics: ObservableObject {

    static let shared = KoHaptics()

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let rigid = UIImpactFeedbackGenerator(style: .rigid)
    private let notice = UINotificationFeedbackGenerator()
 
    func tapLight() {
        light.prepare()
        light.impactOccurred(intensity: 0.55)
    }

    func tapSoft() {
        soft.prepare()
        soft.impactOccurred(intensity: 0.45)
    }

    func tapMedium() {
        medium.prepare()
        medium.impactOccurred(intensity: 0.75)
    }

    func tapRigid() {
        rigid.prepare()
        rigid.impactOccurred(intensity: 1.0)
    }

    func success() {
        notice.prepare()
        notice.notificationOccurred(.success)
    }

    func warning() {
        notice.prepare()
        notice.notificationOccurred(.warning)
    }

    func error() {
        notice.prepare()
        notice.notificationOccurred(.error)
    }
}
