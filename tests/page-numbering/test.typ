#import "/src/lib.typ" as my-package
#import "/src/lib.typ": *

// Regression tests for `page.numbering-from` and `page.numbering-start`.
// Numbering starts on the cover and prints 3 there, so every page's number is its
// position in the document plus two.
#show: clean-cnam-template.with(config: (
  info: (
    title: "page numbering",
    author: "Test",
    class: "Test",
    start-date: datetime(day: 7, month: 9, year: 2025),
  ),
  page: (numbering-from: 1, numbering-start: 3),
))

= Chapitre A <chapA>

// What a page really prints, read from the numbering in effect on it.
#let printed(loc) = {
  let pattern = loc.page-numbering()
  if pattern == none { return none }
  let shown = numbering(pattern, ..counter(page).at(loc))
  if shown in (none, []) { none } else { shown }
}

#context {
  let loc = query(<chapA>).first().location()

  // Cover, outline, then the body.
  assert.eq(loc.page(), 3, message: "the body must open on the third page")
  assert.eq(
    printed(loc),
    "5",
    message: "the third page must print 5: the count starts at 3 on page 1",
  )

  // The page counter is never shifted: an anchored numbering offsets what it prints.
  assert.eq(counter(page).at(loc).first(), 3, message: "the page counter must stay untouched")
}
