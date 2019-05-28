//
//  SettingsViewController.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 28.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var viewModel: SettingsViewModel!
    
    @IBOutlet weak var debugSwitch: UISwitch!
    @IBOutlet weak var connectedWithLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    private func updateUI() {
        debugSwitch.isOn = viewModel.isDebugSwitchOn
        connectedWithLabel.text = viewModel.connectedLabelText
    }
    
    @IBAction func toggledSwitch(_ sender: UISwitch) {
        viewModel.handleDebugSwitchChanged(isDebugModeEnabled: sender.isOn)
    }
    
    @IBAction func tappedDoneButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
