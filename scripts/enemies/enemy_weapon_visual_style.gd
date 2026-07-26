class_name EnemyWeaponVisualStyle
extends RefCounted
## Placeholder procedural weapons for Scout / Raider / Brute. Presentation only.


static func style_for_archetype(archetype: VerticalSliceArchetypePresets.Archetype) -> Dictionary:
	match archetype:
		VerticalSliceArchetypePresets.Archetype.SCOUT:
			return _dagger()
		VerticalSliceArchetypePresets.Archetype.BRUTE:
			return _warhammer()
		_:
			return _sword()


static func _dagger() -> Dictionary:
	return {
		"display_name": "Dagger",
		"blade_color": Color(0.88, 0.9, 0.95, 1.0),
		"blade_polygon": PackedVector2Array([
			Vector2(-1.8, 2.5), Vector2(1.8, 2.5),
			Vector2(1.0, -11.0), Vector2(-1.0, -11.0),
		]),
		"blade_scale": Vector2(0.95, 0.95),
		"rest_offset": Vector2(10.0, -1.0),
		"rest_angle_deg": -8.0,
		"windup_angle_deg": -42.0,
		"strike_angle_deg": 38.0,
	}


static func _sword() -> Dictionary:
	return {
		"display_name": "Sword",
		"blade_color": Color(0.9, 0.92, 0.96, 1.0),
		"blade_polygon": PackedVector2Array([
			Vector2(-2.6, 3.5), Vector2(2.6, 3.5),
			Vector2(1.8, -22.0), Vector2(-1.8, -22.0),
		]),
		"blade_scale": Vector2.ONE,
		"rest_offset": Vector2(12.0, -1.5),
		"rest_angle_deg": -5.0,
		"windup_angle_deg": -48.0,
		"strike_angle_deg": 52.0,
	}


static func _warhammer() -> Dictionary:
	# Heavy head silhouette — distinct from player polearm.
	return {
		"display_name": "Warhammer",
		"blade_color": Color(0.72, 0.68, 0.62, 1.0),
		"blade_polygon": PackedVector2Array([
			Vector2(-2.0, 5.0), Vector2(2.0, 5.0),
			Vector2(2.2, -18.0), Vector2(8.0, -18.0),
			Vector2(8.0, -28.0), Vector2(-8.0, -28.0),
			Vector2(-8.0, -18.0), Vector2(-2.2, -18.0),
		]),
		"blade_scale": Vector2(1.05, 1.05),
		"rest_offset": Vector2(14.0, 0.0),
		"rest_angle_deg": 12.0,
		"windup_angle_deg": -55.0,
		"strike_angle_deg": 62.0,
		"rush_windup_angle_deg": -70.0,
	}
