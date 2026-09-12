//
//  DBZ_InfoView.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/20/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

import UIKit

@objc(DBZ_InfoView)
class DBZ_InfoView: UIViewController {

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
