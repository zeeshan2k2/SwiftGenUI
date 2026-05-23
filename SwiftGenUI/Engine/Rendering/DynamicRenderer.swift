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
                VStack(alignment: horizontalAlignment(from: component.props?.alignment), spacing: component.props?.spacing ?? 16) {
                    renderChildren(component.children)
                }
                .modifier(ComponentStyle(props: component.props))
                .modifier(ComponentLayout(props: component.props))
                .modifier(ComponentPolish(props: component.props))
            )

        case .hStack:
            return AnyView(
                HStack(spacing: component.props?.spacing ?? 12) {
                    renderChildren(component.children)
                }
                .modifier(ComponentStyle(props: component.props))
                .modifier(ComponentLayout(props: component.props))
                .modifier(ComponentPolish(props: component.props))
            )

        case .zStack:
            return AnyView(
                VStack(alignment: horizontalAlignment(from: component.props?.alignment), spacing: component.props?.spacing ?? 16) {
                    renderChildren(component.children)
                }
                .modifier(ComponentStyle(props: component.props))
                .modifier(ComponentLayout(props: component.props))
                .modifier(ComponentPolish(props: component.props))
            )

        case .text:
            return AnyView(
                Text(component.props?.text ?? "")
                    .font(.system(
                        size: textFontSize(for: component.props),
                        weight: textFontWeight(for: component.props),
                        design: .rounded
                    ))
                    .foregroundStyle(textColor(for: component.props))
                    .multilineTextAlignment(textAlignment(from: component.props?.textAlignment))
                    .lineLimit(textLineLimit(for: component.props))
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: frameAlignment(from: component.props?.textAlignment ?? component.props?.alignment))
                    .modifier(ComponentStyle(props: component.props))
                    .modifier(ComponentLayout(props: component.props))
                    .modifier(ComponentPolish(props: component.props))
            )

        case .button:
            return AnyView(
                Button(component.props?.text ?? "Button") {}
                    .font(.system(
                        size: component.props?.fontSize ?? 16,
                        weight: fontWeight(from: component.props?.fontWeight, fallback: .bold),
                        design: .rounded
                    ))
                    .foregroundStyle(color(from: component.props?.foregroundColor, fallback: .white))
                    .padding(.horizontal, component.props?.padding ?? 22)
                    .padding(.vertical, 14)
                    .background(
                        color(from: component.props?.backgroundColor, fallback: AppTheme.amber),
                        in: RoundedRectangle(cornerRadius: component.props?.cornerRadius ?? 14)
                    )
                    .padding(.top, 6)
                    .padding(.bottom, 4)
                    .modifier(ComponentLayout(props: component.props, defaultMaxWidth: .infinity))
                    .modifier(ComponentPolish(props: component.props))
                    .buttonStyle(.plain)
            )

        case .textField:
            return AnyView(
                Text(component.props?.placeholder ?? "Text field")
                    .font(.system(
                        size: component.props?.fontSize ?? 15,
                        weight: fontWeight(from: component.props?.fontWeight, fallback: .medium),
                        design: .rounded
                    ))
                    .foregroundStyle(AppTheme.ink.opacity(0.58))
                    .frame(maxWidth: .infinity, alignment: frameAlignment(from: component.props?.alignment))
                    .padding(.horizontal, component.props?.padding ?? 16)
                    .padding(.vertical, 14)
                    .frame(minHeight: cgFloat(component.props?.minHeight) ?? 48)
                    .background(
                        color(from: component.props?.backgroundColor, fallback: .white),
                        in: RoundedRectangle(cornerRadius: component.props?.cornerRadius ?? 12)
                    )
                    .padding(.vertical, 2)
                    .modifier(ComponentLayout(props: component.props, defaultMaxWidth: .infinity))
                    .modifier(ComponentPolish(props: component.props))
            )

        case .spacer:
            return AnyView(Spacer(minLength: component.props?.spacing ?? 12))

        case .divider:
            return AnyView(Divider())

        case .card:
            return AnyView(
                VStack(alignment: horizontalAlignment(from: component.props?.alignment), spacing: component.props?.spacing ?? 16) {
                    renderChildren(component.children)
                }
                .padding(component.props?.padding ?? 24)
                .background(
                    color(from: component.props?.backgroundColor, fallback: AppTheme.creamSoft),
                    in: RoundedRectangle(cornerRadius: component.props?.cornerRadius ?? 26)
                )
                .modifier(ComponentLayout(props: component.props, defaultMaxWidth: 340))
                .modifier(ComponentPolish(props: component.props))
            )

        case .scrollView:
            return AnyView(
                ScrollView(showsIndicators: false) {
                    VStack(alignment: horizontalAlignment(from: component.props?.alignment), spacing: component.props?.spacing ?? 16) {
                        renderChildren(component.children)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                    .modifier(ComponentLayout(props: component.props, defaultMaxWidth: .infinity))
                }
                .modifier(ComponentPolish(props: component.props))
            )

        case .section:
            return AnyView(
                VStack(alignment: horizontalAlignment(from: component.props?.alignment), spacing: component.props?.spacing ?? 12) {
                    renderChildren(component.children)
                }
                .padding(component.props?.padding ?? 16)
                .background(
                    color(from: component.props?.backgroundColor, fallback: .white.opacity(0.42)),
                    in: RoundedRectangle(cornerRadius: component.props?.cornerRadius ?? 18)
                )
                .modifier(ComponentLayout(props: component.props, defaultMaxWidth: .infinity))
                .modifier(ComponentPolish(props: component.props))
            )
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

    private func cgFloat(_ value: Double?) -> CGFloat? {
        guard let value else { return nil }
        return CGFloat(value)
    }

    private func textFontSize(for props: ComponentProps?) -> CGFloat {
        let requestedSize = props?.fontSize ?? defaultTextFontSize(for: props?.textRole)
        let textLength = props?.text?.count ?? 0
        let isTitle = props?.textRole == "title" || requestedSize >= 28
        let maxSize: Double

        switch props?.textRole {
        case "title":
            maxSize = textLength > 14 ? 27 : 30
        case "subtitle":
            maxSize = 18
        case "caption":
            maxSize = 13
        default:
            maxSize = 22
        }

        if isTitle && textLength > 18 {
            return CGFloat(min(requestedSize, 26))
        }

        return CGFloat(min(requestedSize, maxSize))
    }

    private func defaultTextFontSize(for role: String?) -> Double {
        switch role {
        case "title":
            return 28
        case "subtitle":
            return 16
        case "caption":
            return 12
        default:
            return 17
        }
    }

    private func textFontWeight(for props: ComponentProps?) -> Font.Weight {
        let fallback: Font.Weight

        switch props?.textRole {
        case "title":
            fallback = .black
        case "subtitle":
            fallback = .semibold
        case "caption":
            fallback = .medium
        default:
            fallback = .semibold
        }

        return fontWeight(from: props?.fontWeight, fallback: fallback)
    }

    private func textLineLimit(for props: ComponentProps?) -> Int {
        if let lineLimit = props?.lineLimit {
            return lineLimit
        }

        switch props?.textRole {
        case "title":
            return 2
        case "subtitle":
            return 3
        case "caption":
            return 2
        default:
            return 3
        }
    }

    private func textColor(for props: ComponentProps?) -> Color {
        if let foregroundColor = props?.foregroundColor {
            return Color(hex: foregroundColor)
        }

        switch props?.textRole {
        case "subtitle", "caption":
            return AppTheme.ink.opacity(0.58)
        default:
            return AppTheme.ink
        }
    }

    private func fontWeight(from value: String?, fallback: Font.Weight) -> Font.Weight {
        switch value {
        case "regular":
            return .regular
        case "medium":
            return .medium
        case "semibold":
            return .semibold
        case "bold":
            return .bold
        case "black":
            return .black
        default:
            return fallback
        }
    }

    private func textAlignment(from value: String?) -> TextAlignment {
        switch value {
        case "center":
            return .center
        case "trailing":
            return .trailing
        default:
            return .leading
        }
    }

    private func frameAlignment(from value: String?) -> Alignment {
        switch value {
        case "center":
            return .center
        case "trailing":
            return .trailing
        default:
            return .leading
        }
    }

    private func horizontalAlignment(from value: String?) -> HorizontalAlignment {
        switch value {
        case "center":
            return .center
        case "trailing":
            return .trailing
        default:
            return .leading
        }
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

private struct ComponentLayout: ViewModifier {
    let props: ComponentProps?
    var defaultMaxWidth: CGFloat?
    private let maximumGeneratedWidth: CGFloat = 360

    func body(content: Content) -> some View {
        content
            .frame(
                width: clampedWidth(props?.width),
                height: cgFloat(props?.height)
            )
            .frame(
                maxWidth: clampedMaxWidth(props?.maxWidth, fallback: defaultMaxWidth),
                minHeight: cgFloat(props?.minHeight),
                alignment: frameAlignment(from: props?.alignment)
            )
    }

    private func cgFloat(_ value: Double?) -> CGFloat? {
        guard let value else { return nil }
        return CGFloat(value)
    }

    private func clampedWidth(_ value: Double?) -> CGFloat? {
        guard let value else { return nil }
        return min(CGFloat(value), maximumGeneratedWidth)
    }

    private func clampedMaxWidth(_ value: Double?, fallback: CGFloat?) -> CGFloat? {
        if let value {
            return min(CGFloat(value), maximumGeneratedWidth)
        }

        guard let fallback else { return nil }

        if fallback == .infinity {
            return fallback
        }

        return min(fallback, maximumGeneratedWidth)
    }

    private func frameAlignment(from value: String?) -> Alignment {
        switch value {
        case "center":
            return .center
        case "trailing":
            return .trailing
        default:
            return .leading
        }
    }
}

private struct ComponentPolish: ViewModifier {
    let props: ComponentProps?

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: props?.cornerRadius ?? 0)
                    .stroke(
                        borderColor,
                        lineWidth: cgFloat(props?.borderWidth) ?? 0
                    )
            }
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowYOffset
            )
            .opacity(props?.opacity ?? 1)
    }

    private var borderColor: Color {
        guard let borderColor = props?.borderColor else {
            return .clear
        }

        return Color(hex: borderColor)
    }

    private var shadowColor: Color {
        switch props?.shadow {
        case "soft":
            return Color.black.opacity(0.12)
        case "medium":
            return Color.black.opacity(0.18)
        case "strong":
            return Color.black.opacity(0.26)
        case "glow":
            return Color(hex: "#9DE8FF").opacity(0.28)
        default:
            return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch props?.shadow {
        case "soft":
            return 14
        case "medium":
            return 22
        case "strong":
            return 30
        case "glow":
            return 24
        default:
            return 0
        }
    }

    private var shadowYOffset: CGFloat {
        switch props?.shadow {
        case "soft":
            return 8
        case "medium":
            return 14
        case "strong":
            return 18
        case "glow":
            return 8
        default:
            return 0
        }
    }

    private func cgFloat(_ value: Double?) -> CGFloat? {
        guard let value else { return nil }
        return CGFloat(value)
    }
}
