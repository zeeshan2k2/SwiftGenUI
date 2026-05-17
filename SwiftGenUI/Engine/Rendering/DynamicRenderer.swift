//
//  DynamicRenderer.swift
//  SwiftGenUI
//
//  SwiftUI renderer for validated UI schemas.
//

import SwiftUI

struct DynamicRenderer: View {
    let component: UIComponent

    var body: some View {
        render(component)
    }

    private func render(_ component: UIComponent) -> AnyView {
        switch component.type {
        case .vStack:
            return AnyView(
                VStack(alignment: .leading, spacing: component.props?.spacing ?? 16) {
                    renderChildren(component.children)
                }
                .modifier(ComponentStyle(props: component.props))
            )

        case .hStack:
            return AnyView(
                HStack(spacing: component.props?.spacing ?? 12) {
                    renderChildren(component.children)
                }
                .modifier(ComponentStyle(props: component.props))
            )

        case .zStack:
            return AnyView(
                VStack(alignment: .leading, spacing: component.props?.spacing ?? 16) {
                    renderChildren(component.children)
                }
                .modifier(ComponentStyle(props: component.props))
            )

        case .text:
            return AnyView(
                Text(component.props?.text ?? "")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(color(from: component.props?.foregroundColor, fallback: AppTheme.ink))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ComponentStyle(props: component.props))
            )

        case .button:
            return AnyView(
                Button(component.props?.text ?? "Button") {}
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(color(from: component.props?.foregroundColor, fallback: .white))
                    .padding(.horizontal, component.props?.padding ?? 22)
                    .padding(.vertical, 14)
                    .background(
                        color(from: component.props?.backgroundColor, fallback: AppTheme.amber),
                        in: RoundedRectangle(cornerRadius: component.props?.cornerRadius ?? 14)
                    )
                    .padding(.top, 6)
                    .padding(.bottom, 4)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.plain)
            )

        case .textField:
            return AnyView(
                Text(component.props?.placeholder ?? "Text field")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ink.opacity(0.58))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, component.props?.padding ?? 16)
                    .padding(.vertical, 14)
                    .frame(minHeight: 48)
                    .background(
                        color(from: component.props?.backgroundColor, fallback: .white),
                        in: RoundedRectangle(cornerRadius: component.props?.cornerRadius ?? 12)
                    )
                    .padding(.vertical, 2)
            )

        case .spacer:
            return AnyView(Spacer(minLength: component.props?.spacing ?? 12))

        case .divider:
            return AnyView(Divider())
        }
    }

    @ViewBuilder
    private func renderChildren(_ children: [UIComponent]?) -> some View {
        ForEach(children ?? []) { child in
            render(child)
        }
    }

    private func color(from hex: String?, fallback: Color) -> Color {
        guard let hex else { return fallback }
        return Color(hex: hex)
    }
}

private struct ComponentStyle: ViewModifier {
    let props: ComponentProps?

    func body(content: Content) -> some View {
        content
            .padding(props?.padding ?? 0)
            .background(
                backgroundColor,
                in: RoundedRectangle(cornerRadius: props?.cornerRadius ?? 0)
            )
    }

    private var backgroundColor: Color {
        guard let backgroundColor = props?.backgroundColor else {
            return .clear
        }

        return Color(hex: backgroundColor)
    }
}
