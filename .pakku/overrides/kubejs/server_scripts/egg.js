// 部分灵感源自机械动力：黄铜协奏曲 Create: The Brass Concerto
// 原作者：Slimeli_
ServerEvents.recipes(event => {
    // 水车
    event.custom(
        {
            "type": "create:filling",
            "ingredients": [
                { "item": "minecraft:minecart" },
                { "fluid": "minecraft:water", "amount": 250 }
            ],
            "results": [
                { "item": "create:large_water_wheel" }
            ]
        }
    ).id("kots:eggs/filling/water_wheel")
    // 盾构机
    event.custom(
        {
            "type": "create:deploying",
            "ingredients": [
                { "item": "minecraft:shield" },
                { "item": "minecraft:iron_pickaxe" }
            ],
            "results": [
                { "item": "create:mechanical_drill" }
            ]
        }
    ).id("kots:eggs/deploying/mechanical_drill")
    // 货物凉港
    event.custom(
        {
            "type": "create:deploying",
            "ingredients": [
                { "item": "create:packager" },
                { "item": "minecraft:tadpole_bucket" }
            ],
            "results": [
                { "item": "create:package_frogport" }
            ]
        }
    ).id("kots:eggs/deploying/package_frogport")
    // 烟花
    event.custom(
        {
            "type": "create:deploying",
            "ingredients": [
                { "tag": "minecraft:flowers" },
                { "item": "supplementaries:ash" }
            ],
            "results": [
                { "item": "minecraft:firework_rocket" }
            ]
        }
    ).id("kots:eggs/deploying/fire_flower")
    // 烟药竹
    event.custom(
        {
            "type": "create:deploying",
            "ingredients": [
                { "item": "minecraft:bamboo" },
                { "item": "minecraft:gunpowder" }
            ],
            "results": [
                { "item": "mynethersdelight:powder_cannon" }
            ]
        }
    ).id("kots:eggs/deploying/powder_cannon")
    // 瓦斯麦
    event.custom(
        {
            "type": "create:deploying",
            "ingredients": [
                { "item": "minecraft:wheat" },
                { "item": "minecraft:gunpowder" }
            ],
            "results": [
                { "item": "immortalers_delight:kwat_wheat" }
            ]
        }
    ).id("kots:eggs/deploying/kwat_wheat")
})