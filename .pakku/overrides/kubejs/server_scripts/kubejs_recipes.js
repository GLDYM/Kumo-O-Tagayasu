// flowers
ServerEvents.recipes(event => {
  let i = 0
  Ingredient.of('#minecraft:flowers').stacks.forEach(flower => {
    let name = `flower${i}`
    event.shapeless(flower.id, [flower.id, 'minecraft:bone_meal'])
      .id(`kubejs:${name}`)
    i++
  })
})