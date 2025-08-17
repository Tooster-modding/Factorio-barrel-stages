--[[

Iterate over all existing fluids and their barrel/empty barrel corresponding techs and
ensure that their icons are not shown until the related fluid tech has been researched.

NOTE: If a barrel does not show up, it's because it's not properly named according to what
Factorio expects. Basically, the gist is that the fluid should be named like the
following:

- <fluidName>-barrel
- empty-<fluidName>-barrel

--]]

local technologyData = data.raw["technology"]
local recipeData = data.raw["recipe"]
local fluidTech = technologyData["fluid-handling"]

---@type table<string, string>
local fluidToTechMapping = {}

-- Logs to the mod file for convenience purposes. Contents are added to "script-output/barrel-stages.log"
---@param msg string
local function modLog(msg)
  helpers.write_file("barrel-stages.log", msg, true)
end

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
              modLog("Tech: '" .. tech.name .. "' - Fluid: '" .. result.name .. "'\n")
              -- Set it if it's not set yet
              if not fluidToTechMapping[result.name] then
                fluidToTechMapping[result.name] = techName
              end

              -- If it's set, and it's fluid handling, override it
              if fluidToTechMapping[result.name] == "fluid-handling" then
                fluidToTechMapping[result.name] = techName
              end
            end
          end
        end
      end
    end
  end
end

modLog("FLUIDS TECH MAPPING: " .. helpers.table_to_json(fluidToTechMapping) .. "\n")

-- Now we can convert those mappings into their barrel-equivalents
local barrelToTechMapping = {}

for fluidName, techName in pairs(fluidToTechMapping) do
  local barrelName = fluidName .. "-barrel"
  local emptyBarrelName = "empty-" .. fluidName .. "-barrel"
  barrelToTechMapping[barrelName] = techName
  barrelToTechMapping[emptyBarrelName] = techName
end

modLog("BARRELS TECH MAPPING: " .. helpers.table_to_json(barrelToTechMapping) .. "\n")

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
