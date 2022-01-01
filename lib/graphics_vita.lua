colors = {
    ["0"] = Color.new(255, 255, 255),
    ["X"] = Color.new(230, 230, 230),
    ["r"] = Color.new(245,  21,  24),
    ["b"] = Color.new(104, 166, 229),
    ["g"] = Color.new(104, 159,  56),
    ["o"] = Color.new(246, 202,  24),
    ["d"] = Color.new(113, 113, 113),

    ["5"] = Color.new(0, 0, 0, 153),
    -- colors: r, b, g, o, d
}



function screen_width()
    return 960
end
function screen_height()
    return 544
end

function init_draw_phase()
    Graphics.initBlend()
    Screen.clear()
    Graphics.fillRect(0, 960, 0, 544, colors["X"])
end

function end_draw_phase()
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end

function draw_rect(x1, y1, x2, y2, color_str)
    Graphics.fillRect(x1, x2, y1, y2, colors[color_str])
end

function draw_rect_outline(x1, y1, x2, y2, color_str, outline_px)
    outline_px = outline_px or 1
    for j=0,outline_px-1 do
        Graphics.fillEmptyRect(x1-j, x2+j, y1-j, y2+j, colors[color_str])
    end
end

function draw_icon(x1, y1, x2, y2, modifier_str)
    local img = mod_images[modifier_str]

    -- TODO: catch errors in modifier_str
    draw_general_icon(x1, y1, x2, y2, img, "0")
end

function draw_general_icon(x1, y1, x2, y2, img, color_str)
    if img ~= nil then
        local h = Graphics.getImageHeight(img)
        local w = Graphics.getImageWidth(img)
        local scale = math.min((x2-x1)/w, (y2-y1/h))

        Graphics.drawScaleImage(x1, y1, img, scale, scale, colors[color_str])
    end
end

-- load fonts must be called at start
fonts = {}
function load_fonts()
    -- globals
    for _, font_name in pairs({"good-times-rg.ttf", "LiberationSans-Regular.ttf", "SourceHanSansHW-VF.ttf"}) do
        fonts[font_name] = Font.load("app0:/assets/fonts/" .. font_name)
    end
end

text_size_cache = {}
function text_dimensions(text, font_size, font_name)
    font_name = font_name or default_font_name

    -- Speed up detection of text dimensions in Chinese and Japanese by assuming monospacing
    local text_len = #text
    local is_monospace = (lang_code == "zh_t" or lang_code == "zh_s" or lang_code == "ja")
    if is_monospace then
        text = "北冥有魚其名爲鯤"
    end

    local key = text .. tostring(font_size) .. font_name

    local text_size = text_size_cache[key]
    if not text_size then
        if not fonts or #fonts == 0 then
            load_fonts()
        end

        local font = fonts[font_name]
        assert(font ~= nil)

        Font.setPixelSizes(font, font_size)
        local fw = Font.getTextWidth(font, text)

        -- hacky fix to get the text size right...
        -- TODO: find a better way / figure out how accurate this is...
        local fh = math.floor(Font.getTextHeight(font, text)*1.2)
        text_size = {width = fw, height = fh}
        text_size_cache[key] = text_size
    end
    local width = text_size.width
    local height = text_size.height
    if is_monospace then
        width = round(width * text_len / #text)
    end
    return width, height
end

function draw_text(x, y, font_size, text, color_str, font_name)
    font_name = font_name or default_font_name
    if not fonts then
        load_fonts()
    end

    local font = fonts[font_name]

    Font.setPixelSizes(font, font_size)
    Font.print(font, x, y, text, colors[color_str])
end

function draw_text(x, y, font_size, text, color_str, font_name)
    font_name = font_name or default_font_name
    if not fonts then
        load_fonts()
    end

    local font = fonts[font_name]
    assert(font ~= nil)

    Font.setPixelSizes(font, font_size)
    Font.print(font, x, y, text, colors[color_str])
end
