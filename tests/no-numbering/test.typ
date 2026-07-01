#import "/src/lib.typ" as my-package
#import "/src/lib.typ": *

// Regression tests for `#no-numbering()` counter behavior.
// See CHANGELOG 1.6.7 (Fixed): local detection (BUG 1) + masked headings give their number back (BUG 2).
#show: clean-cnam-template.with(
  title: "no-numbering regression",
  author: "Test",
  class: "Test",
  start-date: datetime(day: 7, month: 9, year: 2025),
  colors: (main: "#C4122E"),
  outline-code: false,
)

#no-numbering()
= Preface

= Chapitre A
== Section
#no-numbering()
=== Masquee 1
#no-numbering()
=== Masquee 2
=== Visible <vis>
=== Visible 2 <vis2>
== Section 2 <s2>

= Chapitre B <chapB>

#context {
  let n(lbl) = counter(heading).at(query(lbl).first().location())

  // BUG 2: masked sub-headings give their number back, so numbered siblings stay consecutive.
  assert.eq(n(<vis>).last(), 1, message: "first visible sub-section must be number 1")
  assert.eq(n(<vis2>).last(), 2, message: "second visible sub-section must be number 2")

  // A masked level-3 heading must not advance its level-2 parent's number.
  assert.eq(n(<s2>).last(), 2, message: "Section 2 must be number 2")

  // BUG 1: a `#no-numbering()` on a sub-section must not de-number or skip later chapters.
  // Chapter A is 1 (the masked Preface gave its number back), Chapter B is 2.
  assert.eq(n(<chapB>).first(), 2, message: "Chapitre B must be chapter 2")
}
