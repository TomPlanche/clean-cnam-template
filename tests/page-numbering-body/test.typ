#import "/src/lib.typ" as my-package
#import "/src/lib.typ": *

// Regression test for the default numbering anchor: `page.numbering-from: auto` leaves the
// cover and the front matter unnumbered, and `page.numbering-start` restarts the count on
// the first page of the body.
#show: clean-cnam-template.with(config: (
  info: (
    title: "page numbering from the body",
    author: "Test",
    class: "Test",
    start-date: datetime(day: 7, month: 9, year: 2025),
  ),
  page: (numbering-start: 1),
))

= Chapitre A <chapA>

#pagebreak()

#context [Deuxième page du corps <second>]

#context {
  let first = query(<chapA>).first().location()
  let second = query(<second>).first().location()

  assert.eq(first.page(), 3, message: "the body must open on the third page")
  assert.eq(counter(page).at(first).first(), 1, message: "the first body page must print 1")
  assert.eq(counter(page).at(second).first(), 2, message: "the next body page must print 2")
}
