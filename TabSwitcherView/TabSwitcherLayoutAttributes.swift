//
//  TabSwitcherLayoutAttributes.swift
//  TabSwitcherViewDemo
//
 
//

import UIKit

class TabSwitcherLayoutAttributes: UICollectionViewLayoutAttributes {

    var displayTransform: CATransform3D = CATransform3DIdentity
    
    override func copy(with zone: NSZone? = nil) -> Any {
        //let copy = super.copyWithZone(zone) as! TabSwitcherLayoutAttributes
        let copy = super.copy(with: zone) as! TabSwitcherLayoutAttributes
        copy.displayTransform = displayTransform
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        let attr = object as! TabSwitcherLayoutAttributes
        return super.isEqual(object) &&
            CATransform3DEqualToTransform(displayTransform, attr.displayTransform)
    }
    
    
    
}
