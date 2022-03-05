
loadlib("xmlparser")

function data_string_to_table(data_string)

    -- remove empty lines
    data_string = string.gsub(data_string, "\n%s*\n", "\n")

    -- remove heading or trailing spaces
    data_string = string.gsub(data_string, "\n%s+", "\n")
    data_string = string.gsub(data_string, "%s+\n", "\n")

    -- remove first and last \n and add last back in (to ensure exactly 1)
    data_string = string.gsub(data_string, "^\n*", "")
    data_string = string.gsub(data_string, "\n$", "")
    data_string = data_string .. "\n"


    local nrows = 0
    local ncols = 0

    local data = {}
    for line in string.gmatch(data_string, "([^\n]+)\n") do
        nrows = nrows + 1
        local row = {}

        if ncols == 0 then
            ncols = #line
        end
        assert(ncols == #line)

        for i = 1,#line do
            table.insert(row, string.sub(line, i, i))
        end
        table.insert(data, row)
    end

    return data
end

function get_level_data_from_pack(level_pack)
    -- read in level file

    local lp_file = level_pack_files[level_pack]
    assert(lp_file ~= nil)

    local pack_xml = read_file_to_string(lp_file)

    -- parse xml
    local data_raw = parse(pack_xml, false)

    local data = {}
    for j, this_level_data_raw in pairs(data_raw["children"][1]["children"]) do
    local color_data_raw = this_level_data_raw["attrs"]["color"]
    local modifier_data_raw = this_level_data_raw["attrs"]["modifier"]
    local level_id = this_level_data_raw["attrs"]["number"]
    local level_author = this_level_data_raw["attrs"]["author"]

    local this_data = {}
    local cdata = data_string_to_table(color_data_raw)
    local mdata = data_string_to_table(modifier_data_raw)

    -- some levels have a blank final line. let's remove it.
    local nrows = #cdata
    local ncols = #cdata[nrows]
    assert(nrows == #mdata)
    assert(ncols == #mdata[nrows])
    local last_line_blank = true
    for c = 1, ncols do
        if (cdata[nrows][c] ~= "0") or (mdata[nrows][c] ~= "X") then
            last_line_blank = false
            break
        end
    end
    if last_line_blank then
        table.remove(cdata, nrows)
        table.remove(mdata, nrows)
    end


    this_data["color"] = cdata
    this_data["modifier"] = mdata
    this_data["id"] = level_id
    this_data["author"] = level_author

    data[j] = this_data
    end

    --printtable(data_raw["children"][1]["children"])

    return data
end

function load_all_levels()
    local all_levels = {}

    for level_pack, _ in pairs(level_pack_files) do
        all_levels[level_pack] = get_level_data_from_pack(level_pack)
    end

    return all_levels
end

function level_to_tridata(all_levels, pack, level)
    level = math.max(level, 1)
    level = math.min(level, #all_levels[pack])
    local bidata = all_levels[pack][level]

    -- no need to copy color, since it never changes
    local cdata = bidata["color"]

    -- we need to copy the state since bombs will change it
    local mdata = copy_state(bidata["modifier"])

    local fdata = init_state(cdata, mdata)
    tridata = {["color"]=cdata, ["modifier"]=mdata, ["fill"]=fdata}
    return tridata
end

function get_next_unlocked_level(all_levels, pack, level)
    local level2 = level
    local pack2 = pack
    while true do
        pack2, level2 = get_next_level(all_levels, pack2, level2)
        if level2 then
            if not is_level_locked(pack2, level2) then
                return pack2, level2
            end
        else
            return nil, nil
        end
    end
end
function get_prev_unlocked_level(all_levels, pack, level)
    local level2 = level
    local pack2 = pack
    while true do
        pack2, level2 = get_prev_level(all_levels, pack2, level2)
        if level2 then
            if not is_level_locked(pack2, level2) then
                return pack2, level2
            end
        else
            return nil, nil
        end
    end
end

function get_prev_level(all_levels, pack, level)
    if level > 1 then
        return pack, level - 1
    elseif pack == "easy" then
        return nil, nil
    elseif pack == "medium" then
        return "easy", #all_levels["easy"]
    elseif pack == "hard" then
        return "medium", #all_levels["medium"]
    elseif pack == "community" then
        return nil, nil
    end
end
function get_next_level(all_levels, pack, level)
    if level < #all_levels[pack] then
        return pack, level + 1
    elseif pack == "easy" then
        return "medium", 1
    elseif pack == "medium" then
        return "hard", 1
    elseif pack == "hard" then
        return nil, nil
    elseif pack == "community" then
        return nil, nil
    end
end
