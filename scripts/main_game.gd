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
var jewel_norm_tex: Texture2D
var jewel_hov_tex: Texture2D

# Game State
var lang: String = "es"
var active_cat: int = 1
var auto_escalate: bool = true
var current_turn: int = 1
var player_names := {1: "", 2: ""}
var custom_wishes := {1: "", 2: ""}
var custom_wish_used := {1: false, 2: false}
var passes_left := {1: 3, 2: 3}
var heat_points: int = 1
const MAX_HEAT: int = 12
var climax_shown: bool = false

var draw_bags := {}
var current_card: Dictionary = {}
var timer_remaining: int = 0
var timer_running: bool = false
var timer_accum: float = 0.0
var half_beat_fired: bool = false

# Secret Match ("¿Coinciden?") State
var secret_stage: int = 0 # 0=P1 picking, 1=P2 picking, 2=Revealed
var secret_p1_choice: int = -1

# Living Background & Candle Flicker
var candle_time: float = 0.0
var candle_glow_l: ColorRect
var candle_glow_r: ColorRect

# Top Bar UI
var top_couple_btn: Button
var top_lang_btn: Button
var top_dice_btn: Button
var top_sound_btn: Button
var top_center_brand: Control
var top_center_hud: VBoxContainer
var turn_chip_lbl: Label
var heat_bar: ProgressBar
var heat_val_lbl: Label

# Home View (Centered)
var home_view: Control
var deck_holder: Control
var left_fanned_card: Control
var right_fanned_card: Control
var center_fanned_card: Control
var hero_couple_art: TextureRect
var main_play_btn: Button

# Play View (Centered Giant Card + 1 Action)
var play_view: Control
var card_stage: Control
var active_game_card: PanelContainer
var card_base_pos := Vector2(12, 0)
var card_front_root: Control
var card_back_cover: TextureRect
var active_art_rect: TextureRect
var game_cat_lbl: Label
var game_prompt_rtl: RichTextLabel

# Secret Choice UI inside Card
var secret_box: HBoxContainer
var secret_opt_a_btn: Button
var secret_opt_b_btn: Button
var secret_hint_lbl: Label

var stamp_done: Label
var stamp_pass: Label
var btn_pass_card: Button
var pass_badge_lbl: Label
var btn_done_card: Button

# Bottom Floating Icon Dock
var active_cat_name_lbl: Label
var cat_dock_btns := {}

# Swipe & Parallax State
var dragging_card: bool = false
var drag_start_x: float = 0.0
var drag_dx: float = 0.0
var card_animating: bool = false

# Modal: Roulette & Real Illustrated Dice
var prop_modal: Control
var tab_wheel_btn: Button
var tab_dice_btn: Button
var dice_row_box: HBoxContainer
var d1_cube: Control
var d2_cube: Control
var die_1_icon: TextureRect
var die_2_icon: TextureRect
var die_1_val: Label
var die_2_val: Label
var dice_rolling: bool = false
var wheel_holder: Control
var wheel_disc_rect: TextureRect
var wheel_angle: float = 0.0
var wheel_spinning: bool = false
var last_wheel_peg: int = -1
var prop_outcome_rtl: RichTextLabel
var prop_repeat_btn: Button
var prop_close_btn: Button
var prop_mode: String = "wheel"
var forfeit_mode: bool = false

# Modal: Climax ("Los 3 Sobres Dorados")
var climax_modal: Control
var climax_title_lbl: Label
var climax_sub_lbl: Label
var climax_result_rtl: RichTextLabel
var envelope_btns: Array[Button] = []

# Modal: Couple Names & Secret Wishes
var couple_modal: Control
var couple_title_lbl: Label
var p1_input: LineEdit
var p2_input: LineEdit
var p1_wish_input: LineEdit
var p2_wish_input: LineEdit
var save_couple_btn: Button
var reset_game_btn: Button

func _ready() -> void:
	randomize()
	DisplayServer.screen_set_keep_on(true)
	set_anchors_preset(Control.PRESET_FULL_RECT)

	sfx = SoundFXScript.new()
	add_child(sfx)

	_load_prefs()
	_load_fonts()
	_preload_art()
	_build_living_background()
	_build_mobile_shell()
	_build_modals()
	p1_input.text = player_names.get(1, "")
	p2_input.text = player_names.get(2, "")
	p1_wish_input.text = custom_wishes.get(1, "")
	p2_wish_input.text = custom_wishes.get(2, "")
	p1_wish_input.secret = (p1_wish_input.text != "")
	p2_wish_input.secret = (p2_wish_input.text != "")
	_refresh_all_texts()

func _load_prefs() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://couple_prefs.cfg") == OK:
		player_names[1] = str(cfg.get_value("couple", "p1", ""))
		player_names[2] = str(cfg.get_value("couple", "p2", ""))
		custom_wishes[1] = str(cfg.get_value("couple", "w1", ""))
		custom_wishes[2] = str(cfg.get_value("couple", "w2", ""))
		lang = str(cfg.get_value("couple", "lang", "es"))

func _save_prefs() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("couple", "p1", player_names.get(1, ""))
	cfg.set_value("couple", "p2", player_names.get(2, ""))
	cfg.set_value("couple", "w1", custom_wishes.get(1, ""))
	cfg.set_value("couple", "w2", custom_wishes.get(2, ""))
	cfg.set_value("couple", "lang", lang)
	cfg.save("user://couple_prefs.cfg")

func _load_fonts() -> void:
	if ResourceLoader.exists("res://playfair-display-700.woff2"):
		var loaded_f = load("res://playfair-display-700.woff2")
		if loaded_f is FontFile:
			serif_font = loaded_f
	if not serif_font:
		serif_font = FontFile.new()
		var font_bytes := FileAccess.get_file_as_bytes("res://playfair-display-700.woff2")
		if not font_bytes.is_empty():
			serif_font.data = font_bytes

	italic_serif = FontVariation.new()
	italic_serif.base_font = serif_font
	italic_serif.variation_transform = Transform2D(Vector2(1.0, 0.0), Vector2(-0.20, 1.0), Vector2.ZERO)

func _preload_art() -> void:
	side_back_tex = SVGIcons.make_tex(SVGIcons.SIDE_CARD_BACK, 1.4)
	jewel_norm_tex = SVGIcons.make_tex(SVGIcons.BTN_JEWEL_PRIMARY, 1.0)
	jewel_hov_tex = SVGIcons.make_tex(SVGIcons.BTN_JEWEL_HOVER, 1.0)
	for k in CAT_ART_PATHS.keys():
		cat_textures[k] = _load_external_tex(CAT_ART_PATHS[k])

func _load_external_tex(res_path: String) -> Texture2D:
	if ResourceLoader.exists(res_path):
		var loaded_tex = load(res_path)
		if loaded_tex is Texture2D:
			return loaded_tex
	var raw_bytes := FileAccess.get_file_as_bytes(res_path)
	if not raw_bytes.is_empty():
		var img := Image.new()
		if img.load_jpg_from_buffer(raw_bytes) == OK and not img.is_empty():
			return ImageTexture.create_from_image(img)
	return null

# ============================================================================
# 1. LIVING TABLETOP BACKGROUND (Candlelight Pulse + Floating Golden Embers)
# ============================================================================
func _build_living_background() -> void:
	var bg_tex := _load_external_tex("res://assets/bg-table.jpg")
	if bg_tex:
		var bg_rect := TextureRect.new()
		bg_rect.texture = bg_tex
		bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(bg_rect)

	var dark_overlay := ColorRect.new()
	dark_overlay.color = Color(0.05, 0.008, 0.02, 0.44)
	dark_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	dark_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dark_overlay)

	candle_glow_l = ColorRect.new()
	candle_glow_l.color = Color(1.0, 0.45, 0.20, 0.08)
	candle_glow_l.custom_minimum_size = Vector2(180, 260)
	candle_glow_l.position = Vector2(-30, 620)
	candle_glow_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(candle_glow_l)

	candle_glow_r = ColorRect.new()
	candle_glow_r.color = Color(1.0, 0.38, 0.22, 0.08)
	candle_glow_r.custom_minimum_size = Vector2(180, 260)
	candle_glow_r.position = Vector2(280, 620)
	candle_glow_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(candle_glow_r)

	var embers := CPUParticles2D.new()
	embers.position = Vector2(215, 860)
	embers.amount = 18
	embers.lifetime = 5.5
	embers.preprocess = 3.0
	embers.texture = SVGIcons.make_tex(SVGIcons.EMBER_DOT_SVG, 0.7)
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = Vector2(190, 40)
	embers.direction = Vector2(0, -1)
	embers.spread = 22.0
	embers.gravity = Vector2(0, -14)
	embers.initial_velocity_min = 12.0
	embers.initial_velocity_max = 28.0
	embers.scale_amount_min = 0.35
	embers.scale_amount_max = 0.85
	embers.color = Color(1.0, 0.78, 0.62, 0.55)
	add_child(embers)

# ============================================================================
# 2. SINGLE-COLUMN MOBILE SHELL (Top HUD + Centered Stage + Bottom Icon Dock)
# ============================================================================
func _build_mobile_shell() -> void:
	var root_col := VBoxContainer.new()
	root_col.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_col.offset_left = 18
	root_col.offset_top = 16
	root_col.offset_right = -18
	root_col.offset_bottom = -16
	root_col.add_theme_constant_override("separation", 8)
	add_child(root_col)

	# --- TOP MINIMAL HUD ---
	var top_bar := HBoxContainer.new()
	top_bar.custom_minimum_size = Vector2(0, 56)
	top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	top_bar.add_theme_constant_override("separation", 8)
	root_col.add_child(top_bar)

	top_couple_btn = _make_icon_btn(SVGIcons.NAV_COUPLE)
	top_couple_btn.pressed.connect(func(): couple_modal.visible = true)
	top_bar.add_child(top_couple_btn)

	top_lang_btn = _make_text_chip_btn("ES")
	top_lang_btn.pressed.connect(_toggle_lang)
	top_bar.add_child(top_lang_btn)

	var center_slot := Control.new()
	center_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_slot.custom_minimum_size = Vector2(150, 54)
	top_bar.add_child(center_slot)

	top_center_brand = HBoxContainer.new()
	top_center_brand.set_anchors_preset(Control.PRESET_FULL_RECT)
	top_center_brand.alignment = BoxContainer.ALIGNMENT_CENTER
	top_center_brand.add_theme_constant_override("separation", 6)
	center_slot.add_child(top_center_brand)

	var b_heart := TextureRect.new()
	b_heart.texture = SVGIcons.make_tex(SVGIcons.BRAND_HEART, 0.55)
	b_heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top_center_brand.add_child(b_heart)

	var b_lbl := Label.new()
	b_lbl.text = "Entre Nosotros"
	b_lbl.add_theme_font_override("font", italic_serif)
	b_lbl.add_theme_font_size_override("font_size", 21)
	b_lbl.add_theme_color_override("font_color", Color(1.0, 0.94, 0.96))
	b_lbl.add_theme_color_override("font_shadow_color", Color(0.95, 0.14, 0.36, 0.45))
	b_lbl.add_theme_constant_override("shadow_offset_y", 2)
	top_center_brand.add_child(b_lbl)

	top_center_hud = VBoxContainer.new()
	top_center_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	top_center_hud.alignment = BoxContainer.ALIGNMENT_CENTER
	top_center_hud.add_theme_constant_override("separation", 4)
	top_center_hud.visible = false
	center_slot.add_child(top_center_hud)

	turn_chip_lbl = Label.new()
	turn_chip_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_chip_lbl.add_theme_font_override("font", italic_serif)
	turn_chip_lbl.add_theme_font_size_override("font_size", 16)
	turn_chip_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.78))
	top_center_hud.add_child(turn_chip_lbl)

	var bar_row := HBoxContainer.new()
	bar_row.alignment = BoxContainer.ALIGNMENT_CENTER
	bar_row.add_theme_constant_override("separation", 6)
	top_center_hud.add_child(bar_row)

	var mini_flame := TextureRect.new()
	mini_flame.texture = SVGIcons.make_tex(SVGIcons.CAT_1_FLAME, 0.36)
	mini_flame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bar_row.add_child(mini_flame)

	heat_bar = ProgressBar.new()
	heat_bar.min_value = 0
	heat_bar.max_value = MAX_HEAT
	heat_bar.value = heat_points
	heat_bar.show_percentage = false
	heat_bar.custom_minimum_size = Vector2(110, 8)
	heat_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var hb_bg := StyleBoxFlat.new()
	hb_bg.bg_color = Color(0.18, 0.03, 0.08, 0.85)
	hb_bg.set_corner_radius_all(99)
	heat_bar.add_theme_stylebox_override("background", hb_bg)

	var hb_fill := StyleBoxFlat.new()
	hb_fill.bg_color = Color(1.0, 0.24, 0.44, 1.0)
	hb_fill.set_corner_radius_all(99)
	heat_bar.add_theme_stylebox_override("fill", hb_fill)
	bar_row.add_child(heat_bar)

	heat_val_lbl = Label.new()
	heat_val_lbl.text = "1/12"
	heat_val_lbl.add_theme_font_size_override("font_size", 11)
	heat_val_lbl.add_theme_color_override("font_color", Color(1.0, 0.76, 0.84))
	bar_row.add_child(heat_val_lbl)

	top_dice_btn = _make_icon_btn(SVGIcons.CAT_4_DICE)
	top_dice_btn.pressed.connect(func(): _open_prop_modal("dice", false))
	top_bar.add_child(top_dice_btn)

	top_sound_btn = _make_icon_btn(SVGIcons.ICON_SOUND)
	top_sound_btn.pressed.connect(func():
		sfx.muted = not sfx.muted
		top_sound_btn.modulate = Color(1, 1, 1, 0.42) if sfx.muted else Color(1, 1, 1, 1)
	)
	top_bar.add_child(top_sound_btn)

	# --- CENTER STAGE ---
	var center_stage := Control.new()
	center_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_col.add_child(center_stage)

	_build_home_stage(center_stage)
	_build_play_stage(center_stage)

	# --- BOTTOM FLOATING ICON DOCK ---
	var bottom_wrap := VBoxContainer.new()
	bottom_wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_wrap.add_theme_constant_override("separation", 6)
	root_col.add_child(bottom_wrap)

	active_cat_name_lbl = Label.new()
	active_cat_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	active_cat_name_lbl.add_theme_font_override("font", italic_serif)
	active_cat_name_lbl.add_theme_font_size_override("font_size", 16)
	active_cat_name_lbl.add_theme_color_override("font_color", Color(1.0, 0.86, 0.76))
	bottom_wrap.add_child(active_cat_name_lbl)

	var dock_panel := PanelContainer.new()
	dock_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var dock_style := StyleBoxFlat.new()
	dock_style.bg_color = Color(0.11, 0.015, 0.045, 0.88)
	dock_style.border_color = Color(1.0, 0.65, 0.74, 0.34)
	dock_style.set_border_width_all(1)
	dock_style.set_corner_radius_all(30)
	dock_style.content_margin_left = 12
	dock_style.content_margin_right = 12
	dock_style.content_margin_top = 8
	dock_style.content_margin_bottom = 8
	dock_panel.add_theme_stylebox_override("panel", dock_style)
	bottom_wrap.add_child(dock_panel)

	var dock_row := HBoxContainer.new()
	dock_row.alignment = BoxContainer.ALIGNMENT_CENTER
	dock_row.add_theme_constant_override("separation", 12)
	dock_panel.add_child(dock_row)

	for cat_idx in range(1, 6):
		var c_btn := _build_dock_icon_btn(cat_idx)
		dock_row.add_child(c_btn)
		cat_dock_btns[cat_idx] = c_btn

	_update_dock_styles()

# ============================================================================
# 3. HOME STAGE (Centered Fanned Cards + Jewel Gradient "Jugar" CTA)
# ============================================================================
func _build_home_stage(parent: Control) -> void:
	home_view = VBoxContainer.new()
	home_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	home_view.alignment = BoxContainer.ALIGNMENT_CENTER
	home_view.add_theme_constant_override("separation", 24)
	parent.add_child(home_view)

	deck_holder = Control.new()
	deck_holder.custom_minimum_size = Vector2(360, 440)
	deck_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	home_view.add_child(deck_holder)

	left_fanned_card = _build_side_fanned_card(Vector2(18, 56), -13.0)
	deck_holder.add_child(left_fanned_card)

	right_fanned_card = _build_side_fanned_card(Vector2(158, 56), 13.0)
	deck_holder.add_child(right_fanned_card)

	center_fanned_card = PanelContainer.new()
	center_fanned_card.custom_minimum_size = Vector2(246, 368)
	center_fanned_card.position = Vector2(57, 26)
	center_fanned_card.pivot_offset = Vector2(123, 184)

	var hero_style := StyleBoxFlat.new()
	hero_style.bg_color = Color(0.11, 0.015, 0.04, 1.0)
	hero_style.border_color = Color(1.0, 0.82, 0.72, 0.96)
	hero_style.set_border_width_all(4)
	hero_style.set_corner_radius_all(22)
	hero_style.shadow_color = Color(1.0, 0.20, 0.42, 0.46)
	hero_style.shadow_size = 30
	center_fanned_card.add_theme_stylebox_override("panel", hero_style)
	deck_holder.add_child(center_fanned_card)

	var hero_clip := Panel.new()
	hero_clip.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	var hc_s := StyleBoxFlat.new()
	hc_s.bg_color = Color.WHITE
	hc_s.set_corner_radius_all(18)
	hero_clip.add_theme_stylebox_override("panel", hc_s)
	center_fanned_card.add_child(hero_clip)

	hero_couple_art = TextureRect.new()
	hero_couple_art.texture = cat_textures.get(1)
	hero_couple_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_couple_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	hero_couple_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	hero_clip.add_child(hero_couple_art)

	var inner_frame := Panel.new()
	inner_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner_frame.offset_left = 10
	inner_frame.offset_top = 10
	inner_frame.offset_right = -10
	inner_frame.offset_bottom = -10
	inner_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var inf_style := StyleBoxFlat.new()
	inf_style.bg_color = Color(0, 0, 0, 0)
	inf_style.border_color = Color(1.0, 0.78, 0.68, 0.55)
	inf_style.set_border_width_all(1)
	inf_style.set_corner_radius_all(14)
	inner_frame.add_theme_stylebox_override("panel", inf_style)
	hero_clip.add_child(inner_frame)

	# Jewel Gradient CTA Button ("Jugar")
	main_play_btn = _make_jewel_cta_btn("Jugar", Vector2(260, 62), SVGIcons.PLAY_TRIANGLE)
	main_play_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_play_btn.pressed.connect(_start_game)
	home_view.add_child(main_play_btn)

func _build_side_fanned_card(pos: Vector2, rot_deg: float) -> Control:
	var holder := Control.new()
	holder.position = pos
	holder.custom_minimum_size = Vector2(184, 272)
	holder.pivot_offset = Vector2(92, 136)
	holder.rotation_degrees = rot_deg

	var glow := PanelContainer.new()
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	var gs := StyleBoxFlat.new()
	gs.bg_color = Color(0.18, 0.02, 0.06, 0.95)
	gs.border_color = Color(1.0, 0.80, 0.72, 0.85)
	gs.set_border_width_all(3)
	gs.set_corner_radius_all(16)
	gs.shadow_color = Color(0.95, 0.16, 0.36, 0.32)
	gs.shadow_size = 18
	glow.add_theme_stylebox_override("panel", gs)
	holder.add_child(glow)

	var tex_rect := TextureRect.new()
	tex_rect.texture = side_back_tex
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.add_child(tex_rect)
	return holder

# ============================================================================
# 4. PLAY STAGE (Giant Card with Curved Clip, Gold Divider & Semantic BBCode)
# ============================================================================
func _build_play_stage(parent: Control) -> void:
	play_view = VBoxContainer.new()
	play_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	play_view.visible = false
	play_view.alignment = BoxContainer.ALIGNMENT_CENTER
	play_view.add_theme_constant_override("separation", 16)
	parent.add_child(play_view)

	card_stage = Control.new()
	card_stage.custom_minimum_size = Vector2(394, 540)
	card_stage.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	play_view.add_child(card_stage)

	active_game_card = PanelContainer.new()
	active_game_card.custom_minimum_size = Vector2(370, 536)
	active_game_card.position = card_base_pos
	active_game_card.pivot_offset = Vector2(185, 268)
	active_game_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	active_game_card.gui_input.connect(_on_active_card_gui_input)

	var gc_style := StyleBoxFlat.new()
	gc_style.bg_color = Color(0.10, 0.012, 0.04, 0.98)
	gc_style.border_color = Color(1.0, 0.82, 0.70, 0.96)
	gc_style.set_border_width_all(3)
	gc_style.set_corner_radius_all(26)
	gc_style.shadow_color = Color(0.95, 0.14, 0.36, 0.48)
	gc_style.shadow_size = 34
	active_game_card.add_theme_stylebox_override("panel", gc_style)
	card_stage.add_child(active_game_card)

	var card_overlay := Control.new()
	active_game_card.add_child(card_overlay)

	# Card Back Cover (shown during physical flip)
	card_back_cover = TextureRect.new()
	card_back_cover.texture = side_back_tex
	card_back_cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_back_cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	card_back_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_back_cover.offset_left = 6
	card_back_cover.offset_top = 6
	card_back_cover.offset_right = -6
	card_back_cover.offset_bottom = -6
	card_back_cover.visible = false
	card_overlay.add_child(card_back_cover)

	# Card Front Root
	card_front_root = Control.new()
	card_front_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_overlay.add_child(card_front_root)

	# Rounded Clip Container for Top Category Art (True Curved Corners!)
	var art_clip := Panel.new()
	art_clip.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	art_clip.position = Vector2(8, 8)
	art_clip.size = Vector2(354, 260)
	art_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ac_s := StyleBoxFlat.new()
	ac_s.bg_color = Color.WHITE
	ac_s.corner_radius_top_left = 20
	ac_s.corner_radius_top_right = 20
	ac_s.corner_radius_bottom_left = 6
	ac_s.corner_radius_bottom_right = 6
	art_clip.add_theme_stylebox_override("panel", ac_s)
	card_front_root.add_child(art_clip)

	active_art_rect = TextureRect.new()
	active_art_rect.texture = cat_textures.get(1)
	active_art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	active_art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	active_art_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	active_art_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_clip.add_child(active_art_rect)

	# Ornamental Gold Filigree Divider with Ruby Heart between Art & Text
	var divider_rect := TextureRect.new()
	divider_rect.texture = SVGIcons.make_tex(SVGIcons.CARD_GOLD_DIVIDER_SVG, 1.0)
	divider_rect.position = Vector2(15, 256)
	divider_rect.size = Vector2(340, 26)
	divider_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	divider_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_front_root.add_child(divider_rect)

	# Minimal level badge floating on top of art
	var badge_pill := PanelContainer.new()
	badge_pill.position = Vector2(20, 18)
	var bp_s := StyleBoxFlat.new()
	bp_s.bg_color = Color(0.08, 0.01, 0.03, 0.82)
	bp_s.border_color = Color(1.0, 0.80, 0.70, 0.55)
	bp_s.set_border_width_all(1)
	bp_s.set_corner_radius_all(99)
	bp_s.content_margin_left = 12
	bp_s.content_margin_right = 12
	bp_s.content_margin_top = 4
	bp_s.content_margin_bottom = 4
	badge_pill.add_theme_stylebox_override("panel", bp_s)
	card_front_root.add_child(badge_pill)

	game_cat_lbl = Label.new()
	game_cat_lbl.add_theme_font_size_override("font_size", 11)
	game_cat_lbl.add_theme_color_override("font_color", Color(1.0, 0.86, 0.76))
	badge_pill.add_child(game_cat_lbl)

	# Bottom 48%: Rich Semantic Typography + Timer / Secret Buttons
	var body_col := VBoxContainer.new()
	body_col.position = Vector2(22, 286)
	body_col.size = Vector2(326, 232)
	body_col.alignment = BoxContainer.ALIGNMENT_CENTER
	body_col.add_theme_constant_override("separation", 12)
	body_col.mouse_filter = Control.MOUSE_FILTER_PASS
	card_front_root.add_child(body_col)

	game_prompt_rtl = RichTextLabel.new()
	game_prompt_rtl.bbcode_enabled = true
	game_prompt_rtl.fit_content = true
	game_prompt_rtl.scroll_active = false
	game_prompt_rtl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_prompt_rtl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	game_prompt_rtl.add_theme_font_override("normal_font", serif_font)
	game_prompt_rtl.add_theme_font_size_override("normal_font_size", 26)
	game_prompt_rtl.add_theme_color_override("default_color", Color(1.0, 0.97, 0.98))
	game_prompt_rtl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	game_prompt_rtl.add_theme_constant_override("shadow_offset_y", 2)
	game_prompt_rtl.add_theme_constant_override("line_separation", 4)
	body_col.add_child(game_prompt_rtl)

	# Secret Choice Hint + 2 Compact Side-by-Side Buttons
	secret_hint_lbl = Label.new()
	secret_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	secret_hint_lbl.add_theme_font_override("font", italic_serif)
	secret_hint_lbl.add_theme_font_size_override("font_size", 14)
	secret_hint_lbl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.70))
	secret_hint_lbl.visible = false
	body_col.add_child(secret_hint_lbl)

	secret_box = HBoxContainer.new()
	secret_box.alignment = BoxContainer.ALIGNMENT_CENTER
	secret_box.add_theme_constant_override("separation", 10)
	secret_box.visible = false
	body_col.add_child(secret_box)

	secret_opt_a_btn = _make_pill_btn("Opción A", Color(0.88, 0.14, 0.36))
	secret_opt_a_btn.custom_minimum_size = Vector2(150, 44)
	secret_opt_a_btn.pressed.connect(func(): _on_secret_option_picked(0))
	secret_box.add_child(secret_opt_a_btn)

	secret_opt_b_btn = _make_pill_btn("Opción B", Color(0.88, 0.14, 0.36))
	secret_opt_b_btn.custom_minimum_size = Vector2(150, 44)
	secret_opt_b_btn.pressed.connect(func(): _on_secret_option_picked(1))
	secret_box.add_child(secret_opt_b_btn)

	# Swipe Stamps
	stamp_done = _build_swipe_stamp("CUMPLIDO", Color(0.25, 0.95, 0.62), Vector2(22, 42), -12.0)
	card_front_root.add_child(stamp_done)

	stamp_pass = _build_swipe_stamp("PASO", Color(1.0, 0.32, 0.45), Vector2(236, 42), 12.0)
	card_front_root.add_child(stamp_pass)

	# --- SINGLE PRIMARY ACTION ROW BELOW CARD ---
	var act_row := HBoxContainer.new()
	act_row.alignment = BoxContainer.ALIGNMENT_CENTER
	act_row.add_theme_constant_override("separation", 14)
	play_view.add_child(act_row)

	var pass_wrap := Control.new()
	pass_wrap.custom_minimum_size = Vector2(58, 58)
	act_row.add_child(pass_wrap)

	btn_pass_card = Button.new()
	btn_pass_card.custom_minimum_size = Vector2(58, 58)
	btn_pass_card.pivot_offset = Vector2(29, 29)
	btn_pass_card.icon = SVGIcons.make_tex(SVGIcons.ICON_CROSS, 1.0)
	btn_pass_card.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_pass_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.18, 0.03, 0.08, 0.92)
	ps.border_color = Color(1.0, 0.58, 0.68, 0.55)
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(99)
	btn_pass_card.add_theme_stylebox_override("normal", ps)
	var ph := ps.duplicate()
	ph.bg_color = Color(0.32, 0.05, 0.13, 0.98)
	btn_pass_card.add_theme_stylebox_override("hover", ph)
	btn_pass_card.add_theme_stylebox_override("pressed", ph)
	_attach_bouncy_press(btn_pass_card)
	btn_pass_card.pressed.connect(func(): _handle_pass_pressed())
	pass_wrap.add_child(btn_pass_card)

	pass_badge_lbl = Label.new()
	pass_badge_lbl.text = "3"
	pass_badge_lbl.position = Vector2(40, 2)
	pass_badge_lbl.add_theme_font_size_override("font_size", 12)
	pass_badge_lbl.add_theme_color_override("font_color", Color(1.0, 0.84, 0.72))
	pass_wrap.add_child(pass_badge_lbl)

	# Unified Jewel Primary Button (Starts timer OR completes card in 1 single button!)
	btn_done_card = _make_jewel_cta_btn("¡Cumplido!", Vector2(252, 60), SVGIcons.ICON_CHECK)
	btn_done_card.pressed.connect(_on_primary_action_pressed)
	act_row.add_child(btn_done_card)

func _make_jewel_cta_btn(txt: String, min_sz: Vector2, icon_svg: String) -> Button:
	var btn := Button.new()
	btn.text = txt
	btn.custom_minimum_size = min_sz
	btn.pivot_offset = min_sz * 0.5
	btn.icon = SVGIcons.make_tex(icon_svg, 0.95)
	btn.add_theme_constant_override("h_separation", 10)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_override("font", serif_font)
	btn.add_theme_font_size_override("font_size", 21)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_shadow_color", Color(0.35, 0.02, 0.10, 0.75))
	btn.add_theme_constant_override("shadow_offset_y", 2)

	var st_norm := StyleBoxTexture.new()
	st_norm.texture = jewel_norm_tex
	st_norm.content_margin_left = 22
	st_norm.content_margin_right = 22
	btn.add_theme_stylebox_override("normal", st_norm)

	var st_hov := StyleBoxTexture.new()
	st_hov.texture = jewel_hov_tex
	st_hov.content_margin_left = 22
	st_hov.content_margin_right = 22
	btn.add_theme_stylebox_override("hover", st_hov)
	btn.add_theme_stylebox_override("pressed", st_hov)

	_attach_bouncy_press(btn)
	return btn

func _attach_bouncy_press(btn: Button) -> void:
	btn.button_down.connect(func():
		var tw := create_tween()
		tw.tween_property(btn, "scale", Vector2(0.93, 0.93), 0.07).set_trans(Tween.TRANS_QUAD)
	)
	btn.button_up.connect(func():
		var tw := create_tween()
		tw.tween_property(btn, "scale", Vector2(1.04, 1.04), 0.09).set_trans(Tween.TRANS_BACK)
		tw.tween_property(btn, "scale", Vector2.ONE, 0.08)
	)

func _build_swipe_stamp(txt: String, col: Color, pos: Vector2, rot: float) -> Label:
	var lbl := Label.new()
	lbl.text = txt
	lbl.position = pos
	lbl.rotation_degrees = rot
	lbl.modulate.a = 0.0
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", col)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.06, 0.01, 0.03, 0.85)
	st.border_color = col
	st.set_border_width_all(2)
	st.set_corner_radius_all(8)
	st.content_margin_left = 10
	st.content_margin_right = 10
	st.content_margin_top = 4
	st.content_margin_bottom = 4
	lbl.add_theme_stylebox_override("normal", st)
	return lbl

# ============================================================================
# 5. BOTTOM FLOATING ICON DOCK (5 Categories, Icon-Only)
# ============================================================================
func _build_dock_icon_btn(cat_idx: int) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(54, 54)
	btn.pivot_offset = Vector2(27, 27)
	btn.icon = SVGIcons.make_tex(SVGIcons.get_category_svg(cat_idx), 0.72)
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_attach_bouncy_press(btn)
	btn.pressed.connect(func(): _select_category(cat_idx, true))
	btn.mouse_entered.connect(func(): _preview_category_art(cat_idx))
	return btn

func _preview_category_art(cat_idx: int) -> void:
	var tex: Texture2D = cat_textures.get(cat_idx)
	if tex and hero_couple_art and home_view.visible:
		hero_couple_art.texture = tex

func _select_category(cat_idx: int, manual: bool = false) -> void:
	active_cat = cat_idx
	if manual:
		sfx.play_flip()
	_preview_category_art(cat_idx)
	_update_dock_styles()
	_refresh_dock_label()
	if play_view.visible and manual:
		_deal_next_card()

func _update_dock_styles() -> void:
	for k in cat_dock_btns.keys():
		var btn: Button = cat_dock_btns[k]
		var is_sel: bool = (k == active_cat)
		var st := StyleBoxFlat.new()
		if is_sel:
			st.bg_color = Color(0.88, 0.14, 0.36, 0.95)
			st.border_color = Color(1.0, 0.84, 0.76, 0.95)
			st.set_border_width_all(2)
			st.shadow_color = Color(0.95, 0.16, 0.38, 0.48)
			st.shadow_size = 14
		else:
			st.bg_color = Color(0.18, 0.03, 0.07, 0.65)
			st.border_color = Color(1.0, 0.55, 0.68, 0.20)
			st.set_border_width_all(1)
		st.set_corner_radius_all(27)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", st)
		btn.add_theme_stylebox_override("pressed", st)

func _refresh_dock_label() -> void:
	var cdata: Dictionary = DeckData.CATEGORIES[active_cat]
	active_cat_name_lbl.text = cdata["badge_es"] if lang == "es" else cdata["badge_en"]

# ============================================================================
# 6. CENTERED MOBILE MODALS (Real Illustrated Dice, Roulette, Climax)
# ============================================================================
func _build_modals() -> void:
	prop_modal = ColorRect.new()
	prop_modal.color = Color(0.03, 0.005, 0.015, 0.88)
	prop_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	prop_modal.visible = false
	add_child(prop_modal)

	var p_card := PanelContainer.new()
	p_card.custom_minimum_size = Vector2(378, 500)
	p_card.set_anchors_preset(Control.PRESET_CENTER)
	p_card.offset_left = -189
	p_card.offset_top = -250
	p_card.offset_right = 189
	p_card.offset_bottom = 250
	p_card.add_theme_stylebox_override("panel", _make_modal_style())
	prop_modal.add_child(p_card)

	var p_col := VBoxContainer.new()
	p_col.alignment = BoxContainer.ALIGNMENT_CENTER
	p_col.add_theme_constant_override("separation", 14)
	p_card.add_child(p_col)

	var tab_row := HBoxContainer.new()
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tab_row.add_theme_constant_override("separation", 10)
	p_col.add_child(tab_row)

	tab_dice_btn = _make_pill_btn("Dados", Color(0.88, 0.14, 0.36))
	tab_dice_btn.custom_minimum_size = Vector2(134, 40)
	tab_dice_btn.pressed.connect(func(): _open_prop_modal("dice", false))
	tab_row.add_child(tab_dice_btn)

	tab_wheel_btn = _make_pill_btn("Ruleta", Color(0.28, 0.05, 0.12))
	tab_wheel_btn.custom_minimum_size = Vector2(134, 40)
	tab_wheel_btn.pressed.connect(func(): _open_prop_modal("wheel", forfeit_mode))
	tab_row.add_child(tab_wheel_btn)

	# Real 3D-Beveled Illustrated Luxury Dice Row
	dice_row_box = HBoxContainer.new()
	dice_row_box.alignment = BoxContainer.ALIGNMENT_CENTER
	dice_row_box.add_theme_constant_override("separation", 16)
	dice_row_box.custom_minimum_size = Vector2(0, 196)
	p_col.add_child(dice_row_box)

	d1_cube = _build_real_die_cube(true)
	dice_row_box.add_child(d1_cube)
	d2_cube = _build_real_die_cube(false)
	dice_row_box.add_child(d2_cube)

	# Visual Roulette Wheel Container
	wheel_holder = Control.new()
	wheel_holder.custom_minimum_size = Vector2(210, 210)
	wheel_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	wheel_holder.visible = false
	p_col.add_child(wheel_holder)

	wheel_disc_rect = TextureRect.new()
	wheel_disc_rect.texture = SVGIcons.make_tex(SVGIcons.WHEEL_DISC_SVG, 0.95)
	wheel_disc_rect.custom_minimum_size = Vector2(200, 200)
	wheel_disc_rect.position = Vector2(5, 10)
	wheel_disc_rect.pivot_offset = Vector2(100, 100)
	wheel_holder.add_child(wheel_disc_rect)

	var needle_rect := TextureRect.new()
	needle_rect.texture = SVGIcons.make_tex(SVGIcons.WHEEL_NEEDLE_SVG, 1.0)
	needle_rect.position = Vector2(91, -2)
	wheel_holder.add_child(needle_rect)

	prop_outcome_rtl = RichTextLabel.new()
	prop_outcome_rtl.bbcode_enabled = true
	prop_outcome_rtl.fit_content = true
	prop_outcome_rtl.scroll_active = false
	prop_outcome_rtl.custom_minimum_size = Vector2(310, 54)
	prop_outcome_rtl.add_theme_font_override("normal_font", serif_font)
	prop_outcome_rtl.add_theme_font_size_override("normal_font_size", 22)
	prop_outcome_rtl.add_theme_color_override("default_color", Color.WHITE)
	p_col.add_child(prop_outcome_rtl)

	var p_btns := HBoxContainer.new()
	p_btns.alignment = BoxContainer.ALIGNMENT_CENTER
	p_btns.add_theme_constant_override("separation", 12)
	p_col.add_child(p_btns)

	prop_repeat_btn = _make_jewel_cta_btn("Tirar dados", Vector2(184, 48), SVGIcons.CAT_4_DICE)
	prop_repeat_btn.add_theme_font_size_override("font_size", 17)
	prop_repeat_btn.pressed.connect(_trigger_prop_action)
	p_btns.add_child(prop_repeat_btn)

	prop_close_btn = _make_pill_btn("Listo", Color(0.24, 0.04, 0.10))
	prop_close_btn.custom_minimum_size = Vector2(104, 48)
	prop_close_btn.pressed.connect(func():
		prop_modal.visible = false
		if forfeit_mode:
			forfeit_mode = false
			_animate_swipe_away(false)
	)
	p_btns.add_child(prop_close_btn)

	# --- CLIMAX MODAL ("LOS 3 SOBRES DORADOS") ---
	climax_modal = ColorRect.new()
	climax_modal.color = Color(0.03, 0.005, 0.015, 0.92)
	climax_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	climax_modal.visible = false
	add_child(climax_modal)

	var cl_card := PanelContainer.new()
	cl_card.custom_minimum_size = Vector2(378, 460)
	cl_card.set_anchors_preset(Control.PRESET_CENTER)
	cl_card.offset_left = -189
	cl_card.offset_top = -230
	cl_card.offset_right = 189
	cl_card.offset_bottom = 230
	cl_card.add_theme_stylebox_override("panel", _make_modal_style())
	climax_modal.add_child(cl_card)

	var cl_col := VBoxContainer.new()
	cl_col.alignment = BoxContainer.ALIGNMENT_CENTER
	cl_col.add_theme_constant_override("separation", 16)
	cl_card.add_child(cl_col)

	climax_title_lbl = Label.new()
	climax_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	climax_title_lbl.add_theme_font_override("font", italic_serif)
	climax_title_lbl.add_theme_font_size_override("font_size", 26)
	climax_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.65))
	cl_col.add_child(climax_title_lbl)

	climax_sub_lbl = Label.new()
	climax_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	climax_sub_lbl.add_theme_font_size_override("font_size", 14)
	climax_sub_lbl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.88))
	cl_col.add_child(climax_sub_lbl)

	var env_row := HBoxContainer.new()
	env_row.alignment = BoxContainer.ALIGNMENT_CENTER
	env_row.add_theme_constant_override("separation", 10)
	cl_col.add_child(env_row)

	envelope_btns.clear()
	for i in range(3):
		var eb := Button.new()
		eb.custom_minimum_size = Vector2(102, 96)
		eb.pivot_offset = Vector2(51, 48)
		eb.icon = SVGIcons.make_tex(SVGIcons.GOLDEN_ENVELOPE_SVG, 0.88)
		eb.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		eb.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		eb.text = "I" if i == 0 else ("II" if i == 1 else "III")
		eb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var es := StyleBoxFlat.new()
		es.bg_color = Color(0.20, 0.03, 0.08, 0.92)
		es.border_color = Color(1.0, 0.82, 0.45, 0.78)
		es.set_border_width_all(2)
		es.set_corner_radius_all(16)
		eb.add_theme_stylebox_override("normal", es)
		eb.add_theme_stylebox_override("hover", es)
		_attach_bouncy_press(eb)
		eb.pressed.connect(func(): _open_golden_envelope(i))
		env_row.add_child(eb)
		envelope_btns.append(eb)

	climax_result_rtl = RichTextLabel.new()
	climax_result_rtl.bbcode_enabled = true
	climax_result_rtl.fit_content = true
	climax_result_rtl.scroll_active = false
	climax_result_rtl.custom_minimum_size = Vector2(320, 84)
	climax_result_rtl.add_theme_font_override("normal_font", serif_font)
	climax_result_rtl.add_theme_font_size_override("normal_font_size", 20)
	climax_result_rtl.add_theme_color_override("default_color", Color(1.0, 0.94, 0.85))
	cl_col.add_child(climax_result_rtl)

	var cl_close := _make_pill_btn("Continuar", Color(0.88, 0.14, 0.36))
	cl_close.custom_minimum_size = Vector2(170, 44)
	cl_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cl_close.pressed.connect(func(): climax_modal.visible = false)
	cl_col.add_child(cl_close)

	# --- COUPLE NAMES MODAL ---
	couple_modal = ColorRect.new()
	couple_modal.color = Color(0.03, 0.005, 0.015, 0.88)
	couple_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	couple_modal.visible = false
	add_child(couple_modal)

	var c_card := PanelContainer.new()
	c_card.custom_minimum_size = Vector2(368, 456)
	c_card.set_anchors_preset(Control.PRESET_CENTER)
	c_card.offset_left = -184
	c_card.offset_top = -228
	c_card.offset_right = 184
	c_card.offset_bottom = 228
	c_card.add_theme_stylebox_override("panel", _make_modal_style())
	couple_modal.add_child(c_card)

	var c_col := VBoxContainer.new()
	c_col.alignment = BoxContainer.ALIGNMENT_CENTER
	c_col.add_theme_constant_override("separation", 10)
	c_card.add_child(c_col)

	couple_title_lbl = Label.new()
	couple_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	couple_title_lbl.add_theme_font_override("font", italic_serif)
	couple_title_lbl.add_theme_font_size_override("font_size", 24)
	c_col.add_child(couple_title_lbl)

	p1_input = _make_styled_input("Jugador 1 (ej. Sofía)")
	c_col.add_child(p1_input)

	p1_wish_input = _make_styled_input("★ Deseo secreto de Jugador 1 (opcional)")
	p1_wish_input.focus_entered.connect(func(): p1_wish_input.secret = false)
	p1_wish_input.focus_exited.connect(func(): p1_wish_input.secret = (p1_wish_input.text.strip_edges() != ""))
	c_col.add_child(p1_wish_input)

	p2_input = _make_styled_input("Jugador 2 (ej. Mateo)")
	c_col.add_child(p2_input)

	p2_wish_input = _make_styled_input("★ Deseo secreto de Jugador 2 (opcional)")
	p2_wish_input.focus_entered.connect(func(): p2_wish_input.secret = false)
	p2_wish_input.focus_exited.connect(func(): p2_wish_input.secret = (p2_wish_input.text.strip_edges() != ""))
	c_col.add_child(p2_wish_input)

	save_couple_btn = _make_jewel_cta_btn("Guardar", Vector2(200, 48), SVGIcons.ICON_CHECK)
	save_couple_btn.add_theme_font_size_override("font_size", 18)
	save_couple_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	save_couple_btn.pressed.connect(func():
		player_names[1] = p1_input.text.strip_edges()
		player_names[2] = p2_input.text.strip_edges()
		var w1 := p1_wish_input.text.strip_edges()
		var w2 := p2_wish_input.text.strip_edges()
		if w1 != custom_wishes.get(1, ""):
			custom_wish_used[1] = false
		if w2 != custom_wishes.get(2, ""):
			custom_wish_used[2] = false
		custom_wishes[1] = w1
		custom_wishes[2] = w2
		p1_wish_input.secret = (w1 != "")
		p2_wish_input.secret = (w2 != "")
		_save_prefs()
		couple_modal.visible = false
		_update_hud()
		if not current_card.is_empty():
			_render_active_card_text()
	)
	c_col.add_child(save_couple_btn)

	reset_game_btn = _make_pill_btn("Volver al inicio", Color(0.24, 0.04, 0.10))
	reset_game_btn.custom_minimum_size = Vector2(200, 40)
	reset_game_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	reset_game_btn.pressed.connect(_reset_to_home)
	c_col.add_child(reset_game_btn)

func _reset_to_home() -> void:
	timer_running = false
	couple_modal.visible = false
	heat_points = 1
	passes_left = {1: 3, 2: 3}
	custom_wish_used = {1: false, 2: false}
	current_turn = 1
	active_cat = 1
	climax_shown = false
	play_view.visible = false
	home_view.visible = true
	top_center_hud.visible = false
	top_center_brand.visible = true
	_update_dock_styles()
	_refresh_dock_label()
	_preview_category_art(1)

func _build_real_die_cube(is_action_die: bool) -> Control:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(154, 154)
	holder.pivot_offset = Vector2(77, 77)

	var bg_tex := TextureRect.new()
	bg_tex.texture = SVGIcons.make_tex(SVGIcons.DIE_CRIMSON_BG if is_action_die else SVGIcons.DIE_OBSIDIAN_BG, 1.0)
	bg_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.add_child(bg_tex)

	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 6)
	holder.add_child(col)

	var ico := TextureRect.new()
	ico.custom_minimum_size = Vector2(52, 48)
	ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ico.texture = SVGIcons.make_tex(SVGIcons.get_dice_action_svg(0) if is_action_die else SVGIcons.get_dice_zone_svg(0), 1.0)
	col.add_child(ico)

	var lbl := Label.new()
	lbl.text = "?"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_override("font", serif_font)
	lbl.add_theme_font_size_override("font_size", 17)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.78) if not is_action_die else Color(1.0, 0.96, 0.98))
	col.add_child(lbl)

	if is_action_die:
		die_1_icon = ico
		die_1_val = lbl
	else:
		die_2_icon = ico
		die_2_val = lbl
	return holder

# ============================================================================
# 7. GAMEPLAY LOGIC, STRICT TIMER LOCK & AUTO-ESCALATION
# ============================================================================
func _start_game() -> void:
	sfx.play_flip()
	home_view.visible = false
	play_view.visible = true
	top_center_brand.visible = false
	top_center_hud.visible = true
	_update_hud()
	_deal_next_card()

func _get_player_name(idx: int) -> String:
	var custom: String = player_names.get(idx, "")
	if custom != "":
		return custom
	return ("Jugador " + str(idx)) if lang == "es" else ("Player " + str(idx))

func _get_target_name() -> String:
	var other_idx := 2 if current_turn == 1 else 1
	var custom: String = player_names.get(other_idx, "")
	if custom != "":
		return custom
	return "tu pareja" if lang == "es" else "your partner"

func _format_prompt(raw: String) -> String:
	return "[center]" + raw.replace("{target}", _get_target_name()) + "[/center]"

func _can_complete_current_card() -> bool:
	var ctype: String = current_card.get("type", "Action")
	if ctype == "Secret" and secret_stage < 2:
		return false
	if timer_remaining > 0:
		return false
	return true

func _deal_next_card() -> void:
	timer_running = false
	half_beat_fired = false

	var partner_idx := 2 if current_turn == 1 else 1
	var p_wish: String = custom_wishes.get(partner_idx, "").strip_edges()
	if p_wish != "" and not custom_wish_used.get(partner_idx, false) and heat_points >= 3 and (randf() < 0.38 or heat_points >= 8):
		custom_wish_used[partner_idx] = true
		var author_name := _get_player_name(partner_idx).to_upper()
		current_card = {
			"cat": active_cat,
			"type": "CustomWish",
			"timer": 30,
			"custom_badge": ("★ DESEO SECRETO DE " + author_name) if lang == "es" else ("★ SECRET WISH FROM " + author_name),
			"es": "[color=#ff5e84]Deseo secreto[/color] de [color=#ffd8a8]{target}[/color]:\n“" + p_wish + "”",
			"en": "[color=#ff5e84]Secret wish[/color] from [color=#ffd8a8]{target}[/color]:\n“" + p_wish + "”"
		}
		timer_remaining = 30
		secret_stage = 0
		secret_p1_choice = -1
		_play_card_flip_reveal()
		return

	if not draw_bags.has(active_cat) or draw_bags[active_cat].is_empty():
		var pool := []
		for c in DeckData.CARDS:
			if c["cat"] == active_cat:
				pool.append(c)
		pool.shuffle()
		draw_bags[active_cat] = pool

	var bag: Array = draw_bags[active_cat]
	current_card = bag.pop_back()
	timer_remaining = current_card.get("timer", 0)
	secret_stage = 0
	secret_p1_choice = -1

	_play_card_flip_reveal()

func _play_card_flip_reveal() -> void:
	card_animating = true
	active_game_card.position = card_base_pos
	active_game_card.rotation_degrees = 0.0
	active_game_card.scale = Vector2(0.92, 0.92)
	active_game_card.modulate.a = 1.0
	stamp_done.modulate.a = 0.0
	stamp_pass.modulate.a = 0.0

	card_front_root.visible = false
	card_back_cover.visible = true

	var tw := create_tween()
	tw.tween_property(active_game_card, "scale", Vector2(0.02, 1.0), 0.13).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func():
		_populate_card_front()
		card_back_cover.visible = false
		card_front_root.visible = true
	)
	tw.tween_property(active_game_card, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func(): card_animating = false)

func _populate_card_front() -> void:
	var cdata: Dictionary = DeckData.CATEGORIES[active_cat]
	if current_card.has("custom_badge"):
		game_cat_lbl.text = str(current_card["custom_badge"])
	else:
		game_cat_lbl.text = cdata["badge_es"] if lang == "es" else cdata["badge_en"]

	var cat_tex: Texture2D = cat_textures.get(active_cat)
	if cat_tex:
		active_art_rect.texture = cat_tex

	_render_active_card_text()

	var ctype: String = current_card.get("type", "Action")
	if ctype == "Secret":
		secret_box.visible = true
		secret_hint_lbl.visible = true
		secret_opt_a_btn.disabled = false
		secret_opt_b_btn.disabled = false
		secret_opt_a_btn.text = current_card.get("opt_a_es" if lang == "es" else "opt_a_en", "A")
		secret_opt_b_btn.text = current_card.get("opt_b_es" if lang == "es" else "opt_b_en", "B")
		var p1n := _get_player_name(current_turn)
		secret_hint_lbl.text = (p1n + " elige en secreto:") if lang == "es" else (p1n + " picks secretly:")
	else:
		secret_box.visible = false
		secret_hint_lbl.visible = false

	_sync_primary_action_btn()

func _sync_primary_action_btn() -> void:
	if not btn_done_card:
		return
	var es := (lang == "es")
	var ctype: String = current_card.get("type", "Action")
	if ctype == "Secret" and secret_stage < 2:
		btn_done_card.icon = null
		btn_done_card.text = "Elijan arriba..." if es else "Pick above..."
		btn_done_card.modulate = Color(1.0, 1.0, 1.0, 0.52)
	elif timer_remaining > 0 and not timer_running:
		btn_done_card.icon = SVGIcons.make_tex(SVGIcons.PLAY_TRIANGLE, 0.90)
		btn_done_card.text = ("Iniciar " + str(timer_remaining) + "s") if es else ("Start " + str(timer_remaining) + "s")
		btn_done_card.modulate = Color.WHITE
	elif timer_running and timer_remaining > 0:
		btn_done_card.icon = null
		btn_done_card.text = (str(timer_remaining) + "s · En curso...") if es else (str(timer_remaining) + "s · Hold on...")
		btn_done_card.modulate = Color(1.0, 0.86, 0.90, 0.92)
	else:
		btn_done_card.icon = SVGIcons.make_tex(SVGIcons.ICON_CHECK, 0.95)
		btn_done_card.text = "¡Cumplido!" if es else "Done!"
		btn_done_card.modulate = Color.WHITE

func _on_primary_action_pressed() -> void:
	if card_animating:
		return
	var ctype: String = current_card.get("type", "Action")
	if ctype == "Secret" and secret_stage < 2:
		# Shake the secret options so players know they must vote first
		var tw := create_tween()
		tw.tween_property(secret_box, "scale", Vector2(1.05, 1.05), 0.08)
		tw.tween_property(secret_box, "scale", Vector2.ONE, 0.08)
		return
	if timer_remaining > 0:
		if not timer_running:
			timer_running = true
			timer_accum = 0.0
			half_beat_fired = false
			_sync_primary_action_btn()
			_pulse_timer_visually()
			sfx.play_heartbeat()
		# While timer_running is true and timer_remaining > 0, tapping does NOT skip!
		return
	_animate_swipe_away(true)

func _render_active_card_text() -> void:
	var raw_txt: String = current_card.get("es" if lang == "es" else "en", "")
	game_prompt_rtl.text = _format_prompt(raw_txt)

func _on_secret_option_picked(choice_idx: int) -> void:
	sfx.play_flip()
	if secret_stage == 0:
		secret_p1_choice = choice_idx
		secret_stage = 1
		var other_turn := 2 if current_turn == 1 else 1
		var p2n := _get_player_name(other_turn)
		secret_hint_lbl.text = ("Turno de " + p2n + ":") if lang == "es" else (p2n + "'s turn:")
	elif secret_stage == 1:
		secret_stage = 2
		# Hide the option buttons so the result looks clean and centered
		secret_box.visible = false
		if choice_idx == secret_p1_choice:
			sfx.play_complete()
			heat_points = mini(MAX_HEAT, heat_points + 1)
			secret_hint_lbl.text = "¡COINCIDIERON! +2" if lang == "es" else "IT'S A MATCH! +2"
			game_prompt_rtl.text = "[center]¡[color=#ff5e84]Eligieron lo mismo[/color]! Bésense [color=#ffd8a8]15 segundos[/color].[/center]" if lang == "es" else "[center][color=#ff5e84]Same choice[/color]! Kiss for [color=#ffd8a8]15 seconds[/color].[/center]"
			timer_remaining = 15
			_update_hud()
		else:
			sfx.play_pass()
			secret_hint_lbl.text = "NO COINCIDIERON" if lang == "es" else "NO MATCH"
			var ff: String = current_card.get("forfeit_es" if lang == "es" else "forfeit_en", "")
			game_prompt_rtl.text = _format_prompt(ff)
			timer_remaining = 10
		_sync_primary_action_btn()

func _handle_pass_pressed() -> void:
	if card_animating:
		return
	var p_left: int = passes_left[current_turn]
	if p_left > 0:
		_animate_swipe_away(false)
	else:
		_open_prop_modal("wheel", true)

func _on_active_card_gui_input(event: InputEvent) -> void:
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
				if drag_dx > 85.0 and _can_complete_current_card():
					_animate_swipe_away(true)
				elif drag_dx < -85.0:
					_handle_pass_pressed()
				else:
					if drag_dx > 50.0 and timer_remaining > 0 and not timer_running:
						_on_primary_action_pressed()
					_snap_card_back()
	elif event is InputEventMouseMotion and dragging_card:
		var raw_dx: float = event.global_position.x - drag_start_x
		# Block right-swipe if timer or secret choice isn't finished yet!
		if raw_dx > 0.0 and not _can_complete_current_card():
			drag_dx = raw_dx * 0.20
			stamp_done.modulate.a = 0.0
		else:
			drag_dx = raw_dx
			stamp_done.modulate.a = clampf(drag_dx / 95.0, 0.0, 1.0)
		active_game_card.position.x = card_base_pos.x + drag_dx
		active_game_card.rotation_degrees = clampf(drag_dx * 0.06, -14.0, 14.0)
		stamp_pass.modulate.a = clampf(-drag_dx / 95.0, 0.0, 1.0)

func _snap_card_back() -> void:
	var tw := create_tween().set_parallel(true)
	tw.tween_property(active_game_card, "position:x", card_base_pos.x, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(active_game_card, "rotation_degrees", 0.0, 0.18)
	tw.tween_property(stamp_done, "modulate:a", 0.0, 0.14)
	tw.tween_property(stamp_pass, "modulate:a", 0.0, 0.14)

func _animate_swipe_away(completed: bool) -> void:
	if card_animating:
		return
	card_animating = true
	timer_running = false

	if completed:
		sfx.play_complete()
		heat_points = mini(MAX_HEAT, heat_points + 1)
		stamp_done.modulate.a = 1.0
	else:
		sfx.play_pass()
		if passes_left[current_turn] > 0:
			passes_left[current_turn] -= 1
		else:
			heat_points = maxi(0, heat_points - 1)
		stamp_pass.modulate.a = 1.0

	var target_x := card_base_pos.x + (380.0 if completed else -380.0)
	var target_rot := 16.0 if completed else -16.0

	var tw := create_tween().set_parallel(true)
	tw.tween_property(active_game_card, "position:x", target_x, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(active_game_card, "rotation_degrees", target_rot, 0.22)
	tw.tween_property(active_game_card, "modulate:a", 0.0, 0.22)
	tw.chain().tween_callback(func():
		current_turn = 2 if current_turn == 1 else 1
		_check_auto_escalation()
		_update_hud()
		if heat_points >= MAX_HEAT and not climax_shown:
			climax_shown = true
			card_animating = false
			_show_climax_modal()
		else:
			_deal_next_card()
	)

func _check_auto_escalation() -> void:
	if not auto_escalate:
		return
	var target_cat := 1
	if heat_points >= 10:
		target_cat = 5
	elif heat_points >= 8:
		target_cat = 4
	elif heat_points >= 5:
		target_cat = 3
	elif heat_points >= 3:
		target_cat = 2
	if target_cat > active_cat:
		active_cat = target_cat
		sfx.play_level_up()
		_update_dock_styles()
		_refresh_dock_label()
		# Visual Level-Up bounce on the newly unlocked category dock icon
		if cat_dock_btns.has(active_cat):
			var d_btn: Button = cat_dock_btns[active_cat]
			var tw := create_tween()
			tw.tween_property(d_btn, "scale", Vector2(1.32, 1.32), 0.16).set_trans(Tween.TRANS_BACK)
			tw.tween_property(d_btn, "scale", Vector2.ONE, 0.20)

func _update_hud() -> void:
	var p_name := _get_player_name(current_turn)
	turn_chip_lbl.text = ("Turno de " + p_name) if lang == "es" else (p_name + "'s Turn")
	heat_bar.value = heat_points
	heat_val_lbl.text = str(heat_points) + "/" + str(MAX_HEAT)

	var p_left: int = passes_left[current_turn]
	pass_badge_lbl.text = str(p_left) if p_left > 0 else "!"

# ============================================================================
# 8. PROCESS LOOP (Visual Heartbeat Pulse on Main Button, Candlelight, Parallax)
# ============================================================================
func _pulse_timer_visually() -> void:
	var peak := 1.10 if timer_remaining <= 5 else 1.06
	var tw := create_tween()
	tw.tween_property(btn_done_card, "scale", Vector2(peak, peak), 0.10).set_trans(Tween.TRANS_BACK)
	tw.tween_property(btn_done_card, "scale", Vector2.ONE, 0.15)

func _process(delta: float) -> void:
	candle_time += delta
	if candle_glow_l and candle_glow_r:
		candle_glow_l.color.a = 0.06 + 0.03 * sin(candle_time * 4.2)
		candle_glow_r.color.a = 0.06 + 0.03 * cos(candle_time * 3.7)

	if timer_running and timer_remaining > 0:
		timer_accum += delta
		# Double-speed heartbeat in the final 5 seconds!
		if timer_remaining <= 5 and timer_accum >= 0.5 and not half_beat_fired:
			half_beat_fired = true
			_pulse_timer_visually()
			sfx.play_heartbeat()
		if timer_accum >= 1.0:
			timer_accum -= 1.0
			half_beat_fired = false
			timer_remaining -= 1
			if timer_remaining > 0:
				_sync_primary_action_btn()
				_pulse_timer_visually()
				sfx.play_heartbeat()
			else:
				timer_running = false
				sfx.play_timer_finish()
				_sync_primary_action_btn()
				_pulse_timer_visually()

	if wheel_spinning and wheel_disc_rect:
		var peg_idx := int(floor(wheel_disc_rect.rotation_degrees / 45.0))
		if peg_idx != last_wheel_peg:
			last_wheel_peg = peg_idx
			sfx.play_wheel_tick()

	var vp_size := get_viewport_rect().size
	if vp_size.x > 0 and vp_size.y > 0:
		var accel := Input.get_accelerometer()
		var nx: float = 0.0
		var ny: float = 0.0
		if accel.length_squared() > 0.1:
			# Mobile accelerometer tilt parallax
			nx = clampf(accel.x / 5.5, -1.0, 1.0)
			ny = clampf((accel.y + 5.0) / 5.5, -1.0, 1.0)
		else:
			var m_pos := get_viewport().get_mouse_position()
			nx = clampf((m_pos.x / vp_size.x - 0.5) * 2.0, -1.0, 1.0)
			ny = clampf((m_pos.y / vp_size.y - 0.5) * 2.0, -1.0, 1.0)

		if home_view and home_view.visible and center_fanned_card:
			center_fanned_card.position = center_fanned_card.position.lerp(Vector2(57 + nx * 8.0, 26 + ny * 5.0), delta * 6.0)
			left_fanned_card.rotation_degrees = lerpf(left_fanned_card.rotation_degrees, -13.0 - nx * 2.5, delta * 6.0)
			right_fanned_card.rotation_degrees = lerpf(right_fanned_card.rotation_degrees, 13.0 + nx * 2.5, delta * 6.0)
		elif play_view and play_view.visible and active_game_card and not dragging_card and not card_animating:
			active_game_card.position = active_game_card.position.lerp(card_base_pos + Vector2(nx * 5.0, ny * 4.0), delta * 6.0)

# ============================================================================
# 9. REAL TUMBLING DICE, RULETA & LOS 3 SOBRES DORADOS
# ============================================================================
func _open_prop_modal(mode: String, is_forfeit: bool = false) -> void:
	prop_mode = mode
	forfeit_mode = is_forfeit
	prop_modal.visible = true

	var active_col := Color(0.88, 0.14, 0.36)
	var idle_col := Color(0.24, 0.04, 0.10)
	_style_pill_btn(tab_dice_btn, active_col if mode == "dice" else idle_col)
	_style_pill_btn(tab_wheel_btn, active_col if mode == "wheel" else idle_col)

	dice_row_box.visible = (mode == "dice")
	wheel_holder.visible = (mode == "wheel")
	_trigger_prop_action()

func _trigger_prop_action() -> void:
	if prop_mode == "dice":
		if dice_rolling:
			return
		dice_rolling = true
		sfx.play_dice()
		prop_repeat_btn.text = "Tirar dados" if lang == "es" else "Roll dice"

		var acts := DeckData.DICE_ACTIONS_ES if lang == "es" else DeckData.DICE_ACTIONS_EN
		var bods := DeckData.DICE_BODY_ES if lang == "es" else DeckData.DICE_BODY_EN
		var win_a_idx := randi() % acts.size()
		var win_b_idx := randi() % bods.size()

		var tw := create_tween()
		for step in range(5):
			tw.tween_callback(func():
				var ra := randi() % acts.size()
				var rb := randi() % bods.size()
				die_1_icon.texture = SVGIcons.make_tex(SVGIcons.get_dice_action_svg(ra), 1.0)
				die_2_icon.texture = SVGIcons.make_tex(SVGIcons.get_dice_zone_svg(rb), 1.0)
				die_1_val.text = acts[ra]
				die_2_val.text = bods[rb]
				d1_cube.rotation_degrees = randf_range(-18.0, 18.0)
				d2_cube.rotation_degrees = randf_range(-18.0, 18.0)
				d1_cube.scale = Vector2(0.90, 0.90)
				d2_cube.scale = Vector2(0.90, 0.90)
			)
			tw.tween_interval(0.065)

		tw.tween_callback(func():
			var final_a: String = acts[win_a_idx]
			var final_b: String = bods[win_b_idx]
			die_1_icon.texture = SVGIcons.make_tex(SVGIcons.get_dice_action_svg(win_a_idx), 1.0)
			die_2_icon.texture = SVGIcons.make_tex(SVGIcons.get_dice_zone_svg(win_b_idx), 1.0)
			die_1_val.text = final_a
			die_2_val.text = final_b
			prop_outcome_rtl.text = "[center][color=#ff5e84]" + final_a + "[/color] · [color=#ffd8a8]" + final_b + "[/color][/center]"
			sfx.play_complete()
			dice_rolling = false
		)
		tw.tween_property(d1_cube, "rotation_degrees", 0.0, 0.22).set_trans(Tween.TRANS_BACK)
		tw.parallel().tween_property(d2_cube, "rotation_degrees", 0.0, 0.22).set_trans(Tween.TRANS_BACK)
		tw.parallel().tween_property(d1_cube, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK)
		tw.parallel().tween_property(d2_cube, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK)
	else:
		if wheel_spinning:
			return
		wheel_spinning = true
		var wheel_list := DeckData.WHEEL_FANTASIES_ES if lang == "es" else DeckData.WHEEL_FANTASIES_EN
		var win_idx := randi() % wheel_list.size()
		var win_text: String = wheel_list[win_idx]

		prop_outcome_rtl.text = "[center][color=#ffd8a8]" + (("¡Sin pases! Girando penitencia..." if forfeit_mode else "Girando...") if lang == "es" else "Spinning...") + "[/color][/center]"
		prop_repeat_btn.text = "Girar ruleta" if lang == "es" else "Spin wheel"

		var extra_turns := randf_range(1080.0, 1800.0)
		wheel_angle += extra_turns
		var tw := create_tween()
		tw.tween_property(wheel_disc_rect, "rotation_degrees", wheel_angle, 2.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_callback(func():
			wheel_spinning = false
			sfx.play_complete()
			prop_outcome_rtl.text = "[center]" + win_text + "[/center]"
		)

func _show_climax_modal() -> void:
	sfx.play_climax()
	climax_modal.visible = true
	climax_title_lbl.text = "Los 3 Sobres Dorados" if lang == "es" else "The 3 Golden Envelopes"
	climax_sub_lbl.text = "Elijan un sobre para sellar la noche" if lang == "es" else "Pick an envelope to seal the night"
	climax_result_rtl.text = ""
	for b in envelope_btns:
		b.disabled = false
		b.modulate = Color.WHITE

func _open_golden_envelope(idx: int) -> void:
	sfx.play_flip()
	var env: Dictionary = DeckData.CLIMAX_ENVELOPES[idx]
	var raw_res: String = env["es"] if lang == "es" else env["en"]
	climax_result_rtl.text = _format_prompt(raw_res)
	for i in range(envelope_btns.size()):
		envelope_btns[i].modulate = Color(1, 1, 1, 1.0 if i == idx else 0.38)

# ============================================================================
# 10. LOCALIZATION & UI HELPERS
# ============================================================================
func _toggle_lang() -> void:
	lang = "en" if lang == "es" else "es"
	_save_prefs()
	_refresh_all_texts()

func _refresh_all_texts() -> void:
	var es := (lang == "es")
	top_lang_btn.text = "ES" if es else "EN"
	main_play_btn.text = "Jugar" if es else "Play"
	btn_done_card.text = "¡Cumplido!" if es else "Done!"
	tab_wheel_btn.text = "Ruleta" if es else "Wheel"
	tab_dice_btn.text = "Dados" if es else "Dice"
	prop_close_btn.text = "Listo" if es else "Close"
	couple_title_lbl.text = "Pareja" if es else "Couple"
	if p1_input:
		p1_input.placeholder_text = "Jugador 1 (ej. Sofía)" if es else "Player 1 (e.g. Sofia)"
	if p1_wish_input:
		p1_wish_input.placeholder_text = "★ Deseo secreto de Jugador 1 (opcional)" if es else "★ Player 1 secret wish (optional)"
	if p2_input:
		p2_input.placeholder_text = "Jugador 2 (ej. Mateo)" if es else "Player 2 (e.g. Mateo)"
	if p2_wish_input:
		p2_wish_input.placeholder_text = "★ Deseo secreto de Jugador 2 (opcional)" if es else "★ Player 2 secret wish (optional)"
	save_couple_btn.text = "Guardar" if es else "Save"
	reset_game_btn.text = "Volver al inicio" if es else "Back to Home"
	_refresh_dock_label()
	_update_hud()
	if not current_card.is_empty():
		_populate_card_front()

func _make_icon_btn(svg_str: String) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(40, 40)
	btn.pivot_offset = Vector2(20, 20)
	btn.icon = SVGIcons.make_tex(svg_str, 0.90)
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.14, 0.02, 0.06, 0.78)
	st.border_color = Color(1.0, 0.65, 0.75, 0.28)
	st.set_border_width_all(1)
	st.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", st)
	btn.add_theme_stylebox_override("pressed", st)
	_attach_bouncy_press(btn)
	return btn

func _make_text_chip_btn(txt: String) -> Button:
	var btn := Button.new()
	btn.text = txt
	btn.custom_minimum_size = Vector2(40, 40)
	btn.pivot_offset = Vector2(20, 20)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 12)
	btn.add_theme_color_override("font_color", Color(1.0, 0.90, 0.94))
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.14, 0.02, 0.06, 0.78)
	st.border_color = Color(1.0, 0.65, 0.75, 0.28)
	st.set_border_width_all(1)
	st.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("hover", st)
	btn.add_theme_stylebox_override("pressed", st)
	_attach_bouncy_press(btn)
	return btn

func _make_pill_btn(txt: String, bg_col: Color) -> Button:
	var btn := Button.new()
	btn.text = txt
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)
	_style_pill_btn(btn, bg_col)
	_attach_bouncy_press(btn)
	return btn

func _style_pill_btn(btn: Button, bg_col: Color) -> void:
	var st := StyleBoxFlat.new()
	st.bg_color = bg_col
	st.border_color = Color(1.0, 0.78, 0.84, 0.45)
	st.set_border_width_all(1)
	st.set_corner_radius_all(99)
	st.content_margin_left = 14
	st.content_margin_right = 14
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	btn.add_theme_stylebox_override("normal", st)
	var hv := st.duplicate()
	hv.bg_color = bg_col.lightened(0.12)
	btn.add_theme_stylebox_override("hover", hv)
	btn.add_theme_stylebox_override("pressed", hv)

func _make_modal_style() -> StyleBoxFlat:
	var ms := StyleBoxFlat.new()
	ms.bg_color = Color(0.11, 0.015, 0.045, 0.98)
	ms.border_color = Color(1.0, 0.76, 0.70, 0.72)
	ms.set_border_width_all(2)
	ms.set_corner_radius_all(26)
	ms.content_margin_left = 22
	ms.content_margin_right = 22
	ms.content_margin_top = 22
	ms.content_margin_bottom = 22
	return ms

func _make_styled_input(placeholder: String) -> LineEdit:
	var le := LineEdit.new()
	le.placeholder_text = placeholder
	le.custom_minimum_size = Vector2(280, 44)
	le.alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ls := StyleBoxFlat.new()
	ls.bg_color = Color(0.06, 0.01, 0.025, 0.92)
	ls.border_color = Color(1.0, 0.55, 0.68, 0.40)
	ls.set_border_width_all(1)
	ls.set_corner_radius_all(12)
	le.add_theme_stylebox_override("normal", ls)
	le.add_theme_stylebox_override("focus", ls)
	return le
