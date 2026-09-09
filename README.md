# CNAM TYPST Template

A modular and organized TYPST template for creating professional documents using CNAM branding and styling.

Originally based on [hzkonor's bubble-template](https://github.com/hzkonor/bubble-template) and uses [CNAM](https://www.cnam.fr/)'s logo and colors. The code block styling is adapted from [typst-endfield-doc-theme](https://github.com/Ives-Natsume/typst-endfield-doc-theme).

## Dependencies

This template uses the following external packages:
- `@preview/great-theorems:0.1.2` - Mathematical theorem environments
- `@preview/headcount:0.1.0` - Counter management
- `@preview/hydra:0.6.2` - Intelligent page headers with section awareness
- `@preview/i-figured:0.2.4` - Figure and equation numbering
- `@preview/orchid:0.1.0` - ORCID link generation (required when using ORCID author fields)

## Project Structure

```text
├── src/
│   ├── lib/               # Template library files
│   │   ├── store.typ      # Configuration schema, defaults and document-wide state
│   │   ├── themes.typ     # Shipped themes and document presets
│   │   ├── config.typ     # Template entrypoint (clean-cnam-template)
│   │   ├── components.typ # UI components (blockquote, my-block, code)
│   │   ├── layout.typ     # Document layout and styling
│   │   ├── utils.typ      # Utility functions
│   │   ├── colors.typ     # Color definitions
│   │   └── math.typ       # Mathematical environments
│   └── lib.typ            # Main package entrypoint (local import)
├── docs/
│   └── preview.typ        # Demo document used by `just preview`
├── scripts/               # Packaging and development helpers
├── template/
│   └── assets/            # Static assets (logos, images)
│       └── cnam_logo.svg  # CNAM logo
├── main.typ               # Example document using the published package
└── README.md
```

## Features

- **Modular Design**: Template split into logical, maintainable modules
- **Single Configuration Object**: One nested `config` dictionary drives the whole document, and every component reads it
- **Themes and Presets**: Composable configuration layers for the look (`sobre`, `dark`, `monochrome`) and the document shape (`article`, `memoire`, `tp`)
- **Typo Protection**: An unknown configuration key raises an error naming the valid keys, instead of being silently ignored
- **CNAM Branding**: Official CNAM colors and styling
- **Themeable Components**: Blocks, quotes, code and math environments derive their colors from the palette
- **Enhanced Code Blocks**: Syntax highlighting, line numbers, filename labels
- **Rich Components**: Custom blockquotes, styled content blocks
- **Math Support**: Mathematical definitions, theorems, examples
- **Smart Headers**: Context-aware page headers
- **Responsive Layout**: Professional document layout with decorative elements

## Usage

### Basic Usage

1. Import the template in your document:

   - Using the published package (as in `main.typ`):
   ```typst
   #import "@preview/clean-cnam-template:2.0.0": *
   ```

   - Using this repository locally (from `src/`):
   ```text
   #import "src/lib.typ": *
   ```

2. Configure your document through the `config` dictionary:
```typst
#show: clean-cnam-template.with(config: (
  info: (
    title: "Your Title",
    subtitle: "Subtitle",
    author: "Your Name",
    class: "Course Name",
    // If using the package, point to your own copy of the logo
    // If using this repo locally, you can use the provided logo path
    logo: image("template/assets/cnam_logo.svg"),
    start-date: datetime(day: 4, month: 9, year: 2024),
  ),
  colors: (primary: "#C4122E"),  // Custom color (default is "E94845")
  fonts: (
    default: (name: "New Computer Modern Math", weight: 400),
    code: (name: "Zed Plex Mono", weight: 400),
  ),
))
```

3. Write your content using the available components and styling.

### The Configuration Object

`clean-cnam-template` takes a single parameter, `config`: a nested dictionary merged over the template defaults and published to a document-wide state.

Three consequences are worth knowing:

- **Overrides are partial at every depth.** `(cover: (title: (size: 3em)))` changes only the title size; color, weight, font and alignment keep their defaults.
- **An unknown key is an error.** A typo such as `(cover: (titel: "..."))` stops the compilation with `unknown option 'config.cover.titel'` followed by the list of valid keys, rather than being silently dropped.
- **Components follow the configuration.** Blocks, quotes, code blocks and math environments read the resolved palette and fonts, so restyling the document does not mean restyling every call site.

Your own code can read the resolved configuration from any `context` block:

```typst
#context {
  let cfg = get-config()
  text(fill: cfg.colors.primary)[This follows the theme]
}
```

`default-config` is exported too, which is handy to inspect the full tree or to build a preset on top of it.

### Complete Configuration Reference

#### `info` -- document metadata and cover content

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `title` | string | `""` | Document title. Can also be set via `cover.title.text` (cover value takes priority). |
| `subtitle` | string | `""` | Document subtitle. Can also be set via `cover.subtitle.text` (cover value takes priority). |
| `subsubtitle` | string | `""` | Optional third cover line rendered below the subtitle in a smaller style. Can also be set via `cover.subsubtitle.text`. Omitted when empty. |
| `author` | string / dict / array | `""` | Author name(s). Accepts a plain string, a dict `(name: "..", orcid: "..", email: "..")`, or a mixed array. Rendering: email only → underlined `mailto:` link; orcid only → name + icon linked to orcid.org; both → name links to `mailto:`, ORCID icon links separately to orcid.org. |
| `affiliation` | string | `""` | Author's affiliation/institution |
| `year` | int / auto | `auto` (current year) | Year for school year calculation. `none` hides it. |
| `class` | string / none | `none` | Class/course name |
| `start-date` | datetime / auto / none | `auto` (today) | Document start date. `none` hides the date. |
| `last-updated-date` | datetime / auto / none | `auto` (today) | Last updated date |
| `logo` | image / none | `none` | Logo image to display |

#### `colors` -- semantic palette

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `primary` | color / string | `"E94845"` | Primary theme color. Accepts a color or a hex string. |
| `secondary` | color / auto | `auto` | Decorative circles and accents. `auto` = `primary` lightened by 30%. |
| `outline` | color / auto | `auto` | Table of contents entries. `auto` = default text color. |
| `page-number` | color / auto | `auto` | Page numbers. `auto` = default text color. |
| `neutral-lightest` | color | `luma(250)` | Reserved light shade, available to your own components |
| `neutral-light` | color | `luma(230)` | `my-block` and `blockquote` background |
| `neutral-border` | color | `luma(180)` | Reserved border shade, available to your own components |
| `neutral` | color | `luma(170)` | Blockquote accent, code line numbers |
| `neutral-dark` | color | `luma(100)` | Blockquote attribution, muted captions |
| `neutral-darkest` | color | `luma(80)` | Reserved dark shade, available to your own components |
| `definition` | color | `rgb("#ff0000")` | `#definition` environment |
| `example` | color | `rgb("#0000ff")` | `#example` environment |
| `theorem` | color | `rgb("#800080")` | `#theorem` environment |

Components derive their shades from this palette, so overriding `neutral-light` restyles every block and blockquote at once, and overriding `definition` restyles every definition. Individual call sites can still override their own colors.

#### `fonts` -- typography

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `default` | object | `(name: "New Computer Modern Math", weight: 400)` | Base font, the fallback for the entries below |
| `body` | object | `auto` members | Body text (cascades from `default`) |
| `title` | object | `auto` members | Titles and headings (cascades from `default`) |
| `chapter` | object | `auto` members, `size: 1.5em` | Level-1 chapter headings (cascades from `title`) |
| `code` | object | `(name: "Zed Plex Mono", weight: 400)` | Code blocks |
| `inline-raw` | object | `auto` members | Inline code (cascades from `body`) |
| `size` | length | `12pt` | Base body text size |

#### `page` -- page setup

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `margin` | dictionary | `(top: 2.5cm, right: 1.27cm, bottom: 1.75cm, left: 1.27cm)` | Page margins, partial overrides supported |
| `numbering` | string | `"1 / 1"` | Page numbering pattern |
| `number-align` | alignment | `bottom + right` | Page number placement |

#### `code` -- code block colors

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `accent` | color / auto | `auto` | Left rule and language tab. `auto` = the language's own color, falling back to `colors.primary`. Set a color to pin every block and ignore the language table. |
| `background` | color / auto | `auto` | Behind the code. `auto` = the accent lightened to 94%. |
| `lang-colors` | dictionary | ~45 languages | Language name (lowercased) to color. Open-ended: unknown keys are accepted. |
| `lang-aliases` | dictionary | `py`, `rs`, `sh`, `ts`, `c++`, ... | Alternate spellings to `lang-colors` keys. Also open-ended. |

See [Colors per Language](#colors-per-language) for the resolution order and examples.

#### `render` -- rendering hooks

Each key takes `auto` (the built-in implementation) or a function receiving the resolved configuration.

| Key | Signature | Replaces |
|-----|-----------|----------|
| `cover` | `(cfg) => content` | The cover page content. Not the page break that follows it, nor the outline. |
| `decorations` | `(cfg) => content` | The shapes placed behind the cover. Still gated by `cover.decorations`. |
| `header` | `(cfg) => content` | The running page header. |
| `footer` | `(cfg) => content` | The page footer, page numbering included. |
| `chapter` | `(cfg, it, label: bool) => content` | The decorated chapter page. Not the page break, nor the heading counter bookkeeping. |

The built-ins are exported as `default-cover`, `default-decorations`, `default-header` and `default-chapter`, so a hook can wrap one instead of starting over. See [Rendering Hooks](#rendering-hooks).

#### `headings` -- level-1 heading rendering

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `chapter-style` | string | `"decorated"` | `"decorated"` opens a centered chapter page with rules and its own font size. `"plain"` renders a normal in-flow level-1 heading, still using `fonts.chapter` so it outranks a level-2 heading. |
| `chapter-pagebreak` | bool | `true` | Decorated style only: start each chapter on a new page |
| `chapter-label` | bool | `true` | Decorated style only: the "Chapitre N" line above the title |

#### `outline` -- table of contents

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `enabled` | bool | `true` | Render the table of contents after the cover |
| `custom` | content / none | `none` | Content rendered instead of the default outline |
| `indent` | function / auto | `auto` | Passed to Typst's `outline(indent: ..)` |
| `depth` | int / none | `none` | Deepest level shown. `none` = every level. |

#### Top-level keys

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `lang` | string | `"fr"` | Document language (`"fr"`, `"en"`) |
| `print` | bool | `false` | Strip link color, underline, and glossary markers for print output |
| `color-words` | array | `()` | Words automatically highlighted with the primary color |
| `cover` | dictionary | see below | Cover page configuration (see [Cover Page](#cover-page-customization)) |

### Themes and Presets

A theme is a partial configuration dictionary applied *under* your own `config`. It is validated against the same schema, so it can touch any option, and anything it sets remains overridable per document.

```typst
#show: clean-cnam-template.with(
  theme: themes.sobre,
  config: (info: (title: "Rapport")),
)
```

Pass an array to compose several layers. Later layers win, and your `config` always wins over all of them:

```typst
#show: clean-cnam-template.with(
  theme: (presets.memoire, themes.sobre),
  config: (
    info: (title: "Rapport"),
    cover: (title: (color: rgb("#004400"))),  // wins over the theme
  ),
)
```

Merging is recursive, so a second layer refines the first instead of replacing it wholesale: `themes.dark` sets `cover.title.color` and `themes.monochrome` sets `colors.primary`, and composing them keeps both.

#### Visual themes (`themes`)

| Name | Effect |
|------|--------|
| `cnam` | The template defaults, spelled out. Changes nothing, but gives a readable starting point to copy from. |
| `sobre` | No decorative circles, neutral cover text. The primary color stays on headings, links and accents only. Suited to a dissertation handed to a jury. |
| `dark` | Dark cover with white text, decorations kept. |
| `monochrome` | Greyscale palette for black and white printing. Pair it with `config: (print: true)`. Syntax highlighting inside code blocks stays colored: it comes from Typst's built-in `raw` theme, not from this palette. |

#### Document presets (`presets`)

| Name | Effect |
|------|--------|
| `article` | Short pieces. Level-1 headings stay in the flow instead of opening a decorated chapter page, decorations are dropped, margins tighten to 2cm. |
| `memoire` | A wider left margin (2.5cm) to survive binding, a two-level outline, and a date range on the cover. |
| `tp` | Compact lab reports. 11pt body, tighter margins, no outline. |

#### Writing your own

A theme is just a dictionary, so there is nothing to subclass:

```typst
#let mon-theme = (
  colors: (primary: rgb("#00539F")),
  fonts: (title: (name: "Inter Display", weight: 700)),
  cover: (decorations: false, title: (size: 3em)),
)

#show: clean-cnam-template.with(theme: mon-theme, config: (info: (title: "Rapport")))
```

A theme cannot compute a value from another layer (it cannot say "20% lighter than whatever primary ends up being"), because layers are merged before resolution. The `auto` cascades cover the usual cases: leaving `colors.secondary` or `cover.title.color` alone lets them derive from the final `colors.primary`, whoever set it.

### Migrating from 1.x

Every option moved inside the `config` dictionary, grouped by section. The values themselves are unchanged.

| 1.x | 2.x |
|-----|-----|
| `title:`, `subtitle:`, `subsubtitle:`, `author:`, `affiliation:`, `class:`, `year:`, `start-date:`, `last-updated-date:`, `logo:` | `config.info.*` |
| `colors: (main: "..")` | `config.colors.primary` |
| `colors: (outline: .., page-number: ..)` | `config.colors.*` (unchanged names) |
| `fonts: (..)` | `config.fonts.*` (unchanged names) |
| `margin: (..)` | `config.page.margin` |
| `outline-code: none` | `config.outline.enabled: true` (the default) |
| `outline-code: false` | `config.outline.enabled: false` |
| `outline-code: <content>` | `config.outline.custom: <content>` |
| `cover: (..)` | `config.cover.*` (unchanged names) |
| `cover: (second-logo: (image: ..))` | unchanged, but `image` now defaults to `none` inside a full dict |
| `language: "en"` | `config.lang` |
| `color-words:`, `print:` | `config.*` (unchanged names) |
| `show-secondary-header:` | removed, it never did anything |

Before:

```typst
#show: clean-cnam-template.with(
  title: "Rapport",
  author: "Tom Planche",
  colors: (main: "#C4122E"),
  outline-code: false,
)
```

After:

```typst
#show: clean-cnam-template.with(config: (
  info: (title: "Rapport", author: "Tom Planche"),
  colors: (primary: "#C4122E"),
  outline: (enabled: false),
))
```

Two removals to be aware of:

- `fonts.typ` is gone. Its state moved into `store.typ`; `get-fonts()` still works and now reads `config.fonts`, but `set-fonts()` was removed since the configuration is the single source of truth.
- `page-margin` and `body-font-size` are no longer exported. Read `default-config.page.margin` and `default-config.fonts.size` instead.

Because unknown keys now raise an error, a document still written against the 1.x API fails immediately with a message naming the offending option, rather than compiling with the setting silently ignored.

## Advanced Configuration

### Cover Page Customization

The `cover` section of the configuration controls the cover page background, decorative circles, and text styling for every element. You only need to specify the keys you want to override, all others fall back to defaults.

#### Cover Dictionary Structure

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `bg` | color/none | `none` | Page background color (`none` = transparent) |
| `decorations` | bool | `true` | Show decorative circles on the cover page |
| `second-logo` | dictionary | `(image: none, scale: 1.0, dx: 0pt, dy: 0pt)` | Secondary logo placed inside the top-left circle. Pass `image` to enable it; `scale` is relative to the circle diameter, `dx` / `dy` fine-tune the centering. |
| `padding` | length | `1em` | Space between the horizontal lines and the content |
| `spacing` | length | `1em` | Space between elements (title, subtitle, date) |
| `title` | dictionary | see below | Title text configuration |
| `subtitle` | dictionary | see below | Subtitle text configuration |
| `subsubtitle` | dictionary | see below | Subsubtitle text configuration (omitted when `text` / top-level param is empty) |
| `date` | dictionary | see below | Date text configuration |
| `author` | dictionary | see below | Author/affiliation text configuration |

#### Element Dictionaries

All five element dictionaries (`title`, `subtitle`, `subsubtitle`, `date`, `author`) share these keys:

| Key | Type | title | subtitle | subsubtitle | date | author |
|-----|------|-------|----------|-------------|------|--------|
| `text` | string | — | — | — | n/a | n/a |
| `color` | color/auto | `auto` (`colors.primary`) | `auto` (title color) | `auto` (subtitle color) | `auto` (title color) | `auto` (title color) |
| `weight` | int/string/auto | `700` | `700` | `400` | `auto` (`fonts.body` weight) | `"bold"` |
| `size` | length | `2.5em` | `2em` | `1.4em` | `1.1em` | `14pt` |
| `font` | string/auto | `auto` (`fonts.title`) | `auto` (`fonts.title`) | `auto` (`fonts.body`) | `auto` (`fonts.body`) | `auto` (`fonts.body`) |
| `align` | alignment | `center` | `center` | `center` | `center` | `center` |

The `text` key is available on `title`, `subtitle`, and `subsubtitle`. When set it overrides the corresponding `info` field, letting you keep all cover-page concerns in one place.

The `date` dictionary also accepts:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `range` | bool | `true` | Show date range (`start-date - last-updated-date`). When `false`, only `start-date` is shown. |

All `auto` color values cascade from the title color. Setting `cover: (title: (color: white))` makes every element white unless individually overridden. The horizontal lines also follow the title color.

#### Examples

Override only the background:

```typst
#show: clean-cnam-template.with(config: (
  // ... other sections
  cover: (bg: rgb("#1a1a2e")),
))
```

Dark background with white text and no decorative circles:

```typst
#show: clean-cnam-template.with(config: (
  // ... other sections
  cover: (
    bg: rgb("#1a1a2e"),
    decorations: false,
    title: (color: white, size: 3em),
    subtitle: (color: rgb("#cccccc")),
  ),
))
```

Custom fonts and sizes while keeping default colors:

```typst
#show: clean-cnam-template.with(config: (
  // ... other sections
  cover: (
    title: (font: "Inter Display", weight: 800, size: 3em),
    subtitle: (font: "Inter", weight: 400, size: 1.5em),
  ),
))
```

Title and subtitle content alongside their styling (everything in one place):

```typst
#show: clean-cnam-template.with(config: (
  // info.title / info.subtitle can be omitted when using cover.title.text / cover.subtitle.text
  cover: (
    title: (text: "My Report", font: "Inter Display", weight: 800, size: 3em),
    subtitle: (text: "First year of apprenticeship", font: "Inter"),
  ),
))
```

Partial overrides work at every level. For example, `cover: (title: (size: 3em))` only changes the title size -- color, weight, and font keep their defaults.

The title color cascades: setting `cover: (title: (color: white))` also applies white to the subtitle and the horizontal lines, unless the subtitle explicitly overrides its own color.

### Rendering Hooks

The template's own layout functions are the default value of a configuration key, not a hard-coded call. Pass your own function to `render.<name>` and it is used instead, receiving the resolved configuration: every color, font and piece of metadata the template itself works from.

```typst
#let ma-cover(cfg) = {
  set align(center + horizon)
  text(size: 3em, fill: cfg.colors.primary, weight: 700, cfg.cover.title.text)
  linebreak()
  text(size: 1.2em, fill: cfg.colors.neutral-dark, cfg.info.affiliation)
}

#show: clean-cnam-template.with(config: (
  info: (title: "Rapport", affiliation: "CNAM"),
  render: (cover: ma-cover),
))
```

#### What each hook owns

The split is deliberate: bookkeeping stays with the template, appearance goes to the hook. A replacement chapter page never has to remember to break the page or to fix the heading counter, and a replacement cover never has to remember the outline.

| Hook | You provide | The template still handles |
|------|-------------|----------------------------|
| `cover` | The cover page content | The page break after it, the background reset, the outline |
| `decorations` | The placed shapes | The `cover.decorations` toggle |
| `header` | The running header | Nothing else |
| `footer` | The whole footer | Nothing: providing a footer replaces the page numbering, so render it yourself if you want it |
| `chapter` | The chapter page appearance | The page break, and the counter give-back for masked chapters |

`chapter` receives `label`, which is `false` for a chapter masked by `#no-numbering()`. It is not called at all when `headings.chapter-style` is `"plain"`, or for a heading preceded by `#no-big-title()`: both of those mean "this is not a chapter page".

#### Wrapping a built-in

The default implementations are exported, so a hook can extend one rather than replace it:

```typst
#let cover-avec-mention(cfg) = {
  default-cover(cfg)
  place(bottom + left, dy: -1cm, text(size: 7pt)[Document confidentiel])
}
```

#### Hooks in a theme

A theme is a configuration dictionary, and `render` is a configuration key, so a theme can carry a layout and not just a palette:

```typst
#let theme-bandeau = (
  colors: (primary: rgb("#00539F")),
  cover: (decorations: false),
  render: (
    cover: cover-avec-mention,
    chapter: (cfg, it, label: true) => block(
      fill: cfg.colors.primary,
      inset: 0.8em,
      width: 100%,
      text(fill: white, size: 1.3em, weight: 700, it.body),
    ),
  ),
)

#show: clean-cnam-template.with(theme: theme-bandeau, config: (info: (title: "Rapport")))
```

### Font Configuration

The template includes centralized font management that allows you to set consistent fonts across your document. Fonts are specified as objects with `name` and `weight` properties:

```typst
#show: clean-cnam-template.with(config: (
  fonts: (
    default: (name: "Inter", weight: 400),              // Base fallback for every other entry
    title: (name: "Inter Display", weight: 600),        // Titles and headings
    chapter: (size: 2em),                               // Level-1 headings, inherits title's name and weight
    code: (name: "JetBrains Mono", weight: 400),        // Code blocks
    size: 11pt,                                         // Base body size
  ),
  // ... other sections
))
```

Font Object Structure:
- `name`: The font family name (string)
- `weight`: The font weight (integer: 100-900, or string: "regular", "bold", etc.)
- `size`: for `chapter` only, the level-1 heading size

Each member is filled independently, so a partial override keeps the rest: `title: (name: "Inter Display")` keeps the weight inherited from `default`.

The template uses a hierarchical font system:
- `default` serves as the base font object for the document
- `body` is used for body text and cascades from `default`
- `title` is used for titles and headings and cascades from `default`
- `chapter` is used for level-1 chapter headings and cascades from `title`, with its own `size` (default `1.5em`)
- `code` is used for all code blocks and monospace text
- `inline-raw` is used for inline code (`\`backtick\`` spans) and cascades from `body`

This allows you to use different fonts and weights for body text and headings while maintaining a fallback to `default`.

### Print Mode

Set `print: true` to produce output suitable for printing. This:
- Strips the primary-color fill and underline from all links (by returning the link body directly, which also suppresses glossary entry markers such as the superscript `g` from `@preview/glossarium`).
- Strips all `underline()` wrappers document-wide, covering glossary packages that wrap the link in an underline rather than embedding it inside the link body.

```typst
#show: clean-cnam-template.with(config: (
  // ... other sections
  print: true,
))
```

### Color Highlighting

You can automatically highlight specific words throughout your document with the primary color:

```typst
#show: clean-cnam-template.with(config: (
  // ... other sections
  color-words: ("important", "CNAM", "theorem"),
  colors: (primary: "#C4122E"),
))
```

Any occurrence of the specified words will be rendered in `colors.primary`.

### Header Configuration

The running header shows the current level-2 heading, tracked by [hydra](https://typst.app/universe/package/hydra). To replace it entirely, pass your own function through `config.render.header` (see [Rendering Hooks](#rendering-hooks)).

### Date Range Display

The template automatically formats date ranges. If `start-date` and `last-updated-date` are the same, only one date is shown. Otherwise, both dates are displayed as a range:

```typst
#show: clean-cnam-template.with(config: (
  info: (
    start-date: datetime(day: 1, month: 9, year: 2024),
    last-updated-date: datetime(day: 15, month: 12, year: 2024),
  ),
  // Displays: 01/09/2024 - 15/12/2024
))
```

## Heading Variants

Three functions modify the rendering of the immediately following heading.

### `#no-numbering()`

Behavior depends on the heading level:

- **`=` headings**: renders with the full decorative chapter style (pagebreak, thin lines, centered) but without the "Chapitre/Chapter N" label and without incrementing the chapter counter. Numbered chapters that follow get the correct number.
- **`==` and deeper**: suppresses the numbering prefix (e.g. `I -`, `I.I -`) while keeping the normal heading style.

```typst
#no-numbering()
= Remerciements      // decorative style, no "Chapitre N", not counted

#no-numbering()
= Introduction       // same

= Analyse            // "Chapitre 1"
= Conclusion         // "Chapitre 2"

#no-numbering()
== Remarque          // sub-heading without "I -" prefix
```

### `#no-big-title()`

Renders the immediately following `=` heading as a plain level-1 heading, skipping the decorative chapter formatting entirely.

```typst
#no-big-title()
= Annexes            // plain heading, no pagebreak, no decorative lines
```

## Cross-References

References to headings via `@label` are rendered as `Section <roman-numeral>` with a clean roman numeral that mirrors the heading numbering scheme (`I`, `I.I`, `I.I.1`). The trailing `" -"` that appears in the heading numbers themselves is stripped from references, so `@analyse` renders as `Section I` rather than `Section I -`. Non-heading references keep their default rendering.

```typst
= Analyse <analyse>
== Méthode <methode>

See @analyse and @methode.   // "See Section I and Section I.I."
```

## Custom Outline

The template allows you to customize or disable the table of contents (outline) on the title page:

### Default Outline
```typst
#show: clean-cnam-template.with(config: (
  // ... other sections
  // outline: (enabled: true),  // This is the default - standard outline
))
```

### Custom Outline
You can provide your own outline configuration:
```typst
#show: clean-cnam-template.with(config: (
  // ... other sections
  outline: (custom: outline(
    title: "Table des matières",
    depth: 2,
    indent: auto,
  )),
))
```

### Disable Outline
To disable the outline completely:
```typst
#show: clean-cnam-template.with(config: (
  // ... other sections
  outline: (enabled: false),
))
```

## Code Blocks

The template provides enhanced code blocks with multiple features including syntax highlighting, line numbers, and filename labels.

The look is adapted from [typst-endfield-doc-theme](https://github.com/Ives-Natsume/typst-endfield-doc-theme) by metasequoiaNI, MIT licensed: the language, and the filename beside it, in a small tab notched onto the top-left corner, a thick accent rule down the left edge instead of a full border, running straight from the top of the tab to the bottom of the block, a tint of the accent behind the code, and generous padding. What this template adds on top is the line numbering, the line labels and ranges, the breakable-block measurement, and the per-language color table.

Note: Examples below use text fences and Typst `raw(...)` to avoid nested backticks so automated package checks pass. In your own documents, you can use normal Markdown code fences and standard Typst code blocks.

### Basic Usage
```text
#code(
  lang: "Python",
  raw(block: true, lang: "python", "def hello_world():\n    print(\"Hello, World!\")")
)
```

### With Filename
```text
#code(
  filename: "main.py",
  lang: "Python",
  raw(block: true, lang: "python", "def hello_world():\n    print(\"Hello, World!\")")
)
```

### Advanced Options

The `code()` function supports many customization options:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `lang` | string/none | `none` | Label shown in the tab, uppercased. When `none`, the tab is hidden but syntax highlighting, and the accent color, still use the raw block's own `lang` attribute. |
| `filename` | string/none | `none` | Optional filename, shown beside the language inside the tab |
| `numbering` | bool | `true` | Whether to show line numbers |
| `line-spacing` | length | `5pt` | Vertical spacing between lines |
| `accent` | color/auto | `auto` | Color of the left rule and the language tab. `auto` resolves through `code.lang-colors` (see below) |
| `fill` | color/auto | `auto` | Background behind the code. `auto` = `code.background`, itself defaulting to the accent lightened to 94% |
| `stroke` | stroke | `auto` | Border: a rule down the left edge, in the accent, `0.35` times the code text size |
| `radius` | length | `2pt` | Radius of the two right-hand corners. The left edge stays square, so the accent rule reads as a straight bar. A dictionary is passed through as given |
| `inset` | dict/length | `(x: 1.2em, y: 1em)` | Padding around the code |
| `width` | length/% | `100%` | Block width |
| `lines` | range/auto | `auto` | Line range to display |
| `number-align` | alignment | `right` | Line number alignment |
| `text-style` | dict | `(size: 8pt)` | Text styling options |
| `lang-box` | dict | `(:)` | Tab styling: `fill`, `inset`, `radius`, `text-style`. `radius` rounds the top-right corner only; `fill` defaults to `colors.primary` |
| `title` | dict | `(:)` | Filename styling: `size`, `font`, `fill`, `weight`. `fill` defaults to the tab ink, faded 20% |

The tab carries the same color as the rule down the left edge, and the filename sits in it beside the language. The labels pick black or white automatically, whichever reads against that accent, with the filename lightly faded so the language stays dominant.

### Colors per Language

Every block takes its accent from the language it shows. The lookup table lives in `config.code.lang-colors`, keyed by lowercased language name, with values from [GitHub Linguist](https://github.com/github-linguist/linguist) so a Python block reads blue and a Rust block reads rust-orange, the way they do elsewhere. `config.code.lang-aliases` maps the short spellings (`py`, `rs`, `sh`, `c++`, `yml`) onto those keys.

Both tables are open-ended: unlike every other section, unknown keys are accepted rather than rejected, because adding a language is extending a lookup, not misspelling an option.

```typst
#show: clean-cnam-template.with(config: (code: (
  lang-colors: (
    python: rgb("#FFD43B"),      // override a shipped language
    brainfuck: rgb("#2F2530"),   // or add one the template never heard of
  ),
  lang-aliases: (bf: "brainfuck"),
)))
```

A language with no entry falls back to `colors.primary`.

Three levels of override, most specific first:

| Where | Effect |
|-------|--------|
| `#code(accent: ..., fill: ...)` | This block only |
| `config.code.accent` | Pins every block to one color and ignores the language table. This is the switch for a document that must stay on brand |
| `config.code.background` | Pins every code background, independently of the accent |

Since these are ordinary configuration keys, a theme can carry a code palette. `themes.monochrome` does exactly that.

Example with custom styling:
```text
#code(
  numbering: false,
  fill: rgb("#f8f8f8"),
  stroke: 2pt + rgb("#e0e0e0"),
  radius: 5pt,
  lang: "Rust",
  raw(block: true, lang: "rust", "fn main() {\n    println!(\\\"Hello, world!\\\");\n}")
)
```


## Components

### UI Components

#### `blockquote()`
Styled quote blocks with customizable colors and borders.

**Parameters:**
- `color`: Accent color (`auto` = `colors.neutral` from the config)
- `fill`: Background color (`auto` = `colors.neutral-light` from the config)
- `inset`: Padding (default: custom spacing)
- `border-side`: Which side carries the accent: `left`, `right`, `top`, `bottom` (alignment or string) or `"all"` (default: `left`). An unknown value is an error
- `radius`: Border radius (`auto` = derived from `border-side`: the corners away from the accent are rounded)
- `stroke`: Stroke configuration (`auto` = derived from `border-side`); passing one overrides `border-side` entirely
- `attribution`, `attribution-align`, `attribution-style`, `attribution-inset`: optional source line under the quote

**Example:**
```typst
#blockquote[
  This is an important quote that needs highlighting.
]

#blockquote(border-side: right, attribution: "Confucius")[
  I hear and I forget. I see and I remember. I do and I understand.
]
```

#### `my-block()`
Custom content blocks with configurable styling.

**Parameters:**
- `fill`: Background color (default: `luma(230)`)
- `inset`: Padding (default: `15pt`)
- `radius`: Border radius (default: `4pt`)
- `outline`: Border stroke (default: `none`)
- `alignment`: Block alignment (default: `center`)

**Example:**
```typst
#my-block(fill: rgb("#e3f2fd"))[
  Important note or callout content.
]
```

#### `code()`
Enhanced code blocks with line numbers, syntax highlighting, and filename labels. See the [Code Blocks](#code-blocks) section for detailed documentation.

### Math Components

#### `definition()`
Mathematical definition blocks with red styling.

**Example:**
```typst
#definition(title: "Derivative")[
  The derivative of a function $f$ at point $a$ is defined as...
]
```

#### `example()`
Example blocks with blue styling.

**Example:**
```typst
#example(title: "Computing a limit")[
  Calculate: $lim_(x -> 0) sin(x)/x = 1$
]
```

#### `theorem()`
Theorem blocks with purple styling.

**Example:**
```typst
#theorem(title: "Pythagorean Theorem")[
  For a right triangle: $a^2 + b^2 = c^2$
]
```

### Utilities

#### `ar(name)`
Creates vector arrow notation in math mode.

**Example:**
```typst
$ar(v) = (x, y, z)$
```

#### `icon(codepoint)`
Displays an icon with proper sizing and spacing for inline use.

**Example:**
```typst
#icon("path/to/icon.svg") Inline text with icon
```

#### `date-format(date)`
Formats a datetime object to French format (DD/MM/YYYY).

**Example:**
```typst
#date-format(datetime(day: 4, month: 9, year: 2024))
// Outputs: 04/09/2024
```

## Development

The repository ships a few `just` recipes for working on the template itself. They are not part of the published package.

| Command | Effect |
|---------|--------|
| `just themes` | List the shipped themes and presets with their descriptions. The listing is read from `src/lib/themes.typ`, so it cannot drift. |
| `just preview sobre` | Render `docs/preview.typ` with that theme or preset and open the PDF. `none` renders the bare defaults. |
| `just preview-all` | Render every theme and preset into `docs/preview/`, without opening anything. |
| `just new-theme NAME` | Append a skeleton theme to `src/lib/themes.typ`, along with its catalogue description. |
| `just new-preset NAME` | Same, for a document preset. |

`docs/preview.typ` exercises every component (headings, blocks, quotes, math environments, code, lists, figures), so anything a theme touches shows up somewhere in the output. It picks its layer from `--input theme=<name>`.

Adding a theme by hand means adding it to two places in `src/lib/themes.typ`: the `themes` (or `presets`) dictionary, and `theme-catalogue`. An assertion at the bottom of the file checks the two agree, so a missing description fails the build rather than producing a half-empty listing. `just new-theme` writes both.

## Recent Updates

### v1.6.7 - Print Mode + Inline Raw Font + Unified Cover API + Subsubtitle + Author Email + Alignment Control (Latest)
- **Clean heading cross-references**: `@label` references to headings now render as `Section <roman-numeral>` without the trailing `" -"` baked into the heading numbering.
- **`align` control**: New `align` parameter for `title`, `subtitle`, `subsubtitle`, `date`, and `author` in the `cover` dictionary. Allows independent alignment control for cover elements (defaults to `center`).
- **`print: true`**: Strips link color, underline, and glossary entry markers (e.g. superscript `g` from `@preview/glossarium`) for clean print output.
- **`fonts.inline-raw`**: New font key for inline code. Defaults to `auto` (cascades from `body`), so inline code now uses the body font by default instead of the code font.
- **Author `email` / `mail`**: Author dicts now accept an `email` or `mail` key; the name is rendered as an underlined `mailto:` link when no ORCID is set.
- **`subsubtitle`**: New optional third cover line rendered below the subtitle in a smaller, lighter style. Controlled via `subsubtitle: "..."` or `cover.subsubtitle: (text: "...", size: ..., ...)`.
- **`cover.title.text` and `cover.subtitle.text`**: Title and subtitle content can now live inside the `cover` dict alongside their styling options, eliminating the need to split content (top-level) from presentation (`cover`). The top-level `title` and `subtitle` parameters remain supported as a shorter alias when no cover-specific styling is needed.

### v1.6.7 - Extended `#no-numbering()` + Convergence Fix (Latest, continued)
- **`#no-numbering()` extended**: For `=` headings, now renders with the decorative chapter style but without the "Chapitre N" label and without incrementing the chapter counter. Numbered chapters after it resume from the correct number. Sub-heading behavior is unchanged.
- **Convergence fix**: `#no-big-title()` and `#no-numbering()` now use metadata markers instead of boolean states, eliminating the "layout did not converge" warning.

### v1.6.6 - Heading and Code Improvements
- **`#no-numbering()`**: Suppresses the numbering prefix on the immediately following heading
- **`#code()` `numbering: auto`**: Hides line numbers for single-line blocks
- **`#code()` title API**: Four separate title params merged into a single `title` dict

### v1.6.2 - Math and Block Styling
- **`my-block` body styling**: New `body-style` parameter for body text customization
- **Math component text styling**: New `title-style` and `body-style` parameters for `definition`, `example`, and `theorem`
- **Math components refactored**: Converted from `.with()` wrappers to proper functions with explicit parameters

### v1.5.0 - Font Customization
- **BREAKING: Font parameters use objects**: All font parameters now accept `(name: "..", weight: 400)` instead of plain strings
- **New `body-font` and `title-font` parameters**: Independent font selection for body text and headings

## Previous Updates

### Font Configuration System
- Added centralized font management with `default-font` and `code-font` parameters
- Created separate `fonts.typ` module to avoid circular dependencies
- All components now use consistent font configuration

### Enhanced Code Blocks
- Added optional `filename` parameter for code blocks
- Language labels now appear above code blocks instead of inline
- Improved visual connection between filename/language labels and code content
- Fixed font inheritance issues with proper context handling

### Improved Modularity
- Restructured imports to eliminate circular dependencies
- Added `lib.typ` as main package entrypoint
- Better separation of concerns across modules

## Author

- **Tom Planche**

## Acknowledgements

- [hzkonor/bubble-template](https://github.com/hzkonor/bubble-template), the original basis for this template.
- [Ives-Natsume/typst-endfield-doc-theme](https://github.com/Ives-Natsume/typst-endfield-doc-theme) by metasequoiaNI (MIT), the source of the code block styling.
- [github-linguist/linguist](https://github.com/github-linguist/linguist) (MIT), the source of the per-language colors in `code.lang-colors`.

## License

MIT
