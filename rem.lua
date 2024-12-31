local rem = {}

-- função para remover os florins arremessados que voltaram ao estado "idle"
function rem.florim()
    for i = #florins_trown, 1, -1 do
        if florins_trown[i].state == "idle" then
            table.remove(florins_trown, i)
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