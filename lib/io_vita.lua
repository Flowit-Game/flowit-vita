-- file reading operations.


FLOWIT_DIR = "ux0:/data/flowit"
System.createDirectory(FLOWIT_DIR)
HIGH_SCORES_FILE = FLOWIT_DIR .. "/high_scores.txt"
SETTINGS_FILE = FLOWIT_DIR .. "/settings.txt"

level_pack_files = {
    ["easy"]   = "app0:/assets/levels/levelsEasy.xml",
    ["medium"] = "app0:/assets/levels/levelsMedium.xml",
    ["hard"]   = "app0:/assets/levels/levelsHard.xml",
}


function read_file_to_string(filepath)
    local f = System.openFile(filepath, FREAD)
    local str = System.readFile(f, System.sizeFile(f))
    System.closeFile(f)

    return str
end

function read_file_to_table_stripped(file)
    local str = read_file_to_string(file)
    local lines = split_strip(str, "\n")
    return lines
end

function write_string_to_file(filepath, str)
    local f
    if System.doesFileExist(filepath) then
        f = System.openFile(filepath, FWRITE)
    else
        f = System.openFile(filepath, FCREATE)
    end
    System.writeFile(f, str, #str)
    System.closeFile(f)
end

function file_exists(file)
    if System.doesFileExist(file) then
        return true
    else
        return false
    end
end

-- image loading
function load_mod_images()
    local image_dir = "app0:/assets/images"

    local mod_images = {}
    mod_images["B"] = Graphics.loadImage(image_dir .. "/modifier_bomb.png")
    mod_images["F"] = Graphics.loadImage(image_dir .. "/modifier_circle.png")
    mod_images["U"] = Graphics.loadImage(image_dir .. "/modifier_up.png")
    mod_images["D"] = Graphics.loadImage(image_dir .. "/modifier_down.png")
    mod_images["L"] = Graphics.loadImage(image_dir .. "/modifier_left.png")
    mod_images["R"] = Graphics.loadImage(image_dir .. "/modifier_right.png")
    mod_images["w"] = Graphics.loadImage(image_dir .. "/modifier_rot_up.png")
    mod_images["s"] = Graphics.loadImage(image_dir .. "/modifier_rot_down.png")
    mod_images["a"] = Graphics.loadImage(image_dir .. "/modifier_rot_left.png")
    mod_images["x"] = Graphics.loadImage(image_dir .. "/modifier_rot_right.png")

    return mod_images
end

function load_control_images()
    local image_dir = "app0:/assets/images"

    local control_images = {}
    control_images["prev"] = Graphics.loadImage(image_dir .. "/control_prev.png")
    control_images["next"] = Graphics.loadImage(image_dir .. "/control_next.png")
    control_images["reset"] = Graphics.loadImage(image_dir .. "/control_reset.png")

    return control_images
end

function load_misc_images()
    local image_dir = "app0:/assets/images"

    local misc_images = {}
    misc_images["lock"] = Graphics.loadImage(image_dir .. "/lock.png")
    misc_images["check"] = Graphics.loadImage(image_dir .. "/check.png")
    misc_images["circle"] = Graphics.loadImage(image_dir .. "/btn_circle.png")
    misc_images["cross"] = Graphics.loadImage(image_dir .. "/btn_cross.png")

    return misc_images
end

-- sound operations
Sound.init() -- required at start ?

function load_sounds()
    local sound_dir = "app0:/assets/sounds"

    local sounds = {}
    sounds["click"] = Sound.open(sound_dir .. "/click.ogg")
    sounds["fill"]  = Sound.open(sound_dir .. "/fill.ogg")
    sounds["won"]   = Sound.open(sound_dir .. "/won.ogg")

    return sounds
end

function play_sound(sound_str)
    if SETTINGS.sound.value == "on" then
        if sounds[sound_str] then
            Sound.play(sounds[sound_str], NO_LOOP)
        end
    end
end
