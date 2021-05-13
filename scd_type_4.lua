local clock = require('clock')

local version_field = 2

local format = {
    { name = 'id',              type = 'string' },
    { name = 'version',         type = 'unsigned' },
    { name = 'first_name',      type = 'string' },
    { name = 'last_name',       type = 'string' },
    { name = 'date_of_birth',   type = 'string' },
    { name = 'place_of_birth',  type = 'string' },
    { name = 'company',         type = 'string' },
    { name = 'job_title',       type = 'string' },
    { name = 'phone',           type = 'string' },
    { name = 'email',           type = 'string' }
}

local function flatten(profile)
    return {
        profile.id,
        profile.version,
        profile.first_name,
        profile.last_name,
        profile.date_of_birth,
        profile.place_of_birth,
        profile.company,
        profile.job_title,
        profile.phone,
        profile.email
    }
end

local function create_space(name)
    local space = box.space[name]
    if space ~= nil then
        space:drop()
    end

    space = box.schema.space.create(name)
    space:format(format)
    space:create_index('id', { parts = { 'id' }})

    return space
end

local function create_history_space(name)
    local space = box.space[name]
    if space ~= nil then
        space:drop()
    end

    space = box.schema.space.create(name)
    space:format(format)
    space:create_index('id', { parts = { 'id', 'version' }})

    return space
end

local function get_last(self, id)
    return self.space:get({ id })
end

local function get_all(self, id)
    local res = { get_last(self, id) }
    for _, v in self.history_space:pairs({ id }, 'REQ') do
        table.insert(res, v)
    end
    return res
end

local function insert(self, profile)
    self.space:insert(flatten(profile))
end

local function update(self, id, updates)
    table.insert(updates, { '=', 'version', clock.time64() })
    local t = get_last(self, id)
    self.space:replace(t:update(updates))
end

local function new(name)
    local instance = {
        space = create_space(name),
        history_space = create_history_space(name .. '_history'),

        get_last = get_last,
        get_all = get_all,
        insert = insert,
        update = update
    }

    instance.space:before_replace(function(old, new)
        if old ~= nil then
            instance.history_space:insert(old)
        end

        return new:update({{ '=', version_field, clock.time64() }})
    end)

    return instance 
end

return {
    new = new
}
