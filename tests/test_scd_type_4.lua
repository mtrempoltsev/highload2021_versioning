local engine = require('scd_type_4').new('test_scd_type_4')

local p1 = {
    id = 'p1',
    first_name = 'n1',
    last_name = 'l1',
    date_of_birth = 'd1',
    place_of_birth = 'pb1',
    company = 'c1',
    job_title = 'j1',
    phone = 'ph1',
    email = 'e1'
}

local p2 = {
    id = 'p2',
    first_name = 'n2',
    last_name = 'l2',
    date_of_birth = 'd2',
    place_of_birth = 'pb2',
    company = 'c2',
    job_title = 'j2',
    phone = 'ph2',
    email = 'e2'
}

local function assert(x, y)
    if x ~= y then
        error(string.format('%q ~= %q', x, y))
    end
end

local function assert_not(x, y)
    if x == y then
        error(string.format('%q == %q', x, y))
    end
end

local function assert_less(x, y)
    if x >= y then
        error(string.format('%q >= %q', x, y))
    end
end

local function run()
    engine:insert(p1)
    local t1 = engine:get_last(p1.id)

    assert_not(t1.version, nil)
    assert(t1.email, 'e1')
    assert(#engine:get_all(p1.id), 1)

    engine:update('p1', {{ '=', 'email', 'e1u' }})

    assert(engine:get_last(p1.id).email, 'e1u')
    assert(#engine:get_all(p1.id), 2)
    assert(engine:get_all(p1.id)[1].email, 'e1u')
    assert(engine:get_all(p1.id)[2].email, 'e1')

    assert_less(
        engine:get_all(p1.id)[2].version,
        engine:get_all(p1.id)[1].version)

    engine:insert(p2)
    local t2 = engine:get_last(p2.id)

    assert_not(t2.version, nil)
    assert(t2.email, 'e2')
    assert(#engine:get_all(p2.id), 1)

    engine:update('p2', {{ '=', 'email', 'e2u' }})

    assert(engine:get_last(p2.id).email, 'e2u')
    assert(#engine:get_all(p2.id), 2)
    assert(engine:get_all(p2.id)[1].email, 'e2u')
    assert(engine:get_all(p2.id)[2].email, 'e2')

    engine:update('p2', {{ '=', 'email', 'e2uu' }})

    assert(engine:get_last(p2.id).email, 'e2uu')
    assert(#engine:get_all(p2.id), 3)
    assert(engine:get_all(p2.id)[1].email, 'e2uu')
    assert(engine:get_all(p2.id)[2].email, 'e2u')
    assert(engine:get_all(p2.id)[3].email, 'e2')

    return true
end

return {
    run = run
}
