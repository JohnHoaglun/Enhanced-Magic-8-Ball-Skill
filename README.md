# Enhanced Magic 8 Ball Skill

A conversational implementation of **Enhanced Magic 8 Ball**. It preserves the classic ritual: the user thinks of a private yes-or-no question, invokes the skill, and receives one random saying. The question is neither collected nor used to determine the outcome.

## Behavior

- Uses the complete curated saying catalog from the product specification.
- Preserves 50% affirmative, 25% noncommittal, and 25% negative outcome selection.
- Starts a fresh answer cycle for each conversation; it does not persist answer-deck state between conversations.
- Returns only the selected saying—never a theme, category, source, analysis, or disclaimer.
- Collects no question text, analytics, or identifiers.

## Product Materials

- [Product specification](Magic%208%20Ball%20--%20Product%20Spec.md)
- `Magic 8 Ball -- Approved Idle UI Concept.png` — approved visual reference shared across product variants.

## Status

Product requirements and design direction are complete. Implementation is pending.
