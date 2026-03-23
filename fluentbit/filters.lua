local durations = {}
local seen_uuids_agg = {}
local seen_uuids_raw = {}
local last_flush_time = os.time()
local last_flush_time_raw = os.time()
local window_size = 60
local sampling_rate = 0.2 -- 20%

-- Process raw logs: Deduplicate, Error Filter, and Sampling
function process_raw(tag, timestamp, record)
    local uuid = record["uuid"]
    local now = os.time()
    
    -- 1. Cache maintenance
    if now - last_flush_time_raw >= window_size then
        seen_uuids_raw = {}
        last_flush_time_raw = now
    end

    -- 2. Deduplication
    if uuid then
        if seen_uuids_raw[uuid] then
            return -1, 0, 0
        end
        seen_uuids_raw[uuid] = true
    end

    -- 3. Error detection
    local is_error = (record["level"] == "error")

    -- 4. Pass errors, sample normal logs
    if is_error then
        return 2, timestamp, record
    else
        -- Sampling for non-error logs
        if math.random() <= sampling_rate then
            return 2, timestamp, record
        end
    end

    -- Drop everything else
    return -1, 0, 0
end

-- Aggregate (for metrics): Deduplicate and calculate stats
function aggregate(tag, timestamp, record)
    local uuid = record["uuid"]
    local duration = record["duration"]
    local now = os.time()

    -- 1. Deduplication for metrics (to ensure stats are accurate)
    if uuid then
        if seen_uuids_agg[uuid] then
            return -1, 0, 0
        end
        seen_uuids_agg[uuid] = true
    end

    -- 2. Accumulate duration
    local d_num = tonumber(duration)
    if d_num then
        table.insert(durations, d_num)
    end

    -- 3. Periodic aggregation
    if now - last_flush_time >= window_size then
        if #durations == 0 then
            last_flush_time = now
            seen_uuids_agg = {}
            return -1, 0, 0
        end

        table.sort(durations)
        local count = #durations
        local min = durations[1]
        local max = durations[count]
        local sum = 0
        for _, v in ipairs(durations) do
            sum = sum + v
        end
        local avg = sum / count
        local p95 = durations[math.ceil(count * 0.95)]

        local metrics = {
            avg = avg,
            max = max,
            min = min,
            p95 = p95,
            count = count,
            window_start = last_flush_time,
            window_end = now,
            message_type = "aggregated_metrics"
        }

        durations = {}
        seen_uuids_agg = {}
        last_flush_time = now
        return 2, timestamp, metrics
    end

    -- Drop individual records from metrics stream
    return -1, 0, 0
end
