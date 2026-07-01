# Money Me — Design System

## 1. Brand Philosophy

Serious, modern, trustworthy financial tool. No gamification, no playful elements.
Design communicates precision, stability, and control.
Every pixel serves a purpose — decoration is minimal.

## 2. Color Palette

### Primary (restricted to 3)

| Role | Hex | Usage |
|------|-----|-------|
| Primary | `#1B2A4A` | Navigation, primary buttons, headers |
| Accent | `#4A7CF7` | Interactive elements, links, active states |
| Surface bg | `#F4F5F7` | Page background |

### Semantic (muted, low saturation)

| Role | Hex | Usage |
|------|-----|-------|
| Success | `#2E7D6F` | Income, positive changes |
| Error | `#C0392B` | Expenses, destructive actions |
| Warning | `#D4891D` | Budget alerts, caution |
| Info | `#4A7CF7` | Informational elements |

### Neutral scale

| Token | Hex | Usage |
|-------|-----|-------|
| Text primary | `#1E2028` | Headlines, body |
| Text secondary | `#6B7280` | Labels, captions |
| Text tertiary | `#9CA3AF` | Placeholders, disabled |
| Border | `#E2E4E8` | Card borders, dividers |
| Divider | `#F0F1F3` | Subtle separators |

### Contrast compliance
- Text on primary: white (ratio 8.5:1)
- Text on accent: white (ratio 5.2:1)
- Body text on surface: `#1E2028` on `#F4F5F7` (ratio 15:1)
- Secondary text on surface: `#6B7280` on `#F4F5F7` (ratio 4.8:1)

### What NOT to do
- No gradients in cards
- No bright greens (`#00FF00`), bright reds, neon colors
- No color just for decoration — every color carries meaning
- Maximum 2 accent colors per screen

## 3. Typography

### Font stack
- Primary: Inter (weights 400, 500, 600, 700)
- Monospace: JetBrains Mono (weights 400, 500) — only for monetary values

### Type scale (8 levels max)

| Style | Size | Weight | Letter-spacing | Used for |
|-------|------|--------|----------------|----------|
| displayLarge | 32px | 700 | -0.5 | Hero numbers, balance |
| headlineMedium | 22px | 600 | -0.2 | Page titles |
| titleLarge | 18px | 600 | 0 | Section headers |
| titleMedium | 15px | 600 | 0 | Card titles, dialogs |
| bodyLarge | 16px | 400 | 0 | Lead paragraphs |
| bodyMedium | 14px | 400 | 0 | Default body text |
| bodySmall | 13px | 400 | 0 | Secondary info, metadata |
| labelLarge | 14px | 500 | 0.2 | Form labels, button text |
| labelSmall | 12px | 500 | 0.2 | Small labels |
| caption | 11px | 400 | 0 | Legal, timestamps, hints |

### Monetary values
| Style | Size | Font |
|-------|------|------|
| amountLarge | 28px 700 | JetBrains Mono |
| amountSmall | 16px 600 | JetBrains Mono |

### Line-height
- Display/headline: 1.2
- Title: 1.3
- Body: 1.5
- Label/caption: 1.4

### Rules
- Never use more than 2 font weights within a single component
- Monetary values ALWAYS use monospace for alignment
- No underlined text except links
- No all-caps except short labels (max 3 words)

## 4. Spacing & Negative Space

### Scale (6 levels)

| Token | px | Usage |
|-------|----|-------|
| xs | 4 | Icons within buttons, tight gaps |
| sm | 8 | Between related elements |
| md | 16 | Card padding, between sections |
| lg | 24 | Section separation |
| xl | 32 | Page margins, major sections |
| xxl | 48 | Hero section padding |

### Negative space rules
- Cards: minimum 16px internal padding
- Between cards: 12px
- Between sections: 24px
- Page horizontal padding: 16px (mobile), 24px (tablet+)
- Line height in paragraphs: 1.5 minimum
- Minimum touch target: 44px (any tappable element)

## 5. Radius

### Scale (3 levels)

| Token | px | Usage |
|-------|----|-------|
| sm | 6 | Input fields, small cards |
| md | 10 | Cards, dialogs, large containers |
| lg | 14 | Modals, bottom sheets |

### Rules
- No fully rounded elements (`borderRadius: 999` is forbidden)
- Buttons: 8px (use md)
- Cards: 10px (use md)
- Input fields: 6px (use sm)
- Chips/pills: 6px (use sm) — never pill-shaped
- Modals/bottom sheets: 14px top corners only

## 6. Shadows

### Scale (2 levels)

| Level | Definition | Usage |
|-------|-----------|-------|
| card | `0 2px 8px rgba(0,0,0,0.06)` | Default card |
| elevated | `0 4px 16px rgba(0,0,0,0.10)` | Modals, dropdowns, FAB |

### Rules
- No shadows on navigation bars
- Cards use border (`1px solid #E2E4E8`) instead of shadow for a cleaner look
- Elevated elements only use shadow

## 7. Buttons

### Primary
- Height: 44px (default), 36px (small)
- Background: `#1B2A4A` (primary)
- Text: white, 14px/500, 0.2 letter-spacing
- Radius: 8px
- Padding horizontal: 24px (default), 18px (small)
- Icon + text: icon 16px, 8px gap
- Hover: darken 5%
- Disabled: opacity 0.4

### Secondary (outlined)
- Same dimensions as primary
- Border: 1.5px solid `#4A7CF7`
- Text: `#4A7CF7`
- No background fill

### Text (ghost)
- No border, no background
- Text: `#4A7CF7`
- Padding: 8px horizontal
- Only for secondary actions

### Icon button
- 40x40px touch target
- Icon: 20px
- Color: `#6B7280` (default), `#1E2028` (active)

### What NOT to do
- No rounded pill buttons
- No gradient buttons
- No full-width buttons within cards (prefer inline)

## 8. Form Fields

### Default state
- Height: 44px
- Background: `#FFFFFF`
- Border: 1px `#E2E4E8`
- Radius: 6px
- Label: 14px/500, `#6B7280`, 8px above field
- Text: 14px/400, `#1E2028`
- Padding: 14px 16px (input), 16px top (label)

### Focus state
- Border: 1.5px `#4A7CF7`

### Error state
- Border: 1.5px `#C0392B`
- Error text: 12px/400, `#C0392B`, 4px below field

### Disabled state
- Background: `#F4F5F7`
- Text: `#9CA3AF`

### Rules
- Label is always outside the field (never floating placeholder)
- Helper text below field when needed
- Inline validation only on blur, not on every keystroke
- No filled background (keep white) — only disabled uses bg fill

## 9. Cards

### Structure
- Background: white
- Border: 1px `#E2E4E8`
- Radius: 10px
- Padding: 16px
- No shadow
- No gradient

### Interactive card
- Hover: subtle border color change to `#4A7CF7`
- Tap: brief opacity change

### What NOT to do
- No image background cards
- No overlapping elements
- No more than 2 levels of nesting

## 10. Icons

### Source
- Material Icons (Outlined style only — never filled)
- Size: 20px (default), 16px (inline), 24px (empty states)

### Color
- Default: `#6B7280`
- Interactive: `#4A7CF7`
- In buttons: white (primary), `#4A7CF7` (secondary)

### Rules
- Icon + text: 8px gap
- Always outlined variant
- No animated icons
- No custom icon sets (only Material)
- Icon within a button is always the same size as the text

## 11. Charts & Data Visualization

### Color sequence for charts
```
#4A7CF7  (blue, primary)
#2E7D6F  (teal)
#D4891D  (amber)
#7C6FF7  (purple)
#C0392B  (red)
#6B7280  (gray)
```

### Chart style
- No 3D effects
- No gradients in bars/pies
- No grid lines (use minimal reference lines)
- Bar charts: flat bars, 6px radius on top corners only
- Pie charts: no gap between segments, no exploded slices
- Line charts: 2px stroke, no dot markers, no fill below line

### Rules
- Maximum 6 color segments per chart
- Use the sequence order strictly (don't skip)
- Labels: `#6B7280`, 11px
- Value annotations: `#1E2028`, monospace, 12px/500

## 12. Navigation

### Bottom navigation (mobile)
- Background: white
- Height: 56px
- Icons: 20px outlined
- Active: `#1B2A4A` + label
- Inactive: `#9CA3AF`
- No badge counts

### Top app bar
- Background: white
- Height: 56px
- Title: 18px/600
- No elevation (use 1px bottom border)
- Actions: icon buttons, 40px touch target

### Drawer (desktop)
- Width: 240px
- Items: 44px height, 16px horizontal padding
- Active: `#1B2A4A` text + 3px left border
- Divider between logical groups

## 13. Data Tables

- Header row: 40px, `#F4F5F7` bg, 13px/600 text
- Body rows: 44px, alternating white
- Border: 1px `#E2E4E8` (horizontal only)
- Sort indicator: arrow icon on hover
- First column: left-aligned, bold
- Numeric columns: right-aligned, monospace
- On mobile: switch to card layout (label: value per row)

## 14. Empty & Error States

### Empty state
- Centered layout
- Icon: 48px, outlined, `#9CA3AF`
- Title: 16px/600, `#1E2028`
- Description: 14px/400, `#6B7280`
- Action button (optional): 44px

### Error state
- Centered layout
- Icon: 48px, `#C0392B`
- Title: 16px/600, `#C0392B`
- Description: 14px/400, `#6B7280`
- Retry button: outlined style

### Loading state
- Skeleton screens preferred over spinners
- Pulse animation (opacity 0.3→1.0)
- Match dimensions of actual content
- Never show spinners for full-page loads

---

## 15. Implementation Checklist

- [ ] AppColors: 3 primary + 4 semantic + 7 neutral
- [ ] AppTypography: 10 styles + 2 monetary
- [ ] AppSpacing: 6 levels
- [ ] AppRadius: 3 levels
- [ ] AppShadows: 2 levels
- [ ] All icons use outlined variant
- [ ] No borderRadius: 999 anywhere
- [ ] No gradients in cards/buttons
- [ ] Monetary values use monospace
- [ ] Charts use defined 6-color sequence
- [ ] All buttons 44px min touch target
- [ ] Cards use border instead of shadow
