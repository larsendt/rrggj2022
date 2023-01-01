extends CanvasLayer

const StatBox = preload("res://stat_box.tscn")

@onready var stat_container: Container = find_child("StatContainer")

func _ready():
    for key in Stats.tracked_stats:
        var props = Stats.tracked_stats[key]
        var stat = StatBox.instantiate()
        stat.name = key
        stat.get_node("NameLabel").text = props["name"] + ":"
        stat.get_node("ValueLabel").text = props["initial_value"]
        stat_container.add_child(stat)
    Stats.stat_updated.connect(self._update_stat)

func _update_stat(stat_id: String, value: String):
    stat_container.get_node(stat_id).update(value)
