extends Control

const SVGIcons = preload("res://scripts/svg_icons.gd")
const DeckData = preload("res://scripts/deck_data.gd")
const SoundFXScript = preload("res://scripts/sound_fx.gd")

const CAT_ART_PATHS := {
	1: "res://assets/card-couple.jpg",
	2: "res://assets/card-seduccion.jpg",
	3: "res://assets/card-intimidad.jpg",
	4: "res://assets/card-atrevidos.jpg",
	5: "res://assets/card-sinlimites.jpg"
}

var sfx: Node
var serif_font: FontFile
var italic_serif: FontVariation
var cat_textures := {}
var side_back_tex: Texture2D

# Game State
var lang: String = "es"
var active_cat: int = 1
var include_drinks: bool = true
var current_turn: int = 1
var player_names := {1: "", 2: ""}
var passes_left := {1: 3, 2: 3}
var heat_points: int = 2
const MAX_HEAT: int = 12
var climax_shown: bool = false

var draw_bags := {}
var current_card: Dictionary = {}
var timer_remaining: int = 0
var timer_running: bool = false
var timer_accum: float = 0.0
var twist_visible: bool = false

# Secret Match ("¿Coinciden?") State
var secret_stage: int = 0 # 0=P1 picking, 1=P2 picking, 2=Revealed
var secret_p1_choice: int = -1

# UI References
var brand_tagline_lbl: Label
var hero_title_lbl: Label
var hero_sub_lbl: Label
var lang_top_btn: Button
var sound_top_btn: Button

var nav_buttons := {}
var cat_cards := {}
var cat_titles := {}
var cat_subs := {}
var choose_cat_lbl: Label

var howto_title_lbl: Label
var step1_lbl: Label
var step2_lbl: Label
var step3_lbl: Label
var btn_quick_dice: Button
var btn_quick_wheel: Button

var home_view: Control
var deck_holder: Control
var left_fanned_card: Control
var right_fanned_card: Control
var center_fanned_card: Control
var hero_couple_art: TextureRect
var main_play_btn: Button

var play_view: Control
var turn_chip_lbl: Label
var heat_lbl: Label
var heat_bar: ProgressBar
var passes_chip_lbl: Label

var active_game_card: PanelContainer
var card_base_pos := Vector2(183, 56)
var card_front_root: Control
var card_back_cover: TextureRect
var active_art_rect: TextureRect
var game_cat_lbl: Label
var game_type_lbl: Label
var game_icon_rect: TextureRect
var game_prompt_lbl: Label
var game_twist_lbl: Label

# Secret Choice UI inside Card
var secret_box: VBoxContainer
var secret_hint_lbl: Label
var secret_opt_a_btn: Button
var secret_opt_b_btn: Button

var timer_pill_btn: Button
var twist_pill_btn: Button
var stamp_done: Label
var stamp_pass: Label
var btn_pass_card: Button
var btn_done_card: Button

# Swipe & Parallax State
var dragging_card: bool = false
var drag_start_x: float = 0.0
var drag_dx: float = 0.0
var card_animating: bool = false

# Modals: Dice & Visual Roulette Wheel
var prop_modal: Control
var prop_title_lbl: Label
var prop_sub_lbl: Label
var dice_row_box: HBoxContainer
var d1_panel: PanelContainer
var d2_panel: PanelContainer
var die_1_val: Label
var die_2_val: Label
var wheel_holder: Control
var wheel_disc_rect: TextureRect
var wheel_angle: float = 0.0
var wheel_spinning: bool = false
var last_wheel_peg: int = -1
var prop_outcome_lbl: Label
var prop_repeat_btn: Button
var prop_close_btn: Button
var prop_mode: String = "dice"

# Modal: Climax ("Los 3 Sobres Dorados")
var climax_modal: Control
var climax_title_lbl: Label
var climax_sub_lbl: Label
var climax_result_lbl: Label
var envelope_btns: Array[Button] = []

# Modal: Couple Names
var couple_modal: Control
var couple_title_lbl: Label
var couple_sub_lbl: Label
var p1_input: LineEdit
var p2_input: LineEdit
var save_couple_btn: Button

func _ready() -> void:
	randomize()
	set_anchors_preset(Control.PRESET_FULL_RECT)

	sfx = SoundFXScript.new()
	add_child(sfx)

	_load_fonts()
	_preload_art()
	_build_background()
	_build_shell()
	_build_modals()
	_refresh_all_texts()

func _load_fonts() -> void:
	serif_font = FontFile.new()
	var font_global := ProjectSettings.globalize_path("res://playfair-display-700.woff2")
	if FileAccess.file_exists(font_global):
		serif_font.load_dynamic_font(font_global)

	italic_serif = FontVariation.new()
	italic_serif.base_font = serif_font
	italic_serif.variation_transform = Transform2D(Vector2(1.0, 0.0), Vector2(-0.20, 1.0), Vector2.ZERO)

func _preload_art() -> void:
	side_back_tex = SVGIcons.make_tex(SVGIcons.SIDE_CARD_BACK, 1.0)
	for k in CAT_ART_PATHS.keys():
		cat_textures[k] = _load_external_tex(CAT_ART_PATHS[k])

func _load_external_tex(res_path: String) -> Texture2D:
	var global_p := ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(global_p):
		var img := Image.load_from_file(global_p)
		if img and not img.is_empty():
			return ImageTexture.create_from_image(img)
	if ResourceLoader.exists(res_path):
		return load(res_path)
	return null

func _build_background() -> void:
	var bg_rect := TextureRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.texture = _load_external_tex("res://assets/bg-table.jpg")
	add_child(bg_rect)

	var vignette := ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0.05, 0.005, 0.02, 0.34)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)

	var particles := CPUParticles2D.new()
	particles.position = Vector2(683, 760)
	particles.amount = 28
	particles.lifetime = 6.5
	particles.preprocess = 3.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(640, 40)
	particles.direction = Vector2(0, -1)
	particles.spread = 20.0
	particles.gravity = Vector2(0, -12)
	particles.initial_velocity_min = 18.0
	particles.initial_velocity_max = 38.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = Color(1.0, 0.78, 0.62, 0.38)
	add_child(particles)

func _build_shell() -> void:
	# ================= TOP HEADER =================
	var header := Control.new()
	header.position = Vector2(36, 18)
	header.size = Vector2(1294, 96)
	add_child(header)

	var brand_box := Control.new()
	brand_box.size = Vector2(300, 92)
	brand_box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	brand_box.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			switch_view("home")
	)
	header.add_child(brand_box)

	var heart_logo := TextureRect.new()
	heart_logo.texture = SVGIcons.make_tex(SVGIcons.BRAND_HEART, 1.0)
	heart_logo.position = Vector2(0, 4)
	heart_logo.size = Vector2(62, 52)
	heart_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	heart_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	brand_box.add_child(heart_logo)

	var brand_l1 := _make_label("Cartas", 36, Color.WHITE, true)
	brand_l1.position = Vector2(64, -4)
	brand_box.add_child(brand_l1)

	var brand_en := _make_label("en", 17, Color.WHITE, true)
	brand_en.position = Vector2(68, 34)
	brand_box.add_child(brand_en)

	var brand_l2 := _make_label("Pareja", 35, Color(1.0, 0.28, 0.42), true)
	brand_l2.position = Vector2(94, 24)
	brand_box.add_child(brand_l2)

	brand_tagline_lbl = _make_label("EL JUEGO QUE ENCIENDE LA CONEXIÓN", 10, Color(1.0, 0.88, 0.91, 0.82), false)
	brand_tagline_lbl.position = Vector2(8, 68)
	brand_box.add_child(brand_tagline_lbl)

	hero_title_lbl = _make_label("¿Listos para jugar?", 44, Color.WHITE, true)
	hero_title_lbl.position = Vector2(360, 0)
	hero_title_lbl.size = Vector2(574, 54)
	hero_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_child(hero_title_lbl)

	hero_sub_lbl = _make_label("Retos, seducción y mucha complicidad...", 19, Color(1.0, 0.90, 0.93, 0.88), true)
	hero_sub_lbl.position = Vector2(360, 50)
	hero_sub_lbl.size = Vector2(574, 30)
	hero_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_child(hero_sub_lbl)

	var doodle := TextureRect.new()
	doodle.texture = SVGIcons.make_tex(SVGIcons.DOODLE_HEART, 1.0)
	doodle.position = Vector2(876, 26)
	doodle.size = Vector2(40, 36)
	header.add_child(doodle)

	var util_row := HBoxContainer.new()
	util_row.position = Vector2(1060, 8)
	util_row.add_theme_constant_override("separation", 10)
	header.add_child(util_row)

	var btn_couple_top := _make_glass_icon_btn(SVGIcons.NAV_COUPLE)
	btn_couple_top.pressed.connect(open_couple_modal)
	util_row.add_child(btn_couple_top)

	sound_top_btn = _make_glass_icon_btn(SVGIcons.ICON_SOUND)
	sound_top_btn.pressed.connect(_toggle_sound)
	util_row.add_child(sound_top_btn)

	lang_top_btn = _make_glass_icon_btn("")
	lang_top_btn.text = "ES"
	lang_top_btn.add_theme_font_size_override("font_size", 13)
	lang_top_btn.pressed.connect(_toggle_lang)
	util_row.add_child(lang_top_btn)

	var btn_fs := _make_glass_icon_btn(SVGIcons.ICON_FULLSCREEN)
	btn_fs.pressed.connect(_toggle_fullscreen)
	util_row.add_child(btn_fs)

	# ================= LEFT GLASS NAVIGATION SIDEBAR =================
	var sidebar := PanelContainer.new()
	sidebar.position = Vector2(42, 188)
	sidebar.size = Vector2(224, 268)
	sidebar.add_theme_stylebox_override("panel", _glass_style(Color(0.11, 0.025, 0.055, 0.76), Color(1.0, 0.68, 0.74, 0.24), 20, 1))
	add_child(sidebar)

	var nav_margin := MarginContainer.new()
	nav_margin.add_theme_constant_override("margin_left", 10)
	nav_margin.add_theme_constant_override("margin_right", 10)
	nav_margin.add_theme_constant_override("margin_top", 12)
	nav_margin.add_theme_constant_override("margin_bottom", 12)
	sidebar.add_child(nav_margin)

	var nav_vbox := VBoxContainer.new()
	nav_vbox.add_theme_constant_override("separation", 6)
	nav_margin.add_child(nav_vbox)

	nav_buttons["home"] = _make_nav_btn("Inicio", SVGIcons.NAV_HOME, true, func(): switch_view("home"))
	nav_buttons["play"] = _make_nav_btn("Jugar", SVGIcons.NAV_PLAY, false, func(): switch_view("play"))
	nav_buttons["cats"] = _make_nav_btn("Categorías", SVGIcons.NAV_CATS, false, func(): switch_view("play"))
	nav_buttons["couple"] = _make_nav_btn("Pareja", SVGIcons.NAV_COUPLE, false, open_couple_modal)
	nav_buttons["settings"] = _make_nav_btn("Idioma", SVGIcons.NAV_SETTINGS, false, _toggle_lang)

	for k in ["home", "play", "cats", "couple", "settings"]:
		nav_vbox.add_child(nav_buttons[k])

	# ================= CENTER STAGE =================
	var center_stage := Control.new()
	center_stage.position = Vector2(360, 114)
	center_stage.size = Vector2(646, 446)
	add_child(center_stage)

	_build_home_fanned_view(center_stage)
	_build_active_play_view(center_stage)

	# ================= RIGHT GLASS PANEL =================
	var right_panel := PanelContainer.new()
	right_panel.position = Vector2(1018, 148)
	right_panel.size = Vector2(304, 300)
	right_panel.add_theme_stylebox_override("panel", _glass_style(Color(0.11, 0.025, 0.055, 0.76), Color(1.0, 0.65, 0.72, 0.25), 20, 1))
	add_child(right_panel)

	var rp_margin := MarginContainer.new()
	rp_margin.add_theme_constant_override("margin_left", 20)
	rp_margin.add_theme_constant_override("margin_right", 20)
	rp_margin.add_theme_constant_override("margin_top", 18)
	rp_margin.add_theme_constant_override("margin_bottom", 18)
	right_panel.add_child(rp_margin)

	var rp_vbox := VBoxContainer.new()
	rp_vbox.add_theme_constant_override("separation", 12)
	rp_margin.add_child(rp_vbox)

	var ht_head := HBoxContainer.new()
	ht_head.add_theme_constant_override("separation", 10)
	rp_vbox.add_child(ht_head)

	var ht_flame := TextureRect.new()
	ht_flame.texture = SVGIcons.make_tex(SVGIcons.CAT_1_FLAME, 0.62)
	ht_flame.custom_minimum_size = Vector2(26, 26)
	ht_flame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ht_flame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ht_head.add_child(ht_flame)

	howto_title_lbl = _make_label("Cómo jugar", 20, Color.WHITE, false)
	ht_head.add_child(howto_title_lbl)

	step1_lbl = _make_step_row(rp_vbox, "1", "Elijan una categoría.")
	step2_lbl = _make_step_row(rp_vbox, "2", "Roben una carta por turno.")
	step3_lbl = _make_step_row(rp_vbox, "3", "Cumplan el reto... ¡y disfruten!")

	var extra_sep := HSeparator.new()
	extra_sep.modulate = Color(1, 0.7, 0.75, 0.25)
	rp_vbox.add_child(extra_sep)

	btn_quick_dice = _make_mini_action_btn("Dados de Seducción", SVGIcons.CAT_4_DICE, open_dice_modal)
	rp_vbox.add_child(btn_quick_dice)

	btn_quick_wheel = _make_mini_action_btn("Ruleta de Castigo", SVGIcons.CAT_1_FLAME, open_wheel_modal)
	rp_vbox.add_child(btn_quick_wheel)

	# ================= BOTTOM CATEGORIES FOOTER =================
	var footer := Control.new()
	footer.position = Vector2(180, 566)
	footer.size = Vector2(1006, 184)
	add_child(footer)

	var div_line_l := ColorRect.new()
	div_line_l.position = Vector2(140, 14)
	div_line_l.size = Vector2(240, 1)
	div_line_l.color = Color(1.0, 0.55, 0.65, 0.42)
	footer.add_child(div_line_l)

	choose_cat_lbl = _make_label("Elige una categoría", 18, Color(1.0, 0.94, 0.96), false)
	choose_cat_lbl.position = Vector2(390, 2)
	choose_cat_lbl.size = Vector2(226, 26)
	choose_cat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_child(choose_cat_lbl)

	var div_line_r := ColorRect.new()
	div_line_r.position = Vector2(626, 14)
	div_line_r.size = Vector2(240, 1)
	div_line_r.color = Color(1.0, 0.55, 0.65, 0.42)
	footer.add_child(div_line_r)

	var cat_hbox := HBoxContainer.new()
	cat_hbox.position = Vector2(0, 36)
	cat_hbox.size = Vector2(1006, 140)
	cat_hbox.add_theme_constant_override("separation", 14)
	footer.add_child(cat_hbox)

	for i in range(1, 6):
		var c_card := _make_category_card(i)
		cat_hbox.add_child(c_card)

func _build_home_fanned_view(parent: Control) -> void:
	home_view = Control.new()
	home_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(home_view)

	deck_holder = Control.new()
	deck_holder.position = Vector2(113, 18)
	deck_holder.size = Vector2(420, 310)
	deck_holder.pivot_offset = Vector2(210, 155)
	deck_holder.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	deck_holder.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			switch_view("play")
	)
	home_view.add_child(deck_holder)

	left_fanned_card = _make_side_fanned_card(side_back_tex)
	left_fanned_card.position = Vector2(26, 36)
	left_fanned_card.pivot_offset = Vector2(86, 124)
	left_fanned_card.rotation_degrees = -13.0
	deck_holder.add_child(left_fanned_card)

	right_fanned_card = _make_side_fanned_card(side_back_tex)
	right_fanned_card.position = Vector2(222, 36)
	right_fanned_card.pivot_offset = Vector2(86, 124)
	right_fanned_card.rotation_degrees = 13.0
	deck_holder.add_child(right_fanned_card)

	center_fanned_card = _make_hero_card_container(Vector2(204, 286))
	center_fanned_card.position = Vector2(108, 12)
	center_fanned_card.pivot_offset = Vector2(102, 143)
	deck_holder.add_child(center_fanned_card)

	hero_couple_art = TextureRect.new()
	hero_couple_art.texture = cat_textures[1]
	hero_couple_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	hero_couple_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_couple_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	center_fanned_card.get_child(0).add_child(hero_couple_art)

	var inner_frame := Panel.new()
	inner_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var in_sb := _glass_style(Color(0, 0, 0, 0), Color(1.0, 0.78, 0.68, 0.68), 10, 1)
	inner_frame.add_theme_stylebox_override("panel", in_sb)
	center_fanned_card.get_child(0).add_child(inner_frame)

	var heart_top := TextureRect.new()
	heart_top.texture = SVGIcons.make_tex(SVGIcons.CARD_HEART_EMBLEM, 1.0)
	heart_top.position = Vector2(80, 10)
	heart_top.size = Vector2(24, 22)
	inner_frame.add_child(heart_top)

	var c_title1 := _make_label("Cartas", 24, Color.WHITE, true)
	c_title1.position = Vector2(0, 178)
	c_title1.size = Vector2(184, 30)
	c_title1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner_frame.add_child(c_title1)

	var c_title2 := _make_label("en Pareja", 22, Color(1.0, 0.30, 0.45), true)
	c_title2.position = Vector2(0, 202)
	c_title2.size = Vector2(184, 30)
	c_title2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner_frame.add_child(c_title2)

	var heart_bot := TextureRect.new()
	heart_bot.texture = SVGIcons.make_tex(SVGIcons.CARD_HEART_EMBLEM, 1.0)
	heart_bot.position = Vector2(80, 236)
	heart_bot.size = Vector2(24, 22)
	inner_frame.add_child(heart_bot)

	deck_holder.mouse_entered.connect(func():
		var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(left_fanned_card, "rotation_degrees", -17.0, 0.25)
		tw.tween_property(right_fanned_card, "rotation_degrees", 17.0, 0.25)
		tw.tween_property(center_fanned_card, "scale", Vector2(1.05, 1.05), 0.25)
	)
	deck_holder.mouse_exited.connect(func():
		var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(left_fanned_card, "rotation_degrees", -13.0, 0.25)
		tw.tween_property(right_fanned_card, "rotation_degrees", 13.0, 0.25)
		tw.tween_property(center_fanned_card, "scale", Vector2.ONE, 0.25)
	)

	main_play_btn = _make_ruby_cta_btn("Jugar ahora", Vector2(290, 56))
	main_play_btn.position = Vector2(178, 354)
	main_play_btn.pressed.connect(func(): switch_view("play"))
	home_view.add_child(main_play_btn)

func _build_active_play_view(parent: Control) -> void:
	play_view = Control.new()
	play_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	play_view.visible = false
	parent.add_child(play_view)

	var status_pill := PanelContainer.new()
	status_pill.position = Vector2(98, 4)
	status_pill.size = Vector2(450, 38)
	status_pill.add_theme_stylebox_override("panel", _glass_style(Color(0.10, 0.02, 0.05, 0.80), Color(1.0, 0.72, 0.76, 0.32), 99, 1))
	play_view.add_child(status_pill)

	var st_hbox := HBoxContainer.new()
	st_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	st_hbox.add_theme_constant_override("separation", 14)
	status_pill.add_child(st_hbox)

	turn_chip_lbl = _make_label("Turno de Jugador 1", 14, Color(1.0, 0.85, 0.76), false)
	st_hbox.add_child(turn_chip_lbl)

	heat_lbl = _make_label("COMPLICIDAD", 11, Color(1.0, 0.75, 0.82, 0.85), false)
	st_hbox.add_child(heat_lbl)

	heat_bar = ProgressBar.new()
	heat_bar.max_value = MAX_HEAT
	heat_bar.value = heat_points
	heat_bar.show_percentage = false
	heat_bar.custom_minimum_size = Vector2(92, 8)
	heat_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	heat_bar.add_theme_stylebox_override("background", _glass_style(Color(1, 1, 1, 0.12), Color.TRANSPARENT, 99, 0))
	heat_bar.add_theme_stylebox_override("fill", _glass_style(Color(1.0, 0.22, 0.42), Color.TRANSPARENT, 99, 0))
	st_hbox.add_child(heat_bar)

	passes_chip_lbl = _make_label("3 Pases", 13, Color(1.0, 0.62, 0.72), false)
	st_hbox.add_child(passes_chip_lbl)

	var underlay := _make_hero_card_container(Vector2(268, 314))
	underlay.position = card_base_pos + Vector2(6, 8)
	underlay.rotation_degrees = -3.0
	underlay.modulate = Color(0.65, 0.5, 0.55, 0.85)
	play_view.add_child(underlay)

	active_game_card = _make_hero_card_container(Vector2(280, 320))
	active_game_card.position = card_base_pos
	active_game_card.pivot_offset = Vector2(140, 160)
	active_game_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	active_game_card.gui_input.connect(_on_active_card_input)
	play_view.add_child(active_game_card)

	var card_inner: Control = active_game_card.get_child(0)

	# Card Back Cover (shown during first half of physical 3D-like flip!)
	card_back_cover = TextureRect.new()
	card_back_cover.texture = side_back_tex
	card_back_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_back_cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_back_cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	card_back_cover.visible = false
	card_inner.add_child(card_back_cover)

	# Card Front Root
	card_front_root = Control.new()
	card_front_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_front_root.mouse_filter = Control.MOUSE_FILTER_PASS
	card_inner.add_child(card_front_root)

	active_art_rect = TextureRect.new()
	active_art_rect.texture = cat_textures[1]
	active_art_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	active_art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	active_art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	active_art_rect.modulate = Color(0.55, 0.35, 0.42, 0.36)
	active_art_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_front_root.add_child(active_art_rect)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 14
	vbox.offset_right = -14
	vbox.offset_top = 12
	vbox.offset_bottom = -12
	vbox.add_theme_constant_override("separation", 6)
	card_front_root.add_child(vbox)

	var top_row := HBoxContainer.new()
	vbox.add_child(top_row)

	game_cat_lbl = _make_label("CALENTAMIENTO", 11, Color(1.0, 0.84, 0.74), false)
	game_cat_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(game_cat_lbl)

	game_type_lbl = _make_label("RETO", 11, Color.WHITE, false)
	top_row.add_child(game_type_lbl)

	var stamp_row := HBoxContainer.new()
	vbox.add_child(stamp_row)

	stamp_done = _make_label("CUMPLIDO", 13, Color(1.0, 0.88, 0.78), false)
	stamp_done.modulate.a = 0.0
	stamp_row.add_child(stamp_done)

	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stamp_row.add_child(sp)

	stamp_pass = _make_label("PASAR", 13, Color(1.0, 0.55, 0.68), false)
	stamp_pass.modulate.a = 0.0
	stamp_row.add_child(stamp_pass)

	game_icon_rect = TextureRect.new()
	game_icon_rect.custom_minimum_size = Vector2(38, 38)
	game_icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	game_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	game_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(game_icon_rect)

	game_prompt_lbl = _make_label("", 19, Color.WHITE, true)
	game_prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game_prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_prompt_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_prompt_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(game_prompt_lbl)

	# Secret Choice ("¿Coinciden?") Interactive Box inside Card
	secret_box = VBoxContainer.new()
	secret_box.alignment = BoxContainer.ALIGNMENT_CENTER
	secret_box.add_theme_constant_override("separation", 6)
	secret_box.visible = false
	vbox.add_child(secret_box)

	secret_hint_lbl = _make_label("", 12, Color(1.0, 0.84, 0.74), false)
	secret_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	secret_box.add_child(secret_hint_lbl)

	secret_opt_a_btn = _make_pill_btn("Opción A", func(): _on_secret_option_picked(0))
	secret_opt_a_btn.custom_minimum_size = Vector2(220, 32)
	secret_box.add_child(secret_opt_a_btn)

	secret_opt_b_btn = _make_pill_btn("Opción B", func(): _on_secret_option_picked(1))
	secret_opt_b_btn.custom_minimum_size = Vector2(220, 32)
	secret_box.add_child(secret_opt_b_btn)

	game_twist_lbl = _make_label("", 12, Color(1.0, 0.84, 0.74), false)
	game_twist_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game_twist_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_twist_lbl.visible = false
	vbox.add_child(game_twist_lbl)

	var chips_row := HBoxContainer.new()
	chips_row.alignment = BoxContainer.ALIGNMENT_CENTER
	chips_row.add_theme_constant_override("separation", 8)
	vbox.add_child(chips_row)

	timer_pill_btn = _make_pill_btn("20s", _toggle_timer)
	chips_row.add_child(timer_pill_btn)

	twist_pill_btn = _make_pill_btn("+ Subir el tono", _toggle_twist)
	chips_row.add_child(twist_pill_btn)

	# Bottom Controls under Active Card
	var ctrl_row := HBoxContainer.new()
	ctrl_row.position = Vector2(118, 390)
	ctrl_row.size = Vector2(410, 48)
	ctrl_row.alignment = BoxContainer.ALIGNMENT_CENTER
	ctrl_row.add_theme_constant_override("separation", 14)
	play_view.add_child(ctrl_row)

	btn_pass_card = _make_pill_btn("Cambiar carta", func(): trigger_card_action(-1))
	btn_pass_card.custom_minimum_size = Vector2(160, 44)
	ctrl_row.add_child(btn_pass_card)

	btn_done_card = _make_ruby_cta_btn("¡Reto cumplido!", Vector2(210, 44))
	btn_done_card.pressed.connect(func(): trigger_card_action(1))
	ctrl_row.add_child(btn_done_card)

func _build_modals() -> void:
	# 1. Dice & Visual Spinning Roulette Modal
	prop_modal = _make_modal_backdrop()
	var card := _make_modal_card(prop_modal, Vector2(460, 420))
	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 12)
	card.add_child(vb)

	prop_title_lbl = _make_label("Dados de Seducción", 30, Color.WHITE, true)
	prop_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(prop_title_lbl)

	prop_sub_lbl = _make_label("Lanza los dados y cumplan la combinación", 14, Color(1.0, 0.85, 0.88, 0.8), false)
	prop_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(prop_sub_lbl)

	# Animated Dice Pair
	dice_row_box = HBoxContainer.new()
	dice_row_box.alignment = BoxContainer.ALIGNMENT_CENTER
	dice_row_box.add_theme_constant_override("separation", 16)
	vb.add_child(dice_row_box)

	d1_panel = PanelContainer.new()
	d1_panel.custom_minimum_size = Vector2(180, 96)
	d1_panel.pivot_offset = Vector2(90, 48)
	d1_panel.add_theme_stylebox_override("panel", _glass_style(Color(0.68, 0.07, 0.22, 0.92), Color(1.0, 0.84, 0.74), 16, 2))
	dice_row_box.add_child(d1_panel)
	die_1_val = _make_label("Besar lento", 18, Color.WHITE, true)
	die_1_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	die_1_val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	d1_panel.add_child(die_1_val)

	d2_panel = PanelContainer.new()
	d2_panel.custom_minimum_size = Vector2(180, 96)
	d2_panel.pivot_offset = Vector2(90, 48)
	d2_panel.add_theme_stylebox_override("panel", _glass_style(Color(0.38, 0.04, 0.13, 0.92), Color(1.0, 0.84, 0.74), 16, 2))
	dice_row_box.add_child(d2_panel)
	die_2_val = _make_label("El cuello (15s)", 18, Color.WHITE, true)
	die_2_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	die_2_val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	d2_panel.add_child(die_2_val)

	# Visual Spinning Roulette Wheel (220x220 disc + golden top pointer)
	wheel_holder = Control.new()
	wheel_holder.custom_minimum_size = Vector2(220, 224)
	wheel_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	wheel_holder.visible = false
	vb.add_child(wheel_holder)

	wheel_disc_rect = TextureRect.new()
	wheel_disc_rect.texture = SVGIcons.make_tex(SVGIcons.WHEEL_DISC_SVG, 1.0)
	wheel_disc_rect.position = Vector2(0, 4)
	wheel_disc_rect.size = Vector2(220, 220)
	wheel_disc_rect.pivot_offset = Vector2(110, 110)
	wheel_holder.add_child(wheel_disc_rect)

	var needle_rect := TextureRect.new()
	needle_rect.texture = SVGIcons.make_tex(SVGIcons.WHEEL_NEEDLE_SVG, 1.0)
	needle_rect.position = Vector2(96, -6)
	needle_rect.size = Vector2(28, 32)
	wheel_holder.add_child(needle_rect)

	prop_outcome_lbl = _make_label("", 17, Color(1.0, 0.84, 0.74), false)
	prop_outcome_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prop_outcome_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(prop_outcome_lbl)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 12)
	vb.add_child(btn_row)

	prop_repeat_btn = _make_ruby_cta_btn("Lanzar de nuevo", Vector2(180, 42))
	prop_repeat_btn.pressed.connect(_repeat_prop_modal)
	btn_row.add_child(prop_repeat_btn)

	prop_close_btn = _make_pill_btn("Volver a la mesa", func(): prop_modal.visible = false)
	prop_close_btn.custom_minimum_size = Vector2(150, 42)
	btn_row.add_child(prop_close_btn)

	# 2. Climax Modal: "Los 3 Sobres Dorados"
	climax_modal = _make_modal_backdrop()
	var cl_card := _make_modal_card(climax_modal, Vector2(580, 380))
	var cl_vb := VBoxContainer.new()
	cl_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	cl_vb.add_theme_constant_override("separation", 14)
	cl_card.add_child(cl_vb)

	climax_title_lbl = _make_label("Los 3 Sobres Dorados", 32, Color(1.0, 0.86, 0.65), true)
	climax_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cl_vb.add_child(climax_title_lbl)

	climax_sub_lbl = _make_label("¡Complicidad al máximo! Elijan juntos un sobre sellado", 14, Color.WHITE, false)
	climax_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cl_vb.add_child(climax_sub_lbl)

	var env_row := HBoxContainer.new()
	env_row.alignment = BoxContainer.ALIGNMENT_CENTER
	env_row.add_theme_constant_override("separation", 14)
	cl_vb.add_child(env_row)

	var env_tex := SVGIcons.make_tex(SVGIcons.GOLDEN_ENVELOPE_SVG, 1.0)
	for i in range(3):
		var eb := Button.new()
		eb.custom_minimum_size = Vector2(162, 110)
		eb.icon = env_tex
		eb.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		eb.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		eb.text = DeckData.CLIMAX_ENVELOPES[i]["label_es"]
		eb.add_theme_font_size_override("font_size", 13)
		eb.add_theme_stylebox_override("normal", _glass_style(Color(0.22, 0.04, 0.09, 0.9), Color(1.0, 0.82, 0.45), 16, 2))
		eb.add_theme_stylebox_override("hover", _glass_style(Color(0.55, 0.08, 0.20, 0.95), Color(1.0, 0.92, 0.65), 16, 2))
		eb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var idx := i
		eb.pressed.connect(func():
			sfx.play_climax()
			var item: Dictionary = DeckData.CLIMAX_ENVELOPES[idx]
			climax_result_lbl.text = item[lang]
		)
		env_row.add_child(eb)
		envelope_btns.append(eb)

	climax_result_lbl = _make_label("", 17, Color(1.0, 0.88, 0.72), true)
	climax_result_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	climax_result_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	climax_result_lbl.custom_minimum_size = Vector2(500, 56)
	cl_vb.add_child(climax_result_lbl)

	var cl_close := _make_pill_btn("Continuar jugando", func(): climax_modal.visible = false)
	cl_close.custom_minimum_size = Vector2(180, 40)
	cl_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cl_vb.add_child(cl_close)

	# 3. Couple Names Modal
	couple_modal = _make_modal_backdrop()
	var c_card := _make_modal_card(couple_modal, Vector2(400, 290))
	var c_vb := VBoxContainer.new()
	c_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	c_vb.add_theme_constant_override("separation", 12)
	c_card.add_child(c_vb)

	couple_title_lbl = _make_label("Nuestra Pareja", 28, Color.WHITE, true)
	couple_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c_vb.add_child(couple_title_lbl)

	couple_sub_lbl = _make_label("Personalicen sus nombres para los turnos", 13, Color(1.0, 0.85, 0.88, 0.8), false)
	couple_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c_vb.add_child(couple_sub_lbl)

	p1_input = LineEdit.new()
	p1_input.placeholder_text = "Jugador 1"
	p1_input.custom_minimum_size = Vector2(320, 38)
	c_vb.add_child(p1_input)

	p2_input = LineEdit.new()
	p2_input.placeholder_text = "Jugador 2"
	p2_input.custom_minimum_size = Vector2(320, 38)
	c_vb.add_child(p2_input)

	save_couple_btn = _make_ruby_cta_btn("Guardar y jugar", Vector2(220, 44))
	save_couple_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	save_couple_btn.pressed.connect(func():
		player_names[1] = p1_input.text.strip_edges()
		player_names[2] = p2_input.text.strip_edges()
		couple_modal.visible = false
		_refresh_all_texts()
	)
	c_vb.add_child(save_couple_btn)

# ================= UI HELPERS =================
func _glass_style(bg: Color, border: Color, radius: int, border_w: int, shadow_size: int = 16, shadow_col: Color = Color(0, 0, 0, 0.55)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.shadow_size = shadow_size
	sb.shadow_color = shadow_col
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb

func _make_label(txt: String, fsize: int, col: Color, use_italic_serif: bool) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", col)
	if use_italic_serif and italic_serif:
		l.add_theme_font_override("font", italic_serif)
	return l

func _make_glass_icon_btn(svg_str: String) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(44, 40)
	if svg_str != "":
		b.icon = SVGIcons.make_tex(svg_str, 1.0)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.add_theme_stylebox_override("normal", _glass_style(Color(0.09, 0.02, 0.05, 0.68), Color(1.0, 0.72, 0.76, 0.28), 11, 1, 8))
	b.add_theme_stylebox_override("hover", _glass_style(Color(0.75, 0.08, 0.25, 0.42), Color(1.0, 0.84, 0.74, 0.72), 11, 1, 10))
	b.add_theme_stylebox_override("pressed", _glass_style(Color(0.55, 0.05, 0.18, 0.55), Color(1.0, 0.84, 0.74, 0.85), 11, 1, 6))
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return b

func _make_nav_btn(txt: String, svg_str: String, is_active: bool, cb: Callable) -> Button:
	var b := Button.new()
	b.text = "   " + txt
	b.icon = SVGIcons.make_tex(svg_str, 1.0)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(200, 42)
	b.add_theme_font_size_override("font_size", 15)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(cb)
	_style_nav_btn(b, is_active)
	return b

func _style_nav_btn(b: Button, is_active: bool) -> void:
	if is_active:
		var active_sb := _glass_style(Color(0.84, 0.10, 0.29, 0.92), Color(1.0, 0.78, 0.82, 0.65), 13, 1, 12, Color(0.85, 0.10, 0.30, 0.42))
		b.add_theme_stylebox_override("normal", active_sb)
		b.add_theme_stylebox_override("hover", active_sb)
	else:
		var idle_sb := _glass_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 13, 0, 0)
		var hov_sb := _glass_style(Color(1.0, 0.22, 0.42, 0.16), Color(1.0, 0.75, 0.80, 0.25), 13, 1, 0)
		b.add_theme_stylebox_override("normal", idle_sb)
		b.add_theme_stylebox_override("hover", hov_sb)

func _make_side_fanned_card(tex: Texture2D) -> PanelContainer:
	var p := PanelContainer.new()
	p.size = Vector2(172, 248)
	var sb := _glass_style(Color(0.22, 0.02, 0.08), Color(1.0, 0.74, 0.64), 16, 2, 18, Color(0.95, 0.32, 0.45, 0.36))
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	p.add_theme_stylebox_override("panel", sb)
	var tr := TextureRect.new()
	tr.texture = tex
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(tr)
	return p

func _make_hero_card_container(sz: Vector2) -> PanelContainer:
	var p := PanelContainer.new()
	p.size = sz
	var sb := _glass_style(Color(0.08, 0.01, 0.03), Color(1.0, 0.88, 0.78), 18, 3, 24, Color(1.0, 0.58, 0.45, 0.62))
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	p.add_theme_stylebox_override("panel", sb)
	var clip := Control.new()
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_PASS
	p.add_child(clip)
	return p

func _make_ruby_cta_btn(txt: String, sz: Vector2) -> Button:
	var b := Button.new()
	b.text = "  " + txt
	b.icon = SVGIcons.make_tex(SVGIcons.PLAY_TRIANGLE, 0.9)
	b.custom_minimum_size = sz
	b.size = sz
	b.add_theme_font_size_override("font_size", 19)
	b.add_theme_color_override("font_color", Color.WHITE)
	var sb_n := _glass_style(Color(0.84, 0.09, 0.27), Color(1.0, 0.84, 0.86, 0.78), 99, 2, 18, Color(0.95, 0.12, 0.35, 0.58))
	var sb_h := _glass_style(Color(0.96, 0.14, 0.34), Color(1.0, 0.92, 0.86, 0.95), 99, 2, 22, Color(1.0, 0.22, 0.45, 0.75))
	b.add_theme_stylebox_override("normal", sb_n)
	b.add_theme_stylebox_override("hover", sb_h)
	b.add_theme_stylebox_override("pressed", sb_n)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return b

func _make_pill_btn(txt: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = txt
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", Color.WHITE)
	var sb_n := _glass_style(Color(0.14, 0.03, 0.07, 0.82), Color(1.0, 0.76, 0.72, 0.45), 99, 1, 8)
	var sb_h := _glass_style(Color(0.78, 0.09, 0.26, 0.55), Color(1.0, 0.86, 0.76, 0.85), 99, 1, 10)
	b.add_theme_stylebox_override("normal", sb_n)
	b.add_theme_stylebox_override("hover", sb_h)
	b.add_theme_stylebox_override("pressed", sb_h)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(cb)
	return b

func _make_step_row(parent: VBoxContainer, num_str: String, txt: String) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)

	var badge := Label.new()
	badge.text = num_str
	badge.custom_minimum_size = Vector2(26, 26)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 13)
	badge.add_theme_stylebox_override("normal", _glass_style(Color(0.86, 0.10, 0.28), Color(1.0, 0.78, 0.82, 0.6), 99, 1, 6))
	row.add_child(badge)

	var l := _make_label(txt, 14, Color(1.0, 0.92, 0.95), false)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	return l

func _make_mini_action_btn(txt: String, svg_str: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = "  " + txt
	b.icon = SVGIcons.make_tex(svg_str, 0.45)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(240, 34)
	b.add_theme_font_size_override("font_size", 13)
	var sb_n := _glass_style(Color(1.0, 0.18, 0.36, 0.14), Color(1.0, 0.72, 0.78, 0.30), 10, 1, 4)
	var sb_h := _glass_style(Color(0.85, 0.10, 0.28, 0.42), Color(1.0, 0.86, 0.76, 0.75), 10, 1, 6)
	b.add_theme_stylebox_override("normal", sb_n)
	b.add_theme_stylebox_override("hover", sb_h)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(cb)
	return b

func _make_category_card(cat_idx: int) -> PanelContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.custom_minimum_size = Vector2(188, 134)
	p.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	cat_cards[cat_idx] = p

	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 4)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(vb)

	var icon_rect := TextureRect.new()
	icon_rect.texture = SVGIcons.make_tex(SVGIcons.get_category_svg(cat_idx), 1.0)
	icon_rect.custom_minimum_size = Vector2(44, 40)
	icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(icon_rect)

	var t_lbl := _make_label("", 16, Color.WHITE, false)
	t_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cat_titles[cat_idx] = t_lbl
	vb.add_child(t_lbl)

	var s_lbl := _make_label("", 12, Color(1.0, 0.86, 0.90, 0.78), false)
	s_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cat_subs[cat_idx] = s_lbl
	vb.add_child(s_lbl)

	p.mouse_entered.connect(func():
		if cat_textures.has(cat_idx) and cat_textures[cat_idx] != null:
			hero_couple_art.texture = cat_textures[cat_idx]
	)

	p.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			select_category(cat_idx)
	)

	_style_cat_card(cat_idx, cat_idx == active_cat)
	return p

func _style_cat_card(cat_idx: int, is_active: bool) -> void:
	var p: PanelContainer = cat_cards[cat_idx]
	if is_active:
		var sb := _glass_style(Color(0.82, 0.08, 0.26, 0.88), Color(1.0, 0.82, 0.70), 18, 2, 20, Color(1.0, 0.25, 0.42, 0.58))
		p.add_theme_stylebox_override("panel", sb)
	else:
		var sb := _glass_style(Color(0.14, 0.03, 0.07, 0.76), Color(1.0, 0.68, 0.74, 0.24), 18, 1, 12, Color(0, 0, 0, 0.55))
		p.add_theme_stylebox_override("panel", sb)

func _make_modal_backdrop() -> Control:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.005, 0.015, 0.84)
	bg.visible = false
	bg.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			bg.visible = false
	)
	add_child(bg)
	return bg

func _make_modal_card(backdrop: Control, sz: Vector2) -> PanelContainer:
	var p := PanelContainer.new()
	p.size = sz
	p.position = (Vector2(1366, 768) - sz) * 0.5
	var sb := _glass_style(Color(0.16, 0.025, 0.065, 0.96), Color(1.0, 0.84, 0.74), 24, 2, 28, Color(1.0, 0.22, 0.42, 0.45))
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 22
	sb.content_margin_bottom = 22
	p.add_theme_stylebox_override("panel", sb)
	backdrop.add_child(p)
	return p

# ================= GAMEPLAY LOGIC & CARD FLIP =================
func switch_view(view_name: String) -> void:
	var is_play := view_name == "play"
	home_view.visible = not is_play
	play_view.visible = is_play
	_style_nav_btn(nav_buttons["home"], not is_play)
	_style_nav_btn(nav_buttons["play"], is_play)

	if is_play and current_card.is_empty():
		deal_next_card(true)
	else:
		sfx.play_flip()

func select_category(cat_idx: int) -> void:
	active_cat = cat_idx
	if cat_textures.has(cat_idx) and cat_textures[cat_idx] != null:
		hero_couple_art.texture = cat_textures[cat_idx]
	for i in range(1, 6):
		_style_cat_card(i, i == active_cat)
	switch_view("play")
	deal_next_card(true)

func _get_bag(cat_idx: int) -> Array:
	if not draw_bags.has(cat_idx) or draw_bags[cat_idx].is_empty():
		var pool: Array = []
		for c in DeckData.DECK:
			if c["cat"] == cat_idx:
				pool.append(c)
		pool.shuffle()
		draw_bags[cat_idx] = pool
	return draw_bags[cat_idx]

func deal_next_card(keep_turn: bool = false) -> void:
	timer_running = false
	twist_visible = false
	secret_stage = 0
	secret_p1_choice = -1

	if not keep_turn:
		current_turn = 2 if current_turn == 1 else 1

	var bag := _get_bag(active_cat)
	current_card = bag.pop_back()
	timer_remaining = current_card.get("time", 0)

	sfx.play_flip()
	_refresh_all_texts()

	# Physical Two-Step Card Flip Animation (Back -> 0 width -> Front)
	card_animating = true
	active_game_card.position = card_base_pos
	active_game_card.rotation = 0.0
	active_game_card.scale = Vector2(0.92, 0.92)
	card_back_cover.visible = true
	card_front_root.visible = false
	stamp_done.modulate.a = 0.0
	stamp_pass.modulate.a = 0.0

	var tw := create_tween()
	tw.tween_property(active_game_card, "scale", Vector2(0.02, 1.03), 0.13).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		card_back_cover.visible = false
		card_front_root.visible = true
	)
	tw.tween_property(active_game_card, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		card_animating = false
		if current_card.get("type", "") == "Dice":
			open_dice_modal()
	)

func _on_secret_option_picked(opt_idx: int) -> void:
	var t: Dictionary = DeckData.TEXTS[lang]
	if secret_stage == 0:
		secret_p1_choice = opt_idx
		secret_stage = 1
		sfx.play_flip()
		var other_turn := 2 if current_turn == 1 else 1
		secret_hint_lbl.text = t["secret_p2_hint"] + _get_player_name(other_turn)
	elif secret_stage == 1:
		secret_stage = 2
		secret_opt_a_btn.visible = false
		secret_opt_b_btn.visible = false
		if opt_idx == secret_p1_choice:
			sfx.play_complete()
			secret_hint_lbl.text = t["secret_match"]
			_add_heat(2)
		else:
			sfx.play_pass()
			secret_hint_lbl.text = t["secret_diff"]

func _add_heat(amount: int) -> void:
	heat_points = min(MAX_HEAT, heat_points + amount)
	heat_bar.value = heat_points
	if heat_points >= MAX_HEAT and not climax_shown:
		climax_shown = true
		sfx.play_climax()
		climax_result_lbl.text = ""
		climax_modal.visible = true

func trigger_card_action(dir: int) -> void:
	if card_animating:
		return
	if dir < 0 and passes_left[current_turn] <= 0:
		_snap_card_back()
		open_wheel_modal()
		return

	card_animating = true
	if dir > 0:
		sfx.play_complete()
		stamp_done.modulate.a = 1.0
		_add_heat(1)
	else:
		sfx.play_pass()
		stamp_pass.modulate.a = 1.0
		passes_left[current_turn] -= 1

	var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(active_game_card, "position:x", card_base_pos.x + dir * 360.0, 0.22)
	tw.tween_property(active_game_card, "rotation", dir * 0.22, 0.22)
	tw.chain().tween_callback(func():
		card_animating = false
		deal_next_card(false)
	)

func _on_active_card_input(event: InputEvent) -> void:
	if card_animating:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging_card = true
			drag_start_x = event.global_position.x
			drag_dx = 0.0
		else:
			if dragging_card:
				dragging_card = false
				if drag_dx > 90.0:
					trigger_card_action(1)
				elif drag_dx < -90.0:
					trigger_card_action(-1)
				else:
					_snap_card_back()
	elif event is InputEventMouseMotion and dragging_card:
		drag_dx = event.global_position.x - drag_start_x
		active_game_card.position.x = card_base_pos.x + drag_dx
		active_game_card.rotation = clampf(drag_dx * 0.0009, -0.22, 0.22)
		stamp_done.modulate.a = clampf((drag_dx - 24.0) / 75.0, 0.0, 1.0)
		stamp_pass.modulate.a = clampf((-drag_dx - 24.0) / 75.0, 0.0, 1.0)

func _snap_card_back() -> void:
	var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tw.tween_property(active_game_card, "position", card_base_pos, 0.22)
	tw.tween_property(active_game_card, "rotation", 0.0, 0.22)
	tw.tween_property(stamp_done, "modulate:a", 0.0, 0.15)
	tw.tween_property(stamp_pass, "modulate:a", 0.0, 0.15)

# ================= DICE & VISUAL ROULETTE WHEEL =================
func open_dice_modal() -> void:
	prop_mode = "dice"
	var t: Dictionary = DeckData.TEXTS[lang]
	prop_title_lbl.text = t["dice_title"]
	prop_sub_lbl.text = t["dice_sub"]
	dice_row_box.visible = true
	wheel_holder.visible = false
	prop_repeat_btn.text = "  " + t["roll_again"]
	prop_close_btn.text = t["back_table"]
	prop_modal.visible = true
	_roll_dice_now()

func _roll_dice_now() -> void:
	sfx.play_dice()
	prop_outcome_lbl.text = "..."
	d1_panel.scale = Vector2(0.75, 0.75)
	d2_panel.scale = Vector2(0.75, 0.75)
	d1_panel.rotation = -0.35
	d2_panel.rotation = 0.35

	var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(d1_panel, "scale", Vector2.ONE, 0.45)
	tw.tween_property(d2_panel, "scale", Vector2.ONE, 0.45)
	tw.tween_property(d1_panel, "rotation", 0.0, 0.45)
	tw.tween_property(d2_panel, "rotation", 0.0, 0.45)

	var act: Dictionary = DeckData.DICE_ACTIONS[randi() % DeckData.DICE_ACTIONS.size()]
	var zone: Dictionary = DeckData.DICE_ZONES[randi() % DeckData.DICE_ZONES.size()]
	die_1_val.text = act[lang]
	die_2_val.text = zone[lang]
	prop_outcome_lbl.text = "%s · %s" % [act[lang], zone[lang]]

func open_wheel_modal() -> void:
	prop_mode = "wheel"
	var t: Dictionary = DeckData.TEXTS[lang]
	prop_title_lbl.text = t["wheel_title"]
	prop_sub_lbl.text = t["wheel_sub"]
	dice_row_box.visible = false
	wheel_holder.visible = true
	prop_repeat_btn.text = "  " + t["spin_again"]
	prop_close_btn.text = t["back_table"]
	prop_modal.visible = true
	_spin_wheel_now()

func _spin_wheel_now() -> void:
	if wheel_spinning:
		return
	wheel_spinning = true
	prop_outcome_lbl.text = "..."
	var target_deg: float = wheel_angle + 1080.0 + randf_range(360.0, 720.0)
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "wheel_angle", target_deg, 2.2)
	tw.tween_callback(func():
		wheel_spinning = false
		sfx.play_complete()
		var seg: Dictionary = DeckData.WHEEL_OUTCOMES[randi() % DeckData.WHEEL_OUTCOMES.size()]
		prop_outcome_lbl.text = seg[lang]
	)

func _repeat_prop_modal() -> void:
	if prop_mode == "dice":
		_roll_dice_now()
	else:
		_spin_wheel_now()

func open_couple_modal() -> void:
	p1_input.text = player_names[1]
	p2_input.text = player_names[2]
	couple_modal.visible = true

func _toggle_twist() -> void:
	twist_visible = not twist_visible
	game_twist_lbl.visible = twist_visible
	sfx.play_flip()

func _toggle_timer() -> void:
	if timer_remaining <= 0:
		timer_remaining = current_card.get("time", 20)
	timer_running = not timer_running
	sfx.play_heartbeat()
	_refresh_all_texts()

func _toggle_lang() -> void:
	lang = "en" if lang == "es" else "es"
	sfx.play_flip()
	_refresh_all_texts()

func _toggle_sound() -> void:
	sfx.muted = not sfx.muted
	sound_top_btn.modulate.a = 0.45 if sfx.muted else 1.0

func _toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _get_player_name(idx: int) -> String:
	var custom: String = player_names.get(idx, "")
	if custom != "":
		return custom
	var t: Dictionary = DeckData.TEXTS[lang]
	return t["p1_default"] if idx == 1 else t["p2_default"]

func _refresh_all_texts() -> void:
	var t: Dictionary = DeckData.TEXTS[lang]
	brand_tagline_lbl.text = t["brand_tagline"]
	hero_title_lbl.text = t["hero_title"]
	hero_sub_lbl.text = t["hero_sub"]
	lang_top_btn.text = lang.to_upper()

	nav_buttons["home"].text = "   " + t["nav_home"]
	nav_buttons["play"].text = "   " + t["nav_play"]
	nav_buttons["cats"].text = "   " + t["nav_cats"]
	nav_buttons["couple"].text = "   " + t["nav_couple"]
	nav_buttons["settings"].text = "   " + t["nav_settings"]

	main_play_btn.text = "  " + t["main_play"]
	howto_title_lbl.text = t["howto_title"]
	step1_lbl.text = t["step_1"]
	step2_lbl.text = t["step_2"]
	step3_lbl.text = t["step_3"]
	btn_quick_dice.text = "  " + t["btn_dice"]
	btn_quick_wheel.text = "  " + t["btn_wheel"]
	choose_cat_lbl.text = t["choose_cat"]

	for i in range(1, 6):
		cat_titles[i].text = t["cats"][i]["title"]
		cat_subs[i].text = t["cats"][i]["sub"]

	turn_chip_lbl.text = t["turn_of"] + _get_player_name(current_turn)
	heat_lbl.text = t["heat_label"]
	heat_bar.value = heat_points
	passes_chip_lbl.text = str(passes_left[current_turn]) + t["passes_left"]

	twist_pill_btn.text = t["twist_btn"]
	btn_pass_card.text = t["pass_btn"]
	btn_done_card.text = "  " + t["done_btn"]
	stamp_done.text = t["stamp_done"]
	stamp_pass.text = t["stamp_pass"]

	climax_title_lbl.text = t["climax_title"]
	climax_sub_lbl.text = t["climax_sub"]
	for i in range(envelope_btns.size()):
		envelope_btns[i].text = DeckData.CLIMAX_ENVELOPES[i]["label_" + lang]

	couple_title_lbl.text = t["couple_title"]
	couple_sub_lbl.text = t["couple_sub"]
	save_couple_btn.text = "  " + t["save_couple"]

	if not current_card.is_empty():
		var c_cat: int = current_card.get("cat", 1)
		var c_type: String = current_card.get("type", "Dare")
		if cat_textures.has(c_cat) and cat_textures[c_cat] != null:
			active_art_rect.texture = cat_textures[c_cat]
		game_cat_lbl.text = str(t["cats"][c_cat]["title"]).to_upper()
		game_type_lbl.text = t["types"].get(c_type, c_type)
		game_icon_rect.texture = SVGIcons.make_tex(SVGIcons.get_category_svg(c_cat), 1.0)
		game_prompt_lbl.text = current_card.get(lang, "")
		game_twist_lbl.text = current_card.get("twist_" + lang, "")
		game_twist_lbl.visible = twist_visible

		if c_type == "Secret":
			secret_box.visible = true
			secret_opt_a_btn.visible = (secret_stage < 2)
			secret_opt_b_btn.visible = (secret_stage < 2)
			secret_opt_a_btn.text = current_card.get("opt_a_" + lang, "A")
			secret_opt_b_btn.text = current_card.get("opt_b_" + lang, "B")
			if secret_stage == 0:
				secret_hint_lbl.text = t["secret_p1_hint"] + _get_player_name(current_turn)
		else:
			secret_box.visible = false

		var has_time: bool = current_card.get("time", 0) > 0
		timer_pill_btn.visible = has_time
		if has_time:
			timer_pill_btn.text = str(timer_remaining) + "s"

func _process(delta: float) -> void:
	# Subtle Mouse Parallax on Fanned Deck & Active Card
	var mpos := get_viewport().get_mouse_position()
	var norm_x := clampf((mpos.x - 683.0) / 683.0, -1.0, 1.0)
	var norm_y := clampf((mpos.y - 384.0) / 384.0, -1.0, 1.0)

	if home_view and home_view.visible and deck_holder:
		deck_holder.position = deck_holder.position.lerp(Vector2(113.0 + norm_x * 10.0, 18.0 + norm_y * 6.0), delta * 6.0)
	elif play_view and play_view.visible and not dragging_card and not card_animating:
		active_game_card.rotation = lerpf(active_game_card.rotation, norm_x * 0.03, delta * 6.0)

	# Visual Roulette Wheel Spin & Peg Ticks
	if wheel_disc_rect:
		wheel_disc_rect.rotation_degrees = wheel_angle
		if wheel_spinning:
			var peg_idx := int(fposmod(wheel_angle, 360.0) / 60.0)
			if peg_idx != last_wheel_peg:
				last_wheel_peg = peg_idx
				sfx.play_wheel_tick()

	# Heartbeat Countdown Timer
	if timer_running and timer_remaining > 0:
		timer_accum += delta
		if timer_accum >= 1.0:
			timer_accum -= 1.0
			timer_remaining -= 1
			if timer_remaining > 0:
				sfx.play_heartbeat()
			else:
				timer_running = false
				sfx.play_climax()
			timer_pill_btn.text = str(timer_remaining) + "s"

func _unhandled_input(event: InputEvent) -> void:
	if not play_view or not play_view.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_RIGHT:
			trigger_card_action(1)
		elif event.keycode == KEY_LEFT:
			trigger_card_action(-1)
