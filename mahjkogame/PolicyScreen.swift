import Combine
import SwiftUI
import WebKit

struct PolicyScreen: View {
    @EnvironmentObject private var theme: KoTheme
    @EnvironmentObject private var flow: FlowLines
    @EnvironmentObject private var ledger: PathLedger
    @StateObject private var vm = PolicyViewModel()

    @State private var isLoaded: Bool = false

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            GlowLayer()

            VStack(spacing: 24) {
                header
                    .padding(.top, 28)
                    .padding(.horizontal, 26)

                policyBlock
                    .padding(.horizontal, 26)
                    .frame(maxWidth: 600, maxHeight: .infinity)

                Spacer()

                closeButton
                    .padding(.bottom, 28)
                    .padding(.horizontal, 26)
            }
            .opacity(vm.fadeIn ? 1 : 0)
            .animation(.easeOut(duration: 0.3), value: vm.fadeIn)

            if !isLoaded {
                loadingOverlay
            }
        }
        .onAppear {
            isLoaded = false
            vm.onAppear()
        }
    }

    private var header: some View {
        HStack {
            Text("Privacy policy")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(KoPalette.textPrimary)
                .shadow(color: KoPalette.softShadow, radius: 8, x: 0, y: 3)

            Spacer()
        }
    }

    private var policyBlock: some View {
        PolicyHost(entry: ledger.policyEntry) {
            withAnimation(.easeOut(duration: 0.25)) {
                isLoaded = true
            }
        }
        .cornerRadius(16)
        .shadow(color: KoPalette.softShadow, radius: 10, x: 0, y: 4)
    }

    private var closeButton: some View {
        Button {
            vm.close(flow: flow)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: KoIcons.back)
                    .font(.system(size: 16, weight: .semibold))

                Text("Back")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(KoPalette.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(KoPalette.card)
                    .shadow(color: KoPalette.softShadow, radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.08)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                ProgressView()
                    .scaleEffect(1.1)

                Text("Loading details…")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(KoPalette.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(KoPalette.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(KoPalette.borderSoft, lineWidth: 1)
                    )
                    .shadow(color: KoPalette.softShadow, radius: 10, x: 0, y: 6)
            )
        }
        .transition(.opacity)
    }
}

// MARK: - ViewModel

final class PolicyViewModel: ObservableObject {
    @Published var fadeIn: Bool = false

    func onAppear() {
        withAnimation(.easeOut(duration: 0.3)) {
            fadeIn = true
        }
    }

    func close(flow: FlowLines) {
        KoHaptics.shared.tapSoft()
        flow.closeCurrent()
    }
}

// MARK: - Host

struct PolicyHost: UIViewRepresentable {
    let entry: URL
    let onFinish: () -> Void

    func makeCoordinator() -> PolicyGuide {
        PolicyGuide(onFinish: onFinish)
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)
        view.navigationDelegate = context.coordinator
        view.isOpaque = false
        view.backgroundColor = .clear
        view.scrollView.backgroundColor = .clear
        view.scrollView.alwaysBounceVertical = true

        let request = URLRequest(url: entry)
        view.load(request)

        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

final class PolicyGuide: NSObject, WKNavigationDelegate {
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onFinish()
    }

    func webView(_ webView: WKWebView,
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        onFinish()
    }

    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        onFinish()
    }
}
