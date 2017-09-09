//
//  DBZ_WKControlView.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/27/16.
//  Copyright © 2016 DBZ Technology. All rights reserved.
//

import WatchKit
import Foundation


class DBZ_WKControlView: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func mediaPressed() {
        DBZ_ServerCommunication.getResponse("PlayMedia", withToken: DBZ_ServerCommunication.token(), withHoldfor: true, withDeviceToken: false, withTarget: nil)
    }
    
    @IBAction func nextPressed() {
        DBZ_ServerCommunication.getResponse("SlideUp", withToken: DBZ_ServerCommunication.token(), withHoldfor: true, withDeviceToken: false, withTarget: nil)
    }
    
    @IBAction func previousPressed() {
        DBZ_ServerCommunication.getResponse("SlideDown", withToken: DBZ_ServerCommunication.token(), withHoldfor: true, withDeviceToken: false, withTarget: nil)
    }
}
