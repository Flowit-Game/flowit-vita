-- dialogs:
-- 1) win dialog
-- 2) confirmation dialogs
-- 2a) return to level menu?
-- 2b) proceed to next level?
-- 2c) return to prev level?
-- 2d) reset game?

DIALOG = {}
DIALOG.LEVEL_MENU    = 0
DIALOG.NEXT_LEVEL    = 1
DIALOG.PREV_LEVEL    = 2
DIALOG.RESET_GAME    = 3
DIALOG.WIN           = 100
DIALOG.WIN_HIGHSCORE = 101

VD = {}
-- constant
VD.dialog_outline = 2
VD.button_height = 40
VD.button_gap = 10
VD.button_icon_size = 20
VD.button_icon_gap = 5
VD.font_button = 24
VD.font_msg1 = 36
VD.font_msg2 = 24

-- variable (must be set in dialog functions
VD.dialog_width = nil
VD.dialog_height = nil
VD.dialog_x = nil
VD.dialog_y = nil

VD.button_width = nil
VD.button_y = nil
VD.button_no_x = nil
VD.button_yes_x = nil

local function draw_confirmation_dialog()
    VD.dialog_width = 600

    local dialog_height_base = 100
    VD.dialog_height = dialog_height_base + VD.button_height + VD.button_gap*2


    local width = screen_width()
    local height = screen_height()

    VD.dialog_x = (width - VD.dialog_width)/2
    VD.dialog_y = (height - VD.dialog_height)/2

    VD.button_width = math.floor(VD.dialog_width - 3*VD.button_gap)/2
    VD.button_y = VD.dialog_y + VD.dialog_height - VD.button_gap - VD.button_height
    VD.button_no_x = VD.dialog_x + VD.button_gap
    VD.button_yes_x = VD.dialog_x + 2*VD.button_gap + VD.button_width

    local msg1 = nil
    local msg2 = nil
    if cur_dialog == DIALOG.LEVEL_MENU then
        msg1 = get_i18n("conf_levelmenu")
        msg2 = get_i18n("progresslost")
    elseif cur_dialog == DIALOG.NEXT_LEVEL then
        msg1 = get_i18n("conf_nextlevel")
        msg2 = get_i18n("progresslost")
    elseif cur_dialog == DIALOG.PREV_LEVEL then
        msg1 = get_i18n("conf_prevlevel")
        msg2 = get_i18n("progresslost")
    elseif cur_dialog == DIALOG.RESET_GAME then
        msg1 = get_i18n("conf_reset")
    else
        assert(false)
    end

    -- shade background
    draw_rect(0, 0, width, height, "5")

    draw_rect(VD.dialog_x - VD.dialog_outline, VD.dialog_y - VD.dialog_outline, VD.dialog_x + VD.dialog_width + VD.dialog_outline, VD.dialog_y + VD.dialog_height + VD.dialog_outline, "X")
    draw_rect(VD.dialog_x, VD.dialog_y, VD.dialog_x + VD.dialog_width, VD.dialog_y + VD.dialog_height, "t")

    -- set up message text

    local font_big = VD.font_msg1
    local font_small = VD.font_msg2

    local tw1, th1 = text_dimensions(msg1, font_big, message_font_name)
    local tw2 = 0
    local th2 = 0
    local tgap = 0
    if msg2 then
        tw2, th2 = text_dimensions(msg2, font_small, message_font_name)
        tgap = math.ceil(th2*0.1)
    end

    local th = th1 + tgap + th2

    local tx1 = math.max(10, (VD.dialog_width - tw1)/2)
    local tx2 = math.max(10, (VD.dialog_width - tw2)/2)
    local ty1 = math.max(10, (dialog_height_base - th)/2)
    local ty2 = ty1 + th1 + tgap

    draw_text(VD.dialog_x + tx1, VD.dialog_y + ty1, font_big, msg1, "X", message_font_name)
    if msg2 then
        draw_text(VD.dialog_x + tx2, VD.dialog_y + ty2, font_small, msg2, "X", message_font_name)
    end

    -- set up buttons
    if platform == PLATFORMS.DESKTOP then
        VD.button_icon_size = 0
        VD.button_icon_gap = 0
    end

    local no_w, no_h = text_dimensions(get_i18n("no"), VD.font_button, message_font_name)
    local yes_w, yes_h = text_dimensions(get_i18n("yes"), VD.font_button, message_font_name)

    local no_icon_x = VD.button_no_x + (VD.button_width - VD.button_icon_size - VD.button_icon_gap - no_w)/2
    local no_x = no_icon_x + VD.button_icon_size + VD.button_icon_gap
    local no_icon_y = VD.button_y + (VD.button_height - VD.button_icon_size)/2
    local no_y = VD.button_y + (VD.button_height - no_h)/2

    local yes_icon_x = VD.button_yes_x + (VD.button_width - VD.button_icon_size - VD.button_icon_gap - yes_w)/2
    local yes_x = yes_icon_x + VD.button_icon_size + VD.button_icon_gap
    local yes_icon_y = VD.button_y + (VD.button_height - VD.button_icon_size)/2
    local yes_y = VD.button_y + (VD.button_height - yes_h)/2

    local yes_img
    local no_img
    if SETTINGS.buttons.value == "xo" then
        yes_img = misc_images["cross"]
        no_img  = misc_images["circle"]
    else
        yes_img = misc_images["circle"]
        no_img  = misc_images["cross"]
    end


    draw_rect(VD.button_no_x, VD.button_y, VD.button_no_x + VD.button_width, VD.button_y + VD.button_height, "X")
    draw_text(no_x, no_y, VD.font_button, get_i18n("no"), "t", message_font_name)
    if platform ~= PLATFORMS.DESKTOP then
        draw_general_icon(no_icon_x, no_icon_y, no_icon_x + VD.button_icon_size, no_icon_y + VD.button_icon_size, no_img, "t")
    end

    draw_rect(VD.button_yes_x, VD.button_y, VD.button_yes_x + VD.button_width, VD.button_y + VD.button_height, "X")
    draw_text(yes_x, yes_y, VD.font_button, get_i18n("yes"), "t", message_font_name)
    if platform ~= PLATFORMS.DESKTOP then
        draw_general_icon(yes_icon_x, yes_icon_y, yes_icon_x + VD.button_icon_size, yes_icon_y + VD.button_icon_size, yes_img, "t")
    end
end

function xy_to_dialog_control(x, y)
    -- If the user clicks outside the dialog, return "no"
    -- If the user clicks inside the dialog (not on a button), return nil
    -- If the user clicks the "yes" button, return "yes"
    -- If the user clicks the "no" button, return "no"
    local click_type = "no"

    if (VD.dialog_x <= x) and (x <= VD.dialog_x + VD.dialog_width) and
        (VD.dialog_y <= y) and (y <= VD.dialog_y + VD.dialog_height) then
        click_type = nil
    end
    if (VD.button_no_x <= x) and (x <= VD.button_no_x + VD.button_width) and
        (VD.button_y <= y) and (y <= VD.button_y + VD.button_height) then
        click_type = "no"
    end
    if (VD.button_yes_x <= x) and (x <= VD.button_yes_x + VD.button_width) and
        (VD.button_y <= y) and (y <= VD.button_y + VD.button_height) then
        click_type = "yes"
    end

    return click_type
end

function dismiss_dialog()
    cur_dialog = nil
    is_showing_dialog = false
end

local function draw_win_dialog(high_score)
    VD.dialog_width = 500
    VD.dialog_height = 100
    
    local width = screen_width()
    local height = screen_height()

    VD.dialog_x = (width - VD.dialog_width)/2
    VD.dialog_y = (height - VD.dialog_height)/2

    local msg = get_i18n("level complete")
    if high_score then
        msg = get_i18n("high score!")
    end

    -- shade background
    draw_rect(0, 0, width, height, "5")

    draw_rect(VD.dialog_x - VD.dialog_outline, VD.dialog_y - VD.dialog_outline, VD.dialog_x + VD.dialog_width + VD.dialog_outline, VD.dialog_y + VD.dialog_height + VD.dialog_outline, "X")
    draw_rect(VD.dialog_x, VD.dialog_y, VD.dialog_x + VD.dialog_width, VD.dialog_y + VD.dialog_height, "b")

    local font_big = VD.font_msg1
    local tw, th = text_dimensions(msg, font_big, default_font_name)

    local tx = math.max(10, (VD.dialog_width - tw)/2)
    local ty = math.max(10, (VD.dialog_height - th)/2)

    draw_text(VD.dialog_x + tx, VD.dialog_y + ty, font_big, msg, "X", default_font_name)
end


------------------ GLOBAL FUNCTIONS ----------------

function draw_dialog()
    if is_showing_dialog then
        if not cur_dialog then
            is_showing_dialog = false
            return
        end

        if cur_dialog == DIALOG.WIN then
            draw_win_dialog(false)
        elseif cur_dialog == DIALOG.WIN_HIGHSCORE then
            draw_win_dialog(true)
        elseif cur_dialog == DIALOG.LEVEL_MENU then
            draw_confirmation_dialog()
        elseif cur_dialog == DIALOG.NEXT_LEVEL then
            draw_confirmation_dialog()
        elseif cur_dialog == DIALOG.PREV_LEVEL then
            draw_confirmation_dialog()
        elseif cur_dialog == DIALOG.RESET_GAME then
            draw_confirmation_dialog()
        else
            -- invalid dialog
            assert(false)
        end

        
    end
end

function show_dialog(dialog)
    is_showing_dialog = true
    cur_dialog = dialog

    if not dialog then
        is_showing_dialog = false
    end
end
