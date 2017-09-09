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
        
        NotificationCenter.default.addObserver(self, selector: #selector(DBZ_ControlContainerView.updateControlContainer), name:NSNotification.Name(rawValue: "PreferenceUpdate"), object: nil)
        
        updateControlContainer(Notification(name: Notification.Name(rawValue: ""), object: nil))
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DBZ_ServerCommunication.startSession()
    }
    
    func updateControlContainer(_ notification:Notification) {
        swipeContainer.isHidden = true
        buttonsContainer.isHidden = true
        threeDTouchContainer.isHidden = true
        
        let preferences = UserDefaults.standard.object(forKey: "preferences")
        
        switch ((preferences as AnyObject).object(forKey: "ControlMode") as! String) {
        case "Swipe":
            swipeContainer.isHidden = false
            break
        case "Buttons":
            buttonsContainer.isHidden = false
            break
        case "3D Touch":
            threeDTouchContainer.isHidden = false
            break
        default:
            swipeContainer.isHidden = false
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
