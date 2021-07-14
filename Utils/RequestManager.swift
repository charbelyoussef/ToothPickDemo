//
//  FirstPageVCContentCell.swift
//  ToothpickDemo (iOS)
//
//  Created by Youssef on 7/14/21.
//


import UIKit
import Alamofire

class RequestManager: NSObject {
    
    var alamoFireManager: Alamofire.Session?
    
    static let sharedManager = RequestManager()
    
    fileprivate override init() {
        AF.sessionConfiguration.timeoutIntervalForRequest = 30
        AF.sessionConfiguration.timeoutIntervalForResource = 30
    }
    
    /**
     Send GET request.
     - parameter url     : URL string.
     - parameter success : Success handler callback.
     - parameter failure : Failure handler callback.
     */
    
    func get(url: String, headers: HTTPHeaders?, loading: Bool, success:@escaping (_ result: NSDictionary) -> (), failure:@escaping (_ result: Error) -> ()) {
        request(url: url, headers: headers, loading: loading, success: success, failure: failure)
    }
    
    /**
     Send PUT request .
     - parameter url     : URL string.
     - parameter parameters  : Request parameters Dictionary as [String:AnyObject].
     - parameter success : Success handler callback.
     - parameter failure : Failure handler callback.
     */
    
    func put(url: String, parameters: [String: AnyObject], raw:Bool , loading: Bool, success:@escaping (_ result: NSDictionary) -> (), failure:@escaping (_ result: Error) -> ()) {
        request(method: "put", url: url, params: parameters, headers: nil, raw: raw, loading: loading, success: success, failure: failure)
    }
    
    /**
     Send POST request.
     - parameter url     : URL string.
     - parameter params  : Request parameters Dictionary as [String:AnyObject].
     - parameter success : Success handler callback.
     - parameter failure : Failure handler callback.
     */
    
    func post(url: String, parameters: [String: AnyObject], headers: HTTPHeaders?, raw:Bool , loading: Bool, success:@escaping (_ result: NSDictionary) -> (), failure:@escaping (_ result: Error) -> ()) {
        request(method: "post", url: url, params: parameters, headers: headers, raw: raw, loading: loading, success: success, failure: failure)
    }
    
    /**
     Send DELETE request.
     - parameter method  : HTTP method. `"delete"`.
     - parameter url     : URL string.
     - parameter parameters  : Request parameters Dictionary as [String:AnyObject].
     - parameter success : Success handler callback.
     - parameter failure : Failure handler callback.
     */
    
    func delete(url: String, parameters: [String: AnyObject], raw:Bool , loading: Bool, success:@escaping (_ result: NSDictionary) -> (), failure:@escaping (_ result: Error) -> ()) {
        request(method: "delete", url: url, params: parameters ,headers: nil, raw: raw, loading: loading, success: success, failure: failure)
    }
    
    /**
     Send HTTP request.
     - parameter method  : HTTP method. `"get"` by default.
     - parameter url     : URL string. `""` by default.
     - parameter params  : Request parameters Dictionary as [String:AnyObject]. `[:]` by default.
     - parameter success : Success handler callback.
     - parameter failure : Failure handler callback.
     */
    
    fileprivate func request(method: String = "get",
                             url: String = "",
                             params: [String:AnyObject] = [:],
                             headers: HTTPHeaders?,
                             raw:Bool = false,
                             loading: Bool,
                             success:@escaping (_ result: NSDictionary) -> (),
                             failure:@escaping (_ result: Error) -> ()) {
        
        var requestMethod: Alamofire.HTTPMethod
        
        switch method {
        case "post":
            requestMethod = .post
            break
        case "delete":
            requestMethod = .delete
        case "put":
            requestMethod = .put
        default:
            requestMethod = .get
            break
        }

        let encoding:ParameterEncoding = raw ? JSONEncoding.default : URLEncoding.default
                
        AF.request(url, method: requestMethod, parameters: params, encoding: encoding, headers: headers, interceptor: nil).responseJSON {
            (response:AFDataResponse<Any>) in
            switch(response.result) {
            case .success(let jsonResponse):
                
                
                if let responseArray = jsonResponse as? NSArray {
                    let jsonDict:NSDictionary = ["data" : responseArray]
                    success(jsonDict)
                }
                else if let response = jsonResponse as? NSDictionary {
                    success(response)
                }
                else {
                    let error = NSError(domain: "", code: 69, userInfo: [NSLocalizedDescriptionKey: Constants.Errors.PARSING_ERROR])
                    failure(error)
                    return
                }
                break
                
            case .failure(let error):
                if let err = error.asAFError {
                    if err.isResponseSerializationError {
                        let nserror = NSError(domain: "", code: 69, userInfo: [NSLocalizedDescriptionKey: "There was an error reading the data."])
                        failure(nserror)
                    }
                }
                else {
                    failure(error)
                }
                
                break
            }
        }
    }
    
}
