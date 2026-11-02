extends RefCounted

const TEXTS := {
	"es": {
		"brand_tagline": "EL JUEGO QUE ENCIENDE LA CONEXIÓN",
		"hero_title": "¿Listos para jugar?",
		"hero_sub": "Retos, seducción y mucha complicidad...",
		"nav_home": "Inicio",
		"nav_play": "Jugar",
		"nav_cats": "Categorías",
		"nav_couple": "Pareja",
		"nav_settings": "Idioma",
		"main_play": "Jugar ahora",
		"howto_title": "Cómo jugar",
		"step_1": "Elijan una categoría.",
		"step_2": "Roben una carta por turno.",
		"step_3": "Cumplan el reto... ¡y disfruten!",
		"btn_dice": "Dados de Seducción",
		"btn_wheel": "Ruleta de Castigo",
		"choose_cat": "Elige una categoría",
		"cats": {
			1: {"title": "Calentamiento", "sub": "Rompe el hielo"},
			2: {"title": "Seducción", "sub": "Provoca y disfruta"},
			3: {"title": "Intimidad", "sub": "Conecta más profundo"},
			4: {"title": "Retos Atrevidos", "sub": "¿Se atreven?"},
			5: {"title": "Sin Límites", "sub": "Solo para parejas sin tabúes"}
		},
		"types": {
			"Truth": "VERDAD",
			"Dare": "RETO",
			"Drink": "BRINDIS",
			"Dice": "DADOS",
			"Secret": "¿COINCIDEN?"
		},
		"turn_of": "Turno de ",
		"heat_label": "COMPLICIDAD",
		"passes_left": " Pases",
		"twist_btn": "+ Subir el tono",
		"pass_btn": "Cambiar carta",
		"done_btn": "¡Reto cumplido!",
		"stamp_done": "CUMPLIDO",
		"stamp_pass": "PASAR",
		"secret_p1_hint": "Elige en secreto: ",
		"secret_p2_hint": "Ahora elige: ",
		"secret_match": "¡COINCIDIERON! (+2 Complicidad) · Celébrenlo con un beso de 15s",
		"secret_diff": "¡Distinto! Quien eligió último cumple la opción del otro ahora",
		"dice_title": "Dados de Seducción",
		"dice_sub": "Lanza los dados y cumplan la combinación",
		"wheel_title": "Ruleta de Castigo",
		"wheel_sub": "Gira la ruleta para descubrir tu penitencia",
		"roll_again": "Lanzar de nuevo",
		"spin_again": "Girar ruleta",
		"back_table": "Volver a la mesa",
		"climax_title": "Los 3 Sobres Dorados",
		"climax_sub": "¡Complicidad al máximo! Elijan juntos un sobre sellado para cerrar la noche",
		"p1_default": "Jugador 1",
		"p2_default": "Jugador 2",
		"couple_title": "Nuestra Pareja",
		"couple_sub": "Personalicen sus nombres para los turnos",
		"save_couple": "Guardar y jugar"
	},
	"en": {
		"brand_tagline": "THE GAME THAT IGNITES CONNECTION",
		"hero_title": "Ready to play?",
		"hero_sub": "Dares, seduction, and deep complicity...",
		"nav_home": "Home",
		"nav_play": "Play",
		"nav_cats": "Categories",
		"nav_couple": "Couple",
		"nav_settings": "Language",
		"main_play": "Play now",
		"howto_title": "How to play",
		"step_1": "Choose a category.",
		"step_2": "Draw one card per turn.",
		"step_3": "Complete the dare... and enjoy!",
		"btn_dice": "Seduction Dice",
		"btn_wheel": "Penalty Wheel",
		"choose_cat": "Choose a category",
		"cats": {
			1: {"title": "Warm-Up", "sub": "Break the ice"},
			2: {"title": "Seduction", "sub": "Tease and enjoy"},
			3: {"title": "Intimacy", "sub": "Connect deeper"},
			4: {"title": "Bold Dares", "sub": "Do you dare?"},
			5: {"title": "No Limits", "sub": "For couples without taboos"}
		},
		"types": {
			"Truth": "TRUTH",
			"Dare": "DARE",
			"Drink": "TOAST",
			"Dice": "DICE",
			"Secret": "DO YOU MATCH?"
		},
		"turn_of": "Turn: ",
		"heat_label": "CONNECTION",
		"passes_left": " Passes",
		"twist_btn": "+ Raise the heat",
		"pass_btn": "Skip card",
		"done_btn": "Completed!",
		"stamp_done": "DONE",
		"stamp_pass": "SKIP",
		"secret_p1_hint": "Pick secretly: ",
		"secret_p2_hint": "Now pick: ",
		"secret_match": "IT'S A MATCH! (+2 Connection) · Celebrate with a 15s kiss",
		"secret_diff": "Different! The second player must grant the first player's choice",
		"dice_title": "Seduction Dice",
		"dice_sub": "Roll the dice and perform the combination",
		"wheel_title": "Penalty Wheel",
		"wheel_sub": "Spin the wheel to reveal your forfeit",
		"roll_again": "Roll again",
		"spin_again": "Spin wheel",
		"back_table": "Back to table",
		"climax_title": "The 3 Golden Envelopes",
		"climax_sub": "Max Connection reached! Choose one sealed envelope together",
		"p1_default": "Partner 1",
		"p2_default": "Partner 2",
		"couple_title": "Our Couple",
		"couple_sub": "Customize your names for each turn",
		"save_couple": "Save & play"
	}
}

const CLIMAX_ENVELOPES := [
	{
		"label_es": "Sobre I · Fantasía",
		"label_en": "Envelope I · Fantasy",
		"es": "Apaguen todas las luces por 3 minutos. Uno guía al otro solo con susurros y caricias, sin límites.",
		"en": "Turn off all lights for 3 minutes. One guides the other using only whispers and touch."
	},
	{
		"label_es": "Sobre II · Dominio",
		"label_en": "Envelope II · Command",
		"es": "Quien tenga más pases restantes tiene el mando absoluto durante los próximos 5 minutos.",
		"en": "Whoever has the most passes left takes complete command for the next 5 minutes."
	},
	{
		"label_es": "Sobre III · Entrega",
		"label_en": "Envelope III · Surrender",
		"es": "Cierren el juego ahora mismo y cumplan juntos el deseo que ambos llevan pensando toda la partida.",
		"en": "Close the game right now and fulfill the desire you've both been thinking about all night."
	}
]

const DICE_ACTIONS := [
	{"es": "Besar lento", "en": "Slow kiss"},
	{"es": "Acariciar suave", "en": "Soft caress"},
	{"es": "Susurrar en", "en": "Whisper on"},
	{"es": "Mordisquear", "en": "Gently nibble"},
	{"es": "Soplar / Hielo", "en": "Blow / Ice on"},
	{"es": "Recorrer con labios", "en": "Trace with lips"}
]

const DICE_ZONES := [
	{"es": "El cuello (15s)", "en": "The neck (15s)"},
	{"es": "Los labios (15s)", "en": "The lips (15s)"},
	{"es": "La oreja (15s)", "en": "The ear (15s)"},
	{"es": "La espalda (20s)", "en": "The back (20s)"},
	{"es": "Las muñecas", "en": "The wrists"},
	{"es": "Donde tú elijas", "en": "Your choice"}
]

const WHEEL_OUTCOMES := [
	{"es": "Beso apasionado de 20 segundos", "en": "20-second passionate kiss"},
	{"es": "Tu pareja manda por 1 minuto", "en": "Your partner commands for 1 minute"},
	{"es": "Quítate una prenda a elección", "en": "Remove one item of clothing"},
	{"es": "Brindis mirándose a los ojos", "en": "Toast while holding eye contact"},
	{"es": "Masaje sensual de 30 segundos", "en": "30-second sensual massage"},
	{"es": "Tira los Dados de Seducción", "en": "Roll the Seduction Dice"}
]

const DECK := [
	# 1. Calentamiento
	{"cat": 1, "type": "Truth", "time": 0, "es": "¿Qué fue lo primero que te atrajo de mí cuando nos conocimos?", "en": "What first attracted you to me when we met?", "twist_es": "Dilo a un centímetro de mis labios.", "twist_en": "Say it an inch from my lips."},
	{"cat": 1, "type": "Secret", "time": 0, "es": "¿Qué beso prefieres ahora mismo?", "en": "Which kiss do you prefer right now?", "opt_a_es": "Lento en los labios", "opt_b_es": "Suave en el cuello", "opt_a_en": "Slow on the lips", "opt_b_en": "Soft on the neck", "twist_es": "Hagan los dos si coinciden.", "twist_en": "Do both if you match."},
	{"cat": 1, "type": "Dare", "time": 20, "es": "Mírense fijo a los ojos durante 20 segundos sin reírse.", "en": "Hold unbroken eye contact for 20 seconds without laughing.", "twist_es": "Quien sonría primero da un beso lento.", "twist_en": "First to smile owes a slow kiss."},
	{"cat": 1, "type": "Dare", "time": 20, "es": "Dibuja un corazón en su palma con la yema del dedo muy despacio.", "en": "Trace a slow heart on their palm with your fingertip.", "twist_es": "Termina con un beso en su muñeca.", "twist_en": "Finish with a kiss on their wrist."},
	{"cat": 1, "type": "Drink", "time": 0, "es": "Brinden por esta noche y tomen un sorbo sin apartar la mirada.", "en": "Toast to tonight and take a sip without breaking eye contact.", "twist_es": "Séllenlo con un beso.", "twist_en": "Seal the toast with a kiss."},
	{"cat": 1, "type": "Truth", "time": 0, "es": "Dime tres cosas de mí que te encantan en secreto.", "en": "Tell me three things about me you secretly adore.", "twist_es": "Susúrralas directamente en mi oído.", "twist_en": "Whisper them directly in my ear."},
	{"cat": 1, "type": "Dare", "time": 30, "es": "Bailen lento abrazados durante 30 segundos, con o sin música.", "en": "Slow dance close together for 30 seconds, with or without music.", "twist_es": "Mantengan las frentes juntas.", "twist_en": "Keep your foreheads touching."},

	# 2. Seducción
	{"cat": 2, "type": "Secret", "time": 0, "es": "¿Cómo prefieres que empiece el próximo reto?", "en": "How should the next dare begin?", "opt_a_es": "Con los ojos vendados", "opt_b_es": "Con las luces bajas", "opt_a_en": "Blindfolded", "opt_b_en": "Lights dimmed", "twist_es": "Aplíquenlo de inmediato.", "twist_en": "Apply it immediately."},
	{"cat": 2, "type": "Dare", "time": 25, "es": "Besa lentamente desde su mandíbula hasta la clavícula.", "en": "Kiss slowly from their jawline down to their collarbone.", "twist_es": "Tu pareja no puede moverse ni hablar.", "twist_en": "Your partner cannot move or speak."},
	{"cat": 2, "type": "Truth", "time": 0, "es": "¿Qué caricia mía te enciende en menos de cinco segundos?", "en": "What touch of mine turns you on in under five seconds?", "twist_es": "Guía mi mano para hacerlo ahora mismo.", "twist_en": "Guide my hand to do it right now."},
	{"cat": 2, "type": "Dare", "time": 20, "es": "Quédate a un milímetro de sus labios durante 20 segundos sin besar.", "en": "Hover a millimeter from their lips for 20 seconds without kissing.", "twist_es": "Al terminar el tiempo, bésense sin freno.", "twist_en": "When time is up, kiss passionately."},
	{"cat": 2, "type": "Drink", "time": 0, "es": "Toma tu próximo sorbo sentado/a sobre el regazo de tu pareja.", "en": "Take your next sip sitting on your partner's lap.", "twist_es": "Quédate ahí durante el siguiente turno.", "twist_en": "Stay there for the next turn."},
	{"cat": 2, "type": "Dare", "time": 30, "es": "Dale un masaje lento en el cuello respirando cerca de su oído.", "en": "Give a slow neck massage while breathing close to their ear.", "twist_es": "Termina mordisqueando suavemente su oreja.", "twist_en": "End by gently nibbling their earlobe."},

	# 3. Intimidad
	{"cat": 3, "type": "Secret", "time": 0, "es": "¿Qué rol te tienta más para hoy?", "en": "Which role tempts you more tonight?", "opt_a_es": "Llevar el control", "opt_b_es": "Dejarme llevar", "opt_a_en": "Take control", "opt_b_en": "Surrender control", "twist_es": "Intercambien roles por 2 turnos.", "twist_en": "Swap roles for 2 turns."},
	{"cat": 3, "type": "Truth", "time": 0, "es": "¿Cuál es el recuerdo más apasionado que tienes de nosotros dos?", "en": "What is your most passionate memory of the two of us?", "twist_es": "Recrea los primeros diez segundos ahora.", "twist_en": "Recreate the first ten seconds right now."},
	{"cat": 3, "type": "Dare", "time": 30, "es": "Con los ojos cerrados, explora su rostro y cuello solo con tus labios.", "en": "With eyes closed, explore their face and neck using only your lips.", "twist_es": "Silencio absoluto durante los 30 segundos.", "twist_en": "Complete silence for all 30 seconds."},
	{"cat": 3, "type": "Dare", "time": 30, "es": "Abrázalo/a por detrás y susúrrale al oído lo que más deseas hoy.", "en": "Hold them from behind and whisper what you desire most tonight.", "twist_es": "Acaricia sus manos mientras lo dices.", "twist_en": "Caress their hands while whispering."},
	{"cat": 3, "type": "Drink", "time": 0, "es": "Pasa el borde de tu copa por sus labios antes de compartir un sorbo.", "en": "Trace your glass rim across their lips before sharing a slow sip.", "twist_es": "Roba el último rastro con un beso.", "twist_en": "Steal the last drop with a kiss."},

	# 4. Retos Atrevidos
	{"cat": 4, "type": "Dice", "time": 20, "es": "Lanza los Dados de Seducción y cumple el reto que marquen.", "en": "Roll the Seduction Dice and perform the combination.", "twist_es": "Hazlo con los ojos cerrados.", "twist_en": "Do it with your eyes closed."},
	{"cat": 4, "type": "Secret", "time": 0, "es": "¿Dónde prefieres que siga la noche después del juego?", "en": "Where should the night continue after this game?", "opt_a_es": "Aquí mismo", "opt_b_es": "En la habitación", "opt_a_en": "Right here", "opt_b_en": "In the bedroom", "twist_es": "Quien gane elige la primera prenda que cae.", "twist_en": "Winner picks the first clothing item to go."},
	{"cat": 4, "type": "Dare", "time": 0, "es": "Quítate una prenda de ropa lentamente manteniendo contacto visual.", "en": "Slowly remove one piece of clothing while holding eye contact.", "twist_es": "Tu pareja elige qué prenda es.", "twist_en": "Your partner chooses which item."},
	{"cat": 4, "type": "Dare", "time": 40, "es": "Sujeta suavemente sus muñecas y bésalo/a donde quieras por 40 segundos.", "en": "Gently hold their wrists and kiss them anywhere you want for 40s.", "twist_es": "Tu pareja no puede mover las manos.", "twist_en": "Your partner isn't allowed to move their hands."},
	{"cat": 4, "type": "Dare", "time": 30, "es": "Baila de forma sensual para tu pareja durante 30 segundos.", "en": "Dance sensually for your partner for 30 seconds.", "twist_es": "Tiene prohibido tocarte hasta que acabes.", "twist_en": "They aren't allowed to touch you until time's up."},

	# 5. Sin Límites 18+
	{"cat": 5, "type": "Secret", "time": 0, "es": "¿Qué ritmo prefieres para los próximos minutos?", "en": "What pace do you want for the next few minutes?", "opt_a_es": "Lento y provocador", "opt_b_es": "Intenso y sin pausa", "opt_a_en": "Slow & teasing", "opt_b_en": "Intense & non-stop", "twist_es": "Demuéstrenlo durante 1 minuto.", "twist_en": "Prove it for 1 full minute."},
	{"cat": 5, "type": "Dare", "time": 60, "es": "Mando Total: Tienes 1 minuto para pedir tres deseos sin que pueda negarse.", "en": "Total Command: You have 1 minute to give three orders they must obey.", "twist_es": "Debe pedirte permiso antes de hablar.", "twist_en": "They must ask permission before speaking."},
	{"cat": 5, "type": "Dare", "time": 45, "es": "Quítale una prenda a tu pareja usando únicamente una mano o los labios.", "en": "Remove one item of your partner's clothing using one hand or your lips.", "twist_es": "Tómate tu tiempo para provocar.", "twist_en": "Take your time to tease them."},
	{"cat": 5, "type": "Dare", "time": 60, "es": "El Límite: Provoca a tu pareja con besos por 1 minuto sin dejar que te toque.", "en": "The Edge: Tease your partner with kisses for 1 minute—they cannot touch you.", "twist_es": "Si se mueve, el minuto empieza de nuevo.", "twist_en": "If they move, the minute restarts."},
	{"cat": 5, "type": "Dare", "time": 60, "es": "Apaguen la luz 1 minuto: solo vale guiarse por el tacto y la respiración.", "en": "Lights off for 1 minute: let touch and breathing make all the rules.", "twist_es": "Nadie puede decir una sola palabra.", "twist_en": "Neither of you may speak a word."}
]
