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
local fluidHandlingTech = technologyData["fluid-handling"]
local exceptions = require("exceptions")

---@type table<string, string>
local guessedFluidToTechMapping = {}

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
              -- Set if not already set, or override if it's fluid-handling
              if not guessedFluidToTechMapping[result.name]
                  or guessedFluidToTechMapping[result.name] == "fluid-handling"
              then
                guessedFluidToTechMapping[result.name] = techName
              end
            end
          end
        end
      end
    end
  end
end

---@type table<string, string>
fluidToTechNameMapping = util.merge({ guessedFluidToTechMapping, exceptions.overrides })

log("FLUIDS TECH MAPPING: " .. serpent.block(fluidToTechNameMapping))

-- Now we can convert those mappings into their barrel-equivalents
---@type table<string, string>
local barrelToTechNameMapping = {}

for fluidName, techName in pairs(fluidToTechNameMapping) do
  local barrelName = fluidName .. "-barrel"
  local emptyBarrelName = "empty-" .. barrelName
  barrelToTechNameMapping[barrelName] = techName
  barrelToTechNameMapping[emptyBarrelName] = techName
end

local patchedFluidHandlingEffects = {}

for _, effect in ipairs(fluidHandlingTech.effects) do
  local targetTech = technologyData[barrelToTechNameMapping[effect.recipe]]

  if effect.type == "unlock-recipe" and targetTech and targetTech ~= fluidHandlingTech then
    table.insert(targetTech.effects, effect)
  else
    table.insert(patchedFluidHandlingEffects, effect)
  end
end

fluidHandlingTech.effects = patchedFluidHandlingEffects
