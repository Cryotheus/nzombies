nZombies with fixes
========
### Archived because this gamemode is too old for me to handle

A GM13 Nazi Zombies style (WIP) gamemode

This fork will be my attempt at cleaning up the code, and adding some extra nice features.

Download folder and place it in garrysmod/garrysmod/addons
Make sure the structure has a path to addon.json like this: garrysmod/garrysmod/addons/nzombies/addon.json

Get the content pack with all models and materials here:
http://steamcommunity.com/sharedfiles/filedetails/?id=675138912

If you found bugs, have suggestions, or found general improvements please make an issue on this repository. If you want to help, feel free to create pull requests with your changes.

This is an edited version from Zet0rz's fork featuring these changes:
 * Extra features for more modding potential
   * PaP-ed weapon names prioritize nz.Display_PaPNames to allow overriding existing PaP-ed weapon names
   * Perk machines can have a function provided to determine the sound file used for their jingle
   * Down times can be changed per-player allowing modification of down times
   * Extended down times will show a green revive marker fading to yellow during the duration of the extended down time
 * Various fixes
   * Hell hounds can run
   * Generally more optimized code
   * PURE LUA! (in files that have been cleaned up)
   * Fifth and tenth tally marks line up properly
 * Various outsourced fixes
   * Double Tap II applies to every weapon
   * Players no longer get stuck with the morphine SWEP
   * Panzersoldat kills give points
   * Zombies staying at barricades because of improperly removed planks
   * nz_qr can only be run by super admins
   * Dogs no longer leave behind reference posed corpses when killed by instakill power up
   * Ammo is given when obtaining a special weapon from the box
