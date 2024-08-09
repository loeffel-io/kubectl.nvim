local events = require("kubectl.utils.events")
local time = require("kubectl.utils.time")

local M = {}

function M.processLimitedRow(rows)
  local data = M.processRow(rows)
  table.remove(data, 1)

  return data
end
function M.processRow(rows)
  local data = { { name = "All", status = "", age = "" } }

  if not rows.items then
    return data
  end

  for _, row in pairs(rows.items) do
    local pod = {
      name = row.metadata.name,
      status = { symbol = events.ColorStatus(row.status.phase), value = row.status.phase },
      age = time.since(row.metadata.creationTimestamp),
    }

    table.insert(data, pod)
  end

  return data
end

function M.getHeaders()
  local headers = {
    "NAME",
    "STATUS",
    "AGE",
  }

  return headers
end

return M
