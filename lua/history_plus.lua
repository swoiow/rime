local shared = require("shared_history")

local function history_processor(key_event, env)
  local ctx = env.context or (env.engine and env.engine.context)
  local repr = key_event:repr()

  if repr == "space" and ctx:is_composing() then
    local commit_text = ctx:get_commit_text()
    if commit_text and #commit_text > 0 then
      shared.insert(commit_text)
    end
  elseif repr == "BackSpace" and not ctx:is_composing() then
    shared.shrink()
  end

  return 2  -- kNoop
end

local function history_filter(input, env)
  local ctx = env.context or (env.engine and env.engine.context)
  local composing = ctx:get_commit_text() or ctx.input

  if not composing or not composing:match("^vh") then
    for cand in input:iter() do
      yield(cand)
    end
    return
  end

  local current_time = shared.now()
  local count = 0
  for _, text in ipairs(shared.latest(10)) do
    yield(Candidate("history", 0, 0, text, "〔历史〕"))
    count = count + 1
    if count >= 5 then break end
  end

  for cand in input:iter() do
    yield(cand)
  end
end

return {
  processor = history_processor,
  filter = history_filter,
}
