import UIKit
import rcvsdk

class MeetingView: UIView {
    // MARK: - Properties
    public var activeRemoteId: Int64?
    
    // MARK: - UI Elements
    public var remoteVideoViews: [Int64: RemoteVideoView] = [:]
    public let remoteVideoStackView: UIView = UIView()
    public var loadingView: LoadingView = LoadingView()
    public var waitingView: WaitingView = WaitingView()
    public var videoBtn: CircleButton?
    public var micBtn: CircleButton?
    public var leaveBtn: CircleButton?
    public let localVideoView: LocalVideoView = LocalVideoView()
    public let endMeetingAlarm: EndMeetingAlarm = EndMeetingAlarm()
    
    // MARK: - Initialization
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
        translatesAutoresizingMaskIntoConstraints = false
        setupRemoteActiveVideoView()
        setupWaitingView()
        setupEndMeetingAlarm()
        setupLocalVideoView()
        setupToolbarButtons()
        setupLoadingView()
    }
    
    private func setupRemoteActiveVideoView() {
        remoteVideoStackView.backgroundColor = .black
        remoteVideoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(remoteVideoStackView)
        
        let screenHeight = UIScreen.main.bounds.height
        let remoteVideoHeight = 0.75 * screenHeight
        
        NSLayoutConstraint.activate([
            remoteVideoStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            remoteVideoStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            remoteVideoStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            remoteVideoStackView.heightAnchor.constraint(equalToConstant: remoteVideoHeight)
        ])
    }
    
    private func setupWaitingView() {
        addSubview(waitingView)
        NSLayoutConstraint.activate([
            waitingView.topAnchor.constraint(equalTo: topAnchor),
            waitingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            waitingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            waitingView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupEndMeetingAlarm() {
        addSubview(endMeetingAlarm)
        NSLayoutConstraint.activate([
            endMeetingAlarm.centerXAnchor.constraint(equalTo: centerXAnchor),
            endMeetingAlarm.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 70),
            endMeetingAlarm.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            endMeetingAlarm.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }
    
    private func setupLoadingView() {
        addSubview(loadingView)
        loadingView.show()
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupLocalVideoView() {
        addSubview(localVideoView)
        
        let rectangleHeight: CGFloat = UIScreen.main.bounds.height * 0.21
        let rectangleWidth: CGFloat = rectangleHeight * 3 / 4
        let bottomMargin: CGFloat = UIScreen.main.bounds.height * 0.06 + 60
        
        NSLayoutConstraint.activate([
            localVideoView.widthAnchor.constraint(equalToConstant: rectangleWidth),
            localVideoView.heightAnchor.constraint(equalToConstant: rectangleHeight),
            localVideoView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            localVideoView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -bottomMargin),
        ])
        
        localVideoView.hide()
    }
    
    private func setupToolbarButtons() {
        let buttonSize: CGFloat = UIScreen.main.bounds.height * 0.06
        
        // Create buttons using CircleButton with the constant button size
        self.videoBtn = CircleButton(onImageName: "camera-on.svg", offImageName: "camera-off.svg", buttonSize: buttonSize)
        self.micBtn = CircleButton(onImageName: "speaker-on.svg", offImageName: "speaker-off.svg", buttonSize: buttonSize)
        self.leaveBtn = CircleButton(onImageName: "leave.svg", offImageName: "leave.svg", buttonSize: buttonSize)
        
        guard let videoBtn = self.videoBtn, let micBtn = self.micBtn, let leaveBtn = self.leaveBtn else { return }
        
        addSubview(videoBtn)
        addSubview(micBtn)
        addSubview(leaveBtn)
        
        NSLayoutConstraint.activate([
            videoBtn.topAnchor.constraint(equalTo: remoteVideoStackView.bottomAnchor, constant: 16),
            micBtn.topAnchor.constraint(equalTo: remoteVideoStackView.bottomAnchor, constant: 16),
            leaveBtn.topAnchor.constraint(equalTo: remoteVideoStackView.bottomAnchor, constant: 16),
            
            videoBtn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            micBtn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            leaveBtn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            micBtn.leadingAnchor.constraint(equalTo: videoBtn.trailingAnchor, constant: 32),
            leaveBtn.leadingAnchor.constraint(equalTo: micBtn.trailingAnchor, constant: 32),
            
            videoBtn.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            leaveBtn.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
            
            micBtn.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    // MARK: - External Handlers
    public func updateLocalVideoCanvas(_ user: RcvIParticipant) {
        localVideoView.updateLocalVideoCanvas(user)
        
        videoBtn?.setState(false)
        micBtn?.setState(false)
        
    }
    
    public func addNewRemoteUser(_ user: RcvIParticipant) {
        UsersUtils.updateRemoteUser(user)
        let uuid = user.getModelId()
        let remoteVideoView = RemoteVideoView(uuid: uuid)
        remoteVideoViews.updateValue(remoteVideoView, forKey: uuid)
        remoteVideoStackView.addSubview(remoteVideoView)

        NSLayoutConstraint.activate([
            remoteVideoView.topAnchor.constraint(equalTo: remoteVideoStackView.topAnchor),
            remoteVideoView.bottomAnchor.constraint(equalTo: remoteVideoStackView.bottomAnchor),
            remoteVideoView.leadingAnchor.constraint(equalTo: remoteVideoStackView.leadingAnchor),
            remoteVideoView.trailingAnchor.constraint(equalTo: remoteVideoStackView.trailingAnchor)
        ])
        
        if UsersUtils.doesRoomHaveUsers(n: 1) {
            showRemoteVideoById(uuid)
        }
    }
    
    public func removeRemoteUser(_ uuid: Int64) {
        remoteVideoViews[uuid]?.removeFromSuperview()
        UsersUtils.removeRemoteUser(uuid)
    }
    
    public func showRemoteVideoById(_ uuid: Int64) {
        for (key, video) in remoteVideoViews {
            if key == uuid {
                activeRemoteId = uuid
                video.show()
            } else {
                video.hide()
            }
        }
    }
}
