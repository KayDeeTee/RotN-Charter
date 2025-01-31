# RotN-Charter
Charter for Rift of the Necrodancer

## Requirements to edit
Runs in Godot 4.X specifically 4.3 but any should work

Needs an addon from here https://github.com/ynot01/godot_rust_yaml unpack it into addons so your folder path looks like `addons/godot_rust_yaml/godot_rust_yaml.gdextension`

Code desperately needs refactoring, it was designed as a mvp as simple as possible editor, so stuff like enemy enums are duplicated where they are needed

## Screenshot(s)

![image](https://github.com/user-attachments/assets/e27fab1c-9c8d-48a0-9b94-b67fb19baee3)

![image](https://github.com/user-attachments/assets/f8af7cd9-8674-4750-8b19-c8f3ceb92bf9)

![image](https://github.com/user-attachments/assets/9e1eb931-0a86-4203-84d3-d3abc59f2579)

![image](https://github.com/user-attachments/assets/e225a089-1077-4eac-a700-792153138f47)

## Keybinds
Click the key icon top right to open the rebinding menu.

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

## Script Tool
Theres currently, and probably never will be documentation, you will have to look at the given example and at the source code of the charter.

It has full access as if it was written in godot so you can modify pretty much anything.
