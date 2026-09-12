//
//  DBZ_SettingsView.swift
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 9/3/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

import UIKit

@objc(DBZ_SettingsView)
class DBZ_SettingsView: UIViewController {

    @IBOutlet weak var instructionControl: UISegmentedControl!
    @IBOutlet var swipeControl: UISegmentedControl!

    private var oldPreferences: [String: Any] = [:]
    private var newPreferences: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface(_:)), name: Notification.Name("PreferenceUpdate"), object: nil)
        updateInterface(nil)
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func updatePreferences(_ sender: Any) {
        let firstTime = instructionControl.selectedSegmentIndex == 0 ? "Enabled" : "Disabled"

        let controlMode: String
        switch swipeControl.selectedSegmentIndex {
        case 1:
            controlMode = "Buttons"
        default:
            controlMode = "Swipe"
        }

        newPreferences = ["Instructions": firstTime, "ControlMode": controlMode]
        savePreferences()
    }

    private func savePreferences() {
        UserDefaults.standard.set(newPreferences, forKey: "preferences")

        let store = NSUbiquitousKeyValueStore.default
        store.set(newPreferences, forKey: "preferences")
        print("iCloud Saved")
        for (key, value) in store.dictionaryRepresentation {
            print("iCloud: \(key) = \(value)")
        }

        NotificationCenter.default.post(name: Notification.Name("PreferenceUpdate"), object: nil)
    }

    @objc func updateInterface(_ notification: Notification?) {
        oldPreferences = UserDefaults.standard.dictionary(forKey: "preferences") ?? [:]

        instructionControl.selectedSegmentIndex = (oldPreferences["Instructions"] as? String == "Enabled") ? 0 : 1
        swipeControl.selectedSegmentIndex = (oldPreferences["ControlMode"] as? String == "Swipe") ? 0 : 1

        print("Local: \(oldPreferences)")
    }

    func has3DTouch() -> Bool {
        return traitCollection.forceTouchCapability == .available
    }
}
