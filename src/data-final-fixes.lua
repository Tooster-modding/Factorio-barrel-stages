-- Hello there :)
local fluidTech = data.raw.technology['fluid-handling']

-- https://forums.factorio.com/viewtopic.php?f=23&t=100057
local targetTechs = {
  -- base game
  ['sulfuric-acid-barrel'] = 'sulfur-processing',
  ['empty-sulfuric-acid-barrel'] = 'sulfur-processing',

  ['crude-oil-barrel'] = 'oil-gathering',
  ['empty-crude-oil-barrel'] = 'oil-gathering',

  ['petroleum-gas-barrel'] = 'oil-processing',
  ['empty-petroleum-gas-barrel'] = 'oil-processing',

  ['heavy-oil-barrel'] = 'advanced-oil-processing',
  ['empty-heavy-oil-barrel'] = 'advanced-oil-processing',

  ['light-oil-barrel'] = 'advanced-oil-processing',
  ['empty-light-oil-barrel'] = 'advanced-oil-processing',

  ['lubricant-barrel'] = 'lubricant',
  ['empty-lubricant-barrel'] = 'lubricant',

  -- space age
  ['fluoroketone-cold-barrel'] = 'cryogenic-plant',
  ['empty-fluoroketone-cold-barrel'] = 'cryogenic-plant',

  ['fluoroketone-hot-barrel'] = 'cryogenic-plant',
  ['empty-fluoroketone-hot-barrel'] = 'cryogenic-plant',

    -- MARAXSIS
  ['maraxsis-atmosphere-barrel'] = 'maraxsis-glassworking',
  ['empty-maraxsis-atmosphere-barrel'] = 'maraxsis-glassworking',
  ['maraxsis-brackish-water-barrel'] = 'maraxsis-hydro-plant',
  ['empty-maraxsis-brackish-water-barrel'] = 'maraxsis-hydro-plant',
  ['maraxsis-liquid-atmosphere-barrel'] = 'maraxsis-liquid-atmosphere',
  ['empty-maraxsis-liquid-atmosphere-barrel'] = 'maraxsis-liquid-atmosphere',
  ['maraxsis-saline-water-barrel'] = 'planet-discovery-maraxsis',
  ['empty-maraxsis-saline-water-barrel'] = 'planet-discovery-maraxsis',
  ['oxygen-barrel'] = 'maraxsis-hydro-plant',
  ['empty-oxygen-barrel'] = 'maraxsis-hydro-plant',

  -- CORRUNDUM
  ['copper-sulfate-solution-barrel'] = 'recrystalization',
  ['empty-copper-sulfate-solution-barrel'] = 'recrystalization',
  ['hydrogen-barrel'] = 'petrol-dehydrogenation-and-combustion',
  ['empty-hydrogen-barrel'] = 'petrol-dehydrogenation-and-combustion',
  ['hydrogen-sulfide-barrel'] = 'sulfur-redox1',
  ['empty-hydrogen-sulfide-barrel'] = 'sulfur-redox1',
  ['iron-sulfate-solution-barrel'] = 'chalcopyrite-processing',
  ['empty-iron-sulfate-solution-barrel'] = 'chalcopyrite-processing',
  ['mixed-sulfate-solution-barrel'] = 'chalcopyrite-processing',
  ['empty-mixed-sulfate-solution-barrel'] = 'chalcopyrite-processing',
  ['sulfur-dioxide-barrel'] = 'electrochemical-science-pack',
  ['empty-sulfur-dioxide-barrel'] = 'electrochemical-science-pack',
  ['sulfuric-acid-dilute-barrel'] = 'sulfate-processing-2',
  ['empty-sulfuric-acid-dilute-barrel'] = 'sulfate-processing-2',
}


if not fluidTech.effects then return end


local n = #fluidTech.effects;
local patchedEffects = {}; -- resulting table must be continuous, so we can't simply remove entries

for i = 1, n do
  local effect = fluidTech.effects[i];
  local targetTech = data.raw.technology[targetTechs[effect.recipe]];
  if effect.type == 'unlock-recipe' and targetTech then   -- filter only specific effects
    table.insert(targetTech.effects, effect);
  else
    table.insert(patchedEffects, effect);
  end
end
fluidTech.effects = patchedEffects;
