# ddat-gpf.runtime
The runtime scaffold; prebuilt scenes for (DDAT) Godot Prototyping Framework.

includes:
 ddat-gpf.core v0.1.4
 ddat-gpf.input-0.0.1
 ddat-gpf.config-0.0.1
 
This is to be a collection of state scripts and scenes that cover the basic framework for any game; title menu, save/load, etc (in future this will be expanded to include input and configuration settings as well). It is intended to be used as a quick frontend for any game prototype, and it is not suggested to use this in a full release unless you are comfortable configuring and tweaking the included animations and scenes. 

The runtime scaffold includes:
 * **game state handler**: separates the load state of the game into distinct chunks.
 * **preload splash screen**
 * **title screen**: includes functional buttons for multiple menus, transition animations, and placeholder title textures
 * **game meta handler**: includes functionality for creating save files and loading save files
 * **exit handler**: can exit game process safely
 
---------

This is an early release and requires some developer adjustments to be workable.

**To Use:**
1) Download the entire repository and copy the contents of all the folders into your own project folder, retaining the runtime scaffold directory structure. (flexible paths are not supported at the moment).
2) Set up the following singletons in your project settings (AutoLoad tab), using the suggested node names. The exact structure and expected order is included below (under 'expected autoload setup')
3) Add your main project scene, or a preloader for your main project scene, to the export 'game_file' property of the GameMetaHandler (a child node of runtimeMain). (currently this parameter is set to res://_dev_exclude/runtime_test_scene.tscn). On choosing a save file this is the scene that the GameMetaHandler will load.

Save files are not feature-complete currently but you can add your own properties to the gameProgressFile class and access a loaded save file through the .loaded_save_file property of the GlobalProgression autoload to quickly store and load data between sessions. Be aware that installing any future updates to the runtimeScaffold will overwrite the gameProgressFile if you have made any changes to it, so you may wish to extend the class and replace references to the gameProgressFile at the point of writing the save (in the '_create_new_save_resource' method in 'game_meta_load_dialog.gd')).

**Expected Autoload Setup:**
(NodeName -> path)
* GlobalData -> res://src/autoload/global_data.gd
* GlobalDebug -> res://src/autoload/global_debug.gd
* GlobalDevTools -> res://src/autoload/global_devtools.tscn
* GlobalInput -> res://src/autoload/global_input.gd
* GlobalConfig -> res://src/autoload/global_config.gd
* GlobalProgression -> res://src/autoload/global_progression.gd

---------

**Disclaimer:**

Currently the placeholder graphics are for 'Monday Night Missilemania', an ongoing personal project of mine. These are included under the same license as the scaffold to save me having to prune all the placeholder textures and animations for the initial upload. You're welcome to repurpose or edit them, but I'd appreciate if you didn't use them as is/with the same title (they will be removed in a future push).
