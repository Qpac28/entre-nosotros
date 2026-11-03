class_name DeckData
extends RefCounted

const CATEGORIES := {
	1: {
		"title_es": "Calentamiento",
		"title_en": "Warm-Up",
		"badge_es": "NIVEL I · CALENTAMIENTO",
		"badge_en": "LEVEL I · WARM-UP",
		"color": Color(0.95, 0.22, 0.40)
	},
	2: {
		"title_es": "Seducción",
		"title_en": "Seduction",
		"badge_es": "NIVEL II · SEDUCCIÓN",
		"badge_en": "LEVEL II · SEDUCTION",
		"color": Color(0.88, 0.16, 0.35)
	},
	3: {
		"title_es": "Intimidad",
		"title_en": "Intimacy",
		"badge_es": "NIVEL III · INTIMIDAD",
		"badge_en": "LEVEL III · INTIMACY",
		"color": Color(0.76, 0.14, 0.32)
	},
	4: {
		"title_es": "Retos Atrevidos",
		"title_en": "Daring Dares",
		"badge_es": "NIVEL IV · ATREVIDOS",
		"badge_en": "LEVEL IV · DARING",
		"color": Color(0.92, 0.32, 0.22)
	},
	5: {
		"title_es": "Sin Límites 18+",
		"title_en": "No Limits 18+",
		"badge_es": "NIVEL V · SIN LÍMITES 18+",
		"badge_en": "LEVEL V · NO LIMITS 18+",
		"color": Color(0.98, 0.12, 0.30)
	}
}

const CARDS := [
	# ================= 1: CALENTAMIENTO (10 CARTAS) =================
	{
		"cat": 1, "type": "Action", "timer": 15,
		"es": "[color=#ff5e84]Mírense a los ojos[/color] en silencio por [color=#ffd8a8]15 segundos[/color].",
		"en": "[color=#ff5e84]Hold eye contact[/color] in silence for [color=#ffd8a8]15 seconds[/color]."
	},
	{
		"cat": 1, "type": "Question", "timer": 0,
		"es": "¿Qué parte del [color=#ffd8a8]cuerpo de {target}[/color] te [color=#ff5e84]provoca más[/color] hoy?",
		"en": "Which part of [color=#ffd8a8]{target}'s body[/color] [color=#ff5e84]tempts you most[/color] today?"
	},
	{
		"cat": 1, "type": "Action", "timer": 20,
		"es": "[color=#ff5e84]Acaricia[/color] el rostro y [color=#ffd8a8]labios de {target}[/color] por [color=#ffd8a8]20s[/color].",
		"en": "[color=#ff5e84]Caress[/color] [color=#ffd8a8]{target}'s face and lips[/color] for [color=#ffd8a8]20s[/color]."
	},
	{
		"cat": 1, "type": "Action", "timer": 0,
		"es": "Dale [color=#ff5e84]3 besos lentos[/color] a [color=#ffd8a8]{target}[/color] sin tocar sus labios.",
		"en": "Give [color=#ffd8a8]{target}[/color] [color=#ff5e84]3 slow kisses[/color] without touching lips."
	},
	{
		"cat": 1, "type": "Action", "timer": 15,
		"es": "[color=#ff5e84]Entrelaza tus manos[/color] con [color=#ffd8a8]{target}[/color] y bésale la frente [color=#ffd8a8]15s[/color].",
		"en": "[color=#ff5e84]Lock hands[/color] with [color=#ffd8a8]{target}[/color] and kiss their forehead [color=#ffd8a8]15s[/color]."
	},
	{
		"cat": 1, "type": "Question", "timer": 0,
		"es": "Di al oído de [color=#ffd8a8]{target}[/color] qué fue lo que más te [color=#ff5e84]gustó de hoy[/color].",
		"en": "Tell [color=#ffd8a8]{target}[/color] what [color=#ff5e84]turned you on[/color] most about them today."
	},
	{
		"cat": 1, "type": "Action", "timer": 20,
		"es": "[color=#ff5e84]Besa suavemente[/color] las [color=#ffd8a8]manos y muñecas de {target}[/color] por [color=#ffd8a8]20s[/color].",
		"en": "[color=#ff5e84]Softly kiss[/color] [color=#ffd8a8]{target}'s hands and wrists[/color] for [color=#ffd8a8]20s[/color]."
	},
	{
		"cat": 1, "type": "Action", "timer": 20,
		"es": "[color=#ff5e84]Abraza por la cintura[/color] a [color=#ffd8a8]{target}[/color] bien pegados por [color=#ffd8a8]20s[/color].",
		"en": "[color=#ff5e84]Pull[/color] [color=#ffd8a8]{target}[/color] close by the waist for [color=#ffd8a8]20s[/color]."
	},
	{
		"cat": 1, "type": "Secret", "timer": 0,
		"es": "¿Qué [color=#ff5e84]prefieren[/color] ahora mismo?",
		"en": "What do you both [color=#ff5e84]crave[/color] right now?",
		"opt_a_es": "Beso lento", "opt_b_es": "Masaje en cuello",
		"opt_a_en": "Slow kiss", "opt_b_en": "Neck massage",
		"forfeit_es": "[color=#ff5e84]10s de besos[/color] en el [color=#ffd8a8]cuello de {target}[/color].",
		"forfeit_en": "[color=#ff5e84]10s of kisses[/color] on [color=#ffd8a8]{target}'s neck[/color]."
	},
	{
		"cat": 1, "type": "Secret", "timer": 0,
		"es": "¿Cómo prefieren [color=#ff5e84]empezar[/color]?",
		"en": "How do you prefer to [color=#ff5e84]start[/color]?",
		"opt_a_es": "Miradas y besos", "opt_b_es": "Caricias lentas",
		"opt_a_en": "Gaze & kisses", "opt_b_en": "Slow touch",
		"forfeit_es": "[color=#ff5e84]Acaricia el cuello[/color] de [color=#ffd8a8]{target}[/color] por [color=#ffd8a8]10s[/color].",
		"forfeit_en": "[color=#ff5e84]Caress[/color] [color=#ffd8a8]{target}'s neck[/color] for [color=#ffd8a8]10s[/color]."
	},

	# ================= 2: SEDUCCIÓN (10 CARTAS) =================
	{
		"cat": 2, "type": "Action", "timer": 20,
		"es": "[color=#ff5e84]Besa lentamente[/color] el [color=#ffd8a8]cuello de {target}[/color] por [color=#ffd8a8]20s[/color].",
		"en": "[color=#ff5e84]Slowly kiss[/color] [color=#ffd8a8]{target}'s neck[/color] for [color=#ffd8a8]20s[/color]."
	},
	{
		"cat": 2, "type": "Action", "timer": 0,
		"es": "[color=#ff5e84]Susurra al oído[/color] de [color=#ffd8a8]{target}[/color] qué quieres hacerle hoy.",
		"en": "[color=#ff5e84]Whisper in[/color] [color=#ffd8a8]{target}'s ear[/color] what you want tonight."
	},
	{
		"cat": 2, "type": "Action", "timer": 15,
		"es": "[color=#ff5e84]Muerde suave[/color] el [color=#ffd8a8]labio inferior de {target}[/color] por [color=#ffd8a8]15s[/color].",
		"en": "[color=#ff5e84]Gently bite[/color] [color=#ffd8a8]{target}'s lower lip[/color] for [color=#ffd8a8]15s[/color]."
	},
	{
		"cat": 2, "type": "Action", "timer": 30,
		"es": "[color=#ff5e84]Bésense[/color] sin usar las manos durante [color=#ffd8a8]30 segundos[/color].",
		"en": "[color=#ff5e84]Kiss[/color] without using your hands for [color=#ffd8a8]30 seconds[/color]."
	},
	{
		"cat": 2, "type": "Action", "timer": 20,
		"es": "[color=#ff5e84]Roza con tus labios[/color] la [color=#ffd8a8]oreja de {target}[/color] durante [color=#ffd8a8]20s[/color].",
		"en": "[color=#ff5e84]Brush your lips[/color] against [color=#ffd8a8]{target}'s ear[/color] for [color=#ffd8a8]20s[/color]."
	},
	{
		"cat": 2, "type": "Action", "timer": 25,
		"es": "[color=#ff5e84]Desabrocha o sube[/color] un poco la ropa de [color=#ffd8a8]{target}[/color] y bésale [color=#ffd8a8]25s[/color].",
		"en": "[color=#ff5e84]Unbutton or lift[/color] [color=#ffd8a8]{target}'s top[/color] and kiss for [color=#ffd8a8]25s[/color]."
	},
	{
		"cat": 2, "type": "Action", "timer": 20,
		"es": "Pasa las [color=#ff5e84]yemas de tus dedos[/color] por la [color=#ffd8a8]espalda de {target}[/color] [color=#ffd8a8]20s[/color].",
		"en": "Trace your [color=#ff5e84]fingertips[/color] down [color=#ffd8a8]{target}'s back[/color] for [color=#ffd8a8]20s[/color]."
	},
	{
		"cat": 2, "type": "Question", "timer": 0,
		"es": "¿Dónde te vuelve loco/a que [color=#ffd8a8]{target}[/color] te [color=#ff5e84]bese despacio[/color]?",
		"en": "Where does it drive you crazy when [color=#ffd8a8]{target}[/color] [color=#ff5e84]kisses you slowly[/color]?"
	},
	{
		"cat": 2, "type": "Secret", "timer": 0,
		"es": "¿Dónde quieren el [color=#ff5e84]próximo beso[/color]?",
		"en": "Where do you want the [color=#ff5e84]next kiss[/color]?",
		"opt_a_es": "En el cuello", "opt_b_es": "En los labios",
		"opt_a_en": "On the neck", "opt_b_en": "On the lips",
		"forfeit_es": "Dale [color=#ff5e84]ambos besos[/color] a [color=#ffd8a8]{target}[/color] ahora.",
		"forfeit_en": "Give [color=#ffd8a8]{target}[/color] [color=#ff5e84]both kisses[/color] now."
	},
	{
		"cat": 2, "type": "Secret", "timer": 0,
		"es": "¿Qué [color=#ff5e84]provoca más[/color] ahora?",
		"en": "What [color=#ff5e84]teases more[/color] right now?",
		"opt_a_es": "Mordida suave", "opt_b_es": "Susurro caliente",
		"opt_a_en": "Gentle bite", "opt_b_en": "Hot whisper",
		"forfeit_es": "Hazle [color=#ff5e84]las dos cosas[/color] a [color=#ffd8a8]{target}[/color].",
		"forfeit_en": "Do [color=#ff5e84]both[/color] to [color=#ffd8a8]{target}[/color] right now."
	},

	# ================= 3: INTIMIDAD (10 CARTAS) =================
	{
		"cat": 3, "type": "Action", "timer": 30,
		"es": "[color=#ff5e84]Abrácense piel con piel[/color] en silencio por [color=#ffd8a8]30s[/color].",
		"en": "[color=#ff5e84]Hold each other close[/color] in silence for [color=#ffd8a8]30s[/color]."
	},
	{
		"cat": 3, "type": "Question", "timer": 0,
		"es": "Confiesa una [color=#ff5e84]fantasía secreta[/color] con [color=#ffd8a8]{target}[/color].",
		"en": "Confess a [color=#ff5e84]secret fantasy[/color] with [color=#ffd8a8]{target}[/color]."
	},
	{
		"cat": 3, "type": "Action", "timer": 30,
		"es": "[color=#ff5e84]Besa[/color] desde la muñeca hasta el [color=#ffd8a8]hombro de {target}[/color] [color=#ffd8a8]30s[/color].",
		"en": "[color=#ff5e84]Kiss[/color] from wrist to [color=#ffd8a8]{target}'s shoulder[/color] [color=#ffd8a8]30s[/color]."
	},
	{
		"cat": 3, "type": "Action", "timer": 25,
		"es": "[color=#ffd8a8]{target}[/color] cierra los ojos: dale [color=#ff5e84]3 besos sorpresa[/color].",
		"en": "[color=#ffd8a8]{target}[/color] closes eyes: give [color=#ff5e84]3 surprise kisses[/color]."
	},
	{
		"cat": 3, "type": "Action", "timer": 30,
		"es": "[color=#ff5e84]Besa la clavícula[/color] y el [color=#ffd8a8]pecho de {target}[/color] durante [color=#ffd8a8]30s[/color].",
		"en": "[color=#ff5e84]Kiss[/color] [color=#ffd8a8]{target}'s collarbone and chest[/color] for [color=#ffd8a8]30s[/color]."
	},
	{
		"cat": 3, "type": "Action", "timer": 25,
		"es": "Pon la mano de [color=#ffd8a8]{target}[/color] donde quieras que te [color=#ff5e84]acaricie[/color] [color=#ffd8a8]25s[/color].",
		"en": "Place [color=#ffd8a8]{target}'s hand[/color] where you want to be [color=#ff5e84]touched[/color] [color=#ffd8a8]25s[/color]."
	},
	{
		"cat": 3, "type": "Action", "timer": 30,
		"es": "[color=#ff5e84]Respira y besa[/color] muy lento detrás de la [color=#ffd8a8]oreja de {target}[/color] [color=#ffd8a8]30s[/color].",
		"en": "[color=#ff5e84]Breathe and kiss[/color] behind [color=#ffd8a8]{target}'s ear[/color] for [color=#ffd8a8]30s[/color]."
	},
	{
		"cat": 3, "type": "Question", "timer": 0,
		"es": "¿Qué te gustaría que [color=#ffd8a8]{target}[/color] te hiciera [color=#ff5e84]sin que lo pidas[/color]?",
		"en": "What do you wish [color=#ffd8a8]{target}[/color] would do [color=#ff5e84]without you asking[/color]?"
	},
	{
		"cat": 3, "type": "Secret", "timer": 0,
		"es": "¿[color=#ffd8a8]Luz tenue[/color] o [color=#ff5e84]a oscuras[/color]?",
		"en": "[color=#ffd8a8]Dim light[/color] or [color=#ff5e84]total darkness[/color]?",
		"opt_a_es": "Luz tenue", "opt_b_es": "A oscuras",
		"opt_a_en": "Dim light", "opt_b_en": "Total darkness",
		"forfeit_es": "[color=#ff5e84]20s de besos[/color] con los [color=#ffd8a8]ojos cerrados[/color].",
		"forfeit_en": "[color=#ff5e84]20s of kisses[/color] with [color=#ffd8a8]eyes closed[/color]."
	},
	{
		"cat": 3, "type": "Secret", "timer": 0,
		"es": "¿Qué los [color=#ff5e84]conecta más[/color] en la cama?",
		"en": "What [color=#ff5e84]connects you more[/color] in bed?",
		"opt_a_es": "Mirarse a los ojos", "opt_b_es": "Susurros al oído",
		"opt_a_en": "Eye contact", "opt_b_en": "Whispers in ear",
		"forfeit_es": "[color=#ff5e84]Bésense mirándose[/color] durante [color=#ffd8a8]15s[/color].",
		"forfeit_en": "[color=#ff5e84]Kiss while locking eyes[/color] for [color=#ffd8a8]15s[/color]."
	},

	# ================= 4: RETOS ATREVIDOS (10 CARTAS) =================
	{
		"cat": 4, "type": "Action", "timer": 20,
		"es": "[color=#ff5e84]Quítale una prenda[/color] a [color=#ffd8a8]{target}[/color] muy despacio.",
		"en": "Slowly [color=#ff5e84]remove one item[/color] from [color=#ffd8a8]{target}[/color]."
	},
	{
		"cat": 4, "type": "Action", "timer": 30,
		"es": "[color=#ff5e84]Siéntate sobre[/color] [color=#ffd8a8]{target}[/color] y bésale por [color=#ffd8a8]30s[/color].",
		"en": "[color=#ff5e84]Sit on[/color] [color=#ffd8a8]{target}'s lap[/color] and kiss for [color=#ffd8a8]30s[/color]."
	},
	{
		"cat": 4, "type": "Action", "timer": 30,
		"es": "Recorre con [color=#ff5e84]tus labios[/color] el [color=#ffd8a8]pecho de {target}[/color] por [color=#ffd8a8]30s[/color].",
		"en": "Trace [color=#ff5e84]your lips[/color] across [color=#ffd8a8]{target}'s chest[/color] for [color=#ffd8a8]30s[/color]."
	},
	{
		"cat": 4, "type": "Action", "timer": 45,
		"es": "[color=#ff5e84]Masajea[/color] los [color=#ffd8a8]muslos y espalda baja de {target}[/color] [color=#ffd8a8]45s[/color].",
		"en": "[color=#ff5e84]Massage[/color] [color=#ffd8a8]{target}'s thighs and lower back[/color] [color=#ffd8a8]45s[/color]."
	},
	{
		"cat": 4, "type": "Action", "timer": 30,
		"es": "[color=#ff5e84]Besa la cintura[/color] y el [color=#ffd8a8]abdomen de {target}[/color] por [color=#ffd8a8]30s[/color].",
		"en": "[color=#ff5e84]Kiss[/color] [color=#ffd8a8]{target}'s waist and stomach[/color] for [color=#ffd8a8]30s[/color]."
	},
	{
		"cat": 4, "type": "Action", "timer": 30,
		"es": "Quítate [color=#ff5e84]una prenda tuya[/color] manteniendo contacto visual con [color=#ffd8a8]{target}[/color].",
		"en": "Remove [color=#ff5e84]one of your items[/color] while locking eyes with [color=#ffd8a8]{target}[/color]."
	},
	{
		"cat": 4, "type": "Action", "timer": 35,
		"es": "[color=#ff5e84]Besa por dentro[/color] del [color=#ffd8a8]muslo de {target}[/color] durante [color=#ffd8a8]35s[/color].",
		"en": "[color=#ff5e84]Kiss the inner thigh[/color] of [color=#ffd8a8]{target}[/color] for [color=#ffd8a8]35s[/color]."
	},
	{
		"cat": 4, "type": "Action", "timer": 30,
		"es": "Pon las manos de [color=#ffd8a8]{target}[/color] atrás y [color=#ff5e84]bésale a tu antojo[/color] [color=#ffd8a8]30s[/color].",
		"en": "Hold [color=#ffd8a8]{target}'s hands[/color] back and [color=#ff5e84]kiss anywhere[/color] [color=#ffd8a8]30s[/color]."
	},
	{
		"cat": 4, "type": "Secret", "timer": 0,
		"es": "¿Quién [color=#ff5e84]toma el control[/color] ahora?",
		"en": "Who [color=#ff5e84]takes control[/color] right now?",
		"opt_a_es": "Yo mando", "opt_b_es": "Me dejo llevar",
		"opt_a_en": "I lead", "opt_b_en": "Take control",
		"forfeit_es": "[color=#ffd8a8]{target}[/color] elige qué [color=#ff5e84]prenda te quitas[/color].",
		"forfeit_en": "[color=#ffd8a8]{target}[/color] picks what [color=#ff5e84]item you remove[/color]."
	},
	{
		"cat": 4, "type": "Secret", "timer": 0,
		"es": "¿Dónde prefieren las [color=#ff5e84]manos ahora[/color]?",
		"en": "Where do you want [color=#ff5e84]hands right now[/color]?",
		"opt_a_es": "En la cintura", "opt_b_es": "En los muslos",
		"opt_a_en": "On the waist", "opt_b_en": "On the thighs",
		"forfeit_es": "[color=#ff5e84]Acaricia ambas zonas[/color] de [color=#ffd8a8]{target}[/color] [color=#ffd8a8]15s[/color].",
		"forfeit_en": "[color=#ff5e84]Caress both spots[/color] on [color=#ffd8a8]{target}[/color] [color=#ffd8a8]15s[/color]."
	},

	# ================= 5: SIN LÍMITES 18+ (10 CARTAS) =================
	{
		"cat": 5, "type": "Action", "timer": 60,
		"es": "[color=#ffd8a8]60 segundos[/color]: [color=#ffd8a8]{target}[/color] pide [color=#ff5e84]lo que quiera[/color].",
		"en": "[color=#ffd8a8]60 seconds[/color]: [color=#ffd8a8]{target}[/color] asks for [color=#ff5e84]anything[/color]."
	},
	{
		"cat": 5, "type": "Action", "timer": 45,
		"es": "[color=#ff5e84]Sujeta las muñecas[/color] de [color=#ffd8a8]{target}[/color] y bésale donde quieras [color=#ffd8a8]45s[/color].",
		"en": "[color=#ff5e84]Hold[/color] [color=#ffd8a8]{target}'s wrists[/color] and kiss anywhere [color=#ffd8a8]45s[/color]."
	},
	{
		"cat": 5, "type": "Action", "timer": 45,
		"es": "[color=#ff5e84]Besa el abdomen[/color] y [color=#ffd8a8]caderas de {target}[/color] por [color=#ffd8a8]45s[/color].",
		"en": "[color=#ff5e84]Kiss[/color] [color=#ffd8a8]{target}'s hips and stomach[/color] for [color=#ffd8a8]45s[/color]."
	},
	{
		"cat": 5, "type": "Action", "timer": 60,
		"es": "[color=#ff5e84]Venda los ojos[/color] de [color=#ffd8a8]{target}[/color] y provoca su piel [color=#ffd8a8]60s[/color].",
		"en": "[color=#ff5e84]Blindfold[/color] [color=#ffd8a8]{target}[/color] and tease their skin [color=#ffd8a8]60s[/color]."
	},
	{
		"cat": 5, "type": "Action", "timer": 45,
		"es": "[color=#ff5e84]Quítale otra prenda[/color] a [color=#ffd8a8]{target}[/color] usando solo la boca o 1 mano.",
		"en": "[color=#ff5e84]Remove an item[/color] from [color=#ffd8a8]{target}[/color] using 1 hand or mouth."
	},
	{
		"cat": 5, "type": "Action", "timer": 60,
		"es": "[color=#ffd8a8]{target}[/color] se acuesta: [color=#ff5e84]recorre todo su cuerpo[/color] con besos [color=#ffd8a8]60s[/color].",
		"en": "[color=#ffd8a8]{target}[/color] lies back: [color=#ff5e84]kiss down their body[/color] for [color=#ffd8a8]60s[/color]."
	},
	{
		"cat": 5, "type": "Action", "timer": 45,
		"es": "[color=#ff5e84]Provoca a {target}[/color] durante [color=#ffd8a8]45s[/color] sin dejar que te toque.",
		"en": "[color=#ff5e84]Tease {target}[/color] for [color=#ffd8a8]45s[/color] without letting them touch you."
	},
	{
		"cat": 5, "type": "Action", "timer": 60,
		"es": "[color=#ff5e84]Susurra tu deseo más caliente[/color] y hazlo con [color=#ffd8a8]{target}[/color] [color=#ffd8a8]60s[/color].",
		"en": "[color=#ff5e84]Whisper your hottest wish[/color] and do it with [color=#ffd8a8]{target}[/color] [color=#ffd8a8]60s[/color]."
	},
	{
		"cat": 5, "type": "Secret", "timer": 0,
		"es": "¿[color=#ff5e84]Ritmo[/color] para el resto de la noche?",
		"en": "[color=#ff5e84]Pace[/color] for the rest of the night?",
		"opt_a_es": "Lento y sensual", "opt_b_es": "Intenso y salvaje",
		"opt_a_en": "Slow & teasing", "opt_b_en": "Wild & intense",
		"forfeit_es": "[color=#ff5e84]30s de besos intensos[/color] con [color=#ffd8a8]{target}[/color].",
		"forfeit_en": "[color=#ff5e84]30s of intense kisses[/color] with [color=#ffd8a8]{target}[/color]."
	},
	{
		"cat": 5, "type": "Secret", "timer": 0,
		"es": "¿Dónde terminamos [color=#ff5e84]esta noche[/color]?",
		"en": "Where do we finish [color=#ff5e84]tonight[/color]?",
		"opt_a_es": "Aquí mismo ya", "opt_b_es": "Sin nada de ropa",
		"opt_a_en": "Right here now", "opt_b_en": "Zero clothes on",
		"forfeit_es": "[color=#ff5e84]Quítense una prenda[/color] los dos ahora mismo.",
		"forfeit_en": "[color=#ff5e84]Both remove one item[/color] right now."
	}
]

const DICE_ACTIONS_ES := ["Besar lento", "Morder suave", "Susurrar en", "Acariciar", "Calentar", "Soplar en"]
const DICE_BODY_ES := ["el cuello", "los labios", "la oreja", "el pecho", "la espalda", "el muslo"]

const DICE_ACTIONS_EN := ["Slowly kiss", "Gently bite", "Whisper on", "Caress", "Warm up", "Blow softly on"]
const DICE_BODY_EN := ["the neck", "the lips", "the ear", "the chest", "the lower back", "the thigh"]

const WHEEL_FANTASIES_ES := [
	"[color=#ff5e84]60s[/color] con [color=#ffd8a8]ojos vendados[/color]",
	"[color=#ff5e84]Quitar 1 prenda[/color] muy lento",
	"[color=#ff5e84]Beso de 30s[/color] sin manos",
	"[color=#ff5e84]Masaje sensual[/color] por [color=#ffd8a8]1 minuto[/color]",
	"[color=#ff5e84]Susurrar fantasía[/color] + beso",
	"[color=#ffd8a8]1 minuto[/color] a [color=#ff5e84]tu merced[/color]",
	"[color=#ff5e84]Hielo o labios[/color] por el [color=#ffd8a8]cuello[/color]",
	"[color=#ff5e84]3 besos[/color] donde [color=#ffd8a8]tú elijas[/color]"
]

const WHEEL_FANTASIES_EN := [
	"[color=#ff5e84]60s[/color] [color=#ffd8a8]blindfolded[/color]",
	"[color=#ff5e84]Remove 1 item[/color] slowly",
	"[color=#ff5e84]30s kiss[/color] no hands",
	"[color=#ffd8a8]1-min[/color] [color=#ff5e84]sensual massage[/color]",
	"[color=#ff5e84]Whisper fantasy[/color] + kiss",
	"[color=#ffd8a8]1 minute[/color] at [color=#ff5e84]your mercy[/color]",
	"[color=#ff5e84]Ice or lips[/color] on the [color=#ffd8a8]neck[/color]",
	"[color=#ff5e84]3 kisses[/color] [color=#ffd8a8]anywhere[/color]"
]

const CLIMAX_ENVELOPES := [
	{
		"title_es": "Sobre I",
		"title_en": "Envelope I",
		"es": "[color=#ffd8a8]5 minutos a ciegas[/color]: uno cierra los ojos y el otro tiene [color=#ff5e84]control total[/color].",
		"en": "[color=#ffd8a8]5 minutes blindfolded[/color]: one closes eyes, the other has [color=#ff5e84]full control[/color]."
	},
	{
		"title_es": "Sobre II",
		"title_en": "Envelope II",
		"es": "[color=#ff5e84]Deseo concedido[/color]: [color=#ffd8a8]{target}[/color] pide su fantasía favorita ahora.",
		"en": "[color=#ff5e84]Wish granted[/color]: [color=#ffd8a8]{target}[/color] asks for their favorite fantasy now."
	},
	{
		"title_es": "Sobre III",
		"title_en": "Envelope III",
		"es": "[color=#ff5e84]Fuera teléfonos[/color]: apagan la pantalla y continúan [color=#ffd8a8]sin reglas[/color].",
		"en": "[color=#ff5e84]Phones down[/color]: turn off the screen and continue [color=#ffd8a8]with zero rules[/color]."
	}
]
