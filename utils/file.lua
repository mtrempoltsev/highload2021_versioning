local fio = require('fio')

local buf_size = 4096

local function readline(self)
    local res = ""

    while true do
        if self.buf == nil then
            self.buf, err = self.handle:read(buf_size)

            if err ~= nil then
                return nil, err
            end

            if self.buf == "" then
                return res
            end

            self.pos = 1
        end

        local n = string.find(self.buf, '\n', self.pos)
        if n ~= nil then
            res = res .. string.sub(self.buf, self.pos, n)
            self.pos = n + 1
            return res
        end

        res = res .. string.sub(self.buf, self.pos)
        self.buf = nil
    end
end

local function close(self)
    self.handle:close()
end

local function open(filename)
    local handle, err = fio.open(filename, { 'O_RDONLY' })
    if err ~= nil then
        return nil, err
    end

    local instance = {
        handle = handle,
        buf = nil,
        readline = readline,
        close = close
    }

    return instance
end

return {
    open = open
}