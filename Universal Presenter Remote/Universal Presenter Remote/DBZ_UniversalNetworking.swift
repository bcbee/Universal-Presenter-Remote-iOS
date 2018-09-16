//
//  DBZ_UniversalNetworking.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/25/16.
//  Copyright © 2016 DBZ Technology. All rights reserved.
//

import UIKit

@objc class DBZ_UniversalNetworking: NSObject {
    @objc static func makeRequest(_ url:String, page:String, callback: @escaping (NSMutableArray) -> Void) -> Void {
        httpGet(url, callback: callback, page: page)
    }
    
    static func httpGet(_ url: String, callback: @escaping (NSMutableArray) -> Void, page:String) {
        let request = URLRequest(url: URL(string: url)!)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        httpRequest(request, session: session, callback: callback, page: page)
    }
    
    static func httpRequest(_ request: URLRequest, session: URLSession, callback: @escaping (NSMutableArray) -> Void, page:String) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "NetworkIndicatorOn"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadingDataStart"), object: nil)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "NetworkIndicatorOff"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ReloadingDataStop"), object: nil)
            if error != nil {
                print(error!.localizedDescription)
                //callback("", error!.localizedDescription, page: page, response: response!)
            } else {
                if let data = data,
                    let response = response,
                    let result = String.init(data: data, encoding: .ascii) {
                    callback([page, result, response] as NSMutableArray)
                }
            }
        })
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
}
