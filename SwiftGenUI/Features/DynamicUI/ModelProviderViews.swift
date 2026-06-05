
import ComposableArchitecture
import SwiftUI

struct ModelProviderButton: View {
    let provider: LLMProvider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                ProviderBrandIcon(provider: provider, fallbackSystemImage: provider.systemImage)
                    .frame(width: 34, height: 34)
                    .background(iconBackground, in: RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    }

                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(AppTheme.cream.opacity(0.58))
            }
            .padding(.leading, 7)
            .padding(.trailing, 9)
            .frame(height: 54)
            .background(Color(hex: "#121A20"), in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(0.09), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.16), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Select AI model provider")
    }

    private var iconBackground: some ShapeStyle {
        LinearGradient(
            colors: provider.iconBackgroundColors(isSelected: false),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct ModelProviderSheet: View {
    @Bindable var store: StoreOf<DynamicUIFeature>

    var body: some View {
        NavigationStack(path: configurationPath) {
            providerList
                .navigationDestination(for: ProviderConfigurationRoute.self) { route in
                    ProviderConfigurationView(
                        provider: route.provider,
                        configuration: $store.customEndpointConfiguration,
                        backAction: {
                            store.send(.providerConfigDismissed)
                        }
                    )
                }
        }
        .tint(AppTheme.cream)
    }

    private var configurationPath: Binding<[ProviderConfigurationRoute]> {
        Binding(
            get: {
                if let configuredProvider = store.configuredProvider {
                    return [ProviderConfigurationRoute(provider: configuredProvider)]
                }

                return []
            },
            set: { routes in
                if routes.isEmpty {
                    store.send(.providerConfigDismissed)
                }
            }
        )
    }

    private var providerList: some View {
        ProviderSheetBackground {
            VStack(alignment: .leading, spacing: 18) {
                providerHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(LLMProvider.allCases, id: \.self) { provider in
                            ProviderOptionRow(
                                provider: provider,
                                title: provider.sheetTitle,
                                subtitle: provider.subtitle,
                                systemImage: provider.systemImage,
                                isSelected: store.selectedProvider == provider,
                                configureAction: provider == .localOllama ? nil : {
                                    store.send(.providerConfigureTapped(provider))
                                }
                            ) {
                                store.send(.providerSelected(provider))
                            }
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 18)
        }
        .navigationBarHidden(true)
    }

    private var providerHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Model Routing")
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.mutedText)

                Text("AI Provider")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundStyle(.white)

                Text("Choose where generated UI requests will run.")
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundStyle(AppTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 5) {
                Text(store.selectedProvider.pipelineValue)
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(.white.opacity(0.90))

                Text("Active")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.mutedText)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#121A20"), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.055), lineWidth: 1)
        }
    }
}

private struct ProviderOptionRow: View {
    let provider: LLMProvider
    let title: String
    let subtitle: String
    let systemImage: String
    let isSelected: Bool
    let configureAction: (() -> Void)?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ProviderBrandIcon(provider: provider, fallbackSystemImage: systemImage)
                    .frame(width: 42, height: 42)
                    .background(iconBackground, in: RoundedRectangle(cornerRadius: 15))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.white.opacity(isSelected ? 0.28 : 0.12), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundStyle(AppTheme.mutedText)
                        .lineLimit(2)
                }

                Spacer(minLength: 12)

                configureButton

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .foregroundStyle(Color(hex: "#0B1015"))
                        .frame(width: 26, height: 26)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#B9E6BE"),
                                    Color(hex: "#7FCA8B")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: Circle()
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .padding(12)
        .background(Color(hex: isSelected ? "#151F27" : "#10161C"), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(isSelected ? 0.13 : 0.07), lineWidth: 1)
        }
    }

    private var iconBackground: some ShapeStyle {
        LinearGradient(
            colors: provider.iconBackgroundColors(isSelected: isSelected),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    @ViewBuilder
    private var configureButton: some View {
        if let configureAction {
            Button(action: configureAction) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))
                    .frame(width: 34, height: 34)
                    .background(Color(hex: "#1A232B"), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Configure \(title)")
        }
    }
}

private struct ProviderConfigurationRoute: Identifiable, Equatable, Hashable {
    let provider: LLMProvider

    var id: LLMProvider {
        provider
    }
}

private struct ProviderSheetBackground<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color(hex: "#080B10")

            LinearGradient(
                colors: [
                    Color.white.opacity(0.035),
                    Color.clear,
                    Color.black.opacity(0.28)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            content
        }
        .ignoresSafeArea()
    }
}

private struct ProviderConfigurationView: View {
    let provider: LLMProvider
    @Binding var configuration: CustomEndpointConfiguration
    let backAction: () -> Void

    var body: some View {
        ProviderSheetBackground {
            VStack(alignment: .leading, spacing: 18) {
                Button(action: backAction) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 46, height: 46)
                        .foregroundStyle(AppTheme.cream)
                        .background(.white.opacity(0.09), in: Circle())
                        .overlay {
                            Circle()
                                .stroke(.white.opacity(0.14), lineWidth: 1)
                        }
                        .shadow(color: Color.black.opacity(0.22), radius: 16, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 4)

                configurationHeader

                VStack(alignment: .leading, spacing: 12) {
                    ProviderTextField(
                        title: "Base URL",
                        placeholder: provider.defaultConfiguration.baseURL,
                        text: $configuration.baseURL
                    )

                    ProviderTextField(
                        title: "Model ID",
                        placeholder: provider.defaultConfiguration.modelID,
                        text: $configuration.modelID
                    )

                    ProviderTextField(
                        title: "API Key",
                        placeholder: "Paste your own key",
                        text: $configuration.apiKey,
                        isSecure: true
                    )

                    if provider == .customEndpoint {
                        Picker("Format", selection: $configuration.providerFormat) {
                            ForEach(ProviderFormat.allCases, id: \.self) { format in
                                Text(format.title)
                                    .tag(format)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(14)
                .background(Color(hex: "#10161C"), in: RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.07), lineWidth: 1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
            .padding(.top, 26)
            .padding(.bottom, 18)
        }
        .navigationBarHidden(true)
    }

    private var configurationHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Endpoint Settings")
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.mutedText)

                Text("\(provider.sheetTitle) Config")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundStyle(.white)

                Text("Override the endpoint, model, or key used for this provider.")
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundStyle(AppTheme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            ProviderBrandIcon(provider: provider, fallbackSystemImage: provider.systemImage)
                .frame(width: 34, height: 34)
                .background(
                    LinearGradient(
                        colors: provider.iconBackgroundColors(isSelected: true),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.12), lineWidth: 1)
                }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#121A20"), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.055), lineWidth: 1)
        }
    }
}

private struct ProviderBrandIcon: View {
    let provider: LLMProvider
    let fallbackSystemImage: String

    var body: some View {
        ZStack {
            switch provider {
            case .localOllama:
                providerImage("Ollama")
            case .openAI:
                providerImage("OpenAI")
            case .gemini:
                providerImage("Gemini")
            case .openRouter:
                providerImage("OpenRouter")
            case .customEndpoint:
                Image(systemName: fallbackSystemImage)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    private func providerImage(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: imageSize, height: imageSize)
    }

    private var imageSize: CGFloat {
        switch provider {
        case .gemini:
            return 25
        case .openRouter:
            return 24
        case .openAI:
            return 29
        case .localOllama:
            return 28
        case .customEndpoint:
            return 22
        }
    }
}

private struct ProviderTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundStyle(AppTheme.mutedText)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(.system(size: 14, weight: .regular, design: .default))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(Color(hex: "#121A20"), in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(0.07), lineWidth: 1)
            }
        }
    }
}

private extension LLMProvider {
    var usesBrandLogoTile: Bool {
        switch self {
        case .localOllama, .openRouter, .openAI, .gemini:
            return true
        case .customEndpoint:
            return false
        }
    }

    var statusAccent: Color {
        switch self {
        case .localOllama:
            return AppTheme.sage
        case .openRouter:
            return Color(hex: "#8B5CF6")
        case .openAI:
            return Color(hex: "#10A37F")
        case .gemini:
            return Color(hex: "#8B5CF6")
        case .customEndpoint:
            return AppTheme.amberSoft
        }
    }

    var pillBackground: LinearGradient {
        LinearGradient(
            colors: [
                statusAccent.opacity(0.18),
                Color.white.opacity(0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func iconBackgroundColors(isSelected: Bool) -> [Color] {
        if usesBrandLogoTile {
            return [
                Color.white.opacity(isSelected ? 0.98 : 0.92),
                Color(hex: "#F2F4F7").opacity(isSelected ? 0.98 : 0.90)
            ]
        }

        switch self {
        case .localOllama:
            return [
                Color(hex: "#2F3440"),
                Color(hex: "#111827")
            ]
        case .openRouter:
            return [
                Color(hex: "#7C3AED"),
                Color(hex: "#06B6D4")
            ]
        case .openAI:
            return [
                Color(hex: "#10A37F"),
                Color(hex: "#087F68")
            ]
        case .gemini:
            return [
                Color(hex: "#4285F4"),
                Color(hex: "#A142F4"),
                Color(hex: "#EA4335")
            ]
        case .customEndpoint:
            return [
                AppTheme.amber,
                Color(hex: "#FF5A7A")
            ]
        }
    }
}
