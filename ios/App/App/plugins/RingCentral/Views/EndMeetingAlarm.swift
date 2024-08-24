import UIKit

class EndMeetingAlarm: UIView {
    let timeLabel: CustomLabel = {
        let label = CustomLabel()
        label.text = "Your call is about to reach the end of scheduled time."
        label.textAlignment = .center
        label.textColor = .white
        label.fontSize = 14
        label.numberOfLines = 0 // Enable text wrapping
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 4
        layer.masksToBounds = true
        backgroundColor = UIColor(hex: "#000000", alpha: 0.5) // Color with opacity

        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Center the label inside the view
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Add minimum padding around the label
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            timeLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8),
            timeLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
        ])
        
        hide()
    }
}
