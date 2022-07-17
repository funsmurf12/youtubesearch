//
//  YoutubeRouter.swift
//  YouTubeSearch
//
//  Created by Kiet Nguyen on 7/17/22.
//

import Foundation

enum YoutubeRouter {
    case result
    
    var url: String {
        var routePath: String {
            switch self {
            case .result:
                return "/results"
            }
        }
        return NetworkConstants.baseYoutubeUrl + routePath
    }
}
