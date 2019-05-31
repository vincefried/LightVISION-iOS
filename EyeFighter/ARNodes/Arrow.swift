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
    override init() {
        super.init()
        
        let url = Bundle.main.url(forResource: "Arrow",
                                  withExtension: "scn",
                                  subdirectory: "Models.scnassets")!
        let node = SCNReferenceNode(url: url)!
        node.load()
        addChildNode(node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    func update(position: SCNVector3, camera: SCNNode) {
        self.position = position
    }
}
