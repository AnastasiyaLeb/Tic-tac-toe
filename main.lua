function newCell(value, img)
    return {
        value = value,
        img = img,
        now = false,
        last = false
    }
end

function newButton(text, fn, x, y, font)
    return {
        text = text,
        fn = fn, 
        x = x,
        y = y,
        font = font,  
        now = false,
        last = false
    }
end

local cell_number = 1
local first_xy = {82, 121}
local cells = {}
local move = 1
local font = nil
local font1 = nil
local font2 = nil
local win = false
local text = "Turn X"
local winner = ""
local size = 3
local start = true
local values = {}
local buttons = {}
local win_combinations = {}
local win_comb_left_o = {}
local win_comb_left_x = {}
local combination = {}
local players = "Player vs Player"

function love.load()

    font = love.graphics.newFont("res/LSANSD.ttf", 55)
    font1 = love.graphics.newFont("res/LSANSD.ttf", 18)
    font2 = love.graphics.newFont("res/LSANSD.ttf", 35)
    background = love.graphics.newImage("res/background.png")
    empty_img = love.graphics.newImage("res/empty.png")
    x_img = love.graphics.newImage("res/x.png")
    o_img = love.graphics.newImage("res/o.png")

    for i = 1, size * size do 
        table.insert(cells, newCell(0, empty_img))
    end

    table.insert(buttons, newButton(
        "3 x 3",
        function()
            start = true
            size = 3
        end,
        82, 
        620,
        font2
    ))

    table.insert(buttons, newButton(
        "4 x 4",
        function()
            size = 4
            start = true
        end,
        242, 
        620,
        font2
    ))

    table.insert(buttons, newButton(
        "5 x 5",
        function()
            size = 5
            start = true
        end,
        402, 
        620,
        font2
    ))

    table.insert(buttons, newButton(
        "Player vs Player",
        function()
            players = "Player vs Player"
            start = true
        end,
        570, 
        170,
        font1
    ))

    table.insert(buttons, newButton(
        "Player vs PC",
        function()
            players = "Player vs PC"
            start = true
        end,
        570, 
        330,
        font1
    ))

    table.insert(buttons, newButton(
        "PC vs PC",
        function()
            players = "PC vs PC"
            start = true
        end,
        570, 
        490,
        font1
    ))

end

function love.update(dt)
    --Старт игры или начало заново
    if start then
        win_combinations = {}
        win = false
        winner = ""
        move = 1
        values = {}
        cells = {}
        start = false
        combination = {}

        --Заполнение талиц значений и ячеек
        for i = 1, size * size do
            table.insert(values, 0)
        end
        
        for i = 1, size * size do 
            table.insert(cells, newCell(0, empty_img))
        end

        --Заполнение возможных выигрышных комбинаций для поля размера size
        --Выигрышные комбинации по вертикали
        for  i = 1, size do
            for j = i, size*size - (size - i), size do
                table.insert(combination, j)
            end
            table.insert(win_combinations, combination)
            table.insert(win_comb_left_x, combination)
            table.insert(win_comb_left_o, combination)
            combination = {}
        end
        
        --Выигрышные комбинации по горизонтале
        for  i = 1, size*size - size + 1, size do
            for j = i, i + size - 1 do
                table.insert(combination, j)
            end
            table.insert(win_combinations, combination)
            table.insert(win_comb_left_x, combination)
            table.insert(win_comb_left_o, combination)
            combination = {}
        end

        --Выигрышные комбинации по диагонали
        for i = 1, size*size, size + 1 do
            table.insert(combination, i)
        end

        table.insert(win_combinations, combination)
        table.insert(win_comb_left_x, combination)
        table.insert(win_comb_left_o, combination)
        combination = {}

        for i = size  , size*size - size + 1, size - 1 do
            table.insert(combination, i)
        end

        table.insert(win_combinations, combination)
        table.insert(win_comb_left_x, combination)
        table.insert(win_comb_left_o, combination)
        combination = {}
    end

    --Удаление комбинаций, которые не подходят нолику 
    for i = #win_comb_left_o, 1, -1 do
        for j = 1, #win_comb_left_o[i] do
            if values[win_comb_left_o[i][j]] == 1 then
                table.remove(win_comb_left_o, i)
                break
            end
        end
    end

    --Удаление комбинаций, которые не подходят крестику
    for i = #win_comb_left_x, 1, -1 do
        for j = 1, #win_comb_left_x[i] do
            if values[win_comb_left_x[i][j]] == 2 then
                table.remove(win_comb_left_x, i)
                break
            end
        end
    end
    
    --Провекра есть ли победитель
    for i = 1, #win_combinations do
        local check_winner_x = 0
        local check_winner_o = 0
        nul_cell = nil
        for j = 1, #win_combinations[i] do
            if values[win_combinations[i][j]] == 1 then
                check_winner_x = check_winner_x + 1
            end
            if values[win_combinations[i][j]] == 2 then
                check_winner_o = check_winner_o + 1
            end
        end
        if check_winner_x == size then
            winner = "x"
            win = true
            break
        end
        if check_winner_o == size then
            winner = "o"
            win = true
            break
        end
    end

    --Изменение текста сверху в зависимотри от хода игры 
    if not win and move <= size*size then 
        if #win_comb_left_o > 0 and #win_comb_left_x > 0 then
            if move % 2 == 0 then
                text = "Turn O"
            else
                text = "Turn X"
            end
        else
            text = "Draw"
            win = true
        end
        
    else
        if move > size*size then
            text = "Draw"
        else
            if winner == "o" then
                text = "Winner O"
            else
                if winner == "x" then
                    text = "Winner X"
                end
            end
        end
    end

    -- Ход нолика (PC)
    if move % 2 == 0 and (players == "Player vs PC" or players == "PC vs PC") and not win then

        local o = 0
        local x = 0
        local nul_cell = nil
        local nul_cell_O = nil

        --Проверка есть ли выигрышная комбинация, до выигрыша которой остался один ход
        nul_cell = nil
        place_for_o = nil
        
        for i = 1, #win_combinations do
            o = 0
            nul_cell = nil
            for j = 1, #win_combinations[i] do
                if cells[win_combinations[i][j]].value == 2 then
                    o = o + 1
                end
                if cells[win_combinations[i][j]].value == 0 then
                    nul_cell = win_combinations[i][j]
                end 
            end
            if o == (size - 1) and not (nul_cell == nil) then
                place_for_o = nul_cell
            end
        end
        if not (place_for_o == nil) then
            cells[place_for_o].value = 2
            values[place_for_o] = 2
            move = move + 1
        end
        
        --Проверка есть ли выигрышная комбинация у оппонента, до выигрыша которой остался один ход
        if move % 2 == 0 then
            nul_cell = nil
            place_for_o = nil
            
            for i = 1, #win_combinations do
                x = 0
                nul_cell = nil
                for j = 1, #win_combinations[i] do
                    if cells[win_combinations[i][j]].value == 1 then
                        x = x + 1
                    end
                    if cells[win_combinations[i][j]].value == 0 then
                        nul_cell = win_combinations[i][j]
                    end 
                end
                if x == (size - 1) and not (nul_cell == nil) then
                    place_for_o = nul_cell
                end
            end
            if not (place_for_o == nil) then
                cells[place_for_o].value = 2
                values[place_for_o] = 2
                move = move + 1
            end
        end
        
        --Если нет почти заверщенных комбинаций, то проверка наиболее удачного хода
        if move % 2 == 0 then
            local max_count = 0
            for number = 1, size*size do
                local count = 0
                for i = 1, #win_comb_left_o do
                    for j = 1, #win_comb_left_o[i] do
                        if win_comb_left_o[i][j] == number then
                            count = count + 1
                        end
                    end
                end
                if count > max_count and cells[number].value == 0 then
                    max_count = count
                    cell_number = number
                end
            end
            cells[cell_number].value = 2
            values[cell_number] = 2
            move = move + 1
        end

    end

    -- Ход крестика (PC)
    if move % 2 == 1 and players == "PC vs PC" and not win then

        local o = 0
        local x = 0
        local nul_cell = nil
        local nul_cell_O = nil

        --Проверка есть ли выигрышная комбинация, до выигрыша которой остался один ход
        nul_cell = nil
        place_for_x = nil
        
        for i = 1, #win_combinations do
            o = 0
            nul_cell = nil
            for j = 1, #win_combinations[i] do
                if cells[win_combinations[i][j]].value == 1 then
                    x = x + 1
                end
                if cells[win_combinations[i][j]].value == 0 then
                    nul_cell = win_combinations[i][j]
                end 
            end
            if x == (size - 1) and not (nul_cell == nil) then
                place_for_x = nul_cell
            end
        end
        if not (place_for_x == nil) then
            cells[place_for_x].value = 1
            values[place_for_x] = 1
            move = move + 1
        end
        
        --Проверка есть ли выигрышная комбинация у оппонента, до выигрыша которой остался один ход
        if move % 2 == 1 then
            nul_cell = nil
            place_for_x = nil
            
            for i = 1, #win_combinations do
                o = 0
                nul_cell = nil
                for j = 1, #win_combinations[i] do
                    if cells[win_combinations[i][j]].value == 2 then
                        o = o + 1
                    end
                    if cells[win_combinations[i][j]].value == 0 then
                        nul_cell = win_combinations[i][j]
                    end 
                end
                if o == (size - 1) and not (nul_cell == nil) then
                    place_for_x = nul_cell
                end
            end
            if not (place_for_o == nil) then
                cells[place_for_x].value = 1
                values[place_for_x] = 1
                move = move + 1
            end
        end
        
        --Если нет почти заверщенных комбинаций, то проверка наиболее удачного хода
        if move % 2 == 1 then
            local max_count = 0
        --local cell_number = nil
            for number = 1, size*size do
                local count = 0
                for i = 1, #win_comb_left_x do
                    for j = 1, #win_comb_left_x[i] do
                        if win_comb_left_x[i][j] == number then
                            count = count + 1
                        end
                    end
                end
                if count > max_count and cells[number].value == 0 then
                    max_count = count
                    cell_number = number
                end
            end
            cells[cell_number].value = 1
            values[cell_number] = 1
            move = move + 1
        end
        print()
    end    
end

function love.draw()
    
    local cell_x = first_xy[1]
    local cell_y = first_xy[2]
    local space_x = 0
    local space_y = 0

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background)

    for i, cell in ipairs(cells) do
        cell.last = cell.now

        local mx, my = love.mouse.getPosition()

        -- hot - курсор на ячейке
        local hot = mx > cell_x and mx < cell_x + (480 / size) and
                    my > cell_y and my < cell_y + (480 / size)

        cell.now = love.mouse.isDown(1)

        -- Если пользователь щелкнул по ячейке
        if cell.now and not cell.last and hot then
            if cell.value == 0 and not win then
                if move % 2 == 0 then 
                    cell.value = 2
                else
                    if move % 2 == 1 then 
                        cell.value = 1
                    end
                end
                move = move + 1 
            end

        end

        --Изображение крестика или нолика по значению ячейки
        if cell.value == 1 then
            cell.img = x_img
        end

        if cell.value == 2 then
            cell.img = o_img
        end
        -- Отображение ячейки
        love.graphics.draw(cell.img, cell_x, cell_y, 0, 1 / size)
        if i % size == 0 then
            cell_x = first_xy[1]
            cell_y = cell_y + (480 / size)
        else
            cell_x = cell_x + (480 / size)
        end
        values[i] = cell.value
    end

    local button_indent = 0
    
    --Отображение кнопок
    for i, button in ipairs(buttons) do
        button.last = button.now

        local color = {0, 0, 0.5, 0.5}
        local mx, my = love.mouse.getPosition()

        local hot = mx > button.x  and mx < button.x + 160 and
                    my > button.y and my < button.y + 60

        if hot then
            color = {0.5, 0, 0.5, 1}
        end

        button.now = love.mouse.isDown(1)
        if button.now and not button.last and hot then
            button.fn()
        end
        
        love.graphics.setColor(unpack(color))
        love.graphics.rectangle(
            "fill",
            button.x,
            button.y,
            155,
            60
        )

        love.graphics.setColor(0, 0, 0, 1)

        local textW = button.font:getWidth(button.text)
        local textH = button.font:getHeight(button.text)

        love.graphics.print(
            button.text,
            button.font,
            button.x + 77.5 - textW * 0.5,
            button.y + 30 - textH * 0.5
        )

    end
    
    local textW = font:getWidth(text)
    local playersW = font1:getWidth(players)
    local ww = love.graphics.getWidth()
    love.graphics.setColor(0, 0, 1)

    love.graphics.print( text, font, (ww * 0.5 - textW * 0.5) - 50, 30)
    love.graphics.print( players, font1, (ww * 0.5 - playersW * 0.5) - 50, 5 )
end