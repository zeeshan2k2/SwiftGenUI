//
//  PromptBuilder.swift
//  SwiftGenUI
//
//  Builds prompts that constrain the LLM to valid UI schema JSON.
//

import Foundation

struct PromptBuilder {
    func buildPrompt(userPrompt: String) -> String {
        """
        You are a native iOS UI schema generator.
        Respond ONLY with valid JSON. Do not use markdown. Do not explain.

        Generate exactly one root UIComponent object matching this schema:
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

        Rules:
        - Use only supported types.
        - Use hex colors only.
        - Prefer vStack as the root.
        - Include children only for stack components.
        - Keep depth under 5 levels.
        - Do not invent actions or capabilities yet.
        - If the user asks for a button, use type "button" with props.text.
        - If the user asks for an input, use type "textField" with props.placeholder.

        Example response:
        {
          "id": "root",
          "type": "vStack",
          "props": {
            "spacing": 14,
            "padding": 18,
            "backgroundColor": "#FFF7E8",
            "cornerRadius": 22
          },
          "children": [
            {
              "id": "title",
              "type": "text",
              "props": {
                "text": "Create Account",
                "foregroundColor": "#0D111A"
              },
              "children": null,
              "capability": null
            },
            {
              "id": "email",
              "type": "textField",
              "props": {
                "placeholder": "Email address",
                "backgroundColor": "#FFFFFF",
                "cornerRadius": 12
              },
              "children": null,
              "capability": null
            }
          ],
          "capability": null
        }

        User request:
        \(userPrompt)
        """
    }
}
