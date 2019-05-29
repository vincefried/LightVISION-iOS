//
//  SetupViewController.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 29.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {

    var viewModel: SetupViewModel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        updateUI()
    }
    
    private func updateUI() {
        titleLabel.text = viewModel.titleText
        descriptionLabel.text = viewModel.descriptionText
    }
}

extension SetupViewController: SetupViewModelDelegate {
    func updateUINeeded() {
        updateUI()
    }
}

extension SetupViewController: CalibrationDelegate {
    func calibrationStateDidChange(to state: CalibrationState) {
        viewModel.handleStateChange(calibrationState: state)
    }
    
    func calibrationDidChange(for state: CalibrationState, value: Float) { }
}
