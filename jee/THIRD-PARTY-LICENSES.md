# Third-party licenses

This project has **zero runtime dependencies**. The only third-party material it
redistributes is two typefaces, embedded as subset base64 `data:` URLs in
`dist/csab-predictor.html` so the file works offline from `file://`.

Both are used under the **SIL Open Font License, Version 1.1**, which permits
embedding, subsetting and redistribution provided the license travels with the
work and the fonts are not sold on their own.

## Lora

Copyright © 2011 Cyreal (Olga Karpushina, Alexei Vanyashin).
Licensed under SIL OFL 1.1 — <https://openfontlicense.org/>
Used for display type and all rank figures. Chosen because it ships `tnum`
(tabular figures), so a column of ranks aligns digit-for-digit.

## Lato

Copyright © 2010–2015 Łukasz Dziedzic.
Licensed under SIL OFL 1.1 — <https://openfontlicense.org/>
Used for UI and body text.

## What "subset" means here

`tools/make-font-css.py` strips each font to the glyphs this interface actually
draws — Latin printable, plus a short list of marks (dashes, curly quotes,
bullet, rupee sign, arrows, block characters). Lora goes from 212 KB to 45 KB,
Lato from 662 KB to 28 KB per weight. The subsets are not usable as general
typefaces and are not offered as such; anyone wanting the fonts should get the
originals from the upstream projects.

## SIL Open Font License 1.1 — summary of the terms that bind this project

- The fonts may be used, studied, modified and redistributed freely.
- Redistribution must include the copyright notice and license. That is the
  purpose of this file and of the notice generated into
  `src/web/assets/fonts.css`.
- The fonts may not be sold by themselves.
- Modified versions may not use the Reserved Font Names ("Lora", "Lato") to
  identify themselves. The embedded subsets are therefore declared to CSS under
  neutral family names — `Ledger Display` and `Ledger Text` — rather than under
  the original names.

The full license text is available at <https://openfontlicense.org/> and ships
with the upstream font projects.
