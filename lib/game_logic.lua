-- colors: r, b, g, o, d
function is_color(c)
    if c == "r" or c == "b" or c == "g" or c == "o" or c == "d" then
        return true
    else
        return false
    end
end

-- rotate states: up w, right x, down s, left a
function next_rotate_state(s)
    if s == "w" then
        return "x"
    elseif s == "x" then
        return "s"
    elseif s == "s" then
        return "a"
    elseif s == "a" then
        return "w"
    else
        assert(false)
    end
end

-- debugging function which prints out a state
function print_state(data)
    local nrows = #data
    local ncols = #data[1]

    for r = 1,nrows do
        local row_str = ""
        for c = 1,ncols do
            row_str = row_str .. data[r][c]
        end
        print(row_str)
    end

end

-- debugging function which prints out the tri-state
function print_tristate(tridata)
    local cdata = tridata["color"]
    local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    local nrows = #cdata
    local ncols = #cdata[1]

    for r = 1,nrows do
        local row_str = ""

        for c = 1,ncols do
            row_str = row_str .. cdata[r][c]
        end
        row_str = row_str .. "  "
        for c = 1,ncols do
            row_str = row_str .. mdata[r][c]
        end
        row_str = row_str .. "  "
        for c = 1,ncols do
            row_str = row_str .. fdata[r][c]
        end

        print(row_str)
    end

end

function copy_state(data)
    local nrows = #data
    local ncols = #data[1]

    local data2 = {}
    for r = 1,nrows do
        local row = {}
        for c = 1,ncols do
            row[c] = data[r][c]
        end
        data2[r] = row
    end

    return data2
end

function init_state(cdata, mdata)
    local nrows = #cdata
    local ncols = #cdata[1]

    local fdata = {}
    for r = 1,nrows do
        local row = {}
        for c = 1,ncols do
            if mdata[r][c] == "0" then
                row[c] = "0"
            elseif mdata[r][c] == "r" then
                row[c] = "r"
            elseif mdata[r][c] == "b" then
                row[c] = "b"
            elseif mdata[r][c] == "g" then
                row[c] = "g"
            elseif mdata[r][c] == "o" then
                row[c] = "o"
            elseif mdata[r][c] == "d" then
                row[c] = "d"
            else
                row[c] = "X"
            end
        end

        fdata[r] = row
    end

    return fdata
end


-------------------- CELL FINDING LOGIC ------------------

-- return immediate neighbor to the right/left/up/down
-- return nil if it's off the board
function get_neighbor_dir(tridata, r, c, dir)
    --local cdata = tridata["color"]
    --local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    local nrows = #fdata
    local ncols = #fdata[1]

    if dir == "right" and c < ncols then
        return {r = r, c = c+1}
    end
    if dir == "left" and c > 1 then
        return {r = r, c = c-1}
    end
    if dir == "up" and r > 1 then
        return {r = r-1, c = c}
    end
    if dir == "down" and r < nrows then
        return {r = r+1, c = c}
    end

    return nil
end

-- return immediate neighbors within the rectangle of the game
-- no testing on what those neighbors are
function get_neighbors(tridata, r, c)
    --local cdata = tridata["color"]
    --local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    local nrows = #fdata
    local ncols = #fdata[1]

    local neighbors = {}

    if r > 1 then
        neighbors[#neighbors + 1] = {r = r-1, c = c}
    end
    if r < nrows then
        neighbors[#neighbors + 1] = {r = r+1, c = c}
    end
    if c > 1 then
        neighbors[#neighbors + 1] = {r = r, c = c-1}
    end
    if c < ncols then
        neighbors[#neighbors + 1] = {r = r, c = c+1}
    end

    return neighbors
end

-- return neighbors (including diagonal) within the rectangle of the game
-- no testing on what those neighbors are
function get_neighbors_with_diag(fdata, r, c)
    --local cdata = tridata["color"]
    --local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    local nrows = #fdata
    local ncols = #fdata[1]

    local neighbors = {}

    if r > 1 then
        neighbors[#neighbors + 1] = {r = r-1, c = c}
    end
    if r < nrows then
        neighbors[#neighbors + 1] = {r = r+1, c = c}
    end
    if c > 1 then
        neighbors[#neighbors + 1] = {r = r, c = c-1}
    end
    if c < ncols then
        neighbors[#neighbors + 1] = {r = r, c = c+1}
    end
    if r > 1 and c > 1 then
        neighbors[#neighbors + 1] = {r = r-1, c = c-1}
    end
    if r < nrows and c > 1 then
        neighbors[#neighbors + 1] = {r = r+1, c = c-1}
    end
    if r > 1 and c < ncols then
        neighbors[#neighbors + 1] = {r = r-1, c = c+1}
    end
    if r < nrows and c < ncols then
        neighbors[#neighbors + 1] = {r = r+1, c = c+1}
    end

    return neighbors
end

-- get immediate neighbors matching a certain value
-- datatag = "color", "modifier", or "fill"
function get_neighbors_matching(tridata, r, c, datatag, val)
    local data = tridata[datatag]

    local all_neighbors = get_neighbors(tridata, r, c)
    local neighbors = {}
    for i, neighbor in pairs(all_neighbors) do
        if data[neighbor.r][neighbor.c] == val then
            neighbors[#neighbors+1] = neighbor
        end
    end

    return neighbors
end

-- get cells to fill when doing a line fill
-- r,c refers to the location of the arrow
function get_line_cells_to_fill(tridata, r, c, dir)
    return get_line_cells_to_clear(tridata, r, c, dir, "0")
end

-- get cells to delete when doing a line clear
function get_line_cells_to_clear(tridata, r, c, dir, color)
    --local cdata = tridata["color"]
    --local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    local nrows = #fdata
    local ncols = #fdata[1]

    local rstep = 0
    local cstep = 0
    if dir == "right" then
        cstep = 1
    elseif dir == "left" then
        cstep = -1
    elseif dir == "up" then
        rstep = -1
    elseif dir == "down" then
        rstep = 1
    end

    cells = {}
    for t=1,nrows+ncols do
        r = r + rstep
        c = c + cstep

        if (1 <= r and r <= nrows and 1 <= c and c <= ncols) then
            if fdata[r][c] == color then
                cells[#cells+1] = {r = r, c = c}
            else
                break
            end
        else
            break
        end
    end

    return cells
end

-- get cells to update when bombing
function get_bomb_cells(tridata, r, c)
    --local cdata = tridata["color"]
    local mdata = tridata["modifier"]
    --local fdata = tridata["fill"]

    local all_neighbors = get_neighbors_with_diag(tridata, r, c)

    local neighbors = {{r = r, c = c}}
    for i, neighbor in pairs(all_neighbors) do
        if mdata[neighbor.r][neighbor.c] ~= "X" then
            neighbors[#neighbors+1] = neighbor
        end
    end

    return neighbors
end

function get_flood_cells_to_fill(tridata, r, c)
    return get_flood_cells_to_clear(tridata, r, c, "0")
end

function get_flood_cells_to_clear(tridata, r, c, color)
    --local cdata = tridata["color"]
    --local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    local nrows = #fdata
    local ncols = #fdata[1]

    local cells_done = {}
    local cells_by_layer = {}

    local prev_layer_cells = {{r = r, c = c}}
    for layer=1, nrows*ncols do
        local new_layer_cells = {}
        for _, pcell in pairs(prev_layer_cells) do
            local neighbors = get_neighbors_matching(tridata, pcell.r, pcell.c, "fill", color)
            for _, neighbor in pairs(neighbors) do
                if not contains_cell(new_layer_cells, neighbor) then
                    if not contains_cell(cells_done, neighbor) then
                        new_layer_cells[#new_layer_cells+1] = neighbor
                        cells_done[#cells_done+1] = neighbor
                    end
                end
            end
        end

        if #new_layer_cells == 0 then
            break
        end

        cells_by_layer[layer] = new_layer_cells

        prev_layer_cells = new_layer_cells
    end

    return cells_by_layer
end

function contains_cell(cell_list, cell)
    for i, cell_ in pairs(cell_list) do
        if cell_.r == cell.r and cell_.c == cell.c then
            return true
        end
    end
    return false
end

function is_winning_state(tridata)
    local cdata = tridata["color"]
    local mdata = tridata["modifier"]
    local fdata = tridata["fill"]

    local nrows = #fdata
    local ncols = #fdata[1]

    for r = 1,nrows do
        for c = 1,ncols do
            if is_color(cdata[r][c]) and (mdata[r][c] == "0" or is_color(mdata[r][c])) then
                if cdata[r][c] ~= fdata[r][c] then
                    return false
                end
            end
        end
    end

    return true

end
