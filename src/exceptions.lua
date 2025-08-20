local M = {}

--[[
The items that should be overridden. You might want to use this if there's a bug in a mod,
or if you want to be 100% sure a certain recipe will be mapped to a specific technology
--]]
M.overrides = {
  -- Vanilla
  ["water"] = "fluid-handling",
  ["crude-oil"] = "oil-gathering",

  -- Maraxsis
  ["maraxsis-saline-water"] = "planet-discovery-maraxsis",

  -- Shattered Planet
  ["helium"] = "s2_noblegases",
  ["ske_americium_241"] = "s2_isotope_liquification",
}

return M
