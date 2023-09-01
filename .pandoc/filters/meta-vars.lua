--[[
This Lua filter performs variable substitution in a Pandoc document. 
It replaces placeholders in the form of {{key}} with corresponding values from the metadata.

Input:
---
title: My Document
var1: The first variable.
var2: The second variable
var3: he third variab
---

# The heading

{{var1}}

{{var2}}.

T{{var3}}le.

Output:
# The heading

The first variable.

The second variable.

The third variable.
--]]

local vars = {}

function get_vars (meta)
  for k, v in pairs(meta) do
    if pandoc.utils.type(v) == 'Inlines' then
      vars["{{" .. k .. "}}"] = {table.unpack(v)}
    end
  end
end

function replace (el)
  for k, v in pairs(vars) do

    local startIndex, endIndex = string.find(el.text, k) 
    if startIndex then

      local preceding = string.sub(el.text, 1, startIndex - 1)
      if string.len(preceding) > 0 then
        table.insert(v, 1, preceding)
      end

      local remaining = string.sub(el.text, endIndex+1)
      if string.len(remaining) > 0 then
        table.insert(v, remaining)
      end

      return v
    end
  end
  return nil
end


return {{Meta = get_vars}, {Str = replace}}