function get_optimal_score(pack, level)
    return all_levels[pack][level]["optimal_score"]
end

function is_optimal_score(pack, level, score)
    local opt_s = get_optimal_score(pack, level)
    if (opt_s ~= nil) and (score <= opt_s) then
        return true
    end
    return false
end

function is_level_optimally_beaten(pack, level)
    local hs = get_high_score(pack, level)
    return is_optimal_score(pack, level, hs)
end
