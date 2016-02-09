//
//  MapSwiftNodeCollapsedView.swift
//  MapSwift
//
//  Created by David de Florinier on 04/02/2016.
//  Copyright © 2016 Sauf Pompiers Ltd. All rights reserved.
//

import UIKit

class MapSwiftNodeCollapsedView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var backgrounds:[MapSwiftNodeBackgroundView] = []

    var backgroundFrames:[CGRect] {
        get {
            let offset:CGFloat = 3
            var frames:[CGRect] = []
            var frame = CGRectInset(self.bounds, MapSwiftNodeView.BackgroundInset, MapSwiftNodeView.BackgroundInset)
            frame = frame.offsetBy(dx: offset, dy: offset)
            frames.append(frame)
            frame = frame.offsetBy(dx: offset, dy: offset)
            frames.append(frame)
            return frames
        }
    }
    func setNodeStyle(nodeStyle:MapSwift.NodeStyle, nodeAttributes:MapSwiftNodeAttributes) {
        func ensureCollapsed() {
            if backgrounds.count == 0 {
                let frames = self.backgroundFrames
                let lastIndex = frames.count - 1
                for (index, frame) in frames.enumerate() {
                    let bg = MapSwiftNodeBackgroundView(frame: frame)
                    bg.shadowOn =  index == lastIndex ? MapSwiftNodeBackgroundView.ShowShadowOn.Collapsed : MapSwiftNodeBackgroundView.ShowShadowOn.Never
                    self.addSubview(bg)
                    self.sendSubviewToBack(bg)
                    backgrounds.append(bg)
                }
            }
            for bg in self.backgrounds {
                bg.setNodeStyle(nodeStyle, nodeAttributes: nodeAttributes)
            }
        }
        func clearClollapsed() {
            for bg in backgrounds {
                bg.removeFromSuperview()
            }
            backgrounds.removeAll()
        }

        if (nodeAttributes.collapsed) {
            ensureCollapsed()
        } else {
            clearClollapsed()
        }
        self.setNeedsDisplay()
    }
    override func layoutSubviews() {
        let frames = self.backgroundFrames
        for (index, bg) in backgrounds.enumerate() {
            if index < frames.count {
                let frame = frames[index]
                bg.frame = frame
            }
        }
    }
}
