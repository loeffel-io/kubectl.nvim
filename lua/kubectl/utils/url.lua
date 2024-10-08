local state = require("kubectl.state")
local M = {}

--- Replace placeholders in the argument string
---@param arg string
---@return string
local function replacePlaceholders(arg)
  arg = arg:gsub("{{BASE}}", state.getProxyUrl())
  if state.ns and state.ns ~= "All" then
    arg = arg:gsub("{{NAMESPACE}}", string.format("namespaces/%s/", state.ns))
  else
    arg = arg:gsub("{{NAMESPACE}}", "")
  end
  return arg
end

--- Add headers to the argument list based on content type
---@param args string[]
---@param contentType? string
---@return string[]
function M.addHeaders(args, contentType)
  local headers = {
    yaml = {
      "-H",
      "Accept: application/yaml",
      "-H",
      "Content-Type: application/yaml",
    },
    ["text/html"] = {
      "-H",
      "Accept: application/yaml",
      "-H",
      "Content-Type: text/plain",
    },
    default = {
      "-H",
      "Content-Type: application/json",
    },
  }

  local selectedHeaders = headers[contentType] or headers.default
  for i = #selectedHeaders, 1, -1 do
    table.insert(args, 1, selectedHeaders[i])
  end

  table.insert(args, 1, "-sS")
  table.insert(args, 1, "GET")
  table.insert(args, 1, "-X")
  return args
end

--- Build the argument list by replacing placeholders
---@param args string[]
---@return string[]
function M.build(args)
  local parsed_args = {}
  for i, arg in ipairs(args) do
    parsed_args[i] = replacePlaceholders(arg)
  end

  return parsed_args
end

return M
