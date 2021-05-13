local log = require('log')

local work_dir = arg[1] or '.'

box.cfg({
    memtx_dir       = work_dir,
    wal_dir         = work_dir
})

local test_list = {
    'test_scd_type_1',
    'test_scd_type_2',
    'test_scd_type_4'
}

local success = true

for _, t in ipairs(test_list) do
    local test = require('tests.' .. t)
    local ok, res = xpcall(test.run, debug.traceback)
    if not ok or res ~= true then
        success = false
        log.error('%s: FAILED', t)
        if type(res) ~= 'boolean' then
            log.error('    %s', res)
        end
    end
end

if success then
    os.exit(0)
else
    os.exit(1)
end
