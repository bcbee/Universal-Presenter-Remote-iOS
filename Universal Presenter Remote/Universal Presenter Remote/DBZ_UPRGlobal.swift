//
//  DBZ_UPRGlobal.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/29/16.
//  Copyright © 2016 DBZ Technology. All rights reserved.
//

import UIKit

class DBZ_UPRGlobal: NSObject {
    
    @objc static var viewToOpen:String = ""
    
    @objc static func hasTaptic() -> Bool {
        if let feedbackSupportLevel = UIDevice.current.value(forKey: "_feedbackSupportLevel") as? Int {
            if feedbackSupportLevel > 1 {
                return true
            }
        }
        
        return false
    }

}
