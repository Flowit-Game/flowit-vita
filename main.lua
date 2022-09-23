-- main lua file which imports libraries and executes the game
-- This is the desktop version, which loads love libraries instead of vita libraries

function loadlib(str)
    require("lib/" .. str)
end

-- desktop-specific libraries
loadlib("io_desktop")
loadlib("graphics_desktop")
locale = require("lib/locale")

-- globals
loadlib("globals")
loadlib("version")
platform = PLATFORMS.DESKTOP

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


-- set language

locale_get_success, lang_code = pcall(locale.get)
if (not locale_get_success) then
    lang_code = "en"
end

local valid_lang_codes = {"en", "zh_t", "zh_s", "ja"}
if (lang_code == "zh_TW") or (lang_code == "zh_HK") or (lang_code == "zh_HK") or (lang_code == "zh_CHT") then
    lang_code = "zh_t"
elseif (string.sub(lang_code, 1, 2) == "zh") then
    lang_code = "zh_s"
else
    lang_code = string.sub(lang_code, 1, 2)
end

local lang_code_is_valid = false
for _, v_lang_code in pairs(valid_lang_codes) do
    if lang_code == v_lang_code then
        lang_code_is_valid = true
        break
    end
end
if (not lang_code_is_valid) then
    lang_code = "en"
end

default_font_name = "good-times-rg.ttf"
number_font_name = "good-times-rg.ttf"
message_font_name = "LiberationSans-Regular.ttf" -- readable font for dialog text

if (lang_code == "ja") or (lang_code == "ko") or (lang_code == "zh_t") or (lang_code == "zh_s") then
    default_font_name = "SourceHanSansHW-VF.ttf"
    message_font_name = "SourceHanSansHW-VF.ttf"
end
load_fonts()

-- precompute some message sizes to avoid lag on showing dialogs
text_dimensions(get_i18n("no"), VD.font_button, message_font_name)
text_dimensions(get_i18n("yes"), VD.font_button, message_font_name)

-- load settings
load_settings()

-- set colorscheme
colors = colors_1
if SETTINGS.color_scheme.value == "color_scheme_2" then
    colors = colors_2
end


all_levels = load_all_levels()
high_scores_data = load_high_scores()

-- intialize game_status
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

-- love loop and draw
function love.load()
    -- set window to same size as on vita
    success = love.window.setMode( 960, 544 )

    love.graphics.setBackgroundColor(colors["X"])

    -- load images
    mod_images = load_mod_images()
    control_images = load_control_images()
    misc_images = load_misc_images()

    -- load sounds
    sounds = load_sounds()

    cell_animation_timer = 0
end
function love.resize(w, h)
end
function love.draw()

    if app_state == APP_STATE_IN_GAME then
        if not tridata then
            tridata = level_to_tridata(all_levels, game_status.pack, game_status.level)
        end
        game_loop(tridata)
    elseif app_state == APP_STATE_LEVEL_MENU then
        level_menu_loop()
    elseif app_state == APP_STATE_SETTINGS then
        settings_loop()
    end
end

-- step animations
function love.update(dt)


    if app_state == APP_STATE_IN_GAME then
        -- cell animations
        cell_animation_timer = cell_animation_timer + dt
        if cell_animation_timer >= 0.05 then
            cell_animation_timer = 0

            if is_animating_fill then
                step_cell_animation(tridata)
            end
        end
    end

end
function start_cell_animation(tridata)
    cell_animation_timer = 0
    step_cell_animation(tridata)
end

function love.mousereleased(x, y, button, istouch, presses)
    if button > 1 then
        return nil
    end

    if app_state == APP_STATE_IN_GAME then
        handle_tap_ingame(tridata, x, y)
    elseif app_state == APP_STATE_LEVEL_MENU then
        handle_tap_levelmenu(x, y)
    elseif app_state == APP_STATE_SETTINGS then
        handle_tap_settings(x, y)
    end
end
