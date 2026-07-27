extends Node2D
class_name CinderwatchGrayboxGeometry
## Cinderwatch Ridge -- Graybox Identity Pass (4A).
## Terrain-first ridge: cliffs, exposed road, collapse ravine, watch knoll.
## Same world footprint as Pass 1 -- quality, not size.


const WALL_T := 22.0
const CLIFF := Color(0.22, 0.20, 0.18, 0.96)
const CLIFF_LIP := Color(0.30, 0.28, 0.24, 0.95)
const WATCH_STONE := Color(0.40, 0.38, 0.34, 1.0)
const SCAVENGER := Color(0.48, 0.38, 0.26, 0.92)
const ROAD := Color(0.28, 0.24, 0.18, 0.72)
const ROAD_EDGE := Color(0.20, 0.18, 0.14, 0.55)
const SCRUB := Color(0.16, 0.18, 0.12, 0.5)
const GROVE := Color(0.11, 0.20, 0.15, 0.7)
const HOLD_DIRT := Color(0.24, 0.18, 0.12, 0.55)
const VOID := Color(0.04, 0.05, 0.06, 1.0)
const HAZE := Color(0.32, 0.38, 0.42, 0.28)
const ASH := Color(0.22, 0.16, 0.12, 0.45)

# Same footprint as Pass 1
const WORLD_X0 := -1200.0
const WORLD_X1 := 1580.0
const WORLD_Y0 := -520.0
const WORLD_Y1 := 170.0

# Ridge road -- irregular centerline (not a straight combat corridor)
# Road band roughly y = ROAD_N .. ROAD_S, widening/narrowing by stretch
const ROAD_N := -55.0
const ROAD_S := 70.0

# Collapse ravine -- see across; cannot cross; routes around north/south
const RAVINE_X0 := -490.0
const RAVINE_X1 := -370.0
const RAVINE_Y0 := -105.0
const RAVINE_Y1 := 72.0

# Sheltered grove depression (north of ridge)
const GROVE_X0 := -60.0
const GROVE_X1 := 310.0
const GROVE_Y0 := -480.0
const GROVE_Y1 := -95.0
const GROVE_SW0 := 30.0
const GROVE_SW1 := 120.0
const GROVE_SE0 := 200.0
const GROVE_SE1 := 290.0

# Watch knoll -- north of road, tall silhouette readable from approach
const WATCH_X := 130.0
const WATCH_Y := -210.0
const WATCH_W := 56.0
const WATCH_H := 150.0

const EMBER_STONE := Vector2(55.0, -300.0)

# Soft zone rects for announce only -- NOT drawn as room boxes
const ZONE_LAYOUT: Array[Dictionary] = [
	{"name": "Western Approach", "rect": Rect2(-1180, -90, 300, 180), "kind": "approach"},
	{"name": "Scrub Flank", "rect": Rect2(-880, -80, 240, 160), "kind": "scrub"},
	{"name": "Broken Signal Span", "rect": Rect2(-620, -100, 280, 200), "kind": "span"},
	{"name": "Occupied Road", "rect": Rect2(-340, -70, 260, 160), "kind": "occupied"},
	{"name": "Hearth Grove", "rect": Rect2(GROVE_X0, GROVE_Y0, GROVE_X1 - GROVE_X0, GROVE_Y1 - GROVE_Y0), "kind": "grove"},
	{"name": "Ashroad Watch", "rect": Rect2(40, -100, 280, 180), "kind": "watch"},
	{"name": "Waystation Hold", "rect": Rect2(300, -80, 320, 170), "kind": "hold"},
	{"name": "Old Watch Gate", "rect": Rect2(580, -70, 180, 150), "kind": "gate"},
	{"name": "Ridge Outlook", "rect": Rect2(920, -110, 600, 220), "kind": "outlook"},
]

var zones: Array[Dictionary] = []
var _walls: Array[Rect2] = []
var _scavenger: Array[Rect2] = []
var _void_rects: Array[Rect2] = []


func _ready() -> void:
	zones = ZONE_LAYOUT.duplicate()
	_walls = _build_walls()
	_scavenger = _build_scavenger()
	_void_rects = _build_voids()
	for rect in _walls:
		_add_body(rect)
	for rect in _scavenger:
		_add_body(rect)
	for rect in _void_rects:
		_add_body(rect)
	queue_redraw()


func _build_walls() -> Array[Rect2]:
	var w: Array[Rect2] = []
	var t := WALL_T

	# Outer bounds (world envelope)
	w.append(Rect2(WORLD_X0, WORLD_Y0, WORLD_X1 - WORLD_X0, t))
	w.append(Rect2(WORLD_X0, WORLD_Y1 - t, WORLD_X1 - WORLD_X0, t))
	w.append(Rect2(WORLD_X0, WORLD_Y0, t, WORLD_Y1 - WORLD_Y0))
	w.append(Rect2(WORLD_X1 - t, WORLD_Y0, t, WORLD_Y1 - WORLD_Y0))

	# South cliff: leave a walkable ledge around the ravine (y ~ 75..112)
	w.append(Rect2(WORLD_X0, 95.0, 280.0, t))
	w.append(Rect2(-920.0, 105.0, 200.0, t))
	w.append(Rect2(-720.0, 88.0, 160.0, t))
	# Cliff mass drops below the ledge -- opening for south detour under the collapse
	w.append(Rect2(-560.0, 112.0, RAVINE_X1 + 40.0 - -560.0, t))
	w.append(Rect2(-340.0, 100.0, 200.0, t))
	w.append(Rect2(-140.0, 92.0, 420.0, t))
	w.append(Rect2(280.0, 100.0, 300.0, t))
	w.append(Rect2(580.0, 88.0, 200.0, t))
	w.append(Rect2(780.0, 78.0, 800.0, t))

	# Fill south cliff mass to world edge (below the walkable ledge)
	w.append(Rect2(WORLD_X0, 118.0, 280.0, WORLD_Y1 - 118.0 - t))
	w.append(Rect2(-920.0, 128.0, 200.0, WORLD_Y1 - 128.0 - t))
	w.append(Rect2(-720.0, 110.0, 160.0, WORLD_Y1 - 110.0 - t))
	w.append(Rect2(-560.0, 134.0, RAVINE_X1 + 40.0 - -560.0, WORLD_Y1 - 134.0 - t))
	w.append(Rect2(-340.0, 122.0, 200.0, WORLD_Y1 - 122.0 - t))
	w.append(Rect2(-140.0, 114.0, 420.0, WORLD_Y1 - 114.0 - t))
	w.append(Rect2(280.0, 122.0, 300.0, WORLD_Y1 - 122.0 - t))
	w.append(Rect2(580.0, 110.0, 200.0, WORLD_Y1 - 110.0 - t))
	w.append(Rect2(780.0, 100.0, 800.0, WORLD_Y1 - 100.0 - t))

	# --- North ridge shelf / highland ---
	w.append(Rect2(WORLD_X0, WORLD_Y0 + t, 320.0, 40.0))

	# Scrub rises -- uneven north berm
	w.append(Rect2(-880.0, -145.0, 180.0, t))
	w.append(Rect2(-700.0, -165.0, 140.0, t))
	w.append(Rect2(-560.0, -180.0, 70.0, t))

	# North cliff lips of ravine (frame the void; do not bridge it)
	w.append(Rect2(RAVINE_X0 - 55.0, -125.0, 55.0, 30.0))
	w.append(Rect2(RAVINE_X1, -125.0, 60.0, 30.0))

	# Grove depression enclosure
	w.append(Rect2(GROVE_X0, GROVE_Y0, GROVE_X1 - GROVE_X0, t))
	w.append(Rect2(GROVE_X0 - t, GROVE_Y0, t, GROVE_Y1 - GROVE_Y0))
	w.append(Rect2(GROVE_X1, GROVE_Y0, t, GROVE_Y1 - GROVE_Y0))
	w.append(Rect2(GROVE_X0, GROVE_Y1 - t, GROVE_SW0 - GROVE_X0, t))
	w.append(Rect2(GROVE_SW1, GROVE_Y1 - t, GROVE_SE0 - GROVE_SW1, t))
	w.append(Rect2(GROVE_SE1, GROVE_Y1 - t, GROVE_X1 - GROVE_SE1, t))

	# Highland north of road -- DO NOT seal a corridor wall.
	# Leave open scrub west of the span; short berms only east of the ravine.
	w.append(Rect2(40.0, ROAD_N - t - 20.0, GROVE_SW0 - 40.0, t))
	w.append(Rect2(GROVE_SW1, ROAD_N - t - 18.0, GROVE_SE0 - GROVE_SW1, t))
	w.append(Rect2(GROVE_SE1, ROAD_N - t - 22.0, 50.0, t))

	# North-of-ravine channel stays open (y ~ -200..-110, x across collapse)
	# so players can see the void and choose the highland way toward the grove.

	# Watch knoll -- set back from road so silhouette reads without pinching travel
	w.append(Rect2(WATCH_X - 35.0, ROAD_N - 55.0, 150.0, 22.0))
	w.append(Rect2(WATCH_X, WATCH_Y, WATCH_W, WATCH_H))
	w.append(Rect2(WATCH_X - 8.0, WATCH_Y - 14.0, WATCH_W + 28.0, 14.0))

	# North highland continues unevenly toward outlook
	w.append(Rect2(320.0, ROAD_N - t - 40.0, 180.0, t))
	w.append(Rect2(540.0, ROAD_N - t - 22.0, 70.0, t))
	w.append(Rect2(700.0, ROAD_N - t - 50.0, 180.0, t))
	w.append(Rect2(980.0, ROAD_N - t - 60.0, 280.0, t))
	w.append(Rect2(1300.0, ROAD_N - t - 28.0, 260.0, t))

	# Old watch gate -- ruined gatehouse (asymmetric), not arena pillars
	w.append(Rect2(610.0, ROAD_N - 10.0, 28.0, 48.0))
	w.append(Rect2(655.0, 15.0, 22.0, 55.0))
	w.append(Rect2(600.0, ROAD_N - 18.0, 80.0, 14.0))

	# Outlook cliffs pull back
	w.append(Rect2(1100.0, -140.0, 200.0, t))
	w.append(Rect2(1400.0, -100.0, 160.0, t))

	return w


func _build_voids() -> Array[Rect2]:
	# Ravine abyss -- blocks walking; drawn as collapse (far road visible beyond)
	return [
		Rect2(RAVINE_X0, RAVINE_Y0, RAVINE_X1 - RAVINE_X0, RAVINE_Y1 - RAVINE_Y0),
	]


func _build_scavenger() -> Array[Rect2]:
	# Crude wood unlike watch stone -- occupation of Hold only
	return [
		Rect2(340.0, -35.0, 14.0, 55.0),
		Rect2(410.0, 20.0, 48.0, 12.0),
		Rect2(500.0, -20.0, 16.0, 42.0),
		Rect2(470.0, 35.0, 30.0, 10.0),
	]


func _add_body(rect: Rect2) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = rect.position + rect.size * 0.5
	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = rect.size
	shape.shape = rect_shape
	body.add_child(shape)
	add_child(body)


func _draw() -> void:
	_draw_terrain_bands()
	_draw_road()
	_draw_ravine()
	_draw_grove_floor()
	_draw_hold_stain()
	_draw_outlook_haze()

	for rect in _walls:
		var col := CLIFF
		# Watch tower stone reads differently from cliff
		if rect.position.x >= WATCH_X - 1.0 and rect.position.x <= WATCH_X + 1.0 and rect.size.y > 80.0:
			col = WATCH_STONE
		elif rect.size.y <= 16.0 and rect.position.y < ROAD_N:
			col = CLIFF_LIP
		draw_rect(rect, col, true)

	for rect in _scavenger:
		draw_rect(rect, SCAVENGER, true)

	_draw_landmarks()
	# No zone name plates, no START/END markers, no route polylines


func _draw_terrain_bands() -> void:
	# Scrub / highland washes (asymmetric -- not room boxes)
	draw_rect(Rect2(WORLD_X0, WORLD_Y0, WORLD_X1 - WORLD_X0, 200.0), SCRUB, true)
	draw_rect(Rect2(WORLD_X0, 90.0, WORLD_X1 - WORLD_X0, WORLD_Y1 - 90.0), Color(0.10, 0.09, 0.08, 0.65), true)


func _draw_road() -> void:
	# Continuous ridge road ribbon with slight bends -- history of travel
	var stretches: Array[Rect2] = [
		Rect2(-1180, -35, 300, 95), # western approach -- wide, open
		Rect2(-880, -45, 250, 100), # scrub flank -- narrower
		Rect2(-630, -50, 140, 105), # approach to span
		# gap at ravine -- no road fill
		Rect2(-360, -40, 280, 100), # far side continues (visible across void)
		Rect2(-80, -50, 220, 110), # toward watch
		Rect2(140, -45, 200, 105),
		Rect2(340, -40, 280, 100), # hold stretch -- worn
		Rect2(620, -35, 160, 90), # gate
		Rect2(780, -50, 200, 105),
		Rect2(980, -60, 520, 120), # outlook opens wide
	]
	for rect in stretches:
		draw_rect(rect, ROAD_EDGE, true)
		var inner := rect.grow_individual(-6, -8, -6, -8)
		if inner.size.x > 0.0 and inner.size.y > 0.0:
			draw_rect(inner, ROAD, true)

	# Ash / wear near span approaches
	draw_rect(Rect2(-620, -20, 120, 50), ASH, true)
	draw_rect(Rect2(-360, -15, 100, 45), ASH, true)


func _draw_ravine() -> void:
	# Abyss -- readable as collapse, not a hallway wall
	for rect in _void_rects:
		draw_rect(rect, VOID, true)

	# Broken deck stubs reaching into the void from both sides
	draw_rect(Rect2(RAVINE_X0 - 8.0, -8.0, 28.0, 16.0), Color(0.34, 0.30, 0.24, 0.95), true)
	draw_rect(Rect2(RAVINE_X0 - 4.0, 12.0, 18.0, 10.0), Color(0.28, 0.25, 0.20, 0.9), true)
	draw_rect(Rect2(RAVINE_X1 - 20.0, -5.0, 32.0, 14.0), Color(0.34, 0.30, 0.24, 0.95), true)
	draw_rect(Rect2(RAVINE_X1 - 12.0, 18.0, 22.0, 11.0), Color(0.28, 0.25, 0.20, 0.9), true)

	# Fallen beam in the void (historical debris)
	draw_rect(Rect2(RAVINE_X0 + 35.0, 5.0, 55.0, 8.0), Color(0.25, 0.22, 0.18, 0.85), true)

	# Far road clearly continues beyond the collapse
	draw_rect(Rect2(RAVINE_X1 + 4.0, -25.0, 90.0, 70.0), ROAD_EDGE, true)
	draw_rect(Rect2(RAVINE_X1 + 10.0, -15.0, 75.0, 50.0), ROAD, true)

	# South cliff ledge path (exposed alternate around the collapse)
	draw_rect(Rect2(RAVINE_X0 - 30.0, 74.0, RAVINE_X1 - RAVINE_X0 + 70.0, 34.0), Color(0.20, 0.17, 0.13, 0.55), true)

	# North highland shelf hint (toward grove country)
	draw_rect(Rect2(RAVINE_X0 - 40.0, -175.0, RAVINE_X1 - RAVINE_X0 + 90.0, 45.0), Color(0.14, 0.16, 0.12, 0.4), true)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(RAVINE_X0 - 30.0, RAVINE_Y0 - 18.0),
		"Broken Signal Span",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		12,
		Color(0.88, 0.80, 0.62, 0.85)
	)


func _draw_grove_floor() -> void:
	draw_rect(Rect2(GROVE_X0, GROVE_Y0, GROVE_X1 - GROVE_X0, GROVE_Y1 - GROVE_Y0), GROVE, true)
	# Cold hearth ring
	draw_circle(Vector2(120.0, -280.0), 22.0, Color(0.18, 0.16, 0.12, 0.7))
	draw_circle(Vector2(120.0, -280.0), 10.0, Color(0.12, 0.11, 0.09, 0.8))


func _draw_hold_stain() -> void:
	draw_rect(Rect2(320, -55, 260, 120), HOLD_DIRT, true)


func _draw_outlook_haze() -> void:
	draw_rect(Rect2(1200, -90, 340, 160), Color(0.18, 0.22, 0.24, 0.35), true)
	draw_rect(Rect2(1480, -50, 36, 90), HAZE, true)
	draw_rect(Rect2(1520, -70, 24, 50), HAZE, true)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(1380, -75),
		"distant marches",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		11,
		Color(0.65, 0.75, 0.8, 0.55)
	)


func _draw_landmarks() -> void:
	# Ashroad Watch -- tall knoll tower, sealed upper ledge
	draw_rect(Rect2(WATCH_X, WATCH_Y, WATCH_W, WATCH_H), WATCH_STONE, true)
	draw_rect(Rect2(WATCH_X + 12.0, WATCH_Y + 30.0, 16.0, 36.0), Color(0.12, 0.11, 0.10, 1.0), true)
	draw_rect(Rect2(WATCH_X - 8.0, WATCH_Y - 14.0, WATCH_W + 28.0, 14.0), Color(0.45, 0.42, 0.36, 1.0), true)
	draw_circle(Vector2(WATCH_X + 14.0, WATCH_Y + 12.0), 5.0, Color(0.25, 0.23, 0.20, 1.0))
	draw_circle(Vector2(WATCH_X + 40.0, WATCH_Y + 18.0), 5.0, Color(0.25, 0.23, 0.20, 1.0))
	draw_string(
		ThemeDB.fallback_font,
		Vector2(WATCH_X - 20.0, WATCH_Y - 28.0),
		"Ashroad Watch",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		12,
		Color(0.95, 0.88, 0.68, 0.92)
	)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(WATCH_X + WATCH_W + 6.0, WATCH_Y - 6.0),
		"sealed ledge",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		10,
		Color(0.78, 0.72, 0.52, 0.7)
	)

	# Ember-scar stone
	draw_circle(EMBER_STONE, 15.0, Color(0.55, 0.28, 0.16, 0.95))
	draw_circle(EMBER_STONE, 7.0, Color(0.78, 0.38, 0.18, 0.9))

	# Hold occupation marks
	draw_rect(Rect2(390, -15, 34, 11), Color(0.42, 0.30, 0.20, 0.85), true)
	draw_rect(Rect2(455, 28, 26, 9), Color(0.38, 0.28, 0.18, 0.8), true)


func get_ember_stone_position() -> Vector2:
	return EMBER_STONE


func get_grove_hesitation_point() -> Vector2:
	# Lip of the collapse -- look across the ravine with the rider
	return Vector2(RAVINE_X0 - 35.0, -20.0)


func get_span_center() -> Vector2:
	return Vector2((RAVINE_X0 + RAVINE_X1) * 0.5, 10.0)


func get_span_look_point() -> Vector2:
	# Dragon faces the ravine / far stub while waiting
	return Vector2(RAVINE_X1 + 40.0, 5.0)
