# AdventureGuideClassic

Adventure Guide for World of Warcraft Classic — the retail Encounter Journal, brought to
the Classic-line clients. Dungeon and raid encounters with their abilities, loot, maps
and quests, filtered to whichever version you are playing.

Supports Classic Era (including Season of Discovery), Burning Crusade Classic and
WoW: Forever.

## Credits

**TomCat** ([TomCat's Tours](https://www.tomcatstours.com)) built the original structure
this addon is still built on, and wrote the `GlobalFacade` library under `lib/TomCats/`
that every file in the project loads through. Much of the encounter data, the widget
system and the journal's UI scaffolding are his work — the per-file headers say which.
The addon would not exist in this shape without him.

Programming and ongoing development by **FooxyTV** (simon@fooxy.tv).

## Licence

GPL-3.0 — see [`LICENSE`](LICENSE) for the full text. A derivative work has to stay
GPL-3.0 and keep the notices.

**`lib/TomCats/` is the one exception, and is not covered by it.** Those files are
copyright TomCat's Tours, all rights reserved, used here under a non-exclusive licence
granted to FooxyTV for this addon; their own headers carry the terms. They cannot be
taken out of it.

That is more than a footnote, because `GlobalFacade.lua` sits under the exception and
every source file's first line loads through it. Anyone reusing this code needs to
supply their own rather than assume that one travels.
