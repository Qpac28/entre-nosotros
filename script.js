// Cartas en Pareja · Entre Nosotros — Luxury Edition Controller

const AudioFX = (() => {
  let ctx = null;
  let muted = false;

  function ensure() {
    if (muted) return null;
    const AC = window.AudioContext || window.webkitAudioContext;
    if (!AC) return null;
    if (!ctx) ctx = new AC();
    if (ctx.state === "suspended") ctx.resume().catch(() => {});
    return ctx;
  }

  function chime(f1, f2, dur = 0.16, gain = 0.09) {
    const c = ensure();
    if (!c) return;
    const now = c.currentTime;
    const osc = c.createOscillator();
    const g = c.createGain();
    osc.type = "sine";
    osc.frequency.setValueAtTime(f1, now);
    osc.frequency.exponentialRampToValueAtTime(f2, now + dur);
    g.gain.setValueAtTime(0.0001, now);
    g.gain.exponentialRampToValueAtTime(gain, now + 0.025);
    g.gain.exponentialRampToValueAtTime(0.0001, now + dur);
    osc.connect(g).connect(c.destination);
    osc.start(now);
    osc.stop(now + dur + 0.02);
  }

  return {
    cardFlip: () => chime(320, 560, 0.12, 0.07),
    complete: () => {
      chime(440, 659.25, 0.16, 0.09);
      setTimeout(() => chime(659.25, 880, 0.22, 0.08), 85);
    },
    pass: () => chime(310, 185, 0.14, 0.07),
    dice: () => {
      chime(580, 290, 0.07, 0.08);
      setTimeout(() => chime(740, 380, 0.09, 0.08), 110);
    },
    isMuted: () => muted,
    toggle: () => {
      muted = !muted;
      return muted;
    }
  };
})();

const CATEGORY_SVGS = {
  1: `<svg viewBox="0 0 48 48" fill="none"><path d="M25 5 C25 5 39 15 39 28 C39 37 32 43 24 43 C16 43 9 37 9 28 C9 21 13.5 15 17 12 C17 12 15.5 18.5 19.5 20.5 C18 13.5 25 5 25 5 Z" fill="url(#neonGold)"/><path d="M24 43 C19.5 43 16.5 39.5 16.5 34.5 C16.5 30 21 26 24 22 C27 26 31.5 30 31.5 34.5 C31.5 39.5 28.5 43 24 43 Z" fill="#3a0615"/></svg>`,
  2: `<svg viewBox="0 0 56 42" fill="none"><path d="M4 21 C11 11 19 9 24 14 C26 16 30 16 32 14 C37 9 45 11 52 21 C42 19 35 20 28 20 C21 20 14 19 4 21 Z" fill="url(#lipsGrad)"/><path d="M4 21 C13 23 20 24 28 24 C36 24 43 23 52 21 C45 32 36 36 28 36 C20 36 11 32 4 21 Z" fill="url(#lipsGrad)"/></svg>`,
  3: `<svg viewBox="0 0 56 46" fill="none"><path d="M22 36 C22 36 6 25 6 14 C6 8.5 10.5 4.5 15.5 4.5 C18.8 4.5 21 6.5 22 8.8 C23 6.5 25.2 4.5 28.5 4.5 C33.5 4.5 38 8.5 38 14 C38 25 22 36 22 36 Z" stroke="url(#neonGold)" stroke-width="2.4" fill="rgba(255, 80, 120, 0.2)"/><path d="M37 40 C37 40 25 31 25 22.5 C25 18 28.5 15 32.5 15 C35 15 36.5 16.5 37 18 C37.5 16.5 39 15 41.5 15 C45.5 15 49 18 49 22.5 C49 31 37 40 37 40 Z" stroke="url(#neonGold)" stroke-width="2.2" fill="rgba(255, 80, 120, 0.3)"/></svg>`,
  4: `<svg viewBox="0 0 48 48" fill="none" stroke="url(#neonGold)" stroke-width="2.2" stroke-linejoin="round"><polygon points="24,4 42,14 42,34 24,44 6,34 6,14" fill="rgba(255, 70, 110, 0.18)"/><polyline points="6,14 24,24 42,14"/><line x1="24" y1="24" x2="24" y2="44"/><circle cx="24" cy="14" r="2.2" fill="#ffd8c2" stroke="none"/></svg>`,
  5: `<svg viewBox="0 0 48 48" fill="none"><path d="M16 21 V15 C16 10 19.5 6.5 24 6.5 C28.5 6.5 32 10 32 15 V21" stroke="url(#neonGold)" stroke-width="3" stroke-linecap="round"/><rect x="11" y="21" width="26" height="21" rx="5" fill="url(#rubyGlow)" stroke="url(#neonGold)" stroke-width="1.5"/><circle cx="24" cy="30" r="2.5" fill="#2b030d"/></svg>`
};

const TEXTS = {
  es: {
    brandTagline: "EL JUEGO QUE ENCIENDE LA CONEXIÓN",
    heroTitle: "¿Listos para jugar?",
    heroSubtitle: "Retos, seducción y mucha complicidad...",
    navHome: "Inicio",
    navPlay: "Jugar",
    navCats: "Categorías",
    navCouple: "Pareja",
    navSettings: "Ajustes",
    mainPlayBtn: "Jugar ahora",
    howToTitle: "Cómo jugar",
    step1: "Elijan una categoría.",
    step2: "Roben una carta por turno.",
    step3: "Cumplan el reto... <strong>¡y disfruten!</strong>",
    btnQuickDice: "Dados de Seducción",
    btnQuickWheel: "Ruleta de Castigo",
    chooseCat: "Elige una categoría",
    cats: {
      1: { title: "Calentamiento", sub: "Rompe el hielo" },
      2: { title: "Seducción", sub: "Provoca y disfruta" },
      3: { title: "Intimidad", sub: "Conecta más profundo" },
      4: { title: "Retos Atrevidos", sub: "¿Se atreven?" },
      5: { title: "Sin Límites", sub: "Solo para parejas sin tabúes" }
    },
    types: { Truth: "VERDAD", Dare: "RETO", Drink: "BRINDIS", Dice: "DADOS" },
    turnOf: "Turno de ",
    heatLabel: "Complicidad",
    passesLeft: " Pases",
    twistBtn: "+ Subir el tono",
    passBtn: "Cambiar carta",
    doneBtn: "¡Reto cumplido!",
    stampDone: "CUMPLIDO",
    stampPass: "PASAR",
    diceTitle: "Dados de Seducción",
    diceSub: "Lanza los dados y cumplan la combinación",
    wheelTitle: "Ruleta de Castigo",
    wheelSub: "Gira la ruleta para descubrir tu penitencia",
    rollAgain: "Lanzar de nuevo",
    spinAgain: "Girar ruleta",
    backTable: "Volver a la mesa",
    coupleTitle: "Nuestra Pareja",
    coupleSub: "Personalicen sus nombres para los turnos",
    p1Default: "Jugador 1",
    p2Default: "Jugador 2",
    saveCouple: "Guardar y jugar",
    settingsTitle: "Ajustes",
    settingsSub: "Configura la experiencia a su medida",
    setLangLabel: "Idioma",
    setLangVal: "Español",
    setDrinksLabel: "Retos con brindis / copa",
    setSoundLabel: "Efectos de sonido",
    on: "Activado",
    off: "Desactivado",
    ready: "Listo"
  },
  en: {
    brandTagline: "THE GAME THAT IGNITES CONNECTION",
    heroTitle: "Ready to play?",
    heroSubtitle: "Dares, seduction, and deep complicity...",
    navHome: "Home",
    navPlay: "Play",
    navCats: "Categories",
    navCouple: "Couple",
    navSettings: "Settings",
    mainPlayBtn: "Play now",
    howToTitle: "How to play",
    step1: "Choose a category.",
    step2: "Draw one card per turn.",
    step3: "Complete the dare... <strong>and enjoy!</strong>",
    btnQuickDice: "Seduction Dice",
    btnQuickWheel: "Penalty Wheel",
    chooseCat: "Choose a category",
    cats: {
      1: { title: "Warm-Up", sub: "Break the ice" },
      2: { title: "Seduction", sub: "Tease and enjoy" },
      3: { title: "Intimacy", sub: "Connect deeper" },
      4: { title: "Bold Dares", sub: "Do you dare?" },
      5: { title: "No Limits", sub: "For couples without taboos" }
    },
    types: { Truth: "TRUTH", Dare: "DARE", Drink: "TOAST", Dice: "DICE" },
    turnOf: "Turn: ",
    heatLabel: "Connection",
    passesLeft: " Passes",
    twistBtn: "+ Raise the heat",
    passBtn: "Skip card",
    doneBtn: "Completed!",
    stampDone: "DONE",
    stampPass: "SKIP",
    diceTitle: "Seduction Dice",
    diceSub: "Roll the dice and perform the combination",
    wheelTitle: "Penalty Wheel",
    wheelSub: "Spin the wheel to reveal your forfeit",
    rollAgain: "Roll again",
    spinAgain: "Spin wheel",
    backTable: "Back to table",
    coupleTitle: "Our Couple",
    coupleSub: "Customize your names for each turn",
    p1Default: "Partner 1",
    p2Default: "Partner 2",
    saveCouple: "Save & play",
    settingsTitle: "Settings",
    settingsSub: "Tailor the experience to your liking",
    setLangLabel: "Language",
    setLangVal: "English",
    setDrinksLabel: "Toast / Drink prompts",
    setSoundLabel: "Sound effects",
    on: "Enabled",
    off: "Muted",
    ready: "Done"
  }
};

const DICE_ACTIONS = [
  { es: "Besar lento", en: "Slow kiss" },
  { es: "Acariciar suave", en: "Soft caress" },
  { es: "Susurrar en", en: "Whisper on" },
  { es: "Mordisquear", en: "Gently nibble" },
  { es: "Soplar / Hielo", en: "Blow / Ice on" },
  { es: "Recorrer con labios", en: "Trace with lips" }
];

const DICE_ZONES = [
  { es: "El cuello (15s)", en: "The neck (15s)" },
  { es: "Los labios (15s)", en: "The lips (15s)" },
  { es: "La oreja (15s)", en: "The ear (15s)" },
  { es: "La espalda (20s)", en: "The back (20s)" },
  { es: "Las muñecas", en: "The wrists" },
  { es: "Donde tú elijas", en: "Your choice" }
];

const WHEEL_SEGMENTS = [
  { color: "#d81845", es: "Beso apasionado de 20 segundos", en: "20-second passionate kiss" },
  { color: "#7d0926", es: "Tu pareja manda por 1 minuto", en: "Your partner commands for 1 minute" },
  { color: "#b81139", es: "Quítate una prenda a elección", en: "Remove one item of clothing" },
  { color: "#520518", es: "Brindis mirándose a los ojos", en: "Toast while holding eye contact" },
  { color: "#9e0b2f", es: "Masaje sensual de 30 segundos", en: "30-second sensual massage" },
  { color: "#3d0312", es: "Tira los Dados de Seducción", en: "Roll the Seduction Dice" }
];

// Ultra-concise, 1-sentence prompts per category (1..5)
const DECK = [
  // 1. Calentamiento (Rompe el hielo)
  { cat: 1, type: "Truth", time: 0, es: "¿Qué fue lo primero que te atrajo de mí cuando nos conocimos?", en: "What first attracted you to me when we met?", twist_es: "Dilo mirándome a un centímetro de los labios.", twist_en: "Say it an inch from my lips." },
  { cat: 1, type: "Dare", time: 20, es: "Mírense fijo a los ojos durante 20 segundos sin reírse.", en: "Hold unbroken eye contact for 20 seconds without laughing.", twist_es: "Quien sonría primero da un beso lento.", twist_en: "First to smile owes a slow kiss." },
  { cat: 1, type: "Dare", time: 20, es: "Dibuja un corazón en su palma con la yema del dedo muy despacio.", en: "Trace a slow heart on their palm with your fingertip.", twist_es: "Termina con un beso en su muñeca.", twist_en: "Finish with a kiss on their wrist." },
  { cat: 1, type: "Drink", time: 0, es: "Brinden por esta noche y tomen un sorbo sin apartar la mirada.", en: "Toast to tonight and take a sip without breaking eye contact.", twist_es: "Séllenlo con un beso.", twist_en: "Seal the toast with a kiss." },
  { cat: 1, type: "Truth", time: 0, es: "Dime tres cosas de mí que te encantan en secreto.", en: "Tell me three things about me you secretly adore.", twist_es: "Susúrralas directamente en mi oído.", twist_en: "Whisper them directly in my ear." },
  { cat: 1, type: "Dare", time: 30, es: "Bailen lento abrazados durante 30 segundos, con o sin música.", en: "Slow dance close together for 30 seconds, with or without music.", twist_es: "Mantengan las frentes juntas.", twist_en: "Keep your foreheads touching." },
  { cat: 1, type: "Dare", time: 15, es: "Acaricia su cabello y mejilla suavemente durante 15 segundos.", en: "Gently caress their hair and cheek for 15 seconds.", twist_es: "Tu pareja mantiene los ojos cerrados.", twist_en: "Your partner keeps their eyes closed." },

  // 2. Seducción (Provoca y disfruta)
  { cat: 2, type: "Dare", time: 25, es: "Besa lentamente desde su mandíbula hasta la clavícula.", en: "Kiss slowly from their jawline down to their collarbone.", twist_es: "Tu pareja no puede moverse ni hablar.", twist_en: "Your partner cannot move or speak." },
  { cat: 2, type: "Truth", time: 0, es: "¿Qué caricia mía te enciende en menos de cinco segundos?", en: "What touch of mine turns you on in under five seconds?", twist_es: "Guía mi mano para hacerlo ahora mismo.", twist_en: "Guide my hand to do it right now." },
  { cat: 2, type: "Dare", time: 20, es: "Quédate a un milímetro de sus labios durante 20 segundos sin besar.", en: "Hover a millimeter from their lips for 20 seconds without kissing.", twist_es: "Al terminar el tiempo, bésense sin freno.", twist_en: "When time is up, kiss passionately." },
  { cat: 2, type: "Drink", time: 0, es: "Toma tu próximo sorbo sentado/a sobre el regazo de tu pareja.", en: "Take your next sip sitting on your partner's lap.", twist_es: "Quédate ahí durante el siguiente turno.", twist_en: "Stay there for the next turn." },
  { cat: 2, type: "Dare", time: 30, es: "Dale un masaje lento en el cuello y hombros respirando cerca de su oído.", en: "Give a slow neck massage while breathing close to their ear.", twist_es: "Termina mordisqueando suavemente su oreja.", twist_en: "End by gently nibbling their earlobe." },
  { cat: 2, type: "Truth", time: 0, es: "¿Qué prenda mía tienes más ganas de quitarme esta noche?", en: "Which piece of my clothing do you want to remove first tonight?", twist_es: "Desliza tus dedos por esa prenda ahora.", twist_en: "Run your fingers along that item now." },

  // 3. Intimidad (Conecta más profundo)
  { cat: 3, type: "Truth", time: 0, es: "¿Cuál es el recuerdo más apasionado que tienes de nosotros dos?", en: "What is your most passionate memory of the two of us?", twist_es: "Recrea los primeros diez segundos ahora.", twist_en: "Recreate the first ten seconds right now." },
  { cat: 3, type: "Dare", time: 30, es: "Con los ojos cerrados, explora su rostro y cuello solo con tus labios.", en: "With eyes closed, explore their face and neck using only your lips.", twist_es: "Silencio absoluto durante los 30 segundos.", twist_en: "Complete silence for all 30 seconds." },
  { cat: 3, type: "Truth", time: 0, es: "¿Prefieres llevar el control esta noche o entregármelo por completo?", en: "Do you prefer taking control tonight, or surrendering it to me?", twist_es: "Demuéstralo físicamente en este instante.", twist_en: "Demonstrate it physically right now." },
  { cat: 3, type: "Dare", time: 30, es: "Abrázalo/a por detrás y susúrrale al oído lo que más deseas hoy.", en: "Hold them from behind and whisper what you desire most tonight.", twist_es: "Acaricia sus manos mientras lo dices.", twist_en: "Caress their hands while whispering." },
  { cat: 3, type: "Drink", time: 0, es: "Pasa el borde de tu copa por sus labios antes de compartir un sorbo.", en: "Trace your glass rim across their lips before sharing a slow sip.", twist_es: "Roba el último rastro con un beso.", twist_en: "Steal the last drop with a kiss." },
  { cat: 3, type: "Truth", time: 0, es: "¿Qué palabra te encanta escucharme decir cuando estamos a solas?", en: "What word do you love hearing me whisper when we're alone?", twist_es: "Dímela al oído exactamente como te gusta.", twist_en: "Whisper it in my ear just how you like it." },

  // 4. Retos Atrevidos (¿Se atreven?)
  { cat: 4, type: "Dice", time: 20, es: "Lanza los Dados de Seducción y cumple el reto que marquen.", en: "Roll the Seduction Dice and perform the combination.", twist_es: "Hazlo con los ojos vendados o cerrados.", twist_en: "Do it with your eyes closed." },
  { cat: 4, type: "Dare", time: 0, es: "Quítate una prenda de ropa lentamente manteniendo contacto visual.", en: "Slowly remove one piece of clothing while holding eye contact.", twist_es: "Tu pareja elige qué prenda es.", twist_en: "Your partner chooses which item." },
  { cat: 4, type: "Dare", time: 40, es: "Sujeta suavemente sus muñecas y bésalo/a donde quieras por 40 segundos.", en: "Gently hold their wrists and kiss them anywhere you want for 40s.", twist_es: "Tu pareja no puede mover las manos.", twist_en: "Your partner isn't allowed to move their hands." },
  { cat: 4, type: "Truth", time: 0, es: "Confiesa una fantasía secreta que aún no hayamos cumplido juntos.", en: "Confess a secret fantasy we haven't fulfilled together yet.", twist_es: "Elijan un detalle para probarlo hoy.", twist_en: "Pick one detail from it to try tonight." },
  { cat: 4, type: "Dare", time: 30, es: "Baila de forma sensual para tu pareja durante 30 segundos.", en: "Dance sensually for your partner for 30 seconds.", twist_es: "Tiene prohibido tocarte hasta que acabes.", twist_en: "They aren't allowed to touch you until time's up." },
  { cat: 4, type: "Drink", time: 0, es: "Toma una gota de tu bebida directamente del cuello de tu pareja.", en: "Sip or kiss a drop of your drink off your partner's neck.", twist_es: "Sin usar las manos.", twist_en: "No hands allowed." },

  // 5. Sin Límites 18+ (Solo para parejas sin tabúes)
  { cat: 5, type: "Dare", time: 60, es: "Mando Total: Tienes 1 minuto para pedir tres deseos sin que pueda negarse.", en: "Total Command: You have 1 minute to give three orders they must obey.", twist_es: "Debe pedirte permiso antes de hablar.", twist_en: "They must ask permission before speaking." },
  { cat: 5, type: "Dare", time: 45, es: "Quítale una prenda a tu pareja usando únicamente una mano o los labios.", en: "Remove one item of your partner's clothing using one hand or your lips.", twist_es: "Tómate tu tiempo para provocar.", twist_en: "Take your time to tease them." },
  { cat: 5, type: "Dare", time: 60, es: "El Límite: Provoca a tu pareja con besos y caricias por 1 minuto sin dejar que te toque.", en: "The Edge: Tease your partner with kisses for 1 minute—they cannot touch you.", twist_es: "Si se mueve, el minuto empieza de nuevo.", twist_en: "If they move, the minute restarts." },
  { cat: 5, type: "Truth", time: 0, es: "Dime sin filtros qué es exactamente lo primero que quieres hacer al apagar el juego.", en: "Tell me without filters the very first thing you want to do when this game ends.", twist_es: "Empieza los primeros 20 segundos ahora.", twist_en: "Start the first 20 seconds right now." },
  { cat: 5, type: "Dare", time: 60, es: "Apaguen la luz 1 minuto: solo vale guiarse por el tacto y la respiración.", en: "Lights off for 1 minute: let touch and breathing make all the rules.", twist_es: "Nadie puede decir una sola palabra.", twist_en: "Neither of you may speak a word." }
];

let lang = "es";
let activeCat = 1;
let includeDrinks = true;
let currentTurn = 1;
let playerNames = { 1: "", 2: "" };
let passesLeft = { 1: 3, 2: 3 };
let heatPoints = 2;
const MAX_HEAT = 12;

let drawBags = {};
let currentCard = null;
let timerInterval = null;
let timerRemaining = 0;
let activePropMode = "dice";
let wheelRotation = 0;

function getPlayerName(n) {
  if (playerNames[n] && playerNames[n].trim()) return playerNames[n].trim();
  return n === 1 ? TEXTS[lang].p1Default : TEXTS[lang].p2Default;
}

function getBagForCategory(cat) {
  if (!drawBags[cat] || drawBags[cat].length === 0) {
    let pool = DECK.filter((c) => c.cat === cat && (includeDrinks || c.type !== "Drink"));
    if (pool.length === 0) pool = DECK.filter((c) => c.cat === cat);
    drawBags[cat] = pool.slice();
    for (let i = drawBags[cat].length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [drawBags[cat][i], drawBags[cat][j]] = [drawBags[cat][j], drawBags[cat][i]];
    }
  }
  return drawBags[cat];
}

function switchView(view) {
  const isPlay = view === "play";
  document.getElementById("homeHeroView").style.display = isPlay ? "none" : "flex";
  document.getElementById("activePlayView").style.display = isPlay ? "flex" : "none";
  document.getElementById("navHome").classList.toggle("active", !isPlay);
  document.getElementById("navPlay").classList.toggle("active", isPlay);

  if (isPlay && !currentCard) {
    dealNextCard(true);
  } else {
    AudioFX.cardFlip();
  }
}

function selectCategory(cat) {
  activeCat = cat;
  document.querySelectorAll(".cat-card").forEach((el) => {
    el.classList.toggle("active", parseInt(el.dataset.cat, 10) === cat);
  });

  if (document.getElementById("activePlayView").style.display !== "none") {
    dealNextCard(true);
  } else {
    switchView("play");
    dealNextCard(true);
  }
}

function scrollCategoriesHighlight() {
  const footer = document.getElementById("categoriesFooter");
  footer.style.transform = "scale(1.02)";
  setTimeout(() => { footer.style.transform = "scale(1)"; }, 260);
}

function dealNextCard(keepTurn = false) {
  clearInterval(timerInterval);
  timerInterval = null;

  if (!keepTurn) {
    currentTurn = currentTurn === 1 ? 2 : 1;
  }

  const bag = getBagForCategory(activeCat);
  currentCard = bag.pop();
  timerRemaining = currentCard.time || 0;
  document.getElementById("gameTwistBox").classList.remove("visible");

  AudioFX.cardFlip();

  const cardEl = document.getElementById("activeGameCard");
  cardEl.style.transition = "none";
  cardEl.style.transform = "translateY(14px) scale(0.93)";
  cardEl.style.opacity = "0.35";
  document.getElementById("stampDone").style.opacity = "0";
  document.getElementById("stampPass").style.opacity = "0";

  updateAllTexts();

  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      cardEl.style.transition = "transform 0.34s cubic-bezier(0.2, 0.85, 0.25, 1), opacity 0.25s ease";
      cardEl.style.transform = "translate(0px, 0px) rotate(0deg) scale(1)";
      cardEl.style.opacity = "1";
    });
  });

  if (currentCard.type === "Dice") {
    setTimeout(() => openDiceModal(), 360);
  }
}

function triggerCardAction(dir) {
  const cardEl = document.getElementById("activeGameCard");
  if (dir < 0 && passesLeft[currentTurn] <= 0) {
    cardEl.style.transform = "translate(0px, 0px) rotate(0deg)";
    document.getElementById("stampPass").style.opacity = "0";
    openWheelModal();
    return;
  }

  if (dir > 0) {
    AudioFX.complete();
    document.getElementById("stampDone").style.opacity = "1";
    heatPoints = Math.min(MAX_HEAT, heatPoints + 1);
  } else {
    AudioFX.pass();
    document.getElementById("stampPass").style.opacity = "1";
    passesLeft[currentTurn]--;
  }

  cardEl.style.transition = "transform 0.26s ease-in, opacity 0.24s";
  cardEl.style.transform = `translateX(${dir * 340}px) rotate(${dir * 16}deg)`;
  cardEl.style.opacity = "0";

  setTimeout(() => {
    dealNextCard(false);
  }, 240);
}

// Swipe Gesture on Active Luxury Card
function initCardSwipe() {
  const cardEl = document.getElementById("activeGameCard");
  let dragging = false;
  let startX = 0;
  let dx = 0;

  cardEl.addEventListener("pointerdown", (e) => {
    if (e.target.closest("button")) return;
    dragging = true;
    startX = e.clientX;
    dx = 0;
    cardEl.style.transition = "none";
    cardEl.setPointerCapture(e.pointerId);
  });

  cardEl.addEventListener("pointermove", (e) => {
    if (!dragging) return;
    dx = e.clientX - startX;
    const rot = Math.max(-14, Math.min(14, dx * 0.055));
    cardEl.style.transform = `translateX(${dx}px) rotate(${rot}deg)`;
    document.getElementById("stampDone").style.opacity = String(Math.max(0, Math.min(1, (dx - 24) / 75)));
    document.getElementById("stampPass").style.opacity = String(Math.max(0, Math.min(1, (-dx - 24) / 75)));
  });

  function finishDrag() {
    if (!dragging) return;
    dragging = false;
    if (dx > 90) {
      triggerCardAction(1);
    } else if (dx < -90) {
      triggerCardAction(-1);
    } else {
      cardEl.style.transition = "transform 0.26s cubic-bezier(0.2, 0.85, 0.25, 1)";
      cardEl.style.transform = "translate(0px, 0px) rotate(0deg)";
      document.getElementById("stampDone").style.opacity = "0";
      document.getElementById("stampPass").style.opacity = "0";
    }
  }

  cardEl.addEventListener("pointerup", finishDrag);
  cardEl.addEventListener("pointercancel", finishDrag);
}

function toggleTwist() {
  AudioFX.cardFlip();
  document.getElementById("gameTwistBox").classList.toggle("visible");
}

function toggleTimer() {
  const txtEl = document.getElementById("timerPillText");
  if (timerInterval) {
    clearInterval(timerInterval);
    timerInterval = null;
    txtEl.textContent = `${timerRemaining}s`;
    return;
  }
  if (timerRemaining <= 0) timerRemaining = currentCard ? currentCard.time || 20 : 20;
  AudioFX.cardFlip();
  txtEl.textContent = `${timerRemaining}s`;
  timerInterval = setInterval(() => {
    timerRemaining--;
    if (timerRemaining <= 0) {
      clearInterval(timerInterval);
      timerInterval = null;
      AudioFX.complete();
      txtEl.textContent = lang === "es" ? "¡Tiempo!" : "Time's up!";
    } else {
      txtEl.textContent = `${timerRemaining}s`;
    }
  }, 1000);
}

// ================= MODALS: DICE, WHEEL, COUPLE, SETTINGS =================
function closeModals() {
  document.getElementById("propModal").style.display = "none";
  document.getElementById("coupleModal").style.display = "none";
  document.getElementById("settingsModal").style.display = "none";
}

function openDiceModal() {
  activePropMode = "dice";
  const t = TEXTS[lang];
  document.getElementById("propModalTitle").textContent = t.diceTitle;
  document.getElementById("propModalSub").textContent = t.diceSub;
  document.getElementById("diceStage").style.display = "flex";
  document.getElementById("wheelStage").style.display = "none";
  document.getElementById("propRepeatText").textContent = t.rollAgain;
  document.getElementById("propCloseText").textContent = t.backTable;
  document.getElementById("propModal").style.display = "flex";
  rollLuxuryDice();
}

function rollLuxuryDice() {
  AudioFX.dice();
  const d1 = document.getElementById("luxDie1");
  const d2 = document.getElementById("luxDie2");
  d1.classList.add("rolling");
  d2.classList.add("rolling");
  document.getElementById("propOutcomeBanner").textContent = "...";

  const act = DICE_ACTIONS[Math.floor(Math.random() * DICE_ACTIONS.length)];
  const zone = DICE_ZONES[Math.floor(Math.random() * DICE_ZONES.length)];

  setTimeout(() => {
    d1.classList.remove("rolling");
    d2.classList.remove("rolling");
    document.getElementById("die1Val").textContent = act[lang];
    document.getElementById("die2Val").textContent = zone[lang];
    document.getElementById("propOutcomeBanner").textContent = `${act[lang]} · ${zone[lang]}`;
  }, 460);
}

function openWheelModal() {
  activePropMode = "wheel";
  const t = TEXTS[lang];
  document.getElementById("propModalTitle").textContent = t.wheelTitle;
  document.getElementById("propModalSub").textContent = t.wheelSub;
  document.getElementById("diceStage").style.display = "none";
  document.getElementById("wheelStage").style.display = "block";
  document.getElementById("propRepeatText").textContent = t.spinAgain;
  document.getElementById("propCloseText").textContent = t.backTable;
  document.getElementById("propModal").style.display = "flex";
  renderWheelSVG();
  spinLuxuryWheel();
}

function renderWheelSVG() {
  const n = WHEEL_SEGMENTS.length;
  const step = 360 / n;
  let svg = `<svg width="100%" height="100%" viewBox="0 0 200 200">`;
  WHEEL_SEGMENTS.forEach((seg, i) => {
    const a0 = (i * step * Math.PI) / 180;
    const a1 = ((i + 1) * step * Math.PI) / 180;
    const x0 = 100 + 98 * Math.sin(a0), y0 = 100 - 98 * Math.cos(a0);
    const x1 = 100 + 98 * Math.sin(a1), y1 = 100 - 98 * Math.cos(a1);
    svg += `<path d="M100 100 L${x0.toFixed(1)} ${y0.toFixed(1)} A98 98 0 0 1 ${x1.toFixed(1)} ${y1.toFixed(1)} Z" fill="${seg.color}" stroke="#ffd8c2" stroke-width="1.4"/>`;
  });
  svg += `<circle cx="100" cy="100" r="16" fill="#18030a" stroke="#ffd8c2" stroke-width="3"/></svg>`;
  document.getElementById("wheelDisc").innerHTML = svg;
}

function spinLuxuryWheel() {
  AudioFX.cardFlip();
  const disc = document.getElementById("wheelDisc");
  wheelRotation += 1080 + Math.floor(Math.random() * 720);
  disc.style.transition = "transform 2.3s cubic-bezier(0.12, 0.78, 0.14, 1)";
  disc.style.transform = `rotate(${wheelRotation}deg)`;
  document.getElementById("propOutcomeBanner").textContent = "...";

  setTimeout(() => {
    const seg = WHEEL_SEGMENTS[Math.floor(Math.random() * WHEEL_SEGMENTS.length)];
    AudioFX.complete();
    document.getElementById("propOutcomeBanner").textContent = seg[lang];
  }, 2300);
}

function repeatPropAction() {
  if (activePropMode === "dice") rollLuxuryDice();
  else spinLuxuryWheel();
}

function openCoupleModal() {
  document.getElementById("p1NameInput").value = playerNames[1];
  document.getElementById("p2NameInput").value = playerNames[2];
  document.getElementById("coupleModal").style.display = "flex";
}

function saveCoupleNames() {
  playerNames[1] = document.getElementById("p1NameInput").value.trim();
  playerNames[2] = document.getElementById("p2NameInput").value.trim();
  closeModals();
  updateAllTexts();
}

function openSettingsModal() {
  document.getElementById("settingsModal").style.display = "flex";
  updateAllTexts();
}

function toggleLanguage() {
  lang = lang === "es" ? "en" : "es";
  AudioFX.cardFlip();
  updateAllTexts();
}

function toggleDrinks() {
  includeDrinks = !includeDrinks;
  drawBags = {};
  AudioFX.cardFlip();
  updateAllTexts();
}

function toggleMute() {
  const m = AudioFX.toggle();
  document.getElementById("soundTopBtn").style.opacity = m ? "0.45" : "1";
  updateAllTexts();
}

function toggleFullscreen() {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen().catch(() => {});
  } else {
    document.exitFullscreen().catch(() => {});
  }
}

function updateAllTexts() {
  const t = TEXTS[lang];
  document.getElementById("brandTagline").textContent = t.brandTagline;
  document.getElementById("heroTitle").textContent = t.heroTitle;
  document.getElementById("heroSubtitle").textContent = t.heroSubtitle;
  document.getElementById("langTopBtn").querySelector("span").textContent = lang.toUpperCase();

  document.getElementById("navHomeText").textContent = t.navHome;
  document.getElementById("navPlayText").textContent = t.navPlay;
  document.getElementById("navCatsText").textContent = t.navCats;
  document.getElementById("navCoupleText").textContent = t.navCouple;
  document.getElementById("navSettingsText").textContent = t.navSettings;

  document.getElementById("mainPlayBtnText").textContent = t.mainPlayBtn;
  document.getElementById("howToTitle").textContent = t.howToTitle;
  document.getElementById("step1Text").textContent = t.step1;
  document.getElementById("step2Text").textContent = t.step2;
  document.getElementById("step3Text").innerHTML = t.step3;
  document.getElementById("btnQuickDice").textContent = t.btnQuickDice;
  document.getElementById("btnQuickWheel").textContent = t.btnQuickWheel;
  document.getElementById("chooseCatLabel").textContent = t.chooseCat;

  for (let i = 1; i <= 5; i++) {
    document.getElementById(`cat${i}Title`).textContent = t.cats[i].title;
    document.getElementById(`cat${i}Sub`).textContent = t.cats[i].sub;
  }

  document.getElementById("turnChip").textContent = `${t.turnOf}${getPlayerName(currentTurn)}`;
  document.getElementById("heatLabel").textContent = t.heatLabel;
  document.getElementById("heatBarFill").style.width = `${Math.min(100, (heatPoints / MAX_HEAT) * 100)}%`;
  document.getElementById("passesChip").textContent = `${passesLeft[currentTurn]}${t.passesLeft}`;

  document.getElementById("twistPillText").textContent = t.twistBtn;
  document.getElementById("btnPassText").textContent = t.passBtn;
  document.getElementById("btnDoneText").textContent = t.doneBtn;
  document.getElementById("stampDone").textContent = t.stampDone;
  document.getElementById("stampPass").textContent = t.stampPass;

  document.getElementById("coupleModalTitle").textContent = t.coupleTitle;
  document.getElementById("coupleModalSub").textContent = t.coupleSub;
  document.getElementById("p1Label").textContent = t.p1Default;
  document.getElementById("p2Label").textContent = t.p2Default;
  document.getElementById("saveCoupleText").textContent = t.saveCouple;

  document.getElementById("settingsModalTitle").textContent = t.settingsTitle;
  document.getElementById("settingsModalSub").textContent = t.settingsSub;
  document.getElementById("setLangLabel").textContent = t.setLangLabel;
  document.getElementById("setLangBtn").textContent = t.setLangVal;
  document.getElementById("setDrinksLabel").textContent = t.setDrinksLabel;
  document.getElementById("setDrinksBtn").textContent = includeDrinks ? t.on : t.off;
  document.getElementById("setSoundLabel").textContent = t.setSoundLabel;
  document.getElementById("setSoundBtn").textContent = AudioFX.isMuted() ? t.off : t.on;
  document.getElementById("closeSettingsText").textContent = t.ready;

  if (currentCard) {
    document.getElementById("gameCatPill").textContent = t.cats[currentCard.cat].title;
    document.getElementById("gameTypePill").textContent = t.types[currentCard.type] || currentCard.type;
    document.getElementById("gameCardIcon").innerHTML = CATEGORY_SVGS[currentCard.cat] || CATEGORY_SVGS[1];
    document.getElementById("gamePromptText").textContent = currentCard[lang];
    document.getElementById("gameTwistBox").textContent = currentCard["twist_" + lang] || "";

    const timerBtn = document.getElementById("timerPillBtn");
    if (currentCard.time > 0) {
      timerBtn.style.display = "inline-flex";
      document.getElementById("timerPillText").textContent = `${timerRemaining}s`;
    } else {
      timerBtn.style.display = "none";
    }
  }
}

// Subtle Warm Candlelight Sparkles Canvas
function initSparkleCanvas() {
  const canvas = document.getElementById("sparkleCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");
  let w = (canvas.width = window.innerWidth);
  let h = (canvas.height = window.innerHeight);

  window.addEventListener("resize", () => {
    w = canvas.width = window.innerWidth;
    h = canvas.height = window.innerHeight;
  });

  const particles = Array.from({ length: 28 }, () => ({
    x: Math.random() * w,
    y: Math.random() * h,
    r: 0.8 + Math.random() * 1.8,
    vy: -0.15 - Math.random() * 0.35,
    vx: (Math.random() - 0.5) * 0.25,
    a: 0.15 + Math.random() * 0.55
  }));

  function frame() {
    ctx.clearRect(0, 0, w, h);
    for (const p of particles) {
      p.x += p.vx;
      p.y += p.vy;
      if (p.y < -10) {
        p.y = h + 10;
        p.x = Math.random() * w;
      }
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(255, 195, 155, ${p.a})`;
      ctx.fill();
    }
    requestAnimationFrame(frame);
  }
  frame();
}

// Keyboard Shortcuts for Desktop
window.addEventListener("keydown", (e) => {
  if (document.getElementById("activePlayView").style.display === "none") return;
  if (e.target.tagName === "INPUT") return;
  if (e.key === "ArrowRight") triggerCardAction(1);
  else if (e.key === "ArrowLeft") triggerCardAction(-1);
});

initCardSwipe();
initSparkleCanvas();
updateAllTexts();

if ("serviceWorker" in navigator && location.protocol.startsWith("http")) {
  navigator.serviceWorker.register("service-worker.js").catch(() => {});
}
