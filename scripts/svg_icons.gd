extends RefCounted

static var _cache := {}

static func make_tex(svg_str: String, scale: float = 1.0) -> ImageTexture:
	var key := str(svg_str.hash()) + "_" + str(scale)
	if _cache.has(key):
		return _cache[key]
	var img := Image.new()
	var err := img.load_svg_from_string(svg_str, scale)
	if err != OK:
		return null
	var tex := ImageTexture.create_from_image(img)
	_cache[key] = tex
	return tex

const BRAND_HEART := """<svg xmlns="http://www.w3.org/2000/svg" width="68" height="58" viewBox="0 0 68 58" fill="none">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ff8da6"/>
      <stop offset="50%" stop-color="#ff2a55"/>
      <stop offset="100%" stop-color="#9e082a"/>
    </linearGradient>
  </defs>
  <path d="M35 50 C18 39 5 26 7 14 C8.5 5 17 2 25 6 C30 8.5 33 14 35 18 C37 13 41 7.5 47 5.5 C55 3 63 8 63 17 C63 29 48 41 28 55" stroke="url(#g)" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round"/>
</svg>"""

const DOODLE_HEART := """<svg xmlns="http://www.w3.org/2000/svg" width="44" height="40" viewBox="0 0 44 40" fill="none">
  <path d="M20 34 C12 26 5 18 7 11 C8.5 6 14 5 18 9 C19.5 10.5 20.5 13 21 15 C22 12 24 8 28 7 C33 5.5 37 10 35 16 C33 23 25 29 19 35" stroke="#ff4769" stroke-width="2.0" stroke-linecap="round"/>
</svg>"""

const FLOURISH_HEART := """<svg xmlns="http://www.w3.org/2000/svg" width="90" height="36" viewBox="0 0 90 36" fill="none">
  <path d="M6 30 C28 32 54 26 70 14 C73 11 71 6 67 8 C64 10 65 16 70 18 C75 20 82 14 84 8" stroke="#ff4769" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M72 17 C70 11 75 6 79 9 C82 6 87 10 84 16 C81 21 75 24 73 25 C72 24 72 20 72 17 Z" stroke="#ff4769" stroke-width="1.6" fill="none"/>
</svg>"""

const PLAY_TRIANGLE := """<svg xmlns="http://www.w3.org/2000/svg" width="20" height="22" viewBox="0 0 20 22">
  <path d="M3 2.5 C3 1.3 4.3 0.6 5.3 1.2 L18.2 9.7 C19.1 10.3 19.1 11.7 18.2 12.3 L5.3 20.8 C4.3 21.4 3 20.7 3 19.5 Z" fill="#ffffff"/>
</svg>"""

const CARD_HEART_EMBLEM := """<svg xmlns="http://www.w3.org/2000/svg" width="28" height="26" viewBox="0 0 28 26">
  <defs>
    <linearGradient id="rg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ff9ebb"/>
      <stop offset="50%" stop-color="#ff2a55"/>
      <stop offset="100%" stop-color="#8c0624"/>
    </linearGradient>
  </defs>
  <path d="M14 24 C14 24 2 16 2 8.5 C2 4.5 5.2 2 8.8 2 C11.2 2 13 3.4 14 5.2 C15 3.4 16.8 2 19.2 2 C22.8 2 26 4.5 26 8.5 C26 16 14 24 14 24 Z" fill="url(#rg)"/>
</svg>"""

const SIDE_CARD_BACK := """<svg xmlns="http://www.w3.org/2000/svg" width="160" height="236" viewBox="0 0 160 236">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#4e081a"/>
      <stop offset="100%" stop-color="#1b0208"/>
    </linearGradient>
    <pattern id="pat" width="26" height="26" patternUnits="userSpaceOnUse">
      <path d="M13 1 L25 13 L13 25 L1 13 Z" fill="none" stroke="#ff6e8c" stroke-opacity="0.25" stroke-width="0.9"/>
      <path d="M13 17.5 C13 17.5 9 14.2 9 11.4 C9 9.7 10.3 8.6 11.6 8.6 C12.4 8.6 13 9.2 13 9.8 C13 9.2 13.6 8.6 14.4 8.6 C15.7 8.6 17 9.7 17 11.4 C17 14.2 13 17.5 13 17.5 Z" fill="none" stroke="#ff99b0" stroke-opacity="0.32" stroke-width="0.85"/>
    </pattern>
  </defs>
  <rect width="160" height="236" rx="12" fill="url(#bg)"/>
  <rect x="7" y="7" width="146" height="222" rx="8" fill="url(#pat)" stroke="#ffbaa0" stroke-opacity="0.55" stroke-width="1.2"/>
  <rect x="12" y="12" width="136" height="212" rx="6" fill="none" stroke="#ff6b8b" stroke-opacity="0.32" stroke-width="0.9"/>
  <path d="M80 136 C80 136 60 122 60 109 C60 102 65.5 97.5 72 97.5 C76 97.5 78.8 99.8 80 102.5 C81.2 99.8 84 97.5 88 97.5 C94.5 97.5 100 102 100 109 C100 122 80 136 80 136 Z" fill="#e6194b" fill-opacity="0.45" stroke="#ff8da6" stroke-width="2.0"/>
</svg>"""

const WHEEL_DISC_SVG := """<svg xmlns="http://www.w3.org/2000/svg" width="220" height="220" viewBox="0 0 220 220">
  <circle cx="110" cy="110" r="106" fill="#1b0208" stroke="#ffd8c2" stroke-width="4"/>
  <path d="M110 110 L110 8 A102 102 0 0 1 198.3 59 Z" fill="#d81845" stroke="#ffd8c2" stroke-width="1.5"/>
  <path d="M110 110 L198.3 59 A102 102 0 0 1 198.3 161 Z" fill="#6b061e" stroke="#ffd8c2" stroke-width="1.5"/>
  <path d="M110 110 L198.3 161 A102 102 0 0 1 110 212 Z" fill="#b81139" stroke="#ffd8c2" stroke-width="1.5"/>
  <path d="M110 110 L110 212 A102 102 0 0 1 21.7 161 Z" fill="#4a0415" stroke="#ffd8c2" stroke-width="1.5"/>
  <path d="M110 110 L21.7 161 A102 102 0 0 1 21.7 59 Z" fill="#9e0b2f" stroke="#ffd8c2" stroke-width="1.5"/>
  <path d="M110 110 L21.7 59 A102 102 0 0 1 110 8 Z" fill="#3a0310" stroke="#ffd8c2" stroke-width="1.5"/>
  <circle cx="110" cy="14" r="3.5" fill="#fff0dc"/>
  <circle cx="193" cy="62" r="3.5" fill="#fff0dc"/>
  <circle cx="193" cy="158" r="3.5" fill="#fff0dc"/>
  <circle cx="110" cy="206" r="3.5" fill="#fff0dc"/>
  <circle cx="27" cy="158" r="3.5" fill="#fff0dc"/>
  <circle cx="27" cy="62" r="3.5" fill="#fff0dc"/>
  <circle cx="110" cy="110" r="22" fill="#1a0208" stroke="#ffd8c2" stroke-width="3"/>
  <path d="M110 119 C110 119 100 112 100 106 C100 103 102.5 101 105.5 101 C107.5 101 109 102 110 103.5 C111 102 112.5 101 114.5 101 C117.5 101 120 103 120 106 C120 112 110 119 110 119 Z" fill="#ff2a55"/>
</svg>"""

const WHEEL_NEEDLE_SVG := """<svg xmlns="http://www.w3.org/2000/svg" width="28" height="32" viewBox="0 0 28 32">
  <polygon points="14,30 2,4 26,4" fill="#ffd8c2" stroke="#5a061b" stroke-width="2"/>
</svg>"""

const GOLDEN_ENVELOPE_SVG := """<svg xmlns="http://www.w3.org/2000/svg" width="84" height="64" viewBox="0 0 84 64" fill="none">
  <defs>
    <linearGradient id="eg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#fff0dc"/>
      <stop offset="50%" stop-color="#f4c430"/>
      <stop offset="100%" stop-color="#9c6b10"/>
    </linearGradient>
  </defs>
  <rect x="4" y="8" width="76" height="48" rx="7" fill="#2a0510" stroke="url(#eg)" stroke-width="2.5"/>
  <path d="M5 10 L42 36 L79 10" stroke="url(#eg)" stroke-width="2.2" fill="rgba(255, 200, 150, 0.1)"/>
  <circle cx="42" cy="34" r="10" fill="#d81845" stroke="#fff0dc" stroke-width="1.8"/>
  <path d="M42 39 C42 39 36 35 36 31.5 C36 29.8 37.5 28.5 39.2 28.5 C40.5 28.5 41.4 29.2 42 30.2 C42.6 29.2 43.5 28.5 44.8 28.5 C46.5 28.5 48 29.8 48 31.5 C48 35 42 39 42 39 Z" fill="#fff0dc"/>
</svg>"""

const NAV_HOME := """<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff5f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9.5L12 3l9 6.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1V9.5z"/></svg>"""
const NAV_PLAY := """<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff5f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="12" height="16" rx="2" transform="rotate(-8 9 12)"/><rect x="9" y="4" width="12" height="16" rx="2" transform="rotate(8 15 12)"/></svg>"""
const NAV_CATS := """<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff5f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>"""
const NAV_COUPLE := """<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff5f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>"""
const NAV_SETTINGS := """<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#fff5f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>"""
const ICON_SOUND := """<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff5f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/></svg>"""
const ICON_FULLSCREEN := """<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff5f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"/></svg>"""

const CAT_1_FLAME := """<svg xmlns="http://www.w3.org/2000/svg" width="44" height="44" viewBox="0 0 48 48" fill="none">
  <defs>
    <linearGradient id="ng" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#fff0dc"/>
      <stop offset="50%" stop-color="#ffb899"/>
      <stop offset="100%" stop-color="#ff5e7e"/>
    </linearGradient>
  </defs>
  <path d="M25 5 C25 5 39 15 39 28 C39 37 32 43 24 43 C16 43 9 37 9 28 C9 21 13.5 15 17 12 C17 12 15.5 18.5 19.5 20.5 C18 13.5 25 5 25 5 Z" fill="url(#ng)"/>
  <path d="M24 43 C19.5 43 16.5 39.5 16.5 34.5 C16.5 30 21 26 24 22 C27 26 31.5 30 31.5 34.5 C31.5 39.5 28.5 43 24 43 Z" fill="#3a0615"/>
</svg>"""

const CAT_2_LIPS := """<svg xmlns="http://www.w3.org/2000/svg" width="50" height="40" viewBox="0 0 56 42" fill="none">
  <defs>
    <linearGradient id="lg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#ff9ebb"/>
      <stop offset="50%" stop-color="#ff2e5b"/>
      <stop offset="100%" stop-color="#8c0624"/>
    </linearGradient>
  </defs>
  <path d="M4 21 C11 11 19 9 24 14 C26 16 30 16 32 14 C37 9 45 11 52 21 C42 19 35 20 28 20 C21 20 14 19 4 21 Z" fill="url(#lg)"/>
  <path d="M4 21 C13 23 20 24 28 24 C36 24 43 23 52 21 C45 32 36 36 28 36 C20 36 11 32 4 21 Z" fill="url(#lg)"/>
  <path d="M16 27 C21 30 28 30 34 27" stroke="#ffffff" stroke-opacity="0.55" stroke-width="2" stroke-linecap="round"/>
</svg>"""

const CAT_3_HEARTS := """<svg xmlns="http://www.w3.org/2000/svg" width="50" height="42" viewBox="0 0 56 46" fill="none">
  <path d="M22 36 C22 36 6 25 6 14 C6 8.5 10.5 4.5 15.5 4.5 C18.8 4.5 21 6.5 22 8.8 C23 6.5 25.2 4.5 28.5 4.5 C33.5 4.5 38 8.5 38 14 C38 25 22 36 22 36 Z" stroke="#ffd8c2" stroke-width="2.4" fill="#ff5078" fill-opacity="0.16"/>
  <path d="M37 40 C37 40 25 31 25 22.5 C25 18 28.5 15 32.5 15 C35 15 36.5 16.5 37 18 C37.5 16.5 39 15 41.5 15 C45.5 15 49 18 49 22.5 C49 31 37 40 37 40 Z" stroke="#ffd8c2" stroke-width="2.2" fill="#ff5078" fill-opacity="0.28"/>
</svg>"""

const CAT_4_DICE := """<svg xmlns="http://www.w3.org/2000/svg" width="44" height="44" viewBox="0 0 48 48" fill="none" stroke="#ffd8c2" stroke-width="2.1" stroke-linejoin="round">
  <polygon points="24,4 42,14 42,34 24,44 6,34 6,14" fill="#ff466e" fill-opacity="0.16"/>
  <polyline points="6,14 24,24 42,14"/>
  <line x1="24" y1="24" x2="24" y2="44"/>
  <circle cx="24" cy="14" r="2.2" fill="#ffd8c2" stroke="none"/>
  <circle cx="13" cy="24" r="1.8" fill="#ffd8c2" stroke="none"/>
  <circle cx="17" cy="32" r="1.8" fill="#ffd8c2" stroke="none"/>
  <circle cx="30" cy="24" r="1.7" fill="#ffd8c2" stroke="none"/>
  <circle cx="33" cy="30" r="1.7" fill="#ffd8c2" stroke="none"/>
  <circle cx="36" cy="35" r="1.7" fill="#ffd8c2" stroke="none"/>
</svg>"""

const CAT_5_LOCK := """<svg xmlns="http://www.w3.org/2000/svg" width="44" height="44" viewBox="0 0 48 48" fill="none">
  <path d="M16 21 V15 C16 10 19.5 6.5 24 6.5 C28.5 6.5 32 10 32 15 V21" stroke="#ffd8c2" stroke-width="3" stroke-linecap="round"/>
  <rect x="11" y="21" width="26" height="21" rx="5" fill="#d81845" stroke="#ffd8c2" stroke-width="1.6"/>
  <circle cx="24" cy="30" r="2.5" fill="#2b030d"/>
  <path d="M24 32 V36" stroke="#2b030d" stroke-width="2.5" stroke-linecap="round"/>
</svg>"""

const EMBER_DOT_SVG := """<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
  <defs>
    <radialGradient id="eg" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#fff4e0" stop-opacity="1.0"/>
      <stop offset="45%" stop-color="#ff8a5b" stop-opacity="0.75"/>
      <stop offset="100%" stop-color="#ff2a55" stop-opacity="0.0"/>
    </radialGradient>
  </defs>
  <circle cx="12" cy="12" r="12" fill="url(#eg)"/>
</svg>"""

const ICON_CHECK := """<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>"""

const ICON_CROSS := """<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#ff9ebb" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>"""

const BTN_JEWEL_PRIMARY := """<svg xmlns="http://www.w3.org/2000/svg" width="260" height="62" viewBox="0 0 260 62">
  <defs>
    <linearGradient id="jg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#ff6b8b"/>
      <stop offset="35%" stop-color="#e81748"/>
      <stop offset="100%" stop-color="#7a0623"/>
    </linearGradient>
    <linearGradient id="jrim" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#ffe4d6"/>
      <stop offset="50%" stop-color="#ff8da6"/>
      <stop offset="100%" stop-color="#ffd0b8"/>
    </linearGradient>
    <linearGradient id="jshine" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.42"/>
      <stop offset="100%" stop-color="#ffffff" stop-opacity="0.0"/>
    </linearGradient>
  </defs>
  <rect x="2" y="2" width="256" height="58" rx="29" fill="url(#jg)" stroke="url(#jrim)" stroke-width="2.4"/>
  <rect x="14" y="5" width="232" height="22" rx="11" fill="url(#jshine)"/>
</svg>"""

const BTN_JEWEL_HOVER := """<svg xmlns="http://www.w3.org/2000/svg" width="260" height="62" viewBox="0 0 260 62">
  <defs>
    <linearGradient id="jgh" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#ff85a0"/>
      <stop offset="40%" stop-color="#ff2457"/>
      <stop offset="100%" stop-color="#9e0b30"/>
    </linearGradient>
    <linearGradient id="jshine2" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.55"/>
      <stop offset="100%" stop-color="#ffffff" stop-opacity="0.0"/>
    </linearGradient>
  </defs>
  <rect x="2" y="2" width="256" height="58" rx="29" fill="url(#jgh)" stroke="#fff0e6" stroke-width="2.6"/>
  <rect x="14" y="5" width="232" height="24" rx="12" fill="url(#jshine2)"/>
</svg>"""

const CARD_GOLD_DIVIDER_SVG := """<svg xmlns="http://www.w3.org/2000/svg" width="340" height="26" viewBox="0 0 340 26" fill="none">
  <defs>
    <linearGradient id="dg" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#ffd8c2" stop-opacity="0.0"/>
      <stop offset="35%" stop-color="#ffd8c2" stop-opacity="0.75"/>
      <stop offset="50%" stop-color="#fff4e6" stop-opacity="1.0"/>
      <stop offset="65%" stop-color="#ffd8c2" stop-opacity="0.75"/>
      <stop offset="100%" stop-color="#ffd8c2" stop-opacity="0.0"/>
    </linearGradient>
  </defs>
  <line x1="8" y1="13" x2="148" y2="13" stroke="url(#dg)" stroke-width="1.5"/>
  <line x1="192" y1="13" x2="332" y2="13" stroke="url(#dg)" stroke-width="1.5"/>
  <polygon points="154,13 158,9 162,13 158,17" fill="#ffd8c2" fill-opacity="0.75"/>
  <polygon points="178,13 182,9 186,13 182,17" fill="#ffd8c2" fill-opacity="0.75"/>
  <path d="M170 21 C170 21 161 15 161 9.5 C161 6.8 163.2 5 165.8 5 C167.6 5 169 6 170 7.5 C171 6 172.4 5 174.2 5 C176.8 5 179 6.8 179 9.5 C179 15 170 21 170 21 Z" fill="#ff2a55" stroke="#ffe4d6" stroke-width="1.4"/>
</svg>"""

const DIE_CRIMSON_BG := """<svg xmlns="http://www.w3.org/2000/svg" width="154" height="154" viewBox="0 0 154 154">
  <defs>
    <linearGradient id="dcg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#9e0b32"/>
      <stop offset="50%" stop-color="#520418"/>
      <stop offset="100%" stop-color="#24010a"/>
    </linearGradient>
    <linearGradient id="dsh" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.28"/>
      <stop offset="100%" stop-color="#ffffff" stop-opacity="0.0"/>
    </linearGradient>
  </defs>
  <rect x="4" y="4" width="146" height="146" rx="28" fill="url(#dcg)" stroke="#ffd8b8" stroke-width="3.2"/>
  <rect x="12" y="12" width="130" height="130" rx="21" fill="none" stroke="#ff8da6" stroke-opacity="0.38" stroke-width="1.2"/>
  <rect x="16" y="10" width="122" height="44" rx="18" fill="url(#dsh)"/>
  <circle cx="24" cy="24" r="3.8" fill="#ffd8b8"/>
  <circle cx="130" cy="24" r="3.8" fill="#ffd8b8"/>
  <circle cx="24" cy="130" r="3.8" fill="#ffd8b8"/>
  <circle cx="130" cy="130" r="3.8" fill="#ffd8b8"/>
</svg>"""

const DIE_OBSIDIAN_BG := """<svg xmlns="http://www.w3.org/2000/svg" width="154" height="154" viewBox="0 0 154 154">
  <defs>
    <linearGradient id="dog" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#380818"/>
      <stop offset="50%" stop-color="#1a030b"/>
      <stop offset="100%" stop-color="#0a0104"/>
    </linearGradient>
    <linearGradient id="dsh2" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.22"/>
      <stop offset="100%" stop-color="#ffffff" stop-opacity="0.0"/>
    </linearGradient>
  </defs>
  <rect x="4" y="4" width="146" height="146" rx="28" fill="url(#dog)" stroke="#f5c690" stroke-width="3.2"/>
  <rect x="12" y="12" width="130" height="130" rx="21" fill="none" stroke="#ffd8b8" stroke-opacity="0.30" stroke-width="1.2"/>
  <rect x="16" y="10" width="122" height="44" rx="18" fill="url(#dsh2)"/>
  <circle cx="24" cy="24" r="3.8" fill="#f5c690"/>
  <circle cx="130" cy="24" r="3.8" fill="#f5c690"/>
  <circle cx="24" cy="130" r="3.8" fill="#f5c690"/>
  <circle cx="130" cy="130" r="3.8" fill="#f5c690"/>
</svg>"""

const DIE_ACT_BITE := """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="44" viewBox="0 0 48 44" fill="none">
  <path d="M6 18 C14 8 34 8 42 18 C34 32 14 32 6 18 Z" fill="#ff2e5b" stroke="#ffd8c2" stroke-width="2"/>
  <polygon points="16,15 19,23 22,15" fill="#fff5f7"/>
  <polygon points="26,15 29,23 32,15" fill="#fff5f7"/>
</svg>"""

const DIE_ACT_WHISPER := """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="44" viewBox="0 0 48 44" fill="none" stroke="#ffd8c2" stroke-width="2.4" stroke-linecap="round">
  <path d="M10 22 C14 16 14 28 10 22"/>
  <path d="M20 15 C26 19 26 25 20 29"/>
  <path d="M28 10 C37 16 37 28 28 34" stroke="#ff5e7e"/>
  <path d="M36 6 C46 14 46 30 36 38" stroke="#ff2e5b"/>
</svg>"""

const DIE_ACT_FEATHER := """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="44" viewBox="0 0 48 44" fill="none">
  <path d="M38 6 C24 6 12 18 10 34 C24 32 38 20 38 6 Z" fill="#ff476e" fill-opacity="0.35" stroke="#ffd8c2" stroke-width="2.2"/>
  <path d="M8 38 L34 12" stroke="#fff0dc" stroke-width="2.2" stroke-linecap="round"/>
</svg>"""

const DIE_ZONE_NECK := """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="44" viewBox="0 0 48 44" fill="none" stroke="#ffd8c2" stroke-width="2.3" stroke-linecap="round">
  <path d="M16 8 C18 18 16 28 10 36"/>
  <path d="M32 8 C30 18 32 28 38 36"/>
  <circle cx="24" cy="22" r="4" fill="#ff2e5b" stroke="none"/>
</svg>"""

const DIE_ZONE_EAR := """<svg xmlns="http://www.w3.org/2000/svg" width="48" height="44" viewBox="0 0 48 44" fill="none" stroke="#ffd8c2" stroke-width="2.3" stroke-linecap="round">
  <path d="M18 12 C18 6 32 6 32 18 C32 28 24 30 22 36 C18 38 14 34 16 28"/>
  <path d="M22 16 C26 16 26 24 22 24" stroke="#ff5e7e"/>
</svg>"""

static func get_dice_action_svg(idx: int) -> String:
	match idx % 6:
		0: return CAT_2_LIPS
		1: return DIE_ACT_BITE
		2: return DIE_ACT_WHISPER
		3: return DIE_ACT_FEATHER
		4: return CAT_1_FLAME
		5: return DIE_ACT_WHISPER
	return CAT_2_LIPS

static func get_dice_zone_svg(idx: int) -> String:
	match idx % 6:
		0: return DIE_ZONE_NECK
		1: return CAT_2_LIPS
		2: return DIE_ZONE_EAR
		3: return CAT_3_HEARTS
		4: return DIE_ACT_FEATHER
		5: return CAT_1_FLAME
	return DIE_ZONE_NECK

static func get_category_svg(cat_idx: int) -> String:
	match cat_idx:
		1: return CAT_1_FLAME
		2: return CAT_2_LIPS
		3: return CAT_3_HEARTS
		4: return CAT_4_DICE
		5: return CAT_5_LOCK
	return CAT_1_FLAME
