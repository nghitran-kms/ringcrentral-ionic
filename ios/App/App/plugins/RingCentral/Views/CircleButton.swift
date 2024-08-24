import UIKit

class CircleButton: UIButton {
    private var onImage: UIImage?
    private var offImage: UIImage?
    
    private var isOn = false
    
    init(onImageName: String, offImageName: String, buttonSize: CGFloat) {
        super.init(frame: .zero)
        
        guard let onImage = UIImage(named: onImageName) else {
            print("Image not found")
            return
        }
        
        guard let offImage = UIImage(named: offImageName) else {
            print("Image not found")
            return
        }
        
        self.onImage = onImage
        self.offImage = offImage
        self.setImage(offImage, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        self.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        self.backgroundColor = .clear
        self.layer.cornerRadius = buttonSize / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setState(_ toggled: Bool) {
        isOn = toggled
        if toggled {
            self.setImage(onImage, for: .normal)
        } else {
            self.setImage(offImage, for: .normal)
        }
    }
}
