extends Node

var current_wave: int = 0
var cleared_wave_count: int = 0
var last_cleared_wave: int = 0
var enemies_per_wave: int = 0
var enemies_alive: int = 0
var wave_in_progress: bool = false

signal wave_started(wave_num: int)
signal wave_cleared(wave_num: int)
signal enemy_died()

func start_wave(wave_num: int) -> void:
	current_wave = wave_num
	enemies_per_wave = 2 + wave_num
	enemies_alive = enemies_per_wave
	wave_in_progress = true
	wave_started.emit(wave_num)

func on_enemy_died() -> void:
	if not wave_in_progress or enemies_alive <= 0:
		return

	enemies_alive -= 1
	enemy_died.emit()

	if enemies_alive == 0:
		wave_in_progress = false
		last_cleared_wave = current_wave
		cleared_wave_count = max(cleared_wave_count, current_wave)
		wave_cleared.emit(current_wave)

func has_cleared_waves(required_wave_count: int) -> bool:
	return cleared_wave_count >= required_wave_count

func can_enter_level3() -> bool:
	return has_cleared_waves(2)

func reset() -> void:
	current_wave = 0
	cleared_wave_count = 0
	last_cleared_wave = 0
	enemies_per_wave = 0
	enemies_alive = 0
	wave_in_progress = false
