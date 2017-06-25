Handle  g_hPluginOwner;

Handle  g_hResponse;
Handle  g_hSubkey[32];
int     g_iLength;

Handle  g_hAllCreatedHandles;

Handle ResultParser_Parse(Handle hRequest, const char[] szFile, Handle &hCreatedHandles) {
    static Handle hSMC = null;
    if (!hSMC) {
        hSMC = SMC_CreateParser();
        SMC_SetReaders(hSMC, ResultParser_NewSection, ResultParser_KeyValues, ResultParser_EndSection);
    }

    bool bReceiveKV;
    GetTrieValue(hRequest, "receive_kv",    bReceiveKV);
    GetTrieValue(hRequest, "owner",         g_hPluginOwner);

    g_hAllCreatedHandles = UTIL_ChangeHandleOwner(CreateArray(1), g_hPluginOwner);

    if (bReceiveKV) {
        g_hResponse = UTIL_ChangeHandleOwner(CreateKeyValues("response"), g_hPluginOwner, true, g_hAllCreatedHandles);
        FileToKeyValues(g_hResponse, szFile);
    } else {
        g_hResponse = UTIL_ChangeHandleOwner(CreateTrie(), g_hPluginOwner, true, g_hAllCreatedHandles);
        g_iLength   = 0;

        SMC_ParseFile(hSMC, szFile);
    }

    hCreatedHandles = g_hAllCreatedHandles;

    return g_hResponse;
}

Handle ResultParser_GetWriterHandle() {
    return (g_iLength == 1) ? g_hResponse : g_hSubkey[g_iLength];
}

public SMCResult ResultParser_NewSection(Handle hSMC, const char[] szName, bool bOptQuotes) {
    g_hSubkey[g_iLength++] = UTIL_ChangeHandleOwner(CreateTrie(), g_hPluginOwner, true, g_hAllCreatedHandles);
    SetTrieValue(ResultParser_GetWriterHandle(), szName, g_hSubkey[g_iLength]);
}

public SMCResult ResultParser_KeyValues(Handle hSMC, const char[] szKey, const char[] szValue, bool bKeyQuotes, bool bValueQuotes) {
    SetTrieString(ResultParser_GetWriterHandle(), szKey, szValue);
}

public SMCResult ResultParser_EndSection(Handle hSMC) {
    g_iLength--;
}
