/**
 * vim: set ts=4 :
 * =============================================================================
 * super_friendlyfire
 * Colorblinds everyone when mp_friendlyfire is enabled
 *
 * Copyright 2015 CrimsonTautology
 * =============================================================================
 *
 */

#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "1.10.1"
#define PLUGIN_NAME "Super Friendlyfire"

public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "CrimsonTautology",
    description = "Colorblinds everyone when mp_friendlyfire is enabled",
    version = PLUGIN_VERSION,
    url = "https://github.com/CrimsonTautology/sm-super-friendlyfire"
};


new Handle:g_Cvar_Enabled = INVALID_HANDLE;
new Handle:g_Cvar_Friendlyfire = INVALID_HANDLE;

public OnPluginStart()
{
    g_Cvar_Friendlyfire = FindConVar("mp_friendlyfire");

    CreateConVar("sm_super_friendlyfire_version", PLUGIN_VERSION, PLUGIN_NAME,
            FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    g_Cvar_Enabled = CreateConVar("sm_super_friendlyfire", "1", "Enabled");

    HookEvent("player_spawn", Event_PlayerSpawn);
    HookConVarChange(g_Cvar_Enabled, OnEnabledChange);
    HookConVarChange(g_Cvar_Friendlyfire, OnFriendlyfireChange);
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(!IsFriendlyfireEnabled()) return;
    if(!IsSuperFriendlyfireEnabled()) return;

    new client = GetClientOfUserId(GetEventInt(event, "userid"));

    ColorBlindClient(client);
}

public OnEnabledChange(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    if(cvar != g_Cvar_Enabled) return;

    new bool:was_on = !!StringToInt(oldValue);
    new bool:now_on = !!StringToInt(newValue);

    //When changing from on to off
    if(was_on && !now_on)
    {
        UnColorBlindAllClients();
    }

    //When changing from off to on
    if(!was_on && now_on && IsFriendlyfireEnabled())
    {
        ColorBlindAllClients();
    }
}

public OnFriendlyfireChange(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    if(cvar != g_Cvar_Friendlyfire) return;

    new bool:was_on = !!StringToInt(oldValue);
    new bool:now_on = !!StringToInt(newValue);

    //When changing from on to off
    if(was_on && !now_on)
    {
        UnColorBlindAllClients();
    }

    //When changing from off to on
    if(!was_on && now_on && IsSuperFriendlyfireEnabled())
    {
        ColorBlindAllClients();
    }
}

bool:IsSuperFriendlyfireEnabled()
{
    return GetConVarBool(g_Cvar_Enabled);
}

bool:IsFriendlyfireEnabled()
{
    return GetConVarBool(g_Cvar_Friendlyfire);
}

public ColorBlindClient(client)
{
    SetClientOverlay(client, "debug/yuv");
}

public ColorBlindAllClients()
{
    for (new client=1; client <= MaxClients; client++)
    {
        ColorBlindClient(client);
    }
}

public UnColorBlindClient(client)
{
    SetClientOverlay(client, "");
}

public UnColorBlindAllClients()
{
    for (new client=1; client <= MaxClients; client++)
    {
        UnColorBlindClient(client);
    }
}

SetClientOverlay(client, String:strOverlay[])
{
    if(client <= 0) return;
    if(!IsClientInGame(client)) return;

    //Allow cheat command
    new original = GetCommandFlags("r_screenoverlay");
    new flags =  original & (~FCVAR_CHEAT);
    SetCommandFlags("r_screenoverlay", flags);

    ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);

    //Revert to original
    SetCommandFlags("r_screenoverlay", original);
}
