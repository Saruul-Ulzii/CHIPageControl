//
//  CHIPageControlPaprika.swift.swift
//  CHIPageControl  ( https://github.com/ChiliLabs/CHIPageControl )
//
//  Copyright (c) 2017 Chili ( http://chi.lv )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Darwin

open class CHIPageControlPaprika: CHIBasePageControl {
    
    fileprivate var diameter: CGFloat {
        return radius * 2
    }
    
    fileprivate var elements = [CHILayer]()
    
    fileprivate var frames = [CGRect]()
    fileprivate var min: CGRect?
    fileprivate var max: CGRect?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func updateNumberOfPages(_ count: Int) {
        elements.forEach() { $0.removeFromSuperlayer() }
        elements = [CHILayer]()
        elements = (0..<count).map {_ in
            let layer = CHILayer()
            self.layer.addSublayer(layer)
            return layer
        }
        
        layout()
        update(for: progress)
        self.invalidateIntrinsicContentSize()
    }
    
    override func layout() {
        let floatCount = CGFloat(elements.count)
        let x = (self.frame.size.width - self.diameter*floatCount - self.padding*(floatCount-1))*0.5
        let y = (self.frame.size.height - self.diameter)*0.5
        var frame = CGRect(x: x, y: y, width: self.diameter, height: self.diameter)
        
        elements.forEach() { layer in
            layer.backgroundColor = self.tintColor.withAlphaComponent(self.inactiveTransparency).cgColor
            if self.borderWidth > 0 {
                layer.borderWidth = self.borderWidth
                layer.borderColor = self.tintColor.cgColor
            }
            layer.cornerRadius = self.radius
            layer.frame = frame
            frame.origin.x += self.diameter + self.padding
        }

        if let active = elements.first {
            active.backgroundColor = self.tintColor.cgColor
        }
        
        min = elements.first?.frame
        max = elements.last?.frame
        
        self.frames = elements.map { $0.frame }
    }
    
    override func update(for progress: Double) {
        guard let min = self.min,
            let max = self.max else {
                return
        }
        var progress = progress
        if progress < 0 {
            progress = 0
        }
        let total = Double(numberOfPages - 1)
        if progress > total {
            progress = total
        }
        
        let page = Int(progress)
        
        for (index, _) in self.frames.enumerated() {
            if page > index {
                self.elements[index+1].frame = self.frames[index]
            } else if page < index {
                self.elements[index].frame = self.frames[index]
            }
        }
        
        let dist = max.origin.x - min.origin.x
        let percent = CGFloat(progress / total)
        
        let offset = dist * percent
        guard let active = elements.first else { return }
        let x = min.origin.x + offset
        
        let spacePerItem = (dist+diameter+padding)/CGFloat(numberOfPages)
        let r = (spacePerItem)/2
        let yDirection: CGFloat = page%2 == 1 ? 1 : -1
        active.frame.origin.x = x
        let xBetweenPoints = x - CGFloat(page)*spacePerItem - min.origin.x
        let y = sqrt(pow(Double(r), 2) - pow(fabs(Double(r)-Double(xBetweenPoints)), 2))
        active.frame.origin.y = (y.isNaN ? 0 : CGFloat(y)*yDirection) + min.origin.y
        
        let index = page + 1
        guard elements.indices.contains(index) else {
            return
        }
        let element = elements[index]
        guard frames.indices.contains(page), frames.indices.contains(page + 1) else { return }
        
        let prev = frames[page]
        let current = frames[page + 1]
        element.frame = prev
        element.frame.origin.x += current.origin.x - active.frame.origin.x
        element.frame.origin.y = 2*min.origin.y - active.frame.origin.y
    }
    
    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: CGFloat(elements.count) * self.diameter + CGFloat(elements.count - 1) * self.padding,
                      height: self.diameter)
    }
}
