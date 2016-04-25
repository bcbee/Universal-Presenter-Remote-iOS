//
//  DBZ_UniversalNetworking.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/25/16.
//  Copyright © 2016 DBZ Technology. All rights reserved.
//

import UIKit

@objc class DBZ_UniversalNetworking: NSObject {
    static func makeRequest(url:String, page:String, callback: (NSMutableArray) -> Void) -> Void {
        httpGet(url, callback: callback, page: page)
    }
    
    static func httpCallback(result: String, error: String?, page:String, response:NSURLResponse) -> Void {
        print("Response: \(result)")
        let notify: [AnyObject] = [page, result, response]
        let notification:NSNotification = NSNotification(name: "ServerResponse", object: notify)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    static func httpGet(url: String, callback: (NSMutableArray) -> Void, page:String) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        httpRequest(request, session: session, callback: callback, page: page)
    }
    
    static func httpRequest(request: NSMutableURLRequest, session: NSURLSession, callback: (NSMutableArray) -> Void, page:String) {
        NSNotificationCenter.defaultCenter().postNotificationName("NetworkIndicatorOn", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("ReloadingDataStart", object: nil)
        let task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("NetworkIndicatorOff", object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("ReloadingDataStop", object: nil)
            if error != nil {
                print(error!.localizedDescription)
                //callback("", error!.localizedDescription, page: page, response: response!)
            } else {
                let result = NSString(data: data!, encoding:
                    NSASCIIStringEncoding)!
                callback([page, result as String, response!] as NSMutableArray)
            }
        }
        
        task.resume()
    }
}
