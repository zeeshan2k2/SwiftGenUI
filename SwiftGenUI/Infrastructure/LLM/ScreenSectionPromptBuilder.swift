
import Foundation

struct ScreenSectionPromptBuilder {
    func buildPrompt(input: ScreenSectionGenerationInput) -> String {
        """
        You are a native iOS UI schema section generator.
        Respond ONLY with valid JSON. Do not use markdown. Do not explain.

        Generate exactly one valid SwiftGenUI Compact Schema v1 section object:
        {
          "id": "\(input.section.id)",
          "t": "component type code",
          "p": {},
          "c": []
        }

        This object will be merged into a larger native screen. It is not the full screen.

        Whole user request:
        \(input.userPrompt)

        Screen context:
        - Root layout: \(input.rootLayout.promptContext)
        - Visual tone: \(input.style.tone)
        - Background hint: \(input.style.backgroundColor ?? "none")
        - Accent hint: \(input.style.accentColor ?? "none")
        - Typography hint: \(input.style.typography ?? "none")

        Planned section:
        - id: \(input.section.id)
        - title: \(input.section.title)
        - kind: \(input.section.kind.rawValue)
        - purpose: \(input.section.purpose)

        Component type codes:
        - vS = VStack
        - hS = HStack
        - zS = ZStack
        - txt = Text
        - btn = Button
        - tf = TextField
        - spacer = Spacer
        - div = Divider
        - card = styled rounded card container
        - sec = grouped section container

        Prop keys:
        - txt = visible text
        - ph = placeholder text
        - sp = spacing, number 0-32
        - pad = padding, number 0-32
        - fg = foreground color hex "#RRGGBB"
        - bg = background color hex "#RRGGBB"
        - cr = corner radius, number 0-32
        - fs = font size, number 11-32
        - fw = font weight "regular|medium|semibold|bold|black"
        - ta = text alignment "leading|center|trailing"
        - ll = line limit, number 1-3
        - r = text role "title|subtitle|body|caption"
        - al = component alignment "leading|center|trailing"
        - w = fixed width, number 1-360
        - h = fixed height, number 1-220
        - maxW = max width, number 1-360
        - minH = minimum height, number 1-220
        - shadow = shadow preset "soft|medium|strong|glow"
        - bd = border color hex "#RRGGBB"
        - bw = border width, number 0-4
        - op = opacity, number 0-1

        Rules:
        - Use only the compact keys id, t, p, c.
        - The root id must be "\(input.section.id)".
        - Return one section root only. Do not return an array.
        - Do not use scr. The screen root already exists.
        - Use only supported component type codes and prop keys above.
        - Use hex colors only.
        - Follow the screen style hints so separate sections feel coherent.
        - Generate only this planned \(input.section.kind.rawValue) section; do not repeat other screen sections.
        - Use card, sec, vS, or hS as the section root when appropriate.
        - Prefer vS/card/sec for grouped content. Use zS only for explicit overlapping layers.
        - Include c only for stack or container components.
        - Use p only when a component needs props.
        - Keep depth under 4 levels inside this section.
        - Keep repeated rows concise so the final merged screen stays token-efficient.
        - Do not invent actions or capabilities yet.
        - If the section needs a button, use t "btn" with p.txt.
        - If the section needs an input, use t "tf" with p.ph.
        - Always set r on text components: title, subtitle, body, or caption.
        - Use minimal modern iOS typography by default. Prefer fw "medium" or "semibold"; use fw "bold" sparingly for hierarchy. Avoid fw "black" unless the user explicitly asks for a playful, chunky, bubble, cartoon, or poster style.
        - Avoid playful, bubble, cartoon, or overly rounded typography unless explicitly requested.
        - Apply an explicitly requested component color to that component. A blue button uses p.bg "#2563EB" and p.fg "#FFFFFF".
        """
    }

    func buildRetryPrompt(input: ScreenSectionGenerationInput) -> String {
        """
        Return ONLY one valid SwiftGenUI Compact Schema v1 JSON section.
        No markdown. No explanation. Keep it small and safe.

        Output shape:
        {
          "id": "\(input.section.id)",
          "t": "sec",
          "p": { "sp": 12, "pad": 16 },
          "c": []
        }

        Section to generate:
        - id: \(input.section.id)
        - kind: \(input.section.kind.rawValue)
        - purpose: \(input.section.purpose)
        - user request: \(input.userPrompt)
        - tone: \(input.style.tone)
        - accent color: \(input.style.accentColor ?? "none")

        Allowed type codes only:
        - sec, card, vS, hS, txt, btn, tf, div, spacer

        Allowed keys only:
        - id, t, p, c
        - p.txt, p.ph, p.sp, p.pad, p.fg, p.bg, p.cr
        - p.fs, p.fw, p.r, p.al, p.h, p.minH

        Rules:
        - Root id must be "\(input.section.id)".
        - Root type must be sec, card, or vS.
        - Do not use scr or zS.
        - Use hex colors only.
        - Use text roles: title, subtitle, body, or caption on every txt.
        - Keep depth at 3 levels or less.
        - Use at most 4 direct child components.
        - For repeated list content, create at most 2 representative rows.
        - Generate only this section. Do not repeat the full screen.
        - Do not invent actions or capabilities.
        """
    }
}

private extension ScreenRootLayout {
    var promptContext: String {
        switch self {
        case .scrollView:
            return "scrollable full-screen root (scr)"
        case .vStack:
            return "short vertical screen root (vS)"
        }
    }
}
