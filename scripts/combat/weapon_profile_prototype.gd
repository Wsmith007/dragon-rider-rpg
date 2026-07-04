extends RefCounted
class_name WeaponProfilePrototype
## Debug-only weapon profile data for focused + CC attack prototyping. Not equipment.
##
## Identity (Tuning Pass 1):
## - Dagger: fastest, lowest DPS, precision, weakest CC
## - Sword: highest DPS, balanced general-purpose
## - Polearm: highest control, medium DPS, strongest CC


enum Id { DAGGER, SWORD, POLEARM }


const PROFILES: Dictionary = {
	Id.DAGGER: {
		"display_name": "Dagger",
		"focused_damage": 18.0,
		"focused_knockback": 15.0,
		"focused_stagger": 0.3,
		"focused_cooldown": 0.24,
		"focused_range": 40.0,
		"focused_half_angle_deg": 22.5,
		"focused_close_range": 22.0,
		"focused_close_half_angle_deg": 35.0,
		"focused_windup": 0.06,
		"focused_recovery": 0.08,
		"focused_windup_move_speed": 0.64,
		"focused_recovery_move_speed": 0.80,
		"soft_assist_range": 36.0,
		"soft_assist_half_angle_deg": 40.0,
		"soft_assist_strength": 0.2,
		"crowd_control_damage": 8.0,
		"crowd_control_knockback": 14.0,
		"crowd_control_stagger": 0.5,
		"crowd_control_cooldown": 0.75,
		"crowd_control_radius": 22.0,
		"crowd_control_windup": 0.12,
		"crowd_control_recovery": 0.14,
		"crowd_control_windup_move_speed": 0.48,
		"crowd_control_recovery_move_speed": 0.58,
	},
	Id.SWORD: {
		"display_name": "Sword",
		"focused_damage": 29.0,
		"focused_knockback": 25.0,
		"focused_stagger": 0.3,
		"focused_cooldown": 0.38,
		"focused_range": 52.0,
		"focused_half_angle_deg": 50.0,
		"focused_close_range": 30.0,
		"focused_close_half_angle_deg": 55.0,
		"focused_windup": 0.11,
		"focused_recovery": 0.13,
		"focused_windup_move_speed": 0.54,
		"focused_recovery_move_speed": 0.68,
		"soft_assist_range": 44.0,
		"soft_assist_half_angle_deg": 48.0,
		"soft_assist_strength": 0.2,
		"crowd_control_damage": 12.0,
		"crowd_control_knockback": 24.0,
		"crowd_control_stagger": 0.6,
		"crowd_control_cooldown": 0.95,
		"crowd_control_radius": 28.0,
		"crowd_control_windup": 0.17,
		"crowd_control_recovery": 0.20,
		"crowd_control_windup_move_speed": 0.40,
		"crowd_control_recovery_move_speed": 0.50,
	},
	Id.POLEARM: {
		"display_name": "Polearm",
		"focused_damage": 19.0,
		"focused_knockback": 35.0,
		"focused_stagger": 0.3,
		"focused_cooldown": 0.68,
		"focused_range": 72.0,
		"focused_half_angle_deg": 70.0,
		"focused_close_range": 34.0,
		"focused_close_half_angle_deg": 70.0,
		"focused_windup": 0.15,
		"focused_recovery": 0.21,
		"focused_windup_move_speed": 0.46,
		"focused_recovery_move_speed": 0.56,
		"soft_assist_range": 58.0,
		"soft_assist_half_angle_deg": 55.0,
		"soft_assist_strength": 0.15,
		"crowd_control_damage": 10.0,
		"crowd_control_knockback": 35.0,
		"crowd_control_stagger": 0.7,
		"crowd_control_cooldown": 1.35,
		"crowd_control_radius": 36.0,
		"crowd_control_windup": 0.20,
		"crowd_control_recovery": 0.24,
		"crowd_control_windup_move_speed": 0.34,
		"crowd_control_recovery_move_speed": 0.42,
	},
}


static func get_display_name(profile_id: Id) -> String:
	return String(PROFILES[profile_id]["display_name"])


static func get_profile(profile_id: Id) -> Dictionary:
	return PROFILES[profile_id].duplicate()


static func get_focused_arc_deg(profile_id: Id) -> float:
	var data: Dictionary = PROFILES[profile_id]
	return float(data["focused_half_angle_deg"]) * 2.0
