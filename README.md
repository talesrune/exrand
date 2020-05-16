# EXtreme Weapons Randomizer
![visitors](https://visitor-badge.glitch.me/badge?page_id=talesrune.exrand)\
To obtain one of these EXtreme weapons, simply type **!exrand** or **/exrand**. However, there could only be one using it at a time so it's a first-come, first-served basis. If you are from the Blu Team in MvM, you will not receive these EXtreme weapons. All of these weapons can be used by any class.
 
# Commands
- **sm_exrand** - Give the user a random EX weapon.

# Admin commands
- **sm_exrand_reload** - Reload config for EXRand.
- **sm_er** - Give that person a EX weapon. (E.g. No 1) **sm_er 1 @blue** ~ Gives blue team EXtreme Machinas. (E.g. No 2) **sm_er 1 jack** ~ Give jack a EXtreme Machina. (E.g. No 3) **sm_er any jack** ~ Give jack a random EX weapon.

# ConVars
- **exrand_version** Shows EXRand version.
- **exrand_enabled** *(1/0, def. 1)* Enables the plugin.
- **sm_exrand_cooltime** *(def. 40.0)* Cooldown for EXRandomizer. 0 to disable cooldown.

# Installation
**Your server needs both [TF2Items](https://builds.limetech.org/?p=tf2items) and [TF2 Give Weapon](https://forums.alliedmods.net/showthread.php?p=1337899) loaded!**
* Install exrand.smx into your sourcemod/plugins/ directory.
* Install exrand_weapons.cfg into your sourcemod/configs/ directory.
* Install or edit (if you already have it) tf2items.givecustom.txt in your sourcemod/configs/ directory.
* To edit tf2items.givecustom.txt, copy and add the following weapons from **github's** tf2items.givecustom.txt: 7000,7001,7002,7003,7004,7005,7006,7007,7008.
* Done!

# Directory
* configs folder - 1. exrand_weapons.cfg, 2. tf2items.givecustom.txt
* plugins folder - 1. exrand.smx
* scripting folder - 1. exrand.sp

# Credits
* FlaminSarge - Based from his plugin: Be the Horsemann