//
//  Arrow.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 30.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import ARKit
import SceneKit

/// A `SCNNode` that represents an arrow with for calibration.
class Arrow: SCNNode {
    /// Hardcoded values for arrow offset in direction.
    private let positionOffset: (x: Float, y: Float, z: Float) = (x: 0.125, y: 0.15, z: 0.125)
    
    /// Helper variable for holding the old calibration state.
    var oldCalibrationState: CalibrationState = .done
    
    /// If the arrow is currently animating.
    var isAnimating: Bool = false
    
    override init() {
        super.init()
        
        // Load 3D model and add it as a child
        let url = Bundle.main.url(forResource: "Arrow",
                                  withExtension: "scn",
                                  subdirectory: "Models.scnassets")!
        let node = SCNReferenceNode(url: url)!
        node.load()
        addChildNode(node)
        
        // Hide arrow initially
        isHidden = true
    }
    
    /// Required implementation of `NSCoder` because the inheritance of `SCNNode`.
    /// Will never be called actually in this project.
    ///
    /// - Parameter aDecoder: a decoder.
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    /// Update the arrow's position for a given `SCNVector3`.
    ///
    /// - Parameters:
    ///   - position: The given arrow position as `SCNVector3`.
    ///   - calibrationState: The current `CalibrationState` to update the position for.
    private func updatePosition(position: SCNVector3, calibrationState: CalibrationState) {
        self.position = position
        
        switch calibrationState {
        case .center:
            eulerAngles = SCNVector3Make(0, -1 * (Float.pi / 2.0), 3 * (Float.pi / 2.0))
            self.position.z = position.z + positionOffset.z
        case .right:
            eulerAngles = SCNVector3Make(0, 0, 4 * (Float.pi / 2.0))
            self.position.x = position.x + positionOffset.x
        case .down:
            eulerAngles = SCNVector3Make(0, 0, 3 * (Float.pi / 2.0))
            self.position.y = position.y - positionOffset.y
        case .left:
            eulerAngles = SCNVector3Make(0, 0, 2 * (Float.pi / 2.0))
            self.position.x = position.x - positionOffset.x
        case .up:
            eulerAngles = SCNVector3Make(0, 0, Float.pi / 2.0)
            self.position.y = position.y + positionOffset.y
        default:
            break
        }
    }

    /// Updates the arrow position and animates if necessary.
    ///
    /// - Parameters:
    ///   - position: The arrow position as `SCNVector3`.
    ///   - calibrationState: The current `CalibrationState`.
    func update(position: SCNVector3, calibrationState: CalibrationState) {
        // Hide if calibration done or not running
        isHidden = calibrationState == .initial || calibrationState == .done

        // Start transaction if not currently animating
        if !isAnimating && oldCalibrationState != calibrationState {
            SCNTransaction.begin()
            updatePosition(position: position, calibrationState: calibrationState)
            SCNTransaction.animationDuration = 0.25
            SCNTransaction.completionBlock = {
                self.isAnimating = false
                self.oldCalibrationState = calibrationState
            }
        }
        
        // Commit transaction if new calibration state
        if !isAnimating && oldCalibrationState != calibrationState {
            isAnimating = true
            SCNTransaction.commit()
        }

        // Update arrow position if not currently animating
        if !isAnimating {
            updatePosition(position: position, calibrationState: calibrationState)
        }
    }
}
