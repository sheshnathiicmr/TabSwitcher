//
//  TabSwitcherProtocol.swift
//  TabSwitcherViewDemo
//
 
//

import UIKit

@objc protocol TabSwitcherDataSource {
    
    func numberOfTabs() -> Int
    func viewForTabAtIndex(index: Int) -> UIView
    func didPressedIndex(_ indexPath:IndexPath) -> Void
}
