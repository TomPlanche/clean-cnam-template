/**
 * Main layout and styling configuration for the template
 *
 * Every entry point takes the resolved configuration dictionary (see `store.typ`) as its
 * single argument, so adding an option never means threading one more positional
 * parameter through the call chain.
 *
 * @author Tom Planche
 * @license MIT
 */

#import "@preview/i-figured:0.2.4"
#import "@preview/great-theorems:0.1.2": *
#import "@preview/hydra:0.6.2": hydra
#import "@preview/linguify:0.5.0": linguify
#import "utils.typ": date-format, format-authors, thin-line

// Translations database for linguify
#let translations-database = (
  conf: (
    default-lang: "fr",
  ),
  lang: (
    fr: (
      chapter: "Chapitre",
      figures: "Table des figures",
      tables: "Liste des tableaux",
    ),
    en: (
      chapter: "Chapter",
      figures: "List of figures",
      tables: "List of tables",
    ),
  ),
)

// Metadata markers for heading variants.
// These avoid the read-then-write-in-context pattern that causes convergence warnings.

/**
 * Cancel the decorative chapter formatting for the immediately following `=` heading.
 * The heading will render as a plain level-1 heading instead.
 */
#let no-big-title() = [#metadata("cnam-no-big-title")<_cnam-no-big-title>]

/**
 * For `=` headings: render with full decorative styling but without the "Chapitre/Chapter N"
 * label and without incrementing the chapter counter.
 * For `==` and deeper headings: suppress the numbering prefix (e.g. "I -").
 * In both cases the heading retains its normal font size and appears in the outline.
 */
#let no-numbering() = [#metadata("cnam-no-numbering")<_cnam-no-numbering>]

// Returns true when a marker with label `lbl` immediately precedes the heading at `loc`,
// i.e. the last such marker is placed after the last heading of ANY level. This is a
// LOCAL test: a marker only affects the heading it directly precedes, never a later one
// that happens to have an intervening heading. Pure query (no state writes) -> no
// convergence risk. Must be called from within a `context` block.
#let _immediately-preceded-by(lbl, loc) = {
  let markers = query(selector(lbl).before(loc))
  if markers.len() == 0 { return false }
  let prev-heads = query(selector(heading).before(loc, inclusive: false))
  if prev-heads.len() == 0 { return true }
  let mp = markers.last().location().position()
  let hp = prev-heads.last().location().position()
  (mp.page > hp.page) or (mp.page == hp.page and mp.y > hp.y)
}

// Decrement function for `counter(heading).update`: a masked (no-numbering) heading gives
// back the number it consumed so its numbered siblings stay consecutive (I, II, ...) and
// numbered chapters keep counting without gaps. Operates on the heading's own (deepest)
// level component, so deeper-level resets are handled by Typst's hierarchical counter.
#let _give-back-number(..nums) = {
  let m = nums.pos()
  m.at(m.len() - 1) = calc.max(m.last() - 1, 0)
  m
}

// Resolve a rendering hook: `auto` selects the built-in implementation.
#let _hook(cfg, name, fallback) = {
  let hook = cfg.render.at(name)
  if hook == auto { fallback } else { hook }
}

// --- Page numbering ------------------------------------------------------------------
//
// Two independent knobs, `page.numbering-from` (which page starts printing a number) and
// `page.numbering-start` (which number it prints), both `auto` by default. They are
// implemented in page-counter space: a shift emitted once moves the counter, and the
// numbering pattern refuses to print anything below the first expected number. Working on
// the counter rather than on physical pages is what keeps the printed numbers, the outline
// entries and the "n / total" denominator telling the same story.

// The first number the numbering ever prints, or `none` when numbering starts with the
// body: which page that is cannot be known before layout, but the pages before it print
// nothing anyway (see `_front-numbering`), so there is no threshold to apply.
#let _first-printed-number(cfg) = {
  if cfg.page.numbering-from == auto {
    none
  } else if cfg.page.numbering-start == auto {
    cfg.page.numbering-from
  } else {
    cfg.page.numbering-start
  }
}

// A numbering that prints nothing, used for the pages that carry no number. Not the same
// as `numbering: none`: on a page without a numbering, Typst falls back to the raw page
// count in outline entries, so the outline would list numbers the pages never print.
#let _no-numbering = (..nums) => none

// Value for `set page(numbering: ..)` on the pages that are numbered: the configured
// pattern, in `colors.page-number` when it is set, and blank below the first expected
// number (the pages before `page.numbering-from`, whose outline entries then show no page
// number either). The bare pattern is handed back untouched when neither applies.
#let _page-numbering(cfg) = {
  let pattern = cfg.page.numbering
  let min = _first-printed-number(cfg)

  if pattern == none { return _no-numbering }
  if min == none and cfg.colors.page-number == auto { return pattern }

  (..nums) => {
    // `nums` is (page, total) in a footer, (page,) in an outline entry.
    if min != none and nums.pos().first() < min { return }

    let printed = numbering(pattern, ..nums)
    if cfg.colors.page-number == auto { printed } else { text(fill: cfg.colors.page-number, printed) }
  }
}

// Value for `set page(numbering: ..)` on the cover and the front matter: numbered only
// when the document asked for the numbering to start there.
#let _front-numbering(cfg) = {
  if cfg.page.numbering-from == auto { _no-numbering } else { _page-numbering(cfg) }
}

// Page-counter shift for the very first page, so that page `page.numbering-from` prints
// `page.numbering-start`. Nothing to do when the numbering starts with the body (see
// `_body-counter-shift`) or when the count simply follows the pages.
#let _front-counter-shift(cfg) = {
  if cfg.page.numbering-from == auto or cfg.page.numbering-start == auto { return }
  counter(page).update(cfg.page.numbering-start - cfg.page.numbering-from + 1)
}

// Page-counter shift for the first page of the body, where numbering starts by default.
#let _body-counter-shift(cfg) = {
  if cfg.page.numbering-from != auto or cfg.page.numbering-start == auto { return }
  counter(page).update(cfg.page.numbering-start)
}

/**
 * Built-in running header: the current level-2 section, right-aligned above a rule.
 *
 * Replaceable through `render.header`.
 *
 * @param cfg - The resolved configuration dictionary
 * @returns The header content
 */
#let default-header(cfg) = context [
  #hydra(2, display: (_, it) => {
    set align(right)

    numbering(it.numbering, ..counter(heading).at(it.location()))

    h(0.3cm) + it.body

    v(-0.3cm)

    line(length: 100%, stroke: 0.5pt + cfg.colors.primary)
  })
]

/**
 * Built-in decorated chapter page: the title centered between two rules, optionally
 * preceded by the "Chapitre N" label.
 *
 * The page break and the heading counter bookkeeping stay with the template, so a
 * replacement only has to describe what the chapter page looks like. It is not called for
 * `headings.chapter-style: "plain"`, nor for a heading preceded by `#no-big-title()`:
 * both mean "this is not a chapter page".
 *
 * Replaceable through `render.chapter`.
 *
 * @param cfg - The resolved configuration dictionary
 * @param it - The level-1 heading element
 * @param label - Whether to print the "Chapitre N" label (false for a masked chapter)
 * @returns The chapter page content
 */
#let default-chapter(cfg, it, label: true) = {
  let chapter-font = cfg.fonts.chapter
  let primary = cfg.colors.primary

  set align(center)
  set block(spacing: 0.6cm)

  if cfg.headings.chapter-pagebreak {
    v(-(cfg.page.margin.top / 2))
  }

  if label {
    context {
      if heading.numbering != none {
        // Masked chapters gave their number back, so the live counter already holds the
        // visible chapter number.
        let chapter-num = counter(heading).at(here()).at(0)
        [#linguify("chapter", from: translations-database) #chapter-num]
      }
    }
  }

  thin-line(primary)
  text(
    font: chapter-font.name,
    weight: chapter-font.weight,
    size: chapter-font.size,
    it.body,
  )
  thin-line(primary)
}

/**
 * Apply document styling and layout configuration, and render the body.
 *
 * The `set page` rule below always opens a fresh page, so the body starts on a page of its
 * own: this is where the page numbering begins when `page.numbering-from` is `auto`.
 *
 * @param cfg - The resolved configuration dictionary
 * @param body - The document content
 */
#let apply-styling(cfg, body) = {
  let primary = cfg.colors.primary
  let body-font = cfg.fonts.body
  let title-font = cfg.fonts.title
  let chapter-font = cfg.fonts.chapter
  let inline-raw-font = cfg.fonts.inline-raw
  let margin = cfg.page.margin

  // Main document settings
  set page(
    fill: white,
    header-ascent: 50%,
    footer-descent: 50%,
    margin: margin,
    numbering: _page-numbering(cfg),
    number-align: cfg.page.number-align,

    header: (_hook(cfg, "header", default-header))(cfg),

    // `auto` keeps Typst's own footer, which is what renders the page numbering above.
    // A hook replaces it outright, numbering included.
    footer: if cfg.render.footer == auto {
      auto
    } else {
      (cfg.render.footer)(cfg)
    },
  )

  // On the page the rule above just opened, so the first body page is the one that prints
  // `page.numbering-start`.
  _body-counter-shift(cfg)

  show: great-theorems-init

  // Typography settings
  set par(justify: true)
  set text(font: body-font.name, weight: body-font.weight, size: cfg.fonts.size)

  // Figure customization
  set figure.caption(separator: [ \- ], position: bottom)
  show figure.caption: set text(fill: primary, weight: "bold")

  // Headings styling
  show heading: set text(font: title-font.name, weight: title-font.weight, fill: primary)

  // Heading numbering
  set heading(numbering: (..nums) => {
    let level = nums.pos().len()

    if level == 1 {
      numbering("I -", ..nums)
    } else if level == 2 {
      numbering("I -", nums.pos().last())
    } else if level == 3 {
      numbering("I.I -", nums.pos().at(1), nums.pos().last())
    } else if level == 4 {
      numbering("I.I.1 -", nums.pos().at(1), nums.pos().at(2), nums.pos().last())
    }
  })

  // Heading spacing
  let plain-chapters = cfg.headings.chapter-style == "plain"
  let chapter-pagebreak = cfg.headings.chapter-pagebreak
  let chapter-label = cfg.headings.chapter-label
  let chapter-renderer = _hook(cfg, "chapter", default-chapter)

  show heading: it => {
    if it.level == 1 and plain-chapters {
      // Plain chapters: a normal in-flow level-1 heading, still using the chapter font so
      // it outranks the 1.2em of a level-2 heading. A preceding `#no-numbering()` drops
      // the prefix and gives the number back, as it does for deeper levels.
      context [
        #set text(font: chapter-font.name, weight: chapter-font.weight, size: chapter-font.size)
        #if _immediately-preceded-by(<_cnam-no-numbering>, it.location()) [
          #counter(heading).update(_give-back-number)
          #it.body
        ] else [
          #it
        ]
      ]
    } else if it.level == 1 {
      context {
        if _immediately-preceded-by(<_cnam-no-big-title>, it.location()) [
          #set text(size: 1.2em)
          #it
        ] else if _immediately-preceded-by(<_cnam-no-numbering>, it.location()) [
          // Masked chapter: the same chapter page without the "Chapitre N" label, giving
          // its number back so numbered chapters keep counting without a gap. The
          // give-back is emitted after the page break so it lands past the heading's own
          // counted position (a break before it would place it too early).
          #if chapter-pagebreak { pagebreak(weak: true) }
          #counter(heading).update(_give-back-number)
          #chapter-renderer(cfg, it, label: false)
        ] else [
          #if chapter-pagebreak { pagebreak(weak: true) }
          #chapter-renderer(cfg, it, label: chapter-label)
        ]
      }
    } else {
      // Font size decreases with depth: == 1.2em, === 1.1em, ==== 1.0em, ===== 0.95em, ====== 0.9em
      let heading-size = (1.2em, 1.1em, 1.0em, 0.95em, 0.9em).at(calc.min(it.level - 2, 4))
      // Render without Typst's built-in hanging indent (which grows with level depth)
      block(above: 1.2em, below: 0.9em, sticky: true, width: 100%)[
        #set text(size: heading-size)
        #context {
          if _immediately-preceded-by(<_cnam-no-numbering>, it.location()) {
            // Masked sub-heading: suppress the prefix and give back the number so its
            // numbered siblings stay consecutive (I.I, I.II, ...) regardless of how many
            // masked siblings are interleaved.
            counter(heading).update(_give-back-number)
          } else if it.numbering != none {
            numbering(it.numbering, ..counter(heading).at(it.location()))
            h(0.3em)
          }
          it.body
        }
      ]
    }
  }

  // Heading reference styling.
  // The template's heading numbering bakes a trailing " -" into every number
  // (e.g. "VIII -"), which the default `@ref` rendering drags into the reference
  // ("Section VIII -"). Re-render heading references with a clean roman numeral and
  // no dash, mirroring the numbering scheme above at each level.
  show ref: it => {
    let el = it.element
    if el == none or el.func() != heading {
      return it
    }
    let nums = counter(heading).at(el.location())
    let formatted = if el.level == 1 {
      numbering("I", ..nums)
    } else if el.level == 2 {
      numbering("I", nums.last())
    } else if el.level == 3 {
      numbering("I.I", nums.at(1), nums.last())
    } else {
      numbering("I.I.1", nums.at(1), nums.at(2), nums.last())
    }
    link(el.location())[Section #formatted]
  }

  // Link styling
  show link: it => if cfg.print { it.body } else { underline(text(fill: primary, it)) }
  if cfg.print {
    show underline: it => it.body
  }

  // List styling
  set enum(indent: 1em, numbering: n => [#text(fill: primary, numbering("1.", n))])
  set list(indent: 1em, marker: n => [#text(fill: primary, "•")])

  // Math equation configuration
  show heading: i-figured.reset-counters
  show math.equation: i-figured.show-equation.with(
    level: 3,
    zero-fill: false,
    leading-zero: true,
    numbering: "(1.1)",
    prefix: "eqt:",
    only-labeled: false,
    unnumbered-label: "-",
  )
  set math.equation(number-align: bottom)

  // Text highlighting for specific words
  show regex(if cfg.color-words.len() == 0 { "$ " } else { cfg.color-words.join("|") }): text.with(fill: primary)

  // Inline code styling
  let side-padding = .35em;
  show raw.where(block: false) : it => h(side-padding) + box(fill: primary.lighten(90%), outset: (x: .25em, y: .35em), radius: 2pt, text(font: inline-raw-font.name, weight: inline-raw-font.weight, it.text)) + h(side-padding)

  // Outline styling
  set outline(indent: n => n * 0.5em)

  body
}

/**
 * Create decorative elements for the document.
 *
 * Reads `colors.primary`, `colors.secondary` and `cover.second-logo` from the config.
 * The secondary logo is skipped when `cover.second-logo.image` is none.
 *
 * @param cfg - The resolved configuration dictionary
 */
#let default-decorations(cfg) = {
  let second-logo = cfg.cover.second-logo

  // Top left decoration
  place(top + left, dx: -25%, dy: -28%, circle(radius: 150pt, fill: cfg.colors.primary))
  place(top + left, circle(radius: 75pt, fill: cfg.colors.secondary))

  // Logo inside the secondary circle
  if second-logo.image != none {
    let circle-radius = 75pt
    let logo-size = 2 * circle-radius * second-logo.scale
    place(
      top + left,
      dx: circle-radius - logo-size / 2 + second-logo.dx,
      dy: circle-radius - logo-size / 2 + second-logo.dy,
      box(width: logo-size, height: logo-size, clip: true, second-logo.image),
    )
  }

  // Bottom right decoration
  place(bottom + right, dx: 25%, dy: 25%, circle(radius: 100pt, fill: cfg.colors.secondary))
}

/**
 * Place the cover decorations, through the `render.decorations` hook.
 *
 * @param cfg - The resolved configuration dictionary
 */
#let add-decorations(cfg) = (_hook(cfg, "decorations", default-decorations))(cfg)

/**
 * Built-in cover page: logo, the title block framed by two rules, and the author block
 * at the bottom.
 *
 * Returns the cover page content only. The page break that follows it, the background
 * reset and the front matter belong to `create-title-page`, not here.
 *
 * Replaceable through `render.cover`.
 *
 * @param cfg - The resolved configuration dictionary
 * @returns The cover page content
 */
#let default-cover(cfg) = {
  let info = cfg.info
  let cover = cfg.cover
  let author = format-authors(info.author)

  // Logo placement
  if info.logo != none {
    set image(width: 6cm)
    place(
      top + right,
      dx: .5cm,
      dy: -1.5cm,
      info.logo
    )
  }

  v(2fr)

  line(length: 100%, stroke: cover.title.color)

  {
    set block(spacing: 0pt)
    set par(spacing: 0pt)

    v(cover.padding)

    // Title
    align(cover.title.align, text(font: cover.title.font, cover.title.size, weight: cover.title.weight, fill: cover.title.color, cover.title.text))

    // Subtitle
    if cover.subtitle.text != none and cover.subtitle.text != "" {
      v(cover.spacing)
      align(cover.subtitle.align, text(font: cover.subtitle.font, cover.subtitle.size, weight: cover.subtitle.weight, fill: cover.subtitle.color, cover.subtitle.text))
    }

    // Subsubtitle
    if cover.subsubtitle.text != none and cover.subsubtitle.text != "" {
      v(cover.spacing)
      align(cover.subsubtitle.align, text(font: cover.subsubtitle.font, cover.subsubtitle.size, weight: cover.subsubtitle.weight, fill: cover.subsubtitle.color, cover.subsubtitle.text))
    }

    // Date
    if info.start-date != none {
      v(cover.spacing)
      align(
          cover.date.align,
          text(font: cover.date.font, weight: cover.date.weight, cover.date.size, fill: cover.date.color,
            if info.last-updated-date == none or not cover.date.range or info.start-date == info.last-updated-date {
              date-format(info.start-date)
            } else {
              date-format(info.start-date) + " - " + date-format(info.last-updated-date)
            }
          )
      )
    }

    v(cover.padding)
  }

  line(length: 100%, stroke: cover.title.color)

  v(2fr)

  // Author information
  let school-year = if info.year == none {
    none
  } else if info.start-date != none and info.start-date.month() < 9 {
    int(info.year) - 1
  } else {
    int(info.year)
  }
  let next-year = if school-year != none { str(school-year + 1) } else { none }

  let bottom-text = text(
    font: cover.author.font,
    weight: cover.author.weight,
    fill: cover.author.color,
    author + "\n" +
    if (info.affiliation != "") {
      info.affiliation + "\n"
    } else {
      ""
    },
    cover.author.size,
  ) + if (info.class != "") {
    text(
      font: cover.author.font,
      weight: cfg.fonts.body.weight,
      fill: cover.author.color,
      (if school-year != none {
      if cover.date.range { str(school-year) + "-" + str(next-year) } else { str(school-year) }
    } else { "" }) + "\n" + emph[#info.class],
      cover.author.size)
  }

  place(
    bottom + cover.author.align,
    dy: 5%,
    align(cover.author.align)[
      #bottom-text
    ]
  )
}

// --- Front matter --------------------------------------------------------------------
//
// `front-matter.pages` is the ordered list of pages between the cover and the body, so
// "which page carries the outline" is answered by where "outline" sits in that list,
// rather than by a page number that every later edit would invalidate.

// The built-in front-matter pages.
#let _front-matter-builtins = ("blank", "cover-text", "outline", "figures", "tables")

// The keys a dictionary entry may carry.
#let _front-matter-keys = ("kind", "title", "body", "outlined")

// Normalize one `front-matter.pages` entry to (kind, title, body, outlined), `kind` being
// a built-in name or "section" for a section of your own. `title: auto` means "not given":
// the built-in default title for a built-in page, no title at all for a section.
#let _front-matter-entry(entry) = {
  let defaults = (kind: "section", title: auto, body: none, outlined: true)

  if type(entry) == str {
    if entry not in _front-matter-builtins {
      panic(
        "unknown front-matter page `" + entry + "`. Valid names: "
          + _front-matter-builtins.join(", ")
          + ". A section of your own is a `(title: .., body: ..)` dictionary.",
      )
    }
    return (..defaults, kind: entry)
  }

  // Anything that is not a name and not a dictionary is content: it *is* the page.
  if type(entry) != dictionary { return (..defaults, body: entry) }

  for key in entry.keys() {
    if key not in _front-matter-keys {
      panic(
        "unknown key `" + key + "` in a `front-matter.pages` entry. Valid keys: "
          + _front-matter-keys.join(", "),
      )
    }
  }

  let out = defaults + entry

  if out.kind != "section" and out.kind not in _front-matter-builtins {
    panic(
      "unknown front-matter page kind " + repr(out.kind) + ". Valid kinds: "
        + _front-matter-builtins.join(", "),
    )
  }
  if out.kind != "section" and out.body != none {
    panic(
      "`body` does not apply to the built-in front-matter page `" + out.kind
        + "`; drop `kind` to write a section of your own instead",
    )
  }

  out
}

// Outline entry styling, shared by the table of contents and the figure and table lists:
// every entry links to its target, in `colors.outline` when the palette pins one.
#let _outline-entries(cfg, body) = {
  show outline.entry: it => {
    if cfg.colors.outline != auto {
      set text(fill: cfg.colors.outline)
      link(it.element.location(), it.indented(it.prefix(), it.inner()))
    } else {
      link(it.element.location(), it.indented(it.prefix(), it.inner()))
    }
  }
  body
}

// Front-matter titles all read the same way: the plain chapter look, never numbered. The
// rule also catches the title `outline()` renders on its own, so the table of contents is
// titled like the pages around it.
#let _front-matter-styling(cfg, body) = {
  show heading.where(level: 1): it => block(
    below: 1.2em,
    text(
      font: cfg.fonts.chapter.name,
      weight: cfg.fonts.chapter.weight,
      size: cfg.fonts.chapter.size,
      fill: cfg.colors.primary,
      it.body,
    ),
  )
  body
}

// A page body: content, or a function of the resolved configuration, as the `render.*`
// hooks take, so a section can be written next to the rest of its own styling and still
// read the palette, the fonts and the document metadata.
#let _front-matter-body(cfg, body) = {
  if type(body) == function { body(cfg) } else { body }
}

// Render one front-matter entry, or `none` when it has nothing to show -- which is how a
// disabled outline avoids leaving an empty page behind.
#let _front-matter-page(cfg, entry) = {
  let e = _front-matter-entry(entry)

  // An intentionally empty page: the surrounding page breaks are all it takes.
  if e.kind == "blank" { return [] }

  if e.kind == "cover-text" {
    // The cover's text block again, through the same hook and without the logo: this page
    // repeats what the cover says, it does not repeat the cover. The cover background
    // comes along, because the cover text is colored for it.
    let plain = cfg
    plain.info.logo = none

    return {
      set page(fill: cfg.cover.bg)
      (_hook(cfg, "cover", default-cover))(plain)
    }
  }

  if e.kind == "outline" {
    if not cfg.outline.enabled { return none }
    if cfg.outline.custom != none { return cfg.outline.custom }

    return _outline-entries(cfg, outline(
      title: e.title,
      indent: cfg.outline.indent,
      depth: cfg.outline.depth,
    ))
  }

  if e.kind in ("figures", "tables") {
    return _outline-entries(cfg, outline(
      title: if e.title == auto {
        linguify(e.kind, from: translations-database, lang: cfg.lang)
      } else {
        e.title
      },
      target: figure.where(kind: if e.kind == "figures" { image } else { table }),
    ))
  }

  // A section of your own: an unnumbered title, listed in the outline unless told
  // otherwise, followed by its content.
  if e.title != auto and e.title != none {
    heading(level: 1, numbering: none, outlined: e.outlined, e.title)
  }
  _front-matter-body(cfg, e.body)
}

/**
 * Render the cover page, then the front matter.
 *
 * The cover itself comes from the `render.cover` hook; the page breaks, the background
 * reset and the front matter stay here so a replacement cover does not have to remember
 * them. Each entry of `front-matter.pages` gets a page of its own, in the order given, and
 * an entry with nothing to show leaves no page behind.
 *
 * @param cfg - The resolved configuration dictionary
 */
#let create-title-page(cfg) = {
  (_hook(cfg, "cover", default-cover))(cfg)

  pagebreak()

  // Reset cover background for subsequent pages
  set page(fill: none)

  let pages = cfg.front-matter.pages.map(e => _front-matter-page(cfg, e)).filter(p => p != none)

  _front-matter-styling(cfg, {
    for (index, rendered) in pages.enumerate() {
      if index > 0 { pagebreak() }
      rendered
    }
  })

  // A hard break, so that a last front-matter page which is blank stays a page of its own
  // instead of collapsing into the body.
  if pages.len() > 0 { pagebreak() }
}
