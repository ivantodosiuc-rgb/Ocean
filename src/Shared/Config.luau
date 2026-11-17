--!strict
local Config={}
Config.Version=1
Config.DataStoreName='SuckTheSea_Player_v1'
Config.Straws={
 {id='BasicStraw',name='Basic Straw',price=0,power=1.25,speed=1,reach=26,color=Color3.fromRGB(250,139,116),tag='STARTER'},
 {id='ColorfulStraw',name='Colorful Straw',price=150,power=2,speed=1.05,reach=27,color=Color3.fromRGB(49,190,175),tag='PLAYFUL'},
 {id='BambooStraw',name='Bamboo Straw',price=600,power=4,speed=1.1,reach=29,color=Color3.fromRGB(136,201,74),tag='NATURAL'},
 {id='GoldenStraw',name='Golden Straw',price=2000,power=8,speed=1.15,reach=30,color=Color3.fromRGB(255,200,87),tag='GOLDEN'},
 {id='CrystalStraw',name='Crystal Straw',price=7500,power=16,speed=1.2,reach=32,color=Color3.fromRGB(73,189,235),tag='CRYSTAL'},
 {id='OceanVacuum',name='Ocean Vacuum',price=25000,power=35,speed=1.25,reach=34,color=Color3.fromRGB(21,139,137),tag='TURBINE'},
 {id='CoralTwister',name='Coral Twister',price=65000,power=55,speed=1.3,reach=36,color=Color3.fromRGB(247,121,130),tag='CORAL'},
 {id='TidalCoil',name='Tidal Coil',price=160000,power=85,speed=1.4,reach=38,color=Color3.fromRGB(68,178,239),tag='TIDAL'},
 {id='StarSiphon',name='Star Siphon',price=420000,power=130,speed=1.45,reach=40,color=Color3.fromRGB(170,132,229),tag='CELESTIAL'},
 {id='Leviathan',name='Leviathan',price=1000000,power=200,speed=1.5,reach=42,color=Color3.fromRGB(32,116,131),tag='LEGENDARY'},
}
-- Robux entitlements are separate from the coin catalogue; IDs live in Offers.
Config.PremiumStraw={id='PrismStraw',name='Prism Straw',robux=79,power=35,speed=1.25,reach=34,comparisonTier=6,color=Color3.fromRGB(229,153,239),tag='PRISM',premium=true}
Config.AdminStraw={id='AdminStraw',name='Admin Straw',robux=1999,power=400,speed=1.6,reach=56,walk=48,jumpHeight=22,color=Color3.fromRGB(181,136,245),tag='ADMIN',premium=true}
Config.Restroom={PersonalOceanFraction=.05,UseSeconds=5,Distance=10,StarterMusselRespawn=45,Sound='rbxassetid://9126175899'}
Config.Loot=require(script.Parent.LootCatalog)
Config.StrawById={};for _,item in Config.Straws do Config.StrawById[item.id]=item end
Config.StrawById.PrismStraw=Config.PremiumStraw;Config.StrawById.AdminStraw=Config.AdminStraw
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
 initial=0,minimum=-168,bottom=-172,halfSize=384,
 -- Drainable volume of the expanded 768 x 768 x 168 stud ocean. Full precision.
 TotalOceanVolume=99_090_432,BaseRemovalRate=200,MaxRemovalRate=1_600_000,
 ProgressStore='SuckTheSea_Ocean_v1',WorldKey='StarterOcean_v1',ShardCount=16,
 CommitInterval=8,PollInterval=2,LeaseSeconds=120,
 updatePeriod=.6,updateDistance=.000001,
 maxActiveLoot=56,lootSpacing=6,lootRadius=342,lootMargin=.12,
}
Config.Audio={Click='rbxasset://sounds/volume_slider.ogg',Collect='rbxasset://sounds/volume_slider.ogg',Water='rbxasset://sounds/action_swim.mp3',Splash='rbxasset://sounds/impact_water.mp3'}
return table.freeze(Config)
