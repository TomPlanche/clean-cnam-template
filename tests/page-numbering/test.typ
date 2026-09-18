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

#context {
  let loc = query(<chapA>).first().location()

  // Cover, outline, then the body.
  assert.eq(loc.page(), 3, message: "the body must open on the third page")
  assert.eq(
    counter(page).at(loc).first(),
    5,
    message: "the third page must print 5: the count starts at 3 on page 1",
  )
}
