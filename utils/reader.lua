local json = require('json')

local file = require('utils.file')

local function close(self)
    if self.file ~= nil then
        self.file:close()
        self.file = nil
    end
end

local function next(self)
    if self.file == nil then
        return nil
    end

    local line, err = self.file:readline()
    if err ~= nil then
        return nil, err
    end

    if line == "" then
        return nil
    end

    local ok, obj = pcall(json.decode, line)
    if not ok then
        return nil, obj
    end

    return obj
end

local function open(filename)
    local file, err = file.open(filename)
    if err ~= nil then
        return nil, err
    end

    local instance = {
        file = file,

        next = next,
        close = close
    }

    return instance
end

return {
    open = open
}
