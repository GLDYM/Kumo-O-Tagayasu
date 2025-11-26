StartupEvents.modifyFood(event => {
  event.modify('quark:cooked_crab_leg', food => {
    food.hunger(3)
    food.saturation(1)
    food.alwaysEdible(false)
  })

  event.modify('minecraft:golden_carrot', food => {
    food.hunger(5)
    food.saturation(0.5)
    food.alwaysEdible(false)
  })
})
