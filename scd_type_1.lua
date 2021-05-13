local format = {
    { name = 'id',              type = 'string' },
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

local function get_last(self, id)
    return self.space:get({ id })
end

local function get_all(self, id)
    return { get_last(self, id) }
end

local function insert(self, profile)
    self.space:replace(flatten(profile))
end

local function update(self, profile)
    self.space:replace(profile)
end

local function new(space_name)
    local instance = {
        space = create_space(space_name),

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
