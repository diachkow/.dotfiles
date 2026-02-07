local M = {}

function M.apply_config()
  -- The order of the imports mostly matters, so don't change it unless it breaks the editor
  require("base_config.keybinds")
  require("base_config.behavior")
  require("base_config.appearance")
  require("base_config.commands")
  require("base_config.ftmapping")
end

return M
