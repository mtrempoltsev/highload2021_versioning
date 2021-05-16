local clock = require('clock')
local json = require('json')
local fio = require('fio')
local log = require('log')

local reader = require('utils.reader')

local function load_data(engine, work_dir)
    local profiles, err = reader.open(fio.pathjoin(work_dir, 'profiles.jsonl'))
    if err ~= nil then
        log.error(err)
        os.exit(1)
    end

    while true do
        local p = profiles:next()
        if p == nil then
            break
        end

        engine:insert(p)
    end
end

local function update_data(engine, work_dir)
    local changes, err = reader.open(fio.pathjoin(work_dir, 'changes.jsonl'))
    if err ~= nil then
        log.error(err)
        os.exit(1)
    end
    
    while true do
        local c = changes:next()
        if c == nil then
            break
        end

        local updates = {}
        for k, v in ipairs(c.fields) do
            table.insert(updates, { '=', k, v })
        end
        engine:update(c.id, updates)
    end
end

local function read_data(engine, work_dir)
    local profiles, err = reader.open(fio.pathjoin(work_dir, 'profiles.jsonl'))
    if err ~= nil then
        log.error(err)
        os.exit(1)
    end

    while true do
        local p = profiles:next()
        if p == nil then
            break
        end

        engine:get_last(p.id)
    end
end

local function run(scd_type, work_dir)
    box.cfg({
        memtx_memory    = 1024 * 1024 * 1024,
        memtx_dir       = work_dir,
        wal_dir         = work_dir
    })

    local engine = require(scd_type).new(scd_type)

    log.info('loadind data')
    local start = clock.monotonic()
    load_data(engine, work_dir)
    log.info('spent %f sec', clock.monotonic() - start)

    log.info('updating data')
    start = clock.monotonic()
    update_data(engine, work_dir)
    log.info('spent %f sec', clock.monotonic() - start)

    log.info('reading actual data')
    start = clock.monotonic()
    read_data(engine, work_dir)
    log.info('spent %f sec', clock.monotonic() - start)
end

local scd_type_list = {
    'scd_type_1',
    'scd_type_2',
    'scd_type_3',
    'scd_type_4'
}

if #arg ~= 2 then
    log.error('usage: runner.lua SCD_TYPE WORK_DIR')
    log.error('    where SCD_TYPE in ' .. json.encode(scd_type_list))
    os.exit(1)
end

local scd_type = arg[1]
local work_dir = arg[2]

for _, t in ipairs(scd_type_list) do
    if t == scd_type then
        run(scd_type, work_dir)
        os.exit(0)
    end
end

log.error('available SCD_TYPE values: ' .. json.encode(scd_type_list))
os.exit(1)
