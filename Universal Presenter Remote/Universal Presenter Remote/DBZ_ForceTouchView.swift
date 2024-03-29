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
    
    var feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
    
    var vibrated:Bool = false
    var lowStreak:Int = 0
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let maximumForce = touches.first?.maximumPossibleForce
        let force = touches.first?.force
        let strength = force!/maximumForce!
        if (strength >= 0.8 && (!vibrated || lowStreak > 20)) {
            
            if DBZ_UPRGlobal.hasTaptic() {
                feedbackGenerator?.notificationOccurred(.success)
                feedbackGenerator?.prepare()
            } else {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            vibrated = true
            DBZ_ServerCommunication.getResponse("SlideUp", withToken: DBZ_ServerCommunication.token(), withHoldfor: true, withDeviceToken: false, withTarget: nil)
            lowStreak = 0
        } else if (strength < 1.0) {
            lowStreak += 1
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        vibrated = false
        lowStreak = 0
    }
    
    deinit {
        feedbackGenerator = nil
    }

}
