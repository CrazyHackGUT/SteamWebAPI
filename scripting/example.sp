#include <SteamWebAPI>

public Plugin myinfo = {
    version = "1.0",
    author  = "CrazyHackGUT aka Kruzya",
    name    = "Steam Web API: Example"
};

public void OnPluginStart() {
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientAuthorized(i))
            OnClientAuthorized(i, NULL_STRING);
}

public void OnClientAuthorized(int iClient, const char[] szAuth) {
    // Get user CommunityID
    char szCommunityID[48];
    GetClientAuthId(iClient, AuthId_SteamID64, szCommunityID, sizeof(szCommunityID));

    // Start request
    int iRequestID = WebAPI_Start();
    if (iRequestID == -1) {
        LogError("Can't initialize Steam Web API request.");
        return;
    }

    // Setup generic request data
    WebAPI_Setup(iRequestID, Interface, "IPlayerService");
    WebAPI_Setup(iRequestID, Version,   "0001");
    WebAPI_Setup(iRequestID, Method,    "IsPlayingSharedGame");

    // Setup user "owner"
    WebAPI_SetCustomData(iRequestID, GetClientUserId(iClient));

    // Setup callbacks
    WebAPI_SetCallback(iRequestID, OnRequestSuccessful, OnRequestFailed);

    // Setup GET params.
    WebAPI_SetMethod(iRequestID, GET);
    WebAPI_SetRequestParameter(iRequestID, "appid_playing", "440");
    WebAPI_SetRequestParameter(iRequestID, "steamid",       szCommunityID);

    // Start request
    WebAPI_Finish(iRequestID);
}

/**
 * Callbacks.
 */
public void OnRequestSuccessful(int iRequestID, Handle hResponse, any data) {
    data = GetClientOfUserId(data);

    if (!data) {
        return;
    }

    char szOwner[32];
    Handle hRes;

    if (!GetTrieValue(hResponse, "response", hRes) || !GetTrieString(hRes, "lender_steamid", szOwner, sizeof(szOwner))) {
        return;
    }

    // bool bShared = (szOwner[0] == '0');
    if (szOwner[0] == '7') {
        LogMessage("User %L using Steam Family Sharing. Original owner: %s", data, szOwner);
        return;
    }

    LogMessage("User %L do not using Steam Family Sharing.", data);
}

public void OnRequestFailed(int iRequestID, EErrorReason eError, any data) {}
