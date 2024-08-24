import UIKit
import AVKit
import rcvsdk
import CallKit

class MeetingViewController: UIViewController {
    // MARK: - Properties
    private let meetingId: String
    private let apptEndTime: Date
    private let userName: String
    private var isManualLeave: Bool = false
    private var hasBeenInBackground: Bool = false
    private var workItemEndMeetingAlarm: DispatchWorkItem?
    private let callObserver = CXCallObserver()
    public var onDismiss: ((Bool) -> Void)?
    public var onError: ((String) -> Void)?
    
    /** Event Handlers */
    private var engineEventHandler: RcvEngineEventHandler?
    private var meetingEventHandler: RcvMeetingEventHandler?
    private var meetingUserEventHandler: RcvMeetingUserEventHandler?
    private var meetingStatisticEventHandler: RcvMeetingStatisticEventHandler?
    private var audioEventHandler: RcvAudioEventHandler?
    private var videoEventHandler: RcvVideoEventHandler?
    
    // MARK: - UI Elements
    private var meetingView: MeetingView = MeetingView()
    
    // MARK: - View Lifecycle
    init(_ meetingId: String, _ apptEndTime: Date, _ userName: String) {
        self.meetingId = meetingId
        self.apptEndTime = apptEndTime
        self.userName = userName
        super.init(nibName: nil, bundle: nil)
        callObserver.setDelegate(self, queue: nil)
        RCVMeetingDataSource.setupData(meetingId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwipeGesture()
        setupEngineEventHandler()
        setupUI()
        setupEndMeetingAlarm()
        setupObservers()
        joinMeeting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        workItemEndMeetingAlarm?.cancel()
        RCVMeetingDataSource.reset()
        UsersUtils.reset()
        unregisterEventHandlers()
    }
    
    // MARK: - Gesture Recognizer Setup
    private func setupSwipeGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        leaveMeeting()
    }
    
    // MARK: - Request Access
    private func setupRequestAccess() {
        AVCaptureDevice.requestAccess(for: .audio) { response in }
        AVCaptureDevice.requestAccess(for: .video) { response in }
    }
    
    // MARK: - Setup Engine Event Handler
    private func setupEngineEventHandler() {
        engineEventHandler = EngineEventHandler(delegate: self)
        RcvEngine.instance().register(engineEventHandler)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#00111A")
        view.addSubview(meetingView)
        
        guard let videoBtn = meetingView.videoBtn, let micBtn = meetingView.micBtn, let leaveBtn = meetingView.leaveBtn else { return }
        
        videoBtn.addTarget(self, action: #selector(toggleVideoButtonTap), for: .touchUpInside)
        micBtn.addTarget(self, action: #selector(toggleMicButtonTap), for: .touchUpInside)
        leaveBtn.addTarget(self, action: #selector(leaveButtonTap), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            meetingView.topAnchor.constraint(equalTo: view.topAnchor),
            meetingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            meetingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            meetingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Setup Alarm
    private func setupEndMeetingAlarm() {
        let alarmInterval: TimeInterval = 5 * 60 // 5 minutes
        let timeInterval = apptEndTime.timeIntervalSince(Date())
        
        guard timeInterval > 0 else {
            meetingView.endMeetingAlarm.show()
            return
        }
        
        let delay = max(timeInterval - alarmInterval, 0)
        workItemEndMeetingAlarm = DispatchWorkItem { [weak self] in
            self?.meetingView.endMeetingAlarm.show()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItemEndMeetingAlarm!)
    }
    
    // MARK: - Setup Observers
    private func setupObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc private func handleDidEnterBackground() {
        hasBeenInBackground = true
        leaveMeeting()
    }
    
    @objc private func handleWillEnterForeground() {
        dismissView()
    }
    
    @objc private func handleWillTerminate() {
        leaveMeeting()
    }
    
    // MARK: - Register RingCentral event
    private func registerEventHandlers() {
        self.meetingEventHandler = MeetingEventHandler(delegate: self)
        self.meetingUserEventHandler = MeetingUserEventHandler(delegate: self)
        self.meetingStatisticEventHandler = MeetingStatisticEventHandler(delegate: self)
        self.audioEventHandler = AudioEventHandler(delegate: self)
        self.videoEventHandler = VideoEventHandler(delegate: self)
        
        guard let meetingController = RCVMeetingDataSource.getMeetingController(),
              let meetingUserController = RCVMeetingDataSource.getMeetingUserController(),
              let audioController = RCVMeetingDataSource.getAudioController(),
              let videoController = RCVMeetingDataSource.getVideoController() else {return}
        
        meetingController.register(self.meetingEventHandler)
        meetingController.register(self.meetingStatisticEventHandler)
        meetingUserController.register(self.meetingUserEventHandler)
        audioController.register(self.audioEventHandler)
        videoController.register(self.videoEventHandler)
    }
    
    private func unregisterEventHandlers() {
        guard let meetingController = RCVMeetingDataSource.getMeetingController(),
              let audioController = RCVMeetingDataSource.getAudioController(),
              let videoController = RCVMeetingDataSource.getVideoController() else {return}
        
        meetingController.unregisterEventHandler(self.meetingEventHandler)
        audioController.unregisterEventHandler(self.audioEventHandler)
        videoController.unregisterEventHandler(self.videoEventHandler)
    }
    
    // MARK: - User Actions
    @objc func toggleVideoButtonTap() {
        guard let videoController = RCVMeetingDataSource.getVideoController(),
              let videoBtn = meetingView.videoBtn else { return }
        
        let permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch permissionStatus {
        case .authorized:
            let isMuted = videoController.isMuted()
            if isMuted {
                videoController.unmuteLocalVideoStream()
                videoBtn.setState(true)
            } else {
                videoController.muteLocalVideoStream()
                videoBtn.setState(false)
            }
        case .denied, .restricted:
            showAlert(title: "Camera Access Denied", message: "Camera access is denied. Please enable it in the device settings.")
        default:
            break
        }
    }
    
    @objc func toggleMicButtonTap() {
        guard let audioController = RCVMeetingDataSource.getAudioController(),
              let micBtn = meetingView.micBtn else { return }
        
        let permissionStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch permissionStatus {
        case .authorized:
            let isMuted = audioController.isMuted()
            if isMuted {
                audioController.unmuteLocalAudioStream()
                micBtn.setState(true)
            } else {
                audioController.muteLocalAudioStream()
                micBtn.setState(false)
            }
        case .denied, .restricted:
            showAlert(title: "Microphone Access Denied", message: "Microphone access is denied. Please enable it in the device settings.")
        default:
            break
        }
    }
    
    @objc func leaveButtonTap() {
        isManualLeave = true;
        leaveMeeting()
    }
    
    // MARK: - Meeting Actions
    public func joinMeeting() {
        let opt = RcvMeetingOptions.create()
        opt?.setUserName(userName)
        RcvEngine.instance().joinMeeting(meetingId, options: opt!)
    }
    
    func leaveMeeting() {
        if let meetingController = RCVMeetingDataSource.getMeetingController() {
            meetingController.leaveMeeting()
        } else {
            dismissView()
        }
    }
    
    // MARK: - Handle dismiss
    func dismissView(error: String? = nil, completion: (() -> Void)? = nil) {
        super.dismissFromLeftToRight() { [weak self] in
            if error != nil {
                self?.onError?(error ?? "")
            } else {
                let manualLeave = self?.isManualLeave ?? false
                self?.onDismiss?(manualLeave)
            }
            completion?()
        }
    }
}

extension MeetingViewController: RcvEngineEventHandler {
    func onAuthorization(_ newTokenJsonStr: String) {}
    
    func onAuthorizationError(_ errorCode: Int64) {}
    
    func onMeetingBridge(_ info: RcvMeetingBridgeInfo?) {}
    
    func onAuthTokenRenew(_ errorCode: Int64, newTokenJsonStr: String) {
        if(RcvErrorCodeType.errOk != RcvEngine.getErrorType(errorCode)) {
            leaveMeeting()
            dismissView(error: "The authorization token renewal failed.")
        }
        
    }
    
    func onMeetingJoin(_ meetingId: String, errorCode: Int64) {
        let errorType = RcvEngine.getErrorType(errorCode)
        
        guard errorType == RcvErrorCodeType.errOk, !meetingId.isEmpty else {
            // Handle meeting join failure (e.g., log or show an alert)
            var errorMessage: String = ""
            switch (errorType) {
            case .errNeedPassword:
                errorMessage = "Meeting password required. Unable to join the meeting without it."
            case .errInWaitingRoom:
                errorMessage = "You are currently in the waiting room. Access will be granted once the meeting host admits you."
            case .errWaitingHostJoinFirst:
                errorMessage = "Unable to join. Please wait for the meeting host to start the meeting."
            case .errDeniedFromWaitingRoom:
                errorMessage = "Access denied. The meeting host has denied your request to join."
            default:
                errorMessage = "Failed to join the meeting. Please try again later."
            }
            dismissView(error: errorMessage)
            return
        }
        
        setupRequestAccess()
        registerEventHandlers()
        
        meetingView.loadingView.hide()
        meetingView.waitingView.show()
        
        let userList = UsersUtils.getUserList()
        for (_, user) in userList {
            if(user.isMe()) {
                /** Setting up local video view*/
                meetingView.updateLocalVideoCanvas(user)
            } else if user.status() == .ACTIVE {
                /** Setting up remote video view*/
                meetingView.addNewRemoteUser(user)
            }
        }
        
        if let uuid = UsersUtils.getNextActiveRemoteUser()?.getModelId() {
            meetingView.showRemoteVideoById(uuid)
            meetingView.waitingView.hide()
        }
    }
    
    func onMeetingLeave(_ meetingId: String, errorCode: Int64, reason: RcvLeaveReason) {
        var errorMessage: String? = nil
        switch (reason) {
        case .removeByHost:
            errorMessage = "You have been removed from the meeting by the host."
        case .endByHost:
            errorMessage = "The host has ended the meeting."
        case .endByConnectionBroken:
            errorMessage = "The meeting ended due to a broken connection."
        case .endForTimeLimit:
            errorMessage = "The meeting ended due to exceeding the time limit."
        case .deniedFromWaitingRoom:
            errorMessage = "Access denied. The meeting host has denied your request to join."
        default:
            errorMessage = nil
        }
        
        dismissView(error: errorMessage)
    }
    
    func onMeetingStateChanged(_ meetingId: String, state: RcvMeetingState) {
    }
    
    func onAuthTokenError(_ errorCode: Int64) {
    }
    
    func onMeetingSchedule(_ errorCode: Int64, settings: RcvScheduleMeetingSettings?) {
    }
    
    func onPersonalMeetingSettingsUpdate(_ errorCode: Int64, settings: RcvPersonalMeetingSettings?) {
    }
}

extension MeetingViewController: RcvMeetingUserEventHandler {
    func onLocalDialStateChanged(_ id: String, callerId: String, number: String, status: RcvCallPhoneStatus, deleted: Bool) {}
    
    func onCallOut(_ id: String, errorCode: Int64) {}
    
    func onDeleteDial(_ errorCode: Int64) {}
    
    func onActiveSpeakerUserChanged(_ participant: RcvIParticipant?) {
        guard let user = participant, !user.isMe(), user.status() == .ACTIVE else { return }
        let uuid = user.getModelId()
        if let activeRemoteId = meetingView.activeRemoteId,
           let activeUser = UsersUtils.getUserById(activeRemoteId),
           uuid == activeRemoteId || activeUser.isSpeaking() {
            return
        }
        meetingView.showRemoteVideoById(uuid)
    }
    
    func onActiveVideoUserChanged(_ participant: RcvIParticipant?) {
    }
    
    func onUserJoined(_ participant: RcvIParticipant?) {
        guard let user = participant else { return }
        meetingView.addNewRemoteUser(user)
        meetingView.waitingView.hide()
    }
    
    func onUserUpdated(_ participant: RcvIParticipant?) {
        guard let user = participant else { return }
        if let remoteVideo = meetingView.remoteVideoViews[user.getModelId()] {
            if remoteVideo.speakerDisplayName.text != user.displayName(){
                remoteVideo.speakerDisplayName.text = user.displayName()
            }
            if remoteVideo.avatarText.text !=  user.getInitialsAvatarName() {
                remoteVideo.avatarText.text = user.getInitialsAvatarName()
            }
        } else if !user.isMe() && user.status() == .ACTIVE {
            meetingView.addNewRemoteUser(user)
            meetingView.waitingView.hide()
        }
    }
    
    func onUserLeave(_ participant: RcvIParticipant?) {
        guard let user = participant  else { return }
        let uuid = user.getModelId()
        meetingView.removeRemoteUser(uuid)
        if UsersUtils.isEmptyRoom() {
            meetingView.waitingView.show()
        } else if let nextVideoId = UsersUtils.getNextActiveRemoteUser()?.getModelId() {
            meetingView.showRemoteVideoById(nextVideoId)
        }
    }
    
    func onUserRoleChanged(_ participant: RcvIParticipant?) {
    }
    
    func onLocalNetworkQuality(_ state: RcvNqiState) {
    }
    
    func onRemoteNetworkQuality(_ participant: RcvIParticipant?, state: RcvNqiState) {
    }
}

extension MeetingViewController: RcvVideoEventHandler {
    func onLocalVideoMuteChanged(_ muted: Bool) {
        let video = meetingView.localVideoView
        if muted {
            video.hide()
        } else {
            video.loading.show()
            video.show()
        }
    }
    
    func onRemoteVideoMuteChanged(_ participant: RcvIParticipant?, muted: Bool) {
        guard let user = participant  else { return }
        if let remoteVideo = meetingView.remoteVideoViews[user.getModelId()] {
            if muted {
                remoteVideo.avatar.show()
            }
        }
    }
    
    func onUnmuteVideoDemand() {
    }
    
    func onFirstLocalVideoFrame(_ width: Int32, height: Int32, elapsed: Int32) {
        let video = meetingView.localVideoView
        video.loading.hide()
    }
    
    func onFirstRemoteVideoFrame(_ participant: RcvIParticipant?, width: Int32, height: Int32, elapsed: Int32) {
        guard let user = participant  else { return }
        if let remoteVideo = meetingView.remoteVideoViews[user.getModelId()] {
            remoteVideo.avatar.hide()
        }
    }
}

extension MeetingViewController: RcvAudioEventHandler {
    func onLocalAudioStreamStateChanged(_ state: RcvLocalAudioStreamState, error: RcvLocalAudioError) {
    }
    
    func onLocalAudioMuteChanged(_ muted: Bool) {
    }
    
    func onRemoteAudioMuteChanged(_ participant: RcvIParticipant?, muted: Bool) {
    }
    
    func onUnmuteAudioDemand() {
    }
    
    func onAudioRouteChanged(_ audioRouteType: RcvAudioRouteType) {
    }
}

extension MeetingViewController: RcvMeetingStatisticEventHandler {
    func onLocalAudioStats(_ stats: RcvLocalAudioStats?) {
        return
    }
    
    func onLocalVideoStats(_ stats: RcvLocalVideoStats?) {
        return
    }
    
    func onRemoteAudioStats(_ stats: RcvRemoteAudioStats?) {
        return
    }
    
    func onRemoteVideoStats(_ stats: RcvRemoteVideoStats?) {
        return
    }
}

extension MeetingViewController: RcvMeetingEventHandler {
    func onLiveTranscriptionDataChanged(_ data: RcvLiveTranscriptionData?, type: RcvLiveTranscriptionDataType) {
        return
    }
    
    func onLiveTranscriptionSettingChanged(_ data: RcvLiveTranscriptionSetting?) {
        return
    }
    
    func onLiveTranscriptionHistoryChanged(_ data: [RcvLiveTranscriptionData]) {
        return
    }
    
    func onMeetingStateChanged(_ state: RcvMeetingState) {
        return
    }
    
    func onRecordingStateChanged(_ state: RcvRecordingState) {
        return
    }
    
    func onRecordingAllowChanged(_ allowed: Bool) {
        return
    }
    
    func onMeetingApiExecuted(_ method: String, errorCode: Int64, result: RcvMeetingApiExecuteResult) {
        return
    }
    
    func onMeetingLockStateChanged(_ locked: Bool) {
        return
    }
    
    func onMeetingEncryptionStateChanged(_ state: RcvEndToEndEncryptionState) {
        return
    }
    
    func onChatMessageSend(_ messageId: Int32, errorCode: Int64) {
        return
    }
    
    func onChatMessageReceived(_ meetingChatMessage: [RcvMeetingChatMessage]) {
        return
    }
    
    func onClosedCaptionsData(_ data: [RcvClosedCaptionsData]) {
        return
    }
    
    func onClosedCaptionsStateChanged(_ state: RcvClosedCaptionsState) {
        return
    }
}

// MARK: - CXCallObserverDelegate
extension MeetingViewController: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if !call.hasEnded && !call.isOutgoing && call.hasConnected && !call.isOnHold {
            // Handle incoming call connected
            DispatchQueue.main.async {
                self.leaveMeeting()
            }
        }
    }
}
