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
 * Callback calls after successful web request.
 *
 * @param iRequestID    Request ID.
 * @param hResponse     Response object (StringMap object).
 * @param data          Custom data.
 */
typedef WebAPIResponse = function void (int iRequestID, Handle hResponse, any data);

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
 * @param fCallback     Callback function. Set INVALID_FUNCTION if you don't need result.
 */
native void WebAPI_SetCallback(int iRequestID, WebAPIResponse fCallback = INVALID_FUNCTION);

/**
 * Set custom data for callback.
 *
 * @param iRequestID    Request ID.
 * @param data          Any data.
 */
native void WebAPI_SetCustomData(int iRequestID, any data);

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