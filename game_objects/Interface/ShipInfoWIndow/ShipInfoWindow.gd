extends Control
class_name ShipInfoWindow

@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescriptionLabel
@onready var action_label: Label = %ActionPointsLabel
@onready var components_label: Label = %ComponentsLabel

func _ready() -> void:
	hide()

func show_info(ship_state: ShipState) -> void:
	title_label.text = "%s (%s)" % [ship_state.ship_name, ship_state.id]
	desc_label.text = "Power: %d" % ship_state.power
	action_label.text = "Action points: %d/%d" % [ship_state.current_aсtion_points, ship_state.max_action_points]
	if ship_state.components.size() == 0:
		components_label.visible = false
	else:
		components_label.visible = true
		var prep_text = "Components: \n"
		for component in ship_state.components:
			var component_text = "%s\n" % component.name
			prep_text+=component_text
		components_label.text = prep_text
	show()

func _on_background_blocker_pressed() -> void:
	hide()
