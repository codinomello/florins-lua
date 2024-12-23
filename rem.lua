local rem = {}

-- função para remover os florins arremessados que voltaram ao estado "idle"
function rem.florim()
    for i = #florim_thrown, 1, -1 do
        if florim_thrown[i].state == "idle" then
            table.remove(florim_thrown, i)
        end
    end
end
  
-- função para remover objetos do cenário
function rem.object()
    for i = #objects, 1, -1 do
        if objects[i].hp <= 0 then
            table.remove(objects, i)
        end
    end
end

return rem