# CNAM TYPST Template

A modular and organized TYPST template for creating professional documents using CNAM branding and styling.

Originally based on [hzkonor's bubble-template](https://github.com/hzkonor/bubble-template) and uses [CNAM](https://www.cnam.fr/)'s logo and colors.

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
│   │   ├── config.typ     # Template entrypoint (clean-cnam-template)
│   │   ├── components.typ # UI components (blockquote, my-block, code)
│   │   ├── headers.typ    # Header management logic
│   │   ├── layout.typ     # Document layout and styling
│   │   ├── utils.typ      # Utility functions
│   │   ├── colors.typ     # Color definitions
│   │   └── math.typ       # Mathematical environments
│   └── lib.typ            # Main package entrypoint (local import)
├── template/
│   └── assets/            # Static assets (logos, images)
│       └── cnam_logo.svg  # CNAM logo
├── main.typ               # Example document using the published package
└── README.md
```

## Features

- **Modular Design**: Template split into logical, maintainable modules
- **Single Configuration Object**: One nested `config` dictionary drives the whole document, and every component reads it
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
   #import "@preview/clean-cnam-template:1.7.0": *
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
| `neutral-lightest` | color | `luma(250)` | Code block background |
| `neutral-light` | color | `luma(230)` | `my-block` and `blockquote` background |
| `neutral-border` | color | `luma(180)` | Code block border |
| `neutral` | color | `luma(170)` | Blockquote accent, code line numbers |
| `neutral-dark` | color | `luma(100)` | Blockquote attribution |
| `neutral-darkest` | color | `luma(80)` | Code block label bar |
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

#### `outline` -- table of contents

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `enabled` | bool | `true` | Render the table of contents after the cover |
| `custom` | content / none | `none` | Content rendered instead of the default outline |
| `indent` | function / auto | `auto` | Passed to Typst's `outline(indent: ..)` |

#### Top-level keys

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `lang` | string | `"fr"` | Document language (`"fr"`, `"en"`) |
| `print` | bool | `false` | Strip link color, underline, and glossary markers for print output |
| `color-words` | array | `()` | Words automatically highlighted with the primary color |
| `show-secondary-header` | bool | `true` | Show secondary headers |
| `cover` | dictionary | see below | Cover page configuration (see [Cover Page](#cover-page-customization)) |

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
| `color-words:`, `print:`, `show-secondary-header:` | `config.*` (unchanged names) |

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

Control the display of secondary headers (sub-headings in page headers):

```typst
#show: clean-cnam-template.with(config: (
  // ... other sections
  show-secondary-header: false,  // Only show main section in headers
))
```

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
| `lang` | string/none | `none` | Label to display in the top bar. When `none`, the bar is hidden but syntax highlighting still uses the raw block's own `lang` attribute. When the bar is hidden (no `lang` and no `filename`), the block gets fully rounded corners on all sides. |
| `filename` | string/none | `none` | Optional filename to display |
| `numbering` | bool | `true` | Whether to show line numbers |
| `line-spacing` | length | `5pt` | Vertical spacing between lines |
| `fill` | color | `luma(250)` | Background color |
| `stroke` | stroke | `1pt + luma(180)` | Border style |
| `radius` | length | `3pt` | Border radius |
| `width` | length/% | `100%` | Block width |
| `lines` | range/auto | `auto` | Line range to display |
| `number-align` | alignment | `right` | Line number alignment |
| `text-style` | dict | `(size: 8pt)` | Text styling options |

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
- `color`: Stroke color (default: `luma(170)`)
- `fill`: Background color (default: `luma(230)`)
- `inset`: Padding (default: custom spacing)
- `radius`: Border radius (default: rounded right side)
- `stroke`: Stroke configuration (default: left border only)

**Example:**
```typst
#blockquote[
  This is an important quote that needs highlighting.
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

## License

MIT
