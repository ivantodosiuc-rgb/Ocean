--!strict
local Config={}
Config.Version=1
Config.DataStoreName='SuckTheSea_Player_v1'
Config.Straws={
 {id='BasicStraw',name='Basic Straw',price=0,power=1,color=Color3.fromRGB(250,139,116),tag='STARTER'},
 {id='ColorfulStraw',name='Colorful Straw',price=150,power=2,color=Color3.fromRGB(49,190,175),tag='PLAYFUL'},
 {id='BambooStraw',name='Bamboo Straw',price=600,power=4,color=Color3.fromRGB(136,201,74),tag='NATURAL'},
 {id='GoldenStraw',name='Golden Straw',price=2000,power=8,color=Color3.fromRGB(255,200,87),tag='GOLDEN'},
 {id='CrystalStraw',name='Crystal Straw',price=7500,power=16,color=Color3.fromRGB(73,189,235),tag='CRYSTAL'},
 {id='OceanVacuum',name='Ocean Vacuum',price=25000,power=35,color=Color3.fromRGB(21,139,137),tag='ULTIMATE'},
}
Config.Loot=require(script.Parent.LootCatalog)
Config.StrawById={};for _,item in Config.Straws do Config.StrawById[item.id]=item end
Config.LootById={};for _,item in Config.Loot do Config.LootById[item.id]=item end
Config.Capacities={5,7,10,15,20}
Config.BackpackPrices={100,300,800,2000}
Config.WalkSpeeds={16,18,20,23,26,30}
Config.WalkPrices={100,250,650,1400,3000}
Config.Upgrades={
 {id='Power',name='Suction Power',description='+20% power per level',icon='Power',max=15},
 {id='Speed',name='Suction Speed',description='+10% suction speed per level',icon='Speed',max=15},
 {id='Walk',name='Walk Speed',description='Explore the shore faster',icon='Walk',max=5},
 {id='Backpack',name='Backpack',description='Bring back more treasure',icon='Backpack',max=4},
}
Config.UpgradeById={};for _,u in Config.Upgrades do Config.UpgradeById[u.id]=u end
Config.ShopNames={Straws='Finn',Upgrades='Maya',Sell='Captain Shell'}
Config.ShopDistance=23
Config.PickupDistance=8
Config.SuctionReach=26
Config.Ocean={
 initial=0,minimum=-68,bottom=-84,halfSize=384,
 -- Drainable volume of the 768 x 768 x 68 stud ocean. No rounding of gameplay data.
 TotalOceanVolume=40_108_032,BaseRemovalRate=200,MaxRemovalRate=80_000,
 ProgressStore='SuckTheSea_Ocean_v1',WorldKey='StarterOcean_v1',ShardCount=16,
 CommitInterval=8,PollInterval=2,LeaseSeconds=120,
 updatePeriod=.6,updateDistance=.000001,
 maxActiveLoot=56,lootSpacing=5,lootRadius=240,lootMargin=.12,
}
Config.Audio={Click='rbxasset://sounds/volume_slider.ogg',Collect='rbxasset://sounds/volume_slider.ogg',Water='rbxasset://sounds/action_swim.mp3',Splash='rbxasset://sounds/impact_water.mp3'}
return table.freeze(Config)
