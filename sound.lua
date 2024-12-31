sound = {}

function sound.load()
    --sounds.blip = love.audio.newSource("assets/sounds/blip.wav", "static")
    sound.music = love.audio.newSource("music/Pikmin - The Forest of Hope.mp3", "stream")
    sound.music:setLooping(true)
    sound.music:play(false)
end

return sound