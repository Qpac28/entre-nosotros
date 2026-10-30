let currentLang = "en";
let heatPoints = 0;
let passLimit = 3;
let includeDrinks = true;
let includeExtreme = false;
let passesLeft = { 1: 3, 2: 3 };
let playerCount = 2;
let currentTurn = 1;
let activeTier = "all";
let timerInterval = null;
let remainingSeconds = 0;
let currentCard = null;
let drawBag = [];
let lastDrawnCard = null;
let finaleShown = false;
let wheelRotation = 0;
let wheelSpinning = false;
let pendingPenaltyEffect = null;
let playerNames = { 1: "", 2: "" };
let cardsCompleted = 0;
let passesUsedTotal = { 1: 0, 2: 0 };
let sessionStartTime = null;
let cardOfDayPending = false;
let tiersPlayed = new Set();

// Tier 2/3 unlock as Heat rises, so progression feels earned (Tier 4 stays gated by
// the separate includeExtreme opt-in, unaffected by heat)
const TIER_UNLOCK_HEAT = { 2: 3, 3: 6 };

let lifetimeStats = JSON.parse(localStorage.getItem("afterHoursLifetimeStats") || "null") || {
  gamesPlayed: 0,
  cardsCompleted: 0,
  finalesReached: 0,
  badgesEarned: []
};

function saveLifetimeStats() {
  localStorage.setItem("afterHoursLifetimeStats", JSON.stringify(lifetimeStats));
}

// Falls back to "Partner N" / "Pareja N" when no custom name was set
function getPlayerLabel(n) {
  const custom = (playerNames[n] || "").trim();
  if (custom) return custom;
  return currentLang === "es" ? "Pareja " + n : "Partner " + n;
}

function openModal(id) {
  document.getElementById(id).style.display = "flex";
}

function closeModal(id) {
  document.getElementById(id).style.display = "none";
}

// Rebuilds the N name inputs in setup. preserveTyped keeps whatever's already typed
// when the player count changes; pass false only for the one-time initial fill.
function renderNameInputs(preserveTyped) {
  const count = parseInt(document.getElementById("setupPlayerCount").value, 10);
  const container = document.getElementById("nameInputsContainer");

  const existing = {};
  if (preserveTyped) {
    container.querySelectorAll(".playerNameInput").forEach((el) => {
      existing[el.dataset.n] = el.value;
    });
  }

  container.innerHTML = "";
  for (let i = 1; i <= count; i++) {
    const input = document.createElement("input");
    input.type = "text";
    input.className = "playerNameInput";
    input.dataset.n = i;
    input.placeholder = (currentLang === "es" ? "Pareja " : "Partner ") + i;
    input.value = (preserveTyped && existing[i] !== undefined) ? existing[i] : (playerNames[i] || "");
    container.appendChild(input);
  }
}

// Updates existing name-input placeholders in place (does not touch .value),
// so toggling language mid-setup never clobbers what someone is typing.
function updateNameInputPlaceholders() {
  document.querySelectorAll(".playerNameInput").forEach((el) => {
    el.placeholder = (currentLang === "es" ? "Pareja " : "Partner ") + el.dataset.n;
  });
}

// ---------- Web Audio FX (synthesized chime + fireplace crackle) ----------
const AudioFX = (() => {
  let ctx = null;
  let muted = JSON.parse(localStorage.getItem("afterHoursMuted") || "false");

  function getContext() {
    if (!ctx) {
      ctx = new (window.AudioContext || window.webkitAudioContext)();
    }
    if (ctx.state === "suspended") ctx.resume();
    return ctx;
  }

  function isMuted() {
    return muted;
  }

  function setMuted(value) {
    muted = value;
    localStorage.setItem("afterHoursMuted", JSON.stringify(muted));
  }

  // Soft bell chord, used when a card flips to reveal its prompt
  function playChime() {
    if (muted) return;
    const audioCtx = getContext();
    const now = audioCtx.currentTime;
    const freqs = [880, 1318.5, 1760]; // A5, E6, A6

    freqs.forEach((freq, i) => {
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.type = "sine";
      osc.frequency.value = freq;

      const start = now + i * 0.03;
      gain.gain.setValueAtTime(0, start);
      gain.gain.linearRampToValueAtTime(0.16, start + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.9);

      osc.connect(gain);
      gain.connect(audioCtx.destination);
      osc.start(start);
      osc.stop(start + 1);
    });
  }

  // Synthesized fireplace crackle: a soft noise bed with sparse random "pops",
  // played when a timer is started
  function playCrackle() {
    if (muted) return;
    const audioCtx = getContext();
    const duration = 1.6;
    const bufferSize = Math.floor(audioCtx.sampleRate * duration);
    const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
    const data = buffer.getChannelData(0);

    for (let i = 0; i < bufferSize; i++) {
      let sample = (Math.random() * 2 - 1) * 0.04;
      if (Math.random() < 0.0025) {
        sample += (Math.random() * 2 - 1) * 0.9;
      }
      data[i] = sample;
    }

    const noise = audioCtx.createBufferSource();
    noise.buffer = buffer;

    const filter = audioCtx.createBiquadFilter();
    filter.type = "highpass";
    filter.frequency.value = 700;

    const gain = audioCtx.createGain();
    const now = audioCtx.currentTime;
    gain.gain.setValueAtTime(0.45, now);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + duration);

    noise.connect(filter);
    filter.connect(gain);
    gain.connect(audioCtx.destination);
    noise.start(now);
    noise.stop(now + duration);
  }

  return { playChime, playCrackle, isMuted, setMuted };
})();

function toggleMute() {
  AudioFX.setMuted(!AudioFX.isMuted());
  updateMuteButton();
}

function updateMuteButton() {
  document.getElementById("muteBtn").textContent = AudioFX.isMuted() ? "🔇" : "🔊";
}

// Create Embers (Three.js particle field, falls back to flat CSS dots)
const emberContainer = document.getElementById("emberContainer");
if (!(window.Embers3D && Embers3D.init(emberContainer))) {
  for (let i = 0; i < 15; i++) {
    const e = document.createElement("div");
    e.className = "ember";
    const size = Math.random() * 4 + 2 + "px";
    e.style.width = size;
    e.style.height = size;
    e.style.left = Math.random() * 100 + "vw";
    e.style.bottom = "-20px";
    e.style.animationDuration = (Math.random() * 5 + 4) + "s";
    e.style.animationDelay = (Math.random() * 5) + "s";
    emberContainer.appendChild(e);
  }
}

const uiText = {
  en: {
    langBtn: "🌐 ES | Español",
    subtitle: "Tap the card to reveal your prompt",
    tierAll: "All Levels",
    tier1: "1: Spark",
    tier2: "2: Sensory",
    tier3: "3: Power",
    tier4: "4: Extreme",
    labelExtreme: "Include Extreme Dares (18+, opt-in):",
    optExtremeYes: "Yes, include extreme dares",
    optExtremeNo: "No, stay at Power & Fantasy max",
    turnPrefix: "Current Turn: ",
    frontTitle: "Tap to Draw",
    frontSub: "Remember: Green, Yellow, or Pass anytime.",
    passBtn: "Pass (Safe Skip)",
    nextBtn: "Next Card ➔",
    customHeader: "+ Sneak a Custom Card",
    optTier1: "Level 1: Spark",
    optTier2: "Level 2: Sensory",
    optTier3: "Level 3: Power",
    optTier4: "Level 4: Extreme",
    optTruth: "Truth",
    optDare: "Dare",
    optDrink: "Drink",
    placeholder: "Type your secret prompt...",
    addCustomBtn: "Add to Deck",
    startTimer: "Start Timer",
    pauseTimer: "Pause Timer",
    resumeTimer: "Resume",
    timesUp: "Time's Up! 🔥",
    modalTitle: "Entre Nosotros Setup",
    modalDesc: "Configure your boundaries before diving in.",
    labelLanguage: "Language:",
    labelPlayerCount: "Number of Players:",
    labelNames: "Player Names (optional):",
    labelPassLimit: "Free Pass Limit per Player:",
    optPassInf: "Unlimited Passes",
    optPass3: "3 Passes Max",
    optPass2: "2 Passes Max",
    optPass1: "1 Pass Only",
    labelDrinkDares: "Include Drink Dares / Tragos:",
    optDrinkYes: "Yes, include drink dares",
    optDrinkNo: "No, keep it non-alcoholic",
    labelSound: "Sound Effects:",
    optSoundOn: "Sound On",
    optSoundOff: "Sound Off",
    startBtn: "Start Playing 🔥",
    tierLabels: { 1: "Level 1: Spark", 2: "Level 2: Sensory", 3: "Level 3: Power & Fantasy", 4: "Level 4: Extreme", finale: "🔥 THE FINALE 🔥" },
    typeLabels: { Truth: "Truth", Dare: "Dare", Drink: "Drink / Trago", Wildcard: "Wildcard" },
    passExhausted: "⚠️ No passes left! Penalty dare required.",
    wheelTitle: "No Passes Left!",
    wheelDesc: "Spin the Penalty Wheel to see your fate.",
    wheelSpinBtn: "Spin the Wheel 🎡",
    wheelContinueBtn: "Continue ➔",
    wheelSegSip: "Sip 🍷",
    wheelSegTruth: "Truth Time",
    wheelSegDare: "Double Dare",
    wheelSegKiss: "10s Kiss",
    wheelSegHeat: "+2 Heat 🔥",
    wheelSegCompliment: "3 Compliments",
    wheelSegFreeze: "Freeze! ❄️",
    wheelSegPartner: "Partner Picks",
    recapTitle: "Tonight's Recap",
    recapHeatLabel: "Heat Reached: Level",
    recapCardsLabel: "Cards Completed:",
    recapPassesLabel: "Passes Used:",
    recapTimeLabel: "Time Played:",
    recapFinaleYes: "🔥 You reached the Finale!",
    recapFinaleNo: "Finale not yet reached.",
    recapCloseBtn: "Close",
    safePauseTitle: "Paused",
    safePauseDesc: "Take a breath. Check in with each other. Resume whenever you're both ready — no rush, no pressure.",
    safePauseResumeBtn: "Resume",
    cardOfDayLabel: "📅 Card of the Day",
    badgeNoPasses: "🙌 No Passes Used",
    badgeAllTiers: "🌈 All Tiers Explored",
    badgeFinale: "🔥 Reached the Finale",
    badgeNone: "No badges yet — keep playing!",
    importPackHint: "Import a .json expansion pack",
    importPackSuccess: "cards imported!",
    importPackError: "Invalid file. Expecting a JSON array of cards.",
    exportCardsBtn: "⬇️ Export My Cards",
    exportCardsEmpty: "No custom cards to export yet.",
    tierLockedHint: "Unlocks at Heat",
    manageCardsBtn: "📋 Manage My Cards",
    manageCardsTitle: "Manage My Cards",
    manageCardsEmpty: "No custom or imported cards yet.",
    manageCardsDelete: "Delete",
    manageCardsCloseBtn: "Close",
    recapLifetimeTitle: "All-Time",
    recapLifetimeGames: "Games Played:",
    recapLifetimeCards: "Lifetime Cards Completed:",
    recapLifetimeFinales: "Finales Reached:",
    htpLinkBtn: "❓ How to Play",
    htpTitle: "How to Play",
    htpCloseBtn: "Got it",
    htpContent: `
      <p class="htp-line"><strong>Tiers:</strong> Level 1 Spark is light and flirty, Level 2 Sensory focuses on touch and the senses, Level 3 Power & Fantasy leans into roleplay and control. If enabled in setup, Level 4 Extreme pushes further still. "All Levels" draws a random mix from every tier you've unlocked.</p>
      <p class="htp-line"><strong>🔒 Tier Unlocking:</strong> Level 1 is always open. Level 2 unlocks at Heat 3, Level 3 at Heat 6 — progression is earned as you play, not just a filter toggle.</p>
      <p class="htp-line"><strong>Card Types:</strong> Truth = answer a question. Dare = complete a physical challenge (some have a timer). Drink = a toast or sip-based challenge.</p>
      <p class="htp-line"><strong>🌶️ Spicier:</strong> reveals a bonus twist that raises the stakes on the current card.</p>
      <p class="htp-line"><strong>🔥 Heat Meter:</strong> tap "Done (+Heat)" after completing a card. Reach Heat 10 to unlock a one-time Finale card.</p>
      <p class="htp-line"><strong>🙅 Passes:</strong> each player starts with a limited number of free passes (set in setup). Once you're out, passing spins the Penalty Wheel instead.</p>
      <p class="htp-line"><strong>🎡 Penalty Wheel:</strong> a random outcome — a sip, a truth, a forced dare, a kiss, a heat bonus, and more.</p>
      <p class="htp-line"><strong>🛑 Pause:</strong> tap anytime to freeze the game and take a breather. No rush, no pressure.</p>
      <p class="htp-line"><strong>📅 Card of the Day:</strong> the first card each session is the same for everyone on that date.</p>
      <p class="htp-line"><strong>📊 Recap:</strong> check your heat level, cards completed, passes used, badges, and lifetime stats at any point.</p>
      <p class="htp-line"><strong>✍️ Custom Cards & Packs:</strong> add your own prompts in setup, import a .json expansion pack, or manage/export/delete what you've added.</p>
    `
  },
  es: {
    langBtn: "🌐 EN | English",
    subtitle: "Toca la carta para revelar tu reto",
    tierAll: "Todos",
    tier1: "1: Chispa",
    tier2: "2: Sensorial",
    tier3: "3: Poder",
    tier4: "4: Extremo",
    labelExtreme: "Incluir Retos Extremos (18+, opcional):",
    optExtremeYes: "Sí, incluir retos extremos",
    optExtremeNo: "No, quedarse en Poder y Fantasía",
    turnPrefix: "Turno Actual: ",
    frontTitle: "Toca para Sacar",
    frontSub: "Recuerda: Verde, Amarillo o Pasar cuando quieras.",
    passBtn: "Pasar (Saltar)",
    nextBtn: "Siguiente Carta ➔",
    customHeader: "+ Añade una Carta Secreta",
    optTier1: "Nivel 1: Chispa",
    optTier2: "Nivel 2: Sensorial",
    optTier3: "Nivel 3: Poder",
    optTier4: "Nivel 4: Extremo",
    optTruth: "Verdad",
    optDare: "Reto",
    optDrink: "Trago",
    placeholder: "Escribe tu reto secreto...",
    addCustomBtn: "Añadir al Mazo",
    startTimer: "Iniciar Tiempo",
    pauseTimer: "Pausar",
    resumeTimer: "Reanudar",
    timesUp: "¡Tiempo Terminó! 🔥",
    modalTitle: "Configuración de Entre Nosotros",
    modalDesc: "Ajusta las reglas antes de comenzar.",
    labelLanguage: "Idioma:",
    labelPlayerCount: "Número de Jugadores:",
    labelNames: "Nombres de Jugadores (opcional):",
    labelPassLimit: "Límite de Pases por Jugador:",
    optPassInf: "Pases Ilimitados",
    optPass3: "Máximo 3 Pases",
    optPass2: "Máximo 2 Pases",
    optPass1: "Solo 1 Pase",
    labelDrinkDares: "Incluir Retos de Tragos:",
    optDrinkYes: "Sí, incluir tragos",
    optDrinkNo: "No, sin alcohol",
    labelSound: "Efectos de Sonido:",
    optSoundOn: "Sonido Activado",
    optSoundOff: "Sonido Desactivado",
    startBtn: "Comenzar Juego 🔥",
    tierLabels: { 1: "Nivel 1: Chispa", 2: "Nivel 2: Sensorial", 3: "Nivel 3: Poder y Fantasía", 4: "Nivel 4: Extremo", finale: "🔥 EL FINAL 🔥" },
    typeLabels: { Truth: "Verdad", Dare: "Reto", Drink: "Trago / Drink", Wildcard: "Comodín" },
    passExhausted: "⚠️ ¡Sin pases! Te toca un reto de penitencia.",
    wheelTitle: "¡Sin Pases!",
    wheelDesc: "Gira la Rueda de Penitencia para ver tu destino.",
    wheelSpinBtn: "Gira la Rueda 🎡",
    wheelContinueBtn: "Continuar ➔",
    wheelSegSip: "Trago 🍷",
    wheelSegTruth: "Hora Verdad",
    wheelSegDare: "Reto Doble",
    wheelSegKiss: "Beso 10s",
    wheelSegHeat: "+2 Calor 🔥",
    wheelSegCompliment: "3 Cumplidos",
    wheelSegFreeze: "¡Congélate! ❄️",
    wheelSegPartner: "Pareja Elige",
    recapTitle: "Resumen de la Noche",
    recapHeatLabel: "Calor Alcanzado: Nivel",
    recapCardsLabel: "Cartas Completadas:",
    recapPassesLabel: "Pases Usados:",
    recapTimeLabel: "Tiempo Jugado:",
    recapFinaleYes: "🔥 ¡Llegaron al Final!",
    recapFinaleNo: "Aún no llegan al Final.",
    recapCloseBtn: "Cerrar",
    safePauseTitle: "En Pausa",
    safePauseDesc: "Respiren. Hablen entre ustedes. Reanuden cuando ambos estén listos — sin prisa, sin presión.",
    safePauseResumeBtn: "Reanudar",
    cardOfDayLabel: "📅 Carta del Día",
    badgeNoPasses: "🙌 Sin Pases Usados",
    badgeAllTiers: "🌈 Todos los Niveles",
    badgeFinale: "🔥 Llegaron al Final",
    badgeNone: "Aún sin insignias — ¡sigan jugando!",
    importPackHint: "Importa un paquete de expansión .json",
    importPackSuccess: "¡cartas importadas!",
    importPackError: "Archivo inválido. Se espera un arreglo JSON de cartas.",
    exportCardsBtn: "⬇️ Exportar Mis Cartas",
    exportCardsEmpty: "Aún no hay cartas personalizadas para exportar.",
    tierLockedHint: "Se desbloquea con Calor",
    manageCardsBtn: "📋 Administrar Mis Cartas",
    manageCardsTitle: "Administrar Mis Cartas",
    manageCardsEmpty: "Aún no hay cartas personalizadas o importadas.",
    manageCardsDelete: "Eliminar",
    manageCardsCloseBtn: "Cerrar",
    recapLifetimeTitle: "Histórico",
    recapLifetimeGames: "Partidas Jugadas:",
    recapLifetimeCards: "Cartas Completadas (Histórico):",
    recapLifetimeFinales: "Finales Alcanzados:",
    htpLinkBtn: "❓ Cómo Jugar",
    htpTitle: "Cómo Jugar",
    htpCloseBtn: "Entendido",
    htpContent: `
      <p class="htp-line"><strong>Niveles:</strong> El Nivel 1 Chispa es ligero y coqueto, el Nivel 2 Sensorial se enfoca en el tacto y los sentidos, el Nivel 3 Poder y Fantasía se inclina hacia el juego de roles y el control. Si lo activas en la configuración, el Nivel 4 Extremo va aún más lejos. "Todos los Niveles" saca una mezcla aleatoria de cada nivel que hayas desbloqueado.</p>
      <p class="htp-line"><strong>🔒 Desbloqueo de Niveles:</strong> El Nivel 1 siempre está disponible. El Nivel 2 se desbloquea con 3 de Calor, el Nivel 3 con 6 —el progreso se gana jugando, no es solo un filtro.</p>
      <p class="htp-line"><strong>Tipos de Carta:</strong> Verdad = responde una pregunta. Reto = completa un desafío físico (algunos tienen temporizador). Trago = un brindis o reto con bebida.</p>
      <p class="htp-line"><strong>🌶️ Más Picante:</strong> revela un giro extra que sube la apuesta de la carta actual.</p>
      <p class="htp-line"><strong>🔥 Medidor de Calor:</strong> toca "Listo (+Calor)" después de completar una carta. Llega a 10 de Calor para desbloquear una carta Final única.</p>
      <p class="htp-line"><strong>🙅 Pases:</strong> cada jugador empieza con un número limitado de pases gratis (definido en la configuración). Cuando se acaben, pasar gira la Rueda de Penitencia en su lugar.</p>
      <p class="htp-line"><strong>🎡 Rueda de Penitencia:</strong> un resultado aleatorio —un trago, una verdad, un reto forzado, un beso, un bono de calor, y más.</p>
      <p class="htp-line"><strong>🛑 Pausa:</strong> tócalo cuando quieras para congelar el juego y respirar. Sin prisa, sin presión.</p>
      <p class="htp-line"><strong>📅 Carta del Día:</strong> la primera carta de cada sesión es la misma para todos en esa fecha.</p>
      <p class="htp-line"><strong>📊 Resumen:</strong> revisa tu nivel de calor, cartas completadas, pases usados, insignias y estadísticas históricas en cualquier momento.</p>
      <p class="htp-line"><strong>✍️ Cartas Personalizadas y Paquetes:</strong> añade tus propios retos en la configuración, importa un paquete de expansión .json, o administra/exporta/elimina lo que ya añadiste.</p>
    `
  }
};

// One glossy gradient icon per tier+type combo, shared across every card in that group
const ICONS = {
  t1Truth: `<path d="M12 21s-7.5-4.6-10-9.3C.5 7.9 2.8 4 6.5 4c2 0 3.6 1.1 4.5 2.7C11.9 5.1 13.5 4 15.5 4 19.2 4 21.5 7.9 20 11.7 19.5 16.4 12 21 12 21z" fill="url(#gradWine)"/><ellipse cx="9" cy="8" rx="2.6" ry="1.6" fill="rgba(255,255,255,0.35)"/>`,
  t1Dare: `<path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7Z" fill="url(#gradIce)"/><circle cx="12" cy="12" r="4" fill="#1b2e31"/><circle cx="13.2" cy="10.6" r="1.1" fill="rgba(255,255,255,0.8)"/>`,
  t1Drink: `<path d="M7 2h10l-1.2 8.4a4 4 0 0 1-3.8 3.4V18h2.5a1 1 0 0 1 0 2H9.5a1 1 0 0 1 0-2H12v-4.2A4 4 0 0 1 8.2 10.4L7 2Z" fill="url(#gradWine)"/><ellipse cx="9.3" cy="5" rx="1.6" ry="1" fill="rgba(255,255,255,0.4)"/>`,
  t2Truth: `<path d="M3 9l3.5 3L12 5l5.5 7L21 9l-2 9H5L3 9Z" fill="url(#gradGold)"/><ellipse cx="8.5" cy="10.5" rx="1.6" ry="1" fill="rgba(255,255,255,0.4)"/>`,
  t2Dare: `<path d="M2 11c3-3 7-4 10-4s7 1 10 4c-3 3-7 4-10 4s-7-1-10-4Z" fill="url(#gradRose)"/><circle cx="8.5" cy="11" r="1.4" fill="#2c1420"/><circle cx="15.5" cy="11" r="1.4" fill="#2c1420"/><ellipse cx="7.5" cy="9.5" rx="1.2" ry="0.6" fill="rgba(255,255,255,0.4)"/>`,
  t2Drink: `<path d="M4 3h5l-.8 6a2.7 2.7 0 0 1-2.2 2.3V17h1.6a.9.9 0 0 1 0 1.8H4.4a.9.9 0 0 1 0-1.8H6v-5.7A2.7 2.7 0 0 1 3.8 9L3 3Z" fill="url(#gradGold)"/><path d="M15 3h5l-.8 6a2.7 2.7 0 0 1-2.2 2.3V17h1.6a.9.9 0 0 1 0 1.8h-4.2a.9.9 0 0 1 0-1.8H16v-5.7A2.7 2.7 0 0 1 14.8 9L14 3Z" fill="url(#gradWine)"/>`,
  t3Truth: `<path d="m12 2 2.2 6.8L21 11l-6.8 2.2L12 20l-2.2-6.8L3 11l6.8-2.2Z" fill="url(#gradFlame)"/><circle cx="19" cy="4" r="1.3" fill="url(#gradGold)"/><ellipse cx="10" cy="8" rx="1.4" ry="0.9" fill="rgba(255,255,255,0.4)"/>`,
  t3Dare: `<path d="M5 20h14l-1-4H6l-1 4Z" fill="url(#gradGold)"/><path d="M9 16 7 6l5 3 5-3-2 10Z" fill="url(#gradGold)"/><circle cx="12" cy="4" r="1.6" fill="url(#gradFlame)"/>`,
  t3Drink: `<path d="M5 5h6l-1 11a2 2 0 0 1-2 1.8 2 2 0 0 1-2-1.8L5 5Z" fill="url(#gradFlame)"/><path d="M13 5h6l-1 11a2 2 0 0 1-2 1.8 2 2 0 0 1-2-1.8L13 5Z" fill="url(#gradGold)"/>`,
  custom: `<path d="M4 17.25V20h2.75L14.8 11.9l-2.75-2.75L4 17.25Z" fill="url(#gradRose)"/><path d="M16.2 10.5 18 8.7a1.5 1.5 0 0 0 0-2.1l-1.1-1.1a1.5 1.5 0 0 0-2.1 0l-1.8 1.8 2.75 2.75Z" fill="url(#gradGold)"/>`,
  t4Truth: `<path d="M12 21s-7.5-4.6-10-9.3C.5 7.9 2.8 4 6.5 4c2 0 3.6 1.1 4.5 2.7C11.9 5.1 13.5 4 15.5 4 19.2 4 21.5 7.9 20 11.7 19.5 16.4 12 21 12 21z" fill="url(#gradExtreme)"/><ellipse cx="9" cy="8" rx="2.6" ry="1.6" fill="rgba(255,255,255,0.25)"/>`,
  t4Dare: `<path d="m12 2 2.2 6.8L21 11l-6.8 2.2L12 20l-2.2-6.8L3 11l6.8-2.2Z" fill="url(#gradExtreme)"/><circle cx="19" cy="4" r="1.3" fill="url(#gradExtreme)"/><ellipse cx="10" cy="8" rx="1.4" ry="0.9" fill="rgba(255,255,255,0.25)"/>`,
  t4Drink: `<path d="M7 2h10l-1.2 8.4a4 4 0 0 1-3.8 3.4V18h2.5a1 1 0 0 1 0 2H9.5a1 1 0 0 1 0-2H12v-4.2A4 4 0 0 1 8.2 10.4L7 2Z" fill="url(#gradExtreme)"/><ellipse cx="9.3" cy="5" rx="1.6" ry="1" fill="rgba(255,255,255,0.25)"/>`
};

// Maps a card to the same key used by both ICONS (flat SVG) and Icon3D's color palette
function iconKeyFor(card) {
  return card.tier === "finale" ? "finale" : "t" + card.tier + card.type;
}

const defaultDeck = [
  // --- Tier 1: Spark — Truth ---
  {
    tier: 1, type: "Truth", time: 0,
    text: { en: "Tell your partner one specific moment when you found them irresistibly attractive.", es: "Cuéntale a tu pareja un momento exacto en que te pareció irresistible." },
    twist: { en: "Whisper it directly into their ear.", es: "Susúrrale la respuesta directo al oído." },
    svg: ICONS.t1Truth
  },
  {
    tier: 1, type: "Truth", time: 0,
    text: { en: "Describe the exact outfit I was wearing the first time you really noticed me.", es: "Describe la ropa exacta que llevaba la primera vez que realmente te fijaste en mí." },
    twist: { en: "Act out how you looked at me that day.", es: "Actúa cómo me miraste ese día." },
    svg: ICONS.t1Truth
  },
  {
    tier: 1, type: "Truth", time: 0,
    text: { en: "What's a small habit of mine that secretly drives you wild?", es: "¿Cuál es un pequeño hábito mío que secretamente te vuelve loco/a?" },
    twist: { en: "Demonstrate it back to me right now.", es: "Imítamelo ahora mismo." },
    svg: ICONS.t1Truth
  },
  {
    tier: 1, type: "Truth", time: 0,
    text: { en: "If you could kiss me anywhere right now, where would it be?", es: "Si pudieras besarme en cualquier lugar ahora mismo, ¿dónde sería?" },
    twist: { en: "Don't just tell me — show me.", es: "No solo me lo digas, muéstramelo." },
    svg: ICONS.t1Truth
  },
  {
    tier: 1, type: "Truth", time: 0,
    text: { en: "What song reminds you most of us, and why?", es: "¿Qué canción te recuerda más a nosotros, y por qué?" },
    twist: { en: "Hum a few seconds of it while looking into my eyes.", es: "Tararea unos segundos mientras me miras a los ojos." },
    svg: ICONS.t1Truth
  },
  {
    tier: 1, type: "Truth", time: 0,
    text: { en: "Tell me one thing I do that makes you feel most loved.", es: "Dime algo que hago que te hace sentir más amado/a." },
    twist: { en: "Whisper your answer instead of saying it out loud.", es: "Susurra tu respuesta en lugar de decirla en voz alta." },
    svg: ICONS.t1Truth
  },

  // --- Tier 1: Spark — Dare ---
  {
    tier: 1, type: "Dare", time: 60,
    text: { en: "Hold unbroken eye contact for 60 seconds while tracing your fingertips along your partner's jawline.", es: "Mantén contacto visual 60 segundos recorriendo con tus dedos su mandíbula." },
    twist: { en: "Close your eyes during the last 15 seconds.", es: "Cierra los ojos durante los últimos 15 segundos." },
    svg: ICONS.t1Dare
  },
  {
    tier: 1, type: "Dare", time: 60,
    text: { en: "Give your partner a slow 60-second shoulder massage.", es: "Dale a tu pareja un masaje de hombros lento de 60 segundos." },
    twist: { en: "Do it standing behind them, lips near their neck.", es: "Hazlo de pie detrás, con los labios cerca de su cuello." },
    svg: ICONS.t1Dare
  },
  {
    tier: 1, type: "Dare", time: 60,
    text: { en: "Trace a heart shape on your partner's palm with your fingertip, slow enough that they feel every curve.", es: "Dibuja un corazón en la palma de tu pareja con la punta del dedo, despacio para que sienta cada curva." },
    twist: { en: "Finish with a kiss on their palm.", es: "Termina con un beso en su palma." },
    svg: ICONS.t1Dare
  },
  {
    tier: 1, type: "Dare", time: 60,
    text: { en: "Feed your partner a grape, strawberry, or chocolate piece using only your lips.", es: "Dale de comer a tu pareja una uva, fresa o chocolate usando solo tus labios." },
    twist: { en: "No hands allowed for either of you.", es: "Nadie puede usar las manos." },
    svg: ICONS.t1Dare
  },
  {
    tier: 1, type: "Dare", time: 60,
    text: { en: "Give your partner three compliments while slow dancing together for 60 seconds, even without music.", es: "Dale tres cumplidos a tu pareja mientras bailan lento 60 segundos, incluso sin música." },
    twist: { en: "Keep your foreheads touching the whole time.", es: "Mantengan las frentes juntas todo el tiempo." },
    svg: ICONS.t1Dare
  },
  {
    tier: 1, type: "Dare", time: 60,
    text: { en: "Write a one-word desire on your partner's arm using just your fingertip; they must guess it.", es: "Escribe un deseo de una palabra en el brazo de tu pareja solo con el dedo; debe adivinarlo." },
    twist: { en: "If they guess right, reward them with a 10-second kiss.", es: "Si adivina, prémialo con un beso de 10 segundos." },
    svg: ICONS.t1Dare
  },

  // --- Tier 1: Spark — Drink ---
  {
    tier: 1, type: "Drink", time: 0,
    text: { en: "Take a sip of your drink while your partner feeds you a small bite of something sweet or salty.", es: "Da un sorbo a tu trago mientras tu pareja te da un bocado de algo dulce o salado." },
    twist: { en: "Do it without using your hands.", es: "Hazlo sin usar las manos." },
    svg: ICONS.t1Drink
  },
  {
    tier: 1, type: "Drink", time: 0,
    text: { en: "Clink glasses and share one reason you're grateful to be together tonight.", es: "Choquen las copas y compartan una razón por la que agradecen estar juntos esta noche." },
    twist: { en: "Seal it with a toast kiss.", es: "Séllenlo con un beso de brindis." },
    svg: ICONS.t1Drink
  },
  {
    tier: 1, type: "Drink", time: 0,
    text: { en: "Take a sip, then describe your drink's flavor using only words that describe your partner.", es: "Da un sorbo y describe el sabor de tu trago usando solo palabras que describan a tu pareja." },
    twist: { en: "If you repeat a word, take another sip.", es: "Si repites una palabra, toma otro sorbo." },
    svg: ICONS.t1Drink
  },
  {
    tier: 1, type: "Drink", time: 0,
    text: { en: "Let your partner choose your next sip's size by holding up fingers (1 to 5 seconds).", es: "Deja que tu pareja elija el tamaño de tu próximo sorbo levantando dedos (1 a 5 segundos)." },
    twist: { en: "They get to pick where you drink from next — your glass or theirs.", es: "Ellos eligen de dónde beberás después: tu copa o la suya." },
    svg: ICONS.t1Drink
  },
  {
    tier: 1, type: "Drink", time: 0,
    text: { en: "Take a sip while maintaining eye contact the entire time, no blinking.", es: "Da un sorbo manteniendo contacto visual todo el tiempo, sin parpadear." },
    twist: { en: "Loser of the staring contest gives the winner a kiss.", es: "El que pierda el duelo de miradas le da un beso al ganador." },
    svg: ICONS.t1Drink
  },
  {
    tier: 1, type: "Drink", time: 0,
    text: { en: "Take turns describing your dream date over your next sip.", es: "Por turnos, describan su cita soñada mientras dan su siguiente sorbo." },
    twist: { en: "Promise to plan it together before the night ends.", es: "Prometan planearla juntos antes de que termine la noche." },
    svg: ICONS.t1Drink
  },

  // --- Tier 2: Sensory — Truth ---
  {
    tier: 2, type: "Truth", time: 0,
    text: { en: "Do you prefer being in complete control, or surrendering control to your partner?", es: "¿Prefieres tener el control absoluto o entregárselo a tu pareja?" },
    twist: { en: "Demonstrate your preference physically right now.", es: "Demuestra tu preferencia físicamente ahora mismo." },
    svg: ICONS.t2Truth
  },
  {
    tier: 2, type: "Truth", time: 0,
    text: { en: "What's a touch — a graze, a squeeze, a certain kiss — that instantly gets your attention?", es: "¿Qué tipo de toque —un roce, un apretón, cierto beso— capta tu atención al instante?" },
    twist: { en: "Have your partner try it on you right now.", es: "Deja que tu pareja lo intente contigo ahora mismo." },
    svg: ICONS.t2Truth
  },
  {
    tier: 2, type: "Truth", time: 0,
    text: { en: "Which of your partner's senses — touch, taste, sound, sight, smell — do you most love to tease?", es: "¿Cuál de los sentidos de tu pareja —tacto, gusto, sonido, vista, olfato— te encanta provocar más?" },
    twist: { en: "Prove it with a 10-second demonstration.", es: "Pruébalo con una demostración de 10 segundos." },
    svg: ICONS.t2Truth
  },
  {
    tier: 2, type: "Truth", time: 0,
    text: { en: "Describe, in detail, the last time you felt completely swept away by me.", es: "Describe con detalle la última vez que te sentiste completamente arrebatado/a por mí." },
    twist: { en: "Recreate the opening moment of that memory.", es: "Recrea el momento inicial de ese recuerdo." },
    svg: ICONS.t2Truth
  },
  {
    tier: 2, type: "Truth", time: 0,
    text: { en: "On a scale of soft to intense, how do you like to be touched when you're stressed versus turned on?", es: "En una escala de suave a intenso, ¿cómo te gusta que te toquen cuando estás estresado/a frente a cuando estás excitado/a?" },
    twist: { en: "Let your partner practice both for 10 seconds each.", es: "Deja que tu pareja practique ambos durante 10 segundos cada uno." },
    svg: ICONS.t2Truth
  },
  {
    tier: 2, type: "Truth", time: 0,
    text: { en: "What's one sensory detail about me — a smell, a sound, a texture — that you crave when we're apart?", es: "¿Cuál es un detalle sensorial mío —un aroma, un sonido, una textura— que anhelas cuando estamos separados?" },
    twist: { en: "Lean in and experience it again right now.", es: "Acércate y experiméntalo otra vez ahora mismo." },
    svg: ICONS.t2Truth
  },

  // --- Tier 2: Sensory — Dare ---
  {
    tier: 2, type: "Dare", time: 120,
    text: { en: "Blindfold your partner for 2 minutes and use three textures (lips, fingertips, ice) on their skin.", es: "Cúbrele los ojos a tu pareja 2 minutos y usa tres texturas (labios, dedos, hielo) en su piel." },
    twist: { en: "They must guess what each texture is.", es: "Deben adivinar qué es cada textura." },
    svg: ICONS.t2Dare
  },
  {
    tier: 2, type: "Dare", time: 120,
    text: { en: "Close your eyes. Let your partner trace an ice cube slowly from your collarbone to your wrist.", es: "Cierra los ojos. Deja que tu pareja trace un cubo de hielo lentamente desde tu clavícula hasta tu muñeca." },
    twist: { en: "They can stop anywhere and hold it there for 5 seconds.", es: "Pueden detenerse en cualquier punto y mantenerlo ahí 5 segundos." },
    svg: ICONS.t2Dare
  },
  {
    tier: 2, type: "Dare", time: 120,
    text: { en: "Give your partner a 2-minute hand massage using a lotion or oil, focusing on each finger.", es: "Dale a tu pareja un masaje de manos de 2 minutos con loción o aceite, enfocándote en cada dedo." },
    twist: { en: "End with a slow kiss on their palm.", es: "Termina con un beso lento en su palma." },
    svg: ICONS.t2Dare
  },
  {
    tier: 2, type: "Dare", time: 120,
    text: { en: "Whisper a slow countdown from 10 directly into your partner's ear while tracing light circles on their back.", es: "Susurra una cuenta lenta desde 10 directamente al oído de tu pareja mientras trazas círculos suaves en su espalda." },
    twist: { en: "At zero, they choose the next move.", es: "En cero, ellos eligen el siguiente movimiento." },
    svg: ICONS.t2Dare
  },
  {
    tier: 2, type: "Dare", time: 120,
    text: { en: "Feed your partner three different flavors (sweet, salty, spicy) blindfolded; they must guess each one before continuing.", es: "Dale a tu pareja tres sabores distintos (dulce, salado, picante) con los ojos vendados; debe adivinar cada uno antes de continuar." },
    twist: { en: "Wrong guesses earn a playful forfeit of your choice.", es: "Las respuestas erróneas tienen una penitencia divertida a tu elección." },
    svg: ICONS.t2Dare
  },
  {
    tier: 2, type: "Dare", time: 120,
    text: { en: "Run your fingertips along your partner's inner forearm for 2 minutes while maintaining silence and eye contact.", es: "Recorre con tus dedos el antebrazo interno de tu pareja durante 2 minutos manteniendo silencio y contacto visual." },
    twist: { en: "Break the silence only with a single whispered word at the end.", es: "Rompe el silencio solo con una palabra susurrada al final." },
    svg: ICONS.t2Dare
  },

  // --- Tier 2: Sensory — Drink ---
  {
    tier: 2, type: "Drink", time: 0,
    text: { en: "Swap drinks with your partner. Take a sip, look deep into their eyes, and compliment their lips.", es: "Intercambia tu trago con tu pareja. Da un sorbo, míralo a los ojos y elogia sus labios." },
    twist: { en: "Feed them the next sip directly from your lips.", es: "Dile el siguiente sorbo directamente de tus labios." },
    svg: ICONS.t2Drink
  },
  {
    tier: 2, type: "Drink", time: 0,
    text: { en: "Pour your partner's next drink and describe, out loud, exactly how you want the rest of tonight to feel.", es: "Sirve el siguiente trago de tu pareja y describe en voz alta cómo quieres que se sienta el resto de la noche." },
    twist: { en: "Make eye contact the entire time you pour.", es: "Mantén contacto visual todo el tiempo mientras sirves." },
    svg: ICONS.t2Drink
  },
  {
    tier: 2, type: "Drink", time: 0,
    text: { en: "Take a sip, then trace the rim of your glass along your partner's lips before they take theirs.", es: "Da un sorbo, luego pasa el borde de tu copa por los labios de tu pareja antes de que tome la suya." },
    twist: { en: "Let them lick a drop off the rim before continuing.", es: "Déjalos lamer una gota del borde antes de continuar." },
    svg: ICONS.t2Drink
  },
  {
    tier: 2, type: "Drink", time: 0,
    text: { en: "Play a quick round of 'truth or shot' — answer a bold question from your partner or take a drink instead.", es: "Jueguen una ronda rápida de 'verdad o trago': responde una pregunta atrevida de tu pareja o toma un trago en su lugar." },
    twist: { en: "If you dodge twice in a row, you owe a dare instead.", es: "Si evitas dos veces seguidas, debes cumplir un reto en su lugar." },
    svg: ICONS.t2Drink
  },
  {
    tier: 2, type: "Drink", time: 0,
    text: { en: "Take your next sip sitting in your partner's lap, facing them.", es: "Toma tu siguiente sorbo sentado/a en el regazo de tu pareja, de frente a ellos." },
    twist: { en: "Stay there until they finish their own sip too.", es: "Quédate ahí hasta que ellos también terminen su sorbo." },
    svg: ICONS.t2Drink
  },
  {
    tier: 2, type: "Drink", time: 0,
    text: { en: "Blindfold your partner and let them guess what drink you're giving them by taste alone.", es: "Venda los ojos de tu pareja y deja que adivine qué trago le estás dando solo por el sabor." },
    twist: { en: "Wrong guess means they owe you a slow kiss.", es: "Si falla, te debe un beso lento." },
    svg: ICONS.t2Drink
  },

  // --- Tier 3: Power & Fantasy — Truth ---
  {
    tier: 3, type: "Truth", time: 0,
    text: { en: "Describe a secret fantasy or location where you would love for us to lose ourselves tonight.", es: "Describe una fantasía secreta o un lugar donde te encantaría perderte esta noche." },
    twist: { en: "Describe it in a whisper close to their ear.", es: "Descríbelo susurrando muy cerca de su oreja." },
    svg: ICONS.t3Truth
  },
  {
    tier: 3, type: "Truth", time: 0,
    text: { en: "What role — in control, being controlled, worshipped, worshipping — do you crave most?", es: "¿Qué papel —tener el control, ser controlado/a, ser adorado/a, adorar— deseas más?" },
    twist: { en: "Act out the opening 10 seconds of that role right now.", es: "Actúa los primeros 10 segundos de ese papel ahora mismo." },
    svg: ICONS.t3Truth
  },
  {
    tier: 3, type: "Truth", time: 0,
    text: { en: "Describe, without censoring yourself, the boldest fantasy you've had about the two of us.", es: "Describe, sin censurarte, la fantasía más atrevida que has tenido sobre nosotros dos." },
    twist: { en: "Pick one detail from it to actually try tonight.", es: "Elige un detalle de esa fantasía para intentarlo esta misma noche." },
    svg: ICONS.t3Truth
  },
  {
    tier: 3, type: "Truth", time: 0,
    text: { en: "If tonight had no rules at all, what's the first thing you'd want to happen?", es: "Si esta noche no tuviera ninguna regla, ¿qué sería lo primero que querrías que pasara?" },
    twist: { en: "Make it happen within the next two minutes.", es: "Haz que pase en los próximos dos minutos." },
    svg: ICONS.t3Truth
  },
  {
    tier: 3, type: "Truth", time: 0,
    text: { en: "What's a word or phrase you'd love to hear me say to you in the heat of the moment?", es: "¿Qué palabra o frase te encantaría escucharme decir en el momento más intenso?" },
    twist: { en: "I'll say it to you right now, however you want it delivered.", es: "Te la diré ahora mismo, como tú quieras que te la diga." },
    svg: ICONS.t3Truth
  },
  {
    tier: 3, type: "Truth", time: 0,
    text: { en: "Tell me the most daring place you'd want us to sneak off to together.", es: "Dime el lugar más atrevido al que te gustaría que nos escapáramos juntos." },
    twist: { en: "Plan the exact night it happens before this game ends.", es: "Planeen la noche exacta en que sucederá antes de que termine este juego." },
    svg: ICONS.t3Truth
  },

  // --- Tier 3: Power & Fantasy — Dare ---
  {
    tier: 3, type: "Dare", time: 180,
    text: { en: "The Director: You have total command for 3 minutes. Give your partner three instructions to follow.", es: "El Director: Tienes mando total por 3 minutos. Dale tres instrucciones a tu pareja." },
    twist: { en: "Your partner must call you 'Boss' or 'Jefe' during the dare.", es: "Tu pareja debe llamarte 'Jefe' durante el reto." },
    svg: ICONS.t3Dare
  },
  {
    tier: 3, type: "Dare", time: 180,
    text: { en: "Switch roles for 3 minutes: the quieter partner takes full command and gives the orders.", es: "Intercambien roles por 3 minutos: la pareja más callada toma el mando total y da las órdenes." },
    twist: { en: "The other must respond with 'Yes, ma'am/sir' to every instruction.", es: "El otro debe responder 'Sí, señor/señora' a cada instrucción." },
    svg: ICONS.t3Dare
  },
  {
    tier: 3, type: "Dare", time: 180,
    text: { en: "Give your partner a slow, commanding reveal of one item of clothing — their choice of which.", es: "Hazle a tu pareja una revelación lenta y dominante de una prenda de ropa, ellos eligen cuál." },
    twist: { en: "They're not allowed to touch until you say they can.", es: "No pueden tocar hasta que tú lo permitas." },
    svg: ICONS.t3Dare
  },
  {
    tier: 3, type: "Dare", time: 180,
    text: { en: "Gently hold your partner's wrists above their head for 3 minutes while whispering what you plan to do next.", es: "Sujeta suavemente las muñecas de tu pareja por encima de su cabeza durante 3 minutos mientras susurras lo que planeas hacer después." },
    twist: { en: "They must stay still and only respond with words, no struggling.", es: "Deben quedarse quietos y solo responder con palabras, sin forcejear." },
    svg: ICONS.t3Dare
  },
  {
    tier: 3, type: "Dare", time: 180,
    text: { en: "Lead your partner, blindfolded, to a different spot and reveal a fantasy scenario you'll act out together.", es: "Guía a tu pareja con los ojos vendados a otro lugar y revela un escenario de fantasía que actuarán juntos." },
    twist: { en: "They must guess the scenario using only touch clues for 30 seconds first.", es: "Primero deben adivinar el escenario solo con pistas de tacto durante 30 segundos." },
    svg: ICONS.t3Dare
  },
  {
    tier: 3, type: "Dare", time: 180,
    text: { en: "The Negotiation: spend 3 minutes negotiating one new rule or safe word for tonight, then seal it with a kiss.", es: "La Negociación: pasen 3 minutos negociando una nueva regla o palabra de seguridad para esta noche, y séllenlo con un beso." },
    twist: { en: "Whoever gives in first on the negotiation owes a forfeit of the other's choosing.", es: "Quien cede primero en la negociación debe una penitencia elegida por el otro." },
    svg: ICONS.t3Dare
  },

  // --- Tier 3: Power & Fantasy — Drink ---
  {
    tier: 3, type: "Drink", time: 0,
    text: { en: "Take a shot together arm-in-arm, then whisper your deepest desire for later tonight.", es: "Tómense un trago juntos con los brazos entrelazados y susúrrale tu mayor deseo para más tarde." },
    twist: { en: "Keep holding hands until the glass is completely empty.", es: "Sigan tomados de las manos hasta terminar la copa." },
    svg: ICONS.t3Drink
  },
  {
    tier: 3, type: "Drink", time: 0,
    text: { en: "Take a shot off the back of your partner's hand, then tell them exactly what you want next.", es: "Toma un shot del dorso de la mano de tu pareja y dile exactamente lo que quieres a continuación." },
    twist: { en: "They get 10 seconds to grant your wish, no questions asked.", es: "Tienen 10 segundos para cumplir tu deseo, sin preguntas." },
    svg: ICONS.t3Drink
  },
  {
    tier: 3, type: "Drink", time: 0,
    text: { en: "Let your partner pour your drink anywhere on your body they choose (within reason) and take it from there.", es: "Deja que tu pareja sirva tu trago donde ellos elijan en tu cuerpo (dentro de lo razonable) y lo tomen de ahí." },
    twist: { en: "No hands allowed for either of you during the sip.", es: "Nadie puede usar las manos durante el sorbo." },
    svg: ICONS.t3Drink
  },
  {
    tier: 3, type: "Drink", time: 0,
    text: { en: "Make a toast to the wildest night you two will have together, then both finish your glass.", es: "Hagan un brindis por la noche más salvaje que tendrán juntos, y ambos terminen su copa." },
    twist: { en: "Whoever finishes last grants the other one request for later tonight.", es: "Quien termine último le concede al otro un deseo para más tarde esta noche." },
    svg: ICONS.t3Drink
  },
  {
    tier: 3, type: "Drink", time: 0,
    text: { en: "Take your shot while your partner holds you close and whispers one command for the rest of the night.", es: "Toma tu shot mientras tu pareja te abraza cerca y susurra una orden para el resto de la noche." },
    twist: { en: "You must follow it the moment the game ends.", es: "Debes cumplirla en el momento en que termine el juego." },
    svg: ICONS.t3Drink
  },
  {
    tier: 3, type: "Drink", time: 0,
    text: { en: "Share one final drink from the same glass, trading sips, while describing how you want the night to end.", es: "Comparte un último trago de la misma copa, intercambiando sorbos, mientras describen cómo quieren que termine la noche." },
    twist: { en: "The last sip belongs to whoever says the boldest thing.", es: "El último sorbo es para quien diga lo más atrevido." },
    svg: ICONS.t3Drink
  },

  // --- Tier 4: Extreme (opt-in only) — Truth ---
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "Confess the boldest thing you've ever fantasized about doing with me, down to the last detail you're willing to share out loud.", es: "Confiesa lo más atrevido que has fantaseado hacer conmigo, con todos los detalles que te animes a compartir en voz alta." },
    twist: { en: "Act out the first ten seconds of it right now.", es: "Actúa los primeros diez segundos ahora mismo." },
    svg: ICONS.t4Truth
  },
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "What's the one thing you've never asked me for in the bedroom because you were nervous I'd say no?", es: "¿Qué es lo único que nunca me has pedido en la intimidad porque te daba nervios que dijera que no?" },
    twist: { en: "Ask me for it right now. I have to answer honestly.", es: "Pídemelo ahora mismo. Debo responder con honestidad." },
    svg: ICONS.t4Truth
  },
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "Describe exactly how you want to be undressed tonight — slow or fast, who's in control, where it happens.", es: "Describe exactamente cómo quieres que te desvistan esta noche —lento o rápido, quién tiene el control, dónde sucede." },
    twist: { en: "Direct me to start doing it your way for 15 seconds.", es: "Dirígeme para que empiece a hacerlo a tu manera durante 15 segundos." },
    svg: ICONS.t4Truth
  },
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "What's the most out-of-character thing you'd be willing to say to me in the heat of the moment?", es: "¿Qué es lo más fuera de tu personalidad que estarías dispuesto/a a decirme en el momento más intenso?" },
    twist: { en: "Say it to me now, exactly like you would then.", es: "Dímelo ahora, exactamente como lo harías entonces." },
    svg: ICONS.t4Truth
  },
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "Tell me which part of my body you've been thinking about most today, and why.", es: "Dime en qué parte de mi cuerpo has pensado más hoy, y por qué." },
    twist: { en: "Spend the next 20 seconds showing me, not telling me.", es: "Pasa los próximos 20 segundos mostrándomelo, no diciéndomelo." },
    svg: ICONS.t4Truth
  },
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "If I gave you full control for the rest of the night with zero limits except our safe word, what's the very first thing you'd do?", es: "Si te diera el control total por el resto de la noche sin límites, salvo nuestra palabra de seguridad, ¿qué sería lo primero que harías?" },
    twist: { en: "You have full control starting now — for the next two minutes.", es: "Tienes el control total a partir de ahora, por los próximos dos minutos." },
    svg: ICONS.t4Truth
  },

  // --- Tier 4: Extreme (opt-in only) — Dare ---
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "Take full command for 3 minutes: direct your partner through a slow striptease-style reveal of their choosing, piece by piece, on your timing.", es: "Toma el mando total por 3 minutos: dirige a tu pareja en una revelación lenta de su ropa, pieza por pieza, a tu ritmo." },
    twist: { en: "They may only move when you say a chosen keyword.", es: "Solo pueden moverse cuando digas una palabra clave elegida." },
    svg: ICONS.t4Dare
  },
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "Blindfold your partner and spend 3 minutes building anticipation with touch alone — no two touches the same, no warning before each one.", es: "Venda los ojos de tu pareja y pasa 3 minutos generando anticipación solo con el tacto —ningún toque igual al anterior, sin aviso antes de cada uno." },
    twist: { en: "They must guess what comes next before you'll continue.", es: "Debe adivinar qué sigue antes de que continúes." },
    svg: ICONS.t4Dare
  },
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "The Edge: for 3 minutes, bring your partner right to the point of losing control, then stop completely and make them wait.", es: "El Límite: durante 3 minutos, lleva a tu pareja justo al punto de perder el control, luego detente por completo y hazla esperar." },
    twist: { en: "They must ask permission, in words, before you continue.", es: "Debe pedir permiso, en palabras, antes de que continúes." },
    svg: ICONS.t4Dare
  },
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "Switch who's in charge completely for 3 minutes — the quieter partner gives every instruction, the other obeys without question.", es: "Intercambien quién manda por completo durante 3 minutos —la pareja más callada da cada instrucción, la otra obedece sin cuestionar." },
    twist: { en: "Break character and they owe a forfeit of your choosing.", es: "Si rompe el personaje, debe una penitencia a tu elección." },
    svg: ICONS.t4Dare
  },
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "Pin your partner's hands above their head and keep them there for 3 minutes while you decide, out loud, everything that happens next.", es: "Sujeta las manos de tu pareja por encima de su cabeza durante 3 minutos mientras decides, en voz alta, todo lo que sucede después." },
    twist: { en: "They can only respond with 'yes' or silence.", es: "Solo puede responder con 'sí' o silencio." },
    svg: ICONS.t4Dare
  },
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "Lead your partner somewhere private and spend 3 minutes making every rule for what happens there — they follow completely.", es: "Lleva a tu pareja a un lugar privado y pasa 3 minutos estableciendo cada regla de lo que sucede ahí —ellos siguen por completo." },
    twist: { en: "They must thank you after every single instruction.", es: "Debe agradecerte después de cada instrucción." },
    svg: ICONS.t4Dare
  },

  // --- Tier 4: Extreme (opt-in only) — Drink ---
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Take a shot from wherever your partner chooses on their own body, then tell them exactly what you want to happen next — no hesitating.", es: "Toma un shot de donde tu pareja elija en su propio cuerpo, luego dile exactamente lo que quieres que pase después —sin dudar." },
    twist: { en: "They must grant it the second the glass is empty.", es: "Debe concedértelo en cuanto la copa esté vacía." },
    svg: ICONS.t4Drink
  },
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Make a toast to the most intense night you've ever imagined together, then both finish your drink without breaking eye contact.", es: "Brinden por la noche más intensa que han imaginado juntos, y ambos terminen su trago sin romper el contacto visual." },
    twist: { en: "Whoever looks away first owes the other full control for 5 minutes.", es: "Quien aparte la mirada primero le debe al otro el control total por 5 minutos." },
    svg: ICONS.t4Drink
  },
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Take your shot while your partner whispers, in detail, exactly what they plan to do with you once the game ends.", es: "Toma tu shot mientras tu pareja susurra, con detalle, exactamente lo que planea hacer contigo cuando termine el juego." },
    twist: { en: "They must follow through on it the moment you both agree to stop playing.", es: "Debe cumplirlo en el momento en que ambos decidan dejar de jugar." },
    svg: ICONS.t4Drink
  },
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Feed your partner their drink slowly, making them wait between each sip until you decide they've waited long enough.", es: "Dale de beber a tu pareja lentamente, haciéndola esperar entre cada sorbo hasta que decidas que ha esperado suficiente." },
    twist: { en: "They must ask for each sip out loud.", es: "Debe pedir cada sorbo en voz alta." },
    svg: ICONS.t4Drink
  },
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Share one drink between you, trading sips, while each of you names one boundary-pushing thing you want to try tonight.", es: "Compartan un trago entre los dos, intercambiando sorbos, mientras cada uno nombra algo atrevido que quiere intentar esta noche." },
    twist: { en: "You must attempt at least one of them before the night ends.", es: "Deben intentar al menos uno antes de que termine la noche." },
    svg: ICONS.t4Drink
  },
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Take a shot together, then whoever finishes first gets to give the other one command with zero limits except your safe word.", es: "Tomen un shot juntos, y quien termine primero le da al otro una orden sin límites, salvo su palabra de seguridad." },
    twist: { en: "The command must be followed within the next 5 minutes.", es: "La orden debe cumplirse en los próximos 5 minutos." },
    svg: ICONS.t4Drink
  },

  // --- Tier 4: Extreme — more Truth (suggestive, left to the imagination) ---
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "If the rest of tonight played out exactly like the fantasy in your head, what's the last thing you'd remember before falling asleep?", es: "Si el resto de la noche fuera exactamente como la fantasía en tu cabeza, ¿cuál sería lo último que recordarías antes de dormirte?" },
    twist: { en: "Don't finish the sentence — just look at me when you get to the end.", es: "No termines la frase —solo mírame cuando llegues al final." },
    svg: ICONS.t4Truth
  },
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "Tell me the exact moment tonight when you stopped thinking and just wanted.", es: "Dime el momento exacto de esta noche en que dejaste de pensar y solo quisiste." },
    twist: { en: "If it hasn't happened yet, tell me what has to happen first.", es: "Si aún no ha pasado, dime qué tiene que pasar primero." },
    svg: ICONS.t4Truth
  },
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "What would you let happen tonight if neither of us said a single word for the next ten minutes?", es: "¿Qué dejarías que pasara esta noche si ninguno dijera una palabra en los próximos diez minutos?" },
    twist: { en: "Start the silence now. We'll find out.", es: "Empieza el silencio ahora. Lo descubriremos." },
    svg: ICONS.t4Truth
  },
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "Describe the last image in your mind before everything else stops mattering.", es: "Describe la última imagen en tu mente antes de que todo lo demás deje de importar." },
    twist: { en: "Whisper it instead of saying it out loud.", es: "Susúrralo en lugar de decirlo en voz alta." },
    svg: ICONS.t4Truth
  },
  {
    tier: 4, type: "Truth", time: 0,
    text: { en: "What's something you want tonight that you've never had to ask for before, because I already knew?", es: "¿Qué es algo que quieres esta noche que nunca has tenido que pedir, porque yo ya lo sabía?" },
    twist: { en: "Let's find out if I still know.", es: "Veamos si todavía lo sé." },
    svg: ICONS.t4Truth
  },

  // --- Tier 4: Extreme — more Dare (suggestive, left to the imagination) ---
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "Turn off the lights for the next 3 minutes and let touch do all the deciding — no talking, no rushing.", es: "Apaguen las luces por los próximos 3 minutos y dejen que el tacto decida todo —sin hablar, sin apurarse." },
    twist: { en: "Whoever breaks the silence first loses control of what happens next.", es: "Quien rompa el silencio primero pierde el control de lo que sigue." },
    svg: ICONS.t4Dare
  },
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "Spend 3 minutes undressing your partner with your eyes only — no hands — then let them decide what happens the second you touch them.", es: "Pasen 3 minutos desvistiendo a su pareja solo con la mirada —sin manos— y dejen que decidan qué pasa en cuanto la toquen." },
    twist: { en: "They choose the first move. You follow.", es: "Ellos eligen el primer movimiento. Tú sigues." },
    svg: ICONS.t4Dare
  },
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "Make your partner wait exactly 3 minutes for something they clearly want, without explaining why.", es: "Hagan que su pareja espere exactamente 3 minutos por algo que claramente quiere, sin explicar por qué." },
    twist: { en: "When the timer ends, let them decide if the wait was worth it.", es: "Cuando termine el tiempo, dejen que decidan si valió la pena esperar." },
    svg: ICONS.t4Dare
  },
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "Trade one whispered instruction every 30 seconds for 3 minutes — no questions, just follow.", es: "Intercambien una instrucción susurrada cada 30 segundos durante 3 minutos —sin preguntas, solo obedezcan." },
    twist: { en: "The last instruction has to be the boldest one yet.", es: "La última instrucción debe ser la más atrevida de todas." },
    svg: ICONS.t4Dare
  },
  {
    tier: 4, type: "Dare", time: 180,
    text: { en: "Spend 3 minutes somewhere private with one rule only: nothing stops until you both agree it should.", es: "Pasen 3 minutos en un lugar privado con una sola regla: nada se detiene hasta que ambos acuerden que debe parar." },
    twist: { en: "Let the timer run out before either of you speaks again.", es: "Dejen que el tiempo se acabe antes de que alguno vuelva a hablar." },
    svg: ICONS.t4Dare
  },

  // --- Tier 4: Extreme — more Drink (suggestive, left to the imagination) ---
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Take your drink slowly while your partner describes, without details, exactly how the rest of the night is going to feel.", es: "Toma tu trago lentamente mientras tu pareja describe, sin detalles, exactamente cómo se va a sentir el resto de la noche." },
    twist: { en: "When the glass is empty, the night starts exactly like they said.", es: "Cuando la copa esté vacía, la noche empieza exactamente como dijeron." },
    svg: ICONS.t4Drink
  },
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Finish your drink while maintaining eye contact, then let your partner lead wherever they want to go next — literally.", es: "Termina tu trago manteniendo contacto visual, luego deja que tu pareja te lleve a donde quiera —literalmente." },
    twist: { en: "No questions allowed until you get there.", es: "No se permiten preguntas hasta llegar." },
    svg: ICONS.t4Drink
  },
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Share a drink in silence, and when it's empty, whoever speaks first has to say exactly what they want, out loud.", es: "Compartan un trago en silencio, y cuando se termine, quien hable primero debe decir exactamente qué quiere, en voz alta." },
    twist: { en: "The other has to act on it immediately.", es: "El otro debe actuarlo de inmediato." },
    svg: ICONS.t4Drink
  },
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Take a slow sip while your partner traces where they plan to go next — you won't know until the glass is empty.", es: "Da un sorbo lento mientras tu pareja traza a dónde planea ir después —no lo sabrás hasta que la copa esté vacía." },
    twist: { en: "They decide the pace once it starts.", es: "Ellos deciden el ritmo una vez que empieza." },
    svg: ICONS.t4Drink
  },
  {
    tier: 4, type: "Drink", time: 0,
    text: { en: "Finish your drink together without breaking contact — hands, eyes, or otherwise — and let whatever happens next happen.", es: "Terminen su trago juntos sin romper el contacto —manos, ojos, o lo que sea— y dejen que pase lo que tenga que pasar." },
    twist: { en: "No one calls it. It just continues.", es: "Nadie lo anuncia. Simplemente continúa." },
    svg: ICONS.t4Drink
  }
];

// One-time special card unlocked at Heat Level 10
const finaleCard = {
  tier: "finale", type: "Wildcard", time: 0,
  text: {
    en: "THE FINALE: You've generated enough heat for one last, no-limits request. Ask your partner for anything you want tonight — truth, dare, or otherwise — and they must grant it.",
    es: "EL FINAL: Han generado suficiente calor para una última petición sin límites. Pídele a tu pareja lo que quieras esta noche —verdad, reto o lo que sea— y debe concedértelo."
  },
  twist: {
    en: "Seal the deal with a kiss that lasts as long as you both want it to.",
    es: "Sellen el trato con un beso que dure todo lo que ambos quieran."
  },
  svg: `<path d="m12 2 2.2 6.8L21 11l-6.8 2.2L12 20l-2.2-6.8L3 11l6.8-2.2Z" fill="url(#gradFlame)"/><path d="M5 4l1 3-3 1 3 1-1 3 3-2 3 2-1-3 3-1-3-1 1-3-3 2Z" fill="url(#gradGold)"/><circle cx="19" cy="4" r="1.6" fill="url(#gradGold)"/>`
};

// Penalty Wheel segments: labelKey points into uiText; effect decides what happens on continue
const penaltySegments = [
  { effect: "sip", labelKey: "wheelSegSip", color: "#e63956" },
  { effect: "truth", labelKey: "wheelSegTruth", color: "#8fd8e0" },
  { effect: "dare", labelKey: "wheelSegDare", color: "#ff708f" },
  { effect: "kiss", labelKey: "wheelSegKiss", color: "#e2a8af" },
  { effect: "heat", labelKey: "wheelSegHeat", color: "#f4c430" },
  { effect: "compliment", labelKey: "wheelSegCompliment", color: "#8fd8e0" },
  { effect: "freeze", labelKey: "wheelSegFreeze", color: "#e2a8af" },
  { effect: "partner", labelKey: "wheelSegPartner", color: "#ff708f" }
];

let customDeck = JSON.parse(localStorage.getItem("afterHoursCustomDeck") || "[]");
let importedDeck = JSON.parse(localStorage.getItem("afterHoursImportedDeck") || "[]");
let savedPasses = JSON.parse(localStorage.getItem("afterHoursPasses") || "null");
if (savedPasses) passesLeft = savedPasses;
let savedNames = JSON.parse(localStorage.getItem("afterHoursNames") || "null");
if (savedNames) playerNames = savedNames;
let savedPlayerCount = JSON.parse(localStorage.getItem("afterHoursPlayerCount") || "null");
if (savedPlayerCount) playerCount = savedPlayerCount;

function handleExpansionPackFile(event) {
  const file = event.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    try {
      const parsed = JSON.parse(reader.result);
      if (!Array.isArray(parsed)) throw new Error("not an array");
      const valid = parsed.filter((c) =>
        [1, 2, 3, 4].includes(c.tier) &&
        ["Truth", "Dare", "Drink"].includes(c.type) &&
        c.text && typeof c.text.en === "string" && typeof c.text.es === "string"
      );
      if (valid.length === 0) throw new Error("no valid cards");
      valid.forEach((c) => {
        c.svg = ICONS[iconKeyFor(c)] || ICONS.custom;
        if (typeof c.time !== "number") c.time = 0;
      });
      importedDeck = importedDeck.concat(valid);
      localStorage.setItem("afterHoursImportedDeck", JSON.stringify(importedDeck));
      alert(`${valid.length} ${uiText[currentLang].importPackSuccess}`);
    } catch (err) {
      alert(uiText[currentLang].importPackError);
    }
    event.target.value = "";
  };
  reader.readAsText(file);
}

function exportMyCards() {
  const combined = [...customDeck, ...importedDeck];
  if (combined.length === 0) {
    alert(uiText[currentLang].exportCardsEmpty);
    return;
  }
  const exportable = combined.map(({ tier, type, time, text, twist }) => ({ tier, type, time, text, twist }));
  const blob = new Blob([JSON.stringify(exportable, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "entre-nosotros-cards.json";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

// ---------- Manage / Delete Custom Cards ----------
function openManageCards() {
  const t = uiText[currentLang];
  document.getElementById("manageCardsTitle").textContent = t.manageCardsTitle;
  document.getElementById("manageCardsCloseBtn").textContent = t.manageCardsCloseBtn;
  renderManageCardsList();
  openModal("manageCardsModal");
}

function renderManageCardsList() {
  const t = uiText[currentLang];
  const listEl = document.getElementById("manageCardsList");
  const all = [
    ...customDeck.map((card, index) => ({ card, source: "custom", index })),
    ...importedDeck.map((card, index) => ({ card, source: "imported", index }))
  ];

  if (all.length === 0) {
    listEl.innerHTML = `<p style="color: var(--text-muted); font-size: 0.85rem;">${t.manageCardsEmpty}</p>`;
    return;
  }

  listEl.innerHTML = all.map(({ card, source, index }) => {
    const fullText = card.text[currentLang] || "";
    const snippet = fullText.length > 70 ? fullText.slice(0, 70) + "…" : fullText;
    const tierLabel = t.tierLabels[card.tier] || card.tier;
    const typeLabel = t.typeLabels[card.type] || card.type;
    return `
      <div class="manage-card-row">
        <div class="manage-card-info">
          <span class="manage-card-badge">${tierLabel} · ${typeLabel}</span>
          <p class="manage-card-text">${snippet}</p>
        </div>
        <button class="manage-card-delete" onclick="deleteManagedCard('${source}', ${index})" title="${t.manageCardsDelete}">🗑️</button>
      </div>
    `;
  }).join("");
}

function deleteManagedCard(source, index) {
  if (source === "custom") {
    customDeck.splice(index, 1);
    localStorage.setItem("afterHoursCustomDeck", JSON.stringify(customDeck));
  } else {
    importedDeck.splice(index, 1);
    localStorage.setItem("afterHoursImportedDeck", JSON.stringify(importedDeck));
  }
  renderManageCardsList();
}

function startGameSession() {
  passLimit = parseInt(document.getElementById("setupPassLimit").value, 10);
  includeDrinks = document.getElementById("setupDrinkDares").value === "yes";
  includeExtreme = document.getElementById("setupExtreme").value === "yes";
  document.getElementById("tier4Btn").style.display = includeExtreme ? "inline-block" : "none";
  AudioFX.setMuted(document.getElementById("setupSound").value === "off");
  updateMuteButton();

  playerCount = parseInt(document.getElementById("setupPlayerCount").value, 10);
  playerNames = {};
  passesLeft = {};
  passesUsedTotal = {};
  document.querySelectorAll(".playerNameInput").forEach((el) => {
    playerNames[el.dataset.n] = el.value.trim();
  });
  for (let i = 1; i <= playerCount; i++) {
    passesLeft[i] = passLimit;
    passesUsedTotal[i] = 0;
  }

  currentTurn = 1;
  finaleShown = false;
  cardsCompleted = 0;
  tiersPlayed = new Set();
  sessionStartTime = Date.now();
  saveState();

  lifetimeStats.gamesPlayed++;
  saveLifetimeStats();

  closeModal("setupModal");
  updatePassDisplay();
  rebuildDrawBag();
  cardOfDayPending = true;
  nextCard(true, getCardOfTheDay());
}

// Shuffle-bag draw: deals every card in the active deck once before any repeat
function shuffleArray(arr) {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function rebuildDrawBag() {
  drawBag = shuffleArray(getActiveDeck());
}

// Same date -> same card for everyone, so the first draw of the day feels special
function getCardOfTheDay() {
  // Scoped to defaultDeck only (not customDeck/importedDeck) so the date-seeded pick
  // is genuinely "the same card for everyone," regardless of anyone's custom content.
  let pool = includeDrinks ? defaultDeck : defaultDeck.filter((c) => c.type !== "Drink");
  if (!includeExtreme) pool = pool.filter((c) => c.tier !== 4);
  pool = pool.filter((c) => heatPoints >= (TIER_UNLOCK_HEAT[c.tier] || 0));
  const dateStr = new Date().toISOString().slice(0, 10);
  let hash = 0;
  for (let i = 0; i < dateStr.length; i++) {
    hash = (hash * 31 + dateStr.charCodeAt(i)) >>> 0;
  }
  return pool[hash % pool.length];
}

function drawFromBag() {
  if (drawBag.length === 0) {
    rebuildDrawBag();
    if (drawBag.length > 1 && drawBag[drawBag.length - 1] === lastDrawnCard) {
      const lastIdx = drawBag.length - 1;
      const swapIdx = Math.floor(Math.random() * lastIdx);
      [drawBag[lastIdx], drawBag[swapIdx]] = [drawBag[swapIdx], drawBag[lastIdx]];
    }
  }
  const card = drawBag.pop();
  lastDrawnCard = card;
  return card;
}

function saveState() {
  localStorage.setItem("afterHoursCustomDeck", JSON.stringify(customDeck));
  localStorage.setItem("afterHoursPasses", JSON.stringify(passesLeft));
  localStorage.setItem("afterHoursNames", JSON.stringify(playerNames));
  localStorage.setItem("afterHoursPlayerCount", JSON.stringify(playerCount));
}

function getActiveDeck() {
  let combined = [...defaultDeck, ...customDeck, ...importedDeck];
  if (!includeDrinks) {
    combined = combined.filter(c => c.type !== "Drink");
  }
  if (!includeExtreme) {
    combined = combined.filter(c => c.tier !== 4);
  }
  combined = combined.filter(c => heatPoints >= (TIER_UNLOCK_HEAT[c.tier] || 0));
  if (activeTier === "all") return combined;
  return combined.filter(c => c.tier === activeTier);
}

function setLanguage(lang) {
  currentLang = lang;
  updateUIText();
  if (currentCard) renderCurrentCard();
}

function toggleLanguage() {
  setLanguage(currentLang === "en" ? "es" : "en");
}

function updateUIText() {
  const t = uiText[currentLang];
  document.getElementById("langBtn").textContent = t.langBtn;
  document.getElementById("subtitleText").textContent = t.subtitle;
  document.getElementById("tierAllBtn").textContent = t.tierAll;
  document.getElementById("tier1Btn").textContent = t.tier1;
  document.getElementById("tier2Btn").textContent = t.tier2;
  document.getElementById("tier3Btn").textContent = t.tier3;
  document.getElementById("tier4Btn").textContent = t.tier4;
  document.getElementById("turnDisplay").textContent = t.turnPrefix + getPlayerLabel(currentTurn);
  document.getElementById("frontTitle").textContent = t.frontTitle;
  document.getElementById("frontSub").textContent = t.frontSub;
  document.getElementById("passBtn").textContent = t.passBtn;
  document.getElementById("nextBtn").textContent = t.nextBtn;
  document.getElementById("customHeader").textContent = t.customHeader;
  document.getElementById("optTier1").textContent = t.optTier1;
  document.getElementById("optTier2").textContent = t.optTier2;
  document.getElementById("optTier3").textContent = t.optTier3;
  document.getElementById("optTier4").textContent = t.optTier4;
  document.getElementById("optTruth").textContent = t.optTruth;
  document.getElementById("optDare").textContent = t.optDare;
  document.getElementById("optDrink").textContent = t.optDrink;
  document.getElementById("customPrompt").placeholder = t.placeholder;
  document.getElementById("addCustomBtn").textContent = t.addCustomBtn;
  document.getElementById("importPackHint").textContent = t.importPackHint;
  document.getElementById("exportCardsBtn").textContent = t.exportCardsBtn;
  document.getElementById("manageCardsBtn").textContent = t.manageCardsBtn;

  // Setup modal text
  document.getElementById("modalTitle").textContent = t.modalTitle;
  document.getElementById("modalDesc").textContent = t.modalDesc;
  document.getElementById("htpLinkBtn").textContent = t.htpLinkBtn;
  document.getElementById("labelLanguage").textContent = t.labelLanguage;
  document.getElementById("setupLanguage").value = currentLang;
  document.getElementById("labelPlayerCount").textContent = t.labelPlayerCount;
  document.getElementById("labelNames").textContent = t.labelNames;
  updateNameInputPlaceholders();
  document.getElementById("labelPassLimit").textContent = t.labelPassLimit;
  document.getElementById("optPassInf").textContent = t.optPassInf;
  document.getElementById("optPass3").textContent = t.optPass3;
  document.getElementById("optPass2").textContent = t.optPass2;
  document.getElementById("optPass1").textContent = t.optPass1;
  document.getElementById("labelDrinkDares").textContent = t.labelDrinkDares;
  document.getElementById("optDrinkYes").textContent = t.optDrinkYes;
  document.getElementById("optDrinkNo").textContent = t.optDrinkNo;
  document.getElementById("labelExtreme").textContent = t.labelExtreme;
  document.getElementById("optExtremeYes").textContent = t.optExtremeYes;
  document.getElementById("optExtremeNo").textContent = t.optExtremeNo;
  document.getElementById("labelSound").textContent = t.labelSound;
  document.getElementById("optSoundOn").textContent = t.optSoundOn;
  document.getElementById("optSoundOff").textContent = t.optSoundOff;
  document.getElementById("startBtn").textContent = t.startBtn;

  // Penalty wheel modal text
  document.getElementById("wheelTitle").textContent = t.wheelTitle;
  document.getElementById("wheelDesc").textContent = t.wheelDesc;
  document.getElementById("wheelSpinBtn").textContent = t.wheelSpinBtn;
  document.getElementById("wheelContinueBtn").textContent = t.wheelContinueBtn;

  document.getElementById("heatMeterDisplay").textContent = `🔥 Heat: Level ${Math.floor(heatPoints/3) + 1} (${heatPoints} pts)`;
  updateTierLockState();
}

function updatePassDisplay() {
  const parts = [];
  for (let i = 1; i <= playerCount; i++) {
    parts.push(`${getPlayerLabel(i)}(${passesLeft[i]})`);
  }
  document.getElementById("passTrackerDisplay").textContent = parts.join(" | ");
}

function renderCurrentCard() {
  const t = uiText[currentLang];
  document.getElementById("cardTierLabel").textContent = t.tierLabels[currentCard.tier];
  document.getElementById("cardTypeLabel").textContent = t.typeLabels[currentCard.type] || currentCard.type;
  document.getElementById("cardPrompt").textContent = currentCard.text[currentLang];

  const ribbon = document.getElementById("cardOfDayRibbon");
  if (cardOfDayPending) {
    ribbon.textContent = t.cardOfDayLabel;
    ribbon.style.display = "block";
    cardOfDayPending = false;
  } else {
    ribbon.style.display = "none";
  }

  if (Icon3D.isReady) {
    Icon3D.setCard(iconKeyFor(currentCard), currentCard.type);
  } else if (currentCard.svg) {
    const inner = document.getElementById("figurineInner");
    inner.innerHTML = `<svg width="48" height="48" viewBox="0 0 24 24">${currentCard.svg}</svg>`;
  }

  document.getElementById("spicyTwistBox").classList.remove("visible");
  document.getElementById("spicyText").textContent = currentCard.twist ? currentCard.twist[currentLang] : "Bonus Twist!";
}

function setTier(tier, btnEl) {
  if (tier !== "all" && heatPoints < (TIER_UNLOCK_HEAT[tier] || 0)) return;
  activeTier = tier;
  document.querySelectorAll(".tier-btn").forEach(b => b.classList.remove("active"));
  btnEl.classList.add("active");
  rebuildDrawBag();
  nextCard(true);
}

function updateTierLockState() {
  const t = uiText[currentLang];
  const tierLabelKeys = { 2: "tier2", 3: "tier3" };
  [2, 3].forEach((tier) => {
    const btn = document.getElementById(`tier${tier}Btn`);
    const threshold = TIER_UNLOCK_HEAT[tier];
    const unlocked = heatPoints >= threshold;
    btn.disabled = !unlocked;
    btn.classList.toggle("locked", !unlocked);
    btn.textContent = (unlocked ? "" : "🔒 ") + t[tierLabelKeys[tier]];
    btn.title = unlocked ? "" : `${t.tierLockedHint} ${threshold}`;
  });
}

function flipCard() {
  const cardEl = document.getElementById("gameCard");
  cardEl.classList.toggle("is-flipped");
  AudioFX.playChime();
}

function nextCard(isSkip, forcedCard) {
  clearInterval(timerInterval);
  timerInterval = null;

  const cardEl = document.getElementById("gameCard");

  if (forcedCard) {
    currentCard = forcedCard;
  } else {
    const deck = getActiveDeck();
    if (deck.length === 0) {
      alert("No cards available in this filter!");
      return;
    }
    currentCard = drawFromBag();
  }

  if (!isSkip) {
    currentTurn = (currentTurn % playerCount) + 1;
  }
  document.getElementById("turnDisplay").textContent = uiText[currentLang].turnPrefix + getPlayerLabel(currentTurn);

  cardEl.classList.remove("is-flipped");

  setTimeout(() => {
    renderCurrentCard();

    const timerBox = document.getElementById("timerBox");
    if (currentCard.time && currentCard.time > 0) {
      remainingSeconds = currentCard.time;
      updateTimerDisplay();
      document.getElementById("timerBtn").textContent = uiText[currentLang].startTimer;
      timerBox.classList.add("visible");
    } else {
      timerBox.classList.remove("visible");
    }

    cardEl.classList.add("is-flipped");
    AudioFX.playChime();
    if (currentCard.tier === "finale") Confetti3D.burst();
  }, 280);
}

// Draws a card of a specific type, bypassing the normal shuffle bag (used by penalty wheel outcomes)
function forceNextCard(type) {
  let pool = getActiveDeck().filter(c => c.type === type);
  if (pool.length === 0) {
    pool = [...defaultDeck, ...customDeck, ...importedDeck].filter(c =>
      c.type === type && (includeExtreme || c.tier !== 4)
    );
  }
  const card = pool[Math.floor(Math.random() * pool.length)];
  nextCard(false, card);
}

function passCard() {
  if (passesLeft[currentTurn] > 0) {
    passesLeft[currentTurn]--;
    passesUsedTotal[currentTurn]++;
    updatePassDisplay();
    saveState();
    nextCard(false);
  } else {
    openPenaltyWheel();
  }
}

// Increments heat and reports whether Level 10's finale card just unlocked
function addHeat(amount) {
  heatPoints += amount;
  updateUIText();
  if (heatPoints >= 10 && !finaleShown) {
    finaleShown = true;
    return true;
  }
  return false;
}

function completeCard() {
  cardsCompleted++;
  lifetimeStats.cardsCompleted++;
  saveLifetimeStats();
  if (typeof currentCard.tier === "number") tiersPlayed.add(currentCard.tier);
  if (addHeat(1)) {
    triggerFinale();
  } else {
    nextCard(false);
  }
}

// Shared by both ways of reaching Heat 10 (completing a card, or the Penalty Wheel's
// "+2 Heat" outcome), so the lifetime finale count is only ever recorded in one place.
function triggerFinale() {
  lifetimeStats.finalesReached++;
  saveLifetimeStats();
  nextCard(false, finaleCard);
}

// ---------- Penalty Wheel ----------
function buildWheelSVG() {
  const t = uiText[currentLang];
  const segCount = penaltySegments.length;
  const segAngle = 360 / segCount;
  const cx = 100, cy = 100, r = 95, labelR = 62;
  const toXY = (deg, radius) => {
    const rad = (deg * Math.PI) / 180;
    return { x: cx + radius * Math.sin(rad), y: cy - radius * Math.cos(rad) };
  };

  let svg = `<svg width="100%" height="100%" viewBox="0 0 200 200">`;
  penaltySegments.forEach((seg, i) => {
    const a0 = i * segAngle;
    const a1 = a0 + segAngle;
    const p0 = toXY(a0, r);
    const p1 = toXY(a1, r);
    svg += `<path d="M ${cx} ${cy} L ${p0.x.toFixed(2)} ${p0.y.toFixed(2)} A ${r} ${r} 0 0 1 ${p1.x.toFixed(2)} ${p1.y.toFixed(2)} Z" fill="${seg.color}" stroke="#09050b" stroke-width="1.5"/>`;

    const mid = a0 + segAngle / 2;
    const flip = mid > 90 && mid < 270;
    const labelY = (cy - labelR).toFixed(2);
    svg += `<g transform="rotate(${mid} ${cx} ${cy})"><text x="${cx}" y="${labelY}" transform="rotate(${flip ? 180 : 0} ${cx} ${labelY})" text-anchor="middle" font-size="9" font-weight="700" fill="#180a1e">${t[seg.labelKey]}</text></g>`;
  });
  svg += `<circle cx="${cx}" cy="${cy}" r="14" fill="#180a1e" stroke="#e2a8af" stroke-width="2"/>`;
  svg += `</svg>`;
  return svg;
}

function openPenaltyWheel() {
  document.getElementById("wheelRotor").innerHTML = buildWheelSVG();
  const rotor = document.getElementById("wheelRotor");
  rotor.style.transition = "none";
  rotor.style.transform = "rotate(0deg)";
  wheelRotation = 0;
  wheelSpinning = false;
  pendingPenaltyEffect = null;

  document.getElementById("wheelResult").style.display = "none";
  document.getElementById("wheelSpinBtn").style.display = "block";
  document.getElementById("wheelSpinBtn").disabled = false;
  document.getElementById("wheelContinueBtn").style.display = "none";
  openModal("penaltyWheelModal");
}

function spinPenaltyWheel() {
  if (wheelSpinning) return;
  wheelSpinning = true;
  document.getElementById("wheelSpinBtn").disabled = true;

  const segCount = penaltySegments.length;
  const segAngle = 360 / segCount;
  const extraSpins = 4 + Math.floor(Math.random() * 3);
  const randomOffset = Math.random() * 360;
  wheelRotation += extraSpins * 360 + randomOffset;

  const rotor = document.getElementById("wheelRotor");
  rotor.style.transition = "transform 3.2s cubic-bezier(0.12, 0.67, 0.1, 0.99)";
  rotor.style.transform = `rotate(${wheelRotation}deg)`;
  AudioFX.playChime();

  setTimeout(() => {
    const normalized = ((wheelRotation % 360) + 360) % 360;
    const pointerAngle = (360 - normalized) % 360;
    const index = Math.min(segCount - 1, Math.floor(pointerAngle / segAngle));
    const segment = penaltySegments[index];
    pendingPenaltyEffect = segment.effect;

    document.getElementById("wheelResult").textContent = uiText[currentLang][segment.labelKey];
    document.getElementById("wheelResult").style.display = "block";
    document.getElementById("wheelSpinBtn").style.display = "none";
    document.getElementById("wheelContinueBtn").style.display = "block";
    wheelSpinning = false;
  }, 3200);
}

function continuePenalty() {
  closeModal("penaltyWheelModal");
  const effect = pendingPenaltyEffect;
  pendingPenaltyEffect = null;

  if (effect === "heat") {
    if (addHeat(2)) {
      triggerFinale();
      return;
    }
  } else if (effect === "dare") {
    forceNextCard("Dare");
    return;
  } else if (effect === "truth") {
    forceNextCard("Truth");
    return;
  } else if (effect === "partner") {
    // "Someone else decides" — picks a random type instead of always forcing a Dare,
    // so it's a genuinely different outcome from the Double Dare segment.
    const types = includeDrinks ? ["Truth", "Dare", "Drink"] : ["Truth", "Dare"];
    forceNextCard(types[Math.floor(Math.random() * types.length)]);
    return;
  }
  nextCard(false);
}

// ---------- Session Recap ----------
function openRecap() {
  const t = uiText[currentLang];
  const level = Math.floor(heatPoints / 3) + 1;
  const minutes = sessionStartTime ? Math.max(0, Math.round((Date.now() - sessionStartTime) / 60000)) : 0;

  document.getElementById("recapTitle").textContent = t.recapTitle;
  document.getElementById("recapHeat").textContent = `${t.recapHeatLabel} ${level} (${heatPoints} pts)`;
  document.getElementById("recapCards").textContent = `${t.recapCardsLabel} ${cardsCompleted}`;
  const passesParts = [];
  for (let i = 1; i <= playerCount; i++) {
    passesParts.push(`${getPlayerLabel(i)}: ${passesUsedTotal[i]}`);
  }
  document.getElementById("recapPasses").textContent = `${t.recapPassesLabel} ${passesParts.join(" | ")}`;
  document.getElementById("recapTime").textContent = `${t.recapTimeLabel} ${minutes} min`;
  document.getElementById("recapFinale").textContent = finaleShown ? t.recapFinaleYes : t.recapFinaleNo;
  document.getElementById("recapCloseBtn").textContent = t.recapCloseBtn;

  const badges = computeBadges();
  const badgesEl = document.getElementById("recapBadges");
  badgesEl.innerHTML = badges.length
    ? badges.map((b) => `<span class="recap-badge">${b.label}</span>`).join("")
    : `<span class="recap-badge-empty">${t.badgeNone}</span>`;

  let newlyEarned = false;
  badges.forEach((b) => {
    if (!lifetimeStats.badgesEarned.includes(b.key)) {
      lifetimeStats.badgesEarned.push(b.key);
      newlyEarned = true;
    }
  });
  if (newlyEarned) saveLifetimeStats();

  document.getElementById("recapLifetimeTitle").textContent = t.recapLifetimeTitle;
  document.getElementById("recapLifetimeGames").textContent = `${t.recapLifetimeGames} ${lifetimeStats.gamesPlayed}`;
  document.getElementById("recapLifetimeCards").textContent = `${t.recapLifetimeCards} ${lifetimeStats.cardsCompleted}`;
  document.getElementById("recapLifetimeFinales").textContent = `${t.recapLifetimeFinales} ${lifetimeStats.finalesReached}`;

  openModal("recapModal");
}

function computeBadges() {
  const t = uiText[currentLang];
  const badges = [];
  const noPassesUsed = Array.from({ length: playerCount }, (_, i) => i + 1)
    .every((i) => passesUsedTotal[i] === 0);
  if (cardsCompleted > 0 && noPassesUsed) {
    badges.push({ key: "badgeNoPasses", label: t.badgeNoPasses });
  }
  if (tiersPlayed.has(1) && tiersPlayed.has(2) && tiersPlayed.has(3)) {
    badges.push({ key: "badgeAllTiers", label: t.badgeAllTiers });
  }
  if (finaleShown) {
    badges.push({ key: "badgeFinale", label: t.badgeFinale });
  }
  return badges;
}

function closeRecap() {
  closeModal("recapModal");
}

function revealSpicyTwist() {
  document.getElementById("spicyTwistBox").classList.toggle("visible");
}


function updateTimerDisplay() {
  const mins = String(Math.floor(remainingSeconds / 60)).padStart(2, "0");
  const secs = String(remainingSeconds % 60).padStart(2, "0");
  document.getElementById("timerDisplay").textContent = mins + ":" + secs;
}

function startCountdown() {
  document.getElementById("timerBtn").textContent = uiText[currentLang].pauseTimer;
  timerInterval = setInterval(() => {
    if (remainingSeconds > 0) {
      remainingSeconds--;
      updateTimerDisplay();
    } else {
      clearInterval(timerInterval);
      timerInterval = null;
      document.getElementById("timerBtn").textContent = uiText[currentLang].timesUp;
    }
  }, 1000);
}

function toggleTimer() {
  const t = uiText[currentLang];
  if (timerInterval) {
    clearInterval(timerInterval);
    timerInterval = null;
    document.getElementById("timerBtn").textContent = t.resumeTimer;
  } else {
    AudioFX.playCrackle();
    startCountdown();
  }
}

// ---------- Safe Word / Pause ----------
let safePauseResumeTimer = false;

function openSafePause() {
  safePauseResumeTimer = !!timerInterval;
  if (timerInterval) {
    clearInterval(timerInterval);
    timerInterval = null;
  }
  const t = uiText[currentLang];
  document.getElementById("safePauseTitle").textContent = t.safePauseTitle;
  document.getElementById("safePauseDesc").textContent = t.safePauseDesc;
  document.getElementById("safePauseResumeBtn").textContent = t.safePauseResumeBtn;
  openModal("safePauseModal");
}

function closeSafePause() {
  closeModal("safePauseModal");
  if (safePauseResumeTimer && remainingSeconds > 0) {
    startCountdown();
  }
  safePauseResumeTimer = false;
}

// ---------- How to Play ----------
function openHowToPlay() {
  const t = uiText[currentLang];
  document.getElementById("htpTitle").textContent = t.htpTitle;
  document.getElementById("htpContent").innerHTML = t.htpContent;
  document.getElementById("htpCloseBtn").textContent = t.htpCloseBtn;
  openModal("howToPlayModal");
}

function closeHowToPlay() {
  closeModal("howToPlayModal");
}

function addCustomCard() {
  const tier = parseInt(document.getElementById("customTier").value, 10);
  const type = document.getElementById("customType").value;
  const input = document.getElementById("customPrompt");
  const text = input.value.trim();

  if (!text) return;

  customDeck.push({
    tier: tier,
    type: type,
    time: 0,
    text: { en: text, es: text },
    twist: { en: "Make it twice as slow.", es: "Hazlo el doble de lento." },
    svg: ICONS.custom
  });

  input.value = "";
  saveState();
  alert(currentLang === "es" ? "¡Carta personalizada guardada y añadida!" : "Custom card saved and added to deck!");
}

updateUIText();
updateMuteButton();
document.getElementById("setupSound").value = AudioFX.isMuted() ? "off" : "on";
document.getElementById("setupPlayerCount").value = playerCount;
renderNameInputs(false);

// Drag-to-tilt / tap-to-spin for the flat SVG icon, used only if the 3D icon fails to init
function setupFlatIconFallback() {
  const stage = document.getElementById("figurineStage");
  const inner = document.getElementById("figurineInner");
  let dragging = false;
  let moved = false;
  let startX = 0;
  let startY = 0;

  stage.addEventListener("pointerdown", (e) => {
    e.stopPropagation();
    dragging = true;
    moved = false;
    startX = e.clientX;
    startY = e.clientY;
    inner.style.transition = "none";
  });

  stage.addEventListener("pointermove", (e) => {
    if (!dragging) return;
    const dx = e.clientX - startX;
    const dy = e.clientY - startY;
    if (Math.abs(dx) > 4 || Math.abs(dy) > 4) moved = true;
    const rotateY = Math.max(-40, Math.min(40, dx / 2));
    const rotateX = Math.max(-40, Math.min(40, -dy / 2));
    inner.style.transform = `rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
  });

  function endDrag(e) {
    if (!dragging) return;
    e.stopPropagation();
    dragging = false;
    inner.style.transition = "transform 0.5s cubic-bezier(0.2, 0.8, 0.2, 1)";
    if (!moved) {
      inner.style.transform = "rotateY(360deg)";
      setTimeout(() => {
        inner.style.transition = "none";
        inner.style.transform = "rotateY(0deg)";
      }, 500);
    } else {
      inner.style.transform = "rotateX(0deg) rotateY(0deg)";
    }
  }

  stage.addEventListener("pointerup", endDrag);
  stage.addEventListener("pointerleave", endDrag);
}

const icon3DReady = Icon3D.init(document.getElementById("figurineStage"), document.getElementById("figurineInner"));
if (!icon3DReady) {
  setupFlatIconFallback();
}

// Service workers require http(s) — this is a no-op when the file is opened directly (file://)
if ("serviceWorker" in navigator && location.protocol.startsWith("http")) {
  navigator.serviceWorker.register("service-worker.js").catch(() => {});
}
