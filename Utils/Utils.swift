//
//  Utils.swift
//  ToothpickDemo (iOS)
//
//  Created by Youssef on 7/14/21.
//

import UIKit
import Foundation

class Utils: NSObject {

    /**
     Converts an array of dictionaries to JSON string.
     - parameter array: The array to convert.
     - parameter options: Writing options for the JSONSerialization. Can be nil. Is set to .prettyPrinted by default.
     - Returns:
     json: Serialized JSON String.
     */
    class func toJSONString(array:[[String:AnyObject]], options: JSONSerialization.WritingOptions = .prettyPrinted) -> String {
        if let dat = try? JSONSerialization.data(withJSONObject: array, options: options) {
            let str = String(data: dat, encoding: String.Encoding.utf8) ?? ""
            return str
        }
        return "[]"
    }
    
    /**
     Converts an array of Any to JSON string.
     - parameter array: The array to convert.
     - parameter options: Writing options for the JSONSerialization. Can be nil. Is set to .prettyPrinted by default.
     - Returns:
     json: Serialized JSON String.
     */
    class func toJSON(object:Any) -> String {
        if let dat = try? JSONSerialization.data(withJSONObject: object, options: []) {
            let str = String(data: dat, encoding: String.Encoding.utf8) ?? ""
            return str
        }
        return "!!NOT JSON STRUCTURE!!"
    }
}
