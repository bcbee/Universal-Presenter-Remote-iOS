//
//  DBZ_ForceTouchView.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/29/16.
//  Copyright © 2016 DBZ Technology. All rights reserved.
//

import UIKit
import AudioToolbox

class DBZ_ForceTouchView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var vibrated:Bool = false
    var lowStreak:Int = 0
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        let maximumForce = touches.first?.maximumPossibleForce
        let force = touches.first?.force
        let strength = force!/maximumForce!
        if (strength == 1.0 && (!vibrated || lowStreak > 20)) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            vibrated = true
            DBZ_ServerCommunication.getResponse("SlideUp", withToken: DBZ_ServerCommunication.token(), withHoldfor: true, withDeviceToken: false, withTarget: nil)
            lowStreak = 0
        } else if (strength < 1.0) {
            lowStreak += 1
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        vibrated = false
        lowStreak = 0
    }

}
