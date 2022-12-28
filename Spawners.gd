extends Node2D

func pick_spawner() -> Node2D:
    var spawners = get_children()
    var spawner
    while true:
        var i = randi() % len(spawners)
        spawner = spawners[i]
        if spawner.spawner_enabled:
            break
        else:
            print("Spawner %s disabled, trying again" % spawner)
            await get_tree().create_timer(0.25).timeout
    spawner.do_spawn()
    return spawner

        