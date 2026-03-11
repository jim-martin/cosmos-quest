-- TerrainSeamTest.lua
--验证 chunk 边界处不再有接缝伪影
-- Automated regression test for terrain chunk seam artifacts

local TerrainGenerator = require(game.ReplicatedStorage.TerrainEngine.TerrainGenerator)

local TestRunner = {}

function TestRunner:run()
    local generator = TerrainGenerator.new({
        seed = 42,
        chunkSize = 64,
        heightScale = 48,
        blendWidth = 8
    })
    
    local results = {}
    
    -- Test: heights at chunk boundary should be within tolerance
    -- Sample along the x=64 boundary between chunk (0,0) and (1,0)
    local maxDelta = 0
    for z = 0, 63, 4 do
        local h_left = generator:_sampleHeight(63, z)
        local h_right = generator:_sampleHeight(64, z)
        
        -- Apply falloff as generateChunk would
        local falloff_left = generator:_getEdgeFalloff(63, z, 64)
        local falloff_right = generator:_getEdgeFalloff(0, z, 64)
        
        h_left = h_left * falloff_left + 48 * (1 - falloff_left)
        h_right = h_right * falloff_right + 48 * (1 - falloff_right)
        
        local delta = math.abs(h_left - h_right)
        maxDelta = math.max(maxDelta, delta)
    end
    
    table.insert(results, {
        name = "chunk_boundary_height_continuity",
        passed = maxDelta < 2.0,  -- 2 stud tolerance
        maxDelta = maxDelta
    })
    
    -- Test: edge falloff is 0 at boundary and 1 at center
    local falloff_edge = generator:_getEdgeFalloff(0, 32, 64)
    local falloff_center = generator:_getEdgeFalloff(32, 32, 64)
    
    table.insert(results, {
        name = "edge_falloff_range",
        passed = falloff_edge == 0 and falloff_center == 1,
        edge = falloff_edge,
        center = falloff_center
    })
    
    return results
end

return TestRunner
