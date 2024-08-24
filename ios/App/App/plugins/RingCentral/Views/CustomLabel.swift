import Foundation
import UIKit

enum FontWeight {
    case light, medium, regular, semiBold
}

class CustomLabel: UILabel {

    var fontWeight: FontWeight = .regular {
        didSet {
            updateFont()
        }
    }
    
    var fontSize: CGFloat = 17.0 {
        didSet {
            updateFont()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Default font setup
        updateFont()
        
        // Additional common setup can go here
        self.textColor = .black
        self.backgroundColor = .clear
        self.textAlignment = .center
        self.numberOfLines = 0
    }

    private func updateFont() {
        switch fontWeight {
        case .light:
            self.font = UIFont.systemFont(ofSize: fontSize)
        case .medium:
            self.font = UIFont.systemFont(ofSize: fontSize)
        case .regular:
            self.font = UIFont.systemFont(ofSize: fontSize)
        case .semiBold:
            self.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}
