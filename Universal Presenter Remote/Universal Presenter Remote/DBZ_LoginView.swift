//
//  DBZ_LoginView.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/16/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

import UIKit

@objc(DBZ_LoginView)
class DBZ_LoginView: UIViewController {

    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!

    private var refreshTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        applyTitleFont()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(updateInterface(_:)), name: Notification.Name("UpdateInterface"), object: nil)
        center.addObserver(self, selector: #selector(refreshInterface(_:)), name: Notification.Name("Refresh"), object: nil)
        center.addObserver(self, selector: #selector(openInstructions(_:)), name: Notification.Name("OpenInstructions"), object: nil)

        DBZ_ServerCommunication.setupUid()

        refreshTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(localRefresh), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyTitleFont()
    }

    private func applyTitleFont() {
        var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        if let font = UIFont(name: "BatmanForeverAlternate", size: 35.0) {
            attributes[.font] = font
        }
        navigationController?.navigationBar.titleTextAttributes = attributes
    }

    @objc func updateInterface(_ notification: Notification) {
        let tempToken = DBZ_ServerCommunication.temptoken()
        if tempToken > 10 {
            tokenLabel.text = "\(tempToken)"
        }

        switch DBZ_ServerCommunication.controlmode() {
        case 0:
            connectButton.isEnabled = false
            connectButton.setTitle("Connecting...", for: .disabled)
            connectButton.backgroundColor = UIColor(named: "Disabled")
        case 1:
            connectButton.isEnabled = false
            connectButton.setTitle("Waiting...", for: .disabled)
            connectButton.backgroundColor = UIColor(named: "Disabled")
        case 2:
            connectButton.isEnabled = true
            connectButton.setTitle("Begin", for: .normal)
            connectButton.backgroundColor = UIColor(named: "Primary")
        default:
            break
        }
    }

    @objc func refreshInterface(_ notification: Notification) {
        DBZ_ServerCommunication.checkToken()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ControlSegue" || segue.identifier == "SettingsSegue" {
            var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
            if let font = UIFont(name: "mplus-1c-regular", size: 21) {
                attributes[.font] = font
            }
            navigationController?.navigationBar.titleTextAttributes = attributes
        }
    }

    @IBAction func refresh(_ sender: Any) {
        DBZ_ServerCommunication.setupUid()
        DBZ_ServerCommunication.checkToken()
    }

    @objc func openInstructions(_ notification: Notification) {
        performSegue(withIdentifier: "InstructionSegue", sender: self)
    }

    @objc func localRefresh() {
        if DBZ_ServerCommunication.apns().isEmpty {
            // running in Simulator
            DBZ_ServerCommunication.checkToken()
        } else {
            refreshTimer?.invalidate()
        }
    }
}
