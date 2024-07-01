//
//  SwipeAction.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import Foundation

enum SwipeAction: String {
    case down = "DOWN"
    case date = "DATE"
    case none = ""
    
    var icon: String {
      return switch self {
        case .date:
          "heart.fill"
      case .down:
          "flame.fill"
      case .none:
          ""
        }
    }
}
