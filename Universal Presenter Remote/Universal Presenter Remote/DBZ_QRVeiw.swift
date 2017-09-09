//
//  DBZ_QRVeiw.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 11/4/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

import UIKit

class DBZ_QRVeiw: UIViewController {
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var scanContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(DBZ_QRVeiw.sessionActivated(_:)), name:NSNotification.Name(rawValue: "SessionActivated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DBZ_QRVeiw.sessionReady(_:)), name:NSNotification.Name(rawValue: "UpdateInterface"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sessionActivated(_ notification: Notification) {
        loadingIndicator.startAnimating()
        scanContainer.alpha = 0.4
    }
    
    func sessionReady(_ notification: Notification) {
        self.close(self)
    }
    
    @IBAction func close(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ResetQR"), object: nil)
        self.dismiss(animated: true, completion: nil)
        
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
