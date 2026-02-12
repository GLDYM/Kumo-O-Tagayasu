StartupEvents.registry('item', event => {
    event.create('icon').texture('kots:item/icon').displayName('Icon')
    event.create('bedrock_egg').texture('kots:item/bedrock_egg').displayName('Bedrock Egg')
})

StartupEvents.modifyCreativeTab('kubejs:tab', event => {
	event.icon = 'kubejs:icon'
})