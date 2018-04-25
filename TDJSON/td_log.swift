import libtdjson

/**
 Swift interface for managing the internal logging of TDLib.
 By default TDLib writes logs to stderr or an OS specific log and uses a verbosity level of 5.
*/

/// Sets the path to the file where the internal TDLib log will be written.
/// By default TDLib writes logs to stderr or an OS specific log.
/// Use this method to write the log to a file instead.
///
/// - Parameter file_path: Null-terminated path to a file where the internal TDLib log will be written. Use an empty path to switch back to the default logging behaviour.
/// - Returns: True on success, or false otherwise, i.e. if the file can't be opened for writing.
public func td_set_log_file_path(_ file_path: String) -> Bool {
    return libtdjson.td_set_log_file_path(file_path) == 1
}

/// Sets maximum size of the file to where the internal TDLib log is written before the file will be auto-rotated.
/// Unused if log is not written to a file. Defaults to 10 MB.
///
/// - Parameter max_file_size: Maximum size of the file to where the internal TDLib log is written before the file will be auto-rotated. Should be positive.
public func td_set_log_max_file_size(_ max_file_size: Int64) {
    libtdjson.td_set_log_max_file_size(max_file_size)
}

/// Sets the verbosity level of the internal logging of TDLib.
/// By default the TDLib uses a log verbosity level of 5.
///
/// - Parameter new_verbosity_level: New value of logging verbosity level.
///                                 Value 0 corresponds to fatal errors,
///                                 value 1 corresponds to errors,
///                                 value 2 corresponds to warnings and debug warnings,
///                                 value 3 corresponds to informational,
///                                 value 4 corresponds to debug,
///                                 value 5 corresponds to verbose debug,
///                                 value greater than 5 and up to 1024 can be used to enable even more logging.
public func td_set_log_verbosity_level(_ new_verbosity_level: Int32) {
    libtdjson.td_set_log_verbosity_level(new_verbosity_level)
}

/// A type of callback function that will be called when a fatal error happens.
///
/// - Parameter error_message: Null-terminated string with a description of a happened fatal error.
public typealias td_log_fatal_error_callback = (String) -> Void


//TODO: Added error callback function.
/**
 * Sets the callback that will be called when a fatal error happens.
 * None of the TDLib methods can be called from the callback.
 * The TDLib will crash as soon as callback returns.
 * By default the callback is not set.
 *
 * \param[in]  callback Callback that will be called when a fatal error happens.
 *                      Pass NULL to remove the callback.
 */

//public func td_set_log_fatal_error_callback(_ callback: @escaping td_log_fatal_error_callback) {
//    let swiftCallback: @convention(c) (UnsafePointer<Int8>?) -> Void = {
//        callback(String(cString: $0!))
//    }
//    libtdjson.td_set_log_fatal_error_callback(swiftCallback)
//}
