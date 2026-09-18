#import "/src/lib.typ" as my-package
#import "/src/lib.typ": *

// Regression tests for `front-matter.pages`: one page per entry, in the order given,
// sections of your own listed in the outline unless they opt out, and a body given as a
// function of the resolved configuration.
#let note(cfg) = [Texte en #text(fill: cfg.colors.primary)[couleur primaire].]

#show: clean-cnam-template.with(config: (
  info: (
    title: "front-matter",
    author: "Test",
    class: "Test",
    start-date: datetime(day: 7, month: 9, year: 2025),
  ),
  front-matter: (pages: (
    "blank",
    "cover-text",
    (title: "Avant-propos", body: [Texte.]),
    (title: "Note", body: note, outlined: false),
    "outline",
    "figures",
    "tables",
  )),
))

= Chapitre A <chapA>

#figure(rect(width: 1cm, height: 1cm), caption: [Une figure])
#figure(table(columns: 1, [x]), caption: [Un tableau])

#context {
  // Cover, then one page per entry, then the body.
  assert.eq(
    query(<chapA>).first().location().page(),
    9,
    message: "the body must open on the page after the cover and the seven front-matter pages",
  )

  // Sections of your own are unnumbered level-1 headings; only the ones that did not opt
  // out reach the outline. The built-in list titles are never outlined.
  let listed = query(heading).filter(h => h.numbering == none and h.outlined)
  assert.eq(listed.len(), 1, message: "only `Avant-propos` may be listed in the outline")
  assert.eq(listed.first().level, 1, message: "a front-matter section title is a level-1 heading")

  // The front matter must not consume a chapter number.
  assert.eq(
    counter(heading).at(query(<chapA>).first().location()).first(),
    1,
    message: "the first body chapter must still be chapter 1",
  )
}
