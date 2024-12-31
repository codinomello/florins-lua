input = {}
output = {}

--- input ---
function input.keys(key)
    if key == "space" and #florins > 0 then
    -- verifica se há objetos disponíveis
        if #objects > 0 then
            -- remove o primeiro florim da lista principal
            local florim = table.remove(florins, 1)

            -- define o alvo mais próximo (ou o primeiro da lista, dependendo da lógica)
            florim.target = objects[1] -- Pode melhorar com a lógica de "alvo mais próximo"
            florim.state = "thrown"

            -- adiciona o florim à lista de arremessados
            table.insert(florins_trown, florim)
        end
    elseif key == "q" then
        -- ativa o apito
        whistle_active = true
    end

    -- pega itens
    if key == "e" then
        for _, florim in ipairs(florins) do
            if not florim.carrying then
                for _, item in ipairs(items) do
                    local item_distance_x = item.x - florim.x
                    local item_distance_y = item.y - florim.y
                    local item_distance = math.sqrt(item_distance_x^2 + item_distance_y^2)

                    if item_distance < 10 and not item.picked then
                        item.picked = true
                        florim.carrying = item
                        break
                    end
                end
            end
        end
    end

    -- controle da música
    if key == "m" then
        if sound.music:isPlaying() then
            sound.music:pause()
        else
            sound.music:play()
        end
    end
end

--- output ---
function output.keys(key)
    if key == "q" then
        -- desativa o apito
        whistle_active = false
    end
end

return input, output