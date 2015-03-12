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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionActivated:", name:"SessionActivated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionReady:", name:"UpdateInterface", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sessionActivated(notification: NSNotification) {
        loadingIndicator.startAnimating()
        scanContainer.alpha = 0.4
    }
    
    func sessionReady(notification: NSNotification) {
        self.close(self)
    }
    
    @IBAction func close(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("ResetQR", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
        
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
