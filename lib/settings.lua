SETTINGS = {}

-- default settings
SETTINGS.sound = {
    options = {"on", "off"},
    default = "on",
    value = "on",
}
SETTINGS.buttons = {
    options = {"ox", "xo"},
    default = "xo",
    value = "xo",
}
SETTINGS.reset_button = {
    options = {"triangle", "start"},
    default = "triangle",
    value = "triangle",
}
SETTINGS.confirmations = {
    options = {"on", "off"},
    default = "on",
    value = "on",
}

local function reset_invalid_settings()
    for k, setting in pairs(SETTINGS) do
        local setting_is_valid = false
        for _, option in pairs(setting.options) do
            if setting.value == option then
                setting_is_valid = true
                break
            end
        end

        if not setting_is_valid then
            setting.value = setting.default
        end
    end
end

function load_settings()
    if file_exists(SETTINGS_FILE) then
        local s_lines = read_file_to_table_stripped(SETTINGS_FILE)
        for _, line in pairs(s_lines) do
            if #line > 0 then
                local l = split_strip(line, ",")
                if (#l == 2) then -- ignore invalid lines
                    local key = l[1]
                    local val = l[2]

                    if key == "sound" then
                        SETTINGS.sound.value = val
                    elseif key == "buttons" then
                        SETTINGS.buttons.value = val
                    elseif key == "reset_button" then
                        SETTINGS.reset_button.value = val
                    elseif key == "confirmations" then
                        SETTINGS.confirmations.value = val
                    end
                end

            end
        end
    else
        save_settings()
    end

    reset_invalid_settings()

end

function save_settings()
    reset_invalid_settings()

    local settings_str = ""
    for k, setting in pairs(SETTINGS) do
        local line = k .. "," .. tostring(setting.value)
        settings_str = settings_str .. line .. "\n"
    end

    write_string_to_file(SETTINGS_FILE, settings_str)
end
