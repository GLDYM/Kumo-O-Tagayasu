ItemEvents.modification(event => {
  event.modify('quark:cooked_crab_leg', item => {
    item.foodProperties = food => {
      food.hunger(3)
      food.saturation(1)
      food.alwaysEdible(false)
    }
  })
  event.modify('minecraft:golden_carrot', item => {
    item.foodProperties = food => {
      food.hunger(5)
      food.saturation(0.5)
      food.alwaysEdible(false)
    }
  })
})