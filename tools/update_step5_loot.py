"""Migrate authored catalogue without changing existing resource IDs."""
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[1];path=ROOT/'src/Shared/LootCatalog.luau';text=path.read_text(encoding='utf-8')
groups={
1:'StarterMussel CommonShell Starfish OldBottle SunriseScallop SpiralShell CowrieShell NautilusShell ConeShell TurbanShell BrittleStar SandDollar SeaUrchin SeaGlass SmallCrabShell',
2:'PearlShell BlueStar CoralFragment PinkPearl AmberStone JadeBead MessageBottle PorcelainPlate CopperCoin ColorfulShell',
3:'TreasureChest CeramicJug BlackPearl SilverCoin GoldDoubloon CoralRing CaptainsRing RubyBrooch SapphirePendant BronzeKey AnchorCharm Compass PocketWatch Spyglass ShipBell CopperLantern GoldenCoinPile',
4:'AncientRelic RoyalCrown GoldenChalice RubyCluster SapphireCluster AmethystCluster AtlanteanTablet GiantPearl CrystalCoral',
5:'AquamarineCluster GoldenIdol AncientTrident CrystalHeart ObsidianFang LegendaryPearl RoyalTreasureChest'}
zones={id:z for z,ids in groups.items()for id in ids.split()}
overrides={
'PearlShell':('Pearl Oyster',95,'UNCOMMON'),'PinkPearl':('Small Pearl',230,'RARE'),'BlueStar':('Rare Starfish',180,'RARE'),'CoralFragment':('Coral Fragment',62,'COMMON'),
'CeramicJug':('Ancient Vase',360,'UNCOMMON'),'TreasureChest':('Treasure Chest',650,'RARE'),'Compass':('Golden Compass',850,'RARE'),'BlackPearl':('Rare Pearl',1250,'EPIC'),
'AncientRelic':('Ancient Relic',1600,'RARE'),'RoyalCrown':('Golden Crown',3000,'EPIC'),'AtlanteanTablet':('Lost Artifact',4200,'EPIC'),
'GoldenChalice':('Golden Chalice',1800,'RARE'),'AmethystCluster':('Amethyst Geode',2200,'EPIC'),
'AquamarineCluster':('Ocean Crystal',2400,'RARE'),'GoldenIdol':('Ancient Golden Idol',7200,'EPIC'),'AncientTrident':('Ancient Trident',10000,'LEGENDARY'),'CrystalHeart':('Mythic Ocean Relic',20000,'LEGENDARY'),'ObsidianFang':('Obsidian Fang',2600,'EPIC')}
colors={'COMMON':(255,176,173),'UNCOMMON':(93,210,177),'RARE':(75,173,234),'EPIC':(178,128,230),'LEGENDARY':(255,199,75)}
rows=[]
for line in text.splitlines():
 m=re.search(r'id="([^"]+)"',line)
 if not m:continue
 id=m[1];z=zones[id]
 if id in overrides:
  name,value,rarity=overrides[id];line=re.sub(r'name="[^"]+"',f'name="{name}"',line);line=re.sub(r'value=\d+',f'value={value}',line);line=re.sub(r'rarity="[^"]+"',f'rarity="{rarity}"',line)
 rarity=re.search(r'rarity="([^"]+)"',line)[1];line=re.sub(r'minDepth=\d+',f'minDepth={(z-1)*32},minZone={z}',line);line=re.sub(r'color=Color3.fromRGB\([^)]*\)',f'color=Color3.fromRGB({",".join(map(str,colors[rarity]))})',line);rows.append(line)
for id,name,value,rarity,weight in [('SmallCrabShell','Small Crab Shell',15,'COMMON',15),('ColorfulShell','Colorful Shell',140,'UNCOMMON',14),('GoldenCoinPile','Golden Coin Pile',300,'UNCOMMON',14),('GiantPearl','Giant Pearl',1800,'RARE',9),('LegendaryPearl','Legendary Pearl',12000,'LEGENDARY',4),('CrystalCoral','Crystal Coral',700,'UNCOMMON',10),('RoyalTreasureChest','Royal Treasure Chest',5200,'EPIC',6)]:
 z=zones[id];rows.append(f' {{id="{id}",name="{name}",weight={weight},value={value},minDepth={(z-1)*32},minZone={z},rarity="{rarity}",color=Color3.fromRGB({",".join(map(str,colors[rarity]))})}},')
path.write_text('--!strict\n-- Stable IDs preserve inventory saves. Prices, zone gates and item weights are editable here.\nreturn {\n'+'\n'.join(rows)+'\n}\n',encoding='utf-8')
assert len(rows)==58
