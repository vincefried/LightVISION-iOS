//
//  SettingsViewController.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 28.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func settingsViewControllerWillFinish(with viewModel: SettingsViewModel)
}

class SettingsViewController: UIViewController {

    var viewModel: SettingsViewModel!
    
    var delegate: SettingsViewControllerDelegate?
    
    @IBOutlet weak var debugSwitch: UISwitch!
    @IBOutlet weak var voiceSwitch: UISwitch!
    @IBOutlet weak var connectedWithLabel: UILabel!
    @IBOutlet weak var visualEffectsView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCI()
        updateUI()
    }
    
    private func initCI() {
        visualEffectsView.layer.cornerRadius = 10.0
        visualEffectsView.layer.masksToBounds = true
    }
    
    private func updateUI() {
        debugSwitch.isOn = viewModel.isDebugSwitchOn
        voiceSwitch.isOn = viewModel.isVoiceSwitchOn
        connectedWithLabel.text = viewModel.connectedLabelText
    }
    
    @IBAction func toggledDebugSwitch(_ sender: UISwitch) {
        viewModel.handleDebugSwitchChanged(isDebugModeEnabled: sender.isOn)
    }
    
    @IBAction func toggledVoiceSwitch(_ sender: UISwitch) {
        viewModel.handleVoiceSwitchChanged(isVoiceAssistantEnabled: sender.isOn)
    }
    
    @IBAction func tappedDoneButton(_ sender: UIBarButtonItem) {
        delegate?.settingsViewControllerWillFinish(with: viewModel)
        dismiss(animated: true)
    }
}
