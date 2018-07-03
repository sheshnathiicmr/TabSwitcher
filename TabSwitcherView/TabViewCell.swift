//
//  TabViewCell.swift
//  TabSwitcherViewDemo
//
 
//

import UIKit

class TabViewCell: UICollectionViewCell {

    let displayView: UIView
    let gradientView: UIView
    
    private var currentTransform: CATransform3D?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        displayView = UIView(frame: CGRect(x:0, y:0,
                                           width:UIScreen.main.bounds.size.width,
                                           height:UIScreen.main.bounds.size.height))
        gradientView = UIView(frame: displayView.bounds)
        
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.clear
        
        displayView.backgroundColor = UIColor.white
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        displayView.layer.frame = displayView.bounds
        
        contentView.addSubview(displayView)
        setAnchorPoint(anchorPoint: CGPoint(x:0.5, y:0), forView: displayView)
        
        // test button
        let button = UIButton(frame: CGRect(x:200, y:50, width:100, height:50))
        button.setTitle("test", for: .normal)
        button.addTarget(self, action: Selector(("test")), for: UIControlEvents.touchUpInside)
        displayView.addSubview(button)
        
        // setup gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = displayView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientView.layer.addSublayer(gradientLayer)
        displayView.addSubview(gradientView)
        
        // add motion effect
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.transform",
                                                               type: .tiltAlongVerticalAxis)
        
        var tranformMinRelative = CATransform3DIdentity
        tranformMinRelative = CATransform3DRotate(tranformMinRelative, CGFloat(Double.pi / 10), 1, 0, 0);
        
        var tranformMaxRelative = CATransform3DIdentity
        tranformMaxRelative = CATransform3DRotate(tranformMaxRelative, CGFloat(-Double.pi / 10), 1, 0, 0);
        
        //NSValue(caTransform3D:CATransform3DMakeScale(10.0, 10.0, 1.0))

        
        verticalMotionEffect.minimumRelativeValue = NSValue(caTransform3D: tranformMinRelative)
        verticalMotionEffect.maximumRelativeValue = NSValue(caTransform3D: tranformMaxRelative)
        
        displayView.addMotionEffect(verticalMotionEffect)
        
        // add pan gesture
        let gesture = UIPanGestureRecognizer(target: self, action: Selector(("handlePan:")))
        gesture.delegate = self
        displayView.addGestureRecognizer(gesture)
    }
    
    func test() {
        print("test")
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .changed:
            let translation = recognizer.translation(in: displayView)
            let transform = displayView.layer.transform
            displayView.layer.transform = CATransform3DTranslate(transform, translation.x, 0, 0)
            recognizer.setTranslation(CGPoint.zero, in: displayView)
            
        case .cancelled, .ended:
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                if let transform = self.currentTransform {
                    self.displayView.layer.transform = transform
                }
            })
        default: break
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        if let attr = layoutAttributes as? TabSwitcherLayoutAttributes {
            displayView.layer.transform = attr.displayTransform
            currentTransform = attr.displayTransform
        }
    }
    
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPoint(x:view.bounds.size.width * anchorPoint.x,
                               y:view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x:view.bounds.size.width * view.layer.anchorPoint.x,y:
            view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
}

extension TabViewCell: UIGestureRecognizerDelegate {
    
    // fix hard to scroll vertically
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: displayView)
            return fabs(velocity.x) > fabs(velocity.y);
        }
        return true
    }
    
}
