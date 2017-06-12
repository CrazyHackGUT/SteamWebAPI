# SteamWebAPI
Steam Web API library for SourcePawn

# Requirements
- **SourceMod** 1.8+
- **SteamWorks**

# Installing
- Copy all files from `scripting` to your directory with compiler
- Run with _Windows Console Command_ / _Linux Terminal_: `./spcomp SteamWebAPI.sp`
- Copy `SteamWebAPI.smx` from directory with compiler to `server directory/game directory/addons/sourcemod/plugins/`
- Send `sm plugins load SteamWebAPI` with _RCon_ / _direct access to server console_
- If your server - CS:GO, and you have installed Steam Workshop maps, you've great! Plugin automatically loads Steam Web API key, if his can. If not, read next.
- Check exist console var `sv_webapikey`. If him exists, plugin can't load your Steam Web API key, and you need manually setup him.
- Open `server.cfg`, type in end file: `sv_webapikey MY_HIDDEN_KEY`
- Done!

# API
Steam Web API library have API for other plugins. Read our docs in wiki!