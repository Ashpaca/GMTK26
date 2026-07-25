extends Node

@warning_ignore_start("unused_signal")

# emitted by: game_state
# connected to: world
signal spawn_shopper

# emitted by: none
# connected to: none
signal request_start_game

# emitted by: none
# connected to: none
signal request_quit_game


signal game_over(good_ending : bool)
