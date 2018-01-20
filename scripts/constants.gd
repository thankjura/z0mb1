const GROUND_LAYER = 1

const GUN_ENTITY_Z = 20

const GRENADE_LAYER = 64
const GRENADE_MASK = 0

const GUN_ENTITY_LAYER = 0
const GUN_ENTITY_MASK = GROUND_LAYER + GRENADE_LAYER
const GUN_ENTITY_AREA_LAYER = 0
const GUN_ENTITY_AREA_MASK = 16

const BULLET_LAYER = 8
const BULLET_MASK = GROUND_LAYER

const BULLET_SHELL_LAYER = 0
const BULLET_SHELL_MASK = GROUND_LAYER + BULLET_SHELL_LAYER

const ENEMY_LAYER = 32
const ENEMY_MASK = GROUND_LAYER + BULLET_LAYER + GRENADE_LAYER

const ENEMY_BULLET_LAYER = 4
const ENEMY_BULLET_MASK = GROUND_LAYER

const PLAYER_LAYER = GUN_ENTITY_AREA_MASK
const PLAYER_MASK = GROUND_LAYER + ENEMY_BULLET_LAYER + GRENADE_LAYER