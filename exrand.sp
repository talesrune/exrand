//Edited by HowToDoThis v1.2 (2020)
#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <tf2items>
#include <morecolors>
#define PLUGIN_VERSION "1.2"
#include <tf2items_giveweapon>

new Handle:cvarEnabled;
new bool:g_bCoolEnd[MAXPLAYERS + 1] = { true, ... };
new bool:g_bIsUsing[MAXPLAYERS + 1] = { false, ... };
new Handle:ConVar_CoolTime = INVALID_HANDLE;
new Float:TimerRate;

new ExUse;
new bool:IsReady = true;
//new String:useridd[MAXPLAYERS + 1] ;
new Handle:gArray = INVALID_HANDLE;
new gIndexCmd;

public Plugin:myinfo =
{
	name = "[TF2] EXtreme Weapons Randomizer",
	author = "HowToDoThis",
	description = "Obtain a random EXtreme weapon!",
	version = PLUGIN_VERSION,
	url = ""
}

public OnPluginStart()
{
	//Convars and Commands
	CreateConVar("exrand_version", PLUGIN_VERSION , "EXRand Version",  FCVAR_NOTIFY|0|FCVAR_SPONLY);
	cvarEnabled = CreateConVar("exrand_enabled", "1", "What the point of setting it 0 in the first place?", 0, true, 0.0, true, 1.0);
	ConVar_CoolTime = CreateConVar("sm_exrand_cooltime", "40.0", "Cooldown for EXRandomizer. 0 to disable cooldown.", FCVAR_DONTRECORD|0|FCVAR_NOTIFY, true, 0.0);
        HookConVarChange(ConVar_CoolTime, ConVar_Time_Changed);
//	HookEvent("player_spawn", event_PlayerSpawn);
	HookEvent("player_death", Event_Death);
	RegAdminCmd("sm_exrand", Command_EXRand, ADMFLAG_GENERIC, "Give that person a random EX weapon.");
	RegAdminCmd("sm_exrand_reload", Command_EXRandR, ADMFLAG_GENERIC, "Reload config for EXRand");
	RegAdminCmd("sm_er", Command_ER, ADMFLAG_GENERIC, "Give that person a RE.");
	gArray = CreateArray();
}
public OnConfigsExecuted() {
	TimerRate = GetConVarFloat(ConVar_CoolTime);
	SetupEXConfigs("exrand_weapons.cfg");
	
}
public Action:Command_EXRandR(client, args)
{
	SetupEXConfigs("exrand_weapons.cfg");
}

public SetupEXConfigs(const String:sFile[]) {
	
	new String:sPath[PLATFORM_MAX_PATH]; 
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/%s", sFile);
	
	if(!FileExists(sPath)) {
		PrintToServer("[EXRandomizer] Error: Can not find filepath %s", sPath);
		SetFailState("[EXRandomizer] Error: Can not find filepath %s", sPath);
	}
	new Handle:kv = CreateKeyValues("EXRandomizer");
	FileToKeyValues(kv, sPath);

	if(!KvGotoFirstSubKey(kv)) PrintToServer("Could not read file: %s", sPath);
	
	decl String:sName[64], String:sWep[16];
	decl String:sFName[64];
	do {
		KvGetSectionName(kv, sName, sizeof(sName));
		KvGetString(kv, "Weapon", sWep, sizeof(sWep));		
		KvGetString(kv, "FullName", sFName, sizeof(sFName));
		
		new Handle:iTrie = CreateTrie();
		SetTrieString(iTrie, "Name", sName, false);
		SetTrieString(iTrie, "Weapon", sWep, false);
		SetTrieString(iTrie, "FullName", sFName, false);
		PushArrayCell(gArray, iTrie);
	} while (KvGotoNextKey(kv));
	CloseHandle(kv);
        
	PrintToServer("Loaded EXRand configs successfully."); 
}

public OnMapStart()
{
		IsReady = true;
}

public ConVar_Time_Changed(Handle:convar, const String:oldValue[], const String:newValue[]) {
	TimerRate = StringToFloat(newValue);	
}
public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new deathflags = GetEventInt(event, "death_flags");
	if(deathflags & TF_DEATHFLAG_DEADRINGER) return Plugin_Continue;

 	if(g_bIsUsing[client])
	{
		g_bIsUsing[client] = false;
		IsReady = true;
		CreateTimer(TimerRate, Timer_Cooldown, client);
		CPrintToChatAll("{haunted}[EXRandomizer] \x01is READY! Type !exrand quick before other gets it!!!");
	}
	else
	return Plugin_Continue;

	return Plugin_Handled;

}

public Action:Command_EXRand(client, args)
{
	
	new Enabled = GetConVarInt(cvarEnabled);
	if(Enabled == 1)
	{
		if (!IsPlayerAlive(client) || GetClientTeam(client) == 3 && IsMvM())
		{
			CPrintToChat(client, "{haunted}[EXRandomizer] \x01Don't waste your !exrand when you are dead or in MvM Blu's team.");
			
			
		}
		else if(g_bCoolEnd[client] && IsReady) //Cooldown ended + Ready
		{
			RandEX(client);
			IsReady = false;
			g_bIsUsing[client] = true;
			g_bCoolEnd[client] = false;
			ExUse = client;	
			CreateTimer(30.0, Timer_Using, client);
			
		}
		else if (!IsReady)
		{
			
			CPrintToChatAll("{haunted}[EXRandomizer] \x04%N \x01is using an {powderblue}EXtreme \x01weapon. Only one person at a time.", ExUse);	
					
				
		}
		else 
		CPrintToChat(client, "{haunted}[EXRandomizer] \x01Cooldown is still ongoing.");
	}
	else
	PrintToChatAll("EXtreme Randomizer is disabled.");	
	
       
}
public Action:Timer_Using(Handle:timer, any:client)
{
	decl String:auth[32];
	GetClientAuthString( client, auth, sizeof(auth) ); 	
	ReplaceString(auth, sizeof(auth), ":", "_");
	if(g_bIsUsing[client])
	{
		ServerCommand("sm_slay #%s ",auth); //slay
		CPrintToChat(client, "{haunted}[EXRandomizer] \x01Your time is up!");
	}
      	
      
}
public Action:Timer_Cooldown(Handle:timer, any:client)
{
      CoolEnd(client);
}
public Action:CoolEnd(client)
{
	if(!g_bCoolEnd[client])
	{
		g_bCoolEnd[client] = true;
		CPrintToChat(client, "{haunted}[EXRandomizer] \x01Cooldown has ended.");
	}
}
public Action:RandEX(client)
{
	/*decl String:auth[32];
	GetClientAuthString( client, auth, sizeof(auth) );	
	
	ReplaceString(auth, sizeof(auth), ":", "_");*/
  	//behd #STEAM_0_1_72290362
	new num = GetRandomInt(1 , GetArraySize(gArray));
	CreateEX(num, client);
	//CPrintToChatAll("{haunted}[EXRandomizer] {powderblue}If you can't change into the boss, please rename yourself temporarily by typing {haunted}!rename [part of your name] [new name] {powderblue}before you try again.");	
	return Plugin_Continue;
}

public Action:Command_ER(client, args) {
	
	decl String:arg[15];
	decl String:arg2[32];
	if (args < 2) //sm_er 1 @all
	{
		arg2 = "@me";
	}
	else GetCmdArg(2, arg2, sizeof(arg2));
	if (!StrEqual(arg2, "@me") && !CheckCommandAccess(client, "sm_er_others", ADMFLAG_ROOT, true))
	{
		PrintToChat(client, "{haunted}[EXRandomizer] \x01You do not have access to this command.");
		return Plugin_Handled;
	}


	GetCmdArg(1, arg, sizeof(arg));
	new i;
	new Handle:iTrie = INVALID_HANDLE;
	decl String:sName[64];
	for(i = 0; i < GetArraySize(gArray); i++) { //Array size
		iTrie = GetArrayCell(gArray, i);
		if(iTrie != INVALID_HANDLE) {
			GetTrieString(iTrie, "Name", sName, sizeof(sName));
			if(StrEqual(sName, arg, false)){
				break;
			}
		}
	}
	if(i == GetArraySize(gArray) && !StrEqual(arg, "any")) { //Reached the end
		ReplyToCommand(client, "[EX] Error: Ex weapon does not exist.");
		return Plugin_Handled;
	}
	gIndexCmd = i;

	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
        if ((target_count = ProcessTargetString(
			arg2,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0), /* Only allow alive players. If targetting self, allow self. */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new j= 0; j < target_count; j++)
	{
		
		if(!StrEqual(arg, "any")) { //specific boss
			CreateEX(gIndexCmd, target_list[j]);
		} 
		else { //any boss 
			new num = GetRandomInt(1 , GetArraySize(gArray)-1); //minus 1 is important!
			CreateEX(num, target_list[j]);
		}
		
	}	
	return Plugin_Handled;
}

public Action:CreateEX(b_index, client) {
	

	decl String:sName[64], String:sWep[16];
	decl String:sFName[64];
	
	new Handle:iTrie = GetArrayCell(gArray, b_index);
	GetTrieString(iTrie, "Name", sName, sizeof(sName));
	GetTrieString(iTrie, "Weapon", sWep, sizeof(sWep));
	GetTrieString(iTrie, "FullName", sFName, sizeof(sFName));

//Weapon/////////////////////////////////////////////////////////////////
	if(!StrEqual(sWep, NULL_STRING)) {
		if (IsValidClient(client))
		{
			TF2Items_GiveWeapon(client, StringToInt(sWep));
		}
		/*GetWeapons(client, sWep);
		TF2_SwitchtoSlot(client, TFWeaponSlot_Primary);*/
	}
/////////////////////////////////////////////////////////////////////////
//Full Name//////////////////////////////////////////////////////////////	
	CPrintToChatAll("{haunted}[EXRandomizer] \x04%N \x01has rolled an : {powderblue}%s",client,sFName);
/////////////////////////////////////////////////////////////////////////
}

stock bool:IsMvM(bool:forceRecalc = false)
{
    static bool:found = false;
    static bool:ismvm = false;
    if (forceRecalc)
    {
        found = false;
        ismvm = false;
    }
    if (!found)
    {
        new i = FindEntityByClassname(-1, "tf_logic_mann_vs_machine");
        if (i > MaxClients && IsValidEntity(i)) ismvm = true;
        found = true;
    }
    return ismvm;
}
stock bool:IsValidClient(client)
{
	if (client <= 0) return false;
	if (client > MaxClients) return false;
//	if (!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}
