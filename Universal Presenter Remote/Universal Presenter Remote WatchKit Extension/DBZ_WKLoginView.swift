//
//  DBZ_WKLoginController.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/25/16.
//  Copyright © 2016 DBZ Technology. All rights reserved.
//

import WatchKit
import Foundation


class DBZ_WKLoginView: WKInterfaceController {

    @IBOutlet var tokenLabel: WKInterfaceLabel!
    @IBOutlet var connectButton: WKInterfaceButton!
    
    var refreshTimer: Timer?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        connectButton.setEnabled(false)
        
        if (!DBZ_ServerCommunication.setup()) {
            DBZ_ServerCommunication.setupUid()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshInterface), name: NSNotification.Name(rawValue: "Refresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name: NSNotification.Name(rawValue: "UpdateInterface"), object: nil)
        DBZ_ServerCommunication.checkToken()
        
        if refreshTimer == nil {
            refreshTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(refreshLocal), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateInterface(_ notification:Notification) {
        updateTokenLabel()
        switch (DBZ_ServerCommunication.controlmode()) {
            case 0:
                //Button Connecting... NO
                connectButton.setEnabled(false)
                connectButton.setTitle("Connecting...")
                connectButton.setBackgroundColor(nil)
                break
            case 1:
                //Button Waiting... NO
                connectButton.setEnabled(false)
                connectButton.setTitle("Waiting...")
                connectButton.setBackgroundColor(nil)
//                DispatchQueue.global().async {
//                    Thread.sleep(forTimeInterval: 1.0)
//
//                    DispatchQueue.main.async {
//                        DBZ_ServerCommunication.checkToken()
//                        self.updateTokenLabel()
//                    }
//                }
                break
            case 2:
                //Button Begin YES
                connectButton.setEnabled(true)
                connectButton.setTitle("Begin")
                connectButton.setBackgroundColor(UIColor(named: "Primary"))
                DBZ_ServerCommunication.startSession()
                if refreshTimer != nil {
                    refreshTimer?.invalidate()
                }
                break
            default:
                break
        }
    }
    
    func updateTokenLabel() {
        let token = DBZ_ServerCommunication.temptoken()
        if (token > 10) {
            //Set token label
            tokenLabel.setText(String(token))
        } else {
            tokenLabel.setText("...")
        }
    }
    
    @objc func refreshInterface(_ notification:Notification) {
        DBZ_ServerCommunication.checkToken()
    }
    
    @objc func refreshLocal() {
        DBZ_ServerCommunication.checkToken()
        self.updateTokenLabel()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func reloadButton() {
        DBZ_ServerCommunication.setupUid()
        updateTokenLabel()
        connectButton.setEnabled(false)
        DBZ_ServerCommunication.checkToken()
    }
}
