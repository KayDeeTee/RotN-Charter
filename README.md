# RotN-Charter
Charter for Rift of the Necrodancer
## Requirements
Runs in Godot 4.X specifically 4.3 but any should work

Needs an addon from here `https://github.com/ynot01/godot_rust_yaml` unpack it into addons so your folder path looks like `addons/godot_rust_yaml/godot_rust_yaml.gdextension`

## Keybinds
You currently can't rebind stuff, sorry.

Up/Down => Moves the cursor up/down by the snap amount

Left/Right => Adjusts the snap

ZXC => Places an event at the current cursor position, Z is track 1, X is track 2, C is track 3

D => Deletes all events at the current cursor position except Vibe/Bpm changes

F => Swaps facing between left/right

## Converting from other games
I wrote a quaver converter, and quaver itself converts from every mainstream vsrg, the only caveat is it needs a timing event at the start to set the bpm. Quaver itself doesn't need bpm as its based on real time so bpm is just for quantisation and SVs, so some charts won't have a bpm set, RotN does need bpm so you need to set it if it doesn't exist.

## Game Quirks
Events happen as they spawn, not as they "cross" the reticles. This only really causes weirdness with AdjustBPM events that need to be 8 beats later than the hit you want to sync them with.

Hitwindows are directly related to the duration of the current beat as you hit an enemy, this means songs at 600 bpm have 5x smaller hit windows than songs at 120bpm. This also applies to coals, making an enemy 3x faster with coals also makes their hitwindows 3x smaller.

Blademasters bug out if they have to dash through enemies.

Wyrms only add base score for the first hit, this massively inflates your "percentage accuracy" in charts with a lot of wyrm ticks, i.e. a chart with something like 30 triple skeletons and 3 wyrms that last 300 beats, even if you L-OK every hit and combo break to prevent getting a 2x multiplier, but fully hold those 3 wyrms you will get an S+ regardless.

Vibe chains that start while another vibe chain is still running will break (will visually work but the final hit won't give vibe), this bug also happens if you spawn a vibe chain on the exact same subdivision as an enemy spawns.

Some stuff isn't in the demo like freeze and wind, the game hangs if you try to load something that doesn't exist.

## Loading tracks
You'll need to use the mod I wrote https://github.com/KayDeeTee/RotN-Customs to get custom tracks loading.

You need to add a folder to `CustomTracks` in your persistent storage for RotN `Appdata/LocalLow/Brace Yourself Games/Rift of the NecroDancer Demo/CustomTracks/<Your song name>`

You need to add an mp3 file for the music, and a png for album art to the folder as well as your chart json files.

Finally you need to make a copy of info.json from the example folder, and edit the values in that to be correct for your song.
