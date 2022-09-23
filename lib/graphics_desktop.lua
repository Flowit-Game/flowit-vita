colors_1 = {
    ["0"] = {255/255, 255/255, 255/255},
    ["X"] = {230/255, 230/255, 230/255},
    ["r"] = {245/255,  21/255,  24/255},
    ["b"] = {104/255, 166/255, 229/255},
    ["g"] = {104/255, 159/255,  56/255},
    ["o"] = {246/255, 202/255,  24/255},
    ["d"] = {113/255, 113/255, 113/255},

    ["t"] = {113/255, 113/255, 113/255}, -- interface
    ["5"] = {0/255, 0/255, 0/255, 0.6},
    -- colors: r, b, g, o, d
}

colors_2 = {
    ["0"] = {255/255, 255/255, 255/255},
    ["X"] = {230/255, 230/255, 230/255},
    ["r"] = {191/255,  75/255,   0/255},
    ["b"] = { 89/255, 187/255, 242/255},
    ["g"] = {  0/255,  85/255, 133/255},
    ["o"] = {246/255, 202/255,  24/255},
    ["d"] = {155/255, 155/255, 155/255},

    ["t"] = { 80/255,  80/255,  80/255}, -- interface
    ["5"] = {0/255, 0/255, 0/255, 0.6},
    -- colors: r, b, g, o, d
}

-- init to default color scheme
colors = colors_1


function screen_width()
    width, height, _= love.window.getMode()
    return width
end
function screen_height()
    width, height, _= love.window.getMode()
    return height
end

-- dummy functions to make cross-platform code easier
function init_draw_phase()
end
function end_draw_phase()
end

function draw_rect(x1, y1, x2, y2, color_str)
    love.graphics.setColor(colors[color_str])
    love.graphics.rectangle('fill', x1, y1, x2-x1, y2-y1)
end

local function draw_rect_outline_1(x1, y1, x2, y2, color_str)
        love.graphics.setColor(colors[color_str])
        love.graphics.line(x1, y1, x1, y2, x2, y2, x2, y1, x1, y1)
end

function draw_rect_outline(x1, y1, x2, y2, color_str, outline_px)
    outline_px = outline_px or 1
    for j=0,outline_px-1 do
        draw_rect_outline_1(x1-j, y1-j, x2+j, y2+j, color_str)
    end
end

function draw_icon(x1, y1, x2, y2, modifier_str)
    local img = mod_images[modifier_str]

    -- TODO: catch errors in modifier_str
    draw_general_icon(x1, y1, x2, y2, img, "0")
end

function draw_general_icon(x1, y1, x2, y2, img, color_str)
    if img ~= nil then
        local h = img.getHeight(img)
        local w = img.getWidth(img)
        local scale = math.min((x2-x1)/w, (y2-y1/h))

        love.graphics.setColor(colors[color_str])
        love.graphics.draw(img, x1, y1, 0, scale, scale)
    end
end

-- dummy function
function load_fonts()
end

font_cache = {}

text_size_cache = {}
function text_dimensions(text, font_size, font_name)
    font_name = font_name or default_font_name
    local key = text .. tostring(font_size) .. font_name

    local text_size = text_size_cache[key]
    if not text_size then
        local font_key = font_name .. ":" .. tostring(font_size)
        local font = font_cache[font_key]
        if not font then
            font = love.graphics.newFont("fonts/" .. font_name, font_size)
            font_cache[font_key] = font
        end
        local textObj = love.graphics.newText(font, text)
        text_size = {width = textObj.getWidth(textObj), height = textObj.getHeight(textObj)}
    end


    return text_size.width, text_size.height
end

function draw_text(x, y, font_size, text, color_str, font_name)
    font_name = font_name or default_font_name

    local font_key = font_name .. ":" .. tostring(font_size)
    local font = font_cache[font_key]
    if not font then
        font = love.graphics.newFont("fonts/" .. font_name, font_size)
        font_cache[font_key] = font
    end

    love.graphics.setColor(colors[color_str])
    love.graphics.setFont(font)
    love.graphics.print(text, x, y)
end
