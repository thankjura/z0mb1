var player

const constants = preload("res://scripts/constants.gd")

const FOOT_STEP_MIN = db2linear(-50)
const FOOT_STEP_MAX = db2linear(-20)
const FOOT_STEP_LEN = FOOT_STEP_MAX - FOOT_STEP_MIN

var footstep
var footstep_metal

func _init(player):
    self.player = player
    footstep = player.get_node("audio_footstep")
    footstep_metal = player.get_node("audio_footstep_metal")
    footstep.set_area_mask(constants.AUDIO_AREA_MASK)
    footstep_metal.set_area_mask(constants.AUDIO_AREA_MASK)

func footstep(ratio):
    var vol = linear2db(FOOT_STEP_LEN*ratio)
    footstep.volume_db = vol
    footstep.play()

func footstep_metal(ratio):
    var vol = linear2db(FOOT_STEP_LEN*ratio)
    footstep_metal.volume_db = vol
    footstep_metal.play()