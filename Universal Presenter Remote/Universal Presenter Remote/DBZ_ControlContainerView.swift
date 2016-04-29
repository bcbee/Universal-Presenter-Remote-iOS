//
//  DBZ_ControlContainerView.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/29/16.
//  Copyright © 2016 DBZ Technology. All rights reserved.
//

import UIKit

class DBZ_ControlContainerView: UIViewController {

    @IBOutlet var buttonsContainer: UIView!
    @IBOutlet var swipeContainer: UIView!
    @IBOutlet var threeDTouchContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DBZ_ControlContainerView.updateControlContainer), name:"PreferenceUpdate", object: nil)
        
        updateControlContainer(NSNotification(name: "", object: nil))
        
        navigationController?.interactivePopGestureRecognizer?.enabled = false

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        DBZ_ServerCommunication.startSession()
    }
    
    func updateControlContainer(notification:NSNotification) {
        swipeContainer.hidden = true
        buttonsContainer.hidden = true
        threeDTouchContainer.hidden = true
        
        let preferences = NSUserDefaults.standardUserDefaults().objectForKey("preferences")
        
        switch (preferences?.objectForKey("ControlMode") as! String) {
        case "Swipe":
            swipeContainer.hidden = false
            break
        case "Buttons":
            buttonsContainer.hidden = false
            break
        case "3D Touch":
            threeDTouchContainer.hidden = false
            break
        default:
            swipeContainer.hidden = false
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
