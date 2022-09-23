-- loadlib from Noboru ( https://github.com/Creckeryop/NOBORU/ )
function loadlib(str)
	dofile("app0:/assets/lib/" .. str .. ".lua")
end

-- vita-specific libraries
loadlib("io_vita")
loadlib("graphics_vita")
loadlib("controls_vita")

-- globals
loadlib("globals")
loadlib("version")
platform = PLATFORMS.VITA

-- other libraries
loadlib("util")
loadlib("translation")

loadlib("dialogs")
loadlib("settings")

loadlib("level_parser")
loadlib("high_scores")
loadlib("game_logic")
loadlib("game_drawing")
loadlib("game_view")

loadlib("level_menu")
loadlib("settings_view")


-- show splash screen while the rest loads
init_draw_phase()
splash_img = Graphics.loadImage("app0:/assets/images/splash.png")
Graphics.drawImage(0, 0, splash_img)
end_draw_phase()



-- get language code
lang_internal = System.getLanguage()
if lang_internal == 0  then
    lang_code = "ja"
elseif lang_internal == 10 then
    lang_code = "zh_t"
elseif lang_internal == 11 then
    lang_code = "zh_s"
--[[
elseif lang_internal == 9 then
    lang_code = "ko"
elseif lang_internal == 2 then
    lang_code = "fr"
elseif lang_internal == 3 then
    lang_code = "es"
elseif lang_internal == 4 then
    lang_code = "de"
elseif lang_internal == 8 then
    lang_code = "ru"
]]--
else
    lang_code = "en"
end

default_font_name = "good-times-rg.ttf"
number_font_name = "good-times-rg.ttf"
message_font_name = "LiberationSans-Regular.ttf" -- readable font for dialog text

if (lang_code == "ja") or (lang_code == "ko") or (lang_code == "zh_t") or (lang_code == "zh_s") then
    default_font_name = "SourceHanSansHW-VF.ttf"
    message_font_name = "SourceHanSansHW-VF.ttf"
    SETTINGS.buttons.default = "ox"
    SETTINGS.buttons.value = "ox"
end
load_fonts()

-- precompute some message sizes to avoid lag on showing dialogs
text_dimensions(get_i18n("no"),   VD.font_button, message_font_name)
text_dimensions(get_i18n("yes"),  VD.font_button, message_font_name)
text_dimensions(get_i18n("back"), VG.font_big, default_font_name)

text_dimensions(get_i18n("conf_levelmenu"), VD.font_msg1, message_font_name)
text_dimensions(get_i18n("conf_nextlevel"), VD.font_msg1, message_font_name)
text_dimensions(get_i18n("conf_prevlevel"), VD.font_msg1, message_font_name)
text_dimensions(get_i18n("conf_reset"),     VD.font_msg1, message_font_name)
--text_dimensions(get_i18n("high score!"),    VD.font_msg1, default_font_name)
--text_dimensions(get_i18n("level complete"), VD.font_msg1, default_font_name)
text_dimensions(get_i18n("xo_buttons"), VS.header_font, default_font_name)
text_dimensions(get_i18n("confirmations"), VS.header_font, default_font_name)
text_dimensions(get_i18n("color_scheme"), VS.header_font, default_font_name)

-- load settings
load_settings()

-- set colorscheme
colors = colors_1
if SETTINGS.color_scheme.value == "color_scheme_2" then
    colors = colors_2
end


-- load images
mod_images = load_mod_images()
control_images = load_control_images()
misc_images = load_misc_images()

-- load sounds
sounds = load_sounds()

all_levels = load_all_levels()
high_scores_data = load_high_scores()

touch_enabled = true

game_status.pack = game_packs[1]
game_status.level = 1

app_state = APP_STATE_LEVEL_MENU
app_state_before_menu = app_state


function enter_game()
    is_game_over = false
    tridata = level_to_tridata(all_levels, game_status.pack, game_status.level)
    reset_game(tridata)
    app_state = APP_STATE_IN_GAME
end


cell_animation_timer = Timer.new()
cell_animation_ms = 50 -- number of ms for each frame
function start_cell_animation(tridata)
    Timer.reset(cell_animation_timer)
    step_cell_animation(tridata)
end

notouch_timer = Timer.new()
notouch_ms = 100 -- number of ms to disable touch after hitting a button
function set_notouch_timer(tridata)
    touch_enabled = false
    Timer.reset(notouch_timer)
end

-- Initializing oldpad variable
oldpad = SCE_CTRL_CROSS
oldtouch = {x = nil, y = nil, release=false}


-- Main loop
while true do


    -- touch disabling timer
    if Timer.getTime(notouch_timer) > notouch_ms then
        touch_enabled = true
    end

    pad = Controls.read()
    button = getControl(pad, oldpad)
    touch = getTouchControl(oldtouch)

    -- Saving old controls scheme
    oldpad = pad
    oldtouch = touch


    if app_state == APP_STATE_IN_GAME then
        if not tridata then
            tridata = level_to_tridata(all_levels, game_status.pack, game_status.level)
        end
        game_loop(tridata)

        if not is_animating_fill then
            -- controls
            if (touch.x ~= nil and touch.y ~= nil and touch.release) then
                if touch_enabled then
                    handle_tap_ingame(tridata, touch.x, touch.y)
                    set_notouch_timer()
                end
            else

                if not is_showing_dialog then
                    if (button == BUTTON_SINGLE_LTRIGGER or button == BUTTON_HELD_LTRIGGER) then
                        if get_prev_unlocked_level(all_levels, game_status.pack, game_status.level) then
                            if (game_status.steps > 0) and (SETTINGS.confirmations.value ~= "off") then
                                show_dialog(DIALOG.PREV_LEVEL)
                            else
                                go_to_prev_level(tridata)
                            end
                        end
                    elseif (button == BUTTON_SINGLE_RTRIGGER or button == BUTTON_HELD_RTRIGGER) then
                        if get_next_unlocked_level(all_levels, game_status.pack, game_status.level) then
                            if (game_status.steps > 0) and (SETTINGS.confirmations.value ~= "off") then
                                show_dialog(DIALOG.NEXT_LEVEL)
                            else
                                go_to_next_level(tridata)
                            end
                        end
                    elseif (button == BUTTON_SINGLE_TRIANGLE) then
                        if SETTINGS.reset_button.value == "triangle" then
                            if (game_status.steps > 0) and (SETTINGS.confirmations.value ~= "off") then
                                show_dialog(DIALOG.RESET_GAME)
                            else
                                reset_game(tridata)
                            end
                        end
                    elseif (button == BUTTON_SINGLE_CROSS) then
                        if (game_status.steps > 0) and (SETTINGS.confirmations.value ~= "off") then
                            show_dialog(DIALOG.LEVEL_MENU)
                        else
                            --reset_game(tridata)
                            app_state = APP_STATE_LEVEL_MENU
                        end
                    elseif (button == BUTTON_SINGLE_SELECT) then
                        app_state_before_menu = app_state
                        app_state = APP_STATE_SETTINGS
                    elseif (button == BUTTON_SINGLE_START) then
                        if SETTINGS.reset_button.value == "start" then
                            if (game_status.steps > 0) and (SETTINGS.confirmations.value ~= "off") then
                                show_dialog(DIALOG.RESET_GAME)
                            else
                                reset_game(tridata)
                            end
                        end
                    end
                elseif (cur_dialog == DIALOG.WIN) or (cur_dialog == DIALOG.WIN_HIGHSCORE) then
                    if (button == BUTTON_SINGLE_CIRCLE) or (button == BUTTON_SINGLE_CROSS) then
                        dismiss_win_dialog()
                    end
                elseif (cur_dialog ~= nil) then
                    if button == BUTTON_SINGLE_CROSS then
                        dismiss_dialog()
                    elseif button == BUTTON_SINGLE_CIRCLE then
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

        end

        -- cell animation
        if Timer.getTime(cell_animation_timer) > cell_animation_ms then
            Timer.reset(cell_animation_timer)
            if is_animating_fill then
                step_cell_animation(tridata)
            end
        end

    elseif app_state == APP_STATE_LEVEL_MENU then
        level_menu_loop()
        if (touch.x ~= nil and touch.y ~= nil and touch.release) then
            if touch_enabled then
                handle_tap_levelmenu(touch.x, touch.y)
                set_notouch_timer()
            end
        else
            if (button == BUTTON_SINGLE_LTRIGGER or button == BUTTON_HELD_LTRIGGER) then
                prev_menu_pack()
            elseif (button == BUTTON_SINGLE_RTRIGGER or button == BUTTON_HELD_RTRIGGER) then
                next_menu_pack()
            elseif (button == BUTTON_SINGLE_CIRCLE) then
                hit_level_cell(game_status.level)
            elseif (button == BUTTON_SINGLE_SELECT) then
                app_state_before_menu = app_state
                app_state = APP_STATE_SETTINGS
            elseif (button == BUTTON_SINGLE_RIGHT or button == BUTTON_HELD_RIGHT) then
                select_level_right()
            elseif (button == BUTTON_SINGLE_LEFT or button == BUTTON_HELD_LEFT) then
                select_level_left()
            elseif (button == BUTTON_SINGLE_UP or button == BUTTON_HELD_UP) then
                select_level_up()
            elseif (button == BUTTON_SINGLE_DOWN or button == BUTTON_HELD_DOWN) then
                select_level_down()
            end
        end
    elseif app_state == APP_STATE_SETTINGS then
        settings_loop()
        if (touch.x ~= nil and touch.y ~= nil and touch.release) then
            if touch_enabled then
                handle_tap_settings(touch.x, touch.y)
                set_notouch_timer()
            end
        else
            if (button == BUTTON_SINGLE_LTRIGGER or button == BUTTON_HELD_LTRIGGER or button == BUTTON_SINGLE_UP or button == BUTTON_HELD_UP) then
                if settings_sel_item == nil then
                    settings_sel_item = "reset_button"
                elseif settings_sel_item == "reset_button" then
                    settings_sel_item = "buttons"
                elseif settings_sel_item == "buttons" then
                    settings_sel_item = "color_scheme"
                elseif settings_sel_item == "color_scheme" then
                    settings_sel_item = "confirmations"
                elseif settings_sel_item == "confirmations" then
                    settings_sel_item = "sound"
                end
            elseif (button == BUTTON_SINGLE_RTRIGGER or button == BUTTON_HELD_RTRIGGER or button == BUTTON_SINGLE_DOWN or button == BUTTON_HELD_DOWN) then
                if settings_sel_item == nil then
                    settings_sel_item = "sound"
                elseif settings_sel_item == "sound" then
                    settings_sel_item = "confirmations"
                elseif settings_sel_item == "confirmations" then
                    settings_sel_item = "color_scheme"
                elseif settings_sel_item == "color_scheme" then
                    settings_sel_item = "buttons"
                elseif settings_sel_item == "buttons" then
                    settings_sel_item = "reset_button"
                end
            --elseif (button == BUTTON_SINGLE_CIRCLE) then
            elseif (button == BUTTON_SINGLE_CROSS) then
                if app_state_before_menu == APP_STATE_IN_GAME then
                    app_state = APP_STATE_IN_GAME
                else
                    app_state = APP_STATE_LEVEL_MENU
                end
                save_settings()
            elseif (button == BUTTON_SINGLE_RIGHT or button == BUTTON_HELD_RIGHT) then
                if settings_sel_item == "sound" then
                    SETTINGS.sound.value = "off"
                    play_sound("click")
                elseif settings_sel_item == "buttons" then
                    SETTINGS.buttons.value = "xo"
                    play_sound("click")
                elseif settings_sel_item == "reset_button" then
                    SETTINGS.reset_button.value = "start"
                    play_sound("click")
                elseif settings_sel_item == "confirmations" then
                    SETTINGS.confirmations.value = "off"
                    play_sound("click")
                elseif settings_sel_item == "color_scheme" then
                    SETTINGS.color_scheme.value = "color_scheme_2"
                    colors = colors_2;
                    play_sound("click")
                end
            elseif (button == BUTTON_SINGLE_LEFT or button == BUTTON_HELD_LEFT) then
                if settings_sel_item == "sound" then
                    SETTINGS.sound.value = "on"
                    play_sound("click")
                elseif settings_sel_item == "buttons" then
                    SETTINGS.buttons.value = "ox"
                    play_sound("click")
                elseif settings_sel_item == "reset_button" then
                    SETTINGS.reset_button.value = "triangle"
                    play_sound("click")
                elseif settings_sel_item == "confirmations" then
                    SETTINGS.confirmations.value = "on"
                    play_sound("click")
                elseif settings_sel_item == "color_scheme" then
                    SETTINGS.color_scheme.value = "color_scheme_1"
                    colors = colors_1;
                    play_sound("click")
                end
            end
        end
    else
    end
end
