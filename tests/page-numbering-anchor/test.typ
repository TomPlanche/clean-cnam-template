#import "/src/lib.typ" as my-package
#import "/src/lib.typ": *
#import "/src/lib/layout.typ": _anchor-location

// Regression test for a labelled numbering anchor: `page.numbering-from: <chapA>` starts
// the numbering on the page carrying `<chapA>`, whatever its position ends up being, and
// `page.numbering-start` pins the number it prints -- a number the page counter could not
// hold, since it would have to start below zero.
#show: clean-cnam-template.with(config: (
  info: (
    title: "page numbering from a label",
    author: "Test",
    class: "Test",
    start-date: datetime(day: 7, month: 9, year: 2025),
  ),
  page: (numbering-from: <chapA>, numbering-start: 1),
  front-matter: (pages: ((title: "Avant-propos", body: [Texte.]), "outline")),
))

= Chapitre A <chapA>

#pagebreak()

#context [Deuxième page du corps <second>]

#context {
  let anchor = _anchor-location(<chapA>)

  // Cover, foreword, table of contents, then the anchored chapter.
  assert.eq(anchor.page(), 4, message: "the anchor must land on the fourth page")
  assert.eq(
    anchor,
    query(<chapA>).first().location(),
    message: "the anchor must resolve to the element carrying the label",
  )

  // The page counter is never shifted for an anchored numbering: the offset is applied
  // when the number is printed, which is what lets page 4 print 1.
  assert.eq(counter(page).at(anchor).first(), 4, message: "the page counter must stay untouched")
  assert.eq(
    counter(page).at(query(<second>).first().location()).first(),
    5,
    message: "the page counter keeps following the pages",
  )
}
