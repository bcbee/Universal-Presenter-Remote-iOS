//
//  DBZ_ControlContainerView.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/29/16.
//  Copyright © 2016 DBZ Technology. All rights reserved.
//

import UIKit

class DBZ_ControlContainerView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DBZ_ServerCommunication.startSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
