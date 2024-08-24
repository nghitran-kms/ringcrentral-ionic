import UIKit
import rcvsdk

class RemoteVideoView: UIView {
    // MARK: - Properties
    public var uuid: Int64
    
    // MARK: - UI Elements
    public let video: UIView = UIView()
    public let speakerDisplayName: CustomLabel =  CustomLabel()
    public let avatar: UIView = UIView()
    public let avatarText: CustomLabel = CustomLabel()
    
    // MARK: - Initializers
    init(uuid: Int64) {
        self.uuid = uuid
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupViews() {
        setupCanvasVideo()
        setupUI()
    }

    private func setupCanvasVideo() {
        /* Attach video canvas to view */
        let canvas = RCVideoCanvas(view: nil, uid: uuid)
        
        let videoController = RCVMeetingDataSource.getVideoController()

        canvas?.setRenderMode(.fill)
        canvas?.mirrorMode = true
        canvas?.attach(video)
        
        videoController?.setupRemoteVideo(canvas)
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        /* Define UI Elements */
        let user = UsersUtils.getUserById(uuid)
        
        /** speakerNameText  */
        speakerDisplayName.translatesAutoresizingMaskIntoConstraints = false
        speakerDisplayName.text = user?.displayName() ?? "??"
        speakerDisplayName.textAlignment = .center
        speakerDisplayName.font = UIFont.systemFont(ofSize: 20)
        speakerDisplayName.textColor = .white
        addSubview(speakerDisplayName)
        
        /** videoView  */
        video.translatesAutoresizingMaskIntoConstraints = false
        addSubview(video)
        
        /** avatarView  */
        avatar.backgroundColor = UIColor(hex: "#00111A")
        avatar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatar)

        /** avatarImageView  */
        let avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.layer.masksToBounds = true
        avatarImageView.backgroundColor = UIColor(hex: "#005db2")
        avatar.addSubview(avatarImageView)
        
        /** avatarText  */
        avatarText.textColor = .white
        avatarText.text = user?.getInitialsAvatarName() ?? "??"
        avatarText.font =  UIFont.systemFont(ofSize: 24)
        avatarText.textAlignment = .center
        avatarText.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(avatarText)

        
        /* Setup contraints */
        NSLayoutConstraint.activate([
            // Constraints for speakerNameText
            speakerDisplayName.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            speakerDisplayName.leadingAnchor.constraint(equalTo: leadingAnchor),
            speakerDisplayName.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Constraints for videoView
            video.topAnchor.constraint(equalTo: speakerDisplayName.bottomAnchor, constant: 16),
            video.leadingAnchor.constraint(equalTo: leadingAnchor),
            video.trailingAnchor.constraint(equalTo: trailingAnchor),
            video.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Constraints for avatar
            avatar.topAnchor.constraint(equalTo: speakerDisplayName.bottomAnchor, constant: 16),
            avatar.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatar.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatar.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Constraints for avatarImageView
            avatarImageView.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Constraints for avatarText
            avatarText.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            avatarText.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            avatarText.widthAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            avatarText.heightAnchor.constraint(equalTo: avatarImageView.heightAnchor)
        ])
    }
}
