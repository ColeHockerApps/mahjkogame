import Combine
import SwiftUI

struct DailyPopupScreen: View {
    @EnvironmentObject private var flow: FlowLines
    @StateObject private var vm = DailyPopupViewModel()

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            popup
                .scaleEffect(vm.scale)
                .opacity(vm.fadeIn ? 1 : 0)
                .animation(.easeOut(duration: 0.25), value: vm.fadeIn)
        }
        .onAppear {
            vm.onAppear()
        }
    }

    private var popup: some View {
        VStack(spacing: 18) {
            Text(vm.messageTitle)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text(vm.messageBody)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button {
                vm.close(flow: flow)
            } label: {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 34)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [KoPalette.accent, KoPalette.accentDeep],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 6)
        .padding(.horizontal, 30)
    }
}
