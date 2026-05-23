//
//  GeneratedPreviewView.swift
//  SwiftGenUI
//
//  Fullscreen canvas for generated native UI.
//

import ComposableArchitecture
import SwiftUI

struct GeneratedPreviewView: View {
    @Bindable var store: StoreOf<DynamicUIFeature>

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AppTheme.workspaceGradient
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                topBar

                AppCard(opacity: 0.10, strokeOpacity: 0.14) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            AppSectionTitle(title: "Live native preview", systemImage: "rectangle.on.rectangle")
                            Spacer()
                            Text(store.generationStatus)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(AppTheme.sage)
                        }

                        if let warning = store.generationWarning {
                            Label(warning, systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
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
            .padding(.top, 18)
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
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Generated Canvas")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("Native SwiftUI rendered from validated schema")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.mutedText)
            }

            Spacer()

            AppStatusBadge(title: "Validated")
        }
    }

    private var schemaButton: some View {
        Button {
            store.send(.binding(.set(\.isSchemaInspectorPresented, true)))
        } label: {
            Text("{}")
                .font(.system(size: 18, weight: .black, design: .monospaced))
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
            AppTheme.ink
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    AppSectionTitle(title: "Schema inspector", systemImage: "curlybraces")
                    Spacer()
                    Text(schema == nil ? "Empty" : "Ready")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.46))
                }

                ScrollView(showsIndicators: false) {
                    Text(schema ?? "Generated JSON will be shown here after validation.")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(AppTheme.mutedText)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(20)
        }
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
