# Design System — "Программа" (NixOS KZ meetup)

Reverse-engineered from `nixos-kz.jpg` (854 × 1114 px, JPEG).
Colors were sampled from pixels; sizes were measured from glyph bounding boxes.
Fonts are identified visually and are **not confirmed** — see [Typography](#2-typography).

All pixel values below are in the coordinate space of the source image (854 px wide).
To scale for another canvas multiply by `target_width / 854`
(for a 1920 px slide: × 2.25; for 1280 px: × 1.5).

## 1. Character of the style

- **Flat, editorial, "terminal-poster"** look: one saturated blue field, white type, no gradients, no images, no rounded corners.
- **Monospace everywhere.** Every text element uses a monospaced grotesque, including headings.
- **Structure through horizontal rules only.** Content is a table: full-width thin white lines separate rows; there are no vertical lines and no cards.
- **Two accent devices only:** green "tape" labels with a hard black shadow, and dark (near-black) small caps text for service rows.
- **Uppercase for structure** (headings, labels, service rows); sentence case for content (names, talk titles).

## 2. Typography

### 2.1 Font families

| Role | Visual description | Closest free match (assumption) | Fallback |
| --- | --- | --- | --- |
| Display (H1, block titles) | Monospace, heavy (ExtraBold/Black), slightly condensed, square-ish counters | Martian Mono Condensed ExtraBold | JetBrains Mono ExtraBold |
| Text (names, titles) | Monospace grotesque, Bold for names, Medium/Regular for titles | Martian Mono / JetBrains Mono | `ui-monospace, monospace` |
| Labels (tags, service rows, numbers) | Same monospace, Bold, uppercase, tiny | Same family, Bold | same |

Requirements for any substitute: full **Cyrillic** coverage, at least 3 weights (400/700/800), true monospace.

### 2.2 Type scale

Font size is estimated from measured cap height (cap height ≈ 0.72 × font size for this kind of face).

| Token | Element in source | Measured cap height | Font size (@854) | Font size (@1920) | Weight | Case | Color |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `display` | `ПРОГРАММА` | 41 px | ~56 px | ~126 px | 800–900 | UPPER | `white` |
| `h2` | `ОС: ОТ КЛАССИКИ К ДЕКЛАРАТИВНОСТИ` | 24 px | ~33 px | ~74 px | 800 | UPPER | `white` |
| `body-strong` | Speaker name `Абай Садыков` | ~14 px | ~19 px | ~43 px | 700 | Sentence | `white` |
| `body` | Talk title `NixOS для всех` | ~14 px | ~19 px | ~43 px | 500 | Sentence | `white` |
| `label` | `ОПЕНИНГ`, `ОТКРЫТЫЙ МИКРОФОН`, tag text | 9 px | ~12 px | ~27 px | 700 | UPPER | `ink` |
| `caption` | `БЛОК 1`, row numbers `01`, `// 8 докладов от практиков` | 7–8 px | ~10–11 px | ~23–25 px | 700 | UPPER / digits | `ink-muted` / `blue-200` / `ink` |

Line height:

- `body` multi-line titles: ~24 px per line (@854) → **line-height ≈ 1.25**.
- `display` and `h2`: single line, **line-height ≈ 1.0–1.1**.

Letter spacing: none visible (monospace default, `0`). Small uppercase labels look slightly tracked; `0.02em` is a safe value.

## 3. Color palette

| Token | HEX (sampled) | Usage |
| --- | --- | --- |
| `blue-500` (background) | `#0A76EC` | The only background color. Fills the whole canvas. |
| `white` | `#FFFFFF` | Display, headings, names, talk titles, horizontal rules. |
| `green-400` (accent) | `#57C07D` (range `#47B576`–`#57C07D` due to JPEG) | Background of tape labels. |
| `ink` | `#00101B` (near-black, blue-tinted; may be pure `#000000` in source) | Text on green labels; service-row text (`ОПЕНИНГ`, `НЕТВОРКИНГ`); leading dash `—`; tag shadow. |
| `ink-muted` | `ink` at ~60 % opacity (renders ≈ `#315D9A` on blue) | Block eyebrow labels (`БЛОК 1`, `БЛОК 2`). |
| `blue-200` | `#A8D8FF` (sampled `#A0D5FF`–`#BAE2FF`) | Row numbers `01`…`08`. |
| `rule` | `#FFFFFF` at ~90 % opacity | Horizontal separators. |

Contrast notes:

- White on `#0A76EC` ≈ 4.4 : 1 — passes WCAG AA only for large/bold text. Keep body text ≥ 18.66 px bold or ≥ 24 px regular in real use.
- `ink` on `#0A76EC` ≈ 4.4 : 1 — acceptable for bold labels only.
- `ink` on `#57C07D` ≈ 8.5 : 1 — fine.

## 4. Layout and grid

### 4.1 Page frame

| Parameter | Value (@854) | Ratio of width |
| --- | --- | --- |
| Canvas | 854 × 1114 | portrait ≈ 3 : 4 |
| Left margin | 35 px | 4.1 % |
| Right margin | 31 px (content ends at x = 823) | 3.6 % |
| Content width | 789 px | 92.4 % |
| Top margin to first element | 18 px | — |

Treat margins as symmetric `35 px` (≈ 4 %) when rebuilding.

### 4.2 Columns (table rows)

| Column | Starts at x | Offset from content left | Content |
| --- | --- | --- | --- |
| A — index | 35 | 0 | Row number `01` or dash `—` |
| B — speaker / service label | 93 | 58 px (≈ 7 % of content width) | Speaker name or `ОПЕНИНГ` |
| C — talk title | 469 | 434 px (≈ 55 % of content width) | Talk title, wraps inside column C |

Column C width: 469 → 823 = 354 px (≈ 45 % of content width).

### 4.3 Vertical rhythm

Measured positions of horizontal rules (y, px):
`169, 208, 292, 376, 436, 497, 581, 620, 704, 764, 848, 909, 1015, 1054`.

| Row type | Height (rule to rule) | Text top padding | Notes |
| --- | --- | --- | --- |
| Service row (`ОПЕНИНГ`, `НЕТВОРКИНГ`, `ОТКРЫТЫЙ МИКРОФОН`) | 39 px | ~16 px | Text vertically centered |
| Talk row, 1-line title | 60 px | ~22 px | Bottom padding ≈ 22 px |
| Talk row, 2-line title | 84 px | ~22 px | +24 px per extra line |
| Talk row, 3-line title | 106 px | ~22 px | — |

Block header (between a service row and the first talk row):

| Element | Distance |
| --- | --- |
| Rule above → eyebrow `БЛОК N` top | 30 px |
| Eyebrow bottom → block title top | ~7 px |
| Block title bottom → rule below | ~11 px |

Page header:

| Element | y range |
| --- | --- |
| Tape label `03 / ПРОГРАММА` | 18–44 |
| Display `ПРОГРАММА` | 58–98 |
| Tape label `// 8 докладов от практиков` | 118–140 |
| First rule | 169 |

Spacing scale derived from the measurements (base unit 4 px @854):
`4, 8, 12, 16, 22, 30, 40` → use tokens `space-1 … space-7`.

## 5. Components

### 5.1 Tape label (green tag)

- Background `green-400`, text `ink`, `label` or `caption` style, uppercase or lowercase as written.
- Padding ≈ 6 px vertical × 8 px horizontal (@854).
- **Hard shadow:** solid `ink`, offset ≈ 3–4 px right and 3–4 px down, no blur. Visible on the top tag (`03 / ПРОГРАММА`); the lower tag has none or a weaker one.
- No border radius.
- Two variants:
  - **Section index** — `NN / SECTION NAME`, bold, with shadow.
  - **Subtitle** — `// description`, smaller, sits under the display heading.

### 5.2 Display heading

- `display` style, white, uppercase, aligned to the left margin.
- Always preceded by a section-index tape label and followed by a subtitle tape label.

### 5.3 Horizontal rule

- Full content width (x 35 → 823), 1–1.5 px, `rule` color.
- Used above and below every row; adjacent rows share one rule.

### 5.4 Block header

- Eyebrow: `caption`, uppercase, `ink-muted` — `БЛОК 1`.
- Title: `h2`, white, uppercase, one line, may contain a colon (`ОС: ОТ КЛАССИКИ К ДЕКЛАРАТИВНОСТИ`).
- Closed by a rule directly under the title. No rule above the eyebrow (the previous service row's rule plays that role).

### 5.5 Talk row

- Column A: two-digit index `01`…`08`, `caption`, `blue-200`, aligned to the cap height of the name.
- Column B: speaker name, `body-strong`, white.
- Column C: talk title, `body`, white, wraps; preserves original casing and Latin product names (`NixOS`, `RHEL`, `KubernetesOS`).
- Top-aligned: all three columns share the same top line.

### 5.6 Service row

- Column A: em dash `—` in `ink`.
- Column B: label in `label` style, `ink`, uppercase (`ОПЕНИНГ`, `НЕТВОРКИНГ`).
- Column C (optional): note in `caption` style, `ink`, sentence case (`Все спикеры · вопросы, споры, итоги`). Uses middle dot `·` as separator.

### 5.7 Artifact to ignore

Talk `08` has a faint lighter rectangle around its title (border ≈ `#1E7CE6`, 1 px). It looks like a selection/focus frame left over from the editor, not a design element. Do not reproduce it.

## 6. Typographic conventions

- Em dash `—` for service rows and inside titles (`Опросник сдан — компания защищена?`).
- `//` as a comment-style prefix for subtitles (code aesthetic).
- `/` with spaces as a breadcrumb separator (`03 / ПРОГРАММА`).
- `·` (middle dot) as an inline list separator.
- `<` and other code symbols are allowed in titles as-is (`Агент не может < Агент не должен`).
- Two-digit zero-padded numbering (`01`, not `1`).

## 7. Tokens (CSS)

```css
@import url('https://fonts.googleapis.com/css2?family=Martian+Mono:wdth,wght@75..112.5,400..800&display=swap');

:root {
  /* color */
  --color-bg: #0A76EC;
  --color-fg: #FFFFFF;
  --color-accent: #57C07D;
  --color-ink: #00101B;
  --color-ink-muted: rgb(0 16 27 / 0.6);
  --color-index: #A8D8FF;
  --color-rule: rgb(255 255 255 / 0.9);

  /* font */
  --font-mono: 'Martian Mono', 'JetBrains Mono', ui-monospace, monospace;

  /* type scale, base canvas 854 px wide */
  --fs-display: 56px;
  --fs-h2: 33px;
  --fs-body: 19px;
  --fs-label: 12px;
  --fs-caption: 10.5px;

  --lh-tight: 1.05;
  --lh-body: 1.25;

  /* spacing */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 22px;
  --space-6: 30px;
  --space-7: 40px;

  /* layout */
  --page-margin: 35px;
  --col-b: 58px;          /* offset of speaker column */
  --col-c: 55%;           /* offset of title column, of content width */
  --rule-width: 1.5px;

  /* tag */
  --tag-pad: 6px 8px;
  --tag-shadow: 4px 4px 0 var(--color-ink);
}

.tag {
  display: inline-block;
  padding: var(--tag-pad);
  background: var(--color-accent);
  color: var(--color-ink);
  font: 700 var(--fs-label)/1 var(--font-mono);
  text-transform: uppercase;
  box-shadow: var(--tag-shadow);
}

.display {
  font: 800 var(--fs-display)/var(--lh-tight) var(--font-mono);
  font-stretch: 75%;
  text-transform: uppercase;
  color: var(--color-fg);
}

.row {
  display: grid;
  grid-template-columns: var(--col-b) calc(var(--col-c) - var(--col-b)) 1fr;
  padding: var(--space-5) 0;
  border-top: var(--rule-width) solid var(--color-rule);
}
```

## 8. Do / Don't

Do:

- Keep a single background color across the whole page.
- Align everything to the three columns and the left margin.
- Use white for content and `ink` only for labels/service rows.
- Separate everything with full-width horizontal rules.

Don't:

- Add vertical rules, cards, rounded corners, gradients or photos.
- Use a proportional (non-mono) font anywhere.
- Use green for text — green is only a label background.
- Center-align anything.
