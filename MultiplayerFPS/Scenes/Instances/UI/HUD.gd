extends Control

var weapon_ui
var health_ui
var display_ui
var slot_ui
var crosshair
var sniper_crosshair
var damage_indicators
var hitmarker
var damage_overlay
var health_bar

func set_references():
	weapon_ui = $Background/WeaponUI
	display_ui = $Background/Display/WeaponImage
	slot_ui = $Background/Display/WeaponSlot
	health_ui = $Background/HealthUI
	crosshair = $Crosshair
	sniper_crosshair = $SniperCrosshair
	damage_indicators = $DamageIndicators
	hitmarker = $Hitmarker
	damage_overlay = $DamageOverlay
	health_bar = $Background/HealthBar

func _ready():
	hide_interaction_prompt()

func _enter_tree():
	set_references()

func update_weapon_ui(weapon_data, weapon_slot):
	slot_ui.text = weapon_slot
	
	if weapon_data["name"] == "UNARMED":
		weapon_ui.text = weapon_data["name"]
		return
	
	weapon_ui.text = weapon_data["name"] + ": " + weapon_data["ammo"] + "/" + weapon_data["extra_ammo"]
	
func update_health(health):
	health_ui.text = "Health: " + str(health)
	health_bar.value = clamp(health, 0, 100)

func show_interaction_prompt(description = "Interact"):
	$InteractionPrompt.visible = true
	$InteractionPrompt/LabelMessage.text = description
	
func hide_interaction_prompt():
	$InteractionPrompt.visible = false
