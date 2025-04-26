-- shared_history.lua
local history = {}
local MAX_HISTORY_SIZE = 10

local function now()
    return os.time()
end

local function insert(text)
    if history[1] and history[1].text == text then
        return -- 不插入重复的
    end
    table.insert(history, 1, {text = text, time = now()})
    if #history > MAX_HISTORY_SIZE then
        table.remove(history, #history)
    end
end

local function shrink()
    local last = history[1]
    if last and #last.text > 1 then
        local len = utf8.offset(last.text, -1)
        if len then
            last.text = last.text:sub(1, len - 1)
        else
            table.remove(history, 1)
        end
    else
        table.remove(history, 1)
    end
end

local function latest(max_age)
    local current = now()
    local results = {}
    for _, item in ipairs(history) do
        if current - item.time <= max_age then
            table.insert(results, item.text)
            if #results >= 10 then
                break
            end
        end
    end
    return results
end

local function get_history(ctx)
    return history
end

local function add_history(ctx)
    local commit_text = ctx:get_commit_text() or nil
    if commit_text and #commit_text > 0 then
        insert(commit_text)
    end
end

return {
    insert = insert,
    shrink = shrink,
    latest = latest,
    now = now,
    get_history = get_history,
    add_history = add_history
}
