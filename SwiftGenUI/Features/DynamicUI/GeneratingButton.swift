
import SwiftUI

struct GeneratingButton: View {
    let title: String
    let isGenerating: Bool
    let cancelAction: () -> Void
    let action: () -> Void

    @State private var progress: CGFloat = 0
    @State private var loadingCycle = 0

    var body: some View {
        HStack(spacing: 10) {
            Button(action: action) {
                buttonContent
            }
            .buttonStyle(.plain)
            .disabled(isGenerating)

            if isGenerating {
                Button(action: cancelAction) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#B86161"), Color(hex: "#7A3038")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.20), lineWidth: 1)
                        }
                        .shadow(color: Color(hex: "#7A3038").opacity(0.26), radius: 14, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.86).combined(with: .opacity).combined(with: .move(edge: .trailing)),
                    removal: .scale(scale: 0.86).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: isGenerating)
        .onAppear {
            updateProgress()
        }
        .onChange(of: isGenerating) { _, _ in
            updateProgress()
        }
        .onChange(of: loadingCycle) { _, _ in
            continueLoadingIfNeeded()
        }
    }

    private var buttonContent: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(isGenerating ? 0.12 : 0.14))

            if isGenerating {
                LinearGradient(
                    colors: [
                        Color(hex: "#A7F3FF").opacity(0.78),
                        Color(hex: "#B8A7FF").opacity(0.74),
                        Color(hex: "#FFB7D5").opacity(0.70),
                        Color(hex: "#FFD88A").opacity(0.76)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            LinearGradient(
                colors: fillColors,
                startPoint: .leading,
                endPoint: .trailing
            )
            .mask(alignment: .leading) {
                if isGenerating {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .white.opacity(0.70), location: 0.14),
                            .init(color: .white, location: 0.34),
                            .init(color: .white, location: 0.76),
                            .init(color: .white.opacity(0.66), location: 0.90),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .scaleEffect(x: progress, y: 1, anchor: .leading)
                } else {
                    RoundedRectangle(cornerRadius: 18)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))

            if isGenerating {
                GeometryReader { proxy in
                    let sweepWidth = max(proxy.size.width * 0.20, 64)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(0.52),
                                    Color(hex: "#E4D9FF").opacity(0.42),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: sweepWidth)
                        .frame(height: proxy.size.height * 1.35)
                        .offset(x: progress * (proxy.size.width + sweepWidth) - sweepWidth)
                        .offset(y: -proxy.size.height * 0.18)
                        .blur(radius: 10)
                        .opacity(0.92)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            LinearGradient(
                colors: [
                    Color.white.opacity(isGenerating ? 0.22 : 0.34),
                    Color.white.opacity(0.02),
                    Color.black.opacity(isGenerating ? 0.04 : 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack(spacing: 12) {
                Image(systemName: isGenerating ? "hourglass" : "sparkles")
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
                Spacer()
                Image(systemName: isGenerating ? "sparkles" : "arrow.right")
            }
            .font(.system(size: 16, weight: .semibold, design: .default))
            .foregroundStyle(Color(hex: "#10131A"))
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(isGenerating ? 0.56 : 0.34), lineWidth: 1)
        }
        .shadow(color: Color(hex: "#A7F3FF").opacity(isGenerating ? 0.40 : 0.14), radius: isGenerating ? 30 : 16, x: -12, y: 8)
        .shadow(color: Color(hex: "#B8A7FF").opacity(isGenerating ? 0.36 : 0.16), radius: isGenerating ? 34 : 18, x: 10, y: 10)
        .shadow(color: Color(hex: "#FFB7D5").opacity(isGenerating ? 0.30 : 0.12), radius: isGenerating ? 28 : 14, x: 0, y: 12)
    }

    private var fillColors: [Color] {
        if isGenerating {
            return [
                Color(hex: "#A7F3FF"),
                Color(hex: "#E4D9FF"),
                Color(hex: "#FFC4DE"),
                Color(hex: "#FFE7A6")
            ]
        }

        return [
            Color(hex: "#A7F3FF"),
            Color(hex: "#B8A7FF"),
            Color(hex: "#FFB7D5"),
            Color(hex: "#FFD88A")
        ]
    }

    private func updateProgress() {
        guard isGenerating else {
            withAnimation(.easeOut(duration: 0.18)) {
                progress = 1
            }
            return
        }

        progress = 0

        withAnimation(.easeInOut(duration: 1.15)) {
            progress = 1
        }

        continueLoadingIfNeeded()
    }

    private func continueLoadingIfNeeded() {
        guard isGenerating else { return }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.15))
            guard isGenerating else { return }

            progress = 0

            withAnimation(.easeInOut(duration: 1.15)) {
                progress = 1
            }

            loadingCycle += 1
        }
    }
}
