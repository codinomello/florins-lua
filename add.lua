local add = {}

-- função para adicionar florins ao bando
function add.florim(x, y)
    table.insert(florins, {x = x, y = y, speed = 150, state = "idle"})
end
  
-- função para adicionar objetos no cenário
function add.object(x, y, hp)
    table.insert(objects, {x = x, y = y, radius = 30, hp = hp})
end

return add