-- ChunkStreamer.lua
-- Manages chunk loading/unloading based on player position

local ChunkStreamer = {}
ChunkStreamer.__index = ChunkStreamer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

function ChunkStreamer.new(terrainGenerator)
    local self = setmetatable({}, ChunkStreamer)
    self.generator = terrainGenerator
    self.loadedChunks = {}
    self.loadQueue = {}
    self.unloadDistance = terrainGenerator.renderDistance * 1.5
    return self
end

function ChunkStreamer:update(playerPosition)
    local cx = math.floor(playerPosition.X / self.generator.chunkSize)
    local cz = math.floor(playerPosition.Z / self.generator.chunkSize)
    local radius = math.ceil(self.generator.renderDistance / self.generator.chunkSize)
    
    for dx = -radius, radius do
        for dz = -radius, radius do
            local key = (cx + dx) .. "," .. (cz + dz)
            if not self.loadedChunks[key] then
                table.insert(self.loadQueue, {cx + dx, cz + dz, key})
            end
        end
    end
    
    -- Unload distant chunks
    for key, _ in pairs(self.loadedChunks) do
        local parts = string.split(key, ",")
        local dist = math.sqrt(
            (tonumber(parts[1]) - cx)^2 + (tonumber(parts[2]) - cz)^2
        ) * self.generator.chunkSize
        if dist > self.unloadDistance then
            self:_unloadChunk(key)
        end
    end
end

function ChunkStreamer:processQueue(maxPerFrame)
    maxPerFrame = maxPerFrame or 2
    for i = 1, math.min(maxPerFrame, #self.loadQueue) do
        local item = table.remove(self.loadQueue, 1)
        if item then
            self.generator:generateChunk(item[1], item[2])
            self.loadedChunks[item[3]] = true
        end
    end
end

function ChunkStreamer:_unloadChunk(key)
    self.loadedChunks[key] = nil
end

return ChunkStreamer
