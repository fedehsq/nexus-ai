---
name: Lumina AI
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#c7c4d7'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#908fa0'
  outline-variant: '#464554'
  surface-tint: '#c0c1ff'
  primary: '#c0c1ff'
  on-primary: '#1000a9'
  primary-container: '#8083ff'
  on-primary-container: '#0d0096'
  inverse-primary: '#494bd6'
  secondary: '#d0bcff'
  on-secondary: '#3c0091'
  secondary-container: '#571bc1'
  on-secondary-container: '#c4abff'
  tertiary: '#ffb783'
  on-tertiary: '#4f2500'
  tertiary-container: '#d97721'
  on-tertiary-container: '#452000'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d0bcff'
  on-secondary-fixed: '#23005c'
  on-secondary-fixed-variant: '#5516be'
  tertiary-fixed: '#ffdcc5'
  tertiary-fixed-dim: '#ffb783'
  on-tertiary-fixed: '#301400'
  on-tertiary-fixed-variant: '#703700'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  code-sm:
    fontFamily: jetbrainsMono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-padding: 1rem
  stack-gap: 0.75rem
  bubble-padding-x: 1rem
  bubble-padding-y: 0.75rem
  section-margin: 1.5rem
---

## Brand & Style

The design system is anchored in a philosophy of **Intelligent Minimalism**. It aims to evoke a sense of calm efficiency and advanced technological capability without overwhelming the user. The interface acts as a transparent medium for conversation, prioritizing content and readability.

The visual direction combines a professional **Corporate/Modern** foundation with **Glassmorphism** accents to signify the "fluid" and "translucent" nature of artificial intelligence. By utilizing a dark-first aesthetic with vibrant indigo accents, the UI feels both premium and cutting-edge, appealing to power users and casual explorers alike.

## Colors

The palette is optimized for high-end mobile OLED displays, using a deep `background_base` to reduce eye strain.

- **Primary (Electric Indigo):** Used exclusively for high-intent AI actions, the "Send" button, and the user's message bubbles to represent energy and agency.
- **Secondary (Violet):** Reserved for subtle gradients, neural patterns, and accentuating special AI features like model switching.
- **Neutral (Slate/Charcoal):** Provides the structural framework. Different weights of slate create a clear hierarchy between the background, the AI's response bubbles, and secondary UI elements.
- **Semantic Colors:** Use a crisp emerald for "success" (e.g., copied to clipboard) and a soft rose for system errors.

## Typography

The design system utilizes **Inter** for its exceptional legibility and systematic feel. 

- **Hierarchy:** Headlines are tight and bold to provide clear structure in settings and history views. 
- **Message Content:** `body-lg` is the standard for chat bubbles to ensure comfortable reading during long sessions.
- **AI Distinction:** While both user and AI use the same font family, AI text should utilize slightly wider line-heights (1.6x) in long-form responses to improve scannability.
- **Monospace:** Use **JetBrains Mono** for code snippets within chat windows, rendered inside a slightly darker container to distinguish technical data from prose.

## Layout & Spacing

This design system follows a **Fluid Grid** model optimized for mobile devices. 

- **Safe Zones:** A 16px (`1rem`) horizontal margin is maintained globally to prevent content from hitting the screen edges.
- **Chat Rhythm:** Vertical spacing between message bubbles is set to `0.75rem`. However, when the same entity (User or AI) sends consecutive messages, the gap reduces to `0.25rem` to visually group them.
- **Input Bar:** The bottom input area is fixed and occupies the full width minus the safe area, utilizing internal padding of `0.75rem` to house the text field and action icons.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and **Backdrop Blurs** rather than traditional heavy shadows.

1.  **Level 0 (Base):** The deep slate background.
2.  **Level 1 (Submerged):** AI message bubbles, slightly lighter than the base to appear as if they are recessed or part of the system.
3.  **Level 2 (Floating):** User bubbles and the bottom input bar. The input bar uses a `backdrop-filter: blur(12px)` with a 10% white tint to create a glassmorphic effect that lets message content scroll behind it.
4.  **Level 3 (Overlay):** Sidebars and Modals. These use a 20% black shadow with a 30px blur to separate the settings or history from the active conversation.

## Shapes

The shape language is friendly and modern. 

- **Chat Bubbles:** Use `rounded-lg` (16px) for the outer corners. To create a "tail" effect without the literal pointer, the corner closest to the screen edge (right for user, left for AI) should have a reduced radius of 4px.
- **Action Elements:** Buttons and Input fields utilize a fully rounded (pill-shaped) profile to differentiate them from content containers.
- **Cards:** History items and model selection cards use `rounded-lg` to maintain consistency with the chat bubbles.

## Components

### Message Bubbles
- **User:** Solid `primary_color_hex` background with white text. Aligned to the right.
- **AI:** `surface_ai_bubble` background with `text_primary`. Aligned to the left. Includes a small AI sparkle icon in the top left or as an avatar.

### Input Bar
- A container with a subtle `1px` border (white at 10% opacity) and a glassmorphic blur.
- Features a multi-line text input that expands upwards as the user types (up to 5 lines).
- Left-side "plus" icon for attachments and right-side "arrow" button (primary color) for sending.

### Conversation History (Sidebar)
- List items with a hover/active state that uses a subtle indigo tint.
- Timestamps are rendered in `label-sm` using `text_secondary`.
- "New Chat" button should be a prominent floating action button or a top-level list item with a gradient border.

### Settings & Sliders
- **Toggles:** Use the primary indigo color for the "on" state.
- **Sliders:** The track should be the secondary neutral color, while the thumb and active track use the primary indigo.
- **Chips:** Used for quick-prompt suggestions above the input bar. They should have a transparent background with a thin slate border.