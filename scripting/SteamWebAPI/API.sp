/**
 * Registration.
 */
void API_Register() {
    CreateNative("WebAPI_ClearRequestParameters",   Native_ClearRequestParameters);
    CreateNative("WebAPI_SetRequestParameters",     Native_SetRequestParameters);
    CreateNative("WebAPI_SetRequestParameter",      Native_SetRequestParameter);
    CreateNative("WebAPI_ChangeRequestOwner",       Native_ChangeRequestOwner);
    CreateNative("WebAPI_SetUsageKeyValues",        Native_SetUsageKeyValues);
    CreateNative("WebAPI_CancelAllRequests",        Native_CancelAllRequests);
    CreateNative("WebAPI_SetCustomData",            Native_SetCustomData);
    CreateNative("WebAPI_SetCallback",              Native_SetCallback);
    CreateNative("WebAPI_SetMethod",                Native_SetMethod);
    CreateNative("WebAPI_Cancel",                   Native_Cancel);
    CreateNative("WebAPI_Finish",                   Native_Finish);
    CreateNative("WebAPI_Start",                    Native_Start);
    CreateNative("WebAPI_Setup",                    Native_Setup);
}

/**
 * Helpers
 */
int API_GetRequestID(int iParamNum, Handle hPlugin) {
    int iRequestID = GetNativeCell(iParamNum);

    if (!Request_IsValidRequestID(iRequestID)) {
        ThrowNativeError(SP_ERROR_PARAM, "Invalid Request ID");
    }

    if (!Request_IsValidOwner(iRequestID, hPlugin)) {
        ThrowNativeError(SP_ERROR_MEMACCESS, "Access denied for this Request. You need change request owner with WebAPI_ChangeRequestOwner()");
    }

    return iRequestID;
}

/**
 * APIs
 */
public int Native_ClearRequestParameters(NATIVE_PARAMS) {
    Request_ClearRequestParams(API_GetRequestID(1, hPlugin));
}

public int Native_SetRequestParameters(NATIVE_PARAMS) {
    Request_SetRequestParams(API_GetRequestID(1, hPlugin), GetNativeCell(2));
}

public int Native_SetRequestParameter(NATIVE_PARAMS) {
    int iRequestID = API_GetRequestID(1, hPlugin);

    char szParam[32];
    char szValue[64];

    GetNativeString(2, SZF(szParam));
    GetNativeString(3, SZF(szValue));
    Request_SetRequestParam(iRequestID, szParam, szValue);
}

public int Native_ChangeRequestOwner(NATIVE_PARAMS) {
    int iRequestID = API_GetRequestID(1, hPlugin);

    Request_SetOwner(iRequestID, GetNativeCell(2));
}

public int Native_SetUsageKeyValues(NATIVE_PARAMS) {
    Request_MarkUsingKV(API_GetRequestID(1, hPlugin), GetNativeCell(2));
}

public int Native_CancelAllRequests(NATIVE_PARAMS) {
    int iLength = GetArraySize(g_hRequests);
    Handle hOwner;

    for (int i = iLength-1; i >= 0; i--) {
        Handle hRequest = GetArrayCell(g_hRequests, i);
        if (GetTrieValue(hRequest, "owner", hOwner) && hOwner == hPlugin) {
            delete hRequest;
            RemoveFromArray(g_hRequests, i);
        }
    }
}

public int Native_SetCustomData(NATIVE_PARAMS) {
    Request_SetData(API_GetRequestID(1, hPlugin), GetNativeCell(2));
}

public int Native_SetCallback(NATIVE_PARAMS) {
    Request_SetCallback(API_GetRequestID(1, hPlugin), GetNativeFunction(2), GetNativeFunction(3));
}

public int Native_SetMethod(NATIVE_PARAMS) {
    Request_SetHTTPMethod(API_GetRequestID(1, hPlugin), GetNativeCell(2));
}

public int Native_Cancel(NATIVE_PARAMS) {
    Request_Cancel(API_GetRequestID(1, hPlugin));
}

public int Native_Finish(NATIVE_PARAMS) {
    int iRequestID = API_GetRequestID(1, hPlugin);
    if (!Request_Validate(iRequestID)) {
        ThrowNativeError(SP_ERROR_PARAM, "Setup all Steam Web API parameters (Interface, Method, Version)");
    }

    return Request_ReadyToStart(iRequestID);
}

public int Native_Start(NATIVE_PARAMS) {
    int iReqID = -1;
    Request_Create(iReqID);
    return iReqID;
}
    
public int Native_Setup(NATIVE_PARAMS) {
    int iRequestID = API_GetRequestID(1, hPlugin);

    char szData[32];
    GetNativeString(3, SZF(szData));

    switch (GetNativeCell(2)) {
        case Interface: Request_SetInterface(iRequestID, szData);
        case Version:   Request_SetVersion(iRequestID, szData);
        case Method:    Request_SetMethod(iRequestID, szData);

        default:        ThrowNativeError(SP_ERROR_PARAM, "Unknown param");
    }
}

/**
 * Helpers.
 */
void API_OnFailedRequest(const Handle hRequest, const EErrorReason eError) {
    WebAPIError fError;
    Handle hPlugin;
    Handle hPack;

    int iRequestID;
    any data;

    GetTrieValue(hRequest, "data",          data);
    GetTrieValue(hRequest, "owner",         hPlugin);
    GetTrieValue(hRequest, "callback",      hPack);
    GetTrieValue(hRequest, "request_id",    iRequestID);

    ResetPack(hPack);
    ReadPackFunction(hPack); // null read.
    fError = view_as<WebAPIError>(ReadPackFunction(hPack));

    Call_StartFunction(hPlugin, fError);
    Call_PushCell(iRequestID);
    Call_PushCell(eError);
    Call_PushCell(data);
    Call_Finish();
}

void API_OnSuccessRequest(const Handle hRequest, const Handle hResponse) {
    WebAPIResponse fSuccess;
    Handle hPlugin;
    Handle hPack;

    int iRequestID;
    any data;

    GetTrieValue(hRequest, "data",          data);
    GetTrieValue(hRequest, "owner",         hPlugin);
    GetTrieValue(hRequest, "callback",      hPack);
    GetTrieValue(hRequest, "request_id",    iRequestID);

    ResetPack(hPack);
    fSuccess = view_as<WebAPIResponse>(ReadPackFunction(hPack));

    Call_StartFunction(hPlugin, fSuccess);
    Call_PushCell(iRequestID);
    Call_PushCell(hResponse);
    Call_PushCell(data);
    Call_Finish();
}
