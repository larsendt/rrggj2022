extends MarginContainer

@onready var camera_selector: OptionButton = find_child("CameraSelector")
signal camera_selected(id: int)

func _ready():
    GameState.player_joined.connect(self._player_joined)
    GameState.player_left.connect(self._player_left)
    GameState.player_name_updated.connect(self._player_name_updated)
    camera_selector.item_selected.connect(self._camera_selected)

func _player_joined(id: int):
    camera_selector.add_item(str(id), id)

func _player_left(id: int):
    var idx = camera_selector.get_item_index(id)
    camera_selector.remove_item(idx)

func _player_name_updated(id: int, new_name: String):
    var idx = camera_selector.get_item_index(id)
    camera_selector.set_item_text(idx, new_name)

func _camera_selected(idx: int):
    var id = camera_selector.get_item_id(idx)
    emit_signal("camera_selected", id)