import UIKit
import QuartzCore

extension UIView {
    func setGradientBackground(
        colors: [UIColor],
        locations: [NSNumber]? = nil,
        startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
        endPoint: CGPoint = CGPoint(x: 0.5, y: 1),
        frame: CGRect? = nil
    ) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = frame ?? self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc func show() {
        isHidden = false
    }
    
    @objc func hide() {
        isHidden = true
    }
}
