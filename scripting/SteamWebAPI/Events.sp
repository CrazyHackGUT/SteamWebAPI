public APLRes AskPluginLoad2(Handle hMySelf, bool bLate, char[] szError, int iErrorLength) {
    API_Register();
    RegPluginLibrary("SteamWebAPI");
}

public void OnPluginStart() {
    g_hRequests = CreateArray(ByteCountToCells(4));
    g_iRequests = 0;

    BuildPath(Path_SM, SZF(g_szRequestsDir), "data/steam_web_api/");
    if (!DirExists(g_szRequestsDir) && !CreateDirectory(g_szRequestsDir, FPERM_DEFAULT))
        SetFailState("[Steam Web API] Can't create temporary dir: %s.Create dir manually.", g_szRequestsDir);

    if (!UTIL_AutoSetupAPIKey()) {
        Handle hCvar = CreateConVar("sv_webapikey", "", "Steam Web API key");
        GetConVarString(hCvar, SZF(g_szWebAPIKey));
        HookConVarChange(hCvar, Event_OnWebAPIKeyChanged);
    }
}

public void Event_OnWebAPIKeyChanged(Handle hCv, const char[] szOldValue, const char[] szNewValue) {
    strcopy(SZF(g_szWebAPIKey), szNewValue);
}

public int Event_OnSteamTransferFinished(Handle hSteamRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, Handle hRequest) {
    // Start handling response...
    if (bFailure && !bRequestSuccessful) {
        delete hSteamRequest;
        API_OnFailedRequest(hRequest, EError_UnknownError);
        return;
    }

    if (eStatusCode != k_EHTTPStatusCode200OK) {
        delete hSteamRequest;
        API_OnFailedRequest(hRequest, EError_IncorrectHTTPResponseCode);
        return;
    }

    int iRequestID;
    GetTrieValue(hRequest, "request_id", iRequestID);

    char szResponse[PLATFORM_MAX_PATH];
    FormatEx(SZF(szResponse), "%s/%d.tmp", g_szRequestsDir, iRequestID);

    // Try write to file.
    bool bResultWriting = SteamWorks_WriteHTTPResponseBodyToFile(hSteamRequest, szResponse);
    delete hSteamRequest;

    if (!bResultWriting) {
        API_OnFailedRequest(hRequest, EError_CantWriteResponse);
        return;
    }

    // Parse and call successful callback.
    Handle hResponse = ResultParser_Parse(hRequest, szResponse);

    if (!hResponse) {
        API_OnFailedRequest(hRequest, EError_CantParse);
        return;
    }

    API_OnSuccessRequest(hRequest, hResponse);
}