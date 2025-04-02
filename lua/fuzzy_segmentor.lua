-- 定义模糊音映射规则
local fuzzy_map = {
  zh = "z",  z = "zh",
  ch = "c",  c = "ch",
  sh = "s",  s = "sh",
  l = "n",   n = "l",
  in = "ing", ing = "in",
}

-- segmentor 入口函数
local function segmentor(segmentation, env)
  local context = env.engine.context
  local option_name = "enable_fuzzy"

  -- 如果用户没有开启模糊音，直接返回
  if not context:get_option(option_name) then
    return 2  -- kNoop
  end

  -- 遍历每一个 segment，并替换其中的模糊音
  for i = 0, segmentation:count() - 1 do
    local seg = segmentation:segment(i)
    local input_text = seg:get_genuine().text
    local replacement = fuzzy_map[input_text]
    if replacement then
      seg:get_genuine().text = replacement
    end
  end

  return 0  -- 成功处理
end

return segmentor

