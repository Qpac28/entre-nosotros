# Entre Nosotros

A couples card game (Truth / Dare / Drink) — bilingual (EN/ES), installable as a PWA, no build step, no dependencies beyond a vendored copy of Three.js.

**Live site:** https://qpac28.github.io/entre-nosotros/
**Repo:** https://github.com/Qpac28/entre-nosotros

## Files

| File | Purpose |
|---|---|
| `index.html` | Page structure: setup modal, game card, penalty wheel modal, recap modal, safe-pause modal, how-to-play modal, shared SVG gradient defs |
| `style.css` | All styling, including the vendored `Playfair Display` font-face |
| `script.js` | Game state, deck data, all game logic/UI wiring |
| `three-icon.js` | Renders the card-back icon as a lit 3D gem/heart/goblet (Three.js), with flat-SVG fallback if WebGL fails |
| `three-confetti.js` | One-shot 3D confetti burst for the Heat-10 Finale |
| `three-embers.js` | Background rising-ember particle field (Three.js), falls back to CSS dots |
| `three.min.js` | Vendored Three.js r160 UMD build (not loaded from a CDN, so the game works fully offline) |
| `playfair-display-700.woff2` | Vendored Google Font, used for headings only |
| `manifest.json` / `service-worker.js` / `icon-192.png` / `icon-512.png` | PWA install + offline support |

## Feature summary

- **Deck:** 54 base cards across Tiers 1–3 (Spark / Sensory / Power & Fantasy) × Truth/Dare/Drink, plus 33 Tier 4 "Extreme" cards (see Content policy below). No-repeat shuffle-bag draw per active filter.
- **Setup modal:** language, player count (2–4), player names, pass limit, drink-dare toggle, extreme-content toggle (off by default), sound on/off, custom card builder, `.json` expansion-pack import.
- **In-game:** Heat Meter (reach 10 → one-time 3D-confetti Finale card), Penalty Wheel (triggered when passes run out), 🛑 pause/safe-word screen, 📅 Card of the Day (date-seeded, same for everyone), 📊 session recap with badges, ❓ How to Play guide.
- **3D card icon:** drag to tilt, tap to flick-spin, glows via an additive sprite halo, idle shimmer rotation.
- **Multiplayer:** generalized from an original hardcoded 2-player model to 2–4 players (turn cycling, passes, names, recap all loop over `playerCount`).
- **PWA:** installable to home screen, offline after first load — **but this only activates when served over http(s)** (GitHub Pages works; opening `index.html` directly as a local file does not support service workers).

## Content policy

The game includes flirty/suggestive content up through intense power-dynamic and anticipation-driven prompts (Tier 4 "Extreme", opt-in, off by default). **It does not and will not contain explicit sexual act instructions or pornographic descriptions.** Tier 4 is intentionally written to imply and build tension rather than describe explicitly — this is a firm boundary, not a style choice, and was explicitly discussed and agreed with the user.

## Workflow notes

- Local repo lives at `C:\Users\migue\after-hours\`. Auto-push to `main` is pre-authorized for this repo specifically (user request, 2026-10-25) — every change gets committed and pushed without asking each time.
- GitHub Pages is configured as "Deploy from a branch: main / root" — pushes to `main` go live within about a minute.
- No build step. Editing any file and reloading the page (or pushing) is the entire deploy cycle.
