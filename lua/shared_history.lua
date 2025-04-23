-- shared_history.lua
local history = {}

local function now()
  return os.time()
end

local function insert(text)
  table.insert(history, 1, { text = text, time = now() })
  if #history > 10 then
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
    if current - item.time <= max_age then  -- 限制时间为10秒内
      table.insert(results, item.text)
      if #results >= 10 then
        break
      end
    end
  end
  return results
end

return {
  insert = insert,
  shrink = shrink,
  latest = latest,
  now = now,
  get_history = function() return history end,
}
