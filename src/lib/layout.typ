/**
 * Main layout and styling configuration for the template
 *
 * @author Tom Planche
 * @license MIT
 */

#import "@preview/i-figured:0.2.4"
#import "@preview/great-theorems:0.1.2": *
#import "@preview/hydra:0.6.2": hydra
#import "@preview/linguify:0.5.0": linguify
#import "headers.typ": get-header
#import "utils.typ": date-format, thin-line

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

// Global font size setting
#let body-font-size = 12pt

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

#let page-margin = (
    top: 2.5cm,
    right: 1.27cm,
    bottom: 1.75cm,
    left: 1.27cm
);

/**
 * Apply document styling and layout configuration.
 *
 * @param primary-color - The primary theme color
 * @param secondary-color - The secondary theme color
 * @param body-font - The body font family
 * @param title-font - The title/heading font family
 * @param inline-raw-font - The font for inline code elements
 * @param author - The document author
 * @param color-words - Array of words to highlight with primary color
 * @param show-secondary-header - Whether to show secondary headers (with sub-heading)
 * @param language - Language code ("fr" for French, "en" for English)
 * @param margin - Page margin dictionary
 * @param page-number-color - Color for page numbers (auto = default text color)
 * @param print - When true, strips link color and underline for print output
 * @param body - The document content
 */
#let apply-styling(
  primary-color,
  secondary-color,
  body-font,
  title-font,
  inline-raw-font,
  author,
  color-words,
  show-secondary-header,
  language,
  margin,
  page-number-color,
  print,
  body
) = {
  // Main document settings
  set page(
    fill: white,
    header-ascent: 50%,
    footer-descent: 50%,
    margin: margin,
    numbering: if page-number-color != auto {
      (..nums) => text(fill: page-number-color, numbering("1 / 1", ..nums))
    } else {
      "1 / 1"
    },
    number-align: bottom + right,

    header: context [
      #let chapters = query(
      heading.where(
        level: 1
      ))
      #let show_line = true
      #let cur_page = counter(page).at(here())
      #for chapter in chapters [
        #let loc = chapter.location()

        #if counter(page).at(loc) == cur_page {
          show_line = false
        }
      ]

      #hydra(2, display: (_, it) => {
        set align(right)

        numbering(it.numbering, ..counter(heading).at(it.location()))

        h(0.3cm) + it.body

        v(-0.3cm)

        line(length: 100%, stroke: 0.5pt + primary-color)
      })
    ]
  )

  show: great-theorems-init

  // Typography settings
  set par(justify: true)
  set text(font: body-font.name, weight: body-font.weight, size: body-font-size)

  // Figure customization
  set figure.caption(separator: [ \- ], position: bottom)
  show figure.caption: set text(fill: primary-color, weight: "bold")

  // Headings styling
  show heading: set text(font: title-font.name, weight: title-font.weight, fill: primary-color)

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
          #set text(size: 1.5em)
          #set align(center)
          #set block(spacing: 0.6cm)
          #pagebreak(weak: false)
          #counter(heading).update(_give-back-number)
          #v(-(margin.top / 2))
          #thin-line(primary-color)
          #it.body
          #thin-line(primary-color)
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

          #thin-line(primary-color)
          #text(size: 1.5em)[#it.body]
          #thin-line(primary-color)
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
  show link: it => if print { it.body } else { underline(text(fill: primary-color, it)) }
  if print {
    show underline: it => it.body
  }

  // List styling
  set enum(indent: 1em, numbering: n => [#text(fill: primary-color, numbering("1.", n))])
  set list(indent: 1em, marker: n => [#text(fill: primary-color, "•")])

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
  show regex(if color-words.len() == 0 { "$ " } else { color-words.join("|") }): text.with(fill: primary-color)

  // Inline code styling
  let side-padding = .35em;
  show raw.where(block: false) : it => h(side-padding) + box(fill: primary-color.lighten(90%), outset: (x: .25em, y: .35em), radius: 2pt, text(font: inline-raw-font.name, weight: inline-raw-font.weight, it.text)) + h(side-padding)

  // Outline styling
  set outline(indent: n => n * 0.5em)

  // Set header after initial pages
  set page(
      // header: get-header(author: author,show-secondary-header: show-secondary-header),
      margin: margin
  )

  body
}

/**
 * Create decorative elements for the document.
 *
 * @param primary-color - The primary color for decorations
 * @param secondary-color - The secondary color for decorations
 * @param second-logo - Optional dict with keys:
 *   image: logo content (pass image("...") from the user's file so relative paths resolve correctly)
 *   scale: scale factor relative to the circle diameter (default 1.0 = full diameter)
 *   dx: horizontal offset to fine-tune centering (default 0pt)
 *   dy: vertical offset to fine-tune centering (default 0pt)
 */
#let add-decorations(primary-color, secondary-color, second-logo: none) = {
  // Top left decoration
  place(top + left, dx: -25%, dy: -28%, circle(radius: 150pt, fill: primary-color))
  place(top + left, circle(radius: 75pt, fill: secondary-color))

  // Logo inside the secondary circle
  if second-logo != none {
    let circle-radius = 75pt
    let scale = if "scale" in second-logo { second-logo.scale } else { 1 }
    let dx = if "dx" in second-logo { second-logo.dx } else { 0pt }
    let dy = if "dy" in second-logo { second-logo.dy } else { 0pt }
    let logo-size = 2 * circle-radius * scale
    place(
      top + left,
      dx: circle-radius - logo-size / 2 + dx,
      dy: circle-radius - logo-size / 2 + dy,
      box(width: logo-size, height: logo-size, clip: true, second-logo.image),
    )
  }

  // Bottom right decoration
  place(bottom + right, dx: 25%, dy: 25%, circle(radius: 100pt, fill: secondary-color))
}

/**
 * Create the title page layout.
 *
 * @param title - The document title
 * @param subtitle - The document subtitle
 * @param author - The author name
 * @param affiliation - The author's affiliation
 * @param class - The class/course name
 * @param start-date - The document start date
 * @param last-updated-date - The last updated date
 * @param year - The year for school year calculation
 * @param primary-color - The primary theme color
 * @param title-font - The font for titles
 * @param body-font - The font for body text
 * @param logo - Optional logo to display
 * @param outline-code - Custom outline code (none for default, false to disable, or custom content)
 * @param cover - Resolved cover configuration dict with title/subtitle styling
 * @param outline-color - Color for table of contents entries (auto = default text color)
 */
#let create-title-page(
  title,
  subtitle,
  subsubtitle,
  author,
  affiliation,
  class,
  start-date,
  last-updated-date,
  year,
  primary-color,
  title-font,
  body-font,
  logo,
  outline-code,
  cover,
  outline-color,
) = {
  // Logo placement
  if logo != none {
    set image(width: 6cm)
    place(
      top + right,
      dx: .5cm,
      dy: -1.5cm,
      logo
    )
  }

  v(2fr)

  line(length: 100%, stroke: cover.title.color)

  {
    set block(spacing: 0pt)
    set par(spacing: 0pt)

    v(cover.padding)

    // Title
    align(cover.title.align, text(font: cover.title.font, cover.title.size, weight: cover.title.weight, fill: cover.title.color, title))

    // Subtitle
    if subtitle != none and subtitle != "" {
      v(cover.spacing)
      align(cover.subtitle.align, text(font: cover.subtitle.font, cover.subtitle.size, weight: cover.subtitle.weight, fill: cover.subtitle.color, subtitle))
    }

    // Subsubtitle
    if subsubtitle != none and subsubtitle != "" {
      v(cover.spacing)
      align(cover.subsubtitle.align, text(font: cover.subsubtitle.font, cover.subsubtitle.size, weight: cover.subsubtitle.weight, fill: cover.subsubtitle.color, subsubtitle))
    }

    // Date
    if start-date != none {
      v(cover.spacing)
      align(
          cover.date.align,
          text(font: cover.date.font, weight: cover.date.weight, cover.date.size, fill: cover.date.color,
            if last-updated-date == none or not cover.date.range or start-date == last-updated-date {
              date-format(start-date)
            } else {
              date-format(start-date) + " - " + date-format(last-updated-date)
            }
          )
      )
    }

    v(cover.padding)
  }

  line(length: 100%, stroke: cover.title.color)

  v(2fr)

  // Author information
  let school-year = if year == none { none } else if start-date != none and start-date.month() < 9 { int(year) - 1 } else { int(year) }
  let next-year = if school-year != none { str(school-year + 1) } else { none }

  let bottom-text = text(
    font: cover.author.font,
    weight: cover.author.weight,
    fill: cover.author.color,
    author + "\n" +
    if (affiliation != "") {
      affiliation + "\n"
    } else {
      ""
    },
    cover.author.size,
  ) + if (class != "") {
    text(
      font: cover.author.font,
      weight: body-font.weight,
      fill: cover.author.color,
      (if school-year != none {
      if cover.date.range { str(school-year) + "-" + str(next-year) } else { str(school-year) }
    } else { "" }) + "\n" + emph[#class],
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
  if outline-code == none {
    {
      show outline.entry: it => {
        if outline-color != auto {
          set text(fill: outline-color)
          link(it.element.location(), it.indented(it.prefix(), it.inner()))
        } else {
          link(it.element.location(), it.indented(it.prefix(), it.inner()))
        }
      }
      outline(indent: auto)
    }
  } else if outline-code != false {
    // Custom outline code provided by user
    outline-code
  }
  // If outline-code == false, no outline is rendered

}
