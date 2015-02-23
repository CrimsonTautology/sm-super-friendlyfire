/**
 * vim: set ts=4 :
 * =============================================================================
 * super_friendly_fire
 * Colorblinds everyone when mp_friendlyfire is enabled
 *
 * Copyright 2015 CrimsonTautology
 * =============================================================================
 *
 */

#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "0.1"
#define PLUGIN_NAME "Super Friendly Fire"

public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "CrimsonTautology",
    description = "Colorblinds everyone when mp_friendlyfire is enabled",
    version = PLUGIN_VERSION,
    url = "https://github.com/CrimsonTautology/sm_super_friendly_fire"
};


new Handle:g_Cvar_Enabled = INVALID_HANDLE;
new Handle:g_Cvar_FriendlyFire = INVALID_HANDLE;

public OnPluginStart()
{
    g_Cvar_FriendlyFire = FindConVar("mp_friendlyfire");

    CreateConVar("sm_super_friendly_fire_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    g_Cvar_Enabled = CreateConVar("sm_super_friendly_fire_enabled", "1", "Enabled");

    HookEvent("player_spawn", Event_PlayerSpawn);
    HookConVarChange(g_Cvar_Enabled, OnEnabledChange);
    HookConVarChange(g_Cvar_FriendlyFire, OnFriendlyFireChange);
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(!IsFriendlyFireEnabled()) return;
    if(!IsSuperFriendlyFireEnabled()) return;

    new client = GetClientOfUserId(GetEventInt(event, "userid"));

    ColorBlindClient(client);
}

public OnEnabledChange(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    if(cvar != g_Cvar_Enabled) return;
    if(!IsFriendlyFireEnabled()) return;

    new bool:was_on = !!StringToInt(oldValue);
    new bool:now_on = !!StringToInt(newValue);

    //When changing from on to off
    if(was_on && !now_on)
    {
        UnColorBlindAllClients();
    }

    //When changing from off to on
    if(!was_on && now_on)
    {
        ColorBlindAllClients();
    }
}

public OnFriendlyFireChange(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    if(cvar != g_Cvar_FriendlyFire) return;
    if(!IsSuperFriendlyFireEnabled()) return;

    new bool:was_on = !!StringToInt(oldValue);
    new bool:now_on = !!StringToInt(newValue);

    //When changing from on to off
    if(was_on && !now_on)
    {
        UnColorBlindAllClients();
    }

    //When changing from off to on
    if(!was_on && now_on)
    {
        ColorBlindAllClients();
    }
}


bool:IsSuperFriendlyFireEnabled()
{
    return GetConVarBool(g_Cvar_Enabled);
}

bool:IsFriendlyFireEnabled()
{
    return GetConVarBool(g_Cvar_FriendlyFire);
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
    new flags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
    SetCommandFlags("r_screenoverlay", flags);

    ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
}
