static const char g_szAPI_BaseURL[] = "https://api.steampowered.com/{interface}/{method}/v{version}";

bool UTIL_IsValidPluginHandle(Handle hPlugin) {
    Handle hIterator = GetPluginIterator();
    bool bValid = false;

    while (MorePlugins(hIterator) && !bValid) {
        if (ReadPlugin(hIterator) == hPlugin) {
            bValid = true;
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

Handle UTIL_ChangeHandleOwner(Handle hHandle, Handle hPlugin, bool bCloseOriginalHandle = true) {
    Handle hResult = CloneHandle(hHandle, hPlugin);

    if (bCloseOriginalHandle) {
        delete hHandle;
    }

    return hResult;
}

bool UTIL_AutoSetupAPIKey() {
    if (GetEngineVersion() == Engine_CSGO) {
        if (FindCommandLineParam("-authkey")) {
            GetCommandLineParam("-authkey", SZF(g_szWebAPIKey), "");

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