local _M = {}

-- Constants (in milliseconds)
local GC_INTERVAL_MIN_MS = 50000
local GC_INTERVAL_MAX_MS = 70000
local MEMORY_GROWTH_THRESHOLD_KB = 256
local TICK_INTERVAL_MIN_MS = 2000
local TICK_INTERVAL_MAX_MS = 8000
local TICK_INTERVAL_MULTIPLIER = 50

local function get_timestamp()
	-- TODO: Replace with your framework's millisecond timestamp implementation
	-- return quick.timemillis()
	return 0
end

local function get_gc_interval()
	return math.random(GC_INTERVAL_MIN_MS, GC_INTERVAL_MAX_MS)
end

local function get_memory()
	return collectgarbage "count"
end

local function start_gc()
	collectgarbage "collect"
end

local last_gc_timestamp = get_timestamp()
local last_memory_kb = get_memory()
local max_gc_interval = get_gc_interval()
local next_tick_timestamp = get_timestamp()

-- Call per second
function _M.tick()
	local current_time = get_timestamp()
	if current_time < next_tick_timestamp then
		return
	end

	local should_gc = false
	-- If memory growth exceeds threshold within max_gc_interval, trigger GC
	if current_time - last_gc_timestamp < max_gc_interval then
		local current_mem_kb = get_memory()
		if current_mem_kb - last_memory_kb > MEMORY_GROWTH_THRESHOLD_KB then
			should_gc = true
		end
	else
		-- Force GC when interval expires
		should_gc = true
	end

	if should_gc then
		start_gc()
		local gc_end_time = get_timestamp()
		local gc_duration_ms = gc_end_time - current_time
		last_gc_timestamp = gc_end_time
		last_memory_kb = get_memory()
		-- Delay next check based on GC time cost
		local tick_interval_ms = gc_duration_ms * TICK_INTERVAL_MULTIPLIER
		if tick_interval_ms < TICK_INTERVAL_MIN_MS then
			tick_interval_ms = TICK_INTERVAL_MIN_MS
		end
		if tick_interval_ms > TICK_INTERVAL_MAX_MS then
			tick_interval_ms = TICK_INTERVAL_MAX_MS
		end
		next_tick_timestamp = gc_end_time + tick_interval_ms
		max_gc_interval = get_gc_interval()
	end
end

return _M