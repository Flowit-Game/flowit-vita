-------------------- GAME LOOP ------------------

function game_loop(tridata)
        draw_game(tridata)

        -- test for winning state
        if not is_animating_fill then
            if is_winning_state(tridata) then

                if not is_game_over then
                    play_sound("won")

                    local prev_hs = get_high_score(game_status.pack, game_status.level)
                    local is_hs = is_replay_high_score(game_status.pack, game_status.level, game_status.steps)

                    if is_high_score(game_status.pack, game_status.level, game_status.steps) then
                        record_high_score(game_status.pack, game_status.level, game_status.steps)
                    end

                    if is_hs then
                        show_dialog(DIALOG.WIN_HIGHSCORE)
                        high_score_cache[game_status.pack] = {}
                        high_score_cache[game_status.pack][game_status.level] = prev_hs
                    else
                        show_dialog(DIALOG.WIN)
                    end

                end

                is_game_over = true
            end
        end
end

-------------------- INTERACTION LOGIC ------------------

function hit_cell(tridata, r, c)
    local cdata = tridata["color"]
    local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    local mod = mdata[r][c]
    local obj_color = cdata[r][c]

    local cells_by_layer_to_update = {}
    local update_color = "0"

    --0 : No modifier
    if mod == "0" then
        -- do nothing

    --X : Field disabled
    elseif mod == "X" then
        -- do nothing

    --F : Flood
    elseif mod == "F" then
        play_sound("click")
        game_status.steps = game_status.steps + 1
        local empty_neighbors = get_neighbors_matching(tridata, r, c, "fill", "0")

        if #empty_neighbors > 0 then
            -- flood
            cells_by_layer_to_update = get_flood_cells_to_fill(tridata, r, c)
            update_color = obj_color
        else
            -- erase flood
            cells_by_layer_to_update = get_flood_cells_to_clear(tridata, r, c, obj_color)
            update_color = "0"
        end

    --U, w : Up
elseif mod == "U" or mod == "w" then
    play_sound("click")
    game_status.steps = game_status.steps + 1
    local dir = "up"

    local neighbor = get_neighbor_dir(tridata, r, c, dir)
    if neighbor ~= nil then
        local neighbor_color = fdata[neighbor.r][neighbor.c]
        if neighbor_color == "0" then
            update_color = obj_color

            cells_by_layer_to_update = list_to_llist(get_line_cells_to_fill(tridata, r, c, dir))
        elseif is_color(neighbor_color) then
            update_color = "0"
            cells_by_layer_to_update = list_to_llist(get_line_cells_to_clear(tridata, r, c, dir, obj_color))
        end
    end

    if mod == "w" then
        mdata[r][c] = next_rotate_state(mod)
    end

    --R, x : Right
elseif mod == "R" or mod == "x" then
    play_sound("click")
    game_status.steps = game_status.steps + 1
    local dir = "right"

    local neighbor = get_neighbor_dir(tridata, r, c, dir)
    if neighbor ~= nil then
        local neighbor_color = fdata[neighbor.r][neighbor.c]
        if neighbor_color == "0" then
            update_color = obj_color
            cells_by_layer_to_update = list_to_llist(get_line_cells_to_fill(tridata, r, c, dir))
        elseif is_color(neighbor_color) then
            update_color = "0"
            cells_by_layer_to_update = list_to_llist(get_line_cells_to_clear(tridata, r, c, dir, obj_color))
        end
    end

    if mod == "x" then
        mdata[r][c] = next_rotate_state(mod)
    end

    --L, a : Left
elseif mod == "L" or mod == "a" then
    play_sound("click")
    game_status.steps = game_status.steps + 1
    local dir = "left"

    local neighbor = get_neighbor_dir(tridata, r, c, dir)
    if neighbor ~= nil then
        local neighbor_color = fdata[neighbor.r][neighbor.c]
        if neighbor_color == "0" then
            update_color = obj_color
            cells_by_layer_to_update = list_to_llist(get_line_cells_to_fill(tridata, r, c, dir))
        elseif is_color(neighbor_color) then
            update_color = "0"
            cells_by_layer_to_update = list_to_llist(get_line_cells_to_clear(tridata, r, c, dir, obj_color))
        end
    end

    if mod == "a" then
        mdata[r][c] = next_rotate_state(mod)
    end

    --D, s : Down
elseif mod == "D" or mod == "s" then
    play_sound("click")
    game_status.steps = game_status.steps + 1
    local dir = "down"

    local neighbor = get_neighbor_dir(tridata, r, c, dir)
    if neighbor ~= nil then
        local neighbor_color = fdata[neighbor.r][neighbor.c]
        if neighbor_color == "0" then
            update_color = obj_color
            cells_by_layer_to_update = list_to_llist(get_line_cells_to_fill(tridata, r, c, dir))
        elseif is_color(neighbor_color) then
            update_color = "0"
            cells_by_layer_to_update = list_to_llist(get_line_cells_to_clear(tridata, r, c, dir, obj_color))
        end
    end

    if mod == "s" then
        mdata[r][c] = next_rotate_state(mod)
    end

    --B : Bomb
elseif mod == "B" then
    play_sound("click")
    game_status.steps = game_status.steps + 1
    local neighbors = get_bomb_cells(tridata, r, c)
    cells_by_layer_to_update = {[1] = neighbors}
    update_color = obj_color
else
    --assert(false)
end

animation_cell_queue["layers"] = cells_by_layer_to_update
animation_cell_queue["color"] = update_color
animation_cell_queue["is_bomb"] = (mod == "B")
start_cell_animation(tridata)

-- Note that state is updated as the animation progresses

end

function dismiss_win_dialog()
    next_pack, next_level = get_next_unlocked_level(all_levels, game_status.pack, game_status.level)

    cur_dialog = nil
    is_showing_dialog = false

    high_score_cache = {}

    if next_level then
        go_to_next_level(tridata)
    else
        app_state = APP_STATE_LEVEL_MENU
    end
end

-- handle taps
function handle_tap_ingame(tridata, x, y)
    if (not is_showing_dialog) then
        if (not is_animating_fill) then
            -- cell taps
            if (not is_game_over) then
                local tap = xy_to_rc(x, y)
                if (tap ~= nil) then
                    hit_cell(tridata, tap.r, tap.c)
                    return
                end
            end

            -- check for hitting other controls
            local tapped_control = xy_to_control(x, y)
            if tapped_control == "next" then

                if get_next_unlocked_level(all_levels, game_status.pack, game_status.level) then
                    play_sound("click")

                    if (game_status.steps > 0) and (SETTINGS.confirmations.value ~= "off") then
                        show_dialog(DIALOG.NEXT_LEVEL)
                    else
                        go_to_next_level(tridata)
                    end
                end

            elseif tapped_control == "prev" then

                if get_prev_unlocked_level(all_levels, game_status.pack, game_status.level) then
                    play_sound("click")

                    if (game_status.steps > 0) and (SETTINGS.confirmations.value ~= "off") then
                        show_dialog(DIALOG.PREV_LEVEL)
                    else
                        go_to_prev_level(tridata)
                    end
                end

            elseif tapped_control == "reset" then
                play_sound("click")
                if (game_status.steps > 0) and (SETTINGS.confirmations.value ~= "off") then
                    show_dialog(DIALOG.RESET_GAME)
                else
                    reset_game(tridata)
                end
            elseif tapped_control == "back" then
                play_sound("click")
                if (game_status.steps > 0) and (SETTINGS.confirmations.value ~= "off") then
                    show_dialog(DIALOG.LEVEL_MENU)
                else
                    --reset_game(tridata)
                    app_state = APP_STATE_LEVEL_MENU
                end
            else
                -- do nothing
            end
        end
    elseif (cur_dialog == DIALOG.WIN) or (cur_dialog == DIALOG.WIN_HIGHSCORE) then
        dismiss_win_dialog()
    elseif (cur_dialog ~= nil) then
        local dialog_tap = xy_to_dialog_control(x, y)
        if dialog_tap == "no" then
            dismiss_dialog()
        elseif dialog_tap == "yes" then
            if (cur_dialog == DIALOG.LEVEL_MENU) then
                    --reset_game(tridata)
                    app_state = APP_STATE_LEVEL_MENU
                    dismiss_dialog()
            elseif (cur_dialog == DIALOG.NEXT_LEVEL) then
                    go_to_next_level(tridata)
                    dismiss_dialog()
            elseif (cur_dialog == DIALOG.PREV_LEVEL) then
                    go_to_prev_level(tridata)
                    dismiss_dialog()
            elseif (cur_dialog == DIALOG.RESET_GAME) then
                    reset_game(tridata)
                    dismiss_dialog()
            end
        end
    end
end

-------------------- TRANSITIONS ------------------

function go_to_next_level(tridata)
    next_pack, next_level = get_next_unlocked_level(all_levels, game_status.pack, game_status.level)
    if next_pack ~= nil and next_level ~= nil then
        --reset_game(tridata)
        is_game_over = true

        game_status.pack = next_pack
        game_status.level = next_level
        game_status.steps = 0
        tridata = level_to_tridata(all_levels, game_status.pack, game_status.level)

        draw_game(tridata)
        is_game_over = false
    end
end

function go_to_prev_level(tridata)
    prev_pack, prev_level = get_prev_unlocked_level(all_levels, game_status.pack, game_status.level)
    if prev_pack ~= nil and prev_level ~= nil then
        --reset_game(tridata)
        is_game_over = true

        game_status.pack = prev_pack
        game_status.level = prev_level
        game_status.steps = 0
        tridata = level_to_tridata(all_levels, game_status.pack, game_status.level)

        draw_game(tridata)
        is_game_over = false
    end
end

function reset_game(tridata)
    is_game_over = true
    game_status.steps = 0
    tridata = level_to_tridata(all_levels, game_status.pack, game_status.level)

    draw_game(tridata)
    is_game_over = false
end
