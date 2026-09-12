//
//  DBZ_ControlView.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/17/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

import UIKit

@objc(DBZ_ControlView)
class DBZ_ControlView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    @IBAction func mediaButton(_ sender: Any) {
        DBZ_ServerCommunication.getResponse("PlayMedia", withToken: DBZ_ServerCommunication.token(), withHoldfor: true, withDeviceToken: false, withTarget: nil)
    }

    @IBAction func nextButton(_ sender: Any) {
        DBZ_ServerCommunication.getResponse("SlideUp", withToken: DBZ_ServerCommunication.token(), withHoldfor: true, withDeviceToken: false, withTarget: nil)
    }

    @IBAction func previousButton(_ sender: Any) {
        DBZ_ServerCommunication.getResponse("SlideDown", withToken: DBZ_ServerCommunication.token(), withHoldfor: true, withDeviceToken: false, withTarget: nil)
    }
}
