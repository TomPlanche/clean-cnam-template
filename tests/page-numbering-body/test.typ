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

// What a page really prints, read from the numbering in effect on it.
#let printed(loc) = {
  let pattern = loc.page-numbering()
  if pattern == none { return none }
  let shown = numbering(pattern, ..counter(page).at(loc))
  if shown in (none, []) { none } else { shown }
}

#context {
  let first = query(<chapA>).first().location()
  let second = query(<second>).first().location()

  assert.eq(first.page(), 3, message: "the body must open on the third page")
  assert.eq(printed(first), "1", message: "the first body page must print 1")
  assert.eq(printed(second), "2", message: "the next body page must print 2")

  // The front matter carries a numbering that prints nothing, so that its outline entries
  // show no page number either. The table of contents title is the one element the
  // template puts on that page.
  let toc-title = query(heading).first().location()
  assert.eq(toc-title.page(), 2, message: "the table of contents must be the second page")
  assert.eq(printed(toc-title), none, message: "a front-matter page must print no number")
}
