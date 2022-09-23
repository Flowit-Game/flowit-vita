-- global variables
VS = {}
VS.screen_margin   = 20
VS.cell_size       = 50
VS.space_size      = 15
VS.nx              = 0
VS.cell_font       = 16
VS.header_font     = 50
VS.header_width    = 520
VS.header_y_buffer = 40
VS.header_y_step   = 90

VS.done_x         = VS.screen_margin
VS.done_y         = 544 - 60 - VS.screen_margin
VS.done_width     = 100 -- updated in code
VS.done_height    = 60
VS.done_font      = 36
VS.done_icon_size = 32

VS.credits_x_buffer = 40
VS.credits_font     = 18

VS.credits_y        = 544 - 4*(VS.credits_font+3) - VS.screen_margin
if platform ~= PLATFORMS.DESKTOP then
    VS.credits_y        = 544 - 4*(VS.credits_font) - VS.screen_margin
end

VS.button_width     = 120
VS.button_min_height = 48
VS.button_icon_size = 20
VS.button_font      = 24
VS.label_font       = 32
VS.buttonA_x        = VS.header_width + 80
VS.buttonB_x        = VS.buttonA_x + VS.button_width + 50

settings_items = {}
-- A is option 1, B is option 2
settings_items["sound"] = {
    label = "sound",
    show_on_desktop = true,
    y_center = VS.header_y_buffer,

    A = {
        x = VS.buttonA_x, y = 0,
        width = VS.button_width, height = 0,
        msg1 = "on",
    },

    B = {
        x = VS.buttonB_x, y = 0,
        width = VS.button_width, height = 0,
        msg1 = "off",
    },
}
settings_items["confirmations"] = {
    label = "confirmations",
    show_on_desktop = true,
    y_center = VS.header_y_buffer + 1*VS.header_y_step,

    A = {
        x = VS.buttonA_x, y = 0,
        width = VS.button_width, height = 0,
        msg1 = "on",
    },

    B = {
        x = VS.buttonB_x, y = 0,
        width = VS.button_width, height = 0,
        msg1 = "off",
    },
}
settings_items["color_scheme"] = {
    label = "color_scheme",
    show_on_desktop = true,
    y_center = VS.header_y_buffer + 2*VS.header_y_step,

    A = {
        x = VS.buttonA_x, y = 0,
        width = VS.button_width, height = 0,
        msg1 = "color_scheme_1",
    },

    B = {
        x = VS.buttonB_x, y = 0,
        width = VS.button_width, height = 0,
        msg1 = "color_scheme_2",
    },
}
settings_items["buttons"] = {
    label = "xo_buttons",
    show_on_desktop = false,
    y_center = VS.header_y_buffer + 3*VS.header_y_step,

    A = {
        x = VS.buttonA_x, y = 0,
        width = VS.button_width, height = 0,
        msg1 = "yes",
        icon1 = "circle",
        msg2 = "no",
        icon2 = "cross",
    },

    B = {
        x = VS.buttonB_x, y = 0,
        width = VS.button_width, height = 0,
        msg1 = "yes",
        icon1 = "cross",
        msg2 = "no",
        icon2 = "circle",
    },
}
settings_items["reset_button"] = {
    label = "reset_button",
    show_on_desktop = false,
    y_center = VS.header_y_buffer + 4*VS.header_y_step,

    A = {
        x = VS.buttonA_x, y = 0,
        width = VS.button_width, height = 0,
        msg1 = "",
        icon1 = "triangle",
    },

    B = {
        x = VS.buttonB_x, y = 0,
        width = VS.button_width, height = 0,
        msg1 = "",
        icon1 = "start",
        icon1_size = 44
    },
}

settings_sel_item = nil

-- local functions
local function draw_done_button_and_credits()
    local text = get_i18n("back")
    local font_size = VS.done_font
    local text_w, text_h = text_dimensions(text, font_size, default_font_name)
    local done_buffer = 10

    if platform == PLATFORMS.DESKTOP then
        VS.done_icon_size = 0
    end

    VS.done_width = text_w + 3*done_buffer + VS.done_icon_size
    VS.done_height = math.max(VS.done_height, text_h + 6)

    local icon_x = VS.done_x + (VS.done_width - text_w - done_buffer - VS.done_icon_size)/2
    local text_x = icon_x + VS.done_icon_size + done_buffer
    local text_y = VS.done_y + (VS.done_height - text_h)/2
    local icon_y = VS.done_y + (VS.done_height - VS.done_icon_size)/2

    local done_img
    if SETTINGS.buttons.value == "xo" then
        done_img = misc_images["circle"]
    else
        done_img = misc_images["cross"]
    end

    draw_rect(VS.done_x, VS.done_y, VS.done_x + VS.done_width, VS.done_y + VS.done_height, "d")
    draw_text(text_x, text_y, font_size, text, "X", default_font_name)

    if platform ~= PLATFORMS.DESKTOP then
        draw_general_icon(icon_x, icon_y, icon_x + VS.done_icon_size, icon_y + VS.done_icon_size, done_img, "X")
    end

    -- draw credits
    local credits_x = VS.done_x + VS.done_width + VS.credits_x_buffer
    draw_text(credits_x, VS.credits_y, VS.credits_font, get_i18n("credits"), "d", message_font_name)
end

local function draw_button(setting_name, AB, selected)
    local item = settings_items[setting_name]
    local button = item.A
    if AB == "B" then
        button = item.B
    end

    local bg_color = "d"
    local fg_color = "d"
    if selected then
        bg_color = "b"
        fg_color = "X"
    end

    local buffer = 10

    local font_size = VS.button_font
    local text1 = get_i18n(button.msg1)
    local text2 = get_i18n(button.msg2)

    local text_w, text_h = text_dimensions(text1, font_size, message_font_name)
    if text2 then
        local text2_w, text2_h = text_dimensions(text2, font_size, message_font_name)
        text_w = math.max(text_w, text2_w)
    end


    local button_interior_h = text_h
    if text2 then
        button_interior_h = button_interior_h + buffer + text_h
    end
    button.height = math.max(2*buffer + button_interior_h, VS.button_min_height)

    button.y = math.ceil(item.y_center - button.height/2)

    if selected then
        draw_rect(button.x, button.y, button.x + button.width, button.y + button.height, bg_color)
    else
        local outline_px = 2
        draw_rect_outline(button.x + outline_px, button.y + outline_px, button.x + button.width - outline_px, button.y + button.height - outline_px, bg_color, outline_px)
    end

    -- draw text
    local icon_x
    local text_x

    local icon1_size = button.icon1_size or VS.button_icon_size

    if button.icon1 then
        icon_x = math.floor(button.x + (button.width - text_w - icon1_size - buffer)/2)
        text_x = icon_x + icon1_size + buffer
    else
        text_x = math.floor(button.x + (button.width - text_w)/2)
    end
    local text1_y = button.y + buffer

    draw_text(text_x, text1_y, font_size, text1, fg_color, message_font_name)
    if button.icon1 then
        local icon1_y = math.ceil(text1_y + (text_h - icon1_size)/2)
        if not text1 or #text1 == 0 then
            icon1_y = math.ceil(button.y + (button.height - icon1_size)/2)
            icon1_x = math.floor(button.x + (button.width - icon1_size)/2)
        end

        draw_general_icon(icon_x, icon1_y, icon_x + icon1_size, icon1_y + icon1_size, misc_images[button.icon1], fg_color)
    end

    if text2 then
        local icon2_size = button.icon2_size or VS.button_icon_size
        local text2_y = text1_y + buffer + text_h
        draw_text(text_x, text2_y, font_size, text2, fg_color, message_font_name)
        if button.icon2 then
            local icon2_y = text2_y + (text_h - icon2_size)/2
            draw_general_icon(icon_x, icon2_y, icon_x + icon2_size, icon2_y + icon2_size, misc_images[button.icon2], fg_color)
        end
    end
end

local function draw_label(setting_name)
    local item = settings_items[setting_name]
    local text = get_i18n(item.label)
    local font_size = VS.label_font

    local text_w, text_h = text_dimensions(text, font_size, default_font_name)
    local y = math.ceil(item.y_center - text_h/2)
    local x = VS.header_width - text_w

    draw_text(x, y, font_size, text, "d", default_font_name)
end

local function draw_settings_item(setting_name)
    draw_label(setting_name)

    local A_sel = 
    (setting_name == "sound" and SETTINGS.sound.value == "on")
    or (setting_name == "buttons" and SETTINGS.buttons.value == "ox")
    or (setting_name == "reset_button" and SETTINGS.reset_button.value == "triangle")
    or (setting_name == "confirmations" and SETTINGS.confirmations.value == "on")
    or (setting_name == "color_scheme" and SETTINGS.color_scheme.value == "color_scheme_1")

    draw_button(setting_name, "A", A_sel)
    draw_button(setting_name, "B", not A_sel)

    local item = settings_items[setting_name]
    item.x1 = VS.screen_margin
    item.x2 = screen_width() - VS.screen_margin

    local h = math.max(VS.header_y_step/2, math.max(item.A.height, item.B.height) + 2*0.5*VS.screen_margin)

    item.y1 = math.floor(item.y_center - h/2)
    item.y2 = math.ceil(item.y_center + h/2)

    local selected = (settings_sel_item == setting_name)
    if selected then
        draw_rect_outline(item.x1, item.y1, item.x2, item.y2, "b", 5)
    end
end

-- local functions

function settings_loop()
    set_settings_size(screen_width(), screen_height())

    draw_settings()
end

function set_settings_size(width, height)

    local width_orig = width
    local height_orig = height

    width = width - VS.screen_margin - VS.header_width
    height = height - 2*VS.screen_margin

    -- TODO: adjust layout for different screen sizes
    VS.done_y         = screen_height() - 60 - VS.screen_margin

end

function draw_settings()
    init_draw_phase()

    -- draw settings items
    draw_settings_item("sound")
    draw_settings_item("confirmations")
    draw_settings_item("color_scheme")

    if (platform ~= PLATFORMS.DESKTOP) or (settings_items["buttons"].show_on_desktop) then
        draw_settings_item("buttons")
    end
    if (platform ~= PLATFORMS.DESKTOP) or (settings_items["reset_button"].show_on_desktop) then
        draw_settings_item("reset_button")
    end

    -- draw done button & credits
    draw_done_button_and_credits()

    end_draw_phase()
end

local function xy_in_xywh(x, y, x1, y1, w, h)
    return ((x1 <= x) and (x <= x1 + w) and
        (y1 <= y) and (y <= y1 + h))
end
local function xy_in_xyxy(x, y, x1, y1, x2, y2)
    return ((x1 <= x) and (x <= x2) and
        (y1 <= y) and (y <= y2))
end

function handle_tap_settings(x, y)

    -- select setting (NOT button, so we don't return)
    settings_sel_item = nil
    for setting_name, setting_item in pairs(settings_items) do
        if (platform ~= PLATFORMS.DESKTOP) or (setting_item.show_on_desktop) then
            if xy_in_xyxy(x, y,
                setting_item.x1,
                setting_item.y1,
                setting_item.x2,
                setting_item.y2) then

                settings_sel_item = setting_name
                break
            end
        end
    end

    -- done button
    local sx = x - VS.done_x
    local sy = y - VS.done_y
    if xy_in_xywh(sx, sy, 0, 0, VS.done_width, VS.done_height) then

        if app_state_before_menu == APP_STATE_IN_GAME then
            app_state = APP_STATE_IN_GAME
        else
            app_state = APP_STATE_LEVEL_MENU
        end
        save_settings()
        play_sound("click")
        return
    end

    if xy_in_xywh(x, y,
        settings_items["sound"].A.x,
        settings_items["sound"].A.y,
        settings_items["sound"].A.width,
        settings_items["sound"].A.height) then

        SETTINGS.sound.value = "on"
        play_sound("click")

        return
    end
    if xy_in_xywh(x, y,
        settings_items["sound"].B.x,
        settings_items["sound"].B.y,
        settings_items["sound"].B.width,
        settings_items["sound"].B.height) then

        SETTINGS.sound.value = "off"
        play_sound("click")

        return
    end
    if xy_in_xywh(x, y,
        settings_items["confirmations"].A.x,
        settings_items["confirmations"].A.y,
        settings_items["confirmations"].A.width,
        settings_items["confirmations"].A.height) then

        SETTINGS.confirmations.value = "on"
        play_sound("click")

        return
    end
    if xy_in_xywh(x, y,
        settings_items["confirmations"].B.x,
        settings_items["confirmations"].B.y,
        settings_items["confirmations"].B.width,
        settings_items["confirmations"].B.height) then

        SETTINGS.confirmations.value = "off"
        play_sound("click")

        return
    end
    if xy_in_xywh(x, y,
        settings_items["color_scheme"].A.x,
        settings_items["color_scheme"].A.y,
        settings_items["color_scheme"].A.width,
        settings_items["color_scheme"].A.height) then

        SETTINGS.color_scheme.value = "color_scheme_1"
        colors = colors_1
        play_sound("click")

        return
    end
    if xy_in_xywh(x, y,
        settings_items["color_scheme"].B.x,
        settings_items["color_scheme"].B.y,
        settings_items["color_scheme"].B.width,
        settings_items["color_scheme"].B.height) then

        SETTINGS.color_scheme.value = "color_scheme_2"
        colors = colors_2
        play_sound("click")

        return
    end

    if (platform ~= PLATFORMS.DESKTOP) or (settings_items["buttons"].show_on_desktop) then
        if xy_in_xywh(x, y,
            settings_items["buttons"].A.x,
            settings_items["buttons"].A.y,
            settings_items["buttons"].A.width,
            settings_items["buttons"].A.height) then

            SETTINGS.buttons.value = "ox"
            play_sound("click")

            return
        end
        if xy_in_xywh(x, y,
            settings_items["buttons"].B.x,
            settings_items["buttons"].B.y,
            settings_items["buttons"].B.width,
            settings_items["buttons"].B.height) then

            SETTINGS.buttons.value = "xo"
            play_sound("click")

            return
        end
    end
    if (platform ~= PLATFORMS.DESKTOP) or (settings_items["reset_button"].show_on_desktop) then
        if xy_in_xywh(x, y,
            settings_items["reset_button"].A.x,
            settings_items["reset_button"].A.y,
            settings_items["reset_button"].A.width,
            settings_items["reset_button"].A.height) then

            SETTINGS.reset_button.value = "triangle"
            play_sound("click")

            return
        end
        if xy_in_xywh(x, y,
            settings_items["reset_button"].B.x,
            settings_items["reset_button"].B.y,
            settings_items["reset_button"].B.width,
            settings_items["reset_button"].B.height) then

            SETTINGS.reset_button.value = "start"
            play_sound("click")

            return
        end
    end

end
