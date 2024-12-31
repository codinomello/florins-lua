--[[ 
    alt + l (rodar o jogo)
    w, a, s, d (movimento)
    espaço (arremessar florins)
    q (apito)
    m (música)
]]

-- dependências internas
local add = require("add")
local rem = require("rem")
local input = require("input")
local sound = require("sound")
local map = require("map")

-- libraries externas
local anim8 = require("libraries/anim8")
local hump = require("libraries/hump")

--- inicialização ---
function love.load()
    -- configurações iniciais
    love.window.setTitle("Florins")
    love.window.setMode(800, 600)

    -- carrega a fonte rubik
    font_rubik = love.graphics.newFont("fonts/rubik.ttf", 14)

    -- variáveis do fundo
    background = love.graphics.newImage("assets/background/background.png")

    -- câmera
    --camera = camera()
    
    -- sons
    sound.load()
    
    -- ponto de entrega
    delivery_point = {x = 400, y = 300}

    -- jogador
    player = {}
    player.x = 400
    player.y = 300
    player.speed = 200
    player.image = love.graphics.newImage("assets/player/player.png")

    -- variável para armazenar o estado do apito
    whistle_active = false

    -- florins
    florins = {}
    florins_trown = {}   -- lista de florins arremessados
    florins.spacing = 50 -- espaçamento entre os florins
    florins.count = 5

    -- objetos (x, y hp)
    objects = {}

    add.object(500, 300, 100)
    add.object(600, 400, 50)

    -- adiciona itens (não implementado)
    items = {}

    add.item(100, 150, false)
    add.item(200, 200, false)

    -- adiciona florins ao bando
    for i = 1, florins.count do
        add.florim(player.x + math.random(-50, 50), player.y + math.random(-50, 50))
    end
end

--- atualização ---
function love.update(dt)
    -- movimento do líder
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then player.y = player.y - player.speed * dt end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then player.x = player.x - player.speed * dt end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then player.y = player.y + player.speed * dt end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then player.x = player.x + player.speed * dt end

    -- movimento dos florins (seguem o líder quando não estão arremessados)
    for _, florim in ipairs(florins) do
        if florim.state == "idle" then
            local dx = player.x - florim.x
            local dy = player.y - florim.y
            local distance = math.sqrt(dx^2 + dy^2)

            -- move o florim apenas se estiver fora do espaçamento
            if distance > florins.spacing then
                florim.x = florim.x + (dx / distance) * florim.speed * dt
                florim.y = florim.y + (dy / distance) * florim.speed * dt
            end

            -- separação entre florins (evita sobreposição)
            local florin_separation = 25
            for _, other in ipairs(florins) do
                if florim ~= other then
                    local dx = florim.x - other.x
                    local dy = florim.y - other.y
                    local distance = math.sqrt(dx^2 + dy^2)

                    if distance < florin_separation then
                        florim.x = florim.x + (dx / distance) * florin_separation * dt
                        florim.y = florim.y + (dy / distance) * florin_separation * dt
                    end
                end
            end

            -- verifica se o florim pode pegar um item
            if not florim.carrying then
                for _, item in ipairs(items) do
                    local item_dx = item.x - florim.x
                    local item_dy = item.y - florim.y
                    local item_distance = math.sqrt(item_dx^2 + item_dy^2)

                    if item_distance < 10 and not item.picked then
                        item.picked = true
                        florim.carrying = item
                        break
                    end
                end
            else
                -- verifica se o florim chegou ao ponto de entrega
                local delivery_dx = delivery_point.x - florim.x
                local delivery_dy = delivery_point.y - florim.y
                local delivery_distance = math.sqrt(delivery_dx^2 + delivery_dy^2)

                if delivery_distance < 10 then
                    florim.carrying = nil
                end
            end
        end
    end

    -- movimento dos florins arremessados
    for _, florim in ipairs(florins_trown) do
        local dx = florim.target.x - florim.x
        local dy = florim.target.y - florim.y
        local distance = math.sqrt(dx^2 + dy^2)

        if distance > 5 then
            florim.x = florim.x + (dx / distance) * 300 * dt
            florim.y = florim.y + (dy / distance) * 300 * dt
        else
            -- quando o florim atinge o alvo
            florim.target.hp = florim.target.hp - 10  -- dano no objeto
            florim.state = "idle"
            table.insert(florins, florim) -- retorna o florim à lista principal
        end
    end

    -- chama os florins inativos quando o apito está ativo
    if whistle_active then
        for _, florim in ipairs(florins) do
            local dx = player.x - florim.x
            local dy = player.y - florim.y
            local distance = math.sqrt(dx^2 + dy^2)

            if distance > 5 then
                florim.x = florim.x + (dx / distance) * 200 * dt
                florim.y = florim.y + (dy / distance) * 200 * dt
            end
        end
    end

    -- remove florins arremessados que voltaram ao estado "idle"
    rem.florim()

    -- remove objetos destruídos
    rem.object()
end

--- desenho ---
function love.draw()
    -- define a fonte rubik
    love.graphics.setFont(font_rubik)
    
    -- fundo
    love.graphics.draw(background, 0, 0)

    -- câmera
    -- camera:attach(0, 0, 800, 600)
    
    -- desenha o líder
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", player.x, player.y, 20)
    --love.graphics.draw(player.image, player.x, player.y)
    
    -- desenha os florins
    for _, florim in ipairs(florins) do
        love.graphics.setColor(florim.color)
        love.graphics.circle("fill", florim.x, florim.y, 10)

        -- desenha o item carregado pelo florim, se houver
        if florim.carrying then
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", florim.x - 5, florim.y - 15, 10, 10)
        end
    end
    
    -- desenha os florins arremessados
    for _, florim in ipairs(florins_trown) do
        love.graphics.setColor(florim.color)
        love.graphics.circle("fill", florim.x, florim.y, 10)
    end
    
    -- desenha os objetos com hp
    for _, object in ipairs(objects) do
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", object.x, object.y, object.radius)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("HP: " .. object.hp, object.x - 22, object.y - 50)
    end

    -- desenha os itens
    for _, item in ipairs(items) do
        if not item.picked then
            love.graphics.setColor(1, 0, 1)
            love.graphics.rectangle("fill", item.x, item.y, 10, 10)
        end
    end

    -- desenha o ponto de entrega
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", delivery_point.x, delivery_point.y, 20, 20)

    -- cor final (branco)
    love.graphics.setColor(1, 1, 1)
end

--- input (pressionado) ---
function love.keypressed(key)
    input.keys(key)
end

--- output (solto) ---
function love.keyreleased(key)
    output.keys(key)
end