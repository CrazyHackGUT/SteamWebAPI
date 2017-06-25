bool UTIL_IsValidPluginHandle(Handle hPlugin) {
    Handle hIterator = GetPluginIterator();
    bool bValid = false;

    while (MorePlugins(hIterator)) {
        if (ReadPlugin(hIterator) == hPlugin) {
            bValid = true;
            break;
        }
    }

    delete hIterator;
    return bValid;
}

void UTIL_PrepareURL(char[] szBuffer, int iMaxLength, const char[] szInterface, const char[] szMethod, const char[] szVersion) {
    strcopy(szBuffer, iMaxLength, g_szAPI_BaseURL);

    ReplaceString(szBuffer, iMaxLength, "{interface}",  szInterface,    true);
    ReplaceString(szBuffer, iMaxLength, "{version}",    szVersion,      true);
    ReplaceString(szBuffer, iMaxLength, "{method}",     szMethod,       true);
}

Handle UTIL_ChangeHandleOwner(Handle hHandle, Handle hPlugin, bool bCloseOriginalHandle = true, Handle &hOutput = null) {
    Handle hResult = CloneHandle(hHandle, hPlugin);

    if (bCloseOriginalHandle) {
        delete hHandle;
    }

    if (hOutput) {
        PushArrayCell(hOutput, hResult);
    }

    return hResult;
}

bool UTIL_AutoSetupAPIKey() {
    if (GetEngineVersion() == Engine_CSGO) {
        if (FindCommandLineParam(g_szCommandLineArg_CSGO)) {
            GetCommandLineParam(g_szCommandLineArg_CSGO, SZF(g_szWebAPIKey), "");

            if (g_szWebAPIKey[0])
                return true;
        }

        if (FileExists("webapi_authkey.txt")) {
            Handle hFile = OpenFile("webapi_authkey.txt", "rt");
            ReadFileLine(hFile, SZF(g_szWebAPIKey));
            delete hFile;

            if (g_szWebAPIKey[0])
                return true;
        }
    }

    return false;
}

void UTIL_CloseAllHandles(Handle hArrayList) {
    int iLength = GetArraySize(hArrayList);
    for (int iCount = 0; iCount < iLength; iCount++) {
        delete view_as<Handle>(GetArrayCell(hArrayList, iCount));
    }

    delete hArrayList;
}
