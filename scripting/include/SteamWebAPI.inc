#if defined _steamwebapi_included
 #endinput
#endif

#define _steamwebapi_included

/**
 * Describes HTTP request types.
 */
enum EHTTPRequestMethod {
    GET     = 0,        /**< HTTP GET Method */
    POST    = 1         /**< HTTP POST Method */
}

/**
 * Describes available information types for function WebAPI_Setup()
 */
enum EInformationType {
    Interface   = 0,    /**< Interface name */
    Method      = 1,    /**< Method name */
    Version     = 2     /**< Method version */
}

/**
 * Describes error types.
 */
enum EErrorReason {
    EError_None                         = 0,    /**< This error code do not using. */
    EError_UnknownError                 = -1,   /**< Unknown error. */
    EError_CantWriteResponse            = -2,   /**< Can't write response to temporary dir for parsers. */
    EError_IncorrectHTTPResponseCode    = -3,   /**< Incorrect HTTP Response Code. */
    EError_CantParse                    = -4    /**< Parser can't correct parse response */
}

/**
 * Callback calls after successful web request.
 * WARNING! Response handle(-s) automatically has been closed in next tick.
 * If you need something data from response in next ticks, save it manually in your plugin memory.
 *
 * @param iRequestID    Request ID.
 * @param hResponse     Response object (StringMap object).
 * @param data          Custom data.
 */
typedef WebAPIResponse = function void (int iRequestID, Handle hResponse, any data);

/**
 * Callback calls after web request with error.
 *
 * @param iRequestID    Request ID.
 * @param eError        Error reason.
 * @param data          Custom data.
 */
typedef WebAPIError = function void (int iRequestID, EErrorReason eError, any data);

/**
 * Starts a Steam Web API call.
 *
 * @return              Request ID, or -1 if Steam Web API library can't start a request.
 */
native int WebAPI_Start();

/**
 * Cancels a Steam Web API call.
 * 
 * @param iRequestID    Request ID for cancelling.
 */
native void WebAPI_Cancel(int iRequestID);

/**
 * Finish Steam Web API call.
 * Remember. Created Request with WebAPI_Start() don't deletes automatically, if your callback APIWebResponse or APIWebError returns false.
 *
 * @param iRequestID    Request ID for finishing.
 * @return              True, if request started, or false.
 */
native bool WebAPI_Finish(int iRequestID);

/**
 * Setups a call information.
 * 
 * @param iRequestID    Request ID.
 * @param eInfoType     Information type.
 * @param szValue       Information value.
 */
native void WebAPI_Setup(int iRequestID, EInformationType eInfoType, const char[] szValue);

/**
 * Setups a HTTP method.
 * 
 * @param iRequestID    Request ID.
 * @param eMethod       Request method type.
 */
native void WebAPI_SetMethod(int iRequestID, EHTTPRequestMethod eMethod = GET);

/**
 * Setup GET/POST parameter.
 *
 * @param iRequestID    Request ID.
 * @param szParam       Param name.
 * @param szValue       Value name. Leave empty, if you need unset parameter.
 */
native void WebAPI_SetRequestParameter(int iRequestID, const char[] szParam, const char[] szValue = "");

/**
 * Setup GET/POST parameters.
 * Expects StringMap object.
 * You MUST close StringMap object after calling this method.
 * 
 * @param iRequestID    Request ID.
 * @param hParams       Params array.
 */
native void WebAPI_SetRequestParameters(int iRequestID, Handle hParams);

/**
 * Clears GET/POST parameters.
 *
 * @param iRequestID    Request ID.
 */
native void WebAPI_ClearRequestParameters(int iRequestID);

/**
 * Set callback.
 *
 * @param iRequestID    Request ID.
 * @param fSuccess      Callback function, if result is successful. Set INVALID_FUNCTION if you don't need result.
 * @param fError        Callback function, if result is unsuccessful. Set INVALID_FUNCTION if you don't need know about any errors.
 */
native void WebAPI_SetCallback(int iRequestID, WebAPIResponse fSuccess = INVALID_FUNCTION, WebAPIError fError = INVALID_FUNCTION);

/**
 * Set custom data for callback.
 *
 * @param iRequestID    Request ID.
 * @param data          Any data.
 */
native void WebAPI_SetCustomData(int iRequestID, any data);

/**
 * Set KeyValues response type.
 *
 * @param iRequestID    Request ID.
 * @param bUse          Use KeyValues, or use StringMaps.
 */
native void WebAPI_SetUsageKeyValues(int iRequestID, bool bUse = false);

/**
 * Change request owner.
 * WARNING! After call this function, your plugin can't change request parameters, methods and etc.!
 *
 * @param iRequestID    Request ID.
 * @param hPlugin       Plugin Handle.
 */
native void WebAPI_ChangeRequestOwner(int iRequestID, Handle hPlugin);

/**
 * Cancels all requests owned by calling plugin.
 */
native void WebAPI_CancelAllRequests();