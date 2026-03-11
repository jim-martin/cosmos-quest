-- GameManager.lua
-- Core game loop and session management

local GameManager = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local TerrainGenerator = require(ReplicatedStorage.TerrainEngine.TerrainGenerator)
local ChunkStreamer = require(ReplicatedStorage.TerrainEngine.ChunkStreamer)

local playerStore = DataStoreService:GetDataStore("PlayerData_v3")

local activeStreamer = nil

function GameManager:init()
    local generator = TerrainGenerator.new({
        seed = 42,
        chunkSize = 64,
        renderDistance = 256,
        heightScale = 48
    })
    activeStreamer = ChunkStreamer.new(generator)
    
    Players.PlayerAdded:Connect(function(player)
        self:_onPlayerJoined(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:_onPlayerLeft(player)
    end)
end

function GameManager:_onPlayerJoined(player)
    local data = playerStore:GetAsync("player_" .. player.UserId) or {
        position = {0, 100, 0},
        inventory = {},
        questProgress = {}
    }
    -- Spawn player at saved position
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(
            unpack(data.position)
        )
    end)
end

function GameManager:_onPlayerLeft(player)
    -- Save handled by auto-save system
end

return GameManager
