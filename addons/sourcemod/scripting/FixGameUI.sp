#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools_entoutput>
#include <sdktools_entinput>
#include <sdktools_engine>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>

Handle g_hAcceptInput = INVALID_HANDLE;
int g_iAttachedGameUI[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "FixGameUI",
	author = "hlstriker + GoD-Tony",
	description = "Fixes game_ui entity bug.",
	version = "2.1",
	url = ""
}

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);

	HookEntityOutput("game_ui", "PlayerOn", GameUI_PlayerOn);
	HookEntityOutput("game_ui", "PlayerOff", GameUI_PlayerOff);

	// Gamedata.
	Handle hConfig = LoadGameConfigFile("sdktools.games");
	if (hConfig == INVALID_HANDLE)
	{
		SetFailState("Couldn't load sdktools game config!");
		return;
	}

	int offset = GameConfGetOffset(hConfig, "AcceptInput");
	if (offset == -1)
	{
		SetFailState("Failed to find AcceptInput offset");
	}
	CloseHandle(hConfig);

	// DHooks.
	g_hAcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, Hook_AcceptInput);
	DHookAddParam(g_hAcceptInput, HookParamType_CharPtr);
	DHookAddParam(g_hAcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_hAcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_hAcceptInput, HookParamType_Object, 20); //varaint_t is a union of 12 (float[3]) plus two int type params 12 + 8 = 20
	DHookAddParam(g_hAcceptInput, HookParamType_Int);

}

public Action Event_PlayerDeath(Handle hEvent, const char[] szName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	RemoveFromGameUI(iClient);
	SetClientViewEntity(iClient, iClient);

	int iFlags = GetEntityFlags(iClient);
	iFlags &= ~FL_ONTRAIN;
	iFlags &= ~FL_FROZEN;
	iFlags &= ~FL_ATCONTROLS;
	SetEntityFlags(iClient, iFlags);

	return Plugin_Continue;
}

public void OnClientDisconnect(int iClient)
{
	RemoveFromGameUI(iClient);
}

public void GameUI_PlayerOn(const char[] szOutput, int iCaller, int iActivator, float fDelay)
{
	if(!(1 <= iActivator <= MaxClients))
		return;

	if(iCaller >= GetMaxEntities() || iCaller < 0)
    	return;

	g_iAttachedGameUI[iActivator] = EntIndexToEntRef(iCaller);
}

public void GameUI_PlayerOff(const char[] szOutput, int iCaller, int iActivator, float fDelay)
{
	if(!(1 <= iActivator <= MaxClients))
		return;

	g_iAttachedGameUI[iActivator] = 0;
}

stock void RemoveFromGameUI(int iClient)
{
	if(!g_iAttachedGameUI[iClient])
		return;

	int iEnt = EntRefToEntIndex(g_iAttachedGameUI[iClient]);
	if(iEnt == INVALID_ENT_REFERENCE)
		return;

	AcceptEntityInput(iEnt, "Deactivate", iClient, iEnt);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "game_ui"))
	{
		DHookEntity(g_hAcceptInput, false, entity);
	}
}

public MRESReturn Hook_AcceptInput(int thisptr, Handle hReturn, Handle hParams)
{
	char sCommand[128];
	DHookGetParamString(hParams, 1, sCommand, sizeof(sCommand));

	if (StrEqual(sCommand, "Deactivate"))
	{
		int pPlayer = GetEntPropEnt(thisptr, Prop_Data, "m_player");

		if (pPlayer == -1)
		{
			// Manually disable think.
			SetEntProp(thisptr, Prop_Data, "m_nNextThinkTick", -1);

			DHookSetReturn(hReturn, false);
			return MRES_Supercede;
		}
	}

	DHookSetReturn(hReturn, true);
	return MRES_Ignored;
}
