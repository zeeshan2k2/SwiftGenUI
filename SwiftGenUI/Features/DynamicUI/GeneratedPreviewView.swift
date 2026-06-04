
import ComposableArchitecture
import SwiftUI

struct GeneratedPreviewView: View {
    @Bindable var store: StoreOf<DynamicUIFeature>

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            previewBackground

            VStack(alignment: .leading, spacing: 18) {
                headerCard

                AppCard(opacity: 0.065, strokeOpacity: 0.075) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            AppSectionTitle(title: "Live native preview", systemImage: "rectangle.on.rectangle")
                            Spacer()
                            Text(store.generationStatus)
                                .font(.system(size: 12, weight: .semibold, design: .default))
                                .foregroundStyle(AppTheme.mutedText)
                        }

                        if let warning = store.generationWarning {
                            Label(warning, systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 12, weight: .semibold, design: .default))
                                .foregroundStyle(Color(hex: "#FFE1A6"))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(hex: "#8B5A14").opacity(0.22), in: RoundedRectangle(cornerRadius: 14))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(hex: "#FFE1A6").opacity(0.18), lineWidth: 1)
                                }
                        }

                        if let component = store.generatedComponent {
                            generatedCanvas(component)
                        } else {
                            EmptyPreviewCanvas(minHeight: 360)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .padding(.horizontal, AppTheme.contentPadding)
            .padding(.top, 8)
            .padding(.bottom, 18)

            schemaButton
                .padding(.leading, AppTheme.contentPadding + 8)
                .padding(.bottom, 12)
        }
        .sheet(isPresented: $store.isSchemaInspectorPresented) {
            SchemaInspectorSheet(schema: store.generatedSchema)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Native Preview")
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .foregroundStyle(AppTheme.mutedText)

                    Text("Generated Canvas")
                        .font(.system(size: 22, weight: .semibold, design: .default))
                        .foregroundStyle(.white)

                    Text("Native SwiftUI rendered from validated schema")
                        .font(.system(size: 11, weight: .medium, design: .default))
                        .foregroundStyle(AppTheme.mutedText)
                        .lineLimit(1)
                }
                .layoutPriority(1)

                Spacer(minLength: 8)

                validationStatusStack
            }
        }
        .padding(12)
        .background(Color(hex: "#121A20"), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.055), lineWidth: 1)
        }
    }

    private var previewBackground: some View {
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
        }
        .ignoresSafeArea()
    }

    private func compactPreviewBadge(systemImage: String, title: String? = nil) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .semibold, design: .default))

            if let title {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.white.opacity(0.88))
        .padding(.horizontal, title == nil ? 8 : 9)
        .padding(.vertical, 6)
        .background(Color(hex: "#1A232B"), in: Capsule())
    }

    private var validationBadge: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 12, weight: .bold, design: .default))
            .foregroundStyle(Color(hex: "#0B1015"))
            .frame(width: 28, height: 28)
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
            .shadow(color: Color(hex: "#7FCA8B").opacity(0.24), radius: 10, x: 0, y: 5)
    }

    private var validationStatusStack: some View {
        VStack(spacing: 8) {
            validationBadge

            if let durationText = store.completedGenerationDurationText {
                Text(durationText.compactDurationText)
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.mutedText)
                    .lineLimit(1)
            }
        }
    }

    private var schemaButton: some View {
        Button {
            store.send(.binding(.set(\.isSchemaInspectorPresented, true)))
        } label: {
            Text("{}")
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.25), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.30), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    private func generatedCanvas(_ component: UIComponent) -> some View {
        GeometryReader { proxy in
            let canvasWidth = max(proxy.size.width - 8, 0)
            let contentWidth = min(canvasWidth, 360)

            ScrollView(showsIndicators: false) {
                HStack {
                    Spacer(minLength: 0)

                    DynamicRenderer(component: component)
                        .frame(width: contentWidth, alignment: .center)
                        .clipped()

                    Spacer(minLength: 0)
                }
                .frame(width: canvasWidth)
                .padding(.vertical, 18)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}

private struct SchemaInspectorSheet: View {
    let schema: String?

    var body: some View {
        ZStack {
            inspectorBackground

            VStack(alignment: .leading, spacing: 16) {
                inspectorHeader

                ScrollView(showsIndicators: false) {
                    Text(schema ?? "Generated JSON will be shown here after validation.")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color(hex: "#D7DEE5").opacity(0.86))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                }
                .background(Color(hex: "#0B1015"), in: RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.07), lineWidth: 1)
                }
            }
            .padding(20)
        }
    }

    private var inspectorHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Developer View")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.mutedText)

                Text("Schema Inspector")
                    .font(.system(size: 22, weight: .semibold, design: .default))
                    .foregroundStyle(.white)

                Text("Copyable compact JSON used by the native renderer")
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundStyle(AppTheme.mutedText)
                    .lineLimit(2)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            inspectorStatus
        }
        .padding(14)
        .background(Color(hex: "#121A20"), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.055), lineWidth: 1)
        }
    }

    private var inspectorStatus: some View {
        Image(systemName: schema == nil ? "exclamationmark" : "curlybraces")
            .font(.system(size: 12, weight: .bold, design: .default))
            .foregroundStyle(Color(hex: "#0B1015"))
            .frame(width: 30, height: 30)
            .background(Color(hex: schema == nil ? "#DCE4EA" : "#F4F6F8"), in: Circle())
    }

    private var inspectorBackground: some View {
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
        }
        .ignoresSafeArea()
    }
}

private extension String {
    var compactDurationText: String {
        replacingOccurrences(of: "Rendered in ", with: "")
    }
}

struct GeneratedPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GeneratedPreviewView(
                store: Store(initialState: previewState) {
                    DynamicUIFeature()
                }
            )
        }
        .previewDisplayName("Generated Signup Canvas")
    }

    private static var previewState: DynamicUIFeature.State {
        var state = DynamicUIFeature.State()
        let component = previewComponent

        state.generationPhase = .completed
        state.generatedComponent = component
        state.generatedSchema = prettyPrintedJSON(for: component)
        state.completedGenerationDuration = 2.8
        state.isPreviewPresented = true

        return state
    }

    private static var previewComponent: UIComponent {
        UIComponent(
            id: "signup-root",
            type: .vStack,
            props: ComponentProps(
                spacing: 14,
                padding: 20,
                backgroundColor: "#FFF7E8",
                cornerRadius: 24
            ),
            children: [
                UIComponent(
                    id: "signup-title",
                    type: .text,
                    props: ComponentProps(
                        text: "Create Account",
                        foregroundColor: "#0D111A"
                    ),
                    children: nil,
                    capability: nil
                ),
                UIComponent(
                    id: "signup-subtitle",
                    type: .text,
                    props: ComponentProps(
                        text: "Start building native interfaces with AI.",
                        foregroundColor: "#5C6470"
                    ),
                    children: nil,
                    capability: nil
                ),
                UIComponent(
                    id: "email-field",
                    type: .textField,
                    props: ComponentProps(
                        placeholder: "Email address",
                        padding: 14,
                        backgroundColor: "#FFFFFF",
                        cornerRadius: 14
                    ),
                    children: nil,
                    capability: nil
                ),
                UIComponent(
                    id: "password-field",
                    type: .textField,
                    props: ComponentProps(
                        placeholder: "Password",
                        padding: 14,
                        backgroundColor: "#FFFFFF",
                        cornerRadius: 14
                    ),
                    children: nil,
                    capability: nil
                ),
                UIComponent(
                    id: "divider",
                    type: .divider,
                    props: nil,
                    children: nil,
                    capability: nil
                ),
                UIComponent(
                    id: "continue-button",
                    type: .button,
                    props: ComponentProps(
                        text: "Continue",
                        padding: 16,
                        foregroundColor: "#FFFFFF",
                        backgroundColor: "#FF8533",
                        cornerRadius: 16
                    ),
                    children: nil,
                    capability: nil
                )
            ],
            capability: nil
        )
    }

    private static func prettyPrintedJSON(for component: UIComponent) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(component),
              let json = String(data: data, encoding: .utf8) else {
            return ""
        }

        return json
    }
}
