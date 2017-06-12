/**
 * Steam Web API
 *               Defines.sp
 *
 * Version: 0.1 alpha
 */
#define PLUGIN_DESCRIPTION  "Provides API for Steam Web API calls"
#define PLUGIN_VERSION      "0.1 alpha"
#define PLUGIN_AUTHOR       "CrazyHackGUT aka Kruzya"
#define PLUGIN_NAME         "Steam Web API"
#define PLUGIN_URL          "https://kruzefag.ru/"

// Macro-functions
#define SZF(%0)             %0, sizeof(%0)

// File defines
#define FPERM_U_ALL         FPERM_U_READ | FPERM_U_WRITE | FPERM_U_EXEC
#define FPERM_G_ALL         FPERM_G_READ | FPERM_G_WRITE | FPERM_G_EXEC
#define FPERM_O_ALL         FPERM_O_READ | FPERM_O_WRITE | FPERM_O_EXEC
#define FPERM_DEFAULT       FPERM_U_ALL | FPERM_G_READ | FPERM_G_EXEC | FPERM_O_READ | FPERM_O_EXEC

// Other stuff
#define NATIVE_PARAMS       Handle hPlugin, int iNumParams