# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.7.0] - 2026-05-13

### Added

- **Clean heading cross-references**: References to headings via `@label` now render as `Section <roman-numeral>` (e.g. `Section VIII`) instead of dragging the trailing `" -"` from the template's heading numbering into the reference (which previously produced `Section VIII -`). The roman numeral mirrors the heading numbering scheme at each level (`I`, `I.I`, `I.I.1`). Non-heading references are unaffected.

  ```typst
  = Analyse <analyse>
  == Méthode <methode>

  Voir @analyse et @methode.   // "Voir Section I et Section I.I."
  ```

- **`#no-numbering()` extended**: For `=` headings, now renders with the full decorative chapter style but without the "Chapitre/Chapter N" label and without incrementing the chapter counter. Subsequent numbered chapters continue from where they left off. For `==` and deeper headings the existing behavior is unchanged (suppresses the numbering prefix).

  ```typst
  #no-numbering()
  = Remerciements        // no label, not counted

  #no-numbering()
  = Introduction         // no label, not counted

  = Chapitre I           // "Chapitre 1"
  = Chapitre II          // "Chapitre 2"
  ```

- **Convergence fix for heading variants**: `#no-big-title()` and `#no-numbering()` now use invisible metadata markers queried by position instead of boolean states that were read and written inside the same `context` block. This eliminates the "layout did not converge within 5 attempts" warning that appeared when any of these functions was used.

- **`align` parameter for cover elements**: New `align` key added to `title`, `subtitle`, `subsubtitle`, `date`, and `author` dictionaries within the `cover` configuration. Allows overriding the default center alignment for each element independently.

- **`print` mode**: New boolean parameter (`print: false` by default). When `true`, produces clean output suitable for printing:
  - Strips color and underline from all links (returns `it.body` directly, preventing inner show-rules from running, which also suppresses glossary entry markers such as the superscript `g` from `@preview/glossarium`).
  - Strips all `underline()` wrappers via a `show underline` rule, covering cases where a glossary package wraps the link in an underline rather than placing it inside the link body.

  ```typst
  #show: clean-cnam-template.with(
    print: true,
    // ... other parameters
  )
  ```

- **`fonts.inline-raw`**: New font key for inline code elements (`raw.where(block: false)`). Accepts a font object `(name: "..", weight: 400)` and defaults to `auto`, which cascades from `fonts.body`. Inline code is now rendered in the body font by default instead of the code font, keeping it visually consistent with surrounding text while still applying the highlight box.

  ```typst
  fonts: (inline-raw: (name: "JetBrains Mono", weight: 400))
  ```

- **Author `email` / `mail` field**: Author dicts now accept an `email` (or `mail`) key. The rendering depends on what is provided:
  - email only — name is rendered as an underlined `mailto:` link
  - orcid only — existing behavior: name and ORCID icon combined into one link to orcid.org
  - both — name links to `mailto:`, ORCID icon links separately to orcid.org

  ```typst
  author: (name: "Tom Planche", email: "tom@example.com")
  // both: name → mailto, icon → orcid.org
  author: (name: "Tom Planche", email: "tom@example.com", orcid: "0009-0005-6032-3201")
  ```

- **`subsubtitle`**: New optional third line of cover text rendered below the subtitle in a smaller, lighter style. Accepts either a top-level `subsubtitle` string or `cover.subsubtitle.text` (cover value takes priority). Like `title` and `subtitle`, its appearance is fully controlled via the `cover.subsubtitle` dict (`color`, `weight`, `size`, `font`). Color cascades from the subtitle color; font defaults to the body font.

  ```typst
  subsubtitle: "Promotion 2024-2026",
  // or, co-located with styling:
  cover: (
    subsubtitle: (text: "Promotion 2024-2026", size: 1.2em, weight: 300),
  )
  ```

### Changed

- **`#code()` `lang` parameter**: Passing `lang: none` (the default) now hides the language label in the top bar while still using the raw block's own `lang` attribute for syntax highlighting. Previously, omitting `lang` caused the language to be inferred from the raw block and displayed in the label. Syntax highlighting is unaffected in all cases.

- **`#code()` corner radius**: When no top bar is shown (neither `lang` nor `filename` provided), the code block now uses fully rounded corners on all sides instead of only the bottom corners.

- **`#code()` kept whole across pages**: New `breakable` parameter (`auto` by default). With `auto`, a code block that fits within a single page is no longer split across a page boundary; it is pushed to the next page and rendered whole (like an implicit `pagebreak()`). Blocks taller than a page still break normally to avoid overflowing. Pass `breakable: true` to restore the previous always-splittable behavior, or `breakable: false` to force keeping it whole.

  ```typst
  #code(lang: "Rust", source)               // auto: kept whole when it fits
  #code(breakable: true, lang: "Rust", source)  // may split across pages
  ```

- **Unified title and subtitle API**: The `cover.title` and `cover.subtitle` dicts now accept an optional `text` key that, when present, overrides the top-level `title` and `subtitle` parameters. This lets you co-locate cover content and its styling in one place:

  ```typst
  cover: (
    title: (text: "My Report", font: "Inter Display", size: 3em),
    subtitle: (text: "First year", font: "Inter"),
  )
  ```

  The top-level `title` and `subtitle` parameters remain fully supported as a shorter fallback when no cover-specific styling is needed. `cover.title.text` / `cover.subtitle.text` take priority when both are provided.

### Fixed

- **`#no-numbering()` on a sub-section no longer de-numbers later chapters**: Detection of a "no-numbering" `=` heading is now LOCAL. Previously, a single `#no-numbering()` placed anywhere (typically on a `==`/`===` sub-section) caused every following chapter to lose its "Chapitre/Chapter N" label and shifted the chapter count. A level-1 heading is now treated as no-numbering only when a marker immediately precedes it (no other heading in between), using the same locality rule already applied to deeper headings.

- **`#no-numbering()` no longer advances the visible number of sibling headings**: A masked heading now gives its number back via `counter(heading).update(...)` instead of only hiding the display. Numbered headings of the same level under the same parent stay consecutive (`I.I`, `I.II`, ...) regardless of how many `#no-numbering()` siblings are interleaved, and numbered chapters keep counting without gaps. This unifies the counter logic across level 1 and deeper levels around a single source of truth (Typst's own heading counter), replacing the previous separate skipped-chapter counter and display-time subtraction. The change preserves the convergence-safe pattern (no read-then-write inside `context`).

## [1.6.6] - 2026-05-13

### Added

- **`#no-numbering()`**: Suppresses the numbering prefix on the immediately following heading (any level). The heading retains its normal styling and font size; only the counter is omitted. Mirrors the existing `#no-big-title()` API.
- **`#code()` `numbering: auto`**: The `numbering` parameter now accepts `auto` in addition to `true`/`false`. `auto` hides line numbers when the block contains a single line.

### Changed

- **`#code()` title API**: The four separate title params (`title`, `title-align`, `title-style`, `title-inset`) have been merged into a single dict `title: (:)` with keys `font`, `size`, `fill`, and `weight`. Makes the API consistent with `text-style` and `number-style`.
- **Heading layout**: Sub-headings (level 2+) are now rendered in an explicit `block` with per-level font sizes (`1.2em` down to `0.9em`) instead of relying on Typst's built-in hanging indent, which produced inconsistent indentation at deeper levels. Numbering format strings also had cosmetic leading spaces removed.

## [1.6.5] - 2026-04-20

### Added

- **`#no-big-title()`**: Cancels the decorative chapter formatting for the immediately following `=` heading, rendering it as a plain level-1 heading instead.
- **Nullable `date`**: The `date` parameter on the cover now accepts `none` to omit the date entirely.
- **`last-updated-date`**: New cover parameter to display a "last updated" date alongside the start date when the document spans multiple dates.

## [1.6.4] - 2026-03-04
## [1.6.3] - 2026-03-04

### Added

- **ORCID support on the cover page**: The `author` parameter now accepts dicts with an `orcid` field
  - Accepts a string, a dict, or a mixed array of both
  - Dict format: `(name: "Author Name", orcid: (id: "0000-0000-0000-0000", name: "optional display name"))`
  - When `orcid.id` is present a clickable ORCID link is rendered next to the author name
  - `orcid.name` defaults to `author.name` when omitted
  - Requires `@preview/orchid:0.1.0`
- **Second logo on the cover**: `cover.decorations` now accepts a `second-logo` key for placing a secondary logo inside the top-left circle decoration
  - `image`: logo content — pass `image("...")` from your document file so relative paths resolve correctly
  - `scale`: scale factor relative to the circle diameter (default `1.0`)
  - `dx` / `dy`: lengths for fine-tuning the logo position (default `0pt`)

## [1.6.2] - 2026-02-08

### Added

- **`my-block` body styling**: New `body-style` parameter for body text customization
  - Accepts a dict with `size`, `weight`, `fill`, `font` keys
  - `auto` values mean "inherit from context" (no override applied)
- **Font option in `title-style`**: Added `font` key to `title-style` dicts in `my-block` and `code` components
- **Math component text styling**: New `title-style` and `body-style` parameters for `definition`, `example`, and `theorem`
  - Each accepts `(size, weight, fill, font)` with `auto` defaults
  - Title styling applied via custom `titlix` formatter
  - Body styling applied via custom `bodyfmt` formatter

### Changed

- **Math components refactored**: `definition`, `example`, and `theorem` converted from `.with()` wrappers to proper functions
  - Now accept explicit parameters: `title`, `fill`, `stroke`, `radius`, `inset`, `breakable`, `title-style`, `body-style`
  - Internal helpers `_apply-style`, `_styled-titlix`, `_styled-bodyfmt` added to `math.typ`

## [1.5.0] - 2025-12-23

### Changed

- **BREAKING: Font parameters now use objects**: All font parameters (`default-font`, `body-font`, `title-font`, `code-font`) now accept objects with `name` and `weight` properties instead of strings
  - Font object structure: `(name: "Font Name", weight: 400)`
  - `weight` can be an integer (100-900) or string ("regular", "bold", etc.)
  - Updated `fonts.typ` module to store and manage font objects
  - Updated all font usage throughout the template to support font weights
  - **Migration**: Change `default-font: "Font Name"` to `default-font: (name: "Font Name", weight: 400)`

### Added

- **Font customization**: New optional `body-font` and `title-font` parameters in `clean-cnam-template()`
  - Both default to `default-font` when not specified
  - Allows independent font selection for body text and titles/headings
  - Each can specify different font families and weights

## [1.4.0] - 2025-12-15

### Added

#### Multi-language Support
- **Language parameter**: New `language` parameter in `clean-cnam-template()` to set document language
  - Defaults to "fr" (French)
  - Supports "en" (English)
  - Automatically configures text language throughout the document
- **Linguify integration**: Integrated `@preview/linguify:0.4.2` for internationalization
  - Translation database for multi-language support
  - Automatic translation of chapter headings based on language setting
  - Re-exported linguify in main library for user access
- **Translation system**: Added centralized translations database in `lib/layout.typ`

### Changed

- **thinLine utility enhancement**: Now accepts a color parameter for dynamic line styling
  - Updated from fixed stroke to configurable color
  - Applied to chapter heading decorative lines
  - Improved visual consistency with theme colors

### Fixed

- **Subtitle display**: Fixed subtitle rendering to only display when subtitle is provided and not empty
  - Prevents extra vertical spacing when no subtitle is set
  - Improves title page layout for documents without subtitles

## [1.3.0] - 2025-11-24

### Added

#### New Header System
- **Hydra-based page headers**: Integrated `@preview/hydra:0.6.2` for intelligent section-aware headers
  - Displays current section number and title in the header
  - Decorative line below header with primary color
  - Automatically hides on chapter start pages

#### Enhanced Chapter Styling
- **New level 1 heading design**: Completely redesigned chapter headings
  - Centered layout with "Chapter N" prefix
  - Decorative thin lines above and below the title
  - Automatic page break before each chapter
  - Larger title text (1.5em)

#### Utility Additions
- **`thinLine` utility**: New decorative line element for consistent styling across the document

### Changed
- **Heading numbering system**: Refactored to only display relevant numbers per heading level
  - Level 2 headings now show only their section number (e.g., "I -" instead of "III I -")
  - Level 3 and 4 headings properly display parent-child relationships
  - Cleaner, more readable heading hierarchy

### Fixed
- **Heading number display**: Fixed issue where parent chapter numbers appeared in sub-heading numbering

## [1.2.0] - 2025-10-20

### Added

#### Enhanced Component Customization
- **Blockquote enhancements** with extensive customization options:
  - `border-side` parameter: choose left, right, top, bottom, or all borders
  - `attribution` parameter: add source/author attribution to quotes
  - `attribution-align` parameter: align attribution (left, center, right)
  - `attribution-style` parameter: customize attribution text styling (size, weight, fill, style)
  - `attribution-inset` parameter: control attribution spacing
  - `block-align` parameter: align the entire block (left, center, right)
  - `content-align` parameter: align content inside the block (left, center, right)
  - `width` parameter: control block width (auto, 100%, or custom length)
  - Dynamic radius adjustment based on border side
  - Support for full border styling with all sides

- **my-block component enhancements** with title and alignment support:
  - `title` parameter: optional title at the top of the block
  - `title-align` parameter: align title (left, center, right)
  - `title-style` parameter: customize title styling (size, weight, fill)
  - `title-inset` parameter: control spacing around the title
  - `block-align` parameter: align the entire block (left, center, right)
  - `content-align` parameter: align content inside the block (left, center, right)
  - `width` parameter: control block width (auto, 100%, or custom length)

- **Code component enhancements** with advanced display options:
  - `title` parameter: optional title/caption above the code block
  - `title-align` parameter: align title (left, center, right)
  - `title-style` parameter: customize title styling (size, weight, fill)
  - `title-inset` parameter: control spacing around the title
  - `block-align` parameter: align the entire block (left, center, right)
  - `number-style` parameter: customize line number styling (size, fill, weight)
  - Enhanced text styling with `fill` color support
  - Improved language label positioning with better width handling

- **Math components enhancements**:
  - Full customization support for `definition`, `example`, and `theorem`
  - All parameters now configurable: fill, stroke, radius, inset, numbering, breakable
  - Comprehensive JSDoc documentation with usage examples
  - Consistent theming with extensible color options

#### Documentation Improvements
- **Comprehensive showcase document** in `main.typ` demonstrating:
  - All component customization options
  - Multiple styling examples for each component
  - Real-world usage patterns
  - Color customization examples
  - Layout and alignment options
- **Enhanced JSDoc documentation** with detailed usage examples for all components
- **Parameter descriptions** with default values and type information

### Changed
- **Improved component API consistency** across all components
- **Better default styling** with refined color choices
- **Enhanced type safety** in parameter handling
- **Refined layout calculations** for better responsive behavior
- **Package version** updated to 1.2.0 in `typst.toml`

### Fixed
- **Code block width handling** for proper alignment with title and language label
- **Border radius calculations** now adapt to border-side selection
- **Attribution spacing** in blockquotes for better visual hierarchy
- **Title spacing** in all components for consistent appearance

## [1.1.0] - 2025-10-19

### Added
- **Custom outline support** with `outline-code` parameter in `clean-cnam-template()`
  - Pass `none` (default) for standard outline
  - Pass `false` to disable outline completely
  - Pass custom outline code (e.g., `outline(title: "Table des matières", depth: 2)`) for customization
- **Documentation examples** for outline customization in README.md
- **Usage comments** in main.typ demonstrating all outline options

### Changed
- **Enhanced flexibility** of title page generation to support custom outline configurations

## [1.0.0] - 2024-09-15

### Added

#### Core Template System
- **Modular template architecture** with organized library structure in `lib/` directory
- **CNAM branding integration** with official colors and styling
- **Main configuration function** `clean-cnam-template()` for easy document setup
- **Centralized package entrypoint** in `lib.typ` for clean imports

#### Document Configuration
- **Flexible document configuration** with support for:
  - Title, subtitle, author, and affiliation
  - Custom logo support (CNAM logo included)
  - Configurable primary colors and theming
  - Class/course information and date management
  - Multi-language support (French default)

#### Font Management
- **Centralized font configuration system** with `fonts.typ` module
- **Configurable font families** for body text and code blocks
- **Default font support** for "New Computer Modern Math" and "Zed Plex Mono"
- **Consistent font application** across all components

#### Enhanced Code Blocks
- **Advanced code component** with comprehensive features:
  - Syntax highlighting for multiple programming languages
  - Optional line numbering with customizable alignment
  - Filename display support
  - Language label badges
  - Customizable styling (colors, spacing, borders)
  - Line range selection for partial code display
  - Label support for line referencing

#### UI Components
- **Styled blockquote component** with customizable colors and borders
- **Flexible content blocks** (`my-block`) with configurable styling
- **Professional layout system** with decorative elements
- **Context-aware page headers** with smart header management

#### Mathematical Environments
- **Mathematical definition blocks** with red styling and numbering
- **Example blocks** with blue styling and consistent formatting
- **Theorem blocks** with purple styling and proper numbering
- **Integration with great-theorems package** for enhanced mathematical typesetting
- **Dependent numbering system** for mathematical environments

#### Utility Functions
- **Vector arrows utility** (`ar()`) for mathematical expressions
- **Icon sizing utility** (`icon()`) for proper icon display
- **French date formatting** (`date-format()`) for localized dates

#### Color System
- **Predefined color palette** with CNAM branding colors
- **Semantic color naming** with descriptive names:
  - `theorem-color` for theorem blocks
  - `example-color` for example blocks
  - `definition-color` for definition blocks
- **Color word highlighting** for automatic text coloring

#### Layout and Styling
- **Professional document layout** with responsive design
- **Decorative page elements** for enhanced visual appeal
- **Title page generation** with CNAM branding
- **Consistent spacing and typography** throughout the document

#### Project Structure
- **Organized module system** with logical separation:
  - `config.typ` - Main configuration and document setup
  - `fonts.typ` - Font management and configuration
  - `components.typ` - UI components (blockquote, blocks, code)
  - `headers.typ` - Header management logic
  - `layout.typ` - Document layout and styling
  - `utils.typ` - Utility functions
  - `colors.typ` - Color definitions
  - `math.typ` - Mathematical environments
- **Template directory** with example usage
- **Asset management** for logos and static resources

#### Development Features
- **MIT License** for open-source usage
- **Comprehensive documentation** with usage examples
- **Package configuration** with proper metadata and exclusions
- **Git integration** with appropriate ignore patterns

### Technical Details

#### Dependencies
- **Typst 1.0.0+** minimum version requirement
- **great-theorems 0.1.2** for mathematical environments
- **headcount 0.1.0** for numbering systems

#### Code Quality
- **Consistent naming conventions** using kebab-case for functions
- **Comprehensive documentation** with JSDoc-style comments
- **Modular design** eliminating circular dependencies
- **Clean import structure** with optimized exports

#### Package Information
- **Package name**: clean-cnam-template
- **Version**: 1.0.0
- **Author**: Tom Planche
- **Repository**: https://github.com/TomPlanche/clean-cnam-template
- **Keywords**: template, cnam, academic, document, styling
- **Categories**: template, academic

[1.0.0]: https://github.com/TomPlanche/clean-cnam-template/releases/tag/v1.0.0
