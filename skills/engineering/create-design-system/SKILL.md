---
name: create-design-system
description: Creates a design system based on the provided screenshots.
argument-hint: Screenshots to use for generating the design system.
disable-model-invocation: true
---
Build me a design system based on the provided screenshots.

Define tokens for: color palette (name each one), typography scale, spacing scale, border-radius values, shadow depths, and component primitives (buttons, inputs, cards).

Take every value from what the screenshots actually show, not from a generic default scale, because the point is to reproduce this specific look. Where the screenshots don't show something you need, pick a value consistent with the ones they do show, and tell me which values you inferred. If the project already has a styling setup (CSS custom properties, Tailwind config, a theme file), write the tokens in that format.

When you're done, show me the system as a style guide page. Build that page with the tokens themselves, not your own default page styling, so it also shows the system in use.
