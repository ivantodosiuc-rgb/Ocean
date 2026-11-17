"""Shared authored layout. Roblox coordinates: x/z horizontal, y height. Seed 573215."""
import math
SEED=573215
ZONE_HEIGHT=32
OCEAN_MIN=-168
POIS=[
 dict(id='ShellCove',name='Shell Cove',zone=1,x=104,z=-63,kind='shell_cove'),
 dict(id='SirenWindow',name='Siren Window',zone=1,x=122,z=15,kind='small_arch'),
 dict(id='TurtleBasin',name='Turtle Basin',zone=1,x=-102,z=-67,kind='rock_pool'),
 dict(id='CoralAtrium',name='Coral Atrium',zone=2,x=15,z=169,kind='coral_arch'),
 dict(id='CoralArcade',name='Coral Arcade',zone=2,x=-156,z=-65,kind='coral_garden'),
 dict(id='AnchorRest',name="The Anchor's Rest",zone=2,x=122,z=-118,kind='anchor'),
 dict(id='TheMarigoldWreck',name='The Marigold',zone=3,x=166,z=136,kind='existing_wreck',level=-78,inner=22,outer=37),
 dict(id='BrokenGallery',name='Broken Gallery',zone=3,x=-207,z=53,kind='ruined_arch'),
 dict(id='BottleGrotto',name='Bottle Grotto',zone=3,x=-157,z=-147,kind='cave'),
 dict(id='TidekeeperRuins',name='Tidekeeper Sanctuary',zone=4,x=-174,z=192,kind='existing_ruins',level=-114,inner=15,outer=29),
 dict(id='CrownArch',name='Crown Arch',zone=4,x=237,z=-81,kind='large_arch'),
 dict(id='CrystalAlcove',name='Crystal Alcove',zone=4,x=108,z=-230,kind='crystal_cave'),
 dict(id='SunkenVault',name='The Sunken Treasury',zone=5,x=47,z=300,kind='vault',level=-146,inner=15,outer=27),
 dict(id='LeviathanGate',name='Leviathan Gate',zone=5,x=-293,z=-61,kind='abyss_arch'),
 dict(id='LanternChasm',name='Lantern Chasm',zone=5,x=213,z=-216,kind='glowing_reef'),
]
def smooth(t):
 t=max(0,min(1,t));return t*t*(3-2*t)
def interp(points,x):
 for i in range(len(points)-1):
  a,ha=points[i];b,hb=points[i+1]
  if x<=b:return ha+(hb-ha)*smooth((x-a)/(b-a))
 return points[-1][1]
def old_height(x,z):
 r=math.hypot(x,z);a=math.atan2(z,x);effective=r/(1+.028*math.sin(3*a)+.018*math.cos(5*a))
 return interp([(0,-2),(82,-1.2),(100,-5.8),(120,-13),(145,-25),(170,-38),(196,-51),(222,-63),(248,-73),(354,-81)],effective)+math.sin(x*.065)*math.cos(z*.07)*.4

def slope_interp(points,x):
 slopes=[(points[i+1][1]-points[i][1])/(points[i+1][0]-points[i][0]) for i in range(len(points)-1)]
 for i in range(len(slopes)):
  a,ha=points[i];b,hb=points[i+1]
  if x>b:continue
  t=max(0,(x-a)/(b-a));m0=slopes[i]if i==0 else (slopes[i-1]+slopes[i])*.5;m1=slopes[i]if i==len(slopes)-1 else (slopes[i]+slopes[i+1])*.5
  return (2*t**3-3*t*t+1)*ha+(t**3-2*t*t+t)*(b-a)*m0+(-2*t**3+3*t*t)*hb+(t**3-t*t)*(b-a)*m1
 return points[-1][1]
def terrain_height(x,z):
 r=math.hypot(x,z);a=math.atan2(z,x)
 effective=r/(1+.022*math.sin(a*3+.3)+.013*math.cos(a*7))
 base=slope_interp([(0,-2),(84,-1.6),(108,-10),(138,-30),(169,-49),(199,-70),(229,-93),(260,-117),(290,-139),(320,-155),(354,-165.5)],effective)
 detail=(math.sin(x*.049+math.sin(z*.024)*.8)*math.cos(z*.044)*1.6+math.sin(x*.091+z*.067)*.65)*smooth((r-103)/48)
 # Meandering sand gullies are shallow enough to cross on foot.
 channel=math.exp(-((math.sin(a*4+effective*.018)*effective)/14)**2)
 base+=detail-channel*4*smooth((r-130)/70)
 blend=smooth((r-102)/20)
 height=old_height(x,z)*(1-blend)+base*blend
 for p in POIS:
  if 'level' not in p:continue
  d=math.hypot(x-p['x'],z-p['z']);weight=1-smooth((d-p['inner'])/(p['outer']-p['inner']))
  height=height*(1-weight)+p['level']*weight
 return max(-166.5,height)
def zone_for(y):return min(5,max(1,int(max(0,-y)//ZONE_HEIGHT)+1))
