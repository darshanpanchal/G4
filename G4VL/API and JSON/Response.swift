//
//  Response.swift
//  G4VL
//
//  Created by Michael Miller on 07/03/2018.
//  Copyright © 2018 Foamy iMac7. All rights reserved.
//

import UIKit


class Response: NSObject,URLSessionDelegate,URLSessionTaskDelegate {
    
    static let shared = Response()
    
    func basicNew(urlRequest : URLRequest, completion:@escaping (_ :ApiResult)->()) {
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            
            self.checkResultNew(data: data, urlResponse: urlResponse, error: error, completion: { (apiResult) in
                completion(apiResult)
            })
            
            }.resume()
        
    }
    static func basic(urlRequest : URLRequest, completion:@escaping (_ :ApiResult)->()) {
        
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (data, urlResponse, error) in
           
            self.checkResult(data: data, urlResponse: urlResponse, error: error, completion: { (apiResult) in
                completion(apiResult)
            })
            
            }.resume()
        
    }
     func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        completionHandler(nil)

    }
    private  func checkResultNew(data: Data?, urlResponse: URLResponse?, error: Error?, completion:@escaping(_:ApiResult)->()) {
        
        if error != nil {
            print("Error: \(error!.localizedDescription)")
            var url : URL?
            if urlResponse != nil {
                url = urlResponse!.url
            }
            completion(ApiResult(url: url, statusCode: nil, data: data, errorMessage: error!.localizedDescription, userMessage: ErrorHelper.CustomErrorType.unknown))
        }
        
        if urlResponse != nil {
            
            if let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case 200:
                    completion(ApiResult(url: urlResponse!.url!, statusCode: 200, data: data, errorMessage: nil, userMessage: nil))
                    break;
                case 400:
                    completion(ApiResult(url: urlResponse!.url!, statusCode: 400, data: data, errorMessage: nil, userMessage: nil))
                    return
                case 401:
                    completion(ApiResult(url: urlResponse!.url!, statusCode: 401, data: data, errorMessage: nil, userMessage: nil))
                    return
                case 302:
                    AppManager.sharedInstance.sessionExpired()
                    completion(ApiResult(url: urlResponse!.url!, statusCode: 302, data: data, errorMessage: nil, userMessage: nil))
                    return
                default:
                    
                    
                    completion(ApiResult(url: urlResponse!.url!, statusCode: statusCode, data: data, errorMessage: nil, userMessage: ErrorHelper.CustomErrorType.unknown))
                }
            }
            
        }
        
        
    }
    private static func checkResult(data: Data?, urlResponse: URLResponse?, error: Error?, completion:@escaping(_:ApiResult)->()) {
        
        if error != nil {
            print("Error: \(error!.localizedDescription)")
            var url : URL?
            if urlResponse != nil {
                url = urlResponse!.url
            }
            completion(ApiResult(url: url, statusCode: nil, data: data, errorMessage: error!.localizedDescription, userMessage: ErrorHelper.CustomErrorType.unknown))
        }
        
        if urlResponse != nil {
            
            if let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case 200:
                    completion(ApiResult(url: urlResponse!.url!, statusCode: 200, data: data, errorMessage: nil, userMessage: nil))
                    break;
                case 400:
                    completion(ApiResult(url: urlResponse!.url!, statusCode: 400, data: data, errorMessage: nil, userMessage: nil))
                    return
                case 401:
                    completion(ApiResult(url: urlResponse!.url!, statusCode: 401, data: data, errorMessage: nil, userMessage: nil))
                    return
                default:
                    
                    
                    completion(ApiResult(url: urlResponse!.url!, statusCode: statusCode, data: data, errorMessage: nil, userMessage: ErrorHelper.CustomErrorType.unknown))
                }
            }
            
        }
        
        
    }
    
}
