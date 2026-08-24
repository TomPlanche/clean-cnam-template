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
    ),
    en: (
      chapter: "Chapter",
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

/**
 * Apply document styling and layout configuration.
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
    numbering: if cfg.colors.page-number != auto {
      (..nums) => text(fill: cfg.colors.page-number, numbering(cfg.page.numbering, ..nums))
    } else {
      cfg.page.numbering
    },
    number-align: cfg.page.number-align,

    header: context [
      #hydra(2, display: (_, it) => {
        set align(right)

        numbering(it.numbering, ..counter(heading).at(it.location()))

        h(0.3cm) + it.body

        v(-0.3cm)

        line(length: 100%, stroke: 0.5pt + primary)
      })
    ]
  )

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
  show heading: it => {
    if it.level == 1 {
      context {
        if _immediately-preceded-by(<_cnam-no-big-title>, it.location()) [
          #set text(size: 1.2em)
          #it
        ] else if _immediately-preceded-by(<_cnam-no-numbering>, it.location()) [
          // Masked chapter: keep the decorative style but drop the "Chapitre N" label and
          // give back the number so numbered chapters keep counting without a gap. The
          // give-back is emitted after the pagebreak so it lands past the heading's own
          // counted position (a pagebreak before it would place it too early).
          #set text(font: chapter-font.name, weight: chapter-font.weight, size: chapter-font.size)
          #set align(center)
          #set block(spacing: 0.6cm)
          #pagebreak(weak: false)
          #counter(heading).update(_give-back-number)
          #v(-(margin.top / 2))
          #thin-line(primary)
          #it.body
          #thin-line(primary)
        ] else [
          #set align(center)
          #set block(spacing: 0.6cm)

          #pagebreak(weak: false)

          #v(-(margin.top / 2))

          #context {
            if heading.numbering != none {
              // Masked chapters gave their number back, so the live counter already holds
              // the visible chapter number.
              let chapter-num = counter(heading).at(here()).at(0)
              [#linguify("chapter", from: translations-database) #chapter-num]
            }
          }

          #thin-line(primary)
          #text(
            font: chapter-font.name,
            weight: chapter-font.weight,
            size: chapter-font.size,
            it.body,
          )
          #thin-line(primary)
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
#let add-decorations(cfg) = {
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
 * Create the title page layout, followed by the outline.
 *
 * @param cfg - The resolved configuration dictionary
 */
#let create-title-page(cfg) = {
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

  pagebreak()

  // Reset cover background for subsequent pages
  set page(fill: none)

  // Conditional outline rendering
  if not cfg.outline.enabled {
    // nothing
  } else if cfg.outline.custom != none {
    cfg.outline.custom
  } else {
    show outline.entry: it => {
      if cfg.colors.outline != auto {
        set text(fill: cfg.colors.outline)
        link(it.element.location(), it.indented(it.prefix(), it.inner()))
      } else {
        link(it.element.location(), it.indented(it.prefix(), it.inner()))
      }
    }
    outline(indent: cfg.outline.indent)
  }
}
