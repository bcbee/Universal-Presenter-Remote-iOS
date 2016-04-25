//
//  DBZ_WKLoginController.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/25/16.
//  Copyright © 2016 DBZ Technology. All rights reserved.
//

import WatchKit
import Foundation


class DBZ_WKLoginController: WKInterfaceController {

    @IBOutlet var tokenLabel: WKInterfaceLabel!
    @IBOutlet var connectButton: WKInterfaceButton!
    
    var refreshTimer:NSTimer = NSTimer()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        DBZ_ServerCommunication.setupUid()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshInterface), name: "Refresh", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateInterface), name: "UpdateInterface", object: nil)
        DBZ_ServerCommunication.checkToken()
        
        
    }
    
    func updateInterface(notification:NSNotification) {
        let token = DBZ_ServerCommunication.temptoken()
        if (token > 10) {
            //Set token label
            tokenLabel.setText(String(token))
        }
        switch (DBZ_ServerCommunication.controlmode()) {
            case 0:
                //Button Connecting... NO
                connectButton.setEnabled(false)
                connectButton.setTitle("Connecting...")
                break
            case 1:
                //Button Waiting... NO
                connectButton.setEnabled(false)
                connectButton.setTitle("Waiting...")
                //refreshTimer = NSTimer(timeInterval: 2.0, target: self, selector: #selector(refreshInterface), userInfo: nil, repeats: true)
                refreshTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(refreshInterface), userInfo: nil, repeats: true)
                break
            case 2:
                //Button Begin YES
                connectButton.setEnabled(true)
                connectButton.setTitle("Begin")
                refreshTimer.invalidate()
                break
            default:
                break
        }
    }
    
    func refreshInterface(notification:NSNotification) {
        DBZ_ServerCommunication.checkToken()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func instructionsButton() {
        presentControllerWithName("Instructions", context: self)
    }
    
    @IBAction func reloadButton() {
        DBZ_ServerCommunication.setupUid()
        DBZ_ServerCommunication.checkToken()
    }
}
