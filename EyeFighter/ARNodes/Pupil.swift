//
//  Pupil.swift
//  EyeFighter
//
//  Created by Vincent Friedrich on 30.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import ARKit
import SceneKit

/// A `SCNNode` that represents an eyeball with a pupil.
class Pupil: SCNNode {
    override init() {
        super.init()
        
        // Load 3D model and add it as a child
        let url = Bundle.main.url(forResource: "Pupil",
                                  withExtension: "scn",
                                  subdirectory: "Models.scnassets")!
        let node = SCNReferenceNode(url: url)!
        node.load()
        addChildNode(node)
    }
    
    /// Required implementation of `NSCoder` because the inheritance of `SCNNode`.
    /// Will never be called actually in this project.
    ///
    /// - Parameter aDecoder: a decoder.
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
        
    /// Update the pupil position to a given transform.
    ///
    /// - Parameter transform: The given transform.
    func update(transform: simd_float4x4) {
        simdTransform = transform
    }
}
