# Suck The Sea! — Beach comfort update

Implemented in the existing native Studio place, `build/SuckTheSea.rbxlx`. Backup: `build/backups/SuckTheSea-before-comfort.rbxlx` and `build/backups/comfort-src/`.

## Gameplay

- Closed wooden WC cabin near the west side of the village, at `(-43, 5.93025, 24)`. Walk into the entry or use its E/touch/gamepad prompt. A five-second visit closes the door, plays a water-trickle sound, eases the camera out and back, and empties the yellow meter.
- Full meter = `TotalOceanVolume * 0.05` = **2,005,401.6 personally removed water units**. This follows the user's explicit clarification; there is no five-minute timer. Only the amount accepted by `OceanProgress:consume` is attributed, proportionally to each active player's contribution after the shared flow cap. Remote-server progress does not fill local players' meters.
- `NeedsWater` is a fractional saved profile field. Full need stops suction. Server checks distance and occupancy; interrupted use retains the need. Death, respawn, leaving, and interrupted camera transitions release controls and occupancy. Completed visits return the held tool and original camera mode/FOV.
- Sixteen small mussels are available on the island from the start of Play. They use the normal atomic pickup/backpack/sale flow, sell for **1 Coin**, and respawn after 45 seconds. Their world count is bounded by the existing loot budget. They are excluded from ocean/chest weighted rolls.
- Removed 11 beach grass models; relocated 8 garden plants to visible Blender Meadow geometry. All 24 remaining plant roots and sampled extents lie on Meadow; three driftwood decorations remain on sand.

## Straw catalogue

All ten ordinary straws are available at Finn for Coins. Existing ownership IDs remain compatible. Base flow is `power × speed × 200` units/s, before player upgrades and the shared server cap. The cap was raised to 800,000 so the new top tier's upgrades retain their effect.

| Straw | Coins | Power | Speed | Reach |
|---|---:|---:|---:|---:|
| Basic Straw | Starter | 1.25× | 1× | 26 |
| Colorful Straw | 150 | 2× | 1.05× | 27 |
| Bamboo Straw | 600 | 4× | 1.1× | 29 |
| Golden Straw | 2,000 | 8× | 1.15× | 30 |
| Crystal Straw | 7,500 | 16× | 1.2× | 32 |
| Ocean Vacuum | 25,000 | 35× | 1.25× | 34 |
| Coral Twister | 65,000 | 55× | 1.3× | 36 |
| Tidal Coil | 160,000 | 85× | 1.4× | 38 |
| Star Siphon | 420,000 | 130× | 1.45× | 40 |
| Leviathan | 1,000,000 | 200× | 1.5× | 42 |

Prism Straw has an original rainbow-and-brass Blender model, a smoothly cycling coloured offer button, hover/focus animation, rotating 3D preview, specifications and a **BUY · 79 ROBUX** button. This is the requested preview: pressing Buy explains that purchases are not enabled. No charge, fake entitlement or free grant occurs. Its displayed 35× power, 1.25× speed, 34-stud reach and 8,750 units/s exactly match tier 6. A real Roblox product/pass and server entitlement flow must be integrated before monetization.

## Assets and checks

- Original Blender source and FBX: `assets/comfort/SuckTheSea_Comfort.*`. Sixteen imported meshes, 41,672 triangles in the entire asset library; largest mesh 8,428 triangles. One shared 1024px colour/roughness/metalness atlas. Runtime only renders the equipped tool, visible pickups and booth; unused tools remain prefabs.
- Blender QA: zero errors. Material renders and front/back/three-quarter wire views inspected. Intentional atlas UV reuse is not a unique bake layout. Joined architectural boards retain hidden contact faces; no visible coplanar fighting remains.
- 33 comfort/economy tests, 88 existing economy/profile tests and 30 ocean-ledger tests passed. The ledger suite still covers concurrent mock servers, replay prevention, failed writes and fractional serialization. Mock persistence is not a live cloud rejoin test.
- 28 live-session tests cover all nine paid ordinary purchases and physical tools, distance checks, premium rejection, full-meter suction rejection, interrupted/completed restroom visits and movement/tool restoration.
- Actual input verified: **1** puts the straw away and takes it out; E opens Finn's shop and operates the booth. Actual mussel pickup succeeded, duplicate pickup failed, and sale added exactly 1 Coin.
- During an actual RMB suction test, 950.6513914093375 water units were accepted and exactly the same amount filled personal need. A separate death-during-use test retained need, released the door and occupancy, then restored Custom camera/FOV 70 after respawn.
- The restroom audio asset loaded (4.576 seconds) and played during use. Source: [Pro Sound Effects water trickle](https://create.roblox.com/store/asset/9126175899).
- UI bounds, text clipping and footer intersections were checked on desktop, iPad, and iPhone portrait/landscape. Device tests used Roblox's [StudioDeviceSimulatorService](https://create.roblox.com/docs/reference/engine/classes/StudioDeviceSimulatorService); no physical-device performance claim is made.
- Final fresh Play had 16 mussels, three preserved shop NPCs, a working spawn, and no game-script errors. Test scripts, seeded balances/needs, runtime doors, pickups and device overrides are not saved into Edit.

Screenshots are under `build/screenshots/comfort-*`. `build/SuckTheSea-restroom.mp4` is an 11-second Studio animation recording **without audio capture**. Its meter was seeded to 88% only in the disposable Play session to demonstrate the animation.

The experience remains unpublished. Real cross-session DataStore behavior in Roblox cloud remains unverified; local Play intentionally uses session memory. No experience publication or real Robux purchase was performed.
