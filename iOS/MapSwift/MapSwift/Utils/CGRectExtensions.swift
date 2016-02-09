//
//  CGRectExtensions.swift
//  MapSwift
//
//  Created by David de Florinier on 09/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import Foundation

extension CGRect {
    func mapswift_relativePositionOfPoint(to:CGPoint, tolerance:CGFloat = 10) -> MapSwift.RelativeNodePosition {
        if to.y > self.maxY + tolerance {
            return MapSwift.RelativeNodePosition.Below
        }
        if to.y < self.minY - tolerance {
            return MapSwift.RelativeNodePosition.Above
        }
        return MapSwift.RelativeNodePosition.Horizontal
    }
}
