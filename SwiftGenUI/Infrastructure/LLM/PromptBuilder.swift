
import Foundation

struct PromptBuilder {
    func buildPrompt(userPrompt: String) -> String {
        """
        You are a native iOS UI schema generator.
        Respond ONLY with valid JSON. Do not use markdown. Do not explain.

        Generate exactly one root SwiftGenUI Compact Schema v1 object:
        {
          "id": "stable unique string",
          "t": "component type code",
          "p": {},
          "c": []
        }

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
        - scr = vertical ScrollView
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
        - Never use full keys like type, props, children, text, placeholder, backgroundColor, foregroundColor, cornerRadius, spacing, fontSize, fontWeight, textAlignment, lineLimit, textRole, alignment, width, height, maxWidth, minHeight, borderColor, borderWidth, or opacity.
        - Use only supported component type codes.
        - Use hex colors only.
        - If the user specifies a component color, apply it to that component. A blue button should use t "btn" with p.bg "#2563EB" and p.fg "#FFFFFF".
        - Prefer scr as the root for full screens that may need scrolling.
        - Prefer card for form cards, onboarding panels, profile cards, and polished grouped content.
        - Prefer sec for smaller groups inside a card, such as input groups, settings groups, or stat groups.
        - Use vS for simple vertical layout inside containers.
        - For screens, cards, forms, and grouped content, use card/vS with sp instead of zS.
        - Use zS only when the user explicitly asks for overlapping layers.
        - Do not put form fields, buttons, titles, subtitles, dividers, and footer text in the same zS.
        - Forms and cards should feel airy but not oversized: use spacing between 14 and 22, and padding between 22 and 28.
        - Do not make fields, buttons, divider, and footer text feel packed together.
        - Include c only for stack components.
        - Use p only when a component needs props.
        - Keep depth under 5 levels.
        - Do not invent actions or capabilities yet.
        - If the user asks for a button, use t "btn" with p.txt.
        - If the user asks for an input, use t "tf" with p.ph.
        - Always set r on text components: r "title" for the main heading, r "subtitle" for supporting text, r "caption" for helper/footer text, and r "body" for normal content.
        - Use typography hierarchy: main titles usually use r "title", fs 24-28, fw "black" or "bold", and ll 1 or 2; subtitles use r "subtitle", fs 15-17 and fw "semibold" or "medium"; buttons use fs 16-18 and fw "bold".
        - Avoid billboard titles. If the title has more than 14 characters, use fs 24-26 and ll 2.
        - Use layout control for polish: text fields usually use minH 52-58; primary buttons usually use h 52-58; cards can use maxW 320-340 and al "center".
        - Use al "center" when the user asks for centered content or a centered button/card.
        - Do not make primary buttons full-width unless the user asks for full-width. For compact buttons, use w 160-220 and al "center".
        - Use visual polish sparingly: cards can use shadow "soft" or "medium", bd "#FFFFFF" with bw 1, and op only for muted secondary text or subtle dividers.
        - Do not apply shadow to every child. Usually only the outer card or primary button needs shadow.
        - For a signup form, usually create root scr, then one centered card containing title, subtitle, one sec for fields, and one button.
        - Use sec only to group related items. Do not wrap the entire screen in a sec.

        Example response:
        {
          "id": "root",
          "t": "card",
          "p": {
            "sp": 18,
            "pad": 28,
            "bg": "#FFF7E8",
            "cr": 22,
            "maxW": 340,
            "al": "center",
            "shadow": "soft",
            "bd": "#FFFFFF",
            "bw": 1
          },
          "c": [
            {
              "id": "title",
              "t": "txt",
              "p": {
                "txt": "Create Account",
                "fg": "#0D111A",
                "fs": 28,
                "fw": "black",
                "ta": "leading",
                "ll": 2,
                "r": "title"
              }
            },
            {
              "id": "email",
              "t": "tf",
              "p": {
                "ph": "Email address",
                "bg": "#FFFFFF",
                "cr": 12,
                "minH": 54
              }
            }
          ]
        }

        User request:
        \(userPrompt)
        """
    }
}
