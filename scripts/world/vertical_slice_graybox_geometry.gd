extends Node2D
class_name VerticalSliceGrayboxGeometry
## Pass 2 — connected graybox route. Visible walls == collision segments.


const WALL_T := 26.0
const WALL_DRAW := Color(0.28, 0.32, 0.26, 0.92)
const PATH_FLOOR := Color(0.15, 0.21, 0.13, 0.55)
const GROVE_FLOOR := Color(0.11, 0.26, 0.16, 0.62)

# Playable spine Y bands
const SPINE_WIDE := 130.0
const SPINE_MED := 105.0
const SPINE_NARROW := 72.0

const WORLD_X0 := -1340.0
const WORLD_X1 := 1880.0
const WORLD_Y0 := -560.0
const WORLD_Y1 := 150.0

# Grove bowl — south edge has exactly two openings (both on south boundary)
const GROVE_X0 := -230.0
const GROVE_X1 := 290.0
const GROVE_Y0 := -540.0
const GROVE_Y1 := -118.0

# Southwest exit → The Crossroads (southwest corner of grove south lip)
const GROVE_EXIT_SW_X0 := -95.0
const GROVE_EXIT_SW_X1 := 45.0

# South-center / southeast exit → The Hold (east side of grove south lip)
const GROVE_EXIT_SE_X0 := 165.0
const GROVE_EXIT_SE_X1 := 265.0

# Crossroads → Hold main-route gate (vertical choke on shared boundary)
const CR_HOLD_GATE_X0 := 48.0
const CR_HOLD_GATE_X1 := 92.0
const CR_HOLD_GATE_Y0 := -40.0
const CR_HOLD_GATE_Y1 := 40.0

const ZONE_LAYOUT: Array[Dictionary] = [
	{"name": "The Clearing", "rect": Rect2(-1320, -SPINE_WIDE, 500, SPINE_WIDE * 2), "kind": "wide"},
	{"name": "The Ambush", "rect": Rect2(-820, -SPINE_NARROW, 220, SPINE_NARROW * 2), "kind": "choke"},
	{"name": "The Crossing", "rect": Rect2(-600, -SPINE_MED, 240, SPINE_MED * 2), "kind": "path"},
	{"name": "The Crossroads", "rect": Rect2(-360, -SPINE_WIDE * 0.95, 340, SPINE_WIDE * 1.9), "kind": "junction"},
	{"name": "The Quiet Grove", "rect": Rect2(GROVE_X0, GROVE_Y0, GROVE_X1 - GROVE_X0, GROVE_Y1 - GROVE_Y0), "kind": "grove"},
	{"name": "The Hold", "rect": Rect2(100, -SPINE_WIDE, 420, SPINE_WIDE * 2), "kind": "wide"},
	{"name": "The Gate", "rect": Rect2(520, -SPINE_NARROW, 260, SPINE_NARROW * 2), "kind": "choke"},
	{"name": "The Fork", "rect": Rect2(780, -SPINE_MED, 300, SPINE_MED * 2), "kind": "path"},
	{"name": "The Last Stand", "rect": Rect2(1080, -SPINE_WIDE * 1.05, 380, SPINE_WIDE * 2.1), "kind": "wide"},
	{"name": "The Outlook", "rect": Rect2(1460, -SPINE_WIDE * 1.1, 420, SPINE_WIDE * 2.2), "kind": "destination"},
]

var zones: Array[Dictionary] = []
var _wall_segments: Array[Rect2] = []


func _ready() -> void:
	zones = ZONE_LAYOUT.duplicate()
	_wall_segments = _build_wall_segments()
	for rect in _wall_segments:
		_add_wall(rect)
	queue_redraw()


func _build_wall_segments() -> Array[Rect2]:
	var walls: Array[Rect2] = []
	var t := WALL_T

	# --- Outer envelope (continuous ring, overlapping corners) ---
	walls.append(Rect2(WORLD_X0, WORLD_Y0, WORLD_X1 - WORLD_X0, t))
	walls.append(Rect2(WORLD_X0, WORLD_Y1 - t, WORLD_X1 - WORLD_X0, t))
	walls.append(Rect2(WORLD_X0, WORLD_Y0, t, WORLD_Y1 - WORLD_Y0))
	walls.append(Rect2(WORLD_X1 - t, WORLD_Y0, t, WORLD_Y1 - WORLD_Y0))

	# --- Grove bowl — sealed on north, west, and FULL east; two south exits only ---
	walls.append(Rect2(GROVE_X0, GROVE_Y0, GROVE_X1 - GROVE_X0, t)) # north
	walls.append(Rect2(GROVE_X0 - t, GROVE_Y0, t, GROVE_Y1 - GROVE_Y0)) # west
	walls.append(Rect2(GROVE_X1, GROVE_Y0, t, GROVE_Y1 - GROVE_Y0)) # east — full height, no opening

	# Grove south lip — wall segments between the two intentional exits
	walls.append(Rect2(GROVE_X0, GROVE_Y1 - t, GROVE_EXIT_SW_X0 - GROVE_X0, t))
	walls.append(Rect2(GROVE_EXIT_SW_X1, GROVE_Y1 - t, GROVE_EXIT_SE_X0 - GROVE_EXIT_SW_X1, t))
	walls.append(Rect2(GROVE_EXIT_SE_X1, GROVE_Y1 - t, GROVE_X1 - GROVE_EXIT_SE_X1, t))

	# --- Main spine north/south shaping (variable-width corridor) ---
	var spine_n := -SPINE_WIDE - t * 0.5
	var spine_s := SPINE_WIDE

	# North spine wall — three gaps only: grove SW entry, grove SE → Hold, no wide east opening
	walls.append(Rect2(WORLD_X0, spine_n, GROVE_EXIT_SW_X0 - WORLD_X0, t))
	walls.append(Rect2(GROVE_EXIT_SW_X1, spine_n, GROVE_EXIT_SE_X0 - GROVE_EXIT_SW_X1, t))
	walls.append(Rect2(GROVE_EXIT_SE_X1, spine_n, WORLD_X1 - GROVE_EXIT_SE_X1, t))

	# Crossroads → Hold gate — vertical pillars; passage only through center opening
	walls.append(Rect2(CR_HOLD_GATE_X0 - t, spine_n, t, CR_HOLD_GATE_Y0 - spine_n))
	walls.append(Rect2(CR_HOLD_GATE_X0 - t, CR_HOLD_GATE_Y1, t, spine_s + t - CR_HOLD_GATE_Y1))
	walls.append(Rect2(CR_HOLD_GATE_X1, spine_n, t, CR_HOLD_GATE_Y0 - spine_n))
	walls.append(Rect2(CR_HOLD_GATE_X1, CR_HOLD_GATE_Y1, t, spine_s + t - CR_HOLD_GATE_Y1))

	# South spine wall — full (guides east continuously)
	walls.append(Rect2(WORLD_X0, spine_s, WORLD_X1 - WORLD_X0, t))

	# Ambush choke — north/south pinch walls
	walls.append(Rect2(-820, -SPINE_WIDE - t, 220, SPINE_WIDE - SPINE_NARROW))
	walls.append(Rect2(-820, SPINE_NARROW, 220, SPINE_WIDE - SPINE_NARROW))

	# Gate choke — narrows before brute encounter
	walls.append(Rect2(520, -SPINE_WIDE - t, 260, SPINE_WIDE - SPINE_NARROW))
	walls.append(Rect2(520, SPINE_NARROW, 260, SPINE_WIDE - SPINE_NARROW))

	# Crossroads junction hint — short spur walls suggesting branch
	walls.append(Rect2(-120, spine_n - 120.0, t, 118.0))
	walls.append(Rect2(50, spine_n - 120.0, t, 118.0))

	# Outlook end cap feel — partial north/south taper
	walls.append(Rect2(1460, -SPINE_WIDE * 1.1 - t, 420, SPINE_WIDE * 0.15))
	walls.append(Rect2(1460, SPINE_WIDE * 0.95, 420, SPINE_WIDE * 0.15))

	return walls


func _add_wall(rect: Rect2) -> void:
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
	# Visible walls (match collision segments)
	for rect in _wall_segments:
		draw_rect(rect, WALL_DRAW, true)

	# Floor tints follow path shape — no hard room boxes
	for zone in zones:
		var zone_name: String = zone.get("name", "")
		var rect: Rect2 = zone.get("rect", Rect2())
		var kind: String = zone.get("kind", "path")
		var floor_color := GROVE_FLOOR if kind == "grove" else PATH_FLOOR
		if kind == "destination":
			floor_color = Color(0.13, 0.24, 0.19, 0.58)
		elif kind == "choke":
			floor_color = Color(0.17, 0.19, 0.13, 0.5)
		draw_rect(rect, floor_color, true)

		var label_pos := rect.get_center() + Vector2(-60, -8)
		draw_string(
			ThemeDB.fallback_font,
			label_pos,
			zone_name,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			13,
			Color(0.94, 0.96, 0.9, 0.92)
		)

	_draw_route_guides()
	_draw_marker(Vector2(-1180, 0), "START", Color(0.55, 0.85, 0.45))
	_draw_marker(Vector2(1680, 0), "END", Color(0.75, 0.85, 0.55))


func _draw_route_guides() -> void:
	var guide := Color(0.58, 0.68, 0.5, 0.45)
	var gate_center_x := (CR_HOLD_GATE_X0 + CR_HOLD_GATE_X1) * 0.5
	# Main eastward path — passes through Crossroads → Hold gate
	var points := PackedVector2Array([
		Vector2(-1180, 0), Vector2(-700, 0), Vector2(-480, 0), Vector2(-190, 0),
		Vector2(gate_center_x, 0), Vector2(310, 0), Vector2(650, 0), Vector2(930, 0),
		Vector2(1270, 0), Vector2(1680, 0),
	])
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], guide, 3.0)

	# Grove — enter from Crossroads, two south exits (SW → Crossroads, SE → Hold)
	var sw_center := (GROVE_EXIT_SW_X0 + GROVE_EXIT_SW_X1) * 0.5
	var se_center := (GROVE_EXIT_SE_X0 + GROVE_EXIT_SE_X1) * 0.5
	draw_line(Vector2(sw_center, 0), Vector2(sw_center, -300), guide, 4.0)
	draw_line(Vector2(sw_center, -300), Vector2(se_center, -300), guide, 3.0)
	draw_line(Vector2(se_center, -300), Vector2(se_center, GROVE_Y1 + 20), guide, 3.0)
	# Southwest exit back to Crossroads
	draw_line(Vector2(sw_center, GROVE_Y1 + 10), Vector2(sw_center, 0), guide, 4.0)
	# Southeast exit — quieter path into The Hold (bypasses main gate)
	draw_line(Vector2(se_center, GROVE_Y1 + 10), Vector2(se_center, 0), guide, 4.0)
	draw_line(Vector2(se_center, 0), Vector2(310, 0), guide, 3.0)

	# Crossroads spur ticks + gate hint
	draw_line(Vector2(-120, -20), Vector2(-120, -100), Color(0.7, 0.75, 0.55, 0.5), 2.0)
	draw_line(Vector2(50, -20), Vector2(50, -100), Color(0.7, 0.75, 0.55, 0.5), 2.0)
	draw_line(Vector2(CR_HOLD_GATE_X0, CR_HOLD_GATE_Y0), Vector2(CR_HOLD_GATE_X1, CR_HOLD_GATE_Y0), Color(0.75, 0.8, 0.55, 0.55), 2.5)
	draw_line(Vector2(CR_HOLD_GATE_X0, CR_HOLD_GATE_Y1), Vector2(CR_HOLD_GATE_X1, CR_HOLD_GATE_Y1), Color(0.75, 0.8, 0.55, 0.55), 2.5)


func _draw_marker(at: Vector2, text: String, color: Color) -> void:
	draw_circle(at, 10.0, color)
	draw_string(ThemeDB.fallback_font, at + Vector2(-22, -18), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)
