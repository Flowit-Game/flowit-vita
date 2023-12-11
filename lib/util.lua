-- misc utilities

-- convert, e.g., {a,b,c} to {{a}, {b}, {c}}
function list_to_llist(l)
    local new_list = {}
    for j,x in pairs(l) do
        new_list[j] = {x}
    end
    return new_list
end

-- debugging function which prints out a table
function printtable(t, offset_str)
    offset_str = offset_str or ""

    for k, v in pairs(t) do
        print(offset_str .. tostring(k) .. ": " .. tostring(v))
        if type(v) == "table" then
            printtable(v, offset_str .. "  ")
        end
    end

end

-- given "x, y, z", return {x,y,z}
function split_strip(str, delim_char)
    assert(#delim_char == 1)
    local split_list = {}
    for x in string.gmatch(str, "([^" .. delim_char .. "]+)") do
        split_list[#split_list+1] = strip(x)
    end
    return split_list
end

-- given "  z ", return "z"
function strip(str)
    str = string.gsub(str, "^%s+", "")
    str = string.gsub(str, "%s+$", "")
    return str
end

function round(n)
    return math.floor(n+0.5)
end

-- Given a string, return true if it should be rendered in the fallback font and
-- false if it should be rendered in the default font (goodtimes).
-- Goodtimes has < 400 characters, so we just check directly instead of using
-- any font utils.
function needsFallbackFont(str)
    local non_goodtimes = "[^ !\"#$%%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\%]^_`abcdefghijklmnopqrstuvwxyz{|}~ ¡¢£¥¦§¨©ª«®¯°±²³´¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĊċČčĎďĐđĒēĔĕĖėĘęĚěĞğĠġĢģĦħĪīĬĭĮįİıĲĳĶķĹĺĻļĽľĿŀŁłŃńŅņŇňŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžȘșȚțˆˇ˘˙˚˛˜˝̦ẀẁẂẃẄẅỲỳ–—‘’‚“”„†‡•…‰‹›⁄⁰⁴⁵⁶⁷⁸⁹₀₁₂₃₄₅]"
    if (string.match(str, non_goodtimes)) then
        return true
    end
    return false
end
