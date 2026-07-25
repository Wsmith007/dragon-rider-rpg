class_name PlayerWeaponVisualStyle
extends RefCounted
## Presentation-only weapon motion parameters. Gameplay timings come from MeleeAttack exports.
##
## VisualPivot local space: -Y = forward, +X = right, +Y = back/down.


static func get_style(profile_id: WeaponProfilePrototype.Id) -> Dictionary:
	match int(profile_id):
		WeaponProfilePrototype.Id.DAGGER:
			return _dagger_style()
		WeaponProfilePrototype.Id.POLEARM:
			return _polearm_style()
		WeaponProfilePrototype.Id.SWORD:
			return _sword_style()
		_:
			return _sword_style()


static func _dagger_style() -> Dictionary:
	return {
		"blade_color": Color(0.92, 0.95, 1.0, 1.0),
		"blade_polygon": PackedVector2Array([
			Vector2(-2.0, 3.0), Vector2(2.0, 3.0),
			Vector2(1.2, -12.0), Vector2(-1.2, -12.0),
		]),
		"blade_scale": Vector2.ONE,
		"rest_offset": Vector2(11.0, -2.0),
		"rest_angle_deg": 0.0,
		"front_offset": Vector2(0.0, -9.0),
		"front_angle_deg": 0.0,
		"walk_cycle_speed": 9.2,
		"walk_bob": 1.1,
		"walk_sway": 0.45,
		"idle_breathe": 0.35,
		"focused_windup_deg": -28.0,
		"focused_strike_deg": 34.0,
		"focused_body_lean": 0.06,
		"focused_bring_forward_ratio": 0.32,
		"cc_body_lean": 0.08,
	}


static func _sword_style() -> Dictionary:
	return {
		"blade_color": Color(0.92, 0.94, 0.98, 1.0),
		"blade_polygon": PackedVector2Array([
			Vector2(-3.0, 4.0), Vector2(3.0, 4.0),
			Vector2(2.2, -24.0), Vector2(-2.2, -24.0),
		]),
		"blade_scale": Vector2.ONE,
		"rest_offset": Vector2(12.0, -2.0),
		"rest_angle_deg": 0.0,
		"front_offset": Vector2(0.0, -11.0),
		"front_angle_deg": 0.0,
		"walk_cycle_speed": 7.5,
		"walk_bob": 1.5,
		"walk_sway": 0.6,
		"idle_breathe": 0.45,
		"focused_windup_deg": -38.0,
		"focused_strike_deg": 52.0,
		"focused_body_lean": 0.12,
		"focused_bring_forward_ratio": 0.32,
		"cc_body_lean": 0.14,
	}


static func _polearm_style() -> Dictionary:
	# Convex trapezoid only — self-intersecting 6-point tip flanges failed to render.
	return {
		"blade_color": Color(1.0, 0.9, 0.42, 1.0),
		"blade_polygon": PackedVector2Array([
			Vector2(-5.0, 6.0), Vector2(5.0, 6.0),
			Vector2(3.5, -32.0), Vector2(-3.5, -32.0),
		]),
		"blade_scale": Vector2(1.15, 1.1),
		"rest_offset": Vector2(13.0, -1.0),
		"rest_angle_deg": 0.0,
		"front_offset": Vector2(0.0, -14.0),
		"front_angle_deg": 0.0,
		"walk_cycle_speed": 6.0,
		"walk_bob": 2.0,
		"walk_sway": 0.75,
		"idle_breathe": 0.55,
		"focused_windup_deg": -48.0,
		"focused_strike_deg": 68.0,
		"focused_body_lean": 0.16,
		"focused_bring_forward_ratio": 0.34,
		"cc_body_lean": 0.2,
	}
