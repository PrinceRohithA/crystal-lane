extends RefCounted
class_name GddBalance

## GDD v1.3.1 stamped numbers. Do not invent alternates.
## Chart encoded here; combat wiring is P3.

enum Type { STN, STR, MND, BLM, EMB, TID, GAL, SHD }

const TYPE_IDS := ["STN", "STR", "MND", "BLM", "EMB", "TID", "GAL", "SHD"]
const TYPE_NAMES := ["Stone", "Strike", "Mind", "Bloom", "Ember", "Tide", "Gale", "Shade"]

const MULT_SUPER := 1.5
const MULT_NEUTRAL := 1.0
const MULT_RESIST := 0.5

# Rows = attacker, cols = defender. 1 = Super, -1 = Resist, 0 = Neutral.
# Order: STN STR MND BLM EMB TID GAL SHD
const CHART := [
	[0, -1, 0, 0, -1, 1, 0, 1],
	[1, 0, -1, 1, 0, 0, -1, 0],
	[0, 1, 0, 0, 1, -1, 0, -1],
	[0, -1, 0, 0, -1, 1, 0, 1],
	[1, 0, -1, 1, 0, 0, -1, 0],
	[-1, 0, 1, -1, 0, 0, 1, 0],
	[0, 1, 0, 0, 1, -1, 0, -1],
	[-1, 0, 1, -1, 0, 0, 1, 0],
]

const CAMPAIGN_START_MANA := 40.0
const CAMPAIGN_BASE_REGEN := 2.0
const CAMPAIGN_BASE_CAP := 100.0

const BOSS_L10_NAME := "Tidebound Colossus"
const BOSS_L10_TYPES := ["TID", "STN"]
const BOSS_L20_NAME := "Veilpyre Sovereign"
const BOSS_L20_TYPES := ["SHD", "EMB"]


static func type_index(type_id: String) -> int:
	return TYPE_IDS.find(type_id)


static func multiplier(attacker_type: int, defender_type: int) -> float:
	if attacker_type < 0 or defender_type < 0:
		return MULT_NEUTRAL
	if attacker_type >= CHART.size() or defender_type >= CHART[attacker_type].size():
		return MULT_NEUTRAL
	var cell: int = int(CHART[attacker_type][defender_type])
	if cell > 0:
		return MULT_SUPER
	if cell < 0:
		return MULT_RESIST
	return MULT_NEUTRAL


static func troop_mana(tier: int) -> int:
	return int(round(12.0 * pow(1.45, float(maxi(tier, 1) - 1))))


static func power_scale(cost: int) -> float:
	return pow(float(cost) / 12.0, 0.55)


static func regen_coin(n: int) -> int:
	return int(round(50.0 * pow(1.50, float(n))))


static func cap_coin(n: int) -> int:
	return int(round(40.0 * pow(1.55, float(n))))


static func level_coins(level: int) -> int:
	var base := int(round(25.0 * pow(1.22, float(level - 1))))
	if level == 10:
		base += 150
	elif level == 20:
		base += 400
	return base


## Barracks unlock soft-ceiling (GDD v1.3): min(900, round(40*1.22^k))
static func unlock_coins(k: int) -> int:
	return mini(900, int(round(40.0 * pow(1.22, float(maxi(k, 0))))))
