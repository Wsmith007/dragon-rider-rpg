extends RefCounted
class_name VerticalSliceArchetypePresets
## Slice enemy roles — stats + behavior tuning applied at spawn.


enum Archetype { SCOUT, RAIDER, BRUTE }


static func _default_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-12, -14), Vector2(12, -14), Vector2(14, 6), Vector2(0, 16), Vector2(-14, 6),
	])


static func _scout_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-7, -11), Vector2(7, -11), Vector2(8, 3), Vector2(0, 9), Vector2(-8, 3),
	])


static func _brute_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-18, -20), Vector2(18, -20), Vector2(20, 10), Vector2(0, 22), Vector2(-20, 10),
	])


const PRESETS: Dictionary = {
	Archetype.SCOUT: {
		"max_health": 24.0,
		"chase_speed": 235.0,
		"engage_reposition_speed": 105.0,
		"attack_range": 36.0,
		"attack_damage": 6.0,
		"attack_cooldown": 0.62,
		"engage_windup": 0.24,
		"attack_lunge_distance": 26.0,
		"attack_lunge_duration": 0.09,
		"knockback_resistance": 0.72,
		"player_hit_knockback": 0.0,
		"player_hit_stagger": 0.0,
		"disengage_duration": 0.28,
		"disengage_speed": 175.0,
		"circle_bias": 0.0,
		"post_attack_recovery": 0.0,
		"post_attack_cooldown_bonus": 0.0,
		"attack_commit_ratio": 1.0,
		"hit_stagger_multiplier": 1.35,
		"visual_color": Color(1.0, 0.58, 0.18, 1.0),
		"visual_scale": Vector2(0.62, 0.62),
		"accent_color": Color(1.0, 0.92, 0.35, 0.7),
		"accent_scale": Vector2(1.35, 1.35),
	},
	Archetype.RAIDER: {
		"max_health": 40.0,
		"chase_speed": 108.0,
		"engage_reposition_speed": 50.0,
		"attack_range": 36.0,
		"attack_damage": 10.0,
		"attack_cooldown": 1.0,
		"engage_windup": 0.45,
		"attack_lunge_distance": 20.0,
		"attack_lunge_duration": 0.11,
		"knockback_resistance": 1.0,
		"player_hit_knockback": 0.0,
		"player_hit_stagger": 0.0,
		"disengage_duration": 0.0,
		"disengage_speed": 0.0,
		"circle_bias": 0.0,
		"post_attack_recovery": 0.0,
		"post_attack_cooldown_bonus": 0.0,
		"attack_commit_ratio": 0.4,
		"hit_stagger_multiplier": 1.0,
		"visual_color": Color(0.78, 0.14, 0.2, 1.0),
		"visual_scale": Vector2.ONE,
		"accent_color": Color(0.95, 0.25, 0.3, 0.35),
		"accent_scale": Vector2(1.08, 1.08),
	},
	Archetype.BRUTE: {
		"max_health": 72.0,
		"chase_speed": 68.0,
		"engage_reposition_speed": 34.0,
		"attack_range": 50.0,
		"attack_damage": 18.0,
		"attack_cooldown": 0.72,
		"engage_windup": 0.72,
		"attack_lunge_distance": 28.0,
		"attack_lunge_duration": 0.15,
		"knockback_resistance": 4.5,
		"player_hit_knockback": 40.0,
		"player_hit_stagger": 0.62,
		"disengage_duration": 0.0,
		"disengage_speed": 0.0,
		"circle_bias": 0.0,
		"post_attack_recovery": 0.0,
		"post_attack_cooldown_bonus": 0.0,
		"attack_commit_ratio": 0.28,
		"hit_stagger_multiplier": 0.55,
		"body_collision_radius": 22.0,
		"visual_color": Color(0.32, 0.04, 0.08, 1.0),
		"visual_scale": Vector2(1.55, 1.55),
		"accent_color": Color(0.12, 0.02, 0.04, 0.75),
		"accent_scale": Vector2(1.22, 1.22),
	},
}


static func apply_to_enemy(enemy: CharacterBody2D, archetype: Archetype) -> void:
	var preset: Dictionary = PRESETS.get(archetype, PRESETS[Archetype.RAIDER])
	var stat_keys := [
		"max_health",
		"chase_speed",
		"engage_reposition_speed",
		"attack_range",
		"attack_damage",
		"attack_cooldown",
		"engage_windup",
		"attack_lunge_distance",
		"attack_lunge_duration",
		"knockback_resistance",
		"player_hit_knockback",
		"player_hit_stagger",
		"disengage_duration",
		"disengage_speed",
		"circle_bias",
		"post_attack_recovery",
		"post_attack_cooldown_bonus",
		"attack_commit_ratio",
		"hit_stagger_multiplier",
	]
	for key in stat_keys:
		if preset.has(key):
			enemy.set(key, preset[key])

	enemy.set_meta("slice_archetype", archetype)
	enemy.set_meta("weapon_identity", WeaponIdentity.from_archetype(archetype))

	var visual := enemy.get_node_or_null("Visual") as Polygon2D
	if visual != null:
		if preset.has("visual_color"):
			visual.color = preset["visual_color"]
		if preset.has("visual_scale"):
			visual.scale = preset["visual_scale"]
		_apply_silhouette(visual, archetype)

	_apply_accent(enemy, visual, preset, archetype)

	var collision := enemy.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null and collision.shape is CircleShape2D and preset.has("body_collision_radius"):
		(collision.shape as CircleShape2D).radius = preset["body_collision_radius"]

	if preset.has("max_health") and enemy.is_node_ready():
		var health := enemy.get_node_or_null("Health")
		if health != null:
			var hp: float = preset["max_health"]
			health.max_health = hp
			health.current_health = hp


static func _apply_silhouette(visual: Polygon2D, archetype: Archetype) -> void:
	match archetype:
		Archetype.SCOUT:
			visual.polygon = _scout_polygon()
		Archetype.BRUTE:
			visual.polygon = _brute_polygon()
		_:
			visual.polygon = _default_polygon()


static func _apply_accent(
	enemy: CharacterBody2D,
	visual: Polygon2D,
	preset: Dictionary,
	archetype: Archetype,
) -> void:
	var accent := enemy.get_node_or_null("ArchetypeAccent") as Polygon2D
	if accent == null:
		accent = Polygon2D.new()
		accent.name = "ArchetypeAccent"
		accent.z_index = visual.z_index - 1 if visual != null else -1
		enemy.add_child(accent)
		if visual != null:
			enemy.move_child(accent, visual.get_index())

	accent.polygon = visual.polygon if visual != null else _default_polygon()
	accent.rotation = visual.rotation if visual != null else 0.0
	accent.scale = visual.scale if visual != null else Vector2.ONE

	if archetype == Archetype.RAIDER:
		accent.visible = false
		return

	accent.visible = true
	if preset.has("accent_color"):
		accent.color = preset["accent_color"]
	if preset.has("accent_scale"):
		accent.scale = (visual.scale if visual != null else Vector2.ONE) * preset["accent_scale"]


static func archetype_name(archetype: Archetype) -> String:
	match archetype:
		Archetype.SCOUT:
			return "Scout"
		Archetype.RAIDER:
			return "Raider"
		Archetype.BRUTE:
			return "Brute"
	return "Raider"


## Weighted random pick for debug spawns: Scout > Raider > Brute.
static func pick_random_archetype() -> Archetype:
	const WEIGHTS: Array[float] = [5.0, 3.0, 1.0]
	var total := WEIGHTS[0] + WEIGHTS[1] + WEIGHTS[2]
	var roll := randf() * total
	var cumulative := 0.0
	for i in WEIGHTS.size():
		cumulative += WEIGHTS[i]
		if roll <= cumulative:
			return i as Archetype
	return Archetype.RAIDER
