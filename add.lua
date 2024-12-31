local add = {}

-- função para adicionar florins ao bando
function add.florim(x, y)
    local predefined_colors = {
        {1, 0, 0},    -- vermelho
        {0, 1, 0},    -- verde
        {0, 0, 1},    -- azul
        {1, 1, 0},    -- amarelo
        {1, 0, 1},    -- magenta
        {0, 1, 1},    -- ciano
        {1, 0.5, 0},  -- laranja
        {0.5, 0, 0.5} -- roxo
    }    

    local florim = {
        x = x,
        y = y,
        speed = 130,
        state = "idle",
        carrying = nil,
        color = predefined_colors[math.random(#predefined_colors)] -- cor aleatória
    }

    table.insert(florins, florim)
end
  
-- função para adicionar objetos no cenário
function add.object(x, y, hp)
    local object = {
        x = x, 
        y = y, 
        radius = 30, 
        hp = hp
    }

    table.insert(objects, object)
end

function add.item(x, y, picked)
    local item = {
        x = x,
        y = y,
        picked = false
    }

    table.insert(items, item)
end

return add