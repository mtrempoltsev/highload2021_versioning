local format = {
    { name = 'id',              type = 'string' },
    { name = 'first_name',      type = 'string' },
    { name = 'last_name',       type = 'string' },
    { name = 'date_of_birth',   type = 'string' },
    { name = 'place_of_birth',  type = 'string' },
    { name = 'old_company',     type = 'string',    is_nullable = true },
    { name = 'company',         type = 'string' },
    { name = 'job_title',       type = 'string' },
    { name = 'old_phone',       type = 'string',    is_nullable = true },
    { name = 'phone',           type = 'string' },
    { name = 'old_email',       type = 'string',    is_nullable = true },
    { name = 'email',           type = 'string' }
}

local function flatten(profile)
    return {
        profile.id,
        profile.first_name,
        profile.last_name,
        profile.date_of_birth,
        profile.place_of_birth,
        profile.old_company,
        profile.company,
        profile.job_title,
        profile.old_phone,
        profile.phone,
        profile.old_email,
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

local function clear_old(t)
    return t:update({
        { '=', 'old_company', box.NULL },
        { '=', 'old_phone', box.NULL },
        { '=', 'old_email', box.NULL }
    })
end

local function get_last(self, id)
    local t = self.space:get({ id })
    return clear_old(t)
end

local function get_all(self, id)
    local t = self.space:get({ id })

    if t.old_company == nil and t.old_phone == nil and t.old_email == nil then
        return { t }
    end

    local old = t:update({
        { '=', 'company', t.old_company or t.company },
        { '=', 'phone', t.old_phone or t.phone },
        { '=', 'email', t.old_email or t.email }
    })

    return {
        clear_old(t),
        clear_old(old)
    }
end

local function insert(self, profile)
    self.space:insert(flatten(profile))
end

local function update(self, id, updates)
    local t = get_last(self, id)

    for _, u in ipairs(updates) do
        if u[2] == 'company' then
            table.insert(updates, { '=', 'old_company', t.company })
        elseif u[2] == 'phone' then
            table.insert(updates, { '=', 'old_phone', t.phone })
        elseif u[2] == 'email' then
            table.insert(updates, { '=', 'old_email', t.email })
        end
    end

    self.space:replace(t:update(updates))
end

local function new(name)
    local instance = {
        space = create_space(name),

        get_last = get_last,
        get_all = get_all,
        insert = insert,
        update = update
    }

    return instance 
end

return {
    new = new
}
