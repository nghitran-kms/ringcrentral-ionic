import UIKit

class FullScreenGradientView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure gradient background fills the entire view correctly upon layout changes
        backgroundColor = UIColor(hex: "#06A2E5")
    }
    
    func removeSelf() {
        UIView.animate(withDuration: 0.3, animations: {
            self.removeFromSuperview()
        }) { _ in }
    }
    
    override func show() {
        if self.alpha != 1 {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }
    }
    
    override func hide() {
        if self.alpha != 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
            }) { _ in }
        }
    }
}
