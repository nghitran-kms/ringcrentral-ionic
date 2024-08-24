import UIKit

class WaitingView: FullScreenGradientView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Red rectangle background view
        let rectangle = UIView()
        rectangle.backgroundColor = UIColor(hex: "#075082", alpha: 0.6) // Color with opacity
        rectangle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rectangle)
        
        // Add corner radius to make the rectangle rounded
        rectangle.layer.cornerRadius = 8
        
        // Center the rectangle in the superview (WaitingRoomView)
        NSLayoutConstraint.activate([
            rectangle.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            rectangle.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20),
            rectangle.widthAnchor.constraint(equalToConstant: 302),
            rectangle.heightAnchor.constraint(equalToConstant: 234)
        ])
        
        // Create a UIImageView for the GIF
        let gifImageView = UIImageView()
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        gifImageView.contentMode = .scaleAspectFit // Adjust content mode as needed
        rectangle.addSubview(gifImageView)
        
        // Constraints for the GIF image view
        NSLayoutConstraint.activate([
            gifImageView.topAnchor.constraint(equalTo: rectangle.topAnchor, constant: 20),
            gifImageView.centerXAnchor.constraint(equalTo: rectangle.centerXAnchor),
            gifImageView.widthAnchor.constraint(equalToConstant: 98),
            gifImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // Create a UILabel for the message
        let messageLabel = CustomLabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        messageLabel.text = "Waiting for your provider to join..."
        messageLabel.numberOfLines = 0
        rectangle.addSubview(messageLabel)
        
        // Constraints for the message label
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: gifImageView.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: rectangle.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: rectangle.trailingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(equalTo: rectangle.bottomAnchor, constant: -10)
        ])
    }
}
