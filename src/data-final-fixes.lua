--[[

Iterate over all existing fluids and their barrel/empty barrel corresponding techs and
ensure that their icons are not shown until the related fluid tech has been researched.

NOTE: If a barrel does not show up, it's because it's not properly named according to what
Factorio expects. Basically, the gist is that the fluid should be named like the
following:

- <fluidName>-barrel
- empty-<fluidName>-barrel

To skip or hard-code a fluid to a certain technology, see exceptions.lua.

--]]

local technologyData = data.raw["technology"]
local recipeData = data.raw["recipe"]
local fluidTech = technologyData["fluid-handling"]
local exceptions = require("exceptions")

---@type table<string, string>
local fluidToTechMapping = {}

-- Logs to the mod file for convenience purposes. Contents are added to "script-output/barrel-stages.log"
---@param msg string
local function modLog(msg)
  helpers.write_file("barrel-stages.log", msg .. "\n", true)
end

---@param arr string[] - Array of strings that we want to search through
---@param target string - The target string we want to find in the array
---@return boolean - true if found, false otherwise
local function arrayContains(arr, target)
  for i = 1, #arr do
    if arr[i] == target then
      return true
    end
  end
  return false -- If we got here, it's not in the array
end

modLog("****************** NEW RUN BEGIN ******************")

-- First pass: Find which technology unlocks each fluid
-- We need to check all technologies and their effects to see which ones unlock fluid recipes
for techName, tech in pairs(technologyData) do
  if tech.effects then
    for _, effect in ipairs(tech.effects) do
      if effect.type == "unlock-recipe" and effect.recipe then
        local recipe = recipeData[effect.recipe]

        if recipe and recipe.results then
          -- Check if this recipe produces a fluid
          for _, result in ipairs(recipe.results) do
            if result.type == "fluid" and result.name then
              -- Map the fluid to the technology that unlocks it
              modLog("Fluid: '" .. result.name .. "' - Tech: '" .. tech.name .. "'")

              -- Skip recipes that we want to intentionally skip
              if arrayContains(exceptions.skips, result.name) then
                modLog("Skipped fluid: '" .. result.name .. "'")
                goto nextRecipe -- Need to do this, otherwise other recipes get skipped
              end

              -- Set it if it's not set yet
              if not fluidToTechMapping[result.name] then
                fluidToTechMapping[result.name] = techName
              end

              -- If it's set, and it's fluid handling, override it
              if fluidToTechMapping[result.name] == "fluid-handling" then
                fluidToTechMapping[result.name] = techName
              end

              ::nextRecipe::
            end
          end
        end
      end
    end
  end
end

-- Override the mapping with the exceptions
for fluidName, techName in pairs(exceptions.overrides) do
  if fluidToTechMapping[fluidName] then
    fluidToTechMapping[fluidName] = techName
    modLog("Overwrote '" .. fluidName .. "' with tech: '" .. techName .. "'")
  end
end

modLog("FLUIDS TECH MAPPING: " .. helpers.table_to_json(fluidToTechMapping))

-- Now we can convert those mappings into their barrel-equivalents
local barrelToTechMapping = {}

for fluidName, techName in pairs(fluidToTechMapping) do
  local barrelName = fluidName .. "-barrel"
  local emptyBarrelName = "empty-" .. fluidName .. "-barrel"
  barrelToTechMapping[barrelName] = techName
  barrelToTechMapping[emptyBarrelName] = techName
end

modLog("BARRELS TECH MAPPING: " .. helpers.table_to_json(barrelToTechMapping))

local n = #fluidTech.effects
local patchedEffects = {} -- resulting table must be continuous, so we can't simply remove entries

for i = 1, n do
  local effect = fluidTech.effects[i]
  local targetTech = technologyData[barrelToTechMapping[effect.recipe]]

  if effect.type == "unlock-recipe" and targetTech then -- filter only specific effects
    table.insert(targetTech.effects, effect)
  else
    table.insert(patchedEffects, effect)
  end
end

fluidTech.effects = patchedEffects
