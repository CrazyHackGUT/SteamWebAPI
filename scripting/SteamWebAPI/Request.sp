/**
 * StringMap structure.
 *
 * * request_params - [ HANDLE ] StringMap with params
 * * steaminterface - [ STRING ] Steam Web API Interface
 * * steamversion   - [ STRING ] Steam Web API Version
 * * steammethod    - [ STRING ] Steam Web API Method 
 * * http_method    - [  INT   ] Request Method (GET / POST)
 * * request_id     - [  INT   ] Request ID
 * * receive_kv     - [  BOOL  ] Receives KV.
 * * callback       - [FUNCTION] Callback functions
 * * owner          - [ HANDLE ] Plugin owner
 * * data           - [  ANY   ] Custom data
 */

bool Request_IsValidRequestID(int iID) {
    return (Request_FindRequestByID(iID) != null);
}

bool Request_IsValidOwner(int iID, Handle hPlugin) {
    Handle hRequest = Request_FindRequestByID(iID);
    if (!hRequest)
        return false;

    Handle hOwner;
    GetTrieValue(hRequest, "owner", hOwner);

    return (hOwner == hPlugin);
}

Handle Request_FindRequestByID(int iID, int &iArrayID = 0) {
    int iLength = GetArraySize(g_hRequests);
    int iRequestID = -1;

    for (int i = 0; i < iLength; i++) {
        Handle hRequest = GetArrayCell(g_hRequests, i);
        if (GetTrieValue(hRequest, "request_id", iRequestID) && iRequestID == iID) {
            iArrayID = i;
            return hRequest;
        }
    }

    return null;
}

int Request_Init(Handle hRequest) {
    int iID = g_iRequests++;

    SetTrieValue(hRequest, "request_id", iID);
    SetTrieValue(hRequest, "http_method", GET);
    SetTrieValue(hRequest, "request_params", CreateTrie());
    SetTrieValue(hRequest, "receive_kv", false);
    
    Handle hPack = CreateDataPack();
    WritePackFunction(hPack, INVALID_FUNCTION);
    WritePackFunction(hPack, INVALID_FUNCTION);

    SetTrieValue(hRequest, "callback", hPack);

    PushArrayCell(g_hRequests, hRequest);

    return iID;
}

bool Request_Create(int &iRequestID) {
    Handle hRequest = CreateTrie();
    if (!hRequest)
        return false;

    iRequestID = Request_Init(hRequest);
    return true;
}

bool Request_SetHTTPMethod(int iRequestID, EHTTPRequestMethod eMethod) {
    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest)
        return false;

    SetTrieValue(hRequest, "http_method", eMethod);
    return true;
}

bool Request_SetInterface(int iRequestID, const char[] szInterface) {
    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest)
        return false;

    SetTrieString(hRequest, "steaminterface", szInterface);
    return true;
}

bool Request_SetVersion(int iRequestID, const char[] szVersion) {
    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest)
        return false;

    SetTrieString(hRequest, "steamversion", szVersion);
    return true;
}

bool Request_SetMethod(int iRequestID, const char[] szMethod) {
    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest)
        return false;

    SetTrieString(hRequest, "steammethod", szMethod);
    return true;
}

bool Request_SetRequestParam(int iRequestID, const char[] szParam, const char[] szValue) {
    Handle hParams;
    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest || !GetTrieValue(hRequest, "request_params", hParams))
        return false;

    SetTrieString(hParams, szParam, szValue);
    return true;
}

void Request_SetRequestParams(int iRequestID, Handle hParams) {
    Handle hSnapshot = CreateTrieSnapshot(hParams);

    char szParam[32];
    char szValue[64];

    int iLength     = TrieSnapshotLength(hParams);

    for (int i = 0; i < iLength; i++) {
        GetTrieSnapshotKey(hSnapshot, i, SZF(szParam));
        if (GetTrieString(hParams, szParam, SZF(szValue)))
            Request_SetRequestParam(iRequestID, szParam, szValue);
    }
}

bool Request_ClearRequestParams(int iRequestID) {
    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest)
        return false;

    Handle hParams;
    GetTrieValue(hRequest, "request_params", hParams);
    delete hParams;

    SetTrieValue(hRequest, "request_params", CreateTrie());

    return true;
}

bool Request_SetOwner(int iRequestID, Handle hNewOwner) {
    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest || !UTIL_IsValidPluginHandle(hNewOwner))
        return false;

    SetTrieValue(hRequest, "owner", hNewOwner);
    return true;
}

bool Request_SetData(int iRequestID, any data) {
    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest)
        return false;

    SetTrieValue(hRequest, "data", data);
    return true;
}

bool Request_SetCallback(int iRequestID, Function fSuccess, Function fError) {
    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest)
        return false;

    Handle hPack;
    GetTrieValue(hRequest, "callback", hPack);
    ResetPack(hPack, true);
    WritePackFunction(hPack, fSuccess);
    WritePackFunction(hPack, fError);
    return true;
}

bool Request_Cancel(int iRequestID) {
    int iArrayID;
    Handle hRequest = Request_FindRequestByID(iRequestID, iArrayID);
    if (!hRequest)
        return false;

    delete hRequest;
    RemoveFromArray(hRequest, iArrayID);
    return true;
}

bool Request_ReadyToStart(int iRequestID) {
    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest)
        return false;

    // URL building process started...
    char szInterface[32];
    char szVersion[32];
    char szMethod[32];
    GetTrieString(hRequest, "steaminterface",   SZF(szInterface));
    GetTrieString(hRequest, "steamversion",     SZF(szVersion));
    GetTrieString(hRequest, "steammethod",      SZF(szMethod));

    char szURL[255];
    UTIL_PrepareURL(SZF(szURL), szInterface, szVersion, szMethod);

    // Starting HTTP query...
    EHTTPRequestMethod eMethod;
    GetTrieValue(hRequest, "http_method", eMethod);
    Handle hSteamRequest = SteamWorks_CreateHTTPRequest(((eMethod == GET) ? k_EHTTPMethodGET : k_EHTTPMethodPOST), szURL);
    if (!hSteamRequest) {
        return false; // ThrowNativeError(SP_ERROR_NATIVE, "SteamWorks: Can't create Request Object");
    }

    if (!(SteamWorks_SetHTTPRequestContextValue(hSteamRequest, hRequest) && SteamWorks_SetHTTPCallbacks(hSteamRequest, Event_OnSteamTransferFinished))) {
        delete hSteamRequest;
        return false; // ThrowNativeError(SP_ERROR_NATIVE, "SteamWorks: Can't setup generic core callback OR StringMap with Request Data");
    }

    // Set HTTP params
    Handle hParams;
    if (GetTrieValue(hRequest, "request_params", hParams) && GetTrieSize(hParams) > 0) {
        Handle hSnap    = CreateTrieSnapshot(hParams);
        int iLength     = TrieSnapshotLength(hSnap);

        char szParam[64];
        char szValue[512];

        for (int i = 0; i < iLength; i++) {
            GetTrieSnapshotKey(hSnap, i, SZF(szParam));
            GetTrieString(hParams, szParam, SZF(szValue));

            if (!SteamWorks_SetHTTPRequestGetOrPostParameter(hSteamRequest, szParam, szValue)) {
                delete hSteamRequest;
                delete hSnap;

                return false; // ThrowNativeError(SP_ERROR_NATIVE, "SteamWorks: Can't setup HTTP request param %s with value %s", szParam, szValue);
            }
        }
    }

    if (!SteamWorks_SetHTTPRequestGetOrPostParameter(hSteamRequest, "format", "vdf") || !SteamWorks_SetHTTPRequestGetOrPostParameter(hSteamRequest, "key", g_szWebAPIKey)) {
        delete hSteamRequest;

        return false; // ThrowNativeError(SP_ERROR_NATIVE, "SteamWorks: Can't setup Web API key or result type.");
    }

    if (!SteamWorks_SendHTTPRequest(hSteamRequest)) {
        delete hSteamRequest;
        return false; // ThrowNativeError(SP_ERROR_NATIVE, "SteamWorks: Can't send HTTP request.");
    }

    return true;
}

bool Request_Validate(int iRequestID) {
    char szTemp[2];

    Handle hRequest = Request_FindRequestByID(iRequestID);
    if (!hRequest)
        return false;

    return (GetTrieString(hRequest, "steaminterface", SZF(szTemp)) &&
            GetTrieString(hRequest, "steamversion", SZF(szTemp)) &&
            GetTrieString(hRequest, "steammethod", SZF(szTemp)));
}