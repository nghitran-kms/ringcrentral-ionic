import UIKit
import rcvsdk

class LocalVideoView: UIView {
    // MARK: - UI Elements
    public let video: UIView = UIView()
    public let loading: UIView = UIView()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Setup UI
    private func setupView() {
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .black
        translatesAutoresizingMaskIntoConstraints = false
        
        /* Define UI Elements */
        video.translatesAutoresizingMaskIntoConstraints = false
        addSubview(video)
        
        loading.backgroundColor = .clear
        loading.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loading)
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        spinner.startAnimating()
        
        loading.addSubview(spinner)
        
        /* Setup contraints */
        NSLayoutConstraint.activate([
            video.topAnchor.constraint(equalTo: topAnchor),
            video.leadingAnchor.constraint(equalTo: leadingAnchor),
            video.trailingAnchor.constraint(equalTo: trailingAnchor),
            video.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            loading.topAnchor.constraint(equalTo: topAnchor),
            loading.leadingAnchor.constraint(equalTo: leadingAnchor),
            loading.trailingAnchor.constraint(equalTo: trailingAnchor),
            loading.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: loading.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: loading.centerYAnchor)
        ])
    }
    
    public func updateLocalVideoCanvas(_ user: RcvIParticipant) {
        let uuid = user.getModelId()
        let canvas = RCVideoCanvas(view: nil, uid: uuid)
        let videoController = RCVMeetingDataSource.getVideoController()
        let audioController = RCVMeetingDataSource.getAudioController()
        
        canvas?.setRenderMode(.fill)
        canvas?.mirrorMode = true
        canvas?.attach(video)
        
        videoController?.setupLocalVideo(canvas)
        videoController?.muteLocalVideoStream()
        audioController?.muteLocalAudioStream()
        audioController?.enableSpeakerphone()
    }
}
