-- lua/autocomplete.lua
local function translator(input, seg)
  local suggestions = {
    r = { "rime", "rime lua", "rime 配置" },
    py = { "python", "pygame", "pyinstaller" },
    go = { "golang", "go module", "go fmt" },
    v2 = { "v2ex" },
  }

  local list = suggestions[input]
  if list then
    for _, word in ipairs(list) do
      yield(Candidate("completion", seg.start, seg._end, word, "[提示]"))
    end
  end
end

return translator
