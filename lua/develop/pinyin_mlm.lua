local filter = {}

function filter.init(env)
    env.history = {}
    env.engine.context.commit_notifier:connect(function(ctx)
        -- 获取当前提交的文本
        local text = ctx:get_commit_text()
        -- 将文本插入历史记录表的开头
        table.insert(env.history, 1, text)
        -- 保持历史记录的长度不超过5
        if #env.history > 5 then
            table.remove(env.history)
        end
    end)
end

function filter.func(input, env)
    -- 先生成原始输入的候选项
    for cand in input:iter() do
        yield(cand)
    end

    -- 然后生成历史记录的候选项
    for i, text in ipairs(env.history) do
        -- 创建一个新的候选项，类型为 "history"
        local cand = Candidate("history", 0, 0, text, "历史记录")
        yield(cand)
    end
end

return filter
