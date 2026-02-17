---
name: blend-brand
description: Use when building UI, frontend, landing pages, presentations, or any visual output for Blend or Blend360. Triggers on Blend brand colors, Blend logo, Blend branding, company brand guidelines, marketing materials, slide decks, or any design work needing Blend360 identity.
---

# Blend360 Brand Guidelines

Brand identity reference for Blend360. Use these specs for all visual output.

## Brand Identity

- **Company:** Blend360 (commonly referred to as "Blend")
- **Tagline:** "We blend in so you stand out."
- **Purpose:** Solving big challenges by blending people and AI to make your world a better place
- **Voice:** Professional, informative, friendly, approachable. Adaptable between technical and non-technical audiences.

## Logo

Two SVGs available in `assets/`, using Dark Gray (`#0B0D0E`) fill. Change the `fill` attribute to match your background:

| Asset         | File               | Use                                           |
| ------------- | ------------------ | --------------------------------------------- |
| **Full Logo** | `blend-logo.svg`   | Wordmark + symbol, headers, hero sections     |
| **Symbol**    | `blend-symbol.svg` | Favicons, app icons, small spaces, decorative |

**Logo rules:**

- Maintain clear space around the logo (at least the height of the "B" symbol)
- Never outline, stretch, distort, or add shadows to the logo
- Never use unapproved colors
- Never place text or design elements too close
- Never type the brand name in a different font
- The wordmark uses **Monument Extended** typography

## Color Palette

### Primary Colors

| Name                | Hex       | RGB           | CMYK            | Role                                   |
| ------------------- | --------- | ------------- | --------------- | -------------------------------------- |
| **Neon Turquoise**  | `#00EDED` | 0, 237, 237   | 57, 0, 17, 0    | Primary brand accent, CTAs, highlights |
| **Washed Blue**     | `#053057` | 5, 48, 87     | 100, 85, 39, 32 | Primary dark background                |
| **Light Turquoise** | `#A2F3F3` | 162, 243, 243 | 31, 0, 10, 0    | Secondary accent, light backgrounds    |

### Neutral Colors

| Name          | Hex       | RGB           | CMYK           |
| ------------- | --------- | ------------- | -------------- |
| **White**     | `#FFFFFF` | 255, 255, 255 | 0, 0, 0, 0     |
| **Off White** | `#F4F3F0` | 244, 243, 240 | 3, 2, 4, 0     |
| **Cool Gray** | `#314550` | 49, 69, 80    | 81, 62, 51, 38 |
| **Gray**      | `#1A1A1A` | 26, 26, 26    | 73, 67, 65, 78 |
| **Dark Gray** | `#0B0D0E` | 11, 13, 14    | 75, 67, 65, 84 |

### Color Distribution

| Color            | Percentage |
| ---------------- | ---------- |
| Washed Blue      | 20%        |
| Light Turquoise  | 20%        |
| Neon Turquoise   | 20%        |
| Cool Gray        | 10%        |
| Gray / Dark Gray | 10%        |
| Black            | 10%        |
| White            | 5%         |
| Off White        | 5%         |

### Approved Color Combinations (with contrast ratios)

**Light foreground on dark background:**

| Foreground      | Background  | Contrast |
| --------------- | ----------- | -------- |
| White           | Washed Blue | 13.4:1   |
| White           | Cool Gray   | 10.01:1  |
| White           | Gray        | 17.4:1   |
| White           | Dark Gray   | 19.47:1  |
| Off White       | Washed Blue | 12.07:1  |
| Light Turquoise | Washed Blue | 10.62:1  |
| Light Turquoise | Dark Gray   | 15.44:1  |
| Neon Turquoise  | Washed Blue | 9.76:1   |
| Neon Turquoise  | Dark Gray   | 14.19:1  |

**Dark foreground on light background:**

| Foreground  | Background      | Contrast |
| ----------- | --------------- | -------- |
| Cool Gray   | Off White       | 9.02:1   |
| Cool Gray   | Light Turquoise | 7.93:1   |
| Washed Blue | Off White       | 12.07:1  |
| Washed Blue | Light Turquoise | 10.62:1  |
| Washed Blue | Neon Turquoise  | 9.76:1   |
| Gray        | Light Turquoise | 13.79:1  |
| Dark Gray   | Neon Turquoise  | 14.19:1  |

## Typography

### Primary Font: PP Telegraf

- **Weight:** Regular only (no bold)
- **Use:** All brand communication, marketing materials, digital content
- **By:** Pangram Studio
- **Style:** Mid-century grotesk, rigid angles, tech-inspired
- **Rules:** Use only Regular weight. Create hierarchy through scale and color, not weight. Stroke thickness: min 0.5px,
  max 5px.

### Secondary Font: Montserrat

- **Weight:** Regular only
- **Use:** Microsoft Tools only (PowerPoint, Word, Excel)
- **By:** Julieta Ulanovsky (Google Fonts)
- **Rules:** Same weight-only principle. Use scale and color for hierarchy.

### Web Fallback

When PP Telegraf is unavailable, use `Montserrat` from Google Fonts, or fall back to system sans-serif.

```css
font-family: 'PP Telegraf', 'Montserrat', system-ui, sans-serif;
```

## CSS Quick Reference

```css
:root {
  /* Primary */
  --blend-neon-turquoise: #00EDED;
  --blend-washed-blue: #053057;
  --blend-light-turquoise: #A2F3F3;

  /* Neutrals */
  --blend-white: #FFFFFF;
  --blend-off-white: #F4F3F0;
  --blend-cool-gray: #314550;
  --blend-gray: #1A1A1A;
  --blend-dark-gray: #0B0D0E;
}
```

### Tailwind Config

```js
colors: {
  blend: {
    'neon-turquoise': '#00EDED',
    'washed-blue': '#053057',
    'light-turquoise': '#A2F3F3',
    'off-white': '#F4F3F0',
    'cool-gray': '#314550',
    'gray': '#1A1A1A',
    'dark-gray': '#0B0D0E',
  }
}
```

## Image Style

**Do:**

- Warm and neutral tones
- Low contrast, natural balance
- Clean spaces, minimal compositions
- Genuine, unposed people
- Harmonious color palette in clothing/objects

**Don't:**

- Excessive saturation or high contrast
- Fake, staged, or contrived imagery
- Outdated aesthetic
- Cluttered or busy compositions
- Cold tones

## Symbol Usage

The Blend symbol (two overlapping ellipses) can be used as:

- **Filled:** Solid color element for prominence
- **Stroke:** Thin line element for refinement (min 0.5px, max 5px)
- **Mask:** Photography-filled for visual interest

When cropping the symbol, prioritize the horizontal axis to maintain the infinity concept.

## Assets

All brand assets are in the `assets/` subdirectory of this skill.

### Logos (SVG, Dark Gray `#0B0D0E` fill)

- `~/.claude/skills/blend-brand/assets/blend-logo.svg` (full logo: symbol + wordmark)
- `~/.claude/skills/blend-brand/assets/blend-symbol.svg` (symbol only: overlapping ellipses "B")

### Fonts

- `~/.claude/skills/blend-brand/assets/fonts/PPTelegraf-Regular.otf` (primary brand font)
- `~/.claude/skills/blend-brand/assets/fonts/Montserrat-Regular.ttf` (secondary font, MS Office fallback)

To use in a project, copy the appropriate files to your project's public/assets directory.
