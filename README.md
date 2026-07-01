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
│   │   ├── config.typ     # Main configuration and document setup
│   │   ├── fonts.typ      # Centralized font configuration
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
- **CNAM Branding**: Official CNAM colors and styling
- **Centralized Font Configuration**: Global font settings for consistency
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
   #import "@preview/clean-cnam-template:1.6.7": *
   ```

   - Using this repository locally (from `src/`):
   ```text
   #import "src/lib.typ": *
   ```

2. Configure your document with basic parameters:
```typst
#show: clean-cnam-template.with(
  title: "Your Title",
  author: "Your Name",
  class: "Course Name",
  subtitle: "Subtitle",
  // If using the package, point to your own copy of the logo
  // If using this repo locally, you can use the provided logo path
  logo: image("template/assets/cnam_logo.svg"),
  start-date: datetime(day: 4, month: 9, year: 2024),
  main-color: "#C4122E",  // Custom color (default is "E94845")
  default-font: (name: "New Computer Modern Math", weight: 400),
  code-font: (name: "Zed Plex Mono", weight: 400),
)
```

3. Write your content using the available components and styling.

### Complete Parameter Reference

The `clean-cnam-template` function accepts the following parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | string | `""` | Document title. Can also be set via `cover.title.text` (cover value takes priority). |
| `subtitle` | string | `""` | Document subtitle. Can also be set via `cover.subtitle.text` (cover value takes priority). |
| `subsubtitle` | string | `""` | Optional third cover line rendered below the subtitle in a smaller style. Can also be set via `cover.subsubtitle.text`. Omitted when empty. |
| `author` | string / dict / array | `""` | Author name(s). Accepts a plain string, a dict `(name: "..", orcid: "..", email: "..")`, or a mixed array. Rendering: email only → underlined `mailto:` link; orcid only → name + icon linked to orcid.org; both → name links to `mailto:`, ORCID icon links separately to orcid.org. |
| `affiliation` | string | `""` | Author's affiliation/institution |
| `year` | int | current year | Year for school year calculation |
| `class` | string/none | `none` | Class/course name |
| `start-date` | datetime | today | Document start date |
| `last-updated-date` | datetime | today | Last updated date |
| `logo` | image/none | `none` | Logo image to display |
| `main-color` | string | `"E94845"` | Primary color (hex string) |
| `color-words` | array | `()` | Words to highlight with primary color |
| `default-font` | object | `(name: "New Computer Modern Math", weight: 400)` | Default font object (fallback for body and title fonts) |
| `body-font` | object/none | `none` | Body text font object (defaults to `default-font`) |
| `title-font` | object/none | `none` | Title and heading font object (defaults to `default-font`) |
| `code-font` | object | `(name: "Zed Plex Mono", weight: 400)` | Code block font object |
| `show-secondary-header` | bool | `true` | Show secondary headers |
| `outline-code` | content/bool/none | `none` | Custom outline configuration |
| `print` | bool | `false` | Strip link color, underline, and glossary markers for print output |
| `cover` | dictionary | `(:)` | Cover page configuration (see [Cover Page](#cover-page-customization)) |

## Advanced Configuration

### Cover Page Customization

The `cover` parameter lets you control the cover page background, decorative circles, and text styling for every element. You only need to specify the keys you want to override -- all others fall back to defaults.

#### Cover Dictionary Structure

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `bg` | color/none | `none` | Page background color (`none` = transparent) |
| `decorations` | bool | `true` | Show decorative circles on the cover page |
| `decorations.second-logo` | dict / none | `none` | Secondary logo placed inside the top-left circle. Keys: `image` (content), `scale` (float, default `1.0`), `dx` / `dy` (length, default `0pt`) |
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
| `color` | color/auto | `auto` (`main-color`) | `auto` (title color) | `auto` (subtitle color) | `auto` (title color) | `auto` (title color) |
| `weight` | int/string/auto | `700` | `700` | `400` | `auto` (`body-font` weight) | `"bold"` |
| `size` | length | `2.5em` | `2em` | `1.4em` | `1.1em` | `14pt` |
| `font` | string/auto | `auto` (`title-font`) | `auto` (`title-font`) | `auto` (`body-font`) | `auto` (`body-font`) | `auto` (`body-font`) |
| `align` | alignment | `center` | `center` | `center` | `center` | `center` |

The `text` key is available on `title`, `subtitle`, and `subsubtitle`. When present it overrides the corresponding top-level parameter, letting you keep all cover-page concerns in one place.

The `date` dictionary also accepts:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `range` | bool | `true` | Show date range (`start-date - last-updated-date`). When `false`, only `start-date` is shown. |

All `auto` color values cascade from the title color. Setting `cover: (title: (color: white))` makes every element white unless individually overridden. The horizontal lines also follow the title color.

#### Examples

Override only the background:

```typst
#show: clean-cnam-template.with(
  // ... other parameters
  cover: (bg: rgb("#1a1a2e")),
)
```

Dark background with white text and no decorative circles:

```typst
#show: clean-cnam-template.with(
  // ... other parameters
  cover: (
    bg: rgb("#1a1a2e"),
    decorations: false,
    title: (color: white, size: 3em),
    subtitle: (color: rgb("#cccccc")),
  ),
)
```

Custom fonts and sizes while keeping default colors:

```typst
#show: clean-cnam-template.with(
  // ... other parameters
  cover: (
    title: (font: "Inter Display", weight: 800, size: 3em),
    subtitle: (font: "Inter", weight: 400, size: 1.5em),
  ),
)
```

Title and subtitle content alongside their styling (everything in one place):

```typst
#show: clean-cnam-template.with(
  // top-level title/subtitle can be omitted when using cover.title.text / cover.subtitle.text
  cover: (
    title: (text: "My Report", font: "Inter Display", weight: 800, size: 3em),
    subtitle: (text: "First year of apprenticeship", font: "Inter"),
  ),
)
```

Partial overrides work at every level. For example, `cover: (title: (size: 3em))` only changes the title size -- color, weight, and font keep their defaults.

The title color cascades: setting `cover: (title: (color: white))` also applies white to the subtitle and the horizontal lines, unless the subtitle explicitly overrides its own color.

### Font Configuration

The template includes centralized font management that allows you to set consistent fonts across your document. Fonts are specified as objects with `name` and `weight` properties:

```typst
#show: clean-cnam-template.with(
  fonts: (
    default: (name: "Inter", weight: 400),              // Base fallback for body and title
    body: (name: "Inter", weight: 400),                 // Body text (auto = default)
    title: (name: "Inter Display", weight: 600),        // Titles and headings (auto = default)
    code: (name: "JetBrains Mono", weight: 400),        // Code blocks
    inline-raw: (name: "JetBrains Mono", weight: 400),  // Inline code (auto = body)
  ),
  // ... other parameters
)
```

Font Object Structure:
- `name`: The font family name (string)
- `weight`: The font weight (integer: 100-900, or string: "regular", "bold", etc.)

The template uses a hierarchical font system:
- `default-font` serves as the base font object for the document
- `body-font` is used for body text and defaults to `default-font` if not specified
- `title-font` is used for titles and headings and defaults to `default-font` if not specified
- `code-font` is used for all code blocks and monospace text
- `inline-raw` is used for inline code (`\`backtick\`` spans) and defaults to `body-font`

This allows you to use different fonts and weights for body text and headings while maintaining a fallback to `default-font`.

### Print Mode

Set `print: true` to produce output suitable for printing. This:
- Strips the primary-color fill and underline from all links (by returning the link body directly, which also suppresses glossary entry markers such as the superscript `g` from `@preview/glossarium`).
- Strips all `underline()` wrappers document-wide, covering glossary packages that wrap the link in an underline rather than embedding it inside the link body.

```typst
#show: clean-cnam-template.with(
  // ... other parameters
  print: true,
)
```

### Color Highlighting

You can automatically highlight specific words throughout your document with the primary color:

```typst
#show: clean-cnam-template.with(
  // ... other parameters
  color-words: ("important", "CNAM", "theorem"),
  main-color: "#C4122E",
)
```

Any occurrence of the specified words will be rendered in the `main-color`.

### Header Configuration

Control the display of secondary headers (sub-headings in page headers):

```typst
#show: clean-cnam-template.with(
  // ... other parameters
  show-secondary-header: false,  // Only show main section in headers
)
```

### Date Range Display

The template automatically formats date ranges. If `start-date` and `last-updated-date` are the same, only one date is shown. Otherwise, both dates are displayed as a range:

```typst
#show: clean-cnam-template.with(
  start-date: datetime(day: 1, month: 9, year: 2024),
  last-updated-date: datetime(day: 15, month: 12, year: 2024),
  // Displays: 01/09/2024 - 15/12/2024
)
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
#show: clean-cnam-template.with(
  // ... other parameters
  // outline-code: none,  // This is the default - standard outline
)
```

### Custom Outline
You can provide your own outline configuration:
```typst
#show: clean-cnam-template.with(
  // ... other parameters
  outline-code: outline(
    title: "Table des matières",
    depth: 2,
    indent: auto,
  ),
)
```

### Disable Outline
To disable the outline completely:
```typst
#show: clean-cnam-template.with(
  // ... other parameters
  outline-code: false,
)
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
