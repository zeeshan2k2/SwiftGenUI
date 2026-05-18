# SwiftGenUI

SwiftGenUI is a SwiftUI experiment for generating native iOS interfaces from natural language prompts using a local Ollama model.

The idea started while working with local SLMs, where the model should not be allowed to generate and execute arbitrary app code. SwiftGenUI asks the model for a constrained JSON schema, validates that schema, converts it into recursive `UIComponent` nodes, and renders the result as native SwiftUI.

This is not a production app builder yet. It is a research/prototype project for testing whether local models can generate useful UI when forced through a safe schema-first rendering pipeline.

## What It Does

- Takes a natural language prompt for a UI screen or component.
- Sends the prompt to a local Ollama model.
- Uses `qwen2.5-coder:14b` by default.
- Forces the model to respond with JSON instead of Swift code.
- Decodes the JSON into a recursive `UIComponent` tree.
- Validates the generated schema before rendering.
- Rejects unsupported component nesting.
- Rejects generated capabilities/actions for now.
- Renders the validated schema as native SwiftUI.
- Shows the generated screen in a live preview canvas.
- Provides a schema inspector for viewing the generated JSON.
- Keeps an in-memory history of generated screens.

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
    "backgroundColor": "#FFF7E8",
    "cornerRadius": 22
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
        "backgroundColor": "#FF8533"
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
```

Generated components can include simple props:

```text
text
placeholder
spacing
padding
foregroundColor
backgroundColor
cornerRadius
```

Only stack components can contain children. Leaf components such as `text`, `button`, `textField`, `spacer`, and `divider` are validated so they cannot contain nested children.

## Current Pipeline

SwiftGenUI currently follows this flow:

```text
User prompt
-> PromptBuilder
-> Ollama /api/generate
-> JSON response
-> UIComponent decoding
-> SchemaValidator
-> DynamicRenderer
-> Native SwiftUI preview
```

The app currently sends generation requests to:

```text
http://localhost:11434/api/generate
```

The default model is:

```text
qwen2.5-coder:14b
```

The current Ollama generation settings are:

```text
temperature: 0.2
numPredict: 700
numContext: 4096
numThread: 4
keepAlive: 30s
```

These settings are tuned for short, structured UI schema responses rather than long-form text.

## Schema Format

Each generated UI node is represented as a `UIComponent`:

```text
id          stable unique string
type        supported component type
props       optional visual/text properties
children    optional child components
capability  optional native capability call
```

Current schema shape:

```text
{
  "id": "stable unique string",
  "type": "vStack|hStack|zStack|text|button|textField|spacer|divider",
  "props": {
    "text": "optional text",
    "placeholder": "optional placeholder",
    "spacing": 0-32,
    "padding": 0-32,
    "foregroundColor": "#RRGGBB",
    "backgroundColor": "#RRGGBB",
    "cornerRadius": 0-32
  },
  "children": [],
  "capability": null
}
```

The prompt tells the model to prefer `vStack` for screens, cards, forms, and grouped content. `zStack` is only intended for explicit overlapping layouts.

## Safety Model

SwiftGenUI uses a schema-first approach instead of direct Swift generation.

Current validation checks:

```text
Maximum schema depth: 5
Only supported component types are allowed
Only stack components can contain children
Capabilities/actions are rejected for now
```

The capability system exists as a future extension point, but generated capability calls are currently blocked during validation.

This keeps the generated UI limited to a known set of native rendering rules.

## Running

Start Ollama first:

```bash
ollama serve
```

Make sure the model exists locally:

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
xcodebuild -project SwiftGenUI.xcodeproj -scheme SwiftGenUI -configuration Debug build
```

The app expects Ollama to be running locally on port `11434`.

## Dependencies

SwiftGenUI currently uses:

```text
SwiftUI
Composable Architecture
Ollama local API
qwen2.5-coder:14b
```

The Composable Architecture powers the main prompt/generation flow, including generation status, cancellation, schema history, preview navigation, and dependency injection for the LLM client.

## Notes

This project currently focuses on simple static native SwiftUI layouts. Buttons render visually, but generated actions are not executed yet.

The renderer is intentionally small and strict. This makes generated UI easier to reason about, but it also means the model can only create interfaces from the supported component set.

Future directions:

- Add more schema components.
- Add safe registered button actions.
- Persist generation history.
- Improve schema repair when Ollama returns invalid JSON.
- Add tests for schema validation and rendering behavior.
- Support multiple local models.
- Add screenshot/export support for generated screens.
- Add richer layout primitives without allowing arbitrary code execution.

## Status

Experimental. The prompt-to-schema-to-render loop works for simple native SwiftUI screens, but the schema format, validator, renderer, and capability model are still early.
