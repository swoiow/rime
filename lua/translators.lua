-- lua/date_translator.lua
local function date_time_translator(input, seg)
   if string.find(input, "^date") or input == "dt" then
      yield(Candidate("date", seg.start, seg._end, os.date("%Y年%m月%d日"), "[日期]"))
      yield(Candidate("date", seg.start, seg._end, os.date("%Y-%m-%d"), "[日期]"))
      yield(Candidate("date", seg.start, seg._end, os.date("%m/%d"), "[日期: 月/日]"))
   end

   if string.find(input, "^time") or input == "dt" then
      yield(Candidate("time", seg.start, seg._end, os.date("%H:%M:%S"), "[时间]"))
      yield(Candidate("time", seg.start, seg._end, os.date("%I:%M %p"), "[12小时制]"))
   end
end

return {
   date_time_translator = date_time_translator,
}
