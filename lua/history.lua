-- 历史记录表（最多保存10条）
local history = {}

-- processor：记录历史输入
function history_processor(key_event, env)
  local ctx = env.engine.context
  if key_event:repr() == "space" and ctx:is_composing() then
    local commit_text = ctx:get_commit_text()
    if commit_text and #commit_text > 0 then
      table.insert(history, 1, commit_text)
      if #history > 10 then
        table.remove(history)
      end
    end
  end
  return 2  -- 即 kNoop
end

-- translator：返回历史记录候选
function history_translator(input, seg, env)
  for i, text in ipairs(history) do
    if i > 5 then break end
    yield(Candidate("history", seg.start, seg._end, text, "〔历史〕"))
  end
end

function history_filter(input, env)
  local inserted = false
  local index = 0
  for cand in input:iter() do
    yield(cand)
    index = index + 1
    if not inserted and index == 1 then
      for i, text in ipairs(history) do
        if i > 5 then break end
        yield(Candidate("history", cand.start, cand._end, text, "〔历史〕"))
      end
      inserted = true
    end
  end
end

return { history_processor = history_processor, history_filter = history_filter, }
