//
//  TabSwitcherView.swift
//  TabSwitcherViewDemo
//
 
//

import UIKit

class TabSwitcherView: UIView {
    
    let maxNumberOfTabs = 5
    var focusingIndex = -1
    
    private var switchingEnable = true
    var switching: Bool {
        get {
            return switchingEnable
        }
        set {
            setSwithingModeEnable(enable: newValue, fromIndex: focusingIndex)
        }
    }
    
    var collectionView: UICollectionView!
    private let layout = TabSwitcherLayout()
    weak var dataSource: TabSwitcherDataSource?
    
    private var adding = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(TabViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    // MARK: 
    
    func setSwithingModeEnable(enable: Bool, fromIndex: Int) {
        // do nothing if there is no tabs, always in swiching mode
        if dataSource?.numberOfTabs() ?? 0 < 0 {
            return
        }
        
        switchingEnable = enable
        let index = enable ? -1 : focusingIndex
        //let index = enable ? fromIndex : focusingIndex
        layout.switchToIndex(index: index)
    }

    func setSwithingModeEnableManual(enable: Bool, fromIndex: Int) {
        layout.switchToIndex(index: fromIndex)
    }
    
    func addTab() {
        adding = true
        
        if !switching {
            switching = true
        } else {
            didSwitchingToIndex(index: -1)
        }
        
    }
    
    // MARK:
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !switching {
            for cell in collectionView!.visibleCells as! [TabViewCell] {
                if collectionView!.indexPath(for: cell)?.item == focusingIndex {
                    return cell.displayView.hitTest(point, with: event)
                }
            }
        }
        return super.hitTest(point, with: event);
    }
}

// MARK: - CollectionView DataSource & Delegate

extension TabSwitcherView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = dataSource?.numberOfTabs() ?? 0
        if count == 0 {
            switchingEnable = true
        }
        focusingIndex = -1
        layout.switchToIndex(index: focusingIndex)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath as IndexPath) as! TabViewCell
                
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // print(indexPath.item)
        dataSource?.didPressedIndex(indexPath)
    }
    
}

extension TabSwitcherView: TabSwitcherLayoutDelegate {
    
    func didSwitchingToIndex(index: Int) {
        if adding && index < 0 {
            let offset = max(collectionView.contentSize.height - collectionView.bounds.size.height, 0)
            
            if offset > 0 {
                collectionView.setContentOffset(
                    CGPoint(x:0, y:offset),
                    animated: true)
            } else {
                scrollViewDidEndScrollingAnimation(collectionView)
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if adding {
            adding = false
            
            if let count = self.dataSource?.numberOfTabs(), count > 0 {
                collectionView.performBatchUpdates({ () -> Void in
                    //self.collectionView.insertItems(at: [NSIndexPath(forItem: count - 1, inSection: 0) as IndexPath])
                    self.collectionView.insertItems(at: [IndexPath(item: count - 1, section: 0)])
                }, completion: { (finished) in
                    self.layout.switchToIndex(index: count - 1)
                    self.switchingEnable = false
                    self.focusingIndex = count - 1
                })
            }
        }
    }
    
    private func collectionView(collectionView: UICollectionView,
                        didSelectItemAtIndexPath indexPath: IndexPath)
    {
        if switching {
            layout.switchToIndex(index: indexPath.item)
            switchingEnable = false
            focusingIndex = indexPath.item
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if indexPath.item == dataSource!.numberOfTabs() - 1 {
            return CGSize(width:bounds.size.width, height:bounds.size.height * 0.8)
        }
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let count = min(dataSource!.numberOfTabs(), maxNumberOfTabs)
        let height = (bounds.size.height - layout.sectionInset.top - 37) / CGFloat(count)
        return CGSize(width:bounds.size.width, height:height)
    }
    
}
