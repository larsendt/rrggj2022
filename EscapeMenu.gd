extends PanelContainer

func _ready():
    find_child("ResumeButton").pressed.connect(self._on_resume)
    find_child("QuitButton").pressed.connect(self._on_quit)

func _on_resume():
    self.visible = false

func toggle_escape_menu():
    self.visible = not self.visible

func _on_quit():
    get_tree().quit()