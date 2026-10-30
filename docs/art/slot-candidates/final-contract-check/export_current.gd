extends "res://tools/art/render_slot_refs.gd"

# Candidate-only destination. The official export logic and hash are inherited unchanged.
func _initialize() -> void:
	_export(ProjectSettings.globalize_path("res://docs/art/slot-candidates/final-contract-check/slots.json"))
	quit()
