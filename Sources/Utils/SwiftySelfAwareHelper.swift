//
//  SwiftySelfAwareHelper.swift
//  Wormholy
//
//  Created by Kealdish on 2019/2/28.
//  Copyright © 2019 Wormholy. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    private static let runOnce: Void = {
        Wormholy.awake()
    }()
    
    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        UIApplication.runOnce
        return super.next
    }
    
}
