-- Hello there :)
--[[

Move each fluid's barrel/empty barrel recipes from "fluid-handling" to the technologies
that make the fluid available:

- technologies unlocking a recipe that produces the fluid;
- technologies unlocking a planet whose map generation places a tile or a resource
  yielding the fluid (offshore pumps and pumpjacks);
- technologies unlocking a boiler whose output is the fluid.

A fluid gets all of them, not just one: the barrels show up with whichever comes first.
A technology that already requires another one unlocking the same barrels is skipped,
so it does not list barrels the player already has.

A fluid that some source gives without any technology (water on Nauvis) or that has no
technology-gated source at all keeps its barrels on "fluid-handling".

Barrel recipes are recognized by the fluid inside them, so the name does not matter.

To hard-code a fluid to a certain technology, see exceptions.lua.

--]]

local technologyData = data.raw["technology"]
local recipeData = data.raw["recipe"]
local fluidHandlingTech = technologyData["fluid-handling"]
local exceptions = require("exceptions")

if not fluidHandlingTech or not fluidHandlingTech.effects then
  return
end

---@param set table<string, true>
---@param other table<string, true>?
local function mergeSet(set, other)
  for key in pairs(other or {}) do
    set[key] = true
  end
end

---@param sets table<string, table<string, true>>
local function addToSet(sets, key, value)
  sets[key] = sets[key] or {}
  sets[key][value] = true
end

---@param set table<string, true>
---@return string[]
local function sortedKeys(set)
  local keys = {}
  for key in pairs(set) do
    table.insert(keys, key)
  end
  table.sort(keys)
  return keys
end

-- The one fluid a recipe moves, or nil when it has none or several.
---@return string?
local function recipeFluid(recipe)
  local fluidName

  for _, entries in ipairs({ recipe.ingredients or {}, recipe.results or {} }) do
    for _, entry in ipairs(entries) do
      if entry.type == "fluid" then
        if fluidName and fluidName ~= entry.name then
          return nil
        end
        fluidName = entry.name
      end
    end
  end

  return fluidName
end

-- Barrel recipes unlocked by fluid-handling: recipe name -> fluid name.
-- Base names them "<fluid>-barrel" and "empty-<fluid>-barrel", but a mod may point a
-- barrel recipe at another mod's fluid, so the fluid is read from the recipe itself.
---@type table<string, string>
local barrelRecipes = {}

for _, effect in ipairs(fluidHandlingTech.effects) do
  local recipe = effect.type == "unlock-recipe" and recipeData[effect.recipe]
  if recipe and effect.recipe:find("%-barrel$") then
    barrelRecipes[effect.recipe] = recipeFluid(recipe)
  end
end

-- recipe name -> technologies unlocking it, planet name -> technologies unlocking it.
---@type table<string, table<string, true>>
local recipeUnlocks = {}
---@type table<string, table<string, true>>
local locationUnlocks = {}

for techName, tech in pairs(technologyData) do
  for _, effect in ipairs(tech.effects or {}) do
    if effect.type == "unlock-recipe" and effect.recipe then
      addToSet(recipeUnlocks, effect.recipe, techName)
    elseif effect.type == "unlock-space-location" and effect.space_location then
      addToSet(locationUnlocks, effect.space_location, techName)
    end
  end
end

-- Recipes that only move a fluid in or out of a container are not sources of it.
local containerSubgroups = { ["fill-barrel"] = true, ["empty-barrel"] = true, ["barrel"] = true }

local function isContainerRecipe(recipeName, recipe)
  return barrelRecipes[recipeName] ~= nil
      or recipeName:find("^empty%-") ~= nil
      or containerSubgroups[recipe.subgroup] == true
end

-- fluid name -> technologies unlocking a recipe that produces it,
-- item name -> recipes producing it.
---@type table<string, table<string, true>>
local producerTechs = {}
---@type table<string, table<string, true>>
local itemProducers = {}

for recipeName, recipe in pairs(recipeData) do
  for _, result in ipairs(recipe.results or {}) do
    if result.type == "fluid" and result.name then
      if not isContainerRecipe(recipeName, recipe) then
        producerTechs[result.name] = producerTechs[result.name] or {}
        mergeSet(producerTechs[result.name], recipeUnlocks[recipeName])
      end
    elseif result.name then
      addToSet(itemProducers, result.name, recipeName)
    end
  end
end

-- Natural sources: fluid name -> { free = true } when some source needs no technology,
-- otherwise { techs = set of technologies }.
---@type table<string, { free: boolean?, techs: table<string, true> }>
local sources = {}

local function fluidSource(fluidName)
  sources[fluidName] = sources[fluidName] or { techs = {} }
  return sources[fluidName]
end

local function placedByPlanet(planet, kind, name)
  local settings = planet.map_gen_settings and planet.map_gen_settings.autoplace_settings
  settings = settings and settings[kind] and settings[kind].settings
  return settings ~= nil and settings[name] ~= nil
end

-- A tile or resource that no planet's map generation places is placed by a script,
-- which cannot be attributed to a technology, so it counts as available.
local function addPlacedSource(fluidName, kind, name)
  local source = fluidSource(fluidName)
  local placed = false

  for planetName, planet in pairs(data.raw["planet"] or {}) do
    if placedByPlanet(planet, kind, name) then
      placed = true
      if locationUnlocks[planetName] then
        mergeSet(source.techs, locationUnlocks[planetName])
      else
        source.free = true
      end
    end
  end

  if not placed then
    source.free = true
  end
end

for tileName, tile in pairs(data.raw["tile"] or {}) do
  if tile.fluid then
    addPlacedSource(tile.fluid, "tile", tileName)
  end
end

for resourceName, resource in pairs(data.raw["resource"] or {}) do
  for _, result in ipairs(resource.minable and resource.minable.results or {}) do
    if result.type == "fluid" and result.name then
      addPlacedSource(result.name, "entity", resourceName)
    end
  end
end

-- A boiler is available with the recipes of the items that place it.
local function addEntitySource(fluidName, entityName)
  local source = fluidSource(fluidName)
  local buildable = false

  for itemType in pairs(defines.prototypes.item) do
    for _, item in pairs(data.raw[itemType] or {}) do
      if item.place_result == entityName then
        for recipeName in pairs(itemProducers[item.name] or {}) do
          buildable = true
          if recipeUnlocks[recipeName] then
            mergeSet(source.techs, recipeUnlocks[recipeName])
          elseif recipeData[recipeName].enabled ~= false then
            source.free = true
          end
        end
      end
    end
  end

  if not buildable then
    source.free = true
  end
end

for boilerName, boiler in pairs(data.raw["boiler"] or {}) do
  local output = boiler.output_fluid_box and boiler.output_fluid_box.filter
  if output then
    addEntitySource(output, boilerName)
  end
end

-- The technologies that should unlock the fluid's barrels, or nil to leave them on
-- fluid-handling.
---@return table<string, true>?
local function targetTechs(fluidName)
  local override = exceptions.overrides[fluidName]
  if override and technologyData[override] then
    return { [override] = true }
  end

  local source = sources[fluidName]
  if source and source.free then
    return nil
  end

  local techs = {}
  mergeSet(techs, producerTechs[fluidName])
  mergeSet(techs, source and source.techs)

  if next(techs) == nil then
    return nil
  end

  return techs
end

-- tech name -> all of its prerequisites, direct and indirect.
---@type table<string, table<string, true>>
local ancestorSets = {}

local function ancestors(techName)
  local result = ancestorSets[techName]
  if result then
    return result
  end

  result = {}
  ancestorSets[techName] = result

  local tech = technologyData[techName]
  for _, prerequisite in ipairs(tech and tech.prerequisites or {}) do
    result[prerequisite] = true
    mergeSet(result, ancestors(prerequisite))
  end

  return result
end

-- Drops the targets that require another technology unlocking the recipe, whether
-- another target or one that unlocked it before this mod.
local function withoutRedundant(targets, recipeName)
  local unlockers = {}
  mergeSet(unlockers, targets)
  for techName in pairs(recipeUnlocks[recipeName] or {}) do
    if techName ~= fluidHandlingTech.name then
      unlockers[techName] = true
    end
  end

  local result = {}
  for techName in pairs(targets) do
    local required = ancestors(techName)
    local redundant = false

    for unlocker in pairs(unlockers) do
      if required[unlocker] then
        redundant = true
        break
      end
    end

    if not redundant then
      result[techName] = true
    end
  end

  return result
end

local function addUnlock(techName, recipeName)
  local tech = technologyData[techName]
  tech.effects = tech.effects or {}

  for _, effect in ipairs(tech.effects) do
    if effect.type == "unlock-recipe" and effect.recipe == recipeName then
      return
    end
  end

  table.insert(tech.effects, { type = "unlock-recipe", recipe = recipeName })
end

---@type table<string, string[]>
local fluidToTechNamesMapping = {}

local patchedFluidHandlingEffects = {}

for _, effect in ipairs(fluidHandlingTech.effects) do
  local fluidName = effect.type == "unlock-recipe" and barrelRecipes[effect.recipe]
  local targets = fluidName and targetTechs(fluidName)

  if targets then
    targets = withoutRedundant(targets, effect.recipe)
    fluidToTechNamesMapping[fluidName] = sortedKeys(targets)

    -- fluid-handling may itself unlock a producer of the fluid; keep the effect then.
    if targets[fluidHandlingTech.name] then
      targets[fluidHandlingTech.name] = nil
      table.insert(patchedFluidHandlingEffects, effect)
    end

    for techName in pairs(targets) do
      addUnlock(techName, effect.recipe)
    end
  else
    table.insert(patchedFluidHandlingEffects, effect)
  end
end

fluidHandlingTech.effects = patchedFluidHandlingEffects

log("FLUIDS TECH MAPPING: " .. serpent.block(fluidToTechNamesMapping))
