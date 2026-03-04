--[[
    ObjectPool.lua
    Created by @ddydddd9 - Moonlight

    Efficient object pooling system for reusing instances with configurable
    capacity, automatic reset, and performance optimization
]]

local ObjectPool = {}

local slot_instance         = {}   -- [id] -> Instance
local slot_inuse            = {}   -- [id] -> bool
local slot_pool_name        = {}   -- [id] -> string (pool name)

local pool_free_slots       = {}   -- [name] -> { slot_ids... }
local pool_slots            = {}   -- [name] -> { all slot_ids... }
local pool_template_function= {}   -- [name] -> function() -> Instance
local pool_reset_function   = {}   -- [name] -> function(instance)
local pool_initial_capacity = {}   -- [name] -> number
local pool_max_capacity     = {}   -- [name] -> number (hard cap)
local pool_count            = {}   -- [name] -> number (total allocated)

local next_slot_id = 0

local function new_slot(name)
    next_slot_id += 1
    local slot_id = next_slot_id
    local slot_object = pool_template_function[name]()

    slot_instance[slot_id] = slot_object
    slot_inuse[slot_id]    = false
    slot_pool_name[slot_id]= name
    pool_count[name] += 1

    local slots_list = pool_slots[name]
    slots_list[#slots_list + 1] = slot_id

    return slot_id
end

-- Register a pool
-- name         : string
-- template     : function() -> Instance   (called to create a new object)
-- reset        : function(instance)        (called on Release to clean state)
-- capacity     : number                    (initial pre-allocation count)
-- max_capacity : number                    (hard cap, defaults to capacity * 2)
function ObjectPool.Register(name, template, reset, capacity, max_capacity)
    assert(not pool_free_slots[name], "Pool already registered: " .. name)
    assert(type(template) == "function", "template must be a function")
    assert(type(reset)    == "function", "reset must be a function")

    pool_template_function[name] = template
    pool_reset_function[name]    = reset
    pool_initial_capacity[name]   = capacity or 8
    pool_max_capacity[name]      = max_capacity or (pool_initial_capacity[name] * 2)
    pool_count[name]    = 0
    pool_free_slots[name]     = {}
    pool_slots[name]    = {}

    for _ = 1, pool_initial_capacity[name] do
        local new_slot_id = new_slot(name)
        local free_slots = pool_free_slots[name]
        free_slots[#free_slots + 1] = new_slot_id
    end
end

-- Borrow an instance from the pool, returns; instance, slot_id
function ObjectPool.Acquire(name)
    local free_slots = pool_free_slots[name]
    assert(free_slots, "Unknown pool: " .. name)

    local slot_id

    if #free_slots > 0 then
        slot_id = free_slots[#free_slots]
        free_slots[#free_slots] = nil
    else
        if pool_count[name] >= pool_max_capacity[name] then
            warn("[ObjectPool] '" .. name .. "' hit hard cap of " .. pool_max_capacity[name])
            return nil, nil
        end

        slot_id = new_slot(name)
    end

    slot_inuse[slot_id] = true
    return slot_instance[slot_id], slot_id
end

-- Return an instance back to the pool
function ObjectPool.Release(name, slot_id)
    assert(pool_free_slots[name],           "Unknown pool: " .. name)
    assert(slot_instance[slot_id] ~= nil,  "Slot " .. slot_id .. " does not exist")
    assert(slot_pool_name[slot_id] == name,     "Slot " .. slot_id .. " does not belong to '" .. name .. "'")

    if not slot_inuse[slot_id] then
        warn("[ObjectPool] Double-release ignored for slot " .. slot_id)
        return
    end

    pool_reset_function[name](slot_instance[slot_id])
    slot_inuse[slot_id] = false

    local free_slots = pool_free_slots[name]
    free_slots[#free_slots + 1] = slot_id
end

-- Trim excess free slots back down to initial capacity
function ObjectPool.Shrink(name)
    assert(pool_free_slots[name], "Unknown pool: " .. name)

    local free_slots = pool_free_slots[name]
    local target = pool_initial_capacity[name]

    while #free_slots > target do
        local slot_id = free_slots[#free_slots]
        free_slots[#free_slots] = nil

        slot_instance[slot_id]:Destroy()
        slot_instance[slot_id] = nil
        slot_inuse[slot_id]    = nil
        slot_pool_name[slot_id]     = nil
        pool_count[name] -= 1

        -- remove from pool_slots
        local slots_list = pool_slots[name]
        for i = #slots_list, 1, -1 do
            if slots_list[i] == slot_id then
                slots_list[i] = slots_list[#slots_list]
                slots_list[#slots_list] = nil
                break
            end
        end
    end
end

-- Returns true if the pool has more free slots than its initial capacity
-- Useful to decide when to call Shrink
function ObjectPool.ShouldShrink(name)
    assert(pool_free_slots[name], "Unknown pool: " .. name)
    return #pool_free_slots[name] > pool_initial_capacity[name]
end

-- Resize the initial capacity and hard cap, and pre-allocates up to the new capacity if needed
function ObjectPool.Resize(name, new_capacity, new_max_capacity)
    assert(pool_free_slots[name], "Unknown pool: " .. name)
    assert(type(new_capacity) == "number" and new_capacity > 0, "new_capacity must be a positive number")

    local old_cap = pool_initial_capacity[name]
    pool_initial_capacity[name] = new_capacity
    pool_max_capacity[name]    = new_max_capacity or (new_capacity * 2)

    -- pre-allocate if growing
    if new_capacity > old_cap then
        local free_slots = pool_free_slots[name]
        for _ = 1, (new_capacity - old_cap) do
            if pool_count[name] < pool_max_capacity[name] then
                local new_slot_id = new_slot(name)
                free_slots[#free_slots + 1] = new_slot_id
            end
        end
    end
end

-- Fully clean up a pool and destroy all its instances
function ObjectPool.Destroy(name)
    assert(pool_free_slots[name], "Unknown pool: " .. name)

    for _, slot_id in ipairs(pool_slots[name]) do
        if slot_instance[slot_id] then
            slot_instance[slot_id]:Destroy()
        end

        slot_instance[slot_id] = nil
        slot_inuse[slot_id]    = nil
        slot_pool_name[slot_id]= nil
    end

    pool_free_slots[name]     = nil
    pool_slots[name]    = nil
    pool_template_function[name] = nil
    pool_reset_function[name]    = nil
    pool_initial_capacity[name]   = nil
    pool_max_capacity[name]      = nil
    pool_count[name]    = nil
end

-- Read-only access to a slot's instance without acquiring
function ObjectPool.Peek(slot_id)
    assert(slot_instance[slot_id] ~= nil, "Peek on invalid or destroyed slot: " .. tostring(slot_id))
    return slot_instance[slot_id]
end

-- How many slots are currently free
function ObjectPool.FreeCount(name)
    assert(pool_free_slots[name], "Unknown pool: " .. name)
    return #pool_free_slots[name]
end

-- How many slots are currently in use
function ObjectPool.UsedCount(name)
    assert(pool_free_slots[name], "Unknown pool: " .. name)
    return pool_count[name] - #pool_free_slots[name]
end

-- Debug snapshot
function ObjectPool.Debug(name)
    assert(pool_free_slots[name], "Unknown pool: " .. name)
    print(string.format(
        "[ObjectPool] '%s' | allocated=%d  free=%d  inuse=%d  cap=%d max=%d",
        name,
        pool_count[name],
        #pool_free_slots[name],
        pool_count[name] - #pool_free_slots[name],
        pool_initial_capacity[name],
        pool_max_capacity[name]
    ))
end

return ObjectPool