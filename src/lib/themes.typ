/**
 * Shipped themes and document presets
 *
 * A theme is nothing more than a partial configuration dictionary. It is merged between
 * the defaults and the user configuration, and validated against the same schema, so a
 * theme can touch any option and the user can always override any of its choices.
 *
 * ```typst
 * #show: clean-cnam-template.with(
 *   theme: (presets.memoire, themes.sobre),
 *   config: (info: (title: "Rapport")),
 * )
 * ```
 *
 * Themes carry a look, presets carry a document shape. They compose: the later layer wins,
 * and the user configuration wins over both.
 *
 * @author Tom Planche
 * @license MIT
 */

#import "colors.typ": cnam-red

/**
 * Visual themes.
 *
 * - `cnam`: the template defaults, spelled out. Changes nothing, but gives a readable
 *   starting point to copy from.
 * - `sobre`: no decorative circles, neutral cover text. The primary color stays on
 *   headings, links and accents only. Suited to a dissertation handed to a jury.
 * - `dark`: dark cover with white text, decorations kept.
 * - `monochrome`: greyscale everywhere, for black and white printing. Pair it with
 *   `config: (print: true)` to also drop link coloring. It pins `code.accent`, because the
 *   per-language code palette would otherwise print as a muddle of unrelated greys.
 *   Syntax highlighting inside code blocks stays colored: it comes from Typst's built-in
 *   `raw` theme, not from this palette. Pass your own greyscale theme with
 *   `set raw(theme: "..tmTheme")` if you need the code to be monochrome too.
 */
#let themes = (
  cnam: (
    colors: (primary: cnam-red),
    cover: (decorations: true),
  ),

  sobre: (
    cover: (
      decorations: false,
      title: (color: luma(20)),
      subtitle: (color: luma(60)),
      subsubtitle: (color: luma(90)),
      date: (color: luma(60)),
      author: (color: luma(20)),
    ),
  ),

  dark: (
    cover: (
      bg: rgb("#1a1a2e"),
      title: (color: white),
      subtitle: (color: rgb("#cccccc")),
      subsubtitle: (color: rgb("#aaaaaa")),
      date: (color: rgb("#cccccc")),
      author: (color: white),
    ),
  ),

  monochrome: (
    colors: (
      primary: luma(40),
      secondary: luma(140),
      definition: luma(60),
      example: luma(60),
      theorem: luma(60),
    ),
    // Pinned, otherwise every block would still pull its own color from `lang-colors`
    code: (accent: luma(40)),
  ),
)

/**
 * Document presets.
 *
 * - `article`: short pieces. Level-1 headings stay in the flow instead of opening a
 *   decorated chapter page, decorations are dropped and the margins tighten.
 * - `memoire`: a wider left margin to survive binding, a two-level outline and a date
 *   range on the cover.
 * - `tp`: compact lab reports. Smaller margins and body size, no outline.
 */
#let presets = (
  article: (
    headings: (chapter-style: "plain"),
    cover: (decorations: false),
    page: (margin: (top: 2cm, right: 2cm, bottom: 2cm, left: 2cm)),
  ),

  memoire: (
    page: (margin: (left: 2.5cm, right: 1.5cm)),
    outline: (depth: 2),
    cover: (date: (range: true)),
  ),

  tp: (
    fonts: (size: 11pt),
    page: (margin: (top: 2cm, right: 1.5cm, bottom: 1.5cm, left: 1.5cm)),
    outline: (enabled: false),
  ),
)

/**
 * One-line descriptions, keyed exactly like `themes` and `presets`.
 *
 * Consumed by `just themes` so the terminal listing is read from the source rather than
 * duplicated in a script. The assertions below run at import time: adding a theme without
 * describing it fails the build instead of silently producing an incomplete listing.
 */
#let theme-catalogue = (
  themes: (
    cnam: "The template defaults, spelled out",
    sobre: "No decorative circles, neutral cover text",
    dark: "Dark cover with white text, decorations kept",
    monochrome: "Greyscale palette for black and white printing",
  ),
  presets: (
    article: "Short pieces: in-flow level-1 headings, no decorations, tighter margins",
    memoire: "Wider binding margin, two-level outline, date range on the cover",
    tp: "Compact lab reports: 11pt body, tight margins, no outline",
  ),
)

#assert(
  theme-catalogue.themes.keys().sorted() == themes.keys().sorted(),
  message: "theme-catalogue.themes and themes must describe the same set of themes",
)
#assert(
  theme-catalogue.presets.keys().sorted() == presets.keys().sorted(),
  message: "theme-catalogue.presets and presets must describe the same set of presets",
)
