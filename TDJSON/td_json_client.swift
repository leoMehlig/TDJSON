import libtdjson

/**
  Swift interface for interaction with TDLib via JSON-serialized objects.
  Can be used to easily integrate TDLib with any programming language which supports calling C functions
  and is able to work with JSON.

  The JSON serialization of TDLib API objects is straightforward: all API objects are represented as JSON objects with
  the same keys as the API object field names. The object type name is stored in the special field "@type", which is
  optional in places where a type is uniquely determined by the context.
  Bool object fields are stored as Booleans in JSON. int32, int53 and double fields are stored as Numbers.
  int64 and string fields are stored as Strings. bytes fields are base64 encoded and then stored as String.
  vectors are stored as Arrays.
  The main TDLib interface is asynchronous. To match requests with a corresponding response a field "@extra" can
  be added to the request object. The corresponding response will have an "@extra" field with exactly the same value.

  A TDLib client instance should be created through td_json_client_create.
  Requests then can be sent using td_json_client_send from any thread.
  New updates and request responses can be received through td_json_client_receive from any thread. This function
  shouldn't be called simultaneously from two different threads. Also note that all updates and request responses
  should be applied in the order they were received to ensure consistency.
  Given this information, it's advisable to call this function from a dedicated thread.
  Some service TDLib requests can be executed synchronously from any thread by using td_json_client_execute.
  The TDLib client instance can be destroyed via td_json_client_destroy.

  General pattern of usage:
  ```
  let client = td_json_client_create()
  // somehow share the client with other threads, which will be able to send requests via td_json_client_send

  let waitTimeout = 10.0 // seconds
  let isClosed = false  // should be set to true, when updateAuthorizationState with authorizationStateClosed is received
  while !isClosed {
    if let result = td_json_client_receive(client: client, timeout: waitTimeout) {
      // parse the result as JSON object and process it as an incoming update or an answer to a previously sent request
    }
  }
  td_json_client_destroy(client: client)
  ```
 */

/// Creates a new instance of TDLib.
///
/// - Returns: Pointer to the created instance of TDLib.
public func td_json_client_create() -> UnsafeMutableRawPointer! {
    return libtdjson.td_json_client_create()
}

/// Sends request to the TDLib client. May be called from any thread.
///
/// - Parameters:
///   - client: The client.
///   - request: JSON-serialized null-terminated request to TDLib.
public func td_json_client_send(client: UnsafeMutableRawPointer, request: String) {
    libtdjson.td_json_client_send(client, request)
}

/// Receives incoming updates and request responses from the TDLib client. May be called from any thread, but
/// shouldn't be called simultaneously from two different threads.
/// Returned pointer will be deallocated by TDLib during next call to td_json_client_receive or td_json_client_execute
/// in the same thread, so it can't be used after that.
///
/// - Parameters:
///   - client: The client.
///   - timeout: Maximum number of seconds allowed for this function to wait for new data.
/// - Returns: JSON-serialized null-terminated incoming update or request response. May be NULL if the timeout expires.
public func td_json_client_receive(client: UnsafeMutableRawPointer, timeout: TimeInterval) -> String? {
    if let response = libtdjson.td_json_client_receive(client, timeout) {
        return String(cString: response)
    }
    return nil
}

/// Synchronously executes TDLib request. May be called from any thread.
/// Only a few requests can be executed synchronously.
/// Returned pointer will be deallocated by TDLib during next call to td_json_client_receive or td_json_client_execute
/// in the same thread, so it can't be used after that.
///
/// - Parameters:
///   - client: The client.
///   - request: JSON-serialized null-terminated request to TDLib.
/// - Returns: JSON-serialized null-terminated request response. May be NULL if the request can't be parsed.
public func td_json_client_execute(client: UnsafeMutableRawPointer, request: String) -> String? {
    if let response = libtdjson.td_json_client_execute(client, request) {
        return String(cString: response)
    }
    return nil
}

/// Destroys the TDLib client instance. After this is called the client instance shouldn't be used anymore.
///
/// - Parameter client: The client.
public func td_json_client_destroy(client: UnsafeMutableRawPointer) {
    libtdjson.td_json_client_destroy(client)
}
