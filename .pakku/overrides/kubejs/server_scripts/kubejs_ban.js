// Ban items
ServerEvents.recipes(event => {
  event.remove({ output: 'l2complements:diffusion_wand' })
  event.remove({ output: 'create_sa:block_picker' })
//  event.remove({ output: 'etcetera:wrench' }) // 这个现在显得没那么逆天了
//  event.remove({ output: 'supplementaries:slingshot' }) // 这东西在战利品表中也有
//  event.remove({ output: 'quark:pickarang' })
//  event.remove({ output: 'quark:flamerang' })
})

BlockEvents.rightClicked('minecraft:enchanting_table', event => {
  event.player.tell(Text.translate("kubejs.message.enchanting_table_blocked.0"))
  event.player.tell(Text.translate("kubejs.message.enchanting_table_blocked.1"))
  event.cancel()
})
