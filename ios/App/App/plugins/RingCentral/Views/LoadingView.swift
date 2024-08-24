import UIKit

class LoadingView: FullScreenGradientView {
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
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        spinner.startAnimating()
        
        addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
