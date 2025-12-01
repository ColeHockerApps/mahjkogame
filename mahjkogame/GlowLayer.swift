import Combine
import SwiftUI

struct GlowLayer: View {
    @State private var shiftA: CGFloat = .random(in: -40...40)
    @State private var shiftB: CGFloat = .random(in: -40...40)
    @State private var pulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.88, blue: 0.55).opacity(0.45),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 240
                    )
                )
                .scaleEffect(pulse)
                .offset(x: shiftA, y: shiftB)
                .blur(radius: 30)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.65, blue: 0.35).opacity(0.35),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 260
                    )
                )
                .scaleEffect(pulse * 1.15)
                .offset(x: -shiftA, y: -shiftB)
                .blur(radius: 40)
        }
        .allowsHitTesting(false)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        withAnimation(Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            pulse = 1.25
        }

        withAnimation(Animation.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
            shiftA = .random(in: -60...60)
            shiftB = .random(in: -60...60)
        }
    }
}
