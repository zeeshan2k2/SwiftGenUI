# SwiftGenUI

SwiftGenUI is a SwiftUI + TCA experiment for generating native iOS screens from LLM JSON schemas by routing prompts through selected LLM providers, validating the generated schema, and rendering the result as native SwiftUI.

The idea started while working with LLMs, where the model should not be allowed to generate and execute arbitrary app code. SwiftGenUI asks the model for a constrained JSON schema, validates that schema, converts it into recursive `UIComponent` nodes, and renders the result through a native SwiftUI renderer.

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
- Routes generation through a selected LLM provider.
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

Generated compact schema:
{
  "id": "root",
  "t": "card",
  "p": {
    "sp": 18,
    "pad": 28,
    "bg": "#10161C",
    "cr": 18
  },
  "c": [
    {
      "id": "email",
      "t": "tf",
      "p": {
        "ph": "Email address"
      }
    },
    {
      "id": "continue",
      "t": "btn",
      "p": {
        "txt": "Continue",
        "bg": "#D9F99D",
        "fg": "#0B1015"
      }
    }
  ]
}
```

The model does not directly control the app runtime. It only describes UI through a limited compact schema that SwiftGenUI decodes into internal `UIComponent` nodes before validation and rendering.

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
txt
ph
sp
pad
fg
bg
cr
fs
fw
ta
ll
r
al
w
h
maxW
minH
shadow
bd
bw
op
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

The LLM is asked to return a compact SwiftGenUI schema. Each compact node is decoded into an internal `UIComponent` before validation and rendering.

```text
id    stable unique string
t     supported component type code
p     optional visual/text/layout props
c     optional child components
```

Current compact schema shape:

```text
{
  "id": "stable unique string",
  "t": "vS|hS|zS|txt|btn|tf|spacer|div|card|scr|sec",
  "p": {
    "txt": "optional text",
    "ph": "optional placeholder",
    "sp": 0-32,
    "pad": 0-32,
    "fg": "#RRGGBB",
    "bg": "#RRGGBB",
    "cr": 0-32,
    "fs": 11-32,
    "fw": "regular|medium|semibold|bold|black",
    "ta": "leading|center|trailing",
    "ll": 1-3,
    "r": "title|subtitle|body|caption",
    "al": "leading|center|trailing",
    "w": 1-360,
    "h": 1-220,
    "maxW": 1-360,
    "minH": 1-220,
    "shadow": "soft|medium|strong|glow",
    "bd": "#RRGGBB",
    "bw": 0-4,
    "op": 0-1
  },
  "c": []
}
```

Compact type codes map to internal component types:

```text
vS     vStack
hS     hStack
zS     zStack
txt    text
btn    button
tf     textField
spacer spacer
div    divider
card   card
scr    scrollView
sec    section
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
