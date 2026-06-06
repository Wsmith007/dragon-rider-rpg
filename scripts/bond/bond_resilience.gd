class_name BondResilience
## Bond Strength tier source of truth.
##
## All Bond Strength tier lookups (protection, commands, communication, resilience)
## should use get_bond_tier() and get_bond_tier_progress() from this module.
##
## Planned resilience effects (sync floor, instability resistance/recovery) use helpers
## here but are not wired to gameplay yet.


enum BondTier {
	ONE = 1,
	TWO = 2,
	THREE = 3,
	FOUR = 4,
}


const TIER_MIN_BOND: Array[float] = [0.0, 31.0, 61.0, 86.0]
const TIER_MAX_BOND: Array[float] = [30.0, 60.0, 85.0, 100.0]

const COMMAND_RESPONSE_DELAY_BY_TIER: Array[float] = [0.75, 0.50, 0.25, 0.0]

const SYNC_FLOOR_RANGE: Array[Vector2] = [
	Vector2(0.0, 10.0),
	Vector2(15.0, 25.0),
	Vector2(30.0, 45.0),
	Vector2(50.0, 65.0),
]

const INSTABILITY_RESISTANCE_RANGE: Array[Vector2] = [
	Vector2(0.0, 0.05),
	Vector2(0.10, 0.18),
	Vector2(0.25, 0.35),
	Vector2(0.40, 0.45),
]

const INSTABILITY_RECOVERY_RANGE: Array[Vector2] = [
	Vector2(1.00, 1.15),
	Vector2(1.20, 1.40),
	Vector2(1.50, 1.75),
	Vector2(1.80, 2.00),
]


static func get_bond_tier(bond_strength: float) -> int:
	var strength := clampf(bond_strength, 0.0, 100.0)
	if strength <= 30.0:
		return BondTier.ONE
	if strength <= 60.0:
		return BondTier.TWO
	if strength <= 85.0:
		return BondTier.THREE
	return BondTier.FOUR


static func get_bond_tier_progress(bond_strength: float) -> float:
	var strength := clampf(bond_strength, 0.0, 100.0)
	var tier_index := get_bond_tier(strength) - 1
	var min_bond := TIER_MIN_BOND[tier_index]
	var max_bond := TIER_MAX_BOND[tier_index]
	var span := max_bond - min_bond
	if span <= 0.0:
		return 1.0
	return clampf((strength - min_bond) / span, 0.0, 1.0)


static func get_command_response_delay(bond_strength: float) -> float:
	return COMMAND_RESPONSE_DELAY_BY_TIER[get_bond_tier(bond_strength) - 1]


static func get_sync_floor(bond_strength: float) -> float:
	return _interpolate_tier_range(bond_strength, SYNC_FLOOR_RANGE)


static func get_instability_resistance(bond_strength: float) -> float:
	## Returns a fraction (0.0 = 0%, 0.45 = 45%).
	return _interpolate_tier_range(bond_strength, INSTABILITY_RESISTANCE_RANGE)


static func get_instability_recovery_rate(bond_strength: float) -> float:
	## Returns a multiplier applied to future instability decay (1.0 = baseline).
	return _interpolate_tier_range(bond_strength, INSTABILITY_RECOVERY_RANGE)


static func get_bond_tier_label(bond_strength: float) -> String:
	return "Tier %d" % get_bond_tier(bond_strength)


static func _interpolate_tier_range(bond_strength: float, ranges: Array[Vector2]) -> float:
	var tier_index := get_bond_tier(bond_strength) - 1
	var progress := get_bond_tier_progress(bond_strength)
	var tier_range: Vector2 = ranges[tier_index]
	return lerpf(tier_range.x, tier_range.y, progress)
