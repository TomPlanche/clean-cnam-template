/**
 * Global configuration store for the template
 *
 * The whole template is driven by a single nested dictionary, resolved once by
 * `clean-cnam-template` and published to a document-wide state. Every module -- layout,
 * components, math environments -- reads that state instead of receiving a long list of
 * positional arguments, which is what lets a component follow the theme.
 *
 * Reading the config requires a `context` block:
 *
 * ```typst
 * #context {
 *   let cfg = get-config()
 *   text(fill: cfg.colors.primary)[themed]
 * }
 * ```
 */

#import "utils.typ": merge-dicts
#import "colors.typ": *

/**
 * Default configuration tree.
 *
 * Doubles as the schema: `merge-dicts` rejects any user key that does not appear here,
 * so a typo is reported instead of silently ignored.
 *
 * `auto` marks a value derived from another one during resolution (see `resolve-config`).
 */
#let default-config = (
  // Document metadata and cover content
  info: (
    title: "",
    subtitle: "",
    subsubtitle: "",
    // string, dict (name, orcid, email/mail) or an array mixing both
    author: "",
    affiliation: "",
    class: none,
    year: auto,              // auto -> current year
    start-date: auto,        // auto -> today, none -> no date on the cover
    last-updated-date: auto, // auto -> today
    logo: none,
  ),

  // Semantic palette. Components derive their shades from these values.
  colors: (
    primary: cnam-red,       // accepts a color or a hex string
    secondary: auto,         // auto -> primary lightened by 30%
    outline: auto,           // auto -> default text color
    page-number: auto,       // auto -> default text color
    neutral-lightest: neutral-lightest,
    neutral-light: neutral-light,
    neutral-border: neutral-border,
    neutral: neutral,
    neutral-dark: neutral-dark,
    neutral-darkest: neutral-darkest,
    definition: definition-color,
    example: example-color,
    theorem: theorem-color,
  ),

  // Font objects: (name, weight). `auto` members cascade from another entry.
  fonts: (
    default: (name: "New Computer Modern Math", weight: 400),
    body: (name: auto, weight: auto),                  // cascades from default
    title: (name: auto, weight: auto),                 // cascades from default
    chapter: (name: auto, weight: auto, size: 1.5em),  // cascades from title
    code: (name: "Zed Plex Mono", weight: 400),
    inline-raw: (name: auto, weight: auto),            // cascades from body
    size: 12pt,                                        // base body size
  ),

  page: (
    margin: (top: 2.5cm, right: 1.27cm, bottom: 1.75cm, left: 1.27cm),
    numbering: "1 / 1",
    number-align: bottom + right,
  ),

  cover: (
    bg: white,               // page background, none = transparent
    decorations: true,       // decorative circles
    second-logo: (           // logo inside the top-left circle
      image: none,           // pass image("..") from your own file
      scale: 1.0,            // relative to the circle diameter
      dx: 0pt,
      dy: 0pt,
    ),
    padding: 1em,
    spacing: 1em,
    // `text: auto` falls back to the matching `info` field
    title: (text: auto, color: auto, weight: 700, size: 2.5em, font: auto, align: center),
    subtitle: (text: auto, color: auto, weight: 700, size: 2em, font: auto, align: center),
    subsubtitle: (text: auto, color: auto, weight: 400, size: 1.4em, font: auto, align: center),
    date: (color: auto, weight: auto, size: 1.1em, font: auto, range: true, align: center),
    author: (color: auto, weight: "bold", size: 14pt, font: auto, align: center),
  ),

  // Code block colors. `accent` paints the rule down the left edge and the language tab;
  // `background` sits behind the code itself.
  code: (
    // auto -> the language's own color from `lang-colors`, falling back to colors.primary
    // when the language is unknown or absent. Set a color here to pin every block to it
    // and ignore the table.
    accent: auto,
    background: auto,  // auto -> the accent lightened to 94%
    // Language lookup, keyed by lowercased language name. Open-ended: unknown keys are
    // accepted, so adding a language is a one-line override and never a schema error.
    // Values follow GitHub Linguist, so a block reads the way the language does elsewhere.
    lang-colors: (
      bash: rgb("#4EAA25"),
      c: rgb("#555555"),
      clojure: rgb("#DB5855"),
      cpp: rgb("#F34B7D"),
      csharp: rgb("#178600"),
      css: rgb("#563D7C"),
      dart: rgb("#00B4AB"),
      diff: rgb("#88807B"),
      dockerfile: rgb("#384D54"),
      elixir: rgb("#6E4A7E"),
      erlang: rgb("#B83998"),
      fish: rgb("#4EAA25"),
      fortran: rgb("#4D41B1"),
      go: rgb("#00ADD8"),
      haskell: rgb("#5E5086"),
      html: rgb("#E34C26"),
      java: rgb("#B07219"),
      javascript: rgb("#F1E05A"),
      json: rgb("#292929"),
      julia: rgb("#A270BA"),
      kotlin: rgb("#A97BFF"),
      latex: rgb("#3D6117"),
      lua: rgb("#000080"),
      makefile: rgb("#427819"),
      markdown: rgb("#083FA1"),
      matlab: rgb("#E16737"),
      nix: rgb("#7E7EFF"),
      ocaml: rgb("#EF7A08"),
      perl: rgb("#0298C3"),
      php: rgb("#4F5D95"),
      python: rgb("#3572A5"),
      r: rgb("#198CE7"),
      ruby: rgb("#701516"),
      rust: rgb("#DEA584"),
      scala: rgb("#C22D40"),
      scss: rgb("#C6538C"),
      sql: rgb("#E38C00"),
      swift: rgb("#F05138"),
      toml: rgb("#9C4221"),
      typescript: rgb("#3178C6"),
      typst: rgb("#239DAD"),
      vim: rgb("#199F4B"),
      xml: rgb("#0060AC"),
      yaml: rgb("#CB171E"),
      zig: rgb("#EC915C"),
    ),
    // Spellings that should resolve to an entry above. Also open-ended.
    lang-aliases: (
      "c++": "cpp",
      "c#": "csharp",
      js: "javascript",
      jsx: "javascript",
      md: "markdown",
      objective-c: "c",
      "pl": "perl",
      py: "python",
      rs: "rust",
      sh: "bash",
      shell: "bash",
      tex: "latex",
      ts: "typescript",
      tsx: "typescript",
      yml: "yaml",
      zsh: "bash",
    ),
  ),

  // Rendering hooks. `auto` keeps the built-in implementation; pass a function to replace
  // it. Each one receives the resolved configuration, so a replacement has access to
  // every colour, font and piece of metadata the template itself uses. The built-ins are
  // exported as `default-cover`, `default-decorations`, `default-header` and
  // `default-chapter`, so a hook can wrap one instead of starting from scratch.
  render: (
    cover: auto,        // (cfg) => content, the cover page only (no page break, no outline)
    decorations: auto,  // (cfg) => content, the placed shapes behind the cover
    header: auto,       // (cfg) => content, the running page header
    footer: auto,       // (cfg) => content, replaces the page-numbering footer entirely
    chapter: auto,      // (cfg, it, label: bool) => content, the decorated chapter page
  ),

  // Level-1 heading rendering
  headings: (
    // "decorated": the centered chapter page (rules, "Chapitre N", own font size)
    // "plain": a normal in-flow level-1 heading, as `#no-big-title()` produces
    chapter-style: "decorated",
    chapter-pagebreak: true,  // decorated only: start each chapter on a new page
    chapter-label: true,      // decorated only: the "Chapitre N" line above the title
  ),

  outline: (
    enabled: true,
    custom: none,            // content rendered instead of the default outline
    indent: auto,
    depth: none,             // none = every level
  ),

  lang: "fr",
  print: false,              // strips link color and underline for print output
  color-words: (),           // words automatically highlighted in the primary color
)

// Document-wide configuration state.
#let _config = state("cnam-config", default-config)

/**
 * Read the resolved configuration. Must be called from within a `context` block.
 *
 * @returns The full configuration dictionary
 */
#let get-config() = _config.get()

/**
 * Read the resolved font configuration. Must be called from within a `context` block.
 *
 * @returns The `fonts` section of the configuration
 */
#let get-fonts() = _config.get().fonts

/**
 * Publish a resolved configuration to the document state.
 *
 * @param config - A fully resolved configuration dictionary
 */
#let set-config(config) = _config.update(config)

// Accept a hex string wherever a color is expected.
#let _as-color(value) = if type(value) == str { rgb(value) } else { value }

// Fill the `auto` members of a font entry from `fallback`.
// A whole entry replaced by `auto` is treated as "inherit everything".
#let _resolve-font(entry, fallback) = {
  let overrides = if type(entry) == dictionary { entry } else { (:) }
  let out = fallback

  for (key, value) in overrides {
    if value != auto { out.insert(key, value) }
  }

  out
}

// Normalize the `theme` argument to an array of configuration dictionaries.
#let _theme-list(theme) = {
  if theme == none {
    ()
  } else if type(theme) == dictionary {
    (theme,)
  } else {
    theme
  }
}

/**
 * Merge a user configuration over the defaults and resolve every `auto` cascade.
 *
 * Layers are applied in increasing order of priority: defaults, then each theme in the
 * order given, then the user configuration. A theme is a plain (partial) configuration
 * dictionary, validated against the schema exactly like user input, so composing
 * `theme: (presets.memoire, themes.sobre)` lets the second refine the first.
 *
 * Resolution order matters: fonts and colors settle first, then the cover derives its own
 * values from them. After this call no `auto` remains except where `auto` is a meaningful
 * runtime value (`colors.outline`, `colors.page-number`, `outline.indent`).
 *
 * @param config - The user configuration (partial)
 * @param theme - A configuration dictionary, or an array of them, applied under `config`
 * @returns A fully resolved configuration dictionary
 */
// Lookup tables the user extends rather than overrides, so their keys skip validation.
#let _open-paths = ("code.lang-colors", "code.lang-aliases")

#let resolve-config(config, theme: none) = {
  let cfg = default-config

  for layer in _theme-list(theme) {
    cfg = merge-dicts(cfg, layer, path: "theme", open: _open-paths)
  }

  cfg = merge-dicts(cfg, config, open: _open-paths)

  // Dates and academic year
  if cfg.info.start-date == auto { cfg.info.start-date = datetime.today() }
  if cfg.info.last-updated-date == auto { cfg.info.last-updated-date = datetime.today() }
  if cfg.info.year == auto { cfg.info.year = datetime.today().year() }

  // Fonts: body and title cascade from default, inline-raw from body, chapter from title
  cfg.fonts.body = _resolve-font(cfg.fonts.body, cfg.fonts.default)
  cfg.fonts.title = _resolve-font(cfg.fonts.title, cfg.fonts.default)
  cfg.fonts.code = _resolve-font(cfg.fonts.code, cfg.fonts.default)
  cfg.fonts.inline-raw = _resolve-font(cfg.fonts.inline-raw, cfg.fonts.body)
  cfg.fonts.chapter = _resolve-font(
    cfg.fonts.chapter,
    (..cfg.fonts.title, size: default-config.fonts.chapter.size),
  )

  // Colors
  cfg.colors.primary = _as-color(cfg.colors.primary)
  cfg.colors.secondary = if cfg.colors.secondary == auto {
    cfg.colors.primary.lighten(30%)
  } else {
    _as-color(cfg.colors.secondary)
  }
  if cfg.colors.outline != auto { cfg.colors.outline = _as-color(cfg.colors.outline) }
  if cfg.colors.page-number != auto { cfg.colors.page-number = _as-color(cfg.colors.page-number) }

  // Code block colors. `accent` and `background` stay `auto` when unset: both depend on
  // the language of a given block, so they can only settle at render time.
  if cfg.code.accent != auto { cfg.code.accent = _as-color(cfg.code.accent) }
  if cfg.code.background != auto { cfg.code.background = _as-color(cfg.code.background) }
  cfg.code.lang-colors = cfg.code.lang-colors.pairs().map(((k, v)) => (k, _as-color(v))).to-dict()

  // Cover text falls back to the matching `info` field
  if cfg.cover.title.text == auto { cfg.cover.title.text = cfg.info.title }
  if cfg.cover.subtitle.text == auto { cfg.cover.subtitle.text = cfg.info.subtitle }
  if cfg.cover.subsubtitle.text == auto { cfg.cover.subsubtitle.text = cfg.info.subsubtitle }

  // Cover styling: title settles first, everything else cascades from it
  if cfg.cover.title.color == auto { cfg.cover.title.color = cfg.colors.primary }
  if cfg.cover.title.font == auto { cfg.cover.title.font = cfg.fonts.title.name }

  if cfg.cover.subtitle.color == auto { cfg.cover.subtitle.color = cfg.cover.title.color }
  if cfg.cover.subtitle.font == auto { cfg.cover.subtitle.font = cfg.fonts.title.name }

  if cfg.cover.subsubtitle.color == auto { cfg.cover.subsubtitle.color = cfg.cover.subtitle.color }
  if cfg.cover.subsubtitle.font == auto { cfg.cover.subsubtitle.font = cfg.fonts.body.name }

  if cfg.cover.date.color == auto { cfg.cover.date.color = cfg.cover.title.color }
  if cfg.cover.date.weight == auto { cfg.cover.date.weight = cfg.fonts.body.weight }
  if cfg.cover.date.font == auto { cfg.cover.date.font = cfg.fonts.body.name }

  if cfg.cover.author.color == auto { cfg.cover.author.color = cfg.cover.title.color }
  if cfg.cover.author.font == auto { cfg.cover.author.font = cfg.fonts.body.name }

  cfg
}
