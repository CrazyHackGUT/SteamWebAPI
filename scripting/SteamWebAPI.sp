#include <adt_trie>
#include <adt_array>
#include <textparse>
#include <sourcemod>
#include <functions>
#include <keyvalues>
#include <SteamWorks>
#include <SteamWebAPI>

#pragma newdecls required

Handle  g_hRequests;
int     g_iRequests;

char    g_szRequestsDir[PLATFORM_MAX_PATH];

char    g_szWebAPIKey[48];

#include "SteamWebAPI/Defines.sp"

#include "SteamWebAPI/ResultParser.sp"
#include "SteamWebAPI/Request.sp"
#include "SteamWebAPI/Events.sp"
#include "SteamWebAPI/UTIL.sp"
#include "SteamWebAPI/API.sp"

public Plugin myinfo = {
    description = PLUGIN_DESCRIPTION,
    version     = PLUGIN_VERSION,
    author      = PLUGIN_AUTHOR,
    name        = PLUGIN_NAME,
    url         = PLUGIN_URL
};