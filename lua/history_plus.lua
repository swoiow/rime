local shared = require("shared_history")
local MAX_HISTORY_AGE = 15 -- 允许历史记录的最大秒数

local function history_processor(key_event, env)
    local ctx = env.context or (env.engine and env.engine.context)

    if not env._history_connected then
        env._history_connected = true
        ctx.commit_notifier:connect(
            function(ctx)
                shared.add_history(ctx)
            end
        )
    end

    local repr = key_event:repr()

    if repr == "BackSpace" and not ctx:is_composing() then
        shared.shrink()
    end

    return 2 -- kNoop
end

local function history_filter(input, env)
    local ctx = env.context or (env.engine and env.engine.context)
    local composing = ctx:get_commit_text() or ctx.input
    local composing_len = utf8.len(composing) or #composing

    if not composing or not composing:match("^vh") then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    local count = 0
    for _, text in ipairs(shared.latest(MAX_HISTORY_AGE)) do
        yield(Candidate("history", 0, composing_len, text, "〔历史〕"))
        count = count + 1
        if count >= 5 then
            break
        end
    end

    for cand in input:iter() do
        yield(cand)
    end
end

return {
    processor = history_processor,
    filter = history_filter
}
