//
//  NSObject.swift
//  YouTubeSearch
//
//  Created by Kiet Nguyen on 7/17/22.
//

import Foundation
extension NSObject {
    class func name() -> String {
        // get class name
        let path = NSStringFromClass(self)
        
        return path.components(separatedBy: ".").last ?? ""
    }
}
