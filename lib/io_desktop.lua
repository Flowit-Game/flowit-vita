-- file reading operations. This will change on Vita.

-- love automatically puts these in the save directory
HIGH_SCORES_FILE = "high_scores.txt"
SETTINGS_FILE = "settings.txt"

level_pack_files = {
    ["easy"]   = "levels/levelsEasy.xml",
    ["medium"] = "levels/levelsMedium.xml",
    ["hard"]   = "levels/levelsHard.xml",
}


function read_file_to_string(file)
    return love.filesystem.read(file)
end

function read_file_to_table_stripped(file)
    local lines = {}
    for line in love.filesystem.lines(file) do
        lines[#lines+1] = strip(line)
    end
    return lines
end

function write_string_to_file(file, str)
    love.filesystem.write(file, str)
end

function file_exists(file)
    if love.filesystem.getInfo(file) then
        return true
    else
        return false
    end
end

-- image loading
function load_mod_images()
    local mod_images = {}
    mod_images["B"] = love.graphics.newImage("images/modifier_bomb.png")
    mod_images["F"] = love.graphics.newImage("images/modifier_circle.png")
    mod_images["U"] = love.graphics.newImage("images/modifier_up.png")
    mod_images["D"] = love.graphics.newImage("images/modifier_down.png")
    mod_images["L"] = love.graphics.newImage("images/modifier_left.png")
    mod_images["R"] = love.graphics.newImage("images/modifier_right.png")
    mod_images["w"] = love.graphics.newImage("images/modifier_rot_up.png")
    mod_images["s"] = love.graphics.newImage("images/modifier_rot_down.png")
    mod_images["a"] = love.graphics.newImage("images/modifier_rot_left.png")
    mod_images["x"] = love.graphics.newImage("images/modifier_rot_right.png")

    return mod_images
end

function load_control_images()
    local control_images = {}
    control_images["prev"] = love.graphics.newImage("images/control_prev.png")
    control_images["next"] = love.graphics.newImage("images/control_next.png")
    control_images["reset"] = love.graphics.newImage("images/control_reset.png")

    return control_images
end

function load_misc_images()
    local misc_images = {}
    misc_images["lock"]     = love.graphics.newImage("images/lock.png")
    misc_images["check"]    = love.graphics.newImage("images/check.png")
    misc_images["circle"]   = love.graphics.newImage("images/btn_circle.png")
    misc_images["cross"]    = love.graphics.newImage("images/btn_cross.png")
    misc_images["triangle"] = love.graphics.newImage("images/btn_triangle.png")
    misc_images["start"]    = love.graphics.newImage("images/btn_start.png")

    return misc_images
end

-- sound operations
function load_sounds()
    local sounds = {}
    sounds["click"] = love.audio.newSource("sounds/click.ogg", "static")
    sounds["fill"]  = love.audio.newSource("sounds/fill.ogg",  "static")
    sounds["won"]   = love.audio.newSource("sounds/won.ogg",   "static")

    return sounds
end

function play_sound(sound_str)
    if SETTINGS.sound.value == "on" then
        if sounds[sound_str] then
            love.audio.play(sounds[sound_str])
        end
    end
end
