extends Node

var FILLERS = {
    "bodyparts": [
        "face",
        "nose",
        "brain",
        "head",
    ],
    "objects": [
        "mashed potato",
        "paper bag",
        "dirty rock",
        "turnip",
        "old shoe",
    ],
    "containers": [
        "paper bag",
        "dirty cave",
    ],
    "goblin_first_names": [
        "Gribble",
        "Nob",
        "Durbin",
        "Gob",
        "Skrimshank",
        "Bogg",
        "Grub",
        "Snarg",
        "Snikt",
        "Snarf",
        "Sklurp",
        "Snurt",
        "Snog",
    ],
    "goblin_last_names": [
        "Gribbleflange",
        "Nobblefist",
        "Durbinclaw",
        "Gobbleguts",
        "Skrimshankle",
        "Boggins",
        "Grubblethorpe",
        "Snargletooth",
        "Sniktwhistle",
        "Snarfthorn",
        "Sklurpfoot",
        "Snurtchaser",
        "Snogwarts",
        "Snogthorn",
        "Snoglethorpe",
        "Snogsworth",
        "Snogberry",
        "Snogthorn",
        "Snogsworth",
        "Snogberry",
    ]
}





var GOBLIN_MESSAGE_TEMPLATES = [
    ["At least I don't have a %s that looks like a %s!", ["bodyparts", "objects"]],
    ["You're such a fool, you probably can't even find your way out of a %s!", ["containers"]],
    ["You're so dumb, you probably can't even tie your own shoes!", []],
    ["You suck!", []],
    ["Your face sucks!", []],
    ["You walk weird!", []],
    ["You smell!", []],
]

func generate_goblin_message():
    var template = choose(GOBLIN_MESSAGE_TEMPLATES)
    var fillers = []
    for filler in template[1]:
        fillers.push_back(choose_filler(filler))
    return template[0] % fillers

func generate_goblin_name():
    var first_name = choose_filler("goblin_first_names")
    var last_name = choose_filler("goblin_last_names")
    return first_name + " " + last_name

func choose_filler(filler_name):
    return choose(FILLERS[filler_name])

func choose(array):
    return array[randi() % len(array)]
