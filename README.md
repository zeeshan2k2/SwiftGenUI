# SwiftGenUI

SwiftGenUI is a SwiftUI + TCA experiment for generating native iOS screens from LLM JSON schemas by routing prompts through local or online AI providers, validating the generated schema, and rendering the result as native SwiftUI.

The idea started while working with local SLMs, where the model should not be allowed to generate and execute arbitrary app code. SwiftGenUI asks the model for a constrained JSON schema, validates that schema, converts it into recursive `UIComponent` nodes, and renders the result through a native SwiftUI renderer.

This is not a production app builder yet. It is a research/prototype project for testing whether LLMs can generate useful mobile UI when forced through a safe schema-first rendering pipeline.

## Screenshots

<p align="center">
  <img src="https://github.com/zeeshan2k2/SwiftGenUI/blob/main/screenshots/home.png" width="230">
  <img src="https://github.com/zeeshan2k2/SwiftGenUI/blob/main/screenshots/ai%20provider.png" width="230">
  <img src="https://github.com/zeeshan2k2/SwiftGenUI/blob/main/screenshots/endpoint%20setting.png" width="230">
  <img src="https://github.com/zeeshan2k2/SwiftGenUI/blob/main/screenshots/generated%20canvas.png" width="230">
  <img src="https://github.com/zeeshan2k2/SwiftGenUI/blob/main/screenshots/schema%20inspector.png" width="230">
  <img src="https://github.com/zeeshan2k2/SwiftGenUI/blob/main/screenshots/history.png" width="230">
</p>

## What It Does

- Takes a natural language prompt for a native iOS screen or component.
- Routes generation through a selected AI provider.
- Supports local Ollama/Qwen by default.
- Supports OpenRouter, OpenAI, Gemini, and custom endpoints.
- Forces model output into JSON instead of Swift code.
- Supports single-schema generation and planned section-by-section screen generation.
- Decodes JSON into a recursive `UIComponent` tree.
- Validates the generated schema before rendering.
- Rejects unsupported component nesting.
- Rejects generated capabilities/actions for now.
- Renders the validated schema as native SwiftUI.
- Shows the generated screen in a live preview canvas.
- Provides a dark schema inspector for viewing and copying generated JSON.
- Persists generated history with SwiftData.

Example idea:

```text
Prompt:
Create a signup form with an email field, password field, and orange continue button.

Generated schema:
{
  "id": "root",
  "type": "vStack",
  "props": {
    "spacing": 18,
    "padding": 28,
    "backgroundColor": "#10161C",
    "cornerRadius": 18
  },
  "children": [
    {
      "id": "email",
      "type": "textField",
      "props": {
        "placeholder": "Email address"
      },
      "children": null,
      "capability": null
    },
    {
      "id": "continue",
      "type": "button",
      "props": {
        "text": "Continue",
        "backgroundColor": "#D9F99D"
      },
      "children": null,
      "capability": null
    }
  ],
  "capability": null
}
```

The model does not directly control the app runtime. It only describes UI through a limited schema that SwiftGenUI knows how to validate and render.

## Supported Components

The current schema supports these component types:

```text
vStack
hStack
zStack
text
button
textField
spacer
divider
card
scrollView
section
```

Generated components can include props such as:

```text
text
placeholder
spacing
padding
foregroundColor
backgroundColor
cornerRadius
fontSize
fontWeight
textAlignment
lineLimit
textRole
alignment
width
height
maxWidth
minHeight
shadow
borderColor
borderWidth
opacity
```

Only container components can contain children. Leaf components such as `text`, `button`, `textField`, `spacer`, and `divider` are validated so they cannot contain nested children.

## Current Pipeline

SwiftGenUI currently follows this flow:

```text
User prompt
-> Provider picker
-> PromptBuilder or ScreenPlanPromptBuilder
-> LLM provider request
-> JSON response
-> UIComponent decoding
-> SchemaValidator
-> DynamicRenderer
-> Native SwiftUI preview
-> SwiftData history
```

For larger screen prompts, SwiftGenUI can plan the screen first, generate sections separately, retry failed sections, merge valid sections, and render the final screen.

Local Ollama currently sends generation requests to:

```text
http://localhost:11434/api/generate
```

The default local model is:

```text
qwen2.5-coder:14b
```

The current Ollama generation settings are:

```text
temperature: 0.2
numContext: 4096
numThread: 4
keepAlive: 30s
```

Prediction limits vary by operation:

```text
single schema: 1800
screen plan:   420
section:       900
section retry: 520
```

## AI Providers

SwiftGenUI includes a provider picker for switching where generation runs:

```text
Local Ollama
OpenRouter
OpenAI
Gemini
Custom Endpoint
```

The custom endpoint settings support:

```text
Base URL
Model ID
API key
Provider format
```

Supported provider formats:

```text
OpenAI-compatible
Gemini
Ollama-compatible
```

## Schema Format

Each generated UI node is represented as a `UIComponent`:

```text
id          stable unique string
type        supported component type
props       optional visual/text/layout properties
children    optional child components
capability  optional native capability call
```

Current schema shape:

```text
{
  "id": "stable unique string",
  "type": "vStack|hStack|zStack|text|button|textField|spacer|divider|card|scrollView|section",
  "props": {
    "text": "optional text",
    "placeholder": "optional placeholder",
    "spacing": 0-32,
    "padding": 0-32,
    "foregroundColor": "#RRGGBB",
    "backgroundColor": "#RRGGBB",
    "cornerRadius": 0-32,
    "fontSize": 12-34,
    "fontWeight": "regular|medium|semibold|bold",
    "textAlignment": "leading|center|trailing",
    "lineLimit": 1-6,
    "textRole": "title|subtitle|body|caption|metric",
    "alignment": "leading|center|trailing",
    "width": 0,
    "height": 0,
    "maxWidth": 0,
    "minHeight": 0,
    "shadow": "none|soft|medium",
    "borderColor": "#RRGGBB",
    "borderWidth": 0-4,
    "opacity": 0-1
  },
  "children": [],
  "capability": null
}
```

The prompt rules prefer structured vertical layouts for screens, cards, forms, and grouped content. `zStack` is only intended for explicit overlapping layouts.

## Safety Model

SwiftGenUI uses a schema-first approach instead of direct Swift generation.

Current validation checks:

```text
Maximum schema depth: 7
Only supported component types are allowed
Only container components can contain children
Capabilities/actions are rejected for now
```

The capability system exists as a future extension point, but generated capability calls are currently blocked during validation.

This keeps generated UI limited to a known set of native rendering rules.

## Running

For local generation, start Ollama first:

```bash
ollama serve
```

Make sure the default local model exists:

```bash
ollama list
```

If needed, run or pull the model:

```bash
ollama run qwen2.5-coder:14b
```

Open the project in Xcode:

```text
SwiftGenUI.xcodeproj
```

Or build from terminal:

```bash
xcodebuild -scheme SwiftGenUI -project SwiftGenUI.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 17' ONLY_ACTIVE_ARCH=YES -quiet build
```

Local Ollama mode expects Ollama to be running on port `11434`.

## Dependencies

SwiftGenUI currently uses:

```text
SwiftUI
Composable Architecture
SwiftData
Ollama local API
OpenAI-compatible chat APIs
Gemini API
qwen2.5-coder:14b
```

The Composable Architecture powers the main prompt/generation flow, including provider selection, generation status, cancellation, schema history, preview navigation, and dependency injection for the LLM client.

SwiftData stores generated history so previous screens can be replayed after relaunching the app.

## Notes

This project currently focuses on generating polished static native SwiftUI layouts. Buttons render visually, but generated actions are not executed yet.

The renderer is intentionally strict. This makes generated UI easier to reason about, but it also means the model can only create interfaces from the supported component set.

Future directions:

- Add more schema components.
- Add safe registered button actions.
- Add richer generated interaction states.
- Improve schema repair when providers return invalid JSON.
- Add tests for schema validation and rendering behavior.
- Add screenshot/export support for generated screens.
- Add richer layout primitives without allowing arbitrary code execution.

## Status

Experimental. The prompt-to-schema-to-render loop works for native SwiftUI screens, and the app now supports provider routing, schema inspection, generated previews, and persisted history. The schema format, validator, renderer, and capability model are still evolving.
