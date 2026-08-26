/**
 * UI Components for the TYPST template
 */

#import "store.typ": get-config, get-fonts

/**
 * Create a blockquote with customizable styling.
 *
 * Creates a styled quote block with border accent and subtle background.
 * Perfect for highlighting important quotes or references.
 * Supports optional attribution/source, flexible alignment, and border positioning.
 *
 * @param color - The stroke color (auto = colors.neutral from the config)
 * @param fill - The background fill color (auto = colors.neutral-light from the config)
 * @param inset - The padding inside the block (default: custom spacing)
 * @param radius - The border radius (auto = derived from border-side, the corners away from the accent are rounded)
 * @param stroke - The stroke configuration (auto = derived from border-side)
 * @param block-align - The alignment of the block itself (default: left)
 * @param content-align - The alignment of the content inside the block (default: left)
 * @param width - The width of the block: auto for content width, 100% for full width, or custom length (default: 100%)
 * @param border-side - Which side carries the accent border: the alignment `left`, `right`, `top`, `bottom`, the matching string, or `"all"` for a full border (default: left). An unknown value is an error, not a silent fallback
 * @param attribution - Optional attribution/source text to display at the bottom (default: none)
 * @param attribution-align - The alignment of the attribution: left, center, or right (default: right)
 * @param attribution-style - Text styling for the attribution: (size, weight, fill, style) (fill auto = colors.neutral-dark from the config)
 * @param attribution-inset - The padding around the attribution (default: (top: 8pt))
 * @param content - The content to display
 * @returns A styled blockquote element
 *
 * ## Usage Examples
 *
 * Basic usage with attribution:
 * ```typst
 * #blockquote(
 *   attribution: "— Albert Einstein",
 *   [Imagination is more important than knowledge.]
 * )
 * ```
 *
 * Right-side border with centered content:
 * ```typst
 * #blockquote(
 *   border-side: right,
 *   content-align: center,
 *   attribution: "— Confucius",
 *   attribution-align: center,
 *   [I hear and I forget. I see and I remember. I do and I understand.]
 * )
 * ```
 *
 * Full border with custom styling:
 * ```typst
 * #blockquote(
 *   border-side: all,
 *   color: blue,
 *   fill: blue.lighten(95%),
 *   attribution: "— Marie Curie",
 *   attribution-style: (size: 0.85em, style: "italic", fill: blue.darken(20%)),
 *   [Nothing in life is to be feared, it is only to be understood.]
 * )
 * ```
 *
 * Centered block with auto width:
 * ```typst
 * #blockquote(
 *   block-align: center,
 *   width: auto,
 *   [Short quote that fits content width]
 * )
 * ```
 */
#let blockquote = (
  color: auto,
  fill: auto,
  inset: (left: 1em, top: 10pt, right: 10pt, bottom: 10pt),
  radius: auto,
  stroke: auto,
  block-align: left,
  content-align: left,
  width: 100%,
  border-side: left,
  attribution: none,
  attribution-align: right,
  attribution-style: (size: 0.9em, style: "italic", fill: auto),
  attribution-inset: (top: 8pt),
  content,
) => context {
  let cfg = get-config()
  let color = if color == auto { cfg.colors.neutral } else { color }
  let fill = if fill == auto { cfg.colors.neutral-light } else { fill }
  let attribution-fill = {
    let requested = attribution-style.at("fill", default: auto)
    if requested == auto { cfg.colors.neutral-dark } else { requested }
  }

  // `border-side` is accepted both as an alignment (`right`) and as a string ("right"),
  // because both spellings read naturally at the call site. Anything else is a typo, and a
  // typo is reported rather than quietly rendered with the default left border.
  let side = if border-side == "all" {
    "all"
  } else if border-side == left or border-side == "left" {
    "left"
  } else if border-side == right or border-side == "right" {
    "right"
  } else if border-side == top or border-side == "top" {
    "top"
  } else if border-side == bottom or border-side == "bottom" {
    "bottom"
  } else {
    panic(
      "unknown `border-side` " + repr(border-side)
        + ". Expected left, right, top, bottom (alignment or string) or \"all\"",
    )
  }

  // The accent sits on `side`; the corners away from it are the ones that get rounded.
  // An explicit `stroke` or `radius` wins over both.
  let stroke = if stroke != auto {
    stroke
  } else if side == "all" {
    2.5pt + color
  } else if side == "left" {
    (left: 2.5pt + color)
  } else if side == "right" {
    (right: 2.5pt + color)
  } else if side == "top" {
    (top: 2.5pt + color)
  } else {
    (bottom: 2.5pt + color)
  }

  let radius = if radius != auto {
    radius
  } else if side == "all" {
    5pt
  } else if side == "left" {
    (top-right: 5pt, bottom-right: 5pt)
  } else if side == "right" {
    (top-left: 5pt, bottom-left: 5pt)
  } else if side == "top" {
    (bottom-left: 5pt, bottom-right: 5pt)
  } else {
    (top-left: 5pt, top-right: 5pt)
  }

  align(
    block-align,
    rect(
      stroke: stroke,
      inset: inset,
      fill: fill,
      radius: radius,
      width: width,
      {
        align(content-align, content)
        if attribution != none {
          v(attribution-inset.at("top", default: 8pt))
          align(
            attribution-align,
            text(
              size: attribution-style.at("size", default: 0.9em),
              weight: attribution-style.at("weight", default: "regular"),
              fill: attribution-fill,
              style: attribution-style.at("style", default: "italic"),
              attribution
            )
          )
        }
      }
    )
  )
}

/**
 * Create a custom block with configurable styling.
 *
 * A highly customizable content block that can be styled and positioned
 * according to your needs. Useful for callouts, notes, or highlighting content.
 * Supports optional titles and flexible alignment options.
 *
 * @param fill - The background color (auto = colors.neutral-light from the config)
 * @param inset - The padding of the block (default: 15pt)
 * @param radius - The radius of the block (default: 4pt)
 * @param outline - The outline stroke of the block (default: none)
 * @param block-align - The alignment of the block itself (default: center)
 * @param content-align - The alignment of the content inside the block (default: left)
 * @param width - The width of the block: auto for content width, 100% for full width, or custom length (default: auto)
 * @param title - Optional title text to display at the top (default: none)
 * @param title-align - The alignment of the title: left, center, or right (default: left)
 * @param title-style - Text styling for the title: (size, weight, fill, font) (default: (size: 1.1em, weight: "bold", fill: black, font: auto))
 * @param title-inset - The padding around the title (default: (bottom: 8pt))
 * @param body-style - Text styling for the body: (size, weight, fill, font) where auto means inherit (default: (size: auto, weight: auto, fill: auto, font: auto))
 * @param content - The content of the block
 * @returns A styled content block
 *
 * ## Usage Examples
 *
 * Basic usage with title:
 * ```typst
 * #my-block(
 *   title: "Important Note",
 *   [This is some important content.]
 * )
 * ```
 *
 * Centered title with custom styling:
 * ```typst
 * #my-block(
 *   title: "Warning",
 *   title-align: center,
 *   title-style: (size: 1.2em, weight: "bold", fill: red),
 *   fill: rgb("#fff3cd"),
 *   [Be careful with this operation!]
 * )
 * ```
 *
 * Full-width block with centered content:
 * ```typst
 * #my-block(
 *   width: 100%,
 *   content-align: center,
 *   [Centered content in full-width block]
 * )
 * ```
 *
 * Content-width block aligned to the right:
 * ```typst
 * #my-block(
 *   block-align: right,
 *   width: auto,
 *   [This block fits its content and is aligned to the right]
 * )
 * ```
 */
#let my-block = (
  fill: auto,
  inset: 15pt,
  radius: 4pt,
  outline: none,
  block-align: center,
  content-align: left,
  width: auto,
  title: none,
  title-align: left,
  title-style: (size: 1.1em, weight: "bold", fill: black, font: auto),
  title-inset: (bottom: 8pt),
  body-style: (size: auto, weight: auto, fill: auto, font: auto),
  content
) => context {
  let fill = if fill == auto { get-config().colors.neutral-light } else { fill }

  align(
    block-align,
    block(
      fill: fill,
      inset: inset,
      radius: radius,
      stroke: outline,
      width: width,
      {
        if title != none {
          let title-font = title-style.at("font", default: auto)
          align(
            title-align,
            {
              let styled-title = text(
                size: title-style.at("size", default: 1.1em),
                weight: title-style.at("weight", default: "bold"),
                fill: title-style.at("fill", default: black),
                title
              )
              if title-font != auto {
                set text(font: title-font)
                styled-title
              } else {
                styled-title
              }
            }
          )
          v(title-inset.at("bottom", default: 8pt))
        }

        // Apply body-style if any non-auto values are set
        let body-size = body-style.at("size", default: auto)
        let body-weight = body-style.at("weight", default: auto)
        let body-fill = body-style.at("fill", default: auto)
        let body-font = body-style.at("font", default: auto)

        let styled-body = content
        if body-size != auto { styled-body = text(size: body-size, styled-body) }
        if body-weight != auto { styled-body = text(weight: body-weight, styled-body) }
        if body-fill != auto { styled-body = text(fill: body-fill, styled-body) }

        if body-font != auto {
          align(content-align, { set text(font: body-font); styled-body })
        } else {
          align(content-align, styled-body)
        }
      }
    )
  )
}

/**
 * Enhanced and modernized code block with line numbers, syntax highlighting, and language display.
 *
 * This component provides a feature-rich code display with:
 * - Configurable line numbering with custom alignment and styling
 * - Syntax highlighting support for various languages
 * - Language and filename label badges
 * - Customizable styling and theming
 * - Label support for referencing specific lines
 * - Line range selection for partial code display
 * - Flexible alignment options
 *
 * ## Usage Examples
 *
 * Basic usage:
 * ```typst
 * #code(lang: "Python", ```python
 * def hello_world():
 *     print("Hello, World!")
 * ```)
 * ```
 *
 * With custom styling:
 * ```typst
 * #code(
 *   numbering: false,
 *   fill: rgb("#f8f8f8"),
 *   text-style: (size: 10pt),
 *   lang: "Rust",
 *   source
 * )
 * ```
 *
 * Centered block with line range:
 * ```typst
 * #code(
 *   block-align: center,
 *   width: 80%,
 *   lines: (5, 15),
 *   lang: "Python",
 *   source
 * )
 * ```
 *
 * @param line-spacing - Vertical spacing between code lines (default: 5pt)
 * @param line-offset - Horizontal offset for line numbers (default: 5pt)
 * @param numbering - Whether to display line numbers: true, false, or auto (hides for single-line blocks) (default: true)
 * @param inset - Inner padding around the code block (default: 5pt)
 * @param radius - Border radius for rounded corners (default: 3pt)
 * @param number-align - Alignment of line numbers: left, center, right (default: right)
 * @param number-style - Styling for line numbers: (size, fill, weight) (fill auto = colors.neutral from the config)
 * @param accent - Color of the left rule and of the language tab (auto = the language's color from code.lang-colors, falling back to code.accent then colors.primary)
 * @param stroke - Border stroke style and color (auto = a 0.35em rule down the left edge, in the accent)
 * @param fill - Background fill color behind the code (auto = code.background, itself defaulting to the accent lightened to 94%)
 * @param text-style - Text styling for the code body: (size, font, fill). The font defaults to fonts.code from the config
 * @param width - Block width, can be length or percentage (default: 100%)
 * @param block-align - The alignment of the block itself (default: left)
 * @param breakable - Whether the code block may split across pages: true, false, or auto. With auto, the block is kept whole (pushed to the next page) when it fits within a single page, and only allowed to break when it is taller than a page (default: auto)
 * @param lines - Line range to display: (start, end) or auto for all (default: auto)
 * @param lang - Programming language for syntax highlighting (default: none)
 * @param filename - Optional filename to display before the language (default: none)
 * @param lang-box - Styling for the language tab: (fill, inset, radius, text-style). `fill` auto = colors.primary; the text fill auto picks black or white for contrast against it
 * @param title - Text styling for the filename shown beside the language tab: (size, font, fill, weight); fill defaults to colors.neutral-dark
 * @param source - The source code content as raw text block
 */
#let code(
  line-spacing: 5pt,
  line-offset: 5pt,
  numbering: true,
  inset: (x: 1.2em, y: 1em),
  radius: 2pt,
  number-align: right,
  number-style: (size: 8pt, fill: auto),
  accent: auto,
  stroke: auto,
  fill: auto,
  text-style: (size: 8pt),
  width: 100%,
  block-align: left,
  breakable: auto,
  lines: auto,
  lang: none,
  filename: none,
  lang-box: (:),
  title: (:),
  source
) = {
  // Helper function to extract labels from source code
  let extract-labels(source-text) = {
    let label-regex = regex("<((\w|_|-)+)>[ \t\r\f]*(\n|$)")
    source-text
      .split("\n")
      .map(line => {
        let match = line.match(label-regex)
        if match != none {
          match.captures.at(0)
        } else {
          none
        }
      })
  }

  // Helper function to create styled line numbers
  let create-line-number(number, style) = text(
    size: style.at("size", default: 8pt),
    fill: style.at("fill", default: gray),
    weight: style.at("weight", default: "regular"),
    font: style.at("font", default: auto),
    str(number)
  )

  // Helper function to clean source code from labels
  let clean-source(source-text) = {
    let label-regex = regex("<((\w|_|-)+)>[ \t\r\f]*(\n|$)")
    source-text.replace(label-regex, "\n")
  }

  // Helper function to normalize line range
  let normalize-line-range(lines, total-lines) = {
    let result = lines
    if result == auto {
      result = (auto, auto)
    }
    if result.at(0) == auto {
      result.at(0) = 1
    }
    if result.at(1) == auto {
      result.at(1) = total-lines
    }
    (result.at(0) - 1, result.at(1))
  }

  // Process source code
  let labels = extract-labels(source.text)
  let unlabelled-source = clean-source(source.text)

  // effective-lang controls only the top-box label; syntax highlighting always comes from source.lang
  let effective-lang = lang

  context {
    let cfg = get-config()
    let fonts = cfg.fonts

    // The accent carries the block: a rule down the left edge, the language tab, and a
    // tint of the same hue behind the code. Four sources, most specific first: this call,
    // the language's own color, a `code.accent` pinned by the configuration, the brand.
    // The label given to `lang` wins over the raw block's own attribute, since it is the
    // one the reader sees.
    let lang-key = lower(if type(effective-lang) == str {
      effective-lang
    } else if type(source.at("lang", default: none)) == str {
      source.at("lang", default: none)
    } else {
      ""
    })
    let lang-key = cfg.code.lang-aliases.at(lang-key, default: lang-key)
    let accent = if accent != auto {
      accent
    } else if cfg.code.accent != auto {
      cfg.code.accent
    } else {
      cfg.code.lang-colors.at(lang-key, default: cfg.colors.primary)
    }

    let stroke = if stroke == auto { (left: 0.35em + accent) } else { stroke }
    let fill = if fill != auto {
      fill
    } else if cfg.code.background != auto {
      cfg.code.background
    } else {
      accent.lighten(94%)
    }
    let final-text-style = (font: fonts.code.name, weight: fonts.code.weight, ..text-style)
    let final-number-style = {
      let requested = number-style.at("fill", default: auto)
      (
        font: fonts.code.name,
        ..number-style,
        fill: if requested == auto { cfg.colors.neutral } else { requested },
      )
    }

    // Apply text styling to raw content
    // Disable kerning and ligatures to preserve strict monospace grid alignment
    show raw.line: set text(..final-text-style, kerning: true, ligatures: true)
    show raw: set text(..final-text-style, kerning: true, ligatures: true)
    set par(justify: false, leading: line-spacing)

    show raw.where(block: true): it => context {
    // Normalize line range using helper function
    let line-range = normalize-line-range(lines, it.lines.len())

    // Resolve effective numbering: auto means show only when more than one line
    let effective-numbering = if numbering == auto {
      it.lines.len() > 1
    } else {
      numbering
    }

    // Calculate maximum line number width for proper alignment
    let maximum-number-length = if effective-numbering {
      measure(create-line-number(line-range.at(1), final-number-style)).width
    } else {
      0pt
    }

    block(
      inset: inset,
      radius: radius,
      stroke: stroke,
      fill: fill,
      width: width,
      {
        stack(
          dir: ttb,
          spacing: line-spacing,
          // Code lines without language label
          ..it
            .lines
            .slice(..line-range)
            .map(line => table(
              stroke: none,
              inset: 0pt,
              columns: (maximum-number-length, 1fr),
              column-gutter: line-offset,
              align: (number-align, left),
              if effective-numbering {
                create-line-number(line.number, final-number-style)
              },
              {
                let line-label = labels.at(line.number - 1)

                if line-label != none {
                  show figure: it => it.body

                  counter(figure.where(kind: "sourcerer")).update(line.number - 1)
                  [
                    #figure(supplement: "Line", kind: "sourcerer", outlined: false, line)
                    #label(line-label)
                  ]
                } else {
                  line
                }
              }
            ))
            .flatten()
        )
      }
    )
  }

    // The language sits in a small tab notched onto the top-left corner of the block
    // rather than in a full-width bar. A filename, when given, trails it in muted text
    // on the page background: it is a caption, not part of the accent.
    let tab-fill = lang-box.at("fill", default: auto)
    let tab-fill = if tab-fill == auto { accent } else { tab-fill }
    let tab-text = lang-box.at("text-style", default: (:))
    let tab-ink = tab-text.at("fill", default: auto)
    // White on a dark accent, black on a light one, so a theme can recolor `primary`
    // without the tab label disappearing into it.
    let tab-ink = if tab-ink == auto {
      if color.luma(tab-fill).components().at(0) > 60% { black } else { white }
    } else {
      tab-ink
    }

    let rendered = stack(
      dir: ttb,
      spacing: 0pt,
      if filename != none or effective-lang != none {
        stack(
          dir: ltr,
          spacing: 0.6em,
          if effective-lang != none {
            block(
              fill: tab-fill,
              inset: lang-box.at("inset", default: (x: .6em, y: .3em)),
              radius: (top: lang-box.at("radius", default: radius)),
              text(
                font: tab-text.at("font", default: fonts.code.name),
                size: tab-text.at("size", default: .7em),
                weight: tab-text.at("weight", default: "black"),
                fill: tab-ink,
                upper(effective-lang),
              ),
            )
          },
          if filename != none {
            block(
              inset: (y: .3em),
              text(
                font: title.at("font", default: fonts.code.name),
                size: title.at("size", default: .7em),
                fill: title.at("fill", default: cfg.colors.neutral-dark),
                weight: title.at("weight", default: "regular"),
                filename,
              ),
            )
          },
        )
      },
      // Code block
      raw(
          block: true,
          lang: source.at("lang", default: none),
          unlabelled-source
      )
    )

    // Keep the whole code block together when it fits on a single page.
    // With `auto`, measure the rendered block against the full page height: if
    // it fits, make it non-breakable so Typst pushes it whole onto the next
    // page when the remaining space is too small; if it is taller than a page,
    // allow breaking to avoid overflowing off the page.
    //
    // The block is measured inside a `box` of the region's width because the
    // per-line layout uses a `1fr` table column, and `fr` units have no bounded
    // region under `measure` (which inflates the reported height). Bounding the
    // width makes the measurement match the rendered height.
    align(
      block-align,
      if breakable == auto {
        layout(available => context {
          let fits = measure(box(width: available.width, rendered)).height <= available.height
          block(breakable: not fits, rendered)
        })
      } else {
        block(breakable: breakable, rendered)
      }
    )
  }
}
