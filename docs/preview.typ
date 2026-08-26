// Preview document for a single theme or preset.
//
// Compiled by `just preview <name>`, which passes the name through `--input`:
//   typst compile --input theme=sobre docs/preview.typ out.pdf
//
// It exercises every component so that whatever a theme touches is visible somewhere.

#import "/src/lib.typ": *

#let name = sys.inputs.at("theme", default: "cnam")

#let layer = if name in themes {
  themes.at(name)
} else if name in presets {
  presets.at(name)
} else if name == "none" {
  (:)
} else {
  panic("unknown theme or preset: " + name + ". Run `just themes` to list them.")
}

#let kind = if name in themes { "theme" } else if name in presets { "preset" } else { "defaults" }

#show: clean-cnam-template.with(
  theme: layer,
  config: (
    lang: "en",
    info: (
      title: "Preview",
      subtitle: kind + " " + name,
      author: "clean-cnam-template",
      class: "Preview",
      start-date: datetime(day: 1, month: 9, year: 2025),
      last-updated-date: datetime(day: 30, month: 6, year: 2026),
    ),
    color-words: ("highlighted",),
  ),
)

= Headings and text

An ordinary paragraph, with an #emph[emphasised] word, a word highlighted by `color-words`,
some `inline code` and an #link("https://cnam.fr")[external link].

== Second-level section

=== Third-level section

Running text is what shows the body font, the justification and the leading.

= Components

== Blocks

#my-block(title: "Block with a title")[
  The block body, which follows `colors.neutral-light`.
]

#blockquote(attribution: "— A source")[
  A quotation, whose border follows `colors.neutral`.
]

== Math environments

#definition(title: "Definition")[
  A statement, framed according to `colors.definition`.
]

#example(title: "Example")[
  An example, framed according to `colors.example`.
]

#theorem(title: "Theorem")[
  A theorem, framed according to `colors.theorem`. $ a^2 + b^2 = c^2 $
]

== Code

Each block takes its accent from its language, through `code.lang-colors`.

#code(filename: "src/lib/themes.typ", lang: "Typst", ```typst
#let themes = (
  sobre: (
    cover: (decorations: false),
  ),
)
```)

#code(filename: "hello.py", lang: "Python", ```python
def greet(name):
    print(f"Hello, {name}!")
```)

== Lists and figures

+ First numbered item
+ Second numbered item

- First bulleted item
- Second bulleted item

#figure(
  rect(width: 4cm, height: 1.5cm, fill: luma(240)),
  caption: [A figure and its caption],
)
