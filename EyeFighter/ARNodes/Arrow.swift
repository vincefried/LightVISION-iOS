//
//  Arrow.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 30.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import ARKit
import SceneKit

class Arrow: SCNNode {
    var oldCalibrationState: CalibrationState = .done
    
    var isAnimating: Bool = false
    
    override init() {
        super.init()
        
        let url = Bundle.main.url(forResource: "Arrow",
                                  withExtension: "scn",
                                  subdirectory: "Models.scnassets")!
        let node = SCNReferenceNode(url: url)!
        node.load()
        addChildNode(node)
        isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    private func updatePosition(position: SCNVector3, camera: SCNNode, calibrationState: CalibrationState) {
        self.position = position
        
        switch calibrationState {
        case .center:
            eulerAngles = SCNVector3Make(0, -1 * (Float.pi / 2.0), 3 * (Float.pi / 2.0))
            self.position.z = position.z + 0.125
        case .right:
            eulerAngles = SCNVector3Make(0, 0, 4 * (Float.pi / 2.0))
            self.position.x = position.x + 0.125
        case .down:
            eulerAngles = SCNVector3Make(0, 0, 3 * (Float.pi / 2.0))
            self.position.y = position.y - 0.15
        case .left:
            eulerAngles = SCNVector3Make(0, 0, 2 * (Float.pi / 2.0))
            self.position.x = position.x - 0.125
        case .up:
            eulerAngles = SCNVector3Make(0, 0, Float.pi / 2.0)
            self.position.y = position.y + 0.15
        default:
            break
        }
    }

    func update(position: SCNVector3, camera: SCNNode, calibrationState: CalibrationState) {
        isHidden = calibrationState == .initial || calibrationState == .done

        if !isAnimating && oldCalibrationState != calibrationState {
            SCNTransaction.begin()
            updatePosition(position: position, camera: camera, calibrationState: calibrationState)
            SCNTransaction.animationDuration = 0.25
            SCNTransaction.completionBlock = {
                self.isAnimating = false
                self.oldCalibrationState = calibrationState
            }
        }
        
        if !isAnimating && oldCalibrationState != calibrationState {
            isAnimating = true
            SCNTransaction.commit()
        }

        if !isAnimating {
            updatePosition(position: position, camera: camera, calibrationState: calibrationState)
        }
    }
}
