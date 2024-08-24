import UIKit
import rcvsdk

class VideoView: UIView {
    public var canvas: RCVideoCanvas?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .black
    }
    
    func setCanvas(_ canvas: RCVideoCanvas) {
        self.canvas = canvas
        canvas.attach(self)
    }
}
