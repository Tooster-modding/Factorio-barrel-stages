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

  -- CERYS
  ['mixed-oxide-waste-solution-barrel'] = 'cerys-mixed-oxide-waste-reprocessing',
  ['empty-mixed-oxide-waste-solution-barrel'] = 'cerys-mixed-oxide-waste-reprocessing',
  ['nitric-acid-barrel'] = 'cerys-fulgoran-cryogenics',
  ['empty-nitric-acid-barrel'] = 'cerys-fulgoran-cryogenics',

  -- ON WAYWARD SEAS
  ['gleba-resin-barrel' ]= 'resin-tech',
  ['empty-gleba-resin-barrel' ]= 'resin-tech',

  -- SHATTERED PLANET
  ['ske_slurry_promethium-barrel'] = 'chunk_slurry_creation',
  ['empty-ske_slurry_promethium-barrel'] = 'chunk_slurry_creation',
  ['ske_slurry_carbonic-barrel'] = 'chunk_slurry_creation',
  ['empty-ske_slurry_carbonic-barrel'] = 'chunk_slurry_creation',
  ['ske_slurry_metallic-barrel'] = 'chunk_slurry_creation',
  ['empty-ske_slurry_metallic-barrel'] = 'chunk_slurry_creation',
  ['ske_slurry_oxide-barrel'] = 'chunk_slurry_creation',
  ['empty-ske_slurry_oxide-barrel'] = 'chunk_slurry_creation',
  ['nitrogen-barrel'] = 'alternate_methods_of_production',
  ['empty-nitrogen-barrel'] = 'alternate_methods_of_production',
  ['helium-barrel'] = 's2_noblegases',
  ['empty-helium-barrel'] = 's2_noblegases',
  ['neon-barrel'] = 's2_noblegases',
  ['empty-neon-barrel'] = 's2_noblegases',
  ['argon-barrel'] = 's2_noblegases',
  ['empty-argon-barrel'] = 's2_noblegases',
  ['krypton-barrel'] = 's2_noblegases',
  ['empty-krypton-barrel'] = 's2_noblegases',
  ['xenon-barrel'] = 's2_noblegases',
  ['empty-xenon-barrel'] = 's2_noblegases',
  ['ske_supermagnetic-barrel'] = 's2_nanometal',
  ['empty-ske_supermagnetic-barrel'] = 's2_nanometal',
  ['ske_liquid_nitrogen-barrel'] = 's2_noblegases',
  ['empty-ske_liquid_nitrogen-barrel'] = 's2_noblegases',
  ['ske_brine-barrel'] = 'ske_recipe_transformation',
  ['empty-ske_brine-barrel'] = 'ske_recipe_transformation',

  ['ske_plutonium_238-barrel'] = 's1_isotope_liquification',
  ['empty-ske_plutonium_238-barrel'] = 's1_isotope_liquification',
  ['ske_plutonium_239-barrel'] = 's1_isotope_liquification',
  ['empty-ske_plutonium_239-barrel'] = 's1_isotope_liquification',
  ['ske_plutonium_241-barrel'] = 's1_isotope_liquification',
  ['empty-ske_plutonium_241-barrel'] = 's1_isotope_liquification',
  ['ske_plutonium_242-barrel'] = 's1_isotope_liquification',
  ['empty-ske_plutonium_242-barrel'] = 's1_isotope_liquification',

  ['ske_neptunium_236-barrel'] = 's1_isotope_liquification',
  ['empty-ske_neptunium_236-barrel'] = 's1_isotope_liquification',
  ['ske_neptunium_237-barrel'] = 's1_isotope_liquification',
  ['empty-ske_neptunium_237-barrel'] = 's1_isotope_liquification',

  ['ske_uranium_233-barrel'] = 's1_isotope_liquification',
  ['empty-ske_uranium_233-barrel'] = 's1_isotope_liquification',
  ['ske_uranium_235-barrel'] = 's1_isotope_liquification',
  ['empty-ske_uranium_235-barrel'] = 's1_isotope_liquification',
  ['ske_uranium_238-barrel'] = 's1_isotope_liquification',
  ['empty-ske_uranium_238-barrel'] = 's1_isotope_liquification',

  ['ske_americium_241-barrel'] = 's2_isotope_liquification',
  ['empty-ske_americium_241-barrel'] = 's2_isotope_liquification',
  ['ske_americium_242-barrel'] = 's2_isotope_liquification',
  ['empty-ske_americium_242-barrel'] = 's2_isotope_liquification',
  ['ske_americium_243-barrel'] = 's2_isotope_liquification',
  ['empty-ske_americium_243-barrel'] = 's2_isotope_liquification',

  ['ske_berkelium_247-barrel'] = 's2_isotope_liquification',
  ['empty-ske_berkelium_247-barrel'] = 's2_isotope_liquification',
  ['ske_berkelium_248-barrel'] = 's3_isotope_liquification',
  ['empty-ske_berkelium_248-barrel'] = 's3_isotope_liquification',

  ['ske_curium_245-barrel'] = 's2_isotope_liquification',
  ['empty-ske_curium_245-barrel'] = 's2_isotope_liquification',
  ['ske_curium_246-barrel'] = 's2_isotope_liquification',
  ['empty-ske_curium_246-barrel'] = 's2_isotope_liquification',
  ['ske_curium_247-barrel'] = 's2_isotope_liquification',
  ['empty-ske_curium_247-barrel'] = 's2_isotope_liquification',

  ['ske_californium_249-barrel'] = 's3_isotope_liquification',
  ['empty-ske_californium_249-barrel'] = 's3_isotope_liquification',
  ['ske_californium_250-barrel'] = 's3_isotope_liquification',
  ['empty-ske_californium_250-barrel'] = 's3_isotope_liquification',
  ['ske_californium_251-barrel'] = 's3_isotope_liquification',
  ['empty-ske_californium_251-barrel'] = 's3_isotope_liquification',
  ['ske_californium_252-barrel'] = 's3_isotope_liquification',
  ['empty-ske_californium_252-barrel'] = 's3_isotope_liquification',
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
