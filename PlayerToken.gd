# PlayerToken.gd
# Avatar personalizable del jugador (usa el tono elegido en la creación
# de personaje). Se mueve de lado a lado con flechas o A/D para atrapar
# los suministros que caen desde arriba en el Nivel 1, con animación de
# trote continuo y salto de celebración al atrapar.
extends Node2D

const SPEED := 560.0
const MIN_X := 90.0
const MAX_X := 1190.0

@onready var body: Sprite2D = $Body

var controls_enabled := true
var _base_y := 0.0
var _bob_time := 0.0
var _celebration: Tween

func _ready() -> void:
	_base_y = body.position.y

func _process(delta: float) -> void:
	var move_dir := Input.get_axis("ui_left", "ui_right") if controls_enabled else 0.0
	var walking := move_dir != 0.0

	if walking:
		position.x = clampf(position.x + move_dir * SPEED * delta, MIN_X, MAX_X)
		body.flip_h = move_dir < 0.0
		body.rotation = lerpf(body.rotation, 0.06 * move_dir, 10.0 * delta)
	else:
		body.rotation = lerpf(body.rotation, 0.0, 10.0 * delta)

	# Trote continuo (rápido al caminar, respiración suave en reposo)
	_bob_time += delta * (11.0 if walking else 3.5)
	body.position.y = _base_y + sin(_bob_time) * (6.0 if walking else 2.5)

func celebrate() -> void:
	# Si hay una celebración en curso, la reemplaza (evita que dos tweens
	# peleen por position:y y dejen al avatar "colgado" en el aire).
	if _celebration and _celebration.is_valid():
		_celebration.kill()
	var start_y := position.y
	_celebration = create_tween()
	_celebration.tween_property(self, "position:y", start_y - 42.0, 0.15) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_celebration.tween_property(self, "position:y", start_y, 0.22) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
