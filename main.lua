--- florins: löve2D ---

--[[ 
    alt + l (rodar o jogo)
    w, a, s, d (movimento)
    espaço (arremessar florins)
    q (apito)
    m (música)
]]

-- função para adicionar florins no cenário

local add = require("add")
local rem = require("rem")

--- inicialização ---
function love.load()
    love.window.setTitle("florins")
    love.window.setMode(800, 600)

    -- carrega a fonte rubik
    font_rubik = love.graphics.newFont("fonts/rubik.ttf", 14)

    -- variáveis do fundo
    background = love.graphics.newImage("assets/background/background.png")
    
    -- sons
    sounds = {}
    --sounds.blip = love.audio.newSource("assets/sounds/blip.wav", "static")
    sounds.music = love.audio.newSource("music/Pikmin - The Forest of Hope.mp3", "stream")
    sounds.music:setLooping(true)
    sounds.music:play(false)
    
    -- jogador
    player = {x = 400, y = 300, speed = 200}

    -- variável para armazenar o estado do apito
    whistle_active = false

    -- variáveis dos florins
    florins = {}
    florim_count = 5
    florim_spacing = 30 -- espaçamento entre os florins
    florim_thrown = {}  -- lista de florins arremessados

    -- variáveis dos objetos no cenário
    objects = {}

    -- adiciona florins
    for i = 1, florim_count do
        add.florim(player.x + math.random(-50, 50), player.y + math.random(-50, 50))
    end

    -- adiciona objetos com HP
    add.object(500, 300, 50)
    add.object(600, 400, 80)
end

--- atualização ---
function love.update(dt)
    -- movimento do líder
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then player.y = player.y - player.speed * dt end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then player.x = player.x - player.speed * dt end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then player.y = player.y + player.speed * dt end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then player.x = player.x + player.speed * dt end

    -- movimento dos florins (seguem o líder quando não estão arremessados)
    for i, florim in ipairs(florins) do
        if florim.state == "idle" then
            local target_x, target_y
  
            if i == 1 then
                -- o primeiro florim segue diretamente o jogador
                target_x, target_y = player.x, player.y
            else
                -- os outros florins seguem o florim à frente
                target_x, target_y = florins[i - 1].x, florins[i - 1].y
            end
  
            -- calcula a distância para o alvo
            local dx = target_x - florim.x
            local dy = target_y - florim.y
            local distance = math.sqrt(dx^2 + dy^2)
  
            -- move o florim apenas se estiver longe demais do alvo
            if distance > florim_spacing then
                florim.x = florim.x + (dx / distance) * florim.speed * dt
                florim.y = florim.y + (dy / distance) * florim.speed * dt
            end
        end
    end

    -- movimento dos florins arremessados
    for _, florim in ipairs(florim_thrown) do
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

    -- desenha o líder
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", player.x, player.y, 20)
    
    -- desenha os florins
    for _, florim in ipairs(florins) do
        love.graphics.setColor(0, 0, 1)
        love.graphics.circle("fill", florim.x, florim.y, 10)
    end
    
    -- desenha os florins arremessados
    for _, florim in ipairs(florim_thrown) do
        love.graphics.setColor(0.5, 0.5, 1)
        love.graphics.circle("fill", florim.x, florim.y, 10)
    end
    
    -- desenha os objetos com HP
    for _, obj in ipairs(objects) do
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", obj.x, obj.y, obj.radius)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("HP: " .. obj.hp, obj.x - 20, obj.y - 40)
    end

    -- fundo
    --love.graphics.draw(background, 0, 0)
end

--- input (pressionado) ---
function love.keypressed(key)
    if key == "space" and #florins > 0 then
        -- verifica se há objetos disponíveis
        if #objects > 0 then
            -- remove o primeiro florim da lista principal
            local florim = table.remove(florins, 1)
  
            -- define o alvo mais próximo (ou o primeiro da lista, dependendo da lógica)
            florim.target = objects[1] -- Pode melhorar com a lógica de "alvo mais próximo"
            florim.state = "thrown"

            -- adiciona o florim à lista de arremessados
            table.insert(florim_thrown, florim)
        end
    elseif key == "q" then
        -- ativa o apito
        whistle_active = true
    end

    -- controle da música
    if key == "m" then
        if sounds.music:isPlaying() then
            sounds.music:pause()
        else
            sounds.music:play()
        end
    end
end

--- input (solto) ---
function love.keyreleased(key)
    if key == "q" then
        -- desativa o apito
        whistle_active = false
    end
end