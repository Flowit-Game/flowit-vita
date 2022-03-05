
-- Consts

APP_STATE_IN_GAME    = 0
APP_STATE_LEVEL_MENU = 1
APP_STATE_SETTINGS   = 2

game_packs = {"easy", "medium", "hard", "community"}

-- state variables
game_status = {pack = game_packs[1], level = 1, steps = 0}
cur_dialog = nil

-- block animation
-- "layers" should be a list of lists
-- Each list contains sets of the form {r,c}
is_animating_fill = false
animation_cell_queue_blank = {["color"] = "0", ["layers"] = {}, ["is_bomb"] = false}
animation_cell_queue = animation_cell_queue_blank
animation_cell_queue_i = 0

is_showing_dialog = false

is_game_over = false

is_animating_banner = false
