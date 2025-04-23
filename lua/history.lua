-- 历史记录表（最多保存10条）
local history = {}

-- 获取当前时间（秒）
local function now()
  return os.time()
end

-- processor：记录历史输入（仅记录10秒内的输入）
function history_processor(key_event, env)
  local ctx = env.context or (env.engine and env.engine.context)
  if key_event:repr() == "space" and ctx:is_composing() then
    local commit_text = ctx:get_commit_text()
    if commit_text and #commit_text > 0 then
      -- 记录文本和时间戳
      table.insert(history, 1, { text = commit_text, time = now() })
      -- 保留最多10条
      if #history > 10 then
        table.remove(history)
      end
    end
  end
  return 2  -- kNoop
end

-- filter：只有输入以 "vh" 开头才插入历史候选，且排除超过10秒前的记录
function history_filter(input, env)
  local ctx = env.context or (env.engine and env.engine.context)
  local composing = ctx:get_commit_text() or ctx.input

  -- 判断是否以 "vh" 开头
  if not composing or not composing:match("^vh") then
    -- 输入不是以 "vh" 开头，直接正常输出候选
    for cand in input:iter() do
      yield(cand)
    end
    return
  end

  -- 插入历史候选（最多5条，时间在10秒内）
  local current_time = now()
  for i, item in ipairs(history) do
    if i > 5 then break end
    if current_time - item.time <= 10 then
      yield(Candidate("history", 0, 0, item.text, "〔历史〕"))
    end
  end

  -- 然后输出原始候选列表
  for cand in input:iter() do
    yield(cand)
  end
end

return {
  history_processor = history_processor,
  history_filter = history_filter,
}
