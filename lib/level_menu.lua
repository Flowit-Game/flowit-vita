-- global variables
VLM = {}
VLM.grid_width      = 0
VLM.grid_x_offset   = 0
VLM.grid_y_offset   = 100
VLM.screen_margin   = 20
VLM.cell_size       = 50
VLM.space_size      = 15
VLM.nx              = 0
VLM.cell_font       = 16
VLM.header_font     = 50
VLM.header_font_small = 32
VLM.sel_buffer_ext  = 6
VLM.sel_buffer_int  = 3
VLM.header_width    = 300
VLM.header_y_buffer = 100
VLM.header_y_step   = 0

VLM.settings_x = 0
VLM.settings_y = VLM.screen_margin
VLM.settings_width = 0
VLM.settings_height = 40
VLM.settings_font = 24

prev_sel_level_per_pack = {}

-- local functions

local function n_to_rc(n)
    local r = math.ceil(n/VLM.nx)
    local c = n - VLM.nx*(r-1)
    return {r = r, c = c}
end
local function rc_to_n(r, c)
    return VLM.nx*(r-1) + c
end

local function draw_level_square(r, c, level_i, modifier)
    local x1 = VLM.grid_x_offset + (VLM.cell_size + VLM.space_size)*(c-1)
    local y1 = VLM.grid_y_offset + (VLM.cell_size + VLM.space_size)*(r-1)
    local x2 = x1 + VLM.cell_size
    local y2 = y1 + VLM.cell_size

    local fill_color = "b"
    if modifier == "lock" then
        fill_color = "t"
    elseif modifier == "check" then
        fill_color = "b"
    end

    draw_rect(x1, y1, x2, y2, fill_color)
    draw_text(x1+2, y1+1, VLM.cell_font, tostring(level_i), "0", number_font_name)

    local icon_x_offset = VLM.cell_size*0.5
    local icon_y_offset = VLM.cell_size*0.5
    local icon_size = VLM.cell_size*0.4

    if (modifier == "check") or (modifier == "lock") then
        draw_general_icon(x1 + icon_x_offset, y1 + icon_y_offset, x1 + icon_x_offset + icon_size, y1 + icon_y_offset + icon_size, misc_images[modifier], "0")
    end
end

local function draw_selection_square(r, c, fill_color)
    local x = VLM.grid_x_offset + (VLM.cell_size + VLM.space_size)*(c-1)
    local y = VLM.grid_y_offset + (VLM.cell_size + VLM.space_size)*(r-1)
    draw_rect(x - VLM.sel_buffer_ext, y - VLM.sel_buffer_ext, x + VLM.cell_size + VLM.sel_buffer_ext, y + VLM.cell_size + VLM.sel_buffer_ext, fill_color)
    draw_rect(x - VLM.sel_buffer_int, y - VLM.sel_buffer_int, x + VLM.cell_size + VLM.sel_buffer_int, y + VLM.cell_size + VLM.sel_buffer_int, "X")
end

local function draw_settings_button()
    local text = get_i18n("settings")
    local font_size = VLM.settings_font
    local text_w, text_h = text_dimensions(text, font_size, default_font_name)
    --text = tostring(text_w) .. "," .. tostring(text_h) -- debug
    local settings_buffer = 10
    VLM.settings_width = text_w + 2*settings_buffer
    VLM.settings_height = math.max(VLM.settings_height, text_h + 6)
    VLM.settings_x = screen_width() - VLM.settings_width - VLM.screen_margin

    local text_x = VLM.settings_x + (VLM.settings_width - text_w)/2
    local text_y = VLM.settings_y + (VLM.settings_height - text_h)/2
    draw_rect(VLM.settings_x, VLM.settings_y, VLM.settings_x + VLM.settings_width, VLM.settings_y + VLM.settings_height, "t")
    draw_text(text_x, text_y, font_size, text, "X", default_font_name)
end

-- global functions

function level_menu_loop()
    set_levelmenu_size(screen_width(), screen_height())

    draw_level_menu()
end

function set_levelmenu_size(width, height)

    local width_orig = width
    local height_orig = height

    width = width - VLM.screen_margin - VLM.header_width
    height = height - 2*VLM.screen_margin

    --VLM.cell_size*nx + VLM.space_size*(nx-1) <= width
    --(VLM.cell_size + VLM.space_size*)nx <= width + VLM.space_size
    VLM.nx = math.floor((width + VLM.space_size)/(VLM.cell_size + VLM.space_size))
    VLM.grid_width = (VLM.cell_size + VLM.space_size)*VLM.nx - VLM.space_size
    VLM.grid_x_offset = VLM.header_width

    -- header text
    VLM.header_y_step = math.ceil( (height_orig - 2*VLM.header_y_buffer - VLM.header_font)/(#game_packs-1) )
end

function draw_level_menu()
    init_draw_phase()

    -- draw header
    local x_offset_text = VLM.screen_margin

    for tj, pack in pairs(game_packs) do
        local pack_str = get_i18n(pack)
        local y_offset_text = VLM.header_y_buffer + (tj-1)*VLM.header_y_step
        local text_color = "t"
        if pack == game_status.pack then
            text_color = "b"
        end

        local this_header_font = VLM.header_font
        if pack == "community" then
            if (lang_code ~= "zh_t") and (lang_code ~= "zh_s") then
                this_header_font = VLM.header_font_small
            end
        end


        --local text_w, text_h = text_dimensions(pack_str, VLM.header_font, default_font_name) -- debug
        --pack_str = tostring(text_w) .. "," .. tostring(text_h) -- debug
        draw_text(x_offset_text, y_offset_text, this_header_font, pack_str, text_color, default_font_name)
    end

    -- draw squares
    local sel_level = game_status.level or 1
    for n=1,#all_levels[game_status.pack] do
        local cell = n_to_rc(n)

        if n == sel_level then
            draw_selection_square(cell.r, cell.c, "t")
        end

        if get_high_score(game_status.pack, n) then
            draw_level_square(cell.r, cell.c, n, "check")
        elseif is_level_locked(game_status.pack, n) then
            draw_level_square(cell.r, cell.c, n, "lock")
        else
            draw_level_square(cell.r, cell.c, n, nil)
        end

    end

    -- draw settings button
    draw_settings_button()

    end_draw_phase()
end

function next_menu_pack()
    if game_status.pack == "easy" then
        switch_menu_pack("medium")
    elseif game_status.pack == "medium" then
        switch_menu_pack("hard")
    elseif game_status.pack == "hard" then
        switch_menu_pack("community")
    end
end
function prev_menu_pack()
    if game_status.pack == "medium" then
        switch_menu_pack("easy")
    elseif game_status.pack == "hard" then
        switch_menu_pack("medium")
    elseif game_status.pack == "community" then
        switch_menu_pack("hard")
    end
end

function switch_menu_pack(pack)
    game_status.pack = pack

    if prev_sel_level_per_pack[pack] then
        game_status.level = prev_sel_level_per_pack[pack]
    else
        game_status.level = 1
    end
end

local function xy_to_n_levelmenu(x,y)
    x = x - VLM.grid_x_offset
    y = y - VLM.grid_y_offset

    if (0 <= x) and (x <= VLM.grid_width) then

        local r = math.ceil(y/(VLM.cell_size + VLM.space_size))
        local c = math.ceil(x/(VLM.cell_size + VLM.space_size))

        -- compute offset within cell
        local xc = x - (c-1)*(VLM.cell_size + VLM.space_size)
        local yc = y - (r-1)*(VLM.cell_size + VLM.space_size)
        if (xc > VLM.cell_size) or (yc > VLM.cell_size) then
            -- we're between cells
            return nil
        end

        local n = rc_to_n(r, c)

        if (n >= 1) and (n <= #all_levels[game_status.pack]) then
            return n
        else
            return nil
        end
    end
    return nil
end

local function xy_to_pack_levelmenu(x,y)
    y = y - VLM.header_y_buffer
    if (VLM.screen_margin < x) and (x < VLM.header_width - VLM.screen_margin) then

        for j=1,#game_packs do
            local y_off = (j-1)*VLM.header_y_step
            if (y >= y_off) and (y <= y_off + VLM.header_font * 1.1) then
                return game_packs[j]
            end
        end

    end
    return nil
end

function select_level_cell(n)
    game_status.level = n

    prev_sel_level_per_pack[game_status.pack] = game_status.level
end

local function select_level_if_valid(n)
    if (n >= 1) and (n <= #all_levels[game_status.pack]) then
        select_level_cell(n)
    end
end
function select_level_up()
    local n = game_status.level
    local cell = n_to_rc(n)
    n = rc_to_n(cell.r - 1, cell.c)
    select_level_if_valid(n)
end
function select_level_down()
    local n = game_status.level
    local cell = n_to_rc(n)
    n = rc_to_n(cell.r + 1, cell.c)
    select_level_if_valid(n)
end
function select_level_right()
    select_level_if_valid(game_status.level + 1)
end
function select_level_left()
    select_level_if_valid(game_status.level - 1)
end

function hit_level_cell(n)
    select_level_cell(n)

    -- only launch level if unlocked
    if not is_level_locked(game_status.pack, game_status.level) then
        play_sound("click")
        enter_game()
    end
end

function handle_tap_levelmenu(x, y)
    -- check for hitting level pack text
    local tapped_pack = xy_to_pack_levelmenu(x, y)
    if tapped_pack then
        switch_menu_pack(tapped_pack)
        draw_level_menu()
        return
    end

    -- level cell taps
    local tap_n = xy_to_n_levelmenu(x, y)
    if (tap_n ~= nil) then
        hit_level_cell(tap_n)
        return
    end

    -- settings button
    local sx = x - VLM.settings_x
    local sy = y - VLM.settings_y
    if (0 <= sx) and (sx <= VLM.settings_width) and
        (0 <= sy) and (sy <= VLM.settings_height) then
        app_state_before_menu = app_state
        app_state = APP_STATE_SETTINGS
        play_sound("click")
    end
end
