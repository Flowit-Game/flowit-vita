BUTTON_NONE            = -1
BUTTON_SINGLE_UP       = 0
BUTTON_SINGLE_DOWN     = 1
BUTTON_SINGLE_LEFT     = 2
BUTTON_SINGLE_RIGHT    = 3
BUTTON_SINGLE_CIRCLE   = 4
BUTTON_SINGLE_CROSS    = 5
BUTTON_SINGLE_TRIANGLE = 6
BUTTON_SINGLE_SQUARE   = 7
BUTTON_SINGLE_LTRIGGER = 8
BUTTON_SINGLE_RTRIGGER = 9
BUTTON_SINGLE_SELECT   = 10
BUTTON_SINGLE_START    = 11
BUTTON_HELD_UP         = 12
BUTTON_HELD_DOWN       = 13
BUTTON_HELD_LEFT       = 14
BUTTON_HELD_RIGHT      = 15
BUTTON_HELD_CIRCLE     = 16
BUTTON_HELD_CROSS      = 17
BUTTON_HELD_TRIANGLE   = 18
BUTTON_HELD_SQUARE     = 19
BUTTON_HELD_LTRIGGER   = 20
BUTTON_HELD_RTRIGGER   = 21
BUTTON_HELD_SELECT     = 22
BUTTON_HELD_START      = 23

-- count how long the same button is held down
--
local button_hold_timer = Timer.new()
local button_hold_ms_limit = 250 -- number of ms after which to register a 2nd button press


function getControl(pad, oldpad)


    -- Controls checking
    if Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP) then
        Timer.reset(button_hold_timer)
        return BUTTON_SINGLE_UP
    elseif Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN) then
        Timer.reset(button_hold_timer)
        return BUTTON_SINGLE_DOWN
    elseif Controls.check(pad, SCE_CTRL_LEFT) and not Controls.check(oldpad, SCE_CTRL_LEFT) then
        Timer.reset(button_hold_timer)
        return BUTTON_SINGLE_LEFT
    elseif Controls.check(pad, SCE_CTRL_RIGHT) and not Controls.check(oldpad, SCE_CTRL_RIGHT) then
        Timer.reset(button_hold_timer)
        return BUTTON_SINGLE_RIGHT
    elseif Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
        Timer.reset(button_hold_timer)
        if SETTINGS.buttons.value == "xo" then
            return BUTTON_SINGLE_CIRCLE
        else
            return BUTTON_SINGLE_CROSS
        end
    elseif Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE) then
        Timer.reset(button_hold_timer)
        if SETTINGS.buttons.value == "xo" then
            return BUTTON_SINGLE_CROSS
        else
            return BUTTON_SINGLE_CIRCLE
        end
    elseif Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE) then
        Timer.reset(button_hold_timer)
        return BUTTON_SINGLE_TRIANGLE
    elseif Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE) then
        Timer.reset(button_hold_timer)
        return BUTTON_SINGLE_SQUARE
    elseif Controls.check(pad, SCE_CTRL_LTRIGGER) and not Controls.check(oldpad, SCE_CTRL_LTRIGGER) then
        Timer.reset(button_hold_timer)
        return BUTTON_SINGLE_LTRIGGER
    elseif Controls.check(pad, SCE_CTRL_RTRIGGER) and not Controls.check(oldpad, SCE_CTRL_RTRIGGER) then
        Timer.reset(button_hold_timer)
        return BUTTON_SINGLE_RTRIGGER
    elseif Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldpad, SCE_CTRL_SELECT) then
        Timer.reset(button_hold_timer)
        return BUTTON_SINGLE_SELECT
    elseif Controls.check(pad, SCE_CTRL_START) and not Controls.check(oldpad, SCE_CTRL_START) then
        Timer.reset(button_hold_timer)
        return BUTTON_SINGLE_START
    end

    -- repeated hold
    if Controls.check(pad, SCE_CTRL_UP) and Controls.check(oldpad, SCE_CTRL_UP) then
        if Timer.getTime(button_hold_timer) > button_hold_ms_limit then
            Timer.reset(button_hold_timer)
            return BUTTON_HELD_UP
        end
    elseif Controls.check(pad, SCE_CTRL_DOWN) and Controls.check(oldpad, SCE_CTRL_DOWN) then
        if Timer.getTime(button_hold_timer) > button_hold_ms_limit then
            Timer.reset(button_hold_timer)
            return BUTTON_HELD_DOWN
        end
    elseif Controls.check(pad, SCE_CTRL_LEFT) and Controls.check(oldpad, SCE_CTRL_LEFT) then
        if Timer.getTime(button_hold_timer) > button_hold_ms_limit then
            Timer.reset(button_hold_timer)
            return BUTTON_HELD_LEFT
        end
    elseif Controls.check(pad, SCE_CTRL_RIGHT) and Controls.check(oldpad, SCE_CTRL_RIGHT) then
        if Timer.getTime(button_hold_timer) > button_hold_ms_limit then
            Timer.reset(button_hold_timer)
            return BUTTON_HELD_RIGHT
        end
    elseif Controls.check(pad, SCE_CTRL_LTRIGGER) and Controls.check(oldpad, SCE_CTRL_LTRIGGER) then
        if Timer.getTime(button_hold_timer) > button_hold_ms_limit then
            Timer.reset(button_hold_timer)
            return BUTTON_HELD_LTRIGGER
        end
    elseif Controls.check(pad, SCE_CTRL_RTRIGGER) and Controls.check(oldpad, SCE_CTRL_RTRIGGER) then
        if Timer.getTime(button_hold_timer) > button_hold_ms_limit then
            Timer.reset(button_hold_timer)
            return BUTTON_HELD_RTRIGGER
        end
    else
        Timer.reset(button_hold_timer)
    end


    return BUTTON_NONE
end

function getTouchControl(oldtouch)
    local x, y, x2, y2 = Controls.readTouch()

    -- ignore multi-touches
    if x2 ~= nil then
        return {x = nil, y = nil, release=false}
    end

    local touch = {x = x, y = y, release=false}

    -- if we don't detect any touches now but we did in the last frame,
    -- then return the previous coordinates and mark as a release
    if x == nil then
        if (oldtouch.x ~= nil) and (not oldtouch.release) then
            touch = {x = oldtouch.x, y = oldtouch.y, release=true}
        end
    end

    return touch
end
