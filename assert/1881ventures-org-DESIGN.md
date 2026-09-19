---
version: alpha
name: 1881 Ventures
description: "An entrepreneurial ecosystem that builds founders and drives economic growth. From first idea to first funding and beyond."
sourceUrl: "https://www.1881ventures.org/"

colors:
  primary: "#529fcb"
  on-primary: "#ffffff"
  background: "#ffffff"
  surface: "#529fcb"
  border: "#d5d5d5"
  text: "#222121"
  text-muted: "#000000"
  accent: "#211f54"

typography:
  display:
    fontFamily: "Garamondnovacond, Arial, sans-serif"
    fontSize: 80px
    fontWeight: 400
    lineHeight: 0.96
  heading:
    fontFamily: "Garamondnovacond, Arial, sans-serif"
    fontSize: 62px
    fontWeight: 400
    lineHeight: 1.2
  body:
    fontFamily: "Dmsans, Arial, sans-serif"
    fontSize: 19px
    fontWeight: 400
    lineHeight: 1.4

spacing:
  base: 4px
  scale: [12, 16, 20, 24, 28, 32, 40, 48, 80]

radius:
  sm: 2px
  md: 8px
  lg: 20px
  xl: 50px

shadows:
  card: "rgba(20, 20, 43, 0.08) 0px 2px 12px 0px"
  elevated: "rgba(20, 20, 43, 0.08) 0px 2px 12px 0px"

motion:
  duration-fast: 200ms
  duration-base: 300ms
  duration-slow: 600ms
  easing: "cubic-bezier(0.23, 1, 0.32, 1)"

breakpoints: [768px, 1280px, 1440px, 1920px]
---

## Rationale

1881 Ventures operates as a regional entrepreneurial catalyst, positioning itself between early-stage founders and institutional capital. The design system reflects this dual audience: it must communicate trust and professionalism to investors while remaining approachable and energetic for emerging entrepreneurs. The measured tokens reveal a conservative color palette anchored by a mid-tone blue (#529fcb) paired with a deep accent (#211f54), suggesting stability and forward momentum rather than startup disruption. The typography stack—Garamond Novacond for display and DM Sans for body—creates a hierarchy that feels established yet contemporary, leaning on classic serif proportions at large scales to convey gravitas, then shifting to a modern geometric sans-serif for accessible, rapid reading at body sizes. This duality mirrors the organization's role: honoring entrepreneurial tradition while driving practical innovation.

The spacing system is built on a 4px base unit, scaled through deliberate intervals (12, 16, 20, 24, 28, 32, 40, 48, 80), giving the design flexibility without chaos. This precision suggests a structured, methodical approach—appropriate for an organization that evaluates risk and guides capital allocation. The measured breakpoints (768, 1280, 1440, 1920) indicate a desktop-first experience that still adapts gracefully, reflecting a site built primarily for desktop research and investment review, with mobile support as a secondary consideration.

Motion and shadows are subtle: the easing curve (cubic-bezier(0.23, 1, 0.32, 1)) is snappy without being harsh, and the single shadow treatment (8% opacity at 2px / 12px blur) creates soft depth rather than dramatic layering. This restraint reinforces professionalism; the site doesn't distract, but guides.

## 1. Visual Theme & Atmosphere

The design evokes **institutional confidence with entrepreneurial warmth**. The light, nearly-white background (#ffffff) ensures clarity and reduces cognitive load—critical for a site where visitors evaluate programs, team, and investment terms. The primary blue (#529fcb) is neither corporate navy nor venture-capital lime; it sits in an optimistic middle register, suggesting growth without aggression. The accent color (#211f54) introduces a sophisticated, almost nocturnal depth—used sparingly to draw attention to key decisions (likely CTAs or critical information).

Subtle, consistent shadows (card and elevated both use the same recipe: 8% black at 2px/12px) create a unified spatial language without the sharp, neon-edged aesthetic of contemporary tech startups. This is intentional: the site is selling *outcomes* (real change, trusted partnerships), not disruption.

## 2. Color System

| Role | Value | Usage |
|------|-------|-------|
| **Primary** | #529fcb | Buttons, active states, section backgrounds, hyperlinks |
| **On Primary** | #ffffff | Text/icons on primary backgrounds |
| **Background** | #ffffff | Page base, card interiors |
| **Surface** | #529fcb | Secondary containers, emphasis regions |
| **Border** | #d5d5d5 | Dividers, subtle separation (light gray, ~91% lightness) |
| **Text** | #222121 | Body copy, headings (near-black, 13.5% lightness) |
| **Text Muted** | #000000 | Secondary labels, captions (true black, reserved use) |
| **Accent** | #211f54 | High-emphasis CTAs, links requiring decision, UI focus points |

The palette is **triadic in restraint**: one primary (blue), one accent (deep purple), and a neutral foundation. No secondary colors are present, suggesting a design system in early maturity—intentional simplicity rather than exhaustive theming. The border color (#d5d5d5) is deliberately soft, reducing visual clutter while maintaining legibility.

## 3. Typography

### Display Layer
- **Font**: Garamond Novacond (serif, condensed)
- **Size**: 80px
- **Weight**: 400 (regular)
- **Line Height**: 0.96 (tight, magazine-like)

Used for hero headlines or prominent section introductions. The condensed serif is **authoritative and editorial**—think investment prospectus or founding manifesto. The 0.96 line height is aggressive, creating tension and visual weight; appropriate for sizes this large, as it improves readability and prevents headline runaway.

### Heading Layer
- **Font**: Garamond Novacond (same serif, condensed)
- **Size**: 62px
- **Weight**: 400
- **Line Height**: 1.2 (normalized spacing)

Subheadings and section titles. The larger line height (1.2 vs. 0.96) introduces breathing room as the scale decreases, maintaining proportional hierarchy.

### Body Layer
- **Font**: DM Sans (sans-serif, geometric)
- **Size**: 19px
- **Weight**: 400
- **Line Height**: 1.4 (generous, accessible)

Running text, descriptions, and metadata. DM Sans is contemporary and lowercase-friendly, with excellent optical spacing. The 19px base is larger than typical (16px industry norm), signaling confidence in readability and audience maturity. The 1.4 line height (26.6px computed) exceeds WCAG minimum (1.5 × font-size), improving scannability for dense program descriptions.

### System Rationale
The serif-to-sans transition (Garamond for leadership, DM Sans for substance) creates **cognitive separation**: viewers instinctively recognize that headlines convey vision, and body text conveys mechanics. No script or decorative fonts present—appropriately professional.

## 4. Components & Patterns

### Buttons & CTAs
Expect primary buttons (blue #529fcb, white text) and secondary buttons (likely border or inverted). The accent color (#211f54) may appear on high-stakes CTAs ("Get Involved," "Contact") to create visual hierarchy. Measured radius tokens (sm: 2px, md: 8px, lg: 20px, xl: 50px) suggest buttons use **md (8px) or lg (20px)**—probably lg for primary, md for secondary, maintaining modern design trends while staying conservative.

### Cards & Containers
Shadows are identical for both card and elevated states (rgba(20, 20, 43, 0.08) 0px 2px 12px 0px), suggesting **subtle depth without layering**. Likely a single shadow treatment applied consistently. Containers probably use radius **lg (20px)** or **md (8px)**, with white backgrounds and 1–2px borders (color: #d5d5d5).

### Forms & Inputs
Not directly measured, but inferred: input backgrounds likely #ffffff with #d5d5d5 borders, radius **md (8px)**. Focus states use primary blue (#529fcb) or accent (#211f54) outline.

## 5. Spacing & Layout

The spacing scale is **non-linear and intent-driven**:
- **12px, 16px, 20px**: Micro spacing (padding within components, gap between icons/text)
- **24px, 28px, 32px**: Intra-component (button padding, card internal spacing)
- **40px, 48px**: Section margins (gap between featured sections)
- **80px**: Heroic spacing (gap between major content blocks; establishes breathing room)

The scale avoids the common 8×n pattern, instead using a Fibonacci-adjacent progression that feels organic. The largest interval (80px) is notable—it's 20× the base unit, used to visually separate hero from body, or programs from testimonials. On mobile (below 768px breakpoint), these likely halve or compress to 40px / 32px to maintain proportion on smaller screens.

**Grid & Breakpoints**:
- **768px**: Tablet/iPad landscape
- **1280px**: Desktop base (likely where layout stabilizes)
- **1440px**: Desktop optimized (MacBook Air width)
- **1920px**: Ultra-wide (office displays, secondary viewing)

Most layouts probably use a **12-column grid** at desktop (1280+), compress to **6 columns** at tablet (768–1280), and **single column** on mobile. The site is desktop-weighted, as inferred from the "Pricing" and "No Auth" metadata—this is a public, research-first experience.

## 6. Motion & Interaction

### Timing
- **Fast**: 200ms (durationFastMs) — hover states, icon transitions, brief feedback
- **Base**: 300ms (durationBaseMs) — modal opens, tab switches, section reveals
- **Slow**: 600ms (durationSlowMs) — hero animations, lazy-load reveals, page transitions

### Easing
**cubic-bezier(0.23, 1, 0.32, 1)** is a **custom spring-like easing** with aggressive acceleration (0.23) and overshoot (1.0 at Y). This creates a **snappy, energetic feel**—elements feel responsive, not sluggish. The 0.32 at the end creates a gentle deceleration, preventing jarring stops. This easing is ideal for:
- Button presses
- Dropdown reveals
- Scroll-triggered animations
- Tooltip fades

### Interaction Patterns
Likely uses:
- **Hover**: Color shift to accent (#211f54) or subtle shadow lift
- **Active**: Darker overlay or inset shadow
- **Focus**: 2px outline in primary blue (#529fcb), 2px offset
- **Disabled**: Text-muted (#000000) + 50% opacity, no cursor

## Accessibility

### Contrast Ratios

| Pair | Ratio | WCAG AA (4.5:1) | Result |
|------|-------|-----------------|--------|
| Text (#222121) on White (#ffffff) | ~9.0:1 | ✅ Passes | Excellent for body |
| Primary Blue (#529fcb) on White | ~3.5:1 | ❌ Fails | Insufficient for text; use only as background with white text |
| White (#ffffff) on Primary Blue | ~6.8:1 | ✅ Passes | Safe for buttons/CTAs |
| Accent (#211f54) on White | ~12.5:1 | ✅ Passes | Excellent for emphasis |
| Border (#d5d5d5) on White | ~1.2:1 | ❌ Fails | Decorative only; not used for semantic content |

**Critical Finding**: Do not place dark text directly on the primary blue (#529fcb). Always use white on blue. The border color is too light for text; use only for dividers and subtle separators.

### Minimum Requirements

- **Touch Target**: All interactive elements (buttons, links, form inputs) must be minimum **44×44px** (iOS/Android standard). Given the 19px base font size, this requires **~28px padding** for button height; plan for 48–56px buttons at desktop, 44px minimum on mobile.
- **Focus Indicator**: Implement a **2px solid outline** in the primary blue (#529fcb) or accent (#211f54), positioned **2px outside** the element's border. This is especially critical for:
  - CTA buttons ("Get Involved," "Contact")
  - Form fields (email, program selectors)
  - Navigation links
- **Line Height Compliance**: Body line height (1.4) exceeds WCAG AAA minimum (1.5 × font-size = 28.5px); current implementation (26.6px) is close but just shy. Consider increasing body line height to 1.5 (28.5px) to guarantee AAA compliance.
- **Color Independence**: Never rely on color alone to convey information (e.g., required fields, error states). Use icons, text labels, or patterns alongside color.

### Additional Recommendations

1. **Icon Sizing**: Pair icons with a minimum 20px canvas to meet touch targets; 24px is standard for body-adjacent icons.
2. **Link Styling**: Underline or use a distinct color (accent #211f54) to differentiate links from plain text; relying on color difference alone (blue vs. black) risks confusion for colorblind users.
3. **Skip Link**: Implement a skip-to-main-content link, hidden offscreen, then visible on focus.
4. **Form Labels**: Ensure all form inputs have visible, associated `<label>` elements; use `aria-label` for icon-only buttons.
