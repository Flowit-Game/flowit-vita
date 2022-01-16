
-- global variables
VG = {}
VG.grid_width      = 0
VG.grid_height     = 0
VG.grid_nx         = 0
VG.grid_ny         = 0
VG.grid_x_offset   = 0
VG.grid_y_offset   = 0
VG.cell_size       = 0
VG.max_cell_size   = 80
VG.space_size      = 0
VG.screen_margin   = 10
VG.outline_size    = 0
VG.inside_gap_size = 0

VG.font_big = 36
VG.font_small = 24

control_area = {}

-- initialize control areas; these are updated later in set_game_size
control_area["prev"] = {
    x = VG.screen_margin,
    y = VG.screen_margin,
    w = 60,
    h = 60,
}
control_area["next"] = {
    x = screen_width() - 60 - VG.screen_margin,
    y = VG.screen_margin,
    w = 60,
    h = 60,
}
control_area["reset"] = {
    x = screen_width() - 80 - VG.screen_margin,
    y = screen_height() - 80 - VG.screen_margin,
    w = 80,
    h = 80,
}
control_area["back"] = {
    x = VG.screen_margin,
    y = screen_height() - 60 - VG.screen_margin,
    w = 100,
    h = 60,
    lr_align = "left",
    tb_align = "bottom",
    font_size = VG.font_big,
}


-- Fit game grid into window and return:
--   x,y offset of game grid corner
--   cell size
--   inter-cell spacing
-- On vita, this only needs to be called once each game
-- On desktop, we need to rerun it when the window is resized
-- TODO: improve space for controls
function set_game_size(tridata, width, height)
    local cdata = tridata["color"]
    --local mdata = tridata["modifier"]
    --local fdata = tridata["fill"]

    local nrows = #cdata
    local ncols = #cdata[1]

    local width_orig = width
    local height_orig = height

    -- TODO approximate control size more accurately....
    local x_control_margin = width*0.22 + VG.screen_margin

    width = width - 2*x_control_margin
    height = height - 2*VG.screen_margin

    local length = height
    local nx = nrows
    if (ncols/width) > (nrows/height) then
        length = width
        nx = ncols
    end
   
    -- nx*csize + (nx-1)*ssize <= length

    local csize_0 = math.floor(length/nx)
    local ssize = math.ceil(csize_0/20)
    local csize = math.floor( ( length - ssize*(nx-1) )/nx )

    -- the above code make cells small enough to fit in the screen.
    -- but we don't want them to be too big either,
    -- so we cap their size here.
    if (csize > VG.max_cell_size) then
        csize = VG.max_cell_size
        ssize = math.ceil(csize/20)
    end

    local grid_width  = csize*ncols + ssize*(ncols-1)
    local grid_height = csize*nrows + ssize*(nrows-1)

    local xoffset = math.floor((width_orig - grid_width)/2)
    local yoffset = math.floor((height_orig - grid_height)/2)

    VG.grid_width = grid_width
    VG.grid_height = grid_height
    VG.grid_nx = ncols
    VG.grid_ny = nrows
    VG.grid_x_offset = xoffset
    VG.grid_y_offset = yoffset
    VG.cell_size = csize
    VG.space_size = ssize
    VG.outline_size = math.ceil(VG.cell_size/15)
    VG.inside_gap_size = math.ceil(VG.cell_size/40)

    control_area["prev"] = {
        x = VG.screen_margin,
        y = VG.screen_margin,
        w = 60,
        h = 60,
    }
    control_area["next"] = {
        x = screen_width() - 60 - VG.screen_margin,
        y = VG.screen_margin,
        w = 60,
        h = 60,
    }
    control_area["reset"] = {
        x = screen_width() - 80 - VG.screen_margin,
        y = screen_height() - 80 - VG.screen_margin,
        w = 80,
        h = 80,
    }
    control_area["back"] = {
        x = VG.screen_margin,
        y = screen_height() - 60 - VG.screen_margin,
        w = 100,
        h = 60,
        lr_align = "left",
        tb_align = "bottom",
        font_size = VG.font_big,
    }
end

function xy_to_control(x, y)
    for control_str, area in pairs(control_area) do
        if (x >= area.x) and (x <= area.x + area.w)
            and (y >= area.y) and (y <= area.y + area.h) then
            return control_str
        end

    end
    return nil
end

function xy_to_rc(x, y)
    x = x - VG.grid_x_offset
    y = y - VG.grid_y_offset

    if (0 <= x) and (x <= VG.grid_width) and
        (0 <= y) and (y <= VG.grid_height) then

        local r = math.ceil(y/(VG.cell_size + VG.space_size))
        local c = math.ceil(x/(VG.cell_size + VG.space_size))

        -- compute offset within cell
        local xc = x - (c-1)*(VG.cell_size + VG.space_size)
        local yc = y - (r-1)*(VG.cell_size + VG.space_size)
        if (xc > VG.cell_size) or (yc > VG.cell_size) then
            -- we're between cells
            return nil
        end


        return {r = r, c = c}
    end
    return nil
end

function draw_block(tridata, r, c, outline_color, fill_color, modifier)
    local cdata = tridata["color"]

    local x1 = VG.grid_x_offset + (c-1)*(VG.cell_size + VG.space_size)
    local y1 = VG.grid_y_offset + (r-1)*(VG.cell_size + VG.space_size)
    local x2 = x1 + VG.cell_size
    local y2 = y1 + VG.cell_size

    draw_rect(x1, y1, x2, y2, outline_color)

    local x1w = x1 + VG.outline_size
    local y1w = y1 + VG.outline_size
    local x2w = x2 - VG.outline_size
    local y2w = y2 - VG.outline_size

    if modifier ~= nil and modifier ~= "0" and not is_color(modifier) then

        -- fill cell completely
        draw_rect(x1w, y1w, x2w, y2w, fill_color)

        draw_icon(x1, y1, x2, y2, modifier)
    else
        draw_rect(x1w, y1w, x2w, y2w, "0")

        local x1f = x1w + VG.inside_gap_size
        local y1f = y1w + VG.inside_gap_size
        local x2f = x2w - VG.inside_gap_size
        local y2f = y2w - VG.inside_gap_size

        draw_rect(x1f, y1f, x2f, y2f, fill_color)
    end

end

function draw_block_from_state(tridata, r, c)
    local cdata = tridata["color"]
    local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    local outline_color = cdata[r][c]
    local fill_color = fdata[r][c]
    local modifier = mdata[r][c]

    if (fill_color == "X") then
        fill_color = outline_color
    end

    if modifier ~= "X" then
        draw_block(tridata, r, c, outline_color, fill_color, modifier)
    else
        --draw_block(tridata, r, c, "X", "X", modifier)
    end
end

function draw_state(tridata)
    local cdata = tridata["color"]
    --local mdata = tridata["modifier"]
    --local fdata = tridata["fill"]

    local nrows = #cdata
    local ncols = #cdata[1]

    for r = 1,nrows do
        for c = 1,ncols do
            draw_block_from_state(tridata, r, c)
        end
    end

end

function draw_game(tridata)
    set_game_size(tridata, screen_width(), screen_height())
    init_draw_phase()
    draw_info()
    draw_controls()
    draw_state(tridata)
    draw_dialog()
    end_draw_phase()
end

function draw_control_icon(control_str)
    local x1 = control_area[control_str].x
    local y1 = control_area[control_str].y
    local x2 = x1 + control_area[control_str].w
    local y2 = y1 + control_area[control_str].h
    draw_general_icon(x1, y1, x2, y2, control_images[control_str], "d")
end
function draw_control_text(control_str)
    local ca = control_area[control_str]
    local text = " " .. get_i18n(control_str) .. " "
    local font_size = ca.font_size
    local text_w, text_h = text_dimensions(text, font_size, default_font_name)

    -- update control area to math text dimensions
    local x1 = 0
    if ca.lr_align == "right" then
        x1 = ca.x + ca.w - text_w
    else
        x1 = ca.x
    end
    local y1 = 0
    if ca.tb_align == "bottom" then
        y1 = ca.y + ca.h - text_h
    else
        y1 = ca.y
    end

    local buffer = 3

    ca.x = x1
    ca.y = y1
    ca.w = text_w
    ca.h = text_h


    draw_rect(ca.x, ca.y, ca.x + ca.w, ca.y + ca.h, "d")
    draw_text(x1, y1, font_size, text, "X", default_font_name)
end

function draw_controls()
    if not (game_status.pack == "easy" and game_status.level == 1) then
        draw_control_icon("prev")
    end
    if not (game_status.pack == "hard" and game_status.level == #all_levels["hard"]) then
        draw_control_icon("next")
    end
    draw_control_icon("reset")

    draw_control_text("back")
end

function draw_info()
    -- TODO: improve numeric offsets

    local x_offset = VG.screen_margin
    local y_offset = 140

    draw_text(x_offset, 0 + y_offset, VG.font_big, get_i18n(game_status.pack), "d", default_font_name)

    local level_prefix = get_i18n("level_prefix") or ""
    local level_postfix = get_i18n("level_postfix") or ""
    if level_postfix and #level_postfix > 0 then
        draw_text(x_offset, 50 + y_offset, VG.font_big, level_prefix .. tostring(game_status.level) .. level_postfix, "d", default_font_name)
    else
        local level_w, _ = text_dimensions(level_prefix .. " ", VG.font_big, default_font_name)
        draw_text(x_offset, 50 + y_offset, VG.font_big, level_prefix, "d", default_font_name)
        draw_text(x_offset + level_w, 50 + y_offset, VG.font_big, tostring(game_status.level), "d", number_font_name)
    end

    local moves_w, _ = text_dimensions(get_i18n("moves:"), VG.font_small, default_font_name)
    local best_w, _ = text_dimensions(get_i18n("best:"), VG.font_small, default_font_name)
    moves_w = math.max(moves_w, best_w) + math.ceil(VG.font_small/2)

    draw_text(x_offset, 115 + y_offset, VG.font_small, get_i18n("moves:"), "d", default_font_name)
    draw_text(x_offset + moves_w, 115 + y_offset, VG.font_small, tostring(game_status.steps), "d", number_font_name)

    local hs = get_high_score(game_status.pack, game_status.level)
    local hs_cache = get_cached_high_score(game_status.pack, game_status.level)
    if hs ~= nil then

        draw_text(x_offset, 145 + y_offset, VG.font_small, get_i18n("best:"), "d", default_font_name)
        if (is_game_over) and (hs_cache) and (hs < hs_cache) then
            draw_text(x_offset + moves_w, 145 + y_offset, VG.font_small, tostring(hs_cache), "d", number_font_name)
        else
            draw_text(x_offset + moves_w, 145 + y_offset, VG.font_small, tostring(hs), "d", number_font_name)
        end

    end
end

function abort_cell_animation(tridata)
    local cdata = tridata["color"]
    local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    -- complete state (in case animation unfinished)
    for i=animation_cell_queue_i+1,#animation_cell_queue do
        -- update state
        for _, cell in pairs(animation_cell_queue["layers"][i]) do
            if animation_cell_queue["is_bomb"] then
                -- remove modifier due to bomb
                mdata[cell.r][cell.c] = "0"
            end

            -- update fill color
            fdata[cell.r][cell.c] = animation_cell_queue["color"]
        end
    end


    animation_cell_queue = animation_cell_queue_blank
    animation_cell_queue_i = 0
    is_animating_fill = false
end

function step_cell_animation(tridata)
    local cdata = tridata["color"]
    local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    is_animating_fill = true

    if (animation_cell_queue["color"] == nil) or (animation_cell_queue["layers"] == nil)
        or (animation_cell_queue_i >= #animation_cell_queue["layers"])  then
        abort_cell_animation(tridata)
        return nil
    else

        animation_cell_queue_i = animation_cell_queue_i + 1
        play_sound("fill")

        -- update state
        for _, cell in pairs(animation_cell_queue["layers"][animation_cell_queue_i]) do
            if animation_cell_queue["is_bomb"] then
                -- remove modifier due to bomb
                mdata[cell.r][cell.c] = "0"
            end

            -- update fill color
            fdata[cell.r][cell.c] = animation_cell_queue["color"]
        end

    end
end
