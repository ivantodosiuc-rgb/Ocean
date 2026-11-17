assert(not game:GetService('RunService'):IsRunning(),'Edit mode only')
assert(not workspace:GetAttribute('ExpeditionInstalled'),'One-time installer already applied')
local imported=assert(workspace:FindFirstChild('SuckTheSea_Expedition'),'Native import is required')
local layout=game.HttpService:JSONDecode([====[{
  "seed": 573215,
  "pois": [
    {
      "id": "ShellCove",
      "name": "Shell Cove",
      "zone": 1,
      "x": 104,
      "z": -63,
      "kind": "shell_cove",
      "y": -22.22756576538086
    },
    {
      "id": "SirenWindow",
      "name": "Siren Window",
      "zone": 1,
      "x": 122,
      "z": 15,
      "kind": "small_arch",
      "y": -17.430931091308594
    },
    {
      "id": "TurtleBasin",
      "name": "Turtle Basin",
      "zone": 1,
      "x": -102,
      "z": -67,
      "kind": "rock_pool",
      "y": -20.94678497314453
    },
    {
      "id": "CoralAtrium",
      "name": "Coral Atrium",
      "zone": 2,
      "x": 15,
      "z": 169,
      "kind": "coral_arch",
      "y": -51.10486602783203
    },
    {
      "id": "CoralArcade",
      "name": "Coral Arcade",
      "zone": 2,
      "x": -156,
      "z": -65,
      "kind": "coral_garden",
      "y": -47.932289123535156
    },
    {
      "id": "AnchorRest",
      "name": "The Anchor's Rest",
      "zone": 2,
      "x": 122,
      "z": -118,
      "kind": "anchor",
      "y": -50.616416931152344
    },
    {
      "id": "TheMarigoldWreck",
      "name": "The Marigold",
      "zone": 3,
      "x": 166,
      "z": 136,
      "kind": "existing_wreck",
      "level": -78,
      "inner": 22,
      "outer": 37,
      "y": -78.0
    },
    {
      "id": "BrokenGallery",
      "name": "Broken Gallery",
      "zone": 3,
      "x": -207,
      "z": 53,
      "kind": "ruined_arch",
      "y": -78.48722839355469
    },
    {
      "id": "BottleGrotto",
      "name": "Bottle Grotto",
      "zone": 3,
      "x": -157,
      "z": -147,
      "kind": "cave",
      "y": -87.9550552368164
    },
    {
      "id": "TidekeeperRuins",
      "name": "Tidekeeper Sanctuary",
      "zone": 4,
      "x": -174,
      "z": 192,
      "kind": "existing_ruins",
      "level": -114,
      "inner": 15,
      "outer": 29,
      "y": -114.00001525878906
    },
    {
      "id": "CrownArch",
      "name": "Crown Arch",
      "zone": 4,
      "x": 237,
      "z": -81,
      "kind": "large_arch",
      "y": -114.88836669921875
    },
    {
      "id": "CrystalAlcove",
      "name": "Crystal Alcove",
      "zone": 4,
      "x": 108,
      "z": -230,
      "kind": "crystal_cave",
      "y": -114.86543273925781
    },
    {
      "id": "SunkenVault",
      "name": "The Sunken Treasury",
      "zone": 5,
      "x": 47,
      "z": 300,
      "kind": "vault",
      "level": -146,
      "inner": 15,
      "outer": 27,
      "y": -146.0
    },
    {
      "id": "LeviathanGate",
      "name": "Leviathan Gate",
      "zone": 5,
      "x": -293,
      "z": -61,
      "kind": "abyss_arch",
      "y": -146.90103149414062
    },
    {
      "id": "LanternChasm",
      "name": "Lantern Chasm",
      "zone": 5,
      "x": 213,
      "z": -216,
      "kind": "glowing_reef",
      "y": -147.0882568359375
    }
  ],
  "fits": [
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden01_03_Seagrass.Visual",
      "deltaY": -0.03011193000677509,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden01_04_ReefBoulder.Visual",
      "deltaY": -5.993694684603698,
      "samples": 205
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden01_06_Seagrass.Visual",
      "deltaY": -0.2543643779806854,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden01_08_ReefBoulder.Visual",
      "deltaY": -0.11714024454782618,
      "samples": 196
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden01_09_Seagrass.Visual",
      "deltaY": -4.15023557164062,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden02_03_Seagrass.Visual",
      "deltaY": -6.094295527836657,
      "samples": 73
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden02_04_ReefBoulder.Visual",
      "deltaY": -6.648099497290211,
      "samples": 219
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden02_06_Seagrass.Visual",
      "deltaY": -5.382573502874507,
      "samples": 70
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden02_08_ReefBoulder.Visual",
      "deltaY": -4.599668572397999,
      "samples": 205
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden02_09_Seagrass.Visual",
      "deltaY": -5.154277759899484,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden03_03_Seagrass.Visual",
      "deltaY": -13.058950289416522,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden03_04_ReefBoulder.Visual",
      "deltaY": -14.332360809161745,
      "samples": 196
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden03_06_Seagrass.Visual",
      "deltaY": -14.685325336281728,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden03_08_ReefBoulder.Visual",
      "deltaY": -12.882002651994547,
      "samples": 221
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden03_09_Seagrass.Visual",
      "deltaY": -13.96027599900323,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden04_03_Seagrass.Visual",
      "deltaY": -13.858955785261415,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden04_04_ReefBoulder.Visual",
      "deltaY": -14.160798885833337,
      "samples": 205
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden04_06_Seagrass.Visual",
      "deltaY": -13.874348835071778,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden04_08_ReefBoulder.Visual",
      "deltaY": -12.978258306305552,
      "samples": 196
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden04_09_Seagrass.Visual",
      "deltaY": -13.529393307725826,
      "samples": 70
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden05_03_Seagrass.Visual",
      "deltaY": -7.371348341078168,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden05_04_ReefBoulder.Visual",
      "deltaY": -7.119864230097974,
      "samples": 212
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden05_06_Seagrass.Visual",
      "deltaY": -7.63712362617467,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden05_08_ReefBoulder.Visual",
      "deltaY": -7.587799729209635,
      "samples": 205
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden05_09_Seagrass.Visual",
      "deltaY": -7.0085583194372205,
      "samples": 70
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden06_03_Seagrass.Visual",
      "deltaY": -19.493535744524372,
      "samples": 72
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden06_04_ReefBoulder.Visual",
      "deltaY": -16.834592184537875,
      "samples": 196
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden06_06_Seagrass.Visual",
      "deltaY": -17.32899378887784,
      "samples": 66
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden06_08_ReefBoulder.Visual",
      "deltaY": -18.824006510551897,
      "samples": 215
    },
    {
      "path": "Workspace.UnderwaterTerrain.CoralGardens.Garden06_09_Seagrass.Visual",
      "deltaY": -14.8186966770186,
      "samples": 70
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_001_SunsetStaghorn.Visual",
      "deltaY": -1.0967029676332272,
      "samples": 20
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_002_VioletSeaFan.Visual",
      "deltaY": -5.6245720655383895,
      "samples": 27
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_003_TurquoiseTable.Visual",
      "deltaY": -9.372265352285858,
      "samples": 29
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_004_GoldenBrain.Visual",
      "deltaY": -9.839948655366157,
      "samples": 26
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_005_PeachCups.Visual",
      "deltaY": -22.072386594427968,
      "samples": 34
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_006_LavenderFingers.Visual",
      "deltaY": -30.363627384036235,
      "samples": 12
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_007_CrimsonLettuce.Visual",
      "deltaY": -0.3300894154070801,
      "samples": 31
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_008_CobaltTubes.Visual",
      "deltaY": -6.541451905216105,
      "samples": 24
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_009_SunbeamAntlers.Visual",
      "deltaY": -14.04874758109002,
      "samples": 26
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_010_MintPagoda.Visual",
      "deltaY": -11.738982417469089,
      "samples": 19
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_011_SunsetStaghorn.Visual",
      "deltaY": -21.605830954092085,
      "samples": 21
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_012_VioletSeaFan.Visual",
      "deltaY": -29.48545424672811,
      "samples": 23
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_013_TurquoiseTable.Visual",
      "deltaY": -0.37196433665270384,
      "samples": 24
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_014_GoldenBrain.Visual",
      "deltaY": -7.052653979214277,
      "samples": 22
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_015_PeachCups.Visual",
      "deltaY": -13.547362489587574,
      "samples": 32
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_016_LavenderFingers.Visual",
      "deltaY": -14.685443294377016,
      "samples": 17
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_017_CrimsonLettuce.Visual",
      "deltaY": -20.04141920769562,
      "samples": 22
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_018_CobaltTubes.Visual",
      "deltaY": -29.43823899604937,
      "samples": 30
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_019_SunbeamAntlers.Visual",
      "deltaY": 0.043563001130474455,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_020_MintPagoda.Visual",
      "deltaY": -7.120038623313491,
      "samples": 21
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_021_SunsetStaghorn.Visual",
      "deltaY": -9.161282518092943,
      "samples": 19
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_022_VioletSeaFan.Visual",
      "deltaY": -11.571729803251024,
      "samples": 21
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_023_TurquoiseTable.Visual",
      "deltaY": -20.279639603907427,
      "samples": 24
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_024_GoldenBrain.Visual",
      "deltaY": -27.37607407595757,
      "samples": 29
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_025_PeachCups.Visual",
      "deltaY": -0.12331429852235382,
      "samples": 40
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_026_LavenderFingers.Visual",
      "deltaY": -2.44436928103687,
      "samples": 20
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_027_CrimsonLettuce.Visual",
      "deltaY": -12.459667086537337,
      "samples": 18
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_028_CobaltTubes.Visual",
      "deltaY": -11.406111932626018,
      "samples": 37
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_029_SunbeamAntlers.Visual",
      "deltaY": -20.146849804159032,
      "samples": 27
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_030_MintPagoda.Visual",
      "deltaY": -28.233942578007394,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_031_SunsetStaghorn.Visual",
      "deltaY": 0.3725075732920902,
      "samples": 23
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_032_VioletSeaFan.Visual",
      "deltaY": -4.052659611038159,
      "samples": 22
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_033_TurquoiseTable.Visual",
      "deltaY": -14.682110514673386,
      "samples": 24
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_034_GoldenBrain.Visual",
      "deltaY": -13.521770016730699,
      "samples": 19
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_035_PeachCups.Visual",
      "deltaY": -17.443331765234632,
      "samples": 18
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_036_LavenderFingers.Visual",
      "deltaY": -15.212895935206767,
      "samples": 9
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_037_CrimsonLettuce.Visual",
      "deltaY": -0.03971869682682588,
      "samples": 22
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_038_CobaltTubes.Visual",
      "deltaY": -5.462319677037307,
      "samples": 44
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_039_SunbeamAntlers.Visual",
      "deltaY": -12.090022743364631,
      "samples": 30
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_040_MintPagoda.Visual",
      "deltaY": -15.58682825278705,
      "samples": 21
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_041_SunsetStaghorn.Visual",
      "deltaY": -18.703824672324963,
      "samples": 26
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_042_VioletSeaFan.Visual",
      "deltaY": -20.2066594645721,
      "samples": 27
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_043_TurquoiseTable.Visual",
      "deltaY": -0.562844986493477,
      "samples": 27
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_044_GoldenBrain.Visual",
      "deltaY": -5.709161756720411,
      "samples": 23
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_045_PeachCups.Visual",
      "deltaY": -0.778890045575263,
      "samples": 23
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_046_LavenderFingers.Visual",
      "deltaY": -0.5366997877674586,
      "samples": 12
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_047_CrimsonLettuce.Visual",
      "deltaY": -0.06429715779302797,
      "samples": 22
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_048_CobaltTubes.Visual",
      "deltaY": -3.3950108680911764,
      "samples": 28
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_049_SunbeamAntlers.Visual",
      "deltaY": -0.19695046898276097,
      "samples": 31
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_050_MintPagoda.Visual",
      "deltaY": -0.035211531693864095,
      "samples": 28
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_051_SunsetStaghorn.Visual",
      "deltaY": -6.253244816150929,
      "samples": 21
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_052_VioletSeaFan.Visual",
      "deltaY": -5.495513139342666,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_053_TurquoiseTable.Visual",
      "deltaY": -4.945118797661074,
      "samples": 22
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_054_GoldenBrain.Visual",
      "deltaY": -6.653082874343379,
      "samples": 24
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_055_PeachCups.Visual",
      "deltaY": -5.579107080686839,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_056_LavenderFingers.Visual",
      "deltaY": -6.144424301591922,
      "samples": 16
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_057_CrimsonLettuce.Visual",
      "deltaY": -14.683221583302029,
      "samples": 19
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_058_CobaltTubes.Visual",
      "deltaY": -14.658563636431186,
      "samples": 43
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_059_SunbeamAntlers.Visual",
      "deltaY": -13.702106932995783,
      "samples": 31
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_060_MintPagoda.Visual",
      "deltaY": -14.104661709222043,
      "samples": 27
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_061_SunsetStaghorn.Visual",
      "deltaY": -14.576340739313942,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_062_VioletSeaFan.Visual",
      "deltaY": -13.135896492978127,
      "samples": 26
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_063_TurquoiseTable.Visual",
      "deltaY": -14.04689957638843,
      "samples": 22
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_064_GoldenBrain.Visual",
      "deltaY": -11.837029158052399,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_065_PeachCups.Visual",
      "deltaY": -10.667729379674032,
      "samples": 23
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_066_LavenderFingers.Visual",
      "deltaY": -12.30335226972057,
      "samples": 18
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_067_CrimsonLettuce.Visual",
      "deltaY": -9.63178521718745,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_068_CobaltTubes.Visual",
      "deltaY": -13.597785619242671,
      "samples": 34
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_069_SunbeamAntlers.Visual",
      "deltaY": -6.855620653964188,
      "samples": 28
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_070_MintPagoda.Visual",
      "deltaY": -9.621180927352142,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_071_SunsetStaghorn.Visual",
      "deltaY": -9.758811562821322,
      "samples": 19
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_072_VioletSeaFan.Visual",
      "deltaY": -9.707883145738691,
      "samples": 22
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_073_TurquoiseTable.Visual",
      "deltaY": -9.274842304813767,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_074_GoldenBrain.Visual",
      "deltaY": -8.206575929401652,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_075_PeachCups.Visual",
      "deltaY": -17.189698826673528,
      "samples": 38
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_076_LavenderFingers.Visual",
      "deltaY": -17.436707425788597,
      "samples": 8
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_077_CrimsonLettuce.Visual",
      "deltaY": -17.681865484021387,
      "samples": 18
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_078_CobaltTubes.Visual",
      "deltaY": -17.489957314916367,
      "samples": 45
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_079_SunbeamAntlers.Visual",
      "deltaY": -16.81288513881374,
      "samples": 26
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_080_MintPagoda.Visual",
      "deltaY": -19.35999147726107,
      "samples": 21
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_01_SunsetStaghorn.Visual",
      "deltaY": -0.1616153098646282,
      "samples": 20
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_01_TurquoiseTable.Visual",
      "deltaY": -0.26655829439981255,
      "samples": 38
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_01_VioletSeaFan.Visual",
      "deltaY": 0.0928446339085201,
      "samples": 27
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_03_CobaltTubes.Visual",
      "deltaY": -0.02710385123053677,
      "samples": 31
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_03_CrimsonLettuce.Visual",
      "deltaY": -0.03138833897287857,
      "samples": 32
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_03_SunbeamAntlers.Visual",
      "deltaY": -0.016426939246348027,
      "samples": 31
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_04_MintPagoda.Visual",
      "deltaY": -0.16782423860192236,
      "samples": 24
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_04_SunsetStaghorn.Visual",
      "deltaY": 0.10272550497551186,
      "samples": 20
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_04_VioletSeaFan.Visual",
      "deltaY": 0.06696878306950921,
      "samples": 33
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_05_GoldenBrain.Visual",
      "deltaY": 0.00499865619300649,
      "samples": 21
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_05_PeachCups.Visual",
      "deltaY": 0.004996787184091744,
      "samples": 24
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_05_TurquoiseTable.Visual",
      "deltaY": 0.0050015112079669355,
      "samples": 33
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_06_CobaltTubes.Visual",
      "deltaY": 0.004998027542407579,
      "samples": 46
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_06_CrimsonLettuce.Visual",
      "deltaY": 0.005004506662620589,
      "samples": 28
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_06_LavenderFingers.Visual",
      "deltaY": 0.004123368027993124,
      "samples": 14
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_07_MintPagoda.Visual",
      "deltaY": -0.18697258415717205,
      "samples": 29
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_07_SunbeamAntlers.Visual",
      "deltaY": 0.060415314567274614,
      "samples": 31
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_07_SunsetStaghorn.Visual",
      "deltaY": -0.011389143073918973,
      "samples": 30
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_08_GoldenBrain.Visual",
      "deltaY": -0.07995569323773716,
      "samples": 31
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_08_TurquoiseTable.Visual",
      "deltaY": -0.20314629627801545,
      "samples": 25
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_08_VioletSeaFan.Visual",
      "deltaY": 0.14912163706439624,
      "samples": 24
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_09_CrimsonLettuce.Visual",
      "deltaY": -0.025853396621393798,
      "samples": 29
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_09_LavenderFingers.Visual",
      "deltaY": -0.018916383690416427,
      "samples": 22
    },
    {
      "path": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_09_PeachCups.Visual",
      "deltaY": -0.10787781452394157,
      "samples": 30
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_04.Visual",
      "deltaY": -10.114795291280164,
      "samples": 205
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_08.Visual",
      "deltaY": -16.340083281922325,
      "samples": 196
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_12.Visual",
      "deltaY": 0.01000022627050906,
      "samples": 212
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_20.Visual",
      "deltaY": -18.20130186567919,
      "samples": 222
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_24.Visual",
      "deltaY": -0.1524212593907845,
      "samples": 212
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_28.Visual",
      "deltaY": -7.742942351988852,
      "samples": 213
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_32.Visual",
      "deltaY": -19.568975949162294,
      "samples": 205
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_36.Visual",
      "deltaY": -0.0010491371711986441,
      "samples": 197
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_40.Visual",
      "deltaY": -7.201056996173051,
      "samples": 229
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_44.Visual",
      "deltaY": -19.568262870925935,
      "samples": 213
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_48.Visual",
      "deltaY": 0.013696048552423179,
      "samples": 217
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_52.Visual",
      "deltaY": -6.880731003208172,
      "samples": 225
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_56.Visual",
      "deltaY": -17.79390591801927,
      "samples": 224
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_60.Visual",
      "deltaY": 0.0029694516342327337,
      "samples": 199
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_64.Visual",
      "deltaY": -7.872543237816352,
      "samples": 212
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_68.Visual",
      "deltaY": -15.056456472380944,
      "samples": 224
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_72.Visual",
      "deltaY": 0.07110948050066074,
      "samples": 199
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_76.Visual",
      "deltaY": -6.425428747943283,
      "samples": 219
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_80.Visual",
      "deltaY": -17.575404349785217,
      "samples": 205
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_84.Visual",
      "deltaY": -0.12679498230770986,
      "samples": 196
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_88.Visual",
      "deltaY": -8.775843000453051,
      "samples": 216
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_03.Visual",
      "deltaY": -7.924959475667606,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_06.Visual",
      "deltaY": -9.650144504782766,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_09.Visual",
      "deltaY": -16.368925231099986,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_15.Visual",
      "deltaY": -8.225598031348028,
      "samples": 80
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_18.Visual",
      "deltaY": -11.106562979784478,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_21.Visual",
      "deltaY": -17.997023799298304,
      "samples": 70
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_27.Visual",
      "deltaY": -6.91806959390653,
      "samples": 78
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_30.Visual",
      "deltaY": -10.315287420404964,
      "samples": 111
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_33.Visual",
      "deltaY": -20.23776784557925,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_39.Visual",
      "deltaY": -6.0986048028753395,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_42.Visual",
      "deltaY": -13.499827448158115,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_45.Visual",
      "deltaY": -20.029427893093732,
      "samples": 98
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_51.Visual",
      "deltaY": -8.1200273828822,
      "samples": 60
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_54.Visual",
      "deltaY": -11.880924038941657,
      "samples": 64
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_57.Visual",
      "deltaY": -20.319357032473512,
      "samples": 68
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_63.Visual",
      "deltaY": -9.48069890159223,
      "samples": 80
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_66.Visual",
      "deltaY": -11.177222397251356,
      "samples": 78
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_75.Visual",
      "deltaY": -9.452315790378663,
      "samples": 70
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_78.Visual",
      "deltaY": -14.251345943299945,
      "samples": 108
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_81.Visual",
      "deltaY": -19.622553950204214,
      "samples": 74
    },
    {
      "path": "Workspace.UnderwaterTerrain.ReefLife.Seagrass_87.Visual",
      "deltaY": -8.277131764226109,
      "samples": 113
    }
  ],
  "moves": [
    {
      "name": "TheMarigoldWreck",
      "chest": "CaptainsCache",
      "delta": [
        44.0,
        -48.01621447107439,
        36.0
      ],
      "samples": 192
    },
    {
      "name": "TidekeeperRuins",
      "chest": "TidekeepersCache",
      "delta": [
        -42.0,
        -62.960017254948625,
        46.0
      ],
      "samples": 64
    }
  ],
  "placements": [
    {
      "name": "ShellCove_SmallArch_000",
      "asset": "SmallArch",
      "x": 95,
      "z": -58,
      "y": -13.884225463867187,
      "yaw": -1.0261455400698787,
      "scale": 0.65,
      "poi": "ShellCove",
      "zone": 1,
      "samples": 28,
      "collide": true
    },
    {
      "name": "ShellCove_RockShelf_001",
      "asset": "RockShelf",
      "x": 112,
      "z": -65,
      "y": -28.954629516601564,
      "yaw": -1.0261455400698787,
      "scale": 0.6,
      "poi": "ShellCove",
      "zone": 1,
      "samples": 73,
      "collide": true
    },
    {
      "name": "ShellCove_RockShelf_002",
      "asset": "RockShelf",
      "x": 122.99350627191019,
      "z": -63.49670866602877,
      "y": -32.807447052001955,
      "yaw": -0.02614554006987868,
      "scale": 0.65,
      "poi": "ShellCove",
      "zone": 2,
      "samples": 73,
      "collide": true
    },
    {
      "name": "ShellCove_RockShelf_003",
      "asset": "RockShelf",
      "x": 78.05962721244092,
      "z": -61.24015351735889,
      "y": -9.754918670654297,
      "yaw": 3.0738544599301214,
      "scale": 0.9,
      "poi": "ShellCove",
      "zone": 1,
      "samples": 73,
      "collide": true
    },
    {
      "name": "SirenWindow_SmallArch_004",
      "asset": "SmallArch",
      "x": 122,
      "z": 15,
      "y": -20.139798736572267,
      "yaw": -1.6931331606103925,
      "scale": 1,
      "poi": "SirenWindow",
      "zone": 1,
      "samples": 28,
      "collide": true
    },
    {
      "name": "SirenWindow_RockShelf_005",
      "asset": "RockShelf",
      "x": 136.6157093303714,
      "z": 2.859940660355303,
      "y": -29.0056396484375,
      "yaw": -0.6931331606103925,
      "scale": 0.65,
      "poi": "SirenWindow",
      "zone": 1,
      "samples": 73,
      "collide": true
    },
    {
      "name": "SirenWindow_RockShelf_006",
      "asset": "RockShelf",
      "x": 102.70762063423356,
      "z": 32.42997700535917,
      "y": -11.766999816894531,
      "yaw": 2.4068668393896075,
      "scale": 0.9,
      "poi": "SirenWindow",
      "zone": 1,
      "samples": 73,
      "collide": true
    },
    {
      "name": "TurtleBasin_RockShelf_007",
      "asset": "RockShelf",
      "x": -93.0,
      "z": -67.0,
      "y": -17.48593673706055,
      "yaw": 0.0,
      "scale": 0.55,
      "poi": "TurtleBasin",
      "zone": 1,
      "samples": 73,
      "collide": true
    },
    {
      "name": "TurtleBasin_RockShelf_008",
      "asset": "RockShelf",
      "x": -102.0,
      "z": -58.0,
      "y": -18.677060699462892,
      "yaw": 1.5707963267948966,
      "scale": 0.55,
      "poi": "TurtleBasin",
      "zone": 1,
      "samples": 73,
      "collide": true
    },
    {
      "name": "TurtleBasin_RockShelf_009",
      "asset": "RockShelf",
      "x": -111.0,
      "z": -67.0,
      "y": -29.377881622314455,
      "yaw": 3.141592653589793,
      "scale": 0.55,
      "poi": "TurtleBasin",
      "zone": 1,
      "samples": 73,
      "collide": true
    },
    {
      "name": "TurtleBasin_RockShelf_010",
      "asset": "RockShelf",
      "x": -102.0,
      "z": -76.0,
      "y": -28.92173538208008,
      "yaw": 4.71238898038469,
      "scale": 0.55,
      "poi": "TurtleBasin",
      "zone": 1,
      "samples": 73,
      "collide": true
    },
    {
      "name": "TurtleBasin_RockShelf_011",
      "asset": "RockShelf",
      "x": -109.72689317954097,
      "z": -49.642145242226405,
      "y": -22.65049514770508,
      "yaw": 1.989611799414814,
      "scale": 0.65,
      "poi": "TurtleBasin",
      "zone": 1,
      "samples": 73,
      "collide": true
    },
    {
      "name": "TurtleBasin_RockShelf_012",
      "asset": "RockShelf",
      "x": -92.42316071317019,
      "z": -91.1719703225499,
      "y": -30.985040283203126,
      "yaw": 5.089611799414814,
      "scale": 0.9,
      "poi": "TurtleBasin",
      "zone": 1,
      "samples": 73,
      "collide": true
    },
    {
      "name": "CoralAtrium_CoralArch_013",
      "asset": "CoralArch",
      "x": 15,
      "z": 169,
      "y": -54.786363220214845,
      "yaw": -3.0530672348657775,
      "scale": 1,
      "poi": "CoralAtrium",
      "zone": 2,
      "samples": 28,
      "collide": true
    },
    {
      "name": "CoralAtrium_CrystalCoralFormation_014",
      "asset": "CrystalCoralFormation",
      "x": 5.836403692023152,
      "z": 159.77890989608966,
      "y": -48.85966833978892,
      "yaw": -2.3530672348657777,
      "scale": 0.55,
      "poi": "CoralAtrium",
      "zone": 2,
      "samples": 40,
      "collide": false
    },
    {
      "name": "CoralAtrium_CrystalCoralFormation_015",
      "asset": "CrystalCoralFormation",
      "x": 32.51332599727359,
      "z": 164.8426676205503,
      "y": -49.87605531409383,
      "yaw": -0.23306723486577763,
      "scale": 0.79,
      "poi": "CoralAtrium",
      "zone": 2,
      "samples": 35,
      "collide": false
    },
    {
      "name": "CoralAtrium_CrystalCoralFormation_016",
      "asset": "CrystalCoralFormation",
      "x": 7.849373775026059,
      "z": 190.86020458711937,
      "y": -68.73312720045446,
      "yaw": 1.8869327651342225,
      "scale": 1.03,
      "poi": "CoralAtrium",
      "zone": 3,
      "samples": 35,
      "collide": false
    },
    {
      "name": "CoralAtrium_RockShelf_017",
      "asset": "RockShelf",
      "x": 6.187946926303505,
      "z": 152.1670644085366,
      "y": -46.176934814453126,
      "yaw": -2.0530672348657775,
      "scale": 0.65,
      "poi": "CoralAtrium",
      "zone": 2,
      "samples": 73,
      "collide": true
    },
    {
      "name": "CoralAtrium_RockShelf_018",
      "asset": "RockShelf",
      "x": 28.005961642075757,
      "z": 191.51321749028455,
      "y": -75.74750671386718,
      "yaw": 1.0469327651342226,
      "scale": 0.9,
      "poi": "CoralAtrium",
      "zone": 3,
      "samples": 73,
      "collide": true
    },
    {
      "name": "CoralArcade_CrystalCoralFormation_019",
      "asset": "CrystalCoralFormation",
      "x": -159.90640131042986,
      "z": -52.60080531639768,
      "y": -48.59324988275767,
      "yaw": 1.876005207095135,
      "scale": 0.55,
      "poi": "CoralArcade",
      "zone": 2,
      "samples": 40,
      "collide": false
    },
    {
      "name": "CoralArcade_CrystalCoralFormation_020",
      "asset": "CrystalCoralFormation",
      "x": -167.81990999744332,
      "z": -78.57533526850587,
      "y": -63.0358419059217,
      "yaw": 3.996005207095135,
      "scale": 0.79,
      "poi": "CoralArcade",
      "zone": 2,
      "samples": 35,
      "collide": false
    },
    {
      "name": "CoralArcade_CrystalCoralFormation_021",
      "asset": "CrystalCoralFormation",
      "x": -133.32066772574186,
      "z": -68.82725588297845,
      "y": -36.25142248854041,
      "yaw": 6.116005207095135,
      "scale": 1.03,
      "poi": "CoralArcade",
      "zone": 2,
      "samples": 35,
      "collide": false
    },
    {
      "name": "CoralArcade_CrystalCoralFormation_022",
      "asset": "CrystalCoralFormation",
      "x": -160.84638608342033,
      "z": -52.937142049645544,
      "y": -48.86512335687876,
      "yaw": 8.236005207095136,
      "scale": 0.55,
      "poi": "CoralArcade",
      "zone": 2,
      "samples": 40,
      "collide": false
    },
    {
      "name": "CoralArcade_CrystalCoralFormation_023",
      "asset": "CrystalCoralFormation",
      "x": -166.74329544956936,
      "z": -79.44235447852124,
      "y": -62.326880419105294,
      "yaw": 10.356005207095135,
      "scale": 0.79,
      "poi": "CoralArcade",
      "zone": 2,
      "samples": 35,
      "collide": false
    },
    {
      "name": "CoralArcade_CrystalCoralFormation_024",
      "asset": "CrystalCoralFormation",
      "x": -133.0938440423205,
      "z": -67.07557684571415,
      "y": -35.39778479322791,
      "yaw": 12.476005207095136,
      "scale": 1.03,
      "poi": "CoralArcade",
      "zone": 2,
      "samples": 35,
      "collide": false
    },
    {
      "name": "CoralArcade_CrystalCoralFormation_025",
      "asset": "CrystalCoralFormation",
      "x": -161.75778882786614,
      "z": -53.34462064908654,
      "y": -49.575046147406105,
      "yaw": 14.596005207095136,
      "scale": 0.55,
      "poi": "CoralArcade",
      "zone": 2,
      "samples": 40,
      "collide": false
    },
    {
      "name": "CoralArcade_RockShelf_026",
      "asset": "RockShelf",
      "x": -166.80974349836362,
      "z": -49.37471774656261,
      "y": -55.79322967529297,
      "yaw": 2.176005207095135,
      "scale": 0.65,
      "poi": "CoralArcade",
      "zone": 2,
      "samples": 73,
      "collide": true
    },
    {
      "name": "CoralArcade_RockShelf_027",
      "asset": "RockShelf",
      "x": -142.10958879978682,
      "z": -86.97854582744256,
      "y": -51.5432373046875,
      "yaw": 5.276005207095135,
      "scale": 0.9,
      "poi": "CoralArcade",
      "zone": 2,
      "samples": 73,
      "collide": true
    },
    {
      "name": "AnchorRest_SunkenAnchor_028",
      "asset": "SunkenAnchor",
      "x": 122,
      "z": -118,
      "y": -50.94701462984085,
      "yaw": -0.8020632871113891,
      "scale": 1.2,
      "poi": "AnchorRest",
      "zone": 2,
      "samples": 10,
      "collide": true
    },
    {
      "name": "AnchorRest_WreckFragment_029",
      "asset": "WreckFragment",
      "x": 110,
      "z": -111,
      "y": -47.358353327959776,
      "yaw": -0.40206328711138906,
      "scale": 0.7,
      "poi": "AnchorRest",
      "zone": 2,
      "samples": 32,
      "collide": true
    },
    {
      "name": "AnchorRest_CrystalCoralFormation_030",
      "asset": "CrystalCoralFormation",
      "x": 134.93234881224313,
      "z": -119.32452036544308,
      "y": -60.24220618158579,
      "yaw": -0.10206328711138912,
      "scale": 0.55,
      "poi": "AnchorRest",
      "zone": 2,
      "samples": 40,
      "collide": false
    },
    {
      "name": "AnchorRest_CrystalCoralFormation_031",
      "asset": "CrystalCoralFormation",
      "x": 114.21700109376303,
      "z": -101.76962945507668,
      "y": -41.78085228189826,
      "yaw": 2.017936712888611,
      "scale": 0.79,
      "poi": "AnchorRest",
      "zone": 2,
      "samples": 35,
      "collide": false
    },
    {
      "name": "AnchorRest_CrystalCoralFormation_032",
      "asset": "CrystalCoralFormation",
      "x": 109.50237370677048,
      "z": -137.30827120782124,
      "y": -53.03770404711366,
      "yaw": 4.137936712888611,
      "scale": 1.03,
      "poi": "AnchorRest",
      "zone": 2,
      "samples": 35,
      "collide": false
    },
    {
      "name": "AnchorRest_RockShelf_033",
      "asset": "RockShelf",
      "x": 140.62901366220154,
      "z": -114.26371173843503,
      "y": -65.1131607055664,
      "yaw": 0.19793671288861092,
      "scale": 0.65,
      "poi": "AnchorRest",
      "zone": 3,
      "samples": 73,
      "collide": true
    },
    {
      "name": "AnchorRest_RockShelf_034",
      "asset": "RockShelf",
      "x": 96.31711829734778,
      "z": -122.0484055438619,
      "y": -47.154893493652345,
      "yaw": 3.2979367128886112,
      "scale": 0.9,
      "poi": "AnchorRest",
      "zone": 2,
      "samples": 73,
      "collide": true
    },
    {
      "name": "TheMarigoldWreck_SunkenAnchor_035",
      "asset": "SunkenAnchor",
      "x": 142,
      "z": 129,
      "y": -77.42297074943781,
      "yaw": -2.2571815753121136,
      "scale": 0.95,
      "poi": "TheMarigoldWreck",
      "zone": 3,
      "samples": 10,
      "collide": true
    },
    {
      "name": "TheMarigoldWreck_WreckFragment_036",
      "asset": "WreckFragment",
      "x": 186,
      "z": 148,
      "y": -90.23353188969195,
      "yaw": -1.5571815753121137,
      "scale": 0.85,
      "poi": "TheMarigoldWreck",
      "zone": 3,
      "samples": 32,
      "collide": true
    },
    {
      "name": "TheMarigoldWreck_CrystalCoralFormation_037",
      "asset": "CrystalCoralFormation",
      "x": 166.1769863014181,
      "z": 123.00120483086566,
      "y": -78.176050683856,
      "yaw": -1.5571815753121137,
      "scale": 0.55,
      "poi": "TheMarigoldWreck",
      "zone": 3,
      "samples": 40,
      "collide": false
    },
    {
      "name": "TheMarigoldWreck_CrystalCoralFormation_038",
      "asset": "CrystalCoralFormation",
      "x": 181.22358351299107,
      "z": 145.60429617530542,
      "y": -78.1979628354311,
      "yaw": 0.5628184246878865,
      "scale": 0.79,
      "poi": "TheMarigoldWreck",
      "zone": 3,
      "samples": 35,
      "collide": false
    },
    {
      "name": "TheMarigoldWreck_CrystalCoralFormation_039",
      "asset": "CrystalCoralFormation",
      "x": 145.37829193141755,
      "z": 146.18553662475185,
      "y": -78.05525165453552,
      "yaw": 2.682818424687887,
      "scale": 1.03,
      "poi": "TheMarigoldWreck",
      "zone": 3,
      "samples": 35,
      "collide": false
    },
    {
      "name": "TheMarigoldWreck_AncientColumn_040",
      "asset": "AncientColumn",
      "x": 176,
      "z": 123,
      "y": -78.10000762939453,
      "yaw": -2.2571815753121136,
      "scale": 0.6,
      "poi": "TheMarigoldWreck",
      "zone": 3,
      "samples": 24,
      "collide": true
    },
    {
      "name": "TheMarigoldWreck_RockShelf_041",
      "asset": "RockShelf",
      "x": 171.86148261726703,
      "z": 117.92673185260959,
      "y": -78.18573039770126,
      "yaw": -1.2571815753121136,
      "scale": 0.65,
      "poi": "TheMarigoldWreck",
      "zone": 3,
      "samples": 73,
      "collide": true
    },
    {
      "name": "TheMarigoldWreck_RockShelf_042",
      "asset": "RockShelf",
      "x": 159.014327042272,
      "z": 161.04396880144336,
      "y": -89.25311431884765,
      "yaw": 1.8428184246878865,
      "scale": 0.9,
      "poi": "TheMarigoldWreck",
      "zone": 3,
      "samples": 73,
      "collide": true
    },
    {
      "name": "BrokenGallery_RuinedArch_043",
      "asset": "RuinedArch",
      "x": -207,
      "z": 53,
      "y": -87.7754302829504,
      "yaw": 1.821450297887728,
      "scale": 1,
      "poi": "BrokenGallery",
      "zone": 3,
      "samples": 48,
      "collide": true
    },
    {
      "name": "BrokenGallery_CrystalCoralFormation_044",
      "asset": "CrystalCoralFormation",
      "x": -217.57934455172307,
      "z": 60.55496319355215,
      "y": -91.3743396654725,
      "yaw": 2.521450297887728,
      "scale": 0.55,
      "poi": "BrokenGallery",
      "zone": 3,
      "samples": 40,
      "collide": false
    },
    {
      "name": "BrokenGallery_CrystalCoralFormation_045",
      "asset": "CrystalCoralFormation",
      "x": -208.27582560089277,
      "z": 35.04527168024794,
      "y": -80.6833416481316,
      "yaw": 4.641450297887728,
      "scale": 0.79,
      "poi": "BrokenGallery",
      "zone": 3,
      "samples": 35,
      "collide": false
    },
    {
      "name": "BrokenGallery_CrystalCoralFormation_046",
      "asset": "CrystalCoralFormation",
      "x": -186.58072009457914,
      "z": 63.58550934740863,
      "y": -66.90427740797399,
      "yaw": 6.761450297887729,
      "scale": 1.03,
      "poi": "BrokenGallery",
      "zone": 3,
      "samples": 35,
      "collide": false
    },
    {
      "name": "BrokenGallery_AncientColumn_047",
      "asset": "AncientColumn",
      "x": -197,
      "z": 40,
      "y": -70.8036895751953,
      "yaw": 1.821450297887728,
      "scale": 0.6,
      "poi": "BrokenGallery",
      "zone": 3,
      "samples": 24,
      "collide": true
    },
    {
      "name": "BrokenGallery_RockShelf_048",
      "asset": "RockShelf",
      "x": -225.03462193429544,
      "z": 58.979332043550514,
      "y": -96.79984436035156,
      "yaw": 2.8214502978877283,
      "scale": 0.65,
      "poi": "BrokenGallery",
      "zone": 4,
      "samples": 73,
      "collide": true
    },
    {
      "name": "BrokenGallery_RockShelf_049",
      "asset": "RockShelf",
      "x": -182.68261037693262,
      "z": 43.79866520987662,
      "y": -68.08046112060546,
      "yaw": 5.921450297887729,
      "scale": 0.9,
      "poi": "BrokenGallery",
      "zone": 3,
      "samples": 73,
      "collide": true
    },
    {
      "name": "BottleGrotto_SeaCave_050",
      "asset": "SeaCave",
      "x": -157,
      "z": -147,
      "y": -94.43165740966796,
      "yaw": 0.8182810432029604,
      "scale": 1,
      "poi": "BottleGrotto",
      "zone": 3,
      "samples": 81,
      "collide": true
    },
    {
      "name": "BottleGrotto_CrystalCoralFormation_051",
      "asset": "CrystalCoralFormation",
      "x": -156.31761506736962,
      "z": -134.01792193815956,
      "y": -78.64567908197641,
      "yaw": 1.5182810432029603,
      "scale": 0.55,
      "poi": "BottleGrotto",
      "zone": 3,
      "samples": 40,
      "collide": false
    },
    {
      "name": "BottleGrotto_CrystalCoralFormation_052",
      "asset": "CrystalCoralFormation",
      "x": -172.82497751438893,
      "z": -155.57730066332553,
      "y": -99.44410606607794,
      "yaw": 3.6382810432029604,
      "scale": 0.79,
      "poi": "BottleGrotto",
      "zone": 4,
      "samples": 35,
      "collide": false
    },
    {
      "name": "BottleGrotto_CrystalCoralFormation_053",
      "asset": "CrystalCoralFormation",
      "x": -137.09644579866244,
      "z": -158.5259936731901,
      "y": -80.9544025300443,
      "yaw": 5.7582810432029605,
      "scale": 1.03,
      "poi": "BottleGrotto",
      "zone": 3,
      "samples": 35,
      "collide": false
    },
    {
      "name": "BottleGrotto_AncientColumn_054",
      "asset": "AncientColumn",
      "x": -147,
      "z": -160,
      "y": -90.86753997802734,
      "yaw": 0.8182810432029604,
      "scale": 0.6,
      "poi": "BottleGrotto",
      "zone": 3,
      "samples": 24,
      "collide": true
    },
    {
      "name": "BottleGrotto_RockShelf_055",
      "asset": "RockShelf",
      "x": -161.65435570409159,
      "z": -128.5788987033948,
      "y": -82.37362060546874,
      "yaw": 1.8182810432029604,
      "scale": 0.65,
      "poi": "BottleGrotto",
      "zone": 3,
      "samples": 73,
      "collide": true
    },
    {
      "name": "BottleGrotto_RockShelf_056",
      "asset": "RockShelf",
      "x": -151.6845479699789,
      "z": -172.45085400760738,
      "y": -101.796044921875,
      "yaw": 4.918281043202961,
      "scale": 0.9,
      "poi": "BottleGrotto",
      "zone": 4,
      "samples": 73,
      "collide": true
    },
    {
      "name": "TidekeeperRuins_AncientColumn_057",
      "asset": "AncientColumn",
      "x": -154,
      "z": 186,
      "y": -112.72760925292968,
      "yaw": 2.4053352246083652,
      "scale": 1.3,
      "poi": "TidekeeperRuins",
      "zone": 4,
      "samples": 24,
      "collide": true
    },
    {
      "name": "TidekeeperRuins_BrokenWall_058",
      "asset": "BrokenWall",
      "x": -192,
      "z": 202,
      "y": -126.60986299961804,
      "yaw": 2.4053352246083652,
      "scale": 0.9,
      "poi": "TidekeeperRuins",
      "zone": 4,
      "samples": 160,
      "collide": true
    },
    {
      "name": "TidekeeperRuins_CrystalCoralFormation_059",
      "asset": "CrystalCoralFormation",
      "x": -186.99145602853818,
      "z": 192.47124331142064,
      "y": -114.19969519525766,
      "yaw": 3.105335224608365,
      "scale": 0.55,
      "poi": "TidekeeperRuins",
      "zone": 4,
      "samples": 40,
      "collide": false
    },
    {
      "name": "TidekeeperRuins_CrystalCoralFormation_060",
      "asset": "CrystalCoralFormation",
      "x": -165.16656402864717,
      "z": 176.31655621554978,
      "y": -112.31701142981647,
      "yaw": 5.225335224608365,
      "scale": 0.79,
      "poi": "TidekeeperRuins",
      "zone": 4,
      "samples": 35,
      "collide": false
    },
    {
      "name": "TidekeeperRuins_CrystalCoralFormation_061",
      "asset": "CrystalCoralFormation",
      "x": -162.79910439167858,
      "z": 212.0883035015774,
      "y": -117.8630824650824,
      "yaw": 7.345335224608365,
      "scale": 1.03,
      "poi": "TidekeeperRuins",
      "zone": 4,
      "samples": 35,
      "collide": false
    },
    {
      "name": "TidekeeperRuins_AncientColumn_062",
      "asset": "AncientColumn",
      "x": -164,
      "z": 179,
      "y": -113.4115234375,
      "yaw": 2.4053352246083652,
      "scale": 0.6,
      "poi": "TidekeeperRuins",
      "zone": 4,
      "samples": 24,
      "collide": true
    },
    {
      "name": "TidekeeperRuins_RockShelf_063",
      "asset": "RockShelf",
      "x": -192.34300033250238,
      "z": 187.04678500347327,
      "y": -118.80130920410156,
      "yaw": 3.4053352246083652,
      "scale": 0.65,
      "poi": "TidekeeperRuins",
      "zone": 4,
      "samples": 73,
      "collide": true
    },
    {
      "name": "TidekeeperRuins_RockShelf_064",
      "asset": "RockShelf",
      "x": -148.63892351502108,
      "z": 197.7285076174383,
      "y": -113.96495971679687,
      "yaw": 6.505335224608365,
      "scale": 0.9,
      "poi": "TidekeeperRuins",
      "zone": 4,
      "samples": 73,
      "collide": true
    },
    {
      "name": "CrownArch_LargeArch_065",
      "asset": "LargeArch",
      "x": 237,
      "z": -81,
      "y": -117.92154846191406,
      "yaw": -1.241470159747059,
      "scale": 1,
      "poi": "CrownArch",
      "zone": 4,
      "samples": 28,
      "collide": true
    },
    {
      "name": "CrownArch_CrystalCoralFormation_066",
      "asset": "CrystalCoralFormation",
      "x": 248.1403746048928,
      "z": -87.70015325665463,
      "y": -122.9126175455749,
      "yaw": -0.541470159747059,
      "scale": 0.55,
      "poi": "CrownArch",
      "zone": 4,
      "samples": 40,
      "collide": false
    },
    {
      "name": "CrownArch_CrystalCoralFormation_067",
      "asset": "CrystalCoralFormation",
      "x": 236.86079814531112,
      "z": -63.000538262390975,
      "y": -109.15354402258991,
      "yaw": 1.578529840252941,
      "scale": 0.79,
      "poi": "CrownArch",
      "zone": 4,
      "samples": 35,
      "collide": false
    },
    {
      "name": "CrownArch_CrystalCoralFormation_068",
      "asset": "CrystalCoralFormation",
      "x": 217.47580465063535,
      "z": -93.15754070360644,
      "y": -103.85186304941773,
      "yaw": 3.698529840252941,
      "scale": 1.03,
      "poi": "CrownArch",
      "zone": 4,
      "samples": 35,
      "collide": false
    },
    {
      "name": "CrownArch_AncientColumn_069",
      "asset": "AncientColumn",
      "x": 247,
      "z": -94,
      "y": -125.81005249023437,
      "yaw": -1.241470159747059,
      "scale": 0.6,
      "poi": "CrownArch",
      "zone": 4,
      "samples": 24,
      "collide": true
    },
    {
      "name": "CrownArch_RockShelf_070",
      "asset": "RockShelf",
      "x": 255.44876182425998,
      "z": -85.54347742942862,
      "y": -132.66797790527343,
      "yaw": -0.241470159747059,
      "scale": 0.65,
      "poi": "CrownArch",
      "zone": 5,
      "samples": 73,
      "collide": true
    },
    {
      "name": "CrownArch_RockShelf_071",
      "asset": "RockShelf",
      "x": 212.03468284075467,
      "z": -73.73825508997389,
      "y": -95.67603454589843,
      "yaw": 2.858529840252941,
      "scale": 0.9,
      "poi": "CrownArch",
      "zone": 3,
      "samples": 73,
      "collide": true
    },
    {
      "name": "CrystalAlcove_CrystalCave_072",
      "asset": "CrystalCave",
      "x": 108,
      "z": -230,
      "y": -119.01921997070312,
      "yaw": -0.4390047112061925,
      "scale": 1,
      "poi": "CrystalAlcove",
      "zone": 4,
      "samples": 80,
      "collide": true
    },
    {
      "name": "CrystalAlcove_CrystalCoralFormation_073",
      "asset": "CrystalCoralFormation",
      "x": 120.55973719171004,
      "z": -226.64545060027794,
      "y": -116.49943884760141,
      "yaw": 0.26099528879380746,
      "scale": 0.55,
      "poi": "CrystalAlcove",
      "zone": 4,
      "samples": 40,
      "collide": false
    },
    {
      "name": "CrystalAlcove_CrystalCoralFormation_074",
      "asset": "CrystalCoralFormation",
      "x": 94.96036180764122,
      "z": -217.59162235373302,
      "y": -97.2167001505196,
      "yaw": 2.3809952887938075,
      "scale": 0.79,
      "poi": "CrystalAlcove",
      "zone": 4,
      "samples": 35,
      "collide": false
    },
    {
      "name": "CrystalAlcove_CrystalCoralFormation_075",
      "asset": "CrystalCoralFormation",
      "x": 103.17407628051113,
      "z": -252.48800703160853,
      "y": -127.84604986891149,
      "yaw": 4.500995288793808,
      "scale": 1.03,
      "poi": "CrystalAlcove",
      "zone": 4,
      "samples": 35,
      "collide": false
    },
    {
      "name": "CrystalAlcove_AncientColumn_076",
      "asset": "AncientColumn",
      "x": 118,
      "z": -243,
      "y": -124.73810729980468,
      "yaw": -0.4390047112061925,
      "scale": 0.6,
      "poi": "CrystalAlcove",
      "zone": 4,
      "samples": 24,
      "collide": true
    },
    {
      "name": "CrystalAlcove_RockShelf_077",
      "asset": "RockShelf",
      "x": 124.08779414791796,
      "z": -219.89144523414862,
      "y": -116.96985778808593,
      "yaw": 0.5609952887938074,
      "scale": 0.65,
      "poi": "CrystalAlcove",
      "zone": 4,
      "samples": 73,
      "collide": true
    },
    {
      "name": "CrystalAlcove_RockShelf_078",
      "asset": "RockShelf",
      "x": 85.42898806838025,
      "z": -242.90540275941353,
      "y": -119.44440612792968,
      "yaw": 3.6609952887938073,
      "scale": 0.9,
      "poi": "CrystalAlcove",
      "zone": 4,
      "samples": 73,
      "collide": true
    },
    {
      "name": "SunkenVault_RuinedArch_079",
      "asset": "RuinedArch",
      "x": 47,
      "z": 306,
      "y": -149.03749389648436,
      "yaw": 0,
      "scale": 1.15,
      "poi": "SunkenVault",
      "zone": 5,
      "samples": 48,
      "collide": true
    },
    {
      "name": "SunkenVault_AncientColumn_080",
      "asset": "AncientColumn",
      "x": 32,
      "z": 295,
      "y": -146.47333679199218,
      "yaw": 0,
      "scale": 1.25,
      "poi": "SunkenVault",
      "zone": 5,
      "samples": 24,
      "collide": true
    },
    {
      "name": "SunkenVault_BrokenWall_081",
      "asset": "BrokenWall",
      "x": 36,
      "z": 317,
      "y": -155.80346559286116,
      "yaw": -0.3,
      "scale": 1.2,
      "poi": "SunkenVault",
      "zone": 5,
      "samples": 160,
      "collide": true
    },
    {
      "name": "SunkenVault_AncientColumn_082",
      "asset": "AncientColumn",
      "x": 62,
      "z": 295,
      "y": -148.13550720214843,
      "yaw": 0,
      "scale": 1.25,
      "poi": "SunkenVault",
      "zone": 5,
      "samples": 24,
      "collide": true
    },
    {
      "name": "SunkenVault_BrokenWall_083",
      "asset": "BrokenWall",
      "x": 58,
      "z": 317,
      "y": -157.7719561934471,
      "yaw": 0.3,
      "scale": 1.2,
      "poi": "SunkenVault",
      "zone": 5,
      "samples": 160,
      "collide": true
    },
    {
      "name": "SunkenVault_CrystalCoralFormation_084",
      "asset": "CrystalCoralFormation",
      "x": 38.473117704641524,
      "z": 290.1871370986291,
      "y": -146.16870407015085,
      "yaw": -2.2861892009612816,
      "scale": 0.7150000000000001,
      "poi": "SunkenVault",
      "zone": 5,
      "samples": 36,
      "collide": false
    },
    {
      "name": "SunkenVault_CrystalCoralFormation_085",
      "asset": "CrystalCoralFormation",
      "x": 64.7520019196001,
      "z": 297.02234524390184,
      "y": -148.96009399563073,
      "yaw": -0.16618920096128154,
      "scale": 1.0270000000000001,
      "poi": "SunkenVault",
      "zone": 5,
      "samples": 35,
      "collide": false
    },
    {
      "name": "SunkenVault_CrystalCoralFormation_086",
      "asset": "CrystalCoralFormation",
      "x": 38.4044810858855,
      "z": 321.3334726333314,
      "y": -157.2190439067334,
      "yaw": 1.9538107990387186,
      "scale": 1.3390000000000002,
      "poi": "SunkenVault",
      "zone": 5,
      "samples": 35,
      "collide": false
    },
    {
      "name": "SunkenVault_RockShelf_087",
      "asset": "RockShelf",
      "x": 39.332560928387075,
      "z": 282.6158009076316,
      "y": -146.0093017578125,
      "yaw": -1.9861892009612818,
      "scale": 0.65,
      "poi": "SunkenVault",
      "zone": 5,
      "samples": 73,
      "collide": true
    },
    {
      "name": "SunkenVault_RockShelf_088",
      "asset": "RockShelf",
      "x": 58.47236918327169,
      "z": 323.3320540313689,
      "y": -163.53849182128906,
      "yaw": 1.1138107990387183,
      "scale": 0.9,
      "poi": "SunkenVault",
      "zone": 5,
      "samples": 73,
      "collide": true
    },
    {
      "name": "LeviathanGate_AbyssArch_089",
      "asset": "AbyssArch",
      "x": -293,
      "z": -61,
      "y": -152.42696533203124,
      "yaw": 1.3655372330929045,
      "scale": 1,
      "poi": "LeviathanGate",
      "zone": 5,
      "samples": 28,
      "collide": true
    },
    {
      "name": "LeviathanGate_CrystalCoralFormation_090",
      "asset": "CrystalCoralFormation",
      "x": -299.17244733272054,
      "z": -49.55880714589641,
      "y": -151.2645662613958,
      "yaw": 2.0655372330929045,
      "scale": 0.7150000000000001,
      "poi": "LeviathanGate",
      "zone": 5,
      "samples": 36,
      "collide": false
    },
    {
      "name": "LeviathanGate_CrystalCoralFormation_091",
      "asset": "CrystalCoralFormation",
      "x": -302.05066110263664,
      "z": -76.55909809742263,
      "y": -155.10130583776532,
      "yaw": 4.185537233092905,
      "scale": 1.0270000000000001,
      "poi": "LeviathanGate",
      "zone": 5,
      "samples": 35,
      "collide": false
    },
    {
      "name": "LeviathanGate_CrystalCoralFormation_092",
      "asset": "CrystalCoralFormation",
      "x": -270.005745259604,
      "z": -60.485948510578915,
      "y": -133.89680879931151,
      "yaw": 6.305537233092904,
      "scale": 1.3390000000000002,
      "poi": "LeviathanGate",
      "zone": 5,
      "samples": 35,
      "collide": false
    },
    {
      "name": "LeviathanGate_RockShelf_093",
      "asset": "RockShelf",
      "x": -306.5599606904744,
      "z": -47.69107569813437,
      "y": -155.4441162109375,
      "yaw": 2.3655372330929048,
      "scale": 0.65,
      "poi": "LeviathanGate",
      "zone": 5,
      "samples": 73,
      "collide": true
    },
    {
      "name": "LeviathanGate_RockShelf_094",
      "asset": "RockShelf",
      "x": -275.21758808898943,
      "z": -79.96802115738882,
      "y": -140.6512237548828,
      "yaw": 5.465537233092904,
      "scale": 0.9,
      "poi": "LeviathanGate",
      "zone": 5,
      "samples": 73,
      "collide": true
    },
    {
      "name": "LanternChasm_CrystalCoralFormation_095",
      "asset": "CrystalCoralFormation",
      "x": 225.96006245382,
      "z": -217.0182245297993,
      "y": -153.80826095491648,
      "yaw": -0.07840527039211498,
      "scale": 0.7150000000000001,
      "poi": "LanternChasm",
      "zone": 5,
      "samples": 36,
      "collide": false
    },
    {
      "name": "LanternChasm_CrystalCoralFormation_096",
      "asset": "CrystalCoralFormation",
      "x": 204.83523651143034,
      "z": -199.9582844690563,
      "y": -138.3689960588962,
      "yaw": 2.041594729607885,
      "scale": 1.0270000000000001,
      "poi": "LanternChasm",
      "zone": 5,
      "samples": 35,
      "collide": false
    },
    {
      "name": "LanternChasm_CrystalCoralFormation_097",
      "asset": "CrystalCoralFormation",
      "x": 200.9626238080464,
      "z": -235.59850949468833,
      "y": -150.9067880473584,
      "yaw": 4.161594729607885,
      "scale": 1.3390000000000002,
      "poi": "LanternChasm",
      "zone": 5,
      "samples": 35,
      "collide": false
    },
    {
      "name": "LanternChasm_CrystalCoralFormation_098",
      "asset": "CrystalCoralFormation",
      "x": 225.99998355541288,
      "z": -216.02067749971332,
      "y": -153.66301254183054,
      "yaw": 6.281594729607885,
      "scale": 0.7150000000000001,
      "poi": "LanternChasm",
      "zone": 5,
      "samples": 36,
      "collide": false
    },
    {
      "name": "LanternChasm_CrystalCoralFormation_099",
      "asset": "CrystalCoralFormation",
      "x": 203.6282847467453,
      "z": -200.63214545839554,
      "y": -138.29409066338837,
      "yaw": 8.401594729607886,
      "scale": 1.0270000000000001,
      "poi": "LanternChasm",
      "zone": 5,
      "samples": 35,
      "collide": false
    },
    {
      "name": "LanternChasm_CrystalCoralFormation_100",
      "asset": "CrystalCoralFormation",
      "x": 202.5020930365677,
      "z": -236.46445575594717,
      "y": -151.91757601122558,
      "yaw": 10.521594729607887,
      "scale": 1.3390000000000002,
      "poi": "LanternChasm",
      "zone": 5,
      "samples": 35,
      "collide": false
    },
    {
      "name": "LanternChasm_CrystalCoralFormation_101",
      "asset": "CrystalCoralFormation",
      "x": 225.96323600232887,
      "z": -215.0230085220819,
      "y": -153.49942306429148,
      "yaw": 12.641594729607885,
      "scale": 0.7150000000000001,
      "poi": "LanternChasm",
      "zone": 5,
      "samples": 36,
      "collide": false
    },
    {
      "name": "LanternChasm_RockShelf_102",
      "asset": "RockShelf",
      "x": 231.5354156347803,
      "z": -211.82407288785558,
      "y": -154.51273498535156,
      "yaw": 0.22159472960788507,
      "scale": 0.65,
      "poi": "LanternChasm",
      "zone": 5,
      "samples": 73,
      "collide": true
    },
    {
      "name": "LanternChasm_RockShelf_103",
      "asset": "RockShelf",
      "x": 187.42007365094844,
      "z": -220.65482201347135,
      "y": -140.43445739746093,
      "yaw": 3.3215947296078854,
      "scale": 0.9,
      "poi": "LanternChasm",
      "zone": 5,
      "samples": 73,
      "collide": true
    }
  ],
  "reuses": [
    {
      "name": "ReefBand1_01_0",
      "template": "Workspace.Decorations.ShoreRock_03.Visual",
      "cf": [
        92.21431946196071,
        -26.47529446929107,
        98.0964886395674,
        1,
        0,
        2.384185791015625e-07,
        0,
        1,
        0,
        -2.384185791015625e-07,
        0,
        1
      ],
      "scale": 0.7065710446183936,
      "zone": 1,
      "samples": 196
    },
    {
      "name": "ReefBand1_01_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_061_SunsetStaghorn.Visual",
      "cf": [
        92.187076518524,
        -22.554710084395456,
        91.94725545329273,
        -0.704218327999115,
        0.16214871406555176,
        0.6912195682525635,
        0.16622358560562134,
        0.9841669797897339,
        -0.06151983514428139,
        -0.6902506351470947,
        0.07157359272241592,
        -0.7200213670730591
      ],
      "scale": 0.9326399353034773,
      "zone": 1,
      "samples": 25
    },
    {
      "name": "ReefBand1_01_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_035_PeachCups.Visual",
      "cf": [
        88.0019243572969,
        -27.68074295909918,
        105.478722528712,
        -0.7889673113822937,
        -0.024575548246502876,
        0.6139440536499023,
        -0.10814419388771057,
        0.9891555309295654,
        -0.09937908500432968,
        -0.60484379529953,
        -0.14480121433734894,
        -0.7830690741539001
      ],
      "scale": 1.143312243665918,
      "zone": 1,
      "samples": 16
    },
    {
      "name": "ReefBand1_01_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_006_LavenderFingers.Visual",
      "cf": [
        102.15491097491793,
        -30.21379874997096,
        103.06425204201528,
        -0.9173442125320435,
        0.04199201986193657,
        0.3958742916584015,
        0.06706506758928299,
        0.996509850025177,
        0.04970334842801094,
        -0.3924056589603424,
        0.07214440405368805,
        -0.9169588088989258
      ],
      "scale": 0.8788244804488743,
      "zone": 1,
      "samples": 13
    },
    {
      "name": "ReefBand1_01_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_036_LavenderFingers.Visual",
      "cf": [
        95.99372772834037,
        -23.145994878751864,
        89.89973959032574,
        -0.8730697631835938,
        0.09501373022794724,
        0.47824883460998535,
        0.12464607506990433,
        0.9917317628860474,
        0.03052082657814026,
        -0.4713946282863617,
        0.08625857532024384,
        -0.8776940703392029
      ],
      "scale": 1.29181843726639,
      "zone": 1,
      "samples": 7
    },
    {
      "name": "ReefBand1_01_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_045_PeachCups.Visual",
      "cf": [
        89.78677482863499,
        -18.8031763206098,
        88.60059432899452,
        0.2550300657749176,
        -0.08577421307563782,
        -0.963121235370636,
        0.03457271307706833,
        0.9962295293807983,
        -0.07956811785697937,
        0.9663147926330566,
        -0.013005451299250126,
        0.2570338547229767
      ],
      "scale": 1.1851678600833906,
      "zone": 1,
      "samples": 22
    },
    {
      "name": "ReefBand1_02_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_40.Visual",
      "cf": [
        11.496746870923362,
        -27.895802319342955,
        129.62745688574284,
        -0.018740760162472725,
        0,
        0.9998244047164917,
        0,
        1,
        0,
        -0.9998244047164917,
        0,
        -0.018740760162472725
      ],
      "scale": 1.2681787625914573,
      "zone": 1,
      "samples": 220
    },
    {
      "name": "ReefBand1_02_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_044_GoldenBrain.Visual",
      "cf": [
        27.99200788668452,
        -28.33919224729818,
        127.98425047566363,
        -0.814301609992981,
        0.07997231185436249,
        -0.5749067664146423,
        0.10803206264972687,
        0.9940382838249207,
        -0.014741707593202591,
        0.5703004002571106,
        -0.07411252707242966,
        -0.8180863261222839
      ],
      "scale": 0.7106079428465142,
      "zone": 1,
      "samples": 32
    },
    {
      "name": "ReefBand1_02_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_009_SunbeamAntlers.Visual",
      "cf": [
        16.405168565311758,
        -18.344779897004145,
        118.91648065869481,
        0.18995162844657898,
        -0.18528930842876434,
        0.9641504287719727,
        0.024002427235245705,
        0.9826127886772156,
        0.18410857021808624,
        -0.9814999103546143,
        -0.011829777620732784,
        0.19109627604484558
      ],
      "scale": 1.0705898151350648,
      "zone": 1,
      "samples": 26
    },
    {
      "name": "ReefBand1_02_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_053_TurquoiseTable.Visual",
      "cf": [
        15.157507812161045,
        -25.802926176454967,
        126.39469894992214,
        0.8009863495826721,
        0.11957938224077225,
        -0.5866187214851379,
        -0.0221048966050148,
        0.9850884675979614,
        0.1706227958202362,
        0.5982742309570312,
        -0.12369941920042038,
        0.7916857600212097
      ],
      "scale": 1.193741726822752,
      "zone": 1,
      "samples": 22
    },
    {
      "name": "ReefBand1_02_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_039_SunbeamAntlers.Visual",
      "cf": [
        18.287985024680765,
        -25.238084702178732,
        126.22081687773674,
        -0.7804560661315918,
        -0.08266384899616241,
        0.6197216510772705,
        -0.030359942466020584,
        0.9950622320175171,
        0.09449577331542969,
        -0.6244730949401855,
        0.05493507161736488,
        -0.7791123390197754
      ],
      "scale": 1.2974910003674056,
      "zone": 1,
      "samples": 30
    },
    {
      "name": "ReefBand1_02_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_075_PeachCups.Visual",
      "cf": [
        15.643279785361788,
        -28.327535400696455,
        130.02063361619474,
        -0.9489197134971619,
        0.09470698237419128,
        0.3009679913520813,
        0.07102318108081818,
        0.9935223460197449,
        -0.08870770037174225,
        -0.3074197471141815,
        -0.06280079483985901,
        -0.9494993090629578
      ],
      "scale": 0.904550721178256,
      "zone": 1,
      "samples": 45
    },
    {
      "name": "ReefBand1_03_0",
      "template": "Workspace.Decorations.ShoreRock_01.Visual",
      "cf": [
        -59.37575810748065,
        -23.516709645799164,
        114.06641250154802,
        0.8660253286361694,
        0,
        0.5000001192092896,
        0,
        1,
        0,
        -0.5000001192092896,
        0,
        0.8660253286361694
      ],
      "scale": 0.9746469962920647,
      "zone": 1,
      "samples": 212
    },
    {
      "name": "ReefBand1_03_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_025_PeachCups.Visual",
      "cf": [
        -60.38285444983547,
        -22.704728871181384,
        110.97037362326991,
        0.8110082745552063,
        -0.017281455919146538,
        0.5847793817520142,
        -0.042032912373542786,
        0.9952594041824341,
        0.08770585805177689,
        -0.5835228562355042,
        -0.0957101508975029,
        0.8064373135566711
      ],
      "scale": 1.171456690533619,
      "zone": 1,
      "samples": 27
    },
    {
      "name": "ReefBand1_03_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_006_LavenderFingers.Visual",
      "cf": [
        -68.56343485032426,
        -30.575497445161066,
        127.75218972518883,
        -0.9173442125320435,
        0.04199201986193657,
        0.3958742916584015,
        0.06706506758928299,
        0.996509850025177,
        0.04970334842801094,
        -0.3924056589603424,
        0.07214440405368805,
        -0.9169588088989258
      ],
      "scale": 1.0098268390530005,
      "zone": 2,
      "samples": 12
    },
    {
      "name": "ReefBand1_03_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_077_CrimsonLettuce.Visual",
      "cf": [
        -56.38178130551725,
        -27.56380118124116,
        120.04205463242091,
        0.9304539561271667,
        0.1311160922050476,
        -0.34214547276496887,
        -0.09393371641635895,
        0.9879334568977356,
        0.1231432631611824,
        0.35416311025619507,
        -0.08244020491838455,
        0.9315428137779236
      ],
      "scale": 0.7952592695470132,
      "zone": 1,
      "samples": 25
    },
    {
      "name": "ReefBand1_03_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_074_GoldenBrain.Visual",
      "cf": [
        -54.40061721225746,
        -27.43539515903176,
        121.48396417261196,
        0.8124242424964905,
        -0.029150955379009247,
        -0.5823379755020142,
        -0.07340909540653229,
        0.9856884479522705,
        -0.15175572037696838,
        0.5784276723861694,
        0.16603884100914001,
        0.7986571788787842
      ],
      "scale": 1.2578182807960925,
      "zone": 1,
      "samples": 18
    },
    {
      "name": "ReefBand1_03_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_032_VioletSeaFan.Visual",
      "cf": [
        -59.521830679632515,
        -29.10057059557856,
        127.38948107553436,
        0.7235102653503418,
        -0.045412737876176834,
        0.6888179183006287,
        -0.03192097321152687,
        0.994565486907959,
        0.09909886866807938,
        -0.6895750164985657,
        -0.09368682652711868,
        0.7181288599967957
      ],
      "scale": 0.9469022488206553,
      "zone": 1,
      "samples": 22
    },
    {
      "name": "ReefBand1_04_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_36.Visual",
      "cf": [
        -130.95625772414397,
        -30.936679350532522,
        60.33267903172696,
        -0.9953233003616333,
        0,
        0.09659992158412933,
        0,
        1,
        0,
        -0.09659992158412933,
        0,
        -0.9953233003616333
      ],
      "scale": 1.1738658061628535,
      "zone": 2,
      "samples": 196
    },
    {
      "name": "ReefBand1_04_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_005_PeachCups.Visual",
      "cf": [
        -122.77947926926045,
        -29.777531137875688,
        67.85639040143431,
        -0.37297290563583374,
        0.06330561637878418,
        0.9256801009178162,
        -0.09388989210128784,
        0.9899735450744629,
        -0.1055324375629425,
        -0.9230796098709106,
        -0.12627272307872772,
        -0.3632895350456238
      ],
      "scale": 1.2233478703052296,
      "zone": 1,
      "samples": 25
    },
    {
      "name": "ReefBand1_04_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_063_TurquoiseTable.Visual",
      "cf": [
        -120.65354217753563,
        -26.593315421848857,
        58.612061395400694,
        0.08004104346036911,
        -0.1095973402261734,
        -0.9907481670379639,
        -0.13375480473041534,
        0.9837674498558044,
        -0.11963098496198654,
        0.9877773523330688,
        0.14209270477294922,
        0.06408260017633438
      ],
      "scale": 0.8442342723096953,
      "zone": 1,
      "samples": 25
    },
    {
      "name": "ReefBand1_04_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_018_CobaltTubes.Visual",
      "cf": [
        -121.01479476680666,
        -28.357401044899248,
        65.91858486654588,
        0.8596060872077942,
        -0.09785894304513931,
        -0.501498818397522,
        0.018699370324611664,
        0.9868561029434204,
        -0.16051606833934784,
        0.5106150507926941,
        0.12860292196273804,
        0.8501374125480652
      ],
      "scale": 1.218443865249415,
      "zone": 1,
      "samples": 30
    },
    {
      "name": "ReefBand1_04_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_025_PeachCups.Visual",
      "cf": [
        -126.6300938809015,
        -31.028699415314097,
        67.26721241535864,
        0.8110082745552063,
        -0.017281455919146538,
        0.5847793817520142,
        -0.042032912373542786,
        0.9952594041824341,
        0.08770585805177689,
        -0.5835228562355042,
        -0.0957101508975029,
        0.8064373135566711
      ],
      "scale": 0.9863114108870028,
      "zone": 1,
      "samples": 42
    },
    {
      "name": "ReefBand1_04_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_033_TurquoiseTable.Visual",
      "cf": [
        -132.67549052417155,
        -31.343201712772455,
        62.323036172072136,
        0.9581320285797119,
        0.0926273912191391,
        -0.2709295153617859,
        -0.056320805102586746,
        0.9887105822563171,
        0.13885119557380676,
        0.28073227405548096,
        -0.11777884513139725,
        0.9525319933891296
      ],
      "scale": 1.0071093507554651,
      "zone": 2,
      "samples": 24
    },
    {
      "name": "ReefBand1_05_0",
      "template": "Workspace.UnderwaterTerrain.CoralGardens.Garden04_04_ReefBoulder.Visual",
      "cf": [
        -129.96985050078627,
        -29.187588517371868,
        -27.315493671538007,
        -0.9846878051757812,
        0,
        -0.17432722449302673,
        0,
        1,
        0,
        0.17432722449302673,
        0,
        -0.9846878051757812
      ],
      "scale": 0.9548462921254471,
      "zone": 1,
      "samples": 205
    },
    {
      "name": "ReefBand1_05_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_034_GoldenBrain.Visual",
      "cf": [
        -124.47520550244175,
        -24.709617564625983,
        -20.129666540495734,
        0.849556028842926,
        -0.1351654976606369,
        -0.5098870992660522,
        0.1600424200296402,
        0.9870976805686951,
        0.004988342523574829,
        0.5026340484619141,
        -0.08584143221378326,
        0.860227108001709
      ],
      "scale": 1.1437722568835422,
      "zone": 1,
      "samples": 16
    },
    {
      "name": "ReefBand1_05_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_05_TurquoiseTable.Visual",
      "cf": [
        -133.46614088467936,
        -29.94377391978173,
        -12.727632036285808,
        0.021382451057434082,
        -0.17778827250003815,
        0.9838365912437439,
        -0.0749945119023323,
        0.9810037612915039,
        0.1789063662290573,
        -0.9969546794891357,
        -0.07760778814554214,
        0.0076431166380643845
      ],
      "scale": 0.8624489932095049,
      "zone": 1,
      "samples": 37
    },
    {
      "name": "ReefBand1_05_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_013_TurquoiseTable.Visual",
      "cf": [
        -140.94087159893368,
        -33.212630308348835,
        -20.26700169316812,
        -0.8882648944854736,
        -0.08577420562505722,
        0.45125195384025574,
        -0.08237776160240173,
        0.9962295293807983,
        0.02720773033797741,
        -0.4518842399120331,
        -0.013005456887185574,
        -0.8919814825057983
      ],
      "scale": 0.9320058501085953,
      "zone": 2,
      "samples": 24
    },
    {
      "name": "ReefBand1_05_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_019_SunbeamAntlers.Visual",
      "cf": [
        -131.6331644765815,
        -28.332915386470447,
        -24.031561844916922,
        0.853522539138794,
        0.09269501268863678,
        -0.5127449035644531,
        -0.13570596277713776,
        0.9896343350410461,
        -0.046990033239126205,
        0.5030742883682251,
        0.10968957841396332,
        0.8572545051574707
      ],
      "scale": 0.8879227678301941,
      "zone": 1,
      "samples": 25
    },
    {
      "name": "ReefBand1_05_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_063_TurquoiseTable.Visual",
      "cf": [
        -134.9839213347766,
        -29.579166472989325,
        -18.04098485640034,
        0.08004104346036911,
        -0.1095973402261734,
        -0.9907481670379639,
        -0.13375480473041534,
        0.9837674498558044,
        -0.11963098496198654,
        0.9877773523330688,
        0.14209270477294922,
        0.06408260017633438
      ],
      "scale": 1.1658325912175211,
      "zone": 1,
      "samples": 19
    },
    {
      "name": "ReefBand1_07_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_08.Visual",
      "cf": [
        -28.695864413455734,
        -30.876244645816634,
        -142.16703568430816,
        0.9456452131271362,
        0,
        0.32520022988319397,
        0,
        1,
        0,
        -0.32520022988319397,
        0,
        0.9456452131271362
      ],
      "scale": 0.8679157822237202,
      "zone": 2,
      "samples": 200
    },
    {
      "name": "ReefBand1_07_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_08_TurquoiseTable.Visual",
      "cf": [
        -23.41217783566283,
        -28.77079407846178,
        -138.23551883488759,
        -0.0682906061410904,
        0.1297968178987503,
        -0.9891859292984009,
        0.08861566334962845,
        0.9883708953857422,
        0.12357202917337418,
        0.9937216639518738,
        -0.07921856641769409,
        -0.07899848371744156
      ],
      "scale": 0.9929673158440847,
      "zone": 1,
      "samples": 25
    },
    {
      "name": "ReefBand1_07_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_071_SunsetStaghorn.Visual",
      "cf": [
        -21.696193970256566,
        -26.52620092248968,
        -134.4989105757227,
        0.18618527054786682,
        -0.010289905592799187,
        -0.9824609756469727,
        -0.06373211741447449,
        0.9977129101753235,
        -0.022527465596795082,
        0.9804458022117615,
        0.06680859625339508,
        0.18510358035564423
      ],
      "scale": 0.8806399128431815,
      "zone": 1,
      "samples": 19
    },
    {
      "name": "ReefBand1_07_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_078_CobaltTubes.Visual",
      "cf": [
        -19.834873806578535,
        -29.345958653837727,
        -140.7547485306519,
        -0.9967048168182373,
        0.08060286194086075,
        -0.009111842140555382,
        0.08094322681427002,
        0.9956167936325073,
        -0.04685142636299133,
        0.005295541137456894,
        -0.04743455722928047,
        -0.9988602995872498
      ],
      "scale": 0.9346031750451007,
      "zone": 1,
      "samples": 49
    },
    {
      "name": "ReefBand1_07_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_030_MintPagoda.Visual",
      "cf": [
        -14.160876779361054,
        -28.850028037112303,
        -141.39984265575225,
        -0.9473670721054077,
        -0.13161155581474304,
        0.2918451726436615,
        -0.13472068309783936,
        0.990837812423706,
        0.009510994888842106,
        -0.2904229462146759,
        -0.030307183042168617,
        -0.9564179182052612
      ],
      "scale": 0.9043243430683472,
      "zone": 1,
      "samples": 27
    },
    {
      "name": "ReefBand1_07_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_073_TurquoiseTable.Visual",
      "cf": [
        -25.730426939327177,
        -28.109828932965474,
        -136.0895759719637,
        0.7012638449668884,
        -0.010421810671687126,
        -0.7128260135650635,
        -0.03557279706001282,
        0.998136043548584,
        -0.04958897829055786,
        0.7120143175125122,
        0.06013214960694313,
        0.6995861530303955
      ],
      "scale": 1.071772555112161,
      "zone": 1,
      "samples": 24
    },
    {
      "name": "ReefBand1_08_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_80.Visual",
      "cf": [
        64.45751854559933,
        -27.229101940070155,
        -113.33585744960354,
        0.15051239728927612,
        0,
        0.9886081218719482,
        0,
        1,
        0,
        -0.9886081218719482,
        0,
        0.15051239728927612
      ],
      "scale": 1.069971258769681,
      "zone": 1,
      "samples": 205
    },
    {
      "name": "ReefBand1_08_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_057_CrimsonLettuce.Visual",
      "cf": [
        66.77775919572656,
        -31.498227369946036,
        -127.51124606612314,
        0.9815177917480469,
        0.15215663611888885,
        0.11606466770172119,
        -0.14104832708835602,
        0.9850795269012451,
        -0.09860778599977493,
        -0.12933678925037384,
        0.08041457831859589,
        0.9883345365524292
      ],
      "scale": 1.1630567034966486,
      "zone": 2,
      "samples": 14
    },
    {
      "name": "ReefBand1_08_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_09_PeachCups.Visual",
      "cf": [
        55.73576164672546,
        -21.959576899304132,
        -112.12404305911777,
        -0.3613865077495575,
        0.07316252589225769,
        -0.929541289806366,
        0.014705159701406956,
        0.9972400665283203,
        0.07277389615774155,
        0.9323000311851501,
        0.0126304617151618,
        -0.3614650368690491
      ],
      "scale": 1.0733577846466529,
      "zone": 1,
      "samples": 27
    },
    {
      "name": "ReefBand1_08_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_022_VioletSeaFan.Visual",
      "cf": [
        68.94282934758151,
        -29.89924183389993,
        -123.0679470087286,
        -0.6634873151779175,
        -0.08573579043149948,
        -0.7432591319084167,
        -0.08076493442058563,
        0.9958153963088989,
        -0.04277179762721062,
        0.743816077709198,
        0.03165074437856674,
        -0.667635440826416
      ],
      "scale": 0.9512511628833482,
      "zone": 1,
      "samples": 21
    },
    {
      "name": "ReefBand1_08_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_061_SunsetStaghorn.Visual",
      "cf": [
        58.459486630252506,
        -24.617986934857573,
        -115.48921183204313,
        -0.704218327999115,
        0.16214871406555176,
        0.6912195682525635,
        0.16622358560562134,
        0.9841669797897339,
        -0.06151983514428139,
        -0.6902506351470947,
        0.07157359272241592,
        -0.7200213670730591
      ],
      "scale": 1.1348565007099023,
      "zone": 1,
      "samples": 23
    },
    {
      "name": "ReefBand1_08_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_016_LavenderFingers.Visual",
      "cf": [
        62.410463997369654,
        -28.534333793734437,
        -122.00924781949423,
        0.8570197224617004,
        0.11178413778543472,
        -0.5030123591423035,
        -0.03671800345182419,
        0.9869521856307983,
        0.15677057206630707,
        0.5139737129211426,
        -0.11588583141565323,
        0.8499419689178467
      ],
      "scale": 0.9493874912616681,
      "zone": 1,
      "samples": 17
    },
    {
      "name": "ReefBand2_00_0",
      "template": "Workspace.Decorations.ShoreRock_04.Visual",
      "cf": [
        162.5848837874983,
        -47.585288160135974,
        52.399882541796195,
        -0.7313538193702698,
        0,
        0.6819982528686523,
        0,
        1,
        0,
        -0.6819982528686523,
        0,
        -0.7313538193702698
      ],
      "scale": 1.2556856969741292,
      "zone": 2,
      "samples": 212
    },
    {
      "name": "ReefBand2_00_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_064_GoldenBrain.Visual",
      "cf": [
        157.83922282077978,
        -48.3471902016159,
        52.107856947950914,
        -0.9480966329574585,
        -0.06279091536998749,
        -0.311720609664917,
        -0.08361349254846573,
        0.995040774345398,
        0.05387568473815918,
        0.3067918121814728,
        0.07714343816041946,
        -0.9486449956893921
      ],
      "scale": 0.755256072639086,
      "zone": 2,
      "samples": 40
    },
    {
      "name": "ReefBand2_00_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_06_CrimsonLettuce.Visual",
      "cf": [
        158.65549723147643,
        -47.685033880620466,
        46.0829021438837,
        -0.9937598705291748,
        -0.03667576611042023,
        -0.10533780604600906,
        -0.024266202002763748,
        0.9928638339042664,
        -0.11676014959812164,
        0.10886836051940918,
        -0.11347543448209763,
        -0.9875583052635193
      ],
      "scale": 0.8047623968365686,
      "zone": 2,
      "samples": 32
    },
    {
      "name": "ReefBand2_00_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_035_PeachCups.Visual",
      "cf": [
        167.25645693628496,
        -52.01646186546277,
        62.85628623850633,
        -0.7889673113822937,
        -0.024575548246502876,
        0.6139440536499023,
        -0.10814419388771057,
        0.9891555309295654,
        -0.09937908500432968,
        -0.60484379529953,
        -0.14480121433734894,
        -0.7830690741539001
      ],
      "scale": 1.0663604746711,
      "zone": 2,
      "samples": 17
    },
    {
      "name": "ReefBand2_00_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_034_GoldenBrain.Visual",
      "cf": [
        167.213463883183,
        -49.01089063123016,
        51.049013883444616,
        0.849556028842926,
        -0.1351654976606369,
        -0.5098870992660522,
        0.1600424200296402,
        0.9870976805686951,
        0.004988342523574829,
        0.5026340484619141,
        -0.08584143221378326,
        0.860227108001709
      ],
      "scale": 1.2296037348119446,
      "zone": 2,
      "samples": 14
    },
    {
      "name": "ReefBand2_00_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_065_PeachCups.Visual",
      "cf": [
        172.57578407649345,
        -54.88967249338819,
        58.70160211475557,
        0.8434862494468689,
        -0.0627909004688263,
        -0.5334680080413818,
        0.011592798866331577,
        0.9950409531593323,
        -0.0987897738814354,
        0.5370254516601562,
        0.07714344561100006,
        0.8400312662124634
      ],
      "scale": 0.7514722164041514,
      "zone": 2,
      "samples": 31
    },
    {
      "name": "ReefBand2_01_0",
      "template": "Workspace.UnderwaterTerrain.CoralGardens.Garden02_08_ReefBoulder.Visual",
      "cf": [
        103.77338330403839,
        -49.203179979384295,
        136.81878224835276,
        0.9392200112342834,
        0,
        0.3433157801628113,
        0,
        1,
        0,
        -0.3433157801628113,
        0,
        0.9392200112342834
      ],
      "scale": 1.1487936993476195,
      "zone": 2,
      "samples": 205
    },
    {
      "name": "ReefBand2_01_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_059_SunbeamAntlers.Visual",
      "cf": [
        108.55192106618388,
        -59.85435813826209,
        153.0511778191148,
        -0.9940223097801208,
        0.09903024882078171,
        -0.045967452228069305,
        0.09681160748004913,
        0.9941340684890747,
        0.048218414187431335,
        0.05047290772199631,
        0.043479979038238525,
        -0.9977787137031555
      ],
      "scale": 0.9678148146487077,
      "zone": 2,
      "samples": 31
    },
    {
      "name": "ReefBand2_01_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_078_CobaltTubes.Visual",
      "cf": [
        101.91427988420259,
        -50.16696383989007,
        136.92080763600873,
        -0.9967048168182373,
        0.08060286194086075,
        -0.009111842140555382,
        0.08094322681427002,
        0.9956167936325073,
        -0.04685142636299133,
        0.005295541137456894,
        -0.04743455722928047,
        -0.9988602995872498
      ],
      "scale": 0.6940816813611033,
      "zone": 2,
      "samples": 66
    },
    {
      "name": "ReefBand2_01_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_063_TurquoiseTable.Visual",
      "cf": [
        112.83265317488784,
        -60.17363224808364,
        149.81449728490347,
        0.08004104346036911,
        -0.1095973402261734,
        -0.9907481670379639,
        -0.13375480473041534,
        0.9837674498558044,
        -0.11963098496198654,
        0.9877773523330688,
        0.14209270477294922,
        0.06408260017633438
      ],
      "scale": 1.046388260178523,
      "zone": 2,
      "samples": 19
    },
    {
      "name": "ReefBand2_01_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_013_TurquoiseTable.Visual",
      "cf": [
        112.93589112177291,
        -53.704919596196355,
        142.11537564040725,
        -0.8882648944854736,
        -0.08577420562505722,
        0.45125195384025574,
        -0.08237776160240173,
        0.9962295293807983,
        0.02720773033797741,
        -0.4518842399120331,
        -0.013005456887185574,
        -0.8919814825057983
      ],
      "scale": 1.071805669149375,
      "zone": 2,
      "samples": 24
    },
    {
      "name": "ReefBand2_01_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_079_SunbeamAntlers.Visual",
      "cf": [
        98.59475865994774,
        -50.18955111181684,
        144.02122432711838,
        -0.17598800361156464,
        0.1311161071062088,
        -0.9756210446357727,
        0.10503251105546951,
        0.9879334568977356,
        0.11382442712783813,
        0.9787728786468506,
        -0.08244021236896515,
        -0.1876358687877655
      ],
      "scale": 0.7224172007235286,
      "zone": 2,
      "samples": 26
    },
    {
      "name": "ReefBand2_03_0",
      "template": "Workspace.UnderwaterTerrain.CoralGardens.Garden01_04_ReefBoulder.Visual",
      "cf": [
        -103.78515514102341,
        -47.883410672353,
        135.31522024098024,
        -0.9846878051757812,
        0,
        -0.17432722449302673,
        0,
        1,
        0,
        0.17432722449302673,
        0,
        -0.9846878051757812
      ],
      "scale": 1.236341712825837,
      "zone": 2,
      "samples": 205
    },
    {
      "name": "ReefBand2_03_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_020_MintPagoda.Visual",
      "cf": [
        -105.40202905975083,
        -47.75029315865565,
        137.65402248546695,
        -0.5341396927833557,
        -0.13109010457992554,
        -0.8351706862449646,
        -0.06301111727952957,
        0.9913301467895508,
        -0.11530205607414246,
        0.8430449366569519,
        -0.008962387219071388,
        -0.5377689003944397
      ],
      "scale": 1.2622703622957312,
      "zone": 2,
      "samples": 21
    },
    {
      "name": "ReefBand2_03_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_03_CrimsonLettuce.Visual",
      "cf": [
        -98.48626823874878,
        -54.01136966332338,
        151.53166304632393,
        0.9876329898834229,
        -0.03802957013249397,
        0.15209855139255524,
        0.04703831300139427,
        0.9973178505897522,
        -0.05607585236430168,
        -0.14955808222293854,
        0.06253687292337418,
        0.9867730140686035
      ],
      "scale": 1.009148903082835,
      "zone": 2,
      "samples": 32
    },
    {
      "name": "ReefBand2_03_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_08_GoldenBrain.Visual",
      "cf": [
        -103.60573834254909,
        -47.997163192497474,
        137.5523949284214,
        0.795339047908783,
        0.13107027113437653,
        -0.5918244123458862,
        -0.057771988213062286,
        0.9882888197898865,
        0.14123612642288208,
        0.6034052968025208,
        -0.0781397596001625,
        0.7935968041419983
      ],
      "scale": 1.2322540488868325,
      "zone": 2,
      "samples": 25
    },
    {
      "name": "ReefBand2_03_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_05_PeachCups.Visual",
      "cf": [
        -109.76625156406905,
        -50.39853861291304,
        138.00061606582824,
        -0.9077642560005188,
        -0.1498079001903534,
        -0.3918187618255615,
        -0.10695163905620575,
        0.985841691493988,
        -0.12914136052131653,
        0.40561774373054504,
        -0.07532420754432678,
        -0.9109341502189636
      ],
      "scale": 1.2266703750799701,
      "zone": 2,
      "samples": 17
    },
    {
      "name": "ReefBand2_03_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_055_PeachCups.Visual",
      "cf": [
        -111.04147588006997,
        -49.922062508306865,
        135.6620624804234,
        0.8913282155990601,
        0.04093906283378601,
        0.45150554180145264,
        -0.042266298085451126,
        0.9990805387496948,
        -0.007149980869144201,
        -0.4513830840587616,
        -0.01271049864590168,
        0.8922389149665833
      ],
      "scale": 1.0909630921246898,
      "zone": 2,
      "samples": 24
    },
    {
      "name": "ReefBand2_04_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_52.Visual",
      "cf": [
        -165.54639982006887,
        -47.32477475079348,
        48.42347787504406,
        0.9998656511306763,
        0,
        -0.01638980396091938,
        0,
        1,
        0,
        0.01638980396091938,
        0,
        0.9998656511306763
      ],
      "scale": 1.1511608744974058,
      "zone": 2,
      "samples": 221
    },
    {
      "name": "ReefBand2_04_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_08_GoldenBrain.Visual",
      "cf": [
        -173.341526858215,
        -52.71836035166869,
        61.688227380779225,
        0.795339047908783,
        0.13107027113437653,
        -0.5918244123458862,
        -0.057771988213062286,
        0.9882888197898865,
        0.14123612642288208,
        0.6034052968025208,
        -0.0781397596001625,
        0.7935968041419983
      ],
      "scale": 1.1872545545209428,
      "zone": 2,
      "samples": 25
    },
    {
      "name": "ReefBand2_04_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_01_TurquoiseTable.Visual",
      "cf": [
        -159.9438506267072,
        -46.55953103638485,
        60.25002403685989,
        0.7264425158500671,
        0.04611438885331154,
        0.6856786012649536,
        0.005709710530936718,
        0.9973065853118896,
        -0.07312167435884476,
        -0.6872037053108215,
        0.05703369528055191,
        0.7242226004600525
      ],
      "scale": 0.7228218552234297,
      "zone": 2,
      "samples": 50
    },
    {
      "name": "ReefBand2_04_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_03_CobaltTubes.Visual",
      "cf": [
        -174.51495088040988,
        -53.167833582615344,
        60.799199452241346,
        0.4055662751197815,
        -0.042194101959466934,
        0.9130910634994507,
        0.07023322582244873,
        0.9974191188812256,
        0.014895523898303509,
        -0.9113631844520569,
        0.05808820202946663,
        0.4074831008911133
      ],
      "scale": 1.0852963195140062,
      "zone": 2,
      "samples": 29
    },
    {
      "name": "ReefBand2_04_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_04_VioletSeaFan.Visual",
      "cf": [
        -174.24267921681104,
        -52.749038954000405,
        57.1342370286297,
        -0.9551480412483215,
        -0.07784453779459,
        0.285713255405426,
        -0.07197420299053192,
        0.9969244003295898,
        0.031006811186671257,
        -0.2872481942176819,
        0.009052109904587269,
        -0.9578133821487427
      ],
      "scale": 0.9174743979116318,
      "zone": 2,
      "samples": 37
    },
    {
      "name": "ReefBand2_04_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_003_TurquoiseTable.Visual",
      "cf": [
        -174.92801331758017,
        -53.07289565484068,
        52.39157961998733,
        0.9892024397850037,
        0.11546701192855835,
        0.09025294333696365,
        -0.12100295722484589,
        0.9909287691116333,
        0.05846758931875229,
        -0.08268318325281143,
        -0.06875715404748917,
        0.9942010641098022
      ],
      "scale": 1.146667627820215,
      "zone": 2,
      "samples": 27
    },
    {
      "name": "ReefBand2_06_0",
      "template": "Workspace.Decorations.ShoreRock_07.Visual",
      "cf": [
        -112.09472330013219,
        -55.325950907272144,
        -138.73441869736584,
        -0.8480480313301086,
        0,
        -0.5299193263053894,
        0,
        1,
        0,
        0.5299193263053894,
        0,
        -0.8480480313301086
      ],
      "scale": 1.1396921992257196,
      "zone": 2,
      "samples": 212
    },
    {
      "name": "ReefBand2_06_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_01_TurquoiseTable.Visual",
      "cf": [
        -104.10709285749081,
        -49.303873254256864,
        -137.2195132954417,
        0.7264425158500671,
        0.04611438885331154,
        0.6856786012649536,
        0.005709710530936718,
        0.9973065853118896,
        -0.07312167435884476,
        -0.6872037053108215,
        0.05703369528055191,
        0.7242226004600525
      ],
      "scale": 0.7339373622322337,
      "zone": 2,
      "samples": 50
    },
    {
      "name": "ReefBand2_06_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_049_SunbeamAntlers.Visual",
      "cf": [
        -100.99367604127467,
        -45.94124891455387,
        -136.2813086255222,
        0.5883626341819763,
        -0.09562163054943085,
        0.802923321723938,
        0.025913653895258904,
        0.9947028756141663,
        0.09947209805250168,
        -0.808181643486023,
        -0.0377190001308918,
        0.5877239108085632
      ],
      "scale": 1.0357918743226724,
      "zone": 2,
      "samples": 31
    },
    {
      "name": "ReefBand2_06_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_07_SunsetStaghorn.Visual",
      "cf": [
        -102.60095563266792,
        -46.80953836931717,
        -135.8189926100117,
        0.2305946946144104,
        0.04601990059018135,
        -0.9719612002372742,
        0.053819689899683,
        0.9967487454414368,
        0.05996209383010864,
        0.971560537815094,
        -0.06613756716251373,
        0.22736822068691254
      ],
      "scale": 1.2068190848132103,
      "zone": 2,
      "samples": 20
    },
    {
      "name": "ReefBand2_06_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_004_GoldenBrain.Visual",
      "cf": [
        -105.6444187468768,
        -60.73624316210364,
        -151.4498267870059,
        -0.08596451580524445,
        -0.07833579182624817,
        -0.9932137727737427,
        0.13291406631469727,
        0.9870911240577698,
        -0.08935684710741043,
        0.9873926639556885,
        -0.13969354331493378,
        -0.07444290071725845
      ],
      "scale": 1.0374315748179619,
      "zone": 2,
      "samples": 24
    },
    {
      "name": "ReefBand2_06_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_077_CrimsonLettuce.Visual",
      "cf": [
        -99.25738104057766,
        -47.067190632756734,
        -139.26677561212,
        0.9304539561271667,
        0.1311160922050476,
        -0.34214547276496887,
        -0.09393371641635895,
        0.9879334568977356,
        0.1231432631611824,
        0.35416311025619507,
        -0.08244020491838455,
        0.9315428137779236
      ],
      "scale": 1.147592034440656,
      "zone": 2,
      "samples": 16
    },
    {
      "name": "ReefBand2_07_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_88.Visual",
      "cf": [
        6.232830171357982,
        -51.91623170990211,
        -178.69360515063917,
        0.8030879497528076,
        0,
        0.595860481262207,
        0,
        1,
        0,
        -0.595860481262207,
        0,
        0.8030879497528076
      ],
      "scale": 0.7081341443815773,
      "zone": 2,
      "samples": 229
    },
    {
      "name": "ReefBand2_07_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_075_PeachCups.Visual",
      "cf": [
        -7.614739070038148,
        -57.73331654980093,
        -185.58762903658763,
        -0.9489197134971619,
        0.09470698237419128,
        0.3009679913520813,
        0.07102318108081818,
        0.9935223460197449,
        -0.08870770037174225,
        -0.3074197471141815,
        -0.06280079483985901,
        -0.9494993090629578
      ],
      "scale": 1.2273366078222328,
      "zone": 2,
      "samples": 25
    },
    {
      "name": "ReefBand2_07_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_078_CobaltTubes.Visual",
      "cf": [
        5.2679924194927334,
        -53.31819654106159,
        -181.7992333576748,
        -0.9967048168182373,
        0.08060286194086075,
        -0.009111842140555382,
        0.08094322681427002,
        0.9956167936325073,
        -0.04685142636299133,
        0.005295541137456894,
        -0.04743455722928047,
        -0.9988602995872498
      ],
      "scale": 1.154539601826265,
      "zone": 2,
      "samples": 36
    },
    {
      "name": "ReefBand2_07_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_07_SunbeamAntlers.Visual",
      "cf": [
        -2.2307049260636465,
        -52.71671710950606,
        -182.40428576121377,
        -0.9800797700881958,
        0.03837519884109497,
        0.19486235082149506,
        0.024062953889369965,
        0.9968711733818054,
        -0.07529176026582718,
        -0.19714201986789703,
        -0.06910292059183121,
        -0.977936863899231
      ],
      "scale": 0.9589305247544189,
      "zone": 2,
      "samples": 31
    },
    {
      "name": "ReefBand2_07_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_09_CrimsonLettuce.Visual",
      "cf": [
        -2.2125684135577153,
        -54.62015670944828,
        -182.76152527001426,
        0.9955565929412842,
        0.07401320338249207,
        0.058214571326971054,
        -0.0729178786277771,
        0.9971228241920471,
        -0.020723018795251846,
        -0.05958085507154465,
        0.016386061906814575,
        0.9980890154838562
      ],
      "scale": 1.1920377120943042,
      "zone": 2,
      "samples": 24
    },
    {
      "name": "ReefBand2_07_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_004_GoldenBrain.Visual",
      "cf": [
        6.690172999650343,
        -48.10123853390964,
        -173.43535063645243,
        -0.08596451580524445,
        -0.07833579182624817,
        -0.9932137727737427,
        0.13291406631469727,
        0.9870911240577698,
        -0.08935684710741043,
        0.9873926639556885,
        -0.13969354331493378,
        -0.07444290071725845
      ],
      "scale": 0.9007801887616255,
      "zone": 2,
      "samples": 27
    },
    {
      "name": "ReefBand2_09_0",
      "template": "Workspace.Decorations.ShoreRock_01.Visual",
      "cf": [
        175.8560623969086,
        -67.87128603889317,
        -62.11066993159722,
        0.8660253286361694,
        0,
        0.5000001192092896,
        0,
        1,
        0,
        -0.5000001192092896,
        0,
        0.8660253286361694
      ],
      "scale": 1.2550554007243133,
      "zone": 3,
      "samples": 212
    },
    {
      "name": "ReefBand2_09_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_03_CobaltTubes.Visual",
      "cf": [
        164.5842166397311,
        -50.639240216045174,
        -47.47076635267978,
        0.4055662751197815,
        -0.042194101959466934,
        0.9130910634994507,
        0.07023322582244873,
        0.9974191188812256,
        0.014895523898303509,
        -0.9113631844520569,
        0.05808820202946663,
        0.4074831008911133
      ],
      "scale": 1.28566936406936,
      "zone": 2,
      "samples": 25
    },
    {
      "name": "ReefBand2_09_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_054_GoldenBrain.Visual",
      "cf": [
        164.06728322212442,
        -50.78886865588835,
        -48.74474006028117,
        -0.4030073881149292,
        0.11856329441070557,
        0.9074844717979431,
        -0.06334875524044037,
        0.9855809807777405,
        -0.15689939260482788,
        -0.9130016565322876,
        -0.12071960419416428,
        -0.3896855413913727
      ],
      "scale": 1.2916509384451205,
      "zone": 2,
      "samples": 15
    },
    {
      "name": "ReefBand2_09_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_044_GoldenBrain.Visual",
      "cf": [
        159.1971891170336,
        -50.117398362876955,
        -51.4802103125289,
        -0.814301609992981,
        0.07997231185436249,
        -0.5749067664146423,
        0.10803206264972687,
        0.9940382838249207,
        -0.014741707593202591,
        0.5703004002571106,
        -0.07411252707242966,
        -0.8180863261222839
      ],
      "scale": 0.9756071605101176,
      "zone": 2,
      "samples": 24
    },
    {
      "name": "ReefBand2_09_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_09_CrimsonLettuce.Visual",
      "cf": [
        168.5528955061507,
        -59.30654228691004,
        -57.25574730713052,
        0.9955565929412842,
        0.07401320338249207,
        0.058214571326971054,
        -0.0729178786277771,
        0.9971228241920471,
        -0.020723018795251846,
        -0.05958085507154465,
        0.016386061906814575,
        0.9980890154838562
      ],
      "scale": 0.7776525470162515,
      "zone": 2,
      "samples": 34
    },
    {
      "name": "ReefBand2_09_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_010_MintPagoda.Visual",
      "cf": [
        173.85919806495411,
        -60.88963183611239,
        -54.050934512679035,
        -0.7157551050186157,
        -0.025168688967823982,
        -0.6978974938392639,
        -0.13712096214294434,
        0.9849618673324585,
        0.10510827600955963,
        0.6847570538520813,
        0.1709281951189041,
        -0.7084426879882812
      ],
      "scale": 1.093287002349728,
      "zone": 2,
      "samples": 19
    },
    {
      "name": "ReefBand3_00_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_20.Visual",
      "cf": [
        220.16016927742476,
        -87.60004715831404,
        40.75579060384249,
        -0.849296510219574,
        0,
        0.5279161334037781,
        0,
        1,
        0,
        -0.5279161334037781,
        0,
        -0.849296510219574
      ],
      "scale": 0.999147595886647,
      "zone": 3,
      "samples": 222
    },
    {
      "name": "ReefBand3_00_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_004_GoldenBrain.Visual",
      "cf": [
        219.8013169098683,
        -86.071979290216,
        36.945737713697206,
        -0.08596451580524445,
        -0.07833579182624817,
        -0.9932137727737427,
        0.13291406631469727,
        0.9870911240577698,
        -0.08935684710741043,
        0.9873926639556885,
        -0.13969354331493378,
        -0.07444290071725845
      ],
      "scale": 0.9113321153722467,
      "zone": 3,
      "samples": 27
    },
    {
      "name": "ReefBand3_00_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_054_GoldenBrain.Visual",
      "cf": [
        214.43841523492168,
        -79.93928976282314,
        38.45828855421962,
        -0.4030073881149292,
        0.11856329441070557,
        0.9074844717979431,
        -0.06334875524044037,
        0.9855809807777405,
        -0.15689939260482788,
        -0.9130016565322876,
        -0.12071960419416428,
        -0.3896855413913727
      ],
      "scale": 1.2417457151015348,
      "zone": 3,
      "samples": 16
    },
    {
      "name": "ReefBand3_00_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_054_GoldenBrain.Visual",
      "cf": [
        221.52662402860463,
        -87.27834305229231,
        36.3032517080834,
        -0.4030073881149292,
        0.11856329441070557,
        0.9074844717979431,
        -0.06334875524044037,
        0.9855809807777405,
        -0.15689939260482788,
        -0.9130016565322876,
        -0.12071960419416428,
        -0.3896855413913727
      ],
      "scale": 1.0957404817382435,
      "zone": 3,
      "samples": 19
    },
    {
      "name": "ReefBand3_00_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_065_PeachCups.Visual",
      "cf": [
        215.19869150290606,
        -80.24470135623454,
        32.6934594938636,
        0.8434862494468689,
        -0.0627909004688263,
        -0.5334680080413818,
        0.011592798866331577,
        0.9950409531593323,
        -0.0987897738814354,
        0.5370254516601562,
        0.07714344561100006,
        0.8400312662124634
      ],
      "scale": 0.7443143325642267,
      "zone": 3,
      "samples": 32
    },
    {
      "name": "ReefBand3_00_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_059_SunbeamAntlers.Visual",
      "cf": [
        211.18063011476434,
        -75.65655787849525,
        39.11959851201332,
        -0.9940223097801208,
        0.09903024882078171,
        -0.045967452228069305,
        0.09681160748004913,
        0.9941340684890747,
        0.048218414187431335,
        0.05047290772199631,
        0.043479979038238525,
        -0.9977787137031555
      ],
      "scale": 0.8542736044069041,
      "zone": 3,
      "samples": 31
    },
    {
      "name": "ReefBand3_02_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_08.Visual",
      "cf": [
        38.9078423490928,
        -90.24352553242613,
        209.61286174824977,
        0.9456452131271362,
        0,
        0.32520022988319397,
        0,
        1,
        0,
        -0.32520022988319397,
        0,
        0.9456452131271362
      ],
      "scale": 1.1615032855392675,
      "zone": 3,
      "samples": 196
    },
    {
      "name": "ReefBand3_02_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_078_CobaltTubes.Visual",
      "cf": [
        32.86958049397653,
        -91.85283672925276,
        214.0776867796689,
        -0.9967048168182373,
        0.08060286194086075,
        -0.009111842140555382,
        0.08094322681427002,
        0.9956167936325073,
        -0.04685142636299133,
        0.005295541137456894,
        -0.04743455722928047,
        -0.9988602995872498
      ],
      "scale": 1.101250211011533,
      "zone": 3,
      "samples": 38
    },
    {
      "name": "ReefBand3_02_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_03_SunbeamAntlers.Visual",
      "cf": [
        24.079207185606318,
        -80.80517139057272,
        205.44715087935114,
        -0.5493127107620239,
        -0.03757372498512268,
        0.8347716927528381,
        0.03166555240750313,
        0.9973350167274475,
        0.06572802364826202,
        -0.835016667842865,
        0.06253872811794281,
        -0.546658992767334
      ],
      "scale": 0.6524077706421411,
      "zone": 3,
      "samples": 33
    },
    {
      "name": "ReefBand3_02_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_08_GoldenBrain.Visual",
      "cf": [
        27.196153597457233,
        -82.97120888109129,
        205.71848061057756,
        0.795339047908783,
        0.13107027113437653,
        -0.5918244123458862,
        -0.057771988213062286,
        0.9882888197898865,
        0.14123612642288208,
        0.6034052968025208,
        -0.0781397596001625,
        0.7935968041419983
      ],
      "scale": 1.0304634347186536,
      "zone": 3,
      "samples": 29
    },
    {
      "name": "ReefBand3_02_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_004_GoldenBrain.Visual",
      "cf": [
        38.231275881417886,
        -94.05807575059181,
        216.10393593299844,
        -0.08596451580524445,
        -0.07833579182624817,
        -0.9932137727737427,
        0.13291406631469727,
        0.9870911240577698,
        -0.08935684710741043,
        0.9873926639556885,
        -0.13969354331493378,
        -0.07444290071725845
      ],
      "scale": 0.7339572531227916,
      "zone": 3,
      "samples": 34
    },
    {
      "name": "ReefBand3_02_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_01_SunsetStaghorn.Visual",
      "cf": [
        39.963015866333514,
        -93.25801072597791,
        217.44772303971905,
        0.32108861207962036,
        0.051856908947229385,
        -0.9456285238265991,
        -0.07529522478580475,
        0.9967371225357056,
        0.029093129560351372,
        0.94405198097229,
        0.06185983121395111,
        0.3239454925060272
      ],
      "scale": 1.0044159387042992,
      "zone": 3,
      "samples": 19
    },
    {
      "name": "ReefBand3_03_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_52.Visual",
      "cf": [
        -96.6318387254192,
        -89.028504281338,
        197.77824303513958,
        0.9998656511306763,
        0,
        -0.01638980396091938,
        0,
        1,
        0,
        0.01638980396091938,
        0,
        0.9998656511306763
      ],
      "scale": 1.238493440575589,
      "zone": 3,
      "samples": 219
    },
    {
      "name": "ReefBand3_03_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_017_CrimsonLettuce.Visual",
      "cf": [
        -91.83408693524302,
        -89.05168023787957,
        200.42105287889083,
        0.1194809302687645,
        0.12346747517585754,
        0.9851292967796326,
        -0.047579459846019745,
        0.9918095469474792,
        -0.11853403598070145,
        -0.9916955828666687,
        -0.03270937502384186,
        0.12437683343887329
      ],
      "scale": 0.7071473624819955,
      "zone": 3,
      "samples": 27
    },
    {
      "name": "ReefBand3_03_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_006_LavenderFingers.Visual",
      "cf": [
        -90.68460193697291,
        -88.59604985899774,
        201.53502883439006,
        -0.9173442125320435,
        0.04199201986193657,
        0.3958742916584015,
        0.06706506758928299,
        0.996509850025177,
        0.04970334842801094,
        -0.3924056589603424,
        0.07214440405368805,
        -0.9169588088989258
      ],
      "scale": 1.0573156965731874,
      "zone": 3,
      "samples": 12
    },
    {
      "name": "ReefBand3_03_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_038_CobaltTubes.Visual",
      "cf": [
        -104.68989457210029,
        -90.06551504951672,
        196.4301836764885,
        -0.010893287137150764,
        -0.018422242254018784,
        0.9997709393501282,
        0.1333557516336441,
        0.9908722043037415,
        0.019711289554834366,
        -0.9910084009170532,
        0.13353995978832245,
        -0.008337141945958138
      ],
      "scale": 0.8107031561337907,
      "zone": 3,
      "samples": 57
    },
    {
      "name": "ReefBand3_03_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_065_PeachCups.Visual",
      "cf": [
        -100.50612224744597,
        -90.55465011453289,
        198.75892266098316,
        0.8434862494468689,
        -0.0627909004688263,
        -0.5334680080413818,
        0.011592798866331577,
        0.9950409531593323,
        -0.0987897738814354,
        0.5370254516601562,
        0.07714344561100006,
        0.8400312662124634
      ],
      "scale": 1.0271448962609966,
      "zone": 3,
      "samples": 23
    },
    {
      "name": "ReefBand3_03_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_09_LavenderFingers.Visual",
      "cf": [
        -91.78564711849017,
        -86.34675679881303,
        198.04747603362162,
        0.5869461894035339,
        0.07265394926071167,
        -0.8063592910766602,
        -0.050006695091724396,
        0.9973172545433044,
        0.0534597672522068,
        0.8080801367759705,
        0.008945358917117119,
        0.5890047550201416
      ],
      "scale": 1.2765321896497195,
      "zone": 3,
      "samples": 12
    },
    {
      "name": "ReefBand3_04_0",
      "template": "Workspace.Decorations.ShoreRock_03.Visual",
      "cf": [
        -199.06407238759977,
        -85.8341689541545,
        108.8392824838858,
        1,
        0,
        2.384185791015625e-07,
        0,
        1,
        0,
        -2.384185791015625e-07,
        0,
        1
      ],
      "scale": 1.148794019383882,
      "zone": 3,
      "samples": 196
    },
    {
      "name": "ReefBand3_04_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_008_CobaltTubes.Visual",
      "cf": [
        -207.83958673601927,
        -89.54931058706869,
        99.55650012411394,
        0.33262574672698975,
        -0.0324031263589859,
        -0.9425020813941956,
        -0.06309646368026733,
        0.9964051246643066,
        -0.05652415752410889,
        0.9409454464912415,
        0.07826991379261017,
        0.3293854594230652
      ],
      "scale": 0.8005047888986334,
      "zone": 3,
      "samples": 28
    },
    {
      "name": "ReefBand3_04_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_017_CrimsonLettuce.Visual",
      "cf": [
        -205.44260541073317,
        -87.61792857493542,
        98.32155988398124,
        0.1194809302687645,
        0.12346747517585754,
        0.9851292967796326,
        -0.047579459846019745,
        0.9918095469474792,
        -0.11853403598070145,
        -0.9916955828666687,
        -0.03270937502384186,
        0.12437683343887329
      ],
      "scale": 0.8411302997488899,
      "zone": 3,
      "samples": 23
    },
    {
      "name": "ReefBand3_04_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_042_VioletSeaFan.Visual",
      "cf": [
        -207.23676932317878,
        -89.53674139220222,
        99.93617180357842,
        -0.7634177207946777,
        -0.03733833506703377,
        0.6448253393173218,
        -0.08645924925804138,
        0.9952507019042969,
        -0.044730767607688904,
        -0.6400926113128662,
        -0.08989932388067245,
        -0.763020396232605
      ],
      "scale": 0.7528386435552584,
      "zone": 3,
      "samples": 36
    },
    {
      "name": "ReefBand3_04_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_06_CrimsonLettuce.Visual",
      "cf": [
        -206.63290353166622,
        -89.54153316533592,
        100.29579315234652,
        -0.9937598705291748,
        -0.03667576611042023,
        -0.10533780604600906,
        -0.024266202002763748,
        0.9928638339042664,
        -0.11676014959812164,
        0.10886836051940918,
        -0.11347543448209763,
        -0.9875583052635193
      ],
      "scale": 1.1107122352545604,
      "zone": 3,
      "samples": 25
    },
    {
      "name": "ReefBand3_04_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_073_TurquoiseTable.Visual",
      "cf": [
        -200.35811182110854,
        -82.87414016477673,
        99.1762978067714,
        0.7012638449668884,
        -0.010421810671687126,
        -0.7128260135650635,
        -0.03557279706001282,
        0.998136043548584,
        -0.04958897829055786,
        0.7120143175125122,
        0.06013214960694313,
        0.6995861530303955
      ],
      "scale": 1.1083215709470688,
      "zone": 3,
      "samples": 24
    },
    {
      "name": "ReefBand3_05_0",
      "template": "Workspace.UnderwaterTerrain.CoralGardens.Garden01_08_ReefBoulder.Visual",
      "cf": [
        -205.15157098397756,
        -82.05895345802887,
        -42.72400862723248,
        0.9392200112342834,
        0,
        0.3433157801628113,
        0,
        1,
        0,
        -0.3433157801628113,
        0,
        0.9392200112342834
      ],
      "scale": 0.9028475442126268,
      "zone": 3,
      "samples": 196
    },
    {
      "name": "ReefBand3_05_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_004_GoldenBrain.Visual",
      "cf": [
        -213.96729026450197,
        -89.56430222754324,
        -39.657051904419724,
        -0.08596451580524445,
        -0.07833579182624817,
        -0.9932137727737427,
        0.13291406631469727,
        0.9870911240577698,
        -0.08935684710741043,
        0.9873926639556885,
        -0.13969354331493378,
        -0.07444290071725845
      ],
      "scale": 0.6503285832383169,
      "zone": 3,
      "samples": 43
    },
    {
      "name": "ReefBand3_05_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_046_LavenderFingers.Visual",
      "cf": [
        -202.10795153945375,
        -74.69081287840234,
        -26.08005677265367,
        0.9856142997741699,
        -0.09562164545059204,
        0.13935843110084534,
        0.08930693566799164,
        0.9947028756141663,
        0.05089686065912247,
        -0.1434870958328247,
        -0.0377189964056015,
        0.9889330267906189
      ],
      "scale": 0.6991296730265156,
      "zone": 3,
      "samples": 19
    },
    {
      "name": "ReefBand3_05_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_04_VioletSeaFan.Visual",
      "cf": [
        -206.80883844469056,
        -80.2361229768073,
        -28.111934721880274,
        -0.9551480412483215,
        -0.07784453779459,
        0.285713255405426,
        -0.07197420299053192,
        0.9969244003295898,
        0.031006811186671257,
        -0.2872481942176819,
        0.009052109904587269,
        -0.9578133821487427
      ],
      "scale": 0.8947360323906872,
      "zone": 3,
      "samples": 37
    },
    {
      "name": "ReefBand3_05_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_075_PeachCups.Visual",
      "cf": [
        -217.05508941302693,
        -91.21978288033287,
        -41.55291307122801,
        -0.9489197134971619,
        0.09470698237419128,
        0.3009679913520813,
        0.07102318108081818,
        0.9935223460197449,
        -0.08870770037174225,
        -0.3074197471141815,
        -0.06280079483985901,
        -0.9494993090629578
      ],
      "scale": 0.9393822031529744,
      "zone": 3,
      "samples": 42
    },
    {
      "name": "ReefBand3_05_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_071_SunsetStaghorn.Visual",
      "cf": [
        -202.1807923807182,
        -76.8974709549319,
        -41.216083221411296,
        0.18618527054786682,
        -0.010289905592799187,
        -0.9824609756469727,
        -0.06373211741447449,
        0.9977129101753235,
        -0.022527465596795082,
        0.9804458022117615,
        0.06680859625339508,
        0.18510358035564423
      ],
      "scale": 0.9691765404337895,
      "zone": 3,
      "samples": 19
    },
    {
      "name": "ReefBand3_07_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_64.Visual",
      "cf": [
        -34.0876114376842,
        -70.12583990699262,
        -208.07241625896856,
        -0.25362202525138855,
        0,
        -0.9673033952713013,
        0,
        1,
        0,
        0.9673033952713013,
        0,
        -0.25362202525138855
      ],
      "scale": 0.8391271923352104,
      "zone": 3,
      "samples": 214
    },
    {
      "name": "ReefBand3_07_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_021_SunsetStaghorn.Visual",
      "cf": [
        -42.45393011708252,
        -83.61723611262279,
        -220.6011177290025,
        -0.9955676198005676,
        -0.09403102099895477,
        0.001890090061351657,
        -0.09315004199743271,
        0.9830682277679443,
        -0.15779708325862885,
        0.012979729101061821,
        -0.15727365016937256,
        -0.9874699115753174
      ],
      "scale": 0.8519847943326273,
      "zone": 3,
      "samples": 23
    },
    {
      "name": "ReefBand3_07_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_021_SunsetStaghorn.Visual",
      "cf": [
        -34.124327793009186,
        -74.11810405927103,
        -213.54199415264924,
        -0.9955676198005676,
        -0.09403102099895477,
        0.001890090061351657,
        -0.09315004199743271,
        0.9830682277679443,
        -0.15779708325862885,
        0.012979729101061821,
        -0.15727365016937256,
        -0.9874699115753174
      ],
      "scale": 1.0074971261812848,
      "zone": 3,
      "samples": 19
    },
    {
      "name": "ReefBand3_07_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_037_CrimsonLettuce.Visual",
      "cf": [
        -41.486956841536525,
        -86.36818506051578,
        -223.61374060101244,
        0.8950909972190857,
        0.08623725175857544,
        0.4374638795852661,
        -0.10611863434314728,
        0.9941282272338867,
        0.021156007423996925,
        -0.43307068943977356,
        -0.06535965949296951,
        0.8989866375923157
      ],
      "scale": 0.9857552252098629,
      "zone": 3,
      "samples": 22
    },
    {
      "name": "ReefBand3_07_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_06_CrimsonLettuce.Visual",
      "cf": [
        -38.791424585782416,
        -70.54383130470286,
        -209.54498531731215,
        -0.9937598705291748,
        -0.03667576611042023,
        -0.10533780604600906,
        -0.024266202002763748,
        0.9928638339042664,
        -0.11676014959812164,
        0.10886836051940918,
        -0.11347543448209763,
        -0.9875583052635193
      ],
      "scale": 1.2193999815479364,
      "zone": 3,
      "samples": 23
    },
    {
      "name": "ReefBand3_07_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_055_PeachCups.Visual",
      "cf": [
        -33.045835787343705,
        -84.29808293368842,
        -223.74340498963545,
        0.8913282155990601,
        0.04093906283378601,
        0.45150554180145264,
        -0.042266298085451126,
        0.9990805387496948,
        -0.007149980869144201,
        -0.4513830840587616,
        -0.01271049864590168,
        0.8922389149665833
      ],
      "scale": 1.071245381032421,
      "zone": 3,
      "samples": 24
    },
    {
      "name": "ReefBand3_08_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_40.Visual",
      "cf": [
        93.72575656631379,
        -72.58299965215181,
        -181.9781128472883,
        -0.018740760162472725,
        0,
        0.9998244047164917,
        0,
        1,
        0,
        -0.9998244047164917,
        0,
        -0.018740760162472725
      ],
      "scale": 1.157879997626496,
      "zone": 3,
      "samples": 223
    },
    {
      "name": "ReefBand3_08_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_005_PeachCups.Visual",
      "cf": [
        105.75989152806275,
        -90.40594930407184,
        -198.05948630520325,
        -0.37297290563583374,
        0.06330561637878418,
        0.9256801009178162,
        -0.09388989210128784,
        0.9899735450744629,
        -0.1055324375629425,
        -0.9230796098709106,
        -0.12627272307872772,
        -0.3632895350456238
      ],
      "scale": 0.9570241524067351,
      "zone": 3,
      "samples": 37
    },
    {
      "name": "ReefBand3_08_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_005_PeachCups.Visual",
      "cf": [
        98.35921800842172,
        -83.6805142087357,
        -193.39483078826868,
        -0.37297290563583374,
        0.06330561637878418,
        0.9256801009178162,
        -0.09388989210128784,
        0.9899735450744629,
        -0.1055324375629425,
        -0.9230796098709106,
        -0.12627272307872772,
        -0.3632895350456238
      ],
      "scale": 1.2526223324345445,
      "zone": 3,
      "samples": 25
    },
    {
      "name": "ReefBand3_08_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_041_SunsetStaghorn.Visual",
      "cf": [
        89.66968118561633,
        -71.69558835056976,
        -186.1885280915022,
        -0.31585440039634705,
        -0.031223271042108536,
        0.9482935070991516,
        0.08154653757810593,
        0.9948668479919434,
        0.05991797521710396,
        -0.9452967643737793,
        0.09625545144081116,
        -0.3116868734359741
      ],
      "scale": 1.2517006082974906,
      "zone": 3,
      "samples": 21
    },
    {
      "name": "ReefBand3_08_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_023_TurquoiseTable.Visual",
      "cf": [
        97.05917959195953,
        -83.44391265474805,
        -194.83898208494892,
        -0.9179462790489197,
        -0.09769430011510849,
        -0.3844869136810303,
        -0.07590682059526443,
        0.9945496320724487,
        -0.07148081064224243,
        0.38937458395957947,
        -0.03643035516142845,
        -0.9203585982322693
      ],
      "scale": 1.1425139609614756,
      "zone": 3,
      "samples": 23
    },
    {
      "name": "ReefBand3_08_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_012_VioletSeaFan.Visual",
      "cf": [
        105.93396500894401,
        -82.41333945434343,
        -187.88921202738607,
        0.027845142409205437,
        0.021482080221176147,
        -0.999381422996521,
        0.11290169507265091,
        0.9933040738105774,
        0.024497153237462044,
        0.9932159185409546,
        -0.11351394653320312,
        0.025233330205082893
      ],
      "scale": 0.6513769777046317,
      "zone": 3,
      "samples": 28
    },
    {
      "name": "ReefBand3_09_0",
      "template": "Workspace.UnderwaterTerrain.CoralGardens.Garden01_08_ReefBoulder.Visual",
      "cf": [
        198.68260052936938,
        -91.52409051854458,
        -92.67300134224988,
        0.9392200112342834,
        0,
        0.3433157801628113,
        0,
        1,
        0,
        -0.3433157801628113,
        0,
        0.9392200112342834
      ],
      "scale": 0.985581433790785,
      "zone": 3,
      "samples": 196
    },
    {
      "name": "ReefBand3_09_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_001_SunsetStaghorn.Visual",
      "cf": [
        187.02584004402314,
        -84.45898031030409,
        -96.38482713075668,
        -0.17414076626300812,
        -0.07629100233316422,
        0.9817610383033752,
        0.06851060688495636,
        0.9936397671699524,
        0.08936621993780136,
        -0.9823346138000488,
        0.08282335102558136,
        -0.1678064912557602
      ],
      "scale": 1.1452258097129822,
      "zone": 3,
      "samples": 20
    },
    {
      "name": "ReefBand3_09_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_04_MintPagoda.Visual",
      "cf": [
        196.43152629912973,
        -90.70399328902582,
        -90.14330215878796,
        0.6571558713912964,
        -0.08022934943437576,
        0.7494728565216064,
        0.05595559626817703,
        0.9967683553695679,
        0.057638559490442276,
        -0.7516753077507019,
        0.004059679340571165,
        0.6595214605331421
      ],
      "scale": 0.7534340918373401,
      "zone": 3,
      "samples": 34
    },
    {
      "name": "ReefBand3_09_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_05_PeachCups.Visual",
      "cf": [
        187.44283835266327,
        -86.35760320005983,
        -96.38763070555937,
        -0.9077642560005188,
        -0.1498079001903534,
        -0.3918187618255615,
        -0.10695163905620575,
        0.985841691493988,
        -0.12914136052131653,
        0.40561774373054504,
        -0.07532420754432678,
        -0.9109341502189636
      ],
      "scale": 0.8518337237087394,
      "zone": 3,
      "samples": 31
    },
    {
      "name": "ReefBand3_09_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_067_CrimsonLettuce.Visual",
      "cf": [
        198.66870852347938,
        -92.93848106142535,
        -96.12769583348756,
        0.8999747037887573,
        -0.0627909004688263,
        0.43139681220054626,
        0.08986369520425797,
        0.9950407147407532,
        -0.0426417775452137,
        -0.42657992243766785,
        0.07714341580867767,
        0.9011538028717041
      ],
      "scale": 0.7773528084850219,
      "zone": 3,
      "samples": 30
    },
    {
      "name": "ReefBand3_09_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_029_SunbeamAntlers.Visual",
      "cf": [
        196.2760391702123,
        -91.30481235525359,
        -99.45416701954649,
        0.914326012134552,
        0.09047511219978333,
        0.3947434723377228,
        -0.03317328542470932,
        0.9881818890571594,
        -0.1496533751487732,
        -0.40361836552619934,
        0.12373702973127365,
        0.9065216183662415
      ],
      "scale": 0.7819981847929132,
      "zone": 3,
      "samples": 27
    },
    {
      "name": "ReefBand4_00_0",
      "template": "Workspace.UnderwaterTerrain.CoralGardens.Garden06_04_ReefBoulder.Visual",
      "cf": [
        240.7360847590413,
        -110.89595740140234,
        80.47192411112464,
        -0.9846878051757812,
        0,
        -0.17432722449302673,
        0,
        1,
        0,
        0.17432722449302673,
        0,
        -0.9846878051757812
      ],
      "scale": 1.5871740445102736,
      "zone": 4,
      "samples": 196
    },
    {
      "name": "ReefBand4_00_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_047_CrimsonLettuce.Visual",
      "cf": [
        245.29738344307754,
        -114.5699129501408,
        86.41574967002381,
        -0.9128879308700562,
        -0.08577419817447662,
        0.3990965485572815,
        -0.08381408452987671,
        0.9962295293807983,
        0.022395366802811623,
        -0.39951273798942566,
        -0.013005450367927551,
        -0.9166351556777954
      ],
      "scale": 1.3424410602671317,
      "zone": 4,
      "samples": 20
    },
    {
      "name": "ReefBand4_00_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_072_VioletSeaFan.Visual",
      "cf": [
        244.0293724947342,
        -111.5320214953975,
        79.94222705050652,
        0.9906892776489258,
        -0.010434187948703766,
        -0.1357419192790985,
        0.0015959071461111307,
        0.9978801608085632,
        -0.06505744904279709,
        0.13613300025463104,
        0.06423507630825043,
        0.9886059165000916
      ],
      "scale": 1.4724824166989814,
      "zone": 4,
      "samples": 22
    },
    {
      "name": "ReefBand4_00_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_08_VioletSeaFan.Visual",
      "cf": [
        237.5664320405312,
        -108.52861145122239,
        85.93629022371441,
        -0.8739197850227356,
        0.07936374098062515,
        -0.4795469641685486,
        0.09377530962228775,
        0.9955746531486511,
        -0.006129948887974024,
        0.47693824768066406,
        -0.05032676085829735,
        -0.8774943947792053
      ],
      "scale": 1.2419040909478585,
      "zone": 4,
      "samples": 21
    },
    {
      "name": "ReefBand4_00_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_002_VioletSeaFan.Visual",
      "cf": [
        238.63409484078645,
        -104.78573488585337,
        72.33806695582479,
        -0.6158629059791565,
        0.010083849541842937,
        0.7877890467643738,
        -0.0558738075196743,
        0.9968413710594177,
        -0.05643974989652634,
        -0.7858700156211853,
        -0.07877589762210846,
        -0.6133543848991394
      ],
      "scale": 1.1317443157775966,
      "zone": 4,
      "samples": 21
    },
    {
      "name": "ReefBand4_00_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_037_CrimsonLettuce.Visual",
      "cf": [
        238.94524522171307,
        -105.50119178067963,
        71.84842756005318,
        0.8950909972190857,
        0.08623725175857544,
        0.4374638795852661,
        -0.10611863434314728,
        0.9941282272338867,
        0.021156007423996925,
        -0.43307068943977356,
        -0.06535965949296951,
        0.8989866375923157
      ],
      "scale": 1.0514605001202169,
      "zone": 4,
      "samples": 21
    },
    {
      "name": "ReefBand4_01_0",
      "template": "Workspace.Decorations.ShoreRock_04.Visual",
      "cf": [
        163.6751564550755,
        -121.23526084401364,
        216.91073388097558,
        -0.7313538193702698,
        0,
        0.6819982528686523,
        0,
        1,
        0,
        -0.6819982528686523,
        0,
        -0.7313538193702698
      ],
      "scale": 1.2325422457830104,
      "zone": 4,
      "samples": 212
    },
    {
      "name": "ReefBand4_01_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_036_LavenderFingers.Visual",
      "cf": [
        147.1019474505024,
        -115.6547450601236,
        216.4032007391101,
        -0.8730697631835938,
        0.09501373022794724,
        0.47824883460998535,
        0.12464607506990433,
        0.9917317628860474,
        0.03052082657814026,
        -0.4713946282863617,
        0.08625857532024384,
        -0.8776940703392029
      ],
      "scale": 0.9640165751172054,
      "zone": 4,
      "samples": 10
    },
    {
      "name": "ReefBand4_01_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_030_MintPagoda.Visual",
      "cf": [
        154.14049839117308,
        -116.88737140266498,
        215.06940657754635,
        -0.9473670721054077,
        -0.13161155581474304,
        0.2918451726436615,
        -0.13472068309783936,
        0.990837812423706,
        0.009510994888842106,
        -0.2904229462146759,
        -0.030307183042168617,
        -0.9564179182052612
      ],
      "scale": 1.2671067916300167,
      "zone": 4,
      "samples": 23
    },
    {
      "name": "ReefBand4_01_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_028_CobaltTubes.Visual",
      "cf": [
        158.66696588945786,
        -118.12133015183574,
        212.80940146755273,
        -0.30138295888900757,
        0.10672587156295776,
        -0.9475113153457642,
        0.04046430438756943,
        0.9942522644996643,
        0.09911984205245972,
        0.9526439905166626,
        -0.008467348292469978,
        -0.3039693236351013
      ],
      "scale": 0.9042450778725258,
      "zone": 4,
      "samples": 44
    },
    {
      "name": "ReefBand4_01_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_043_TurquoiseTable.Visual",
      "cf": [
        152.8062126758762,
        -115.02936144499873,
        210.81317662227448,
        0.8492597341537476,
        -0.100254587829113,
        0.5183697938919067,
        0.08761869370937347,
        0.9949543476104736,
        0.04887966439127922,
        -0.5206546783447266,
        0.003907354082912207,
        0.853758692741394
      ],
      "scale": 1.5591127590385874,
      "zone": 4,
      "samples": 23
    },
    {
      "name": "ReefBand4_01_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_037_CrimsonLettuce.Visual",
      "cf": [
        149.96634475098872,
        -116.05882538808041,
        214.8282230445271,
        0.8950909972190857,
        0.08623725175857544,
        0.4374638795852661,
        -0.10611863434314728,
        0.9941282272338867,
        0.021156007423996925,
        -0.43307068943977356,
        -0.06535965949296951,
        0.8989866375923157
      ],
      "scale": 1.2649006264310179,
      "zone": 4,
      "samples": 18
    },
    {
      "name": "ReefBand4_02_0",
      "template": "Workspace.UnderwaterTerrain.CoralGardens.Garden03_08_ReefBoulder.Visual",
      "cf": [
        6.975591556797331,
        -121.88194786902608,
        262.500090383922,
        0.9392200112342834,
        0,
        0.3433157801628113,
        0,
        1,
        0,
        -0.3433157801628113,
        0,
        0.9392200112342834
      ],
      "scale": 1.5705899531632261,
      "zone": 4,
      "samples": 212
    },
    {
      "name": "ReefBand4_02_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_022_VioletSeaFan.Visual",
      "cf": [
        4.661231567392984,
        -120.4247724961471,
        262.940847762348,
        -0.6634873151779175,
        -0.08573579043149948,
        -0.7432591319084167,
        -0.08076493442058563,
        0.9958153963088989,
        -0.04277179762721062,
        0.743816077709198,
        0.03165074437856674,
        -0.667635440826416
      ],
      "scale": 1.2726987409845,
      "zone": 4,
      "samples": 21
    },
    {
      "name": "ReefBand4_02_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_01_VioletSeaFan.Visual",
      "cf": [
        5.215152407493904,
        -122.02637181412813,
        264.4382048147434,
        0.9687343239784241,
        0.06045636534690857,
        -0.24062202870845795,
        -0.07402670383453369,
        0.9961121082305908,
        -0.04775494709610939,
        0.23679937422275543,
        0.0640743151307106,
        0.9694432020187378
      ],
      "scale": 1.5229495125812735,
      "zone": 4,
      "samples": 22
    },
    {
      "name": "ReefBand4_02_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_031_SunsetStaghorn.Visual",
      "cf": [
        6.464717045129995,
        -126.76143925901295,
        269.06661016379786,
        0.28391772508621216,
        -0.026364309713244438,
        0.9584863185882568,
        0.1000179722905159,
        0.994982898235321,
        -0.0022585964761674404,
        -0.9536178112030029,
        0.09650709480047226,
        0.28513023257255554
      ],
      "scale": 1.5036369784104235,
      "zone": 5,
      "samples": 20
    },
    {
      "name": "ReefBand4_02_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_077_CrimsonLettuce.Visual",
      "cf": [
        -9.10064092172847,
        -122.63306614542701,
        264.99634605978594,
        0.9304539561271667,
        0.1311160922050476,
        -0.34214547276496887,
        -0.09393371641635895,
        0.9879334568977356,
        0.1231432631611824,
        0.35416311025619507,
        -0.08244020491838455,
        0.9315428137779236
      ],
      "scale": 1.3311188952168196,
      "zone": 4,
      "samples": 15
    },
    {
      "name": "ReefBand4_02_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_03_CobaltTubes.Visual",
      "cf": [
        -5.635415663862396,
        -117.29848808207734,
        257.43133533306474,
        0.4055662751197815,
        -0.042194101959466934,
        0.9130910634994507,
        0.07023322582244873,
        0.9974191188812256,
        0.014895523898303509,
        -0.9113631844520569,
        0.05808820202946663,
        0.4074831008911133
      ],
      "scale": 1.0741219029048348,
      "zone": 4,
      "samples": 29
    },
    {
      "name": "ReefBand4_04_0",
      "template": "Workspace.UnderwaterTerrain.CoralGardens.Garden03_04_ReefBoulder.Visual",
      "cf": [
        -245.3620347266132,
        -114.40559038117824,
        79.68820231814964,
        -0.9846878051757812,
        0,
        -0.17432722449302673,
        0,
        1,
        0,
        0.17432722449302673,
        0,
        -0.9846878051757812
      ],
      "scale": 1.3805498302876362,
      "zone": 4,
      "samples": 196
    },
    {
      "name": "ReefBand4_04_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_080_MintPagoda.Visual",
      "cf": [
        -248.10995530420502,
        -114.38288439876926,
        81.03413730049388,
        0.9856285452842712,
        0.14119142293930054,
        0.09274375438690186,
        -0.14628617465496063,
        0.9879465103149414,
        0.05061548575758934,
        -0.08447939157485962,
        -0.06345517933368683,
        0.9944028258323669
      ],
      "scale": 1.0815068274776216,
      "zone": 4,
      "samples": 21
    },
    {
      "name": "ReefBand4_04_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_055_PeachCups.Visual",
      "cf": [
        -255.9387802328273,
        -117.1857568057481,
        83.3223402117314,
        0.8913282155990601,
        0.04093906283378601,
        0.45150554180145264,
        -0.042266298085451126,
        0.9990805387496948,
        -0.007149980869144201,
        -0.4513830840587616,
        -0.01271049864590168,
        0.8922389149665833
      ],
      "scale": 1.4060736803622829,
      "zone": 4,
      "samples": 20
    },
    {
      "name": "ReefBand4_04_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_046_LavenderFingers.Visual",
      "cf": [
        -253.1224254528716,
        -115.54052895952273,
        76.68437854249609,
        0.9856142997741699,
        -0.09562164545059204,
        0.13935843110084534,
        0.08930693566799164,
        0.9947028756141663,
        0.05089686065912247,
        -0.1434870958328247,
        -0.0377189964056015,
        0.9889330267906189
      ],
      "scale": 1.3967959845076263,
      "zone": 4,
      "samples": 8
    },
    {
      "name": "ReefBand4_04_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_002_VioletSeaFan.Visual",
      "cf": [
        -244.58841462765812,
        -111.92689558883487,
        74.68984108157703,
        -0.6158629059791565,
        0.010083849541842937,
        0.7877890467643738,
        -0.0558738075196743,
        0.9968413710594177,
        -0.05643974989652634,
        -0.7858700156211853,
        -0.07877589762210846,
        -0.6133543848991394
      ],
      "scale": 1.0625777696454128,
      "zone": 4,
      "samples": 24
    },
    {
      "name": "ReefBand4_04_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_024_GoldenBrain.Visual",
      "cf": [
        -242.96435160260003,
        -111.99367036228577,
        80.4305239871026,
        -0.936768651008606,
        0.11738182604312897,
        -0.32967516779899597,
        0.12399190664291382,
        0.9922827482223511,
        0.0009833795484155416,
        0.32724639773368835,
        -0.03995586186647415,
        -0.9440938234329224
      ],
      "scale": 1.414453221906364,
      "zone": 4,
      "samples": 23
    },
    {
      "name": "ReefBand4_05_0",
      "template": "Workspace.Decorations.ShoreRock_07.Visual",
      "cf": [
        -244.17728198868042,
        -115.77529424093906,
        -80.17475569007108,
        -0.8480480313301086,
        0,
        -0.5299193263053894,
        0,
        1,
        0,
        0.5299193263053894,
        0,
        -0.8480480313301086
      ],
      "scale": 0.8796708493935758,
      "zone": 4,
      "samples": 212
    },
    {
      "name": "ReefBand4_05_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_08_GoldenBrain.Visual",
      "cf": [
        -254.91340450385835,
        -124.06636168843788,
        -85.81323377649076,
        0.795339047908783,
        0.13107027113437653,
        -0.5918244123458862,
        -0.057771988213062286,
        0.9882888197898865,
        0.14123612642288208,
        0.6034052968025208,
        -0.0781397596001625,
        0.7935968041419983
      ],
      "scale": 1.395858049198683,
      "zone": 4,
      "samples": 24
    },
    {
      "name": "ReefBand4_05_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_06_LavenderFingers.Visual",
      "cf": [
        -253.28830845963174,
        -119.09026930689237,
        -75.68958781251854,
        -0.6252635717391968,
        -0.048185233026742935,
        0.7789248824119568,
        -0.11548119783401489,
        0.9928169250488281,
        -0.0312829464673996,
        -0.771822452545166,
        -0.10951119661331177,
        -0.6263367533683777
      ],
      "scale": 1.356193254446629,
      "zone": 4,
      "samples": 8
    },
    {
      "name": "ReefBand4_05_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_055_PeachCups.Visual",
      "cf": [
        -245.62841377199862,
        -117.04885860571707,
        -83.43097448303386,
        0.8913282155990601,
        0.04093906283378601,
        0.45150554180145264,
        -0.042266298085451126,
        0.9990805387496948,
        -0.007149980869144201,
        -0.4513830840587616,
        -0.01271049864590168,
        0.8922389149665833
      ],
      "scale": 0.9225891813606844,
      "zone": 4,
      "samples": 28
    },
    {
      "name": "ReefBand4_05_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_004_GoldenBrain.Visual",
      "cf": [
        -250.74140571945298,
        -118.32918544470972,
        -79.56896176362538,
        -0.08596451580524445,
        -0.07833579182624817,
        -0.9932137727737427,
        0.13291406631469727,
        0.9870911240577698,
        -0.08935684710741043,
        0.9873926639556885,
        -0.13969354331493378,
        -0.07444290071725845
      ],
      "scale": 1.3426797597711868,
      "zone": 4,
      "samples": 19
    },
    {
      "name": "ReefBand4_05_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_018_CobaltTubes.Visual",
      "cf": [
        -257.2137915281343,
        -123.08971205323671,
        -78.45370055631875,
        0.8596060872077942,
        -0.09785894304513931,
        -0.501498818397522,
        0.018699370324611664,
        0.9868561029434204,
        -0.16051606833934784,
        0.5106150507926941,
        0.12860292196273804,
        0.8501374125480652
      ],
      "scale": 1.2295568675896238,
      "zone": 4,
      "samples": 30
    },
    {
      "name": "ReefBand4_06_0",
      "template": "Workspace.UnderwaterTerrain.CoralGardens.Garden06_04_ReefBoulder.Visual",
      "cf": [
        -146.1712040692968,
        -114.42910849572544,
        -206.20256646557493,
        -0.9846878051757812,
        0,
        -0.17432722449302673,
        0,
        1,
        0,
        0.17432722449302673,
        0,
        -0.9846878051757812
      ],
      "scale": 1.1053859146430338,
      "zone": 4,
      "samples": 196
    },
    {
      "name": "ReefBand4_06_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_04_VioletSeaFan.Visual",
      "cf": [
        -149.93572217912185,
        -120.10281219885574,
        -219.83033692160538,
        -0.9551480412483215,
        -0.07784453779459,
        0.285713255405426,
        -0.07197420299053192,
        0.9969244003295898,
        0.031006811186671257,
        -0.2872481942176819,
        0.009052109904587269,
        -0.9578133821487427
      ],
      "scale": 0.9746830763687199,
      "zone": 4,
      "samples": 34
    },
    {
      "name": "ReefBand4_06_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_062_VioletSeaFan.Visual",
      "cf": [
        -160.64481056597114,
        -119.11055614666422,
        -210.84295887496373,
        -0.9751834273338318,
        0.0990302637219429,
        0.19801601767539978,
        0.10565204173326492,
        0.9941340684890747,
        0.02313327230513096,
        -0.19456352293491364,
        0.043479982763528824,
        -0.9799259305000305
      ],
      "scale": 1.2397390996331812,
      "zone": 4,
      "samples": 23
    },
    {
      "name": "ReefBand4_06_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_09_CrimsonLettuce.Visual",
      "cf": [
        -148.375819809475,
        -115.93870252664196,
        -208.45039270483394,
        0.9955565929412842,
        0.07401320338249207,
        0.058214571326971054,
        -0.0729178786277771,
        0.9971228241920471,
        -0.020723018795251846,
        -0.05958085507154465,
        0.016386061906814575,
        0.9980890154838562
      ],
      "scale": 1.2070043697086728,
      "zone": 4,
      "samples": 24
    },
    {
      "name": "ReefBand4_06_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_024_GoldenBrain.Visual",
      "cf": [
        -145.77748845910978,
        -116.92745774521997,
        -215.83775105854198,
        -0.936768651008606,
        0.11738182604312897,
        -0.32967516779899597,
        0.12399190664291382,
        0.9922827482223511,
        0.0009833795484155416,
        0.32724639773368835,
        -0.03995586186647415,
        -0.9440938234329224
      ],
      "scale": 1.497301892183833,
      "zone": 4,
      "samples": 21
    },
    {
      "name": "ReefBand4_06_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_055_PeachCups.Visual",
      "cf": [
        -150.78431330864464,
        -117.22319923683347,
        -213.8190538951599,
        0.8913282155990601,
        0.04093906283378601,
        0.45150554180145264,
        -0.042266298085451126,
        0.9990805387496948,
        -0.007149980869144201,
        -0.4513830840587616,
        -0.01271049864590168,
        0.8922389149665833
      ],
      "scale": 0.9400364808364838,
      "zone": 4,
      "samples": 27
    },
    {
      "name": "ReefBand4_07_0",
      "template": "Workspace.Decorations.ShoreRock_04.Visual",
      "cf": [
        7.497769450150571,
        -113.01395454076405,
        -258.54597458730467,
        -0.7313538193702698,
        0,
        0.6819982528686523,
        0,
        1,
        0,
        -0.6819982528686523,
        0,
        -0.7313538193702698
      ],
      "scale": 0.8790737102270157,
      "zone": 4,
      "samples": 212
    },
    {
      "name": "ReefBand4_07_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_001_SunsetStaghorn.Visual",
      "cf": [
        -4.449010842347354,
        -114.09982822995734,
        -262.8078277397544,
        -0.17414076626300812,
        -0.07629100233316422,
        0.9817610383033752,
        0.06851060688495636,
        0.9936397671699524,
        0.08936621993780136,
        -0.9823346138000488,
        0.08282335102558136,
        -0.1678064912557602
      ],
      "scale": 0.9069980646165168,
      "zone": 4,
      "samples": 20
    },
    {
      "name": "ReefBand4_07_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_069_SunbeamAntlers.Visual",
      "cf": [
        -6.7837250843209915,
        -113.09526515368484,
        -260.28261024813463,
        0.9970521926879883,
        -0.037005484104156494,
        -0.0672125592827797,
        0.025887440890073776,
        0.9868855476379395,
        -0.15933121740818024,
        0.07222723215818405,
        0.15712158381938934,
        0.9849344491958618
      ],
      "scale": 0.9347696605395217,
      "zone": 4,
      "samples": 28
    },
    {
      "name": "ReefBand4_07_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_014_GoldenBrain.Visual",
      "cf": [
        5.830908294849584,
        -114.67263340689887,
        -265.959456400155,
        0.651218593120575,
        0.14531700313091278,
        0.7448472380638123,
        -0.15730014443397522,
        0.9860268235206604,
        -0.05484306067228317,
        -0.7424088716506958,
        -0.08144976943731308,
        0.6649771332740784
      ],
      "scale": 1.592378644110013,
      "zone": 4,
      "samples": 14
    },
    {
      "name": "ReefBand4_07_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_061_SunsetStaghorn.Visual",
      "cf": [
        3.253079038951062,
        -111.19564940791139,
        -256.8508409484369,
        -0.704218327999115,
        0.16214871406555176,
        0.6912195682525635,
        0.16622358560562134,
        0.9841669797897339,
        -0.06151983514428139,
        -0.6902506351470947,
        0.07157359272241592,
        -0.7200213670730591
      ],
      "scale": 0.897405643117656,
      "zone": 4,
      "samples": 26
    },
    {
      "name": "ReefBand4_07_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_031_SunsetStaghorn.Visual",
      "cf": [
        -3.5534106882584866,
        -109.91852101739374,
        -256.738463997023,
        0.28391772508621216,
        -0.026364309713244438,
        0.9584863185882568,
        0.1000179722905159,
        0.994982898235321,
        -0.0022585964761674404,
        -0.9536178112030029,
        0.09650709480047226,
        0.28513023257255554
      ],
      "scale": 1.4582885049350596,
      "zone": 4,
      "samples": 20
    },
    {
      "name": "ReefBand4_08_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_64.Visual",
      "cf": [
        158.94823372484294,
        -121.46566671820355,
        -215.26844954308473,
        -0.25362202525138855,
        0,
        -0.9673033952713013,
        0,
        1,
        0,
        0.9673033952713013,
        0,
        -0.25362202525138855
      ],
      "scale": 0.8805634366646525,
      "zone": 4,
      "samples": 213
    },
    {
      "name": "ReefBand4_08_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_029_SunbeamAntlers.Visual",
      "cf": [
        158.88233475016412,
        -122.22493649250686,
        -218.30952914183936,
        0.914326012134552,
        0.09047511219978333,
        0.3947434723377228,
        -0.03317328542470932,
        0.9881818890571594,
        -0.1496533751487732,
        -0.40361836552619934,
        0.12373702973127365,
        0.9065216183662415
      ],
      "scale": 0.9738554710648796,
      "zone": 4,
      "samples": 27
    },
    {
      "name": "ReefBand4_08_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_066_LavenderFingers.Visual",
      "cf": [
        164.28767186663805,
        -115.9169543317831,
        -204.26128516114073,
        -0.9882205128669739,
        -0.06669452786445618,
        0.13774029910564423,
        -0.055698931217193604,
        0.9950584173202515,
        0.08219935745000839,
        -0.14254193007946014,
        0.07355908304452896,
        -0.9870519638061523
      ],
      "scale": 1.5847951173134902,
      "zone": 4,
      "samples": 11
    },
    {
      "name": "ReefBand4_08_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_044_GoldenBrain.Visual",
      "cf": [
        151.45296096200136,
        -117.1524364366029,
        -210.44091782491387,
        -0.814301609992981,
        0.07997231185436249,
        -0.5749067664146423,
        0.10803206264972687,
        0.9940382838249207,
        -0.014741707593202591,
        0.5703004002571106,
        -0.07411252707242966,
        -0.8180863261222839
      ],
      "scale": 1.28726338369469,
      "zone": 4,
      "samples": 21
    },
    {
      "name": "ReefBand4_08_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_075_PeachCups.Visual",
      "cf": [
        160.81923275648978,
        -119.19031338546154,
        -210.35197853125078,
        -0.9489197134971619,
        0.09470698237419128,
        0.3009679913520813,
        0.07102318108081818,
        0.9935223460197449,
        -0.08870770037174225,
        -0.3074197471141815,
        -0.06280079483985901,
        -0.9494993090629578
      ],
      "scale": 1.3087269446997454,
      "zone": 4,
      "samples": 24
    },
    {
      "name": "ReefBand4_08_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_013_TurquoiseTable.Visual",
      "cf": [
        156.16640577146526,
        -118.74758927267003,
        -214.23713432582872,
        -0.8882648944854736,
        -0.08577420562505722,
        0.45125195384025574,
        -0.08237776160240173,
        0.9962295293807983,
        0.02720773033797741,
        -0.4518842399120331,
        -0.013005456887185574,
        -0.8919814825057983
      ],
      "scale": 1.5727667434964023,
      "zone": 4,
      "samples": 24
    },
    {
      "name": "ReefBand5_00_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_56.Visual",
      "cf": [
        302.10233797849145,
        -142.20746323275299,
        39.39442915801433,
        -0.9946389198303223,
        0,
        -0.1034088134765625,
        0,
        1,
        0,
        0.1034088134765625,
        0,
        -0.9946389198303223
      ],
      "scale": 1.308496283230918,
      "zone": 5,
      "samples": 212
    },
    {
      "name": "ReefBand5_00_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_043_TurquoiseTable.Visual",
      "cf": [
        301.05253685593976,
        -141.90702155102952,
        53.19732763619403,
        0.8492597341537476,
        -0.100254587829113,
        0.5183697938919067,
        0.08761869370937347,
        0.9949543476104736,
        0.04887966439127922,
        -0.5206546783447266,
        0.003907354082912207,
        0.853758692741394
      ],
      "scale": 1.5333282660838632,
      "zone": 5,
      "samples": 23
    },
    {
      "name": "ReefBand5_00_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_04_SunsetStaghorn.Visual",
      "cf": [
        296.068347101498,
        -137.70483842109925,
        40.40734663441628,
        -0.2755658030509949,
        -0.08162442594766617,
        0.957810640335083,
        -0.02162574976682663,
        0.9966626763343811,
        0.07871359586715698,
        -0.9610389471054077,
        0.0009773981291800737,
        -0.27641138434410095
      ],
      "scale": 1.4673726894842232,
      "zone": 5,
      "samples": 20
    },
    {
      "name": "ReefBand5_00_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_023_TurquoiseTable.Visual",
      "cf": [
        291.14933719177685,
        -137.8149399685528,
        42.846758633196515,
        -0.9179462790489197,
        -0.09769430011510849,
        -0.3844869136810303,
        -0.07590682059526443,
        0.9945496320724487,
        -0.07148081064224243,
        0.38937458395957947,
        -0.03643035516142845,
        -0.9203585982322693
      ],
      "scale": 1.3338703448711378,
      "zone": 5,
      "samples": 23
    },
    {
      "name": "ReefBand5_00_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_055_PeachCups.Visual",
      "cf": [
        304.1071315504564,
        -144.8373971720131,
        54.60020234252111,
        0.8913282155990601,
        0.04093906283378601,
        0.45150554180145264,
        -0.042266298085451126,
        0.9990805387496948,
        -0.007149980869144201,
        -0.4513830840587616,
        -0.01271049864590168,
        0.8922389149665833
      ],
      "scale": 0.8661376581931244,
      "zone": 5,
      "samples": 29
    },
    {
      "name": "ReefBand5_00_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_070_MintPagoda.Visual",
      "cf": [
        304.04026239905227,
        -143.18846646732126,
        42.70932386387251,
        0.45661869645118713,
        -0.010289905592799187,
        -0.8896030187606812,
        -0.05475109443068504,
        0.9977129101753235,
        -0.03964322432875633,
        0.887976348400116,
        0.06680859625339508,
        0.45501089096069336
      ],
      "scale": 0.911253989696834,
      "zone": 5,
      "samples": 27
    },
    {
      "name": "ReefBand5_01_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_80.Visual",
      "cf": [
        209.56219596522266,
        -138.49827298110807,
        216.82909395256922,
        0.15051239728927612,
        0,
        0.9886081218719482,
        0,
        1,
        0,
        -0.9886081218719482,
        0,
        0.15051239728927612
      ],
      "scale": 1.5276011008649417,
      "zone": 5,
      "samples": 205
    },
    {
      "name": "ReefBand5_01_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_070_MintPagoda.Visual",
      "cf": [
        212.00658546618516,
        -137.38865920261418,
        211.95566584494736,
        0.45661869645118713,
        -0.010289905592799187,
        -0.8896030187606812,
        -0.05475109443068504,
        0.9977129101753235,
        -0.03964322432875633,
        0.887976348400116,
        0.06680859625339508,
        0.45501089096069336
      ],
      "scale": 1.42318430436202,
      "zone": 5,
      "samples": 23
    },
    {
      "name": "ReefBand5_01_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_023_TurquoiseTable.Visual",
      "cf": [
        206.42509135226322,
        -140.73157196349197,
        224.641492110321,
        -0.9179462790489197,
        -0.09769430011510849,
        -0.3844869136810303,
        -0.07590682059526443,
        0.9945496320724487,
        -0.07148081064224243,
        0.38937458395957947,
        -0.03643035516142845,
        -0.9203585982322693
      ],
      "scale": 1.1665833101876522,
      "zone": 5,
      "samples": 23
    },
    {
      "name": "ReefBand5_01_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_015_PeachCups.Visual",
      "cf": [
        223.10475423268355,
        -145.25447854585846,
        215.74238176331235,
        -0.8186210989952087,
        0.046649277210235596,
        0.5724359154701233,
        0.06199803948402405,
        0.9980495572090149,
        0.007327673025429249,
        -0.5709778070449829,
        0.041488517075777054,
        -0.8199164867401123
      ],
      "scale": 1.0357702038732262,
      "zone": 5,
      "samples": 31
    },
    {
      "name": "ReefBand5_01_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_001_SunsetStaghorn.Visual",
      "cf": [
        208.2405654188854,
        -136.27412804804118,
        212.02930513383038,
        -0.17414076626300812,
        -0.07629100233316422,
        0.9817610383033752,
        0.06851060688495636,
        0.9936397671699524,
        0.08936621993780136,
        -0.9823346138000488,
        0.08282335102558136,
        -0.1678064912557602
      ],
      "scale": 1.149796712270876,
      "zone": 5,
      "samples": 20
    },
    {
      "name": "ReefBand5_01_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_036_LavenderFingers.Visual",
      "cf": [
        221.22327925580316,
        -138.6621481137679,
        207.33384635829583,
        -0.8730697631835938,
        0.09501373022794724,
        0.47824883460998535,
        0.12464607506990433,
        0.9917317628860474,
        0.03052082657814026,
        -0.4713946282863617,
        0.08625857532024384,
        -0.8776940703392029
      ],
      "scale": 1.4071214449796055,
      "zone": 5,
      "samples": 7
    },
    {
      "name": "ReefBand5_03_0",
      "template": "Workspace.UnderwaterTerrain.CoralGardens.Garden04_04_ReefBoulder.Visual",
      "cf": [
        -148.33557720900288,
        -150.3611859188734,
        268.7478550770945,
        -0.9846878051757812,
        0,
        -0.17432722449302673,
        0,
        1,
        0,
        0.17432722449302673,
        0,
        -0.9846878051757812
      ],
      "scale": 1.0049673259543,
      "zone": 5,
      "samples": 205
    },
    {
      "name": "ReefBand5_03_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_05_GoldenBrain.Visual",
      "cf": [
        -136.15212361380722,
        -141.34651984721862,
        265.1218721089285,
        -0.8179720044136047,
        -0.1663660705089569,
        0.5506759881973267,
        -0.19259095191955566,
        0.9812242984771729,
        0.01036626473069191,
        -0.5420613884925842,
        -0.09757592529058456,
        -0.8346545100212097
      ],
      "scale": 1.4224783465551032,
      "zone": 5,
      "samples": 16
    },
    {
      "name": "ReefBand5_03_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_046_LavenderFingers.Visual",
      "cf": [
        -142.3296673691197,
        -151.36875028913883,
        277.0142480180522,
        0.9856142997741699,
        -0.09562164545059204,
        0.13935843110084534,
        0.08930693566799164,
        0.9947028756141663,
        0.05089686065912247,
        -0.1434870958328247,
        -0.0377189964056015,
        0.9889330267906189
      ],
      "scale": 0.8354304482523188,
      "zone": 5,
      "samples": 13
    },
    {
      "name": "ReefBand5_03_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_09_LavenderFingers.Visual",
      "cf": [
        -146.97591129377523,
        -147.9530875084027,
        268.1657951713726,
        0.5869461894035339,
        0.07265394926071167,
        -0.8063592910766602,
        -0.050006695091724396,
        0.9973172545433044,
        0.0534597672522068,
        0.8080801367759705,
        0.008945358917117119,
        0.5890047550201416
      ],
      "scale": 1.1524443012091847,
      "zone": 5,
      "samples": 15
    },
    {
      "name": "ReefBand5_03_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_030_MintPagoda.Visual",
      "cf": [
        -141.93018046798323,
        -153.04239466286566,
        280.7256196980639,
        -0.9473670721054077,
        -0.13161155581474304,
        0.2918451726436615,
        -0.13472068309783936,
        0.990837812423706,
        0.009510994888842106,
        -0.2904229462146759,
        -0.030307183042168617,
        -0.9564179182052612
      ],
      "scale": 0.8688372863180445,
      "zone": 5,
      "samples": 27
    },
    {
      "name": "ReefBand5_03_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_048_CobaltTubes.Visual",
      "cf": [
        -142.90505837668096,
        -148.37406900565986,
        271.60075687971596,
        -0.04614562168717384,
        -0.09562164545059204,
        -0.9943475723266602,
        0.03342223912477493,
        0.9947028756141663,
        -0.09720686823129654,
        0.9983753561973572,
        -0.0377190001308918,
        -0.042705290019512177
      ],
      "scale": 1.006955962262001,
      "zone": 5,
      "samples": 27
    },
    {
      "name": "ReefBand5_04_0",
      "template": "Workspace.Decorations.ShoreRock_00.Visual",
      "cf": [
        -280.3160899420581,
        -147.88521568981707,
        142.22916831708278,
        -0.9612616896629333,
        0,
        -0.2756374478340149,
        0,
        1,
        0,
        0.2756374478340149,
        0,
        -0.9612616896629333
      ],
      "scale": 1.4308861087894087,
      "zone": 5,
      "samples": 196
    },
    {
      "name": "ReefBand5_04_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_026_LavenderFingers.Visual",
      "cf": [
        -273.1463553335713,
        -139.59369477849964,
        133.04945792642965,
        -0.5544924139976501,
        0.10127705335617065,
        -0.8260030746459961,
        -0.03611498698592186,
        0.9887033104896545,
        0.14546972513198853,
        0.8314046263694763,
        0.11049296706914902,
        -0.5445708632469177
      ],
      "scale": 1.2163378127160498,
      "zone": 5,
      "samples": 15
    },
    {
      "name": "ReefBand5_04_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_034_GoldenBrain.Visual",
      "cf": [
        -270.54301616999595,
        -138.16970850806302,
        129.30254270607278,
        0.849556028842926,
        -0.1351654976606369,
        -0.5098870992660522,
        0.1600424200296402,
        0.9870976805686951,
        0.004988342523574829,
        0.5026340484619141,
        -0.08584143221378326,
        0.860227108001709
      ],
      "scale": 1.2608043939610403,
      "zone": 5,
      "samples": 14
    },
    {
      "name": "ReefBand5_04_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_047_CrimsonLettuce.Visual",
      "cf": [
        -272.20909439812823,
        -139.9139796627881,
        134.36617485485306,
        -0.9128879308700562,
        -0.08577419817447662,
        0.3990965485572815,
        -0.08381408452987671,
        0.9962295293807983,
        0.022395366802811623,
        -0.39951273798942566,
        -0.013005450367927551,
        -0.9166351556777954
      ],
      "scale": 1.091928027618117,
      "zone": 5,
      "samples": 20
    },
    {
      "name": "ReefBand5_04_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_068_CobaltTubes.Visual",
      "cf": [
        -277.6635807087636,
        -141.6098884350843,
        131.9087855594514,
        -0.7967791557312012,
        -0.09810667484998703,
        0.5962538123130798,
        0.015744807198643684,
        0.9830266237258911,
        0.1827857345342636,
        -0.6040657758712769,
        0.15502765774726868,
        -0.7817105650901794
      ],
      "scale": 1.0696111430876507,
      "zone": 5,
      "samples": 32
    },
    {
      "name": "ReefBand5_04_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_07_MintPagoda.Visual",
      "cf": [
        -272.71535729199064,
        -143.6079989874373,
        145.94247394185155,
        -0.6935103535652161,
        0.03837519884109497,
        -0.7194242477416992,
        0.07635708153247833,
        0.9968711733818054,
        -0.02043202333152294,
        0.7163890600204468,
        -0.06910292059183121,
        -0.6942708492279053
      ],
      "scale": 1.3302244158257301,
      "zone": 5,
      "samples": 22
    },
    {
      "name": "ReefBand5_06_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_04.Visual",
      "cf": [
        -208.86477614829218,
        -148.98851182929474,
        -214.46273569158703,
        -0.23366567492485046,
        0,
        0.9723169803619385,
        0,
        1,
        0,
        -0.9723169803619385,
        0,
        -0.23366567492485046
      ],
      "scale": 1.2564554052501273,
      "zone": 5,
      "samples": 205
    },
    {
      "name": "ReefBand5_06_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_035_PeachCups.Visual",
      "cf": [
        -218.32177310481666,
        -153.50424550953275,
        -219.43816086661988,
        -0.7889673113822937,
        -0.024575548246502876,
        0.6139440536499023,
        -0.10814419388771057,
        0.9891555309295654,
        -0.09937908500432968,
        -0.60484379529953,
        -0.14480121433734894,
        -0.7830690741539001
      ],
      "scale": 1.182101108168139,
      "zone": 5,
      "samples": 15
    },
    {
      "name": "ReefBand5_06_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_056_LavenderFingers.Visual",
      "cf": [
        -205.73879098979475,
        -147.8806398609395,
        -219.3832025576781,
        -0.9930487275123596,
        0.10840848088264465,
        0.04584178328514099,
        0.10353318601846695,
        0.9897944331169128,
        -0.09791470319032669,
        -0.05598871782422066,
        -0.09248794615268707,
        -0.9941378235816956
      ],
      "scale": 1.09361630125989,
      "zone": 5,
      "samples": 9
    },
    {
      "name": "ReefBand5_06_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_05_GoldenBrain.Visual",
      "cf": [
        -219.65339845877014,
        -150.2999188961111,
        -208.26007421415468,
        -0.8179720044136047,
        -0.1663660705089569,
        0.5506759881973267,
        -0.19259095191955566,
        0.9812242984771729,
        0.01036626473069191,
        -0.5420613884925842,
        -0.09757592529058456,
        -0.8346545100212097
      ],
      "scale": 0.8705679588990309,
      "zone": 5,
      "samples": 21
    },
    {
      "name": "ReefBand5_06_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_022_VioletSeaFan.Visual",
      "cf": [
        -211.85214959314055,
        -147.48821708663843,
        -212.6128316521839,
        -0.6634873151779175,
        -0.08573579043149948,
        -0.7432591319084167,
        -0.08076493442058563,
        0.9958153963088989,
        -0.04277179762721062,
        0.743816077709198,
        0.03165074437856674,
        -0.667635440826416
      ],
      "scale": 0.8642614102846197,
      "zone": 5,
      "samples": 22
    },
    {
      "name": "ReefBand5_06_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_07_SunbeamAntlers.Visual",
      "cf": [
        -216.1543762162129,
        -146.52103455879944,
        -207.3192869815507,
        -0.9800797700881958,
        0.03837519884109497,
        0.19486235082149506,
        0.024062953889369965,
        0.9968711733818054,
        -0.07529176026582718,
        -0.19714201986789703,
        -0.06910292059183121,
        -0.977936863899231
      ],
      "scale": 0.9134371994631868,
      "zone": 5,
      "samples": 31
    },
    {
      "name": "ReefBand5_07_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_28.Visual",
      "cf": [
        -41.92792863495273,
        -139.78759195202585,
        -300.8459039580977,
        -0.7468060851097107,
        0,
        0.6650418639183044,
        0,
        1,
        0,
        -0.6650418639183044,
        0,
        -0.7468060851097107
      ],
      "scale": 1.515982677606944,
      "zone": 5,
      "samples": 212
    },
    {
      "name": "ReefBand5_07_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_032_VioletSeaFan.Visual",
      "cf": [
        -38.9857026752984,
        -139.51608958944308,
        -303.94554385623445,
        0.7235102653503418,
        -0.045412737876176834,
        0.6888179183006287,
        -0.03192097321152687,
        0.994565486907959,
        0.09909886866807938,
        -0.6895750164985657,
        -0.09368682652711868,
        0.7181288599967957
      ],
      "scale": 0.9698866457414579,
      "zone": 5,
      "samples": 22
    },
    {
      "name": "ReefBand5_07_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_044_GoldenBrain.Visual",
      "cf": [
        -45.103542171365596,
        -138.3412811622417,
        -300.42206911426257,
        -0.814301609992981,
        0.07997231185436249,
        -0.5749067664146423,
        0.10803206264972687,
        0.9940382838249207,
        -0.014741707593202591,
        0.5703004002571106,
        -0.07411252707242966,
        -0.8180863261222839
      ],
      "scale": 1.6089787225668744,
      "zone": 5,
      "samples": 17
    },
    {
      "name": "ReefBand5_07_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_010_MintPagoda.Visual",
      "cf": [
        -48.768869553603245,
        -140.25848241303646,
        -304.41758095297996,
        -0.7157551050186157,
        -0.025168688967823982,
        -0.6978974938392639,
        -0.13712096214294434,
        0.9849618673324585,
        0.10510827600955963,
        0.6847570538520813,
        0.1709281951189041,
        -0.7084426879882812
      ],
      "scale": 1.2904791053091313,
      "zone": 5,
      "samples": 19
    },
    {
      "name": "ReefBand5_07_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_06_CrimsonLettuce.Visual",
      "cf": [
        -55.64016404086793,
        -143.2565972128792,
        -306.56512822466095,
        -0.9937598705291748,
        -0.03667576611042023,
        -0.10533780604600906,
        -0.024266202002763748,
        0.9928638339042664,
        -0.11676014959812164,
        0.10886836051940918,
        -0.11347543448209763,
        -0.9875583052635193
      ],
      "scale": 1.495933034544017,
      "zone": 5,
      "samples": 21
    },
    {
      "name": "ReefBand5_07_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_078_CobaltTubes.Visual",
      "cf": [
        -42.78396891099157,
        -137.01032368487162,
        -292.9767660074031,
        -0.9967048168182373,
        0.08060286194086075,
        -0.009111842140555382,
        0.08094322681427002,
        0.9956167936325073,
        -0.04685142636299133,
        0.005295541137456894,
        -0.04743455722928047,
        -0.9988602995872498
      ],
      "scale": 1.1202959519264377,
      "zone": 5,
      "samples": 38
    },
    {
      "name": "ReefBand5_08_0",
      "template": "Workspace.Decorations.ShoreRock_03.Visual",
      "cf": [
        136.75607096310915,
        -143.5479658648897,
        -270.840309196636,
        1,
        0,
        2.384185791015625e-07,
        0,
        1,
        0,
        -2.384185791015625e-07,
        0,
        1
      ],
      "scale": 1.349044081057382,
      "zone": 5,
      "samples": 196
    },
    {
      "name": "ReefBand5_08_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_033_TurquoiseTable.Visual",
      "cf": [
        140.85893957919384,
        -145.59946206725638,
        -272.33581695652583,
        0.9581320285797119,
        0.0926273912191391,
        -0.2709295153617859,
        -0.056320805102586746,
        0.9887105822563171,
        0.13885119557380676,
        0.28073227405548096,
        -0.11777884513139725,
        0.9525319933891296
      ],
      "scale": 1.3699728791635595,
      "zone": 5,
      "samples": 23
    },
    {
      "name": "ReefBand5_08_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_035_PeachCups.Visual",
      "cf": [
        142.24135834083725,
        -152.49139129506872,
        -283.5238604942088,
        -0.7889673113822937,
        -0.024575548246502876,
        0.6139440536499023,
        -0.10814419388771057,
        0.9891555309295654,
        -0.09937908500432968,
        -0.60484379529953,
        -0.14480121433734894,
        -0.7830690741539001
      ],
      "scale": 1.2225648914532927,
      "zone": 5,
      "samples": 15
    },
    {
      "name": "ReefBand5_08_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_06_LavenderFingers.Visual",
      "cf": [
        149.70446016018752,
        -151.73252354209885,
        -281.4957067479965,
        -0.6252635717391968,
        -0.048185233026742935,
        0.7789248824119568,
        -0.11548119783401489,
        0.9928169250488281,
        -0.0312829464673996,
        -0.771822452545166,
        -0.10951119661331177,
        -0.6263367533683777
      ],
      "scale": 1.3525446683859899,
      "zone": 5,
      "samples": 8
    },
    {
      "name": "ReefBand5_08_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_015_PeachCups.Visual",
      "cf": [
        145.4688752613577,
        -146.3598382725163,
        -269.80146457875134,
        -0.8186210989952087,
        0.046649277210235596,
        0.5724359154701233,
        0.06199803948402405,
        0.9980495572090149,
        0.007327673025429249,
        -0.5709778070449829,
        0.041488517075777054,
        -0.8199164867401123
      ],
      "scale": 1.4816261032165112,
      "zone": 5,
      "samples": 23
    },
    {
      "name": "ReefBand5_08_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_09_LavenderFingers.Visual",
      "cf": [
        144.2690322945985,
        -144.32782704831249,
        -268.5668308383089,
        0.5869461894035339,
        0.07265394926071167,
        -0.8063592910766602,
        -0.050006695091724396,
        0.9973172545433044,
        0.0534597672522068,
        0.8080801367759705,
        0.008945358917117119,
        0.5890047550201416
      ],
      "scale": 1.5613618817478168,
      "zone": 5,
      "samples": 11
    },
    {
      "name": "ReefBand5_09_0",
      "template": "Workspace.UnderwaterTerrain.ReefLife.ReefBoulder_08.Visual",
      "cf": [
        276.1304016875522,
        -151.99475903040286,
        -141.5952629287157,
        0.9456452131271362,
        0,
        0.32520022988319397,
        0,
        1,
        0,
        -0.32520022988319397,
        0,
        0.9456452131271362
      ],
      "scale": 1.5755638955995783,
      "zone": 5,
      "samples": 196
    },
    {
      "name": "ReefBand5_09_1",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_016_LavenderFingers.Visual",
      "cf": [
        271.003711512288,
        -150.27676799669257,
        -138.41062531267343,
        0.8570197224617004,
        0.11178413778543472,
        -0.5030123591423035,
        -0.03671800345182419,
        0.9869521856307983,
        0.15677057206630707,
        0.5139737129211426,
        -0.11588583141565323,
        0.8499419689178467
      ],
      "scale": 1.317415864129114,
      "zone": 5,
      "samples": 14
    },
    {
      "name": "ReefBand5_09_2",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_039_SunbeamAntlers.Visual",
      "cf": [
        277.2272574061045,
        -152.01041312673672,
        -130.77109135539234,
        -0.7804560661315918,
        -0.08266384899616241,
        0.6197216510772705,
        -0.030359942466020584,
        0.9950622320175171,
        0.09449577331542969,
        -0.6244730949401855,
        0.05493507161736488,
        -0.7791123390197754
      ],
      "scale": 0.8208570248961222,
      "zone": 5,
      "samples": 31
    },
    {
      "name": "ReefBand5_09_3",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_001_SunsetStaghorn.Visual",
      "cf": [
        275.1819537365104,
        -150.28340673591086,
        -130.71977184840733,
        -0.17414076626300812,
        -0.07629100233316422,
        0.9817610383033752,
        0.06851060688495636,
        0.9936397671699524,
        0.08936621993780136,
        -0.9823346138000488,
        0.08282335102558136,
        -0.1678064912557602
      ],
      "scale": 1.2855181445862751,
      "zone": 5,
      "samples": 20
    },
    {
      "name": "ReefBand5_09_4",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Shallows_03_CrimsonLettuce.Visual",
      "cf": [
        275.69434786697326,
        -152.5584504736907,
        -146.60494486254234,
        0.9876329898834229,
        -0.03802957013249397,
        0.15209855139255524,
        0.04703831300139427,
        0.9973178505897522,
        -0.05607585236430168,
        -0.14955808222293854,
        0.06253687292337418,
        0.9867730140686035
      ],
      "scale": 1.5817499189262603,
      "zone": 5,
      "samples": 22
    },
    {
      "name": "ReefBand5_09_5",
      "template": "Workspace.UnderwaterTerrain.PolishedReefs.Reef_016_LavenderFingers.Visual",
      "cf": [
        268.6842397020873,
        -150.12671442358794,
        -141.61929509492842,
        0.8570197224617004,
        0.11178413778543472,
        -0.5030123591423035,
        -0.03671800345182419,
        0.9869521856307983,
        0.15677057206630707,
        0.5139737129211426,
        -0.11588583141565323,
        0.8499419689178467
      ],
      "scale": 1.0693708496867291,
      "zone": 5,
      "samples": 16
    }
  ],
  "drops": {
    "CaptainsCache": [
      {
        "position": [
          177.0,
          -77.99998474121094,
          136.0
        ],
        "normal": [
          0.0,
          1.0,
          -0.0
        ]
      },
      {
        "position": [
          176.4616241455078,
          -78.00000762939453,
          139.39918518066406
        ],
        "normal": [
          0.0,
          1.0,
          -0.0
        ]
      },
      {
        "position": [
          174.89918518066406,
          -78.0,
          142.46563720703125
        ],
        "normal": [
          0.0,
          0.9999999403953552,
          0.0
        ]
      },
      {
        "position": [
          172.46563720703125,
          -78.0,
          144.89918518066406
        ],
        "normal": [
          0.0,
          1.0,
          0.0
        ]
      },
      {
        "position": [
          155.0,
          -78.00000762939453,
          136.0
        ],
        "normal": [
          0.0,
          1.0,
          0.0
        ]
      }
    ],
    "TidekeepersCache": [
      {
        "position": [
          -169.0,
          -114.00001525878906,
          192.0
        ],
        "normal": [
          0.0,
          1.0,
          0.0
        ]
      },
      {
        "position": [
          -169.9549102783203,
          -114.0,
          194.9389190673828
        ],
        "normal": [
          0.0,
          1.0,
          0.0
        ]
      },
      {
        "position": [
          -172.4549102783203,
          -114.0,
          196.75527954101562
        ],
        "normal": [
          0.0,
          1.0,
          0.0
        ]
      },
      {
        "position": [
          -175.5450897216797,
          -114.0,
          196.75527954101562
        ],
        "normal": [
          -0.0,
          1.0,
          0.0
        ]
      },
      {
        "position": [
          -179.0,
          -114.0,
          192.0
        ],
        "normal": [
          -0.0,
          1.0,
          0.0
        ]
      }
    ],
    "AbyssalCache": [
      {
        "position": [
          52.0,
          -146.0,
          293.0
        ],
        "normal": [
          0.0,
          0.9999999403953552,
          0.0
        ]
      },
      {
        "position": [
          51.04508590698242,
          -145.99998474121094,
          295.9389343261719
        ],
        "normal": [
          0.0,
          1.0,
          -0.0
        ]
      },
      {
        "position": [
          48.54508590698242,
          -146.0,
          297.7552795410156
        ],
        "normal": [
          0.0,
          1.0,
          -0.0
        ]
      },
      {
        "position": [
          45.45491409301758,
          -146.00001525878906,
          297.7552795410156
        ],
        "normal": [
          0.0,
          1.0,
          -0.0
        ]
      },
      {
        "position": [
          42.95491409301758,
          -146.00001525878906,
          295.9389343261719
        ],
        "normal": [
          0.0,
          1.0,
          0.0
        ]
      }
    ]
  },
  "sites": 6937,
  "zoneSiteCounts": [
    750,
    916,
    1161,
    909,
    3201
  ],
  "groundVertices": 41450,
  "obstacleTriangles": 1410876
}]====])
local history=game:GetService('ChangeHistoryService');local record=history:TryBeginRecording('ExpeditionDepth','Five ocean zones and authored exploration sites')
local assets=game.ReplicatedStorage.SeaGame.Assets
local backup=Instance.new('Folder');backup.Name='Step5SceneBackup';backup.Parent=game.ServerStorage
local lib=Instance.new('Folder');lib.Name='Expedition';lib.Parent=assets.Environment
local byName={};for _,p in imported:GetDescendants() do if p:IsA('MeshPart') then byName[p.Name]=p end end
local function find(path)
 local p=game;for name in path:gmatch('[^.]+') do p=assert(p:FindFirstChild(name),path) end;return p
end
local function visual(p,name)
 p=p:Clone();p.Name=name or 'Visual';p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Color=Color3.new(1,1,1);p.CFrame=CFrame.Angles(0,math.pi,0)*p.CFrame;p.RenderFidelity=Enum.RenderFidelity.Automatic
 local sa=p:FindFirstChildOfClass('SurfaceAppearance');if sa then p.TextureID=sa.ColorMap end
 return p
end
local function prefab(source,folder,id)
 local m=Instance.new('Model');m.Name=id;local p=visual(source);p:SetAttribute('SurfaceSource','step5__'..source.Name);p.Parent=m;m.WorldPivot=CFrame.new();m.Parent=folder;return m
end
for name,p in byName do
 local kind,id=name:match('^(%a+)__(.+)$')
 if kind=='Loot' then assert(not assets.Loot:FindFirstChild(id));prefab(p,assets.Loot,id)
 elseif kind=='Icon' then prefab(p,assets.Icons,id)
 elseif kind=='Prop' then prefab(p,lib,id) end
end
local seabed=workspace.UnderwaterTerrain.Seafloor
for _,p in seabed:GetChildren() do p.Parent=backup end
for name,p in byName do if name:match('^Seabed__') then
 local model=Instance.new('Model');model.Name=name:gsub('Seabed__','Chunk_');model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local part=visual(p,'Sand');part.CanCollide=true;part.CanQuery=true;part.CanTouch=false;part.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition
 -- World-aligned tiling preserves sand grain scale over long slope sections.
 for _,sa in part:GetChildren() do if sa:IsA('SurfaceAppearance') then sa:Destroy() end end
 part.TextureID='';part.Material=Enum.Material.Sand;part.MaterialVariant='Sea_LagoonSand';part.Color=Color3.fromRGB(238,214,165)
 part:SetAttribute('SurfaceSource','step5__'..name);part:SetAttribute('Wettable',true);part:SetAttribute('ShoreBaseY',part.Position.Y-part.Size.Y*.45);game.CollectionService:AddTag(part,'SeaWettable');part.Parent=model;model.Parent=seabed
end end
-- Support plane protects the outer fringe; its top stays below the visible lowest sand.
local floor=Instance.new('Part');floor.Name='AbyssSafetyFloor';floor.Size=Vector3.new(768,4,768);floor.CFrame=CFrame.new(0,-170,0);floor.Material=Enum.Material.Sand;floor.MaterialVariant='Sea_LagoonSand';floor.Color=Color3.fromRGB(205,193,158);floor.Anchored=true;floor.CanTouch=false;floor.Parent=seabed
for _,f in layout.fits do local p=find(f.path);p.CFrame+=Vector3.new(0,f.deltaY,0);p:SetAttribute('SupportMaxGap',-.07);p:SetAttribute('SupportSamples',f.samples) end
local points=workspace.UnderwaterTerrain.PointsOfInterest
local function moveChest(chest,delta)
 chest:PivotTo(chest:GetPivot()+delta)
 for _,key in {'LidHinge','LidClosedCFrame'} do local cf=chest:GetAttribute(key);if typeof(cf)=='CFrame' then chest:SetAttribute(key,cf+delta) end end
end
for _,move in layout.moves do
 local delta=Vector3.new(table.unpack(move.delta));points[move.name]:PivotTo(points[move.name]:GetPivot()+delta);moveChest(points[move.chest],delta)
 points[move.chest]:SetAttribute('LootDepth',if move.chest=='CaptainsCache' then 80 else 112)
 points[move.chest]:SetAttribute('MinimumValue',if move.chest=='CaptainsCache' then 600 else 1250)
end
local models={}
for _,p in layout.pois do
 local m=points:FindFirstChild(p.id)
 if not m then m=Instance.new('Model');m.Name=p.id;m.WorldPivot=CFrame.new(p.x,p.y,p.z);m.Parent=points end
 m:SetAttribute('PointOfInterest',true);m:SetAttribute('DisplayName',p.name);m:SetAttribute('DepthZone',p.zone);m:SetAttribute('DiscoveryPosition',Vector3.new(p.x,p.y,p.z));m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;models[p.id]=m
end
local function blocker(parent,name,cf,size)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Transparency=1;p.Anchored=true;p.CanTouch=false;p.CastShadow=false;p.Parent=parent
end
for _,f in layout.placements do
 local m=lib[f.asset]:Clone();m.Name=f.name;m:ScaleTo(f.scale);m:PivotTo(CFrame.new(f.x,f.y,f.z)*CFrame.Angles(0,f.yaw,0));local p=m.Visual
 p:SetAttribute('Wettable',true);p:SetAttribute('ShoreBaseY',f.y);p:SetAttribute('SupportMaxGap',-.10);p:SetAttribute('SupportSamples',f.samples);game.CollectionService:AddTag(p,'SeaWettable')
 if f.collide then
  if f.asset:find('Arch') then
   local _,size=m:GetBoundingBox();local pivot=m:GetPivot()
   for _,side in {-1,1} do blocker(m,'ArchFootCollider',pivot*CFrame.new(side*size.X*.41,size.Y*.25,0),Vector3.new(size.X*.17,size.Y*.5,size.Z*.75)) end
   blocker(m,'ArchCrownCollider',pivot*CFrame.new(0,size.Y*.88,0),Vector3.new(size.X*.6,size.Y*.15,size.Z*.7))
  elseif f.asset=='SeaCave' or f.asset=='CrystalCave' or f.asset=='RockShelf' then p.CanCollide=true;p.CanQuery=true;p.CollisionFidelity=Enum.CollisionFidelity.PreciseConvexDecomposition
  else p.CanCollide=true;p.CanQuery=true;p.CollisionFidelity=Enum.CollisionFidelity.Hull end
 end
 m.Parent=models[f.poi]
end
local reefs=Instance.new('Folder');reefs.Name='ExpeditionReefs';reefs.Parent=workspace.UnderwaterTerrain
for _,f in layout.reuses do
 local p=find(f.template):Clone();p.Name='Visual';p.Size*=f.scale;p.CFrame=CFrame.new(table.unpack(f.cf));p.Anchored=true;p.CanTouch=false;p.CanQuery=false;p.CanCollide=false;p.CastShadow=p.Size.Magnitude>8
 local m=Instance.new('Model');m.Name=f.name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;p.Parent=m;m.Parent=reefs;p:SetAttribute('SupportMaxGap',-.07);p:SetAttribute('SupportSamples',f.samples);p:SetAttribute('ShoreBaseY',p.Position.Y-p.Size.Y*.45);p:SetAttribute('Wettable',true);game.CollectionService:AddTag(p,'SeaWettable')
end
-- The treasury reuses the proven animated chest assembly and server reward flow.
local chest=points.TidekeepersCache:Clone();chest.Name='AbyssalCache';chest.Parent=points
local target=Vector3.new(47,-145.6,293);moveChest(chest,target-chest:GetPivot().Position);chest:SetAttribute('DisplayName','Royal Abyssal Treasury');chest:SetAttribute('MinimumValue',4200);chest:SetAttribute('LootDepth',150);chest:SetAttribute('DropCount',4);chest:SetAttribute('Opened',false);chest:SetAttribute('OpenedAt',nil)
for name,sites in layout.drops do
 local c=points[name];c.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local folder=c:FindFirstChild('DropSites')or Instance.new('Folder');folder.Name='DropSites';folder.Parent=c;folder:ClearAllChildren()
 for i,s in sites do local p=Instance.new('Part');p.Name='Drop_'..i;p.Size=Vector3.one*.12;p.Position=Vector3.new(table.unpack(s.position));p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p:SetAttribute('SurfaceNormal',Vector3.new(table.unpack(s.normal)));p.Parent=folder end
end
for _,root in {workspace.Decorations,workspace.UnderwaterTerrain} do for _,p in root:GetDescendants() do if p:IsA('MeshPart')and p:GetAttribute('Wettable')then
 p:SetAttribute('ShoreBaseY',p.Position.Y-p.Size.Y*.45);game.CollectionService:AddTag(p,'SeaWettable')
end end end
workspace.Ocean:SetAttribute('MinimumWaterLevel',-168);workspace.Ocean:SetAttribute('DrainableBottom',-168);workspace.Ocean:SetAttribute('WaterBoundsMin',Vector3.new(-384,-172,-384));workspace.Ocean:SetAttribute('TotalOceanVolume',99090432);workspace.Ocean:SetAttribute('RemainingWaterVolume',99090432);workspace.Ocean:SetAttribute('OceanRemainingPercent',100)
workspace:SetAttribute('ExpeditionSeed',layout.seed);workspace:SetAttribute('ExpeditionInstalled',true);workspace:SetAttribute('OceanDepthZoneHeight',32)
workspace.FallenPartsDestroyHeight=-350
-- Runtime-independent static geometry: streaming affects clients only.
for _,container in {workspace.Buildings,workspace.NPCs} do for _,m in container:GetChildren() do if m:IsA('Model')then m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic end end end
local rig=workspace.Ocean:FindFirstChild('WetShoreRig');if rig then rig.ModelStreamingMode=Enum.ModelStreamingMode.Persistent end
for _,m in workspace.Ocean:GetChildren()do if m:IsA('Model')and m.Name:find('Boat')then m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent end end
for _,m in {workspace.StarterIsland}do if m:IsA('Model')then m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent end end
imported:Destroy();game.Selection:Set({})
if record then history:FinishRecording(record,Enum.FinishRecordingOperation.Commit)end
return {chunks=60,landmarks=#layout.pois,newProps=#layout.placements,reusedProps=#layout.reuses,refitted=#layout.fits,resources=#assets.Loot:GetChildren()}
