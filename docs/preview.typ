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
    info: (
      title: "Aperçu",
      subtitle: kind + " " + name,
      author: "clean-cnam-template",
      class: "Preview",
      start-date: datetime(day: 1, month: 9, year: 2025),
      last-updated-date: datetime(day: 30, month: 6, year: 2026),
    ),
    color-words: ("surligné",),
  ),
)

= Titres et texte

Un paragraphe ordinaire, avec un mot #emph[souligné], un mot surligné par `color-words`,
du `code inline` et un #link("https://cnam.fr")[lien externe].

== Section de niveau 2

=== Section de niveau 3

Le texte courant permet de juger la police de corps, la justification et l'interligne.

= Composants

== Blocs

#my-block(title: "Bloc avec titre")[
  Corps du bloc, qui suit `colors.neutral-light`.
]

#blockquote(attribution: "— Une source")[
  Une citation, dont la bordure suit `colors.neutral`.
]

== Environnements mathématiques

#definition(title: "Définition")[
  Un énoncé, encadré selon `colors.definition`.
]

#example(title: "Exemple")[
  Un exemple, encadré selon `colors.example`.
]

#theorem(title: "Théorème")[
  Un théorème, encadré selon `colors.theorem`. $ a^2 + b^2 = c^2 $
]

== Code

#code(filename: "src/lib/themes.typ", lang: "Typst", ```typst
#let themes = (
  sobre: (
    cover: (decorations: false),
  ),
)
```)

== Listes et figures

+ Premier élément numéroté
+ Second élément numéroté

- Premier élément à puce
- Second élément à puce

#figure(
  rect(width: 4cm, height: 1.5cm, fill: luma(240)),
  caption: [Une figure et sa légende],
)
