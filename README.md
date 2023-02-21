# ddat-gpf.runtime
The runtime scaffold; prebuilt scenes for (DDAT) Godot Prototyping Framework.

(includes ddat-gpf.core v0.1.7)
 
This is to be a collection of state scripts and scenes that cover the basic framework for any game. It is intended to be used as a quick frontend for any game prototype, and it is not suggested to use this in a full release unless you are comfortable configuring and tweaking the included animations and scenes. 

The runtime scaffold includes:
 * **game state handler**: separates the load state of the game into distinct chunks.
 * **preload splash screen**
 * **title screen**: includes functional buttons for multiple menus, transition animations, and placeholder title textures
 * **game meta handler**: includes functionality for creating save files and loading save files
 * **exit handler**: can exit game process safely

Future included integrations will include ddat-gpf.config and ddat-gpf.input, but as of date (21/02/2023) those are not ready for a release.
 
---

This is an early release and requires some developer adjustments to be workable. You'll need to implement save file selection and a transition from the GameMeta load-file menu to your actual project, and update the GameProgressFile class to include variables you wish for the user to save to disk.

Currently the placeholder graphics are for 'Monday Night Missilemania', an ongoing personal project of mine. These are included under the same license as the scaffold to save me having to prune all the placeholder textures and animations for the initial upload. You're welcome to repurpose or edit them, but I'd appreciate if you didn't use them as is/with the same title (they will be removed in a future push).
