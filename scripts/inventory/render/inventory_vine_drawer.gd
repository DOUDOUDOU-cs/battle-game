class_name InventoryVineDrawer
extends Control

func _draw() -> void:
	var w := size.x
	var h := size.y
	_vine_h(Vector2(6, 7), Vector2(w - 6, 7), Vector2(0, 1), 0)
	_vine_h(Vector2(6, h - 7), Vector2(w - 6, h - 7), Vector2(0, -1), 1)
	_vine_v(Vector2(7, 6), Vector2(7, h - 6), Vector2(1, 0), 2)
	_vine_v(Vector2(w - 7, 6), Vector2(w - 7, h - 6), Vector2(-1, 0), 3)

func _vine_h(p0: Vector2, p1: Vector2, nrm: Vector2, si: int) -> void:
	var n := int(p0.distance_to(p1) / 6.0) + 1
	var pts := PackedVector2Array()
	for i in n + 1:
		var t := float(i) / n
		pts.append(p0.lerp(p1, t) + Vector2(0, sin(t * TAU * 2.5 + si * 1.7) * 3.0))
	draw_polyline(pts, Color(0.06, 0.18, 0.03, 0.95), 2.8, true)
	draw_polyline(pts, Color(0.20, 0.50, 0.10, 0.65), 1.2, true)
	_leaves(pts, nrm, si)

func _vine_v(p0: Vector2, p1: Vector2, nrm: Vector2, si: int) -> void:
	var n := int(p0.distance_to(p1) / 6.0) + 1
	var pts := PackedVector2Array()
	for i in n + 1:
		var t := float(i) / n
		pts.append(p0.lerp(p1, t) + Vector2(sin(t * TAU * 2.0 + si * 1.3) * 3.0, 0))
	draw_polyline(pts, Color(0.06, 0.18, 0.03, 0.95), 2.2, true)
	draw_polyline(pts, Color(0.20, 0.50, 0.10, 0.65), 1.0, true)
	_leaves(pts, nrm, si)

func _leaves(pts: PackedVector2Array, nrm: Vector2, si: int) -> void:
	var cnt := pts.size()
	var step: int = max(1, cnt / 9)
	var li := 0
	var idx: int = step / 2

	while idx < cnt - 1:
		var lp := pts[idx]
		var side := 1.0 if li % 2 == 0 else -1.0
		var sz := 5.0 + fmod(float((li + si) * 7 + 3), 3.5)
		_leaf(lp, nrm * side, sz)
		if li % 3 == si % 3:
			var bp := lp + nrm * side * (sz + 4.0)
			draw_circle(bp, 2.5, Color(0.50, 0.08, 0.08, 0.9))
			draw_circle(bp, 1.2, Color(0.85, 0.22, 0.12, 0.85))
		if li % 4 == (si + 1) % 4:
			var tp := pts[min(idx + step / 2, cnt - 1)]
			_tendril(lp, tp + nrm * side * 8.0)
		idx += step
		li += 1

func _leaf(pos: Vector2, ld: Vector2, sz: float) -> void:
	var d := ld.normalized()
	var p := Vector2(-d.y, d.x)
	var poly := PackedVector2Array([pos + p * sz * 0.4, pos + d * sz, pos - p * sz * 0.4, pos])
	draw_colored_polygon(poly, Color(0.10, 0.32, 0.06, 0.90))
	draw_line(pos, pos + d * sz, Color(0.20, 0.55, 0.12, 0.6), 0.8, true)

func _tendril(p0: Vector2, p1: Vector2) -> void:
	var pts := PackedVector2Array()
	var perp := (p1 - p0).normalized().rotated(PI * 0.5)
	for i in 8:
		var t := float(i) / 7.0
		pts.append(p0.lerp(p1, t) + perp * sin(t * PI * 2.0) * 4.0 * (1.0 - t))
	draw_polyline(pts, Color(0.12, 0.35, 0.07, 0.6), 0.9, true)
