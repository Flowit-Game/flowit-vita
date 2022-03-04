-------------------- INDEPENDENT FUNCTIONS------------------

function load_high_scores()
    local high_scores_data = {}
    if file_exists(HIGH_SCORES_FILE) then
        local hs_lines = read_file_to_table_stripped(HIGH_SCORES_FILE)
        for _, line in pairs(hs_lines) do
            if #line > 0 then
                local l = split_strip(line, ",")
                if (#l == 3) then -- ignore invalid lines
                    local pack = l[1]
                    local id = l[2]
                    local score = tonumber(l[3])

                    high_scores_data[pack] = high_scores_data[pack] or {}
                    high_scores_data[pack][id] = score
                end
            end
        end
    else
        write_string_to_file(HIGH_SCORES_FILE, "")
    end

    return high_scores_data

end

function save_high_scores()

    local hs_str = ""
    for pack, hs1 in pairs(high_scores_data) do
        for id, hs2 in pairs(hs1) do
            local line = pack .. "," .. tostring(id) .. "," .. tostring(hs2)
            hs_str = hs_str .. line .. "\n"
            --print(line)
        end
    end
    write_string_to_file(HIGH_SCORES_FILE, hs_str)
end

function get_high_score(pack, level)
    if high_scores_data[pack] == nil then
        return nil
    end

    local id = all_levels[pack][level]["id"]
    assert(id ~= nil)

    return high_scores_data[pack][id]
end
function is_replay_high_score(pack, level, score)
    local prev_hs = get_high_score(pack, level)
    if (prev_hs == nil) then
        return false
    else
        if (score < prev_hs) then
            return true
        end
    end
    return false
end
function is_high_score(pack, level, score)
    local prev_hs = get_high_score(pack, level)
    if (prev_hs == nil) or (score < prev_hs) then
        return true
    end
    return false
end

-- 5 levels ahead are unlocked
-- But all community levels are unlocked
UNLOCK_NUM = 5
function is_level_locked(pack, level)
    if (pack == "community") then
        return false
    end
    if level <= UNLOCK_NUM then
        return false
    else
        for n=level,level-UNLOCK_NUM,-1 do
            local hs = get_high_score(pack, n)
            if hs then
                return false
            end
        end
    end
    return true

end

-------------------- FUNCTIONS DEP ON GLOBAL VARS ------------------

function record_high_score(pack, level, score)
    local id = all_levels[pack][level]["id"]
    assert(id ~= nil)

    if is_high_score(pack, level, score) then
        if high_scores_data[pack] == nil then
            high_scores_data[pack] = {}
        end
        high_scores_data[pack][id] = score
        save_high_scores()
    end
end

high_score_cache = {}
function get_cached_high_score(pack, level)
    if high_score_cache[pack] then
        return high_score_cache[pack][level]
    end
    return nil
end
