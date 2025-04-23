-- cloud_predictor.lua
local http = require("simplehttp")
local json = require("libs/json")
local shared = require("shared_history")

local TRIGGER_INPUT = "vv"

local function reverse(t)
  local res = {}
  for i = #t, 1, -1 do
    table.insert(res, t[i])
  end
  return res
end

-- 云预测过滤器
local function cloud_filter(input, env)
  local ctx = env.context or (env.engine and env.engine.context)
  local composing = ctx:get_commit_text() or ctx.input
  local composing_len = utf8.len(composing) or #composing

  if not composing or composing ~= TRIGGER_INPUT then
    for cand in input:iter() do yield(cand) end
    return
  end

  local history_text = table.concat(reverse(shared.latest(10)), "")
  local full_text = history_text

  -- 发起 HTTP 请求
  local ok, reply = pcall(function()
    local url = "http://127.0.0.1:18000/predict?text=" .. full_text
    return http.request(url)
  end)

  if not ok or not reply then return end

  local ok2, result = pcall(json.decode, reply)
  if not ok2 or not result or result.status ~= 200 or not result.result then return end

  -- 记录云候选到环境变量中，供 processor 使用
  env.cloud_candidates = {}

  for _, item in ipairs(result.result) do
    local word = item.token or item.word or "?"
    table.insert(env.cloud_candidates, word)
    yield(Candidate("cloud", 0, composing_len, word, "〔云〕"))
  end
end

-- 云处理器：用户上屏云候选词时写入历史， TODO
local function cloud_processor(key_event, env)
  local ctx = env.context or (env.engine and env.engine.context)

  if not ctx:is_composing() then
    local commit_text = ctx:get_commit_text()
    if commit_text and #commit_text > 0 then
      local cloud_set = env.cloud_candidates or {}
      for _, word in ipairs(cloud_set) do
        if commit_text == word then
          shared.insert(commit_text)
          break
        end
      end
    end
  end

  return 2  -- kNoop
end

return {
  filter = cloud_filter,
  processor = cloud_processor
}
