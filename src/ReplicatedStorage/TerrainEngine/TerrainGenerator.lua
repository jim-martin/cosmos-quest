-- TerrainGenerator.lua
-- Handles procedural terrain generation for planetary surfaces

local TerrainGenerator = {}
TerrainGenerator.__index = TerrainGenerator

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

function TerrainGenerator.new(config)
    local self = setmetatable({}, TerrainGenerator)
    self.seed = config.seed or os.time()
    self.chunkSize = config.chunkSize or 64
    self.renderDistance = config.renderDistance or 256
    self.heightScale = config.heightScale or 48
    self.biomeMap = config.biomeMap or require(script.Parent.BiomeMap)
    return self
end

function TerrainGenerator:generateChunk(cx, cz)
    local terrain = Workspace.Terrain
    local region = Region3.new(
        Vector3.new(cx * self.chunkSize, -self.heightScale, cz * self.chunkSize),
        Vector3.new((cx + 1) * self.chunkSize, self.heightScale * 2, (cz + 1) * self.chunkSize)
    )
    -- Perlin noise based heightmap
    for x = 0, self.chunkSize - 1, 4 do
        for z = 0, self.chunkSize - 1, 4 do
            local wx = cx * self.chunkSize + x
            local wz = cz * self.chunkSize + z
            local height = self:_sampleHeight(wx, wz)
            local material = self.biomeMap:getMaterial(wx, wz, height)
            terrain:FillBlock(
                CFrame.new(wx, height / 2, wz),
                Vector3.new(4, height, 4),
                material
            )
        end
    end
end

function TerrainGenerator:_sampleHeight(x, z)
    local n1 = math.noise(x / 128, z / 128, self.seed) * self.heightScale
    local n2 = math.noise(x / 32, z / 32, self.seed + 1) * (self.heightScale / 4)
    local n3 = math.noise(x / 8, z / 8, self.seed + 2) * (self.heightScale / 16)
    return math.max(4, n1 + n2 + n3 + self.heightScale)
end

function TerrainGenerator:_getEdgeFalloff(x, z, chunkSize)
    local edgeDist = math.min(
        math.min(x, chunkSize - x),
        math.min(z, chunkSize - z)
    )
    return math.clamp(edgeDist / 8, 0, 1)
end

return TerrainGenerator
