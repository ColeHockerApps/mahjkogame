import Combine
import SwiftUI

final class DailyPopupViewModel: ObservableObject {
    @Published var fadeIn: Bool = false
    @Published var scale: CGFloat = 0.9
    @Published var messageTitle: String = ""
    @Published var messageBody: String = ""

    init() {
        let store = PopupMessageStore()
        let message = store.randomMessage()
        messageTitle = message.title
        messageBody = message.body
    }

    func onAppear() {
        withAnimation(.easeOut(duration: 0.25)) {
            fadeIn = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.1)) {
            scale = 1.0
        }
    }

    func close(flow: FlowLines) {
        KoHaptics.shared.tapSoft()
        flow.goHub()
    }
}
