<div align="center">
    <h3>RingCentral Ionic Integration Code Walkthrough for iOS</h3>
    <p>A detailed explanation of how RingCentral is used in iOS</p>
</div>

This document focuses on the primary aspects of integrating the RingCentral Native iOS SDK.

## [RingCentralPlugin.swift](../ios/App/App/plugins/RingCentral/RingCentralPlugin.swift)

- `initRingCentral`: receive in clientId and clientSecret to create a RcvEngine instance
- `joinMeeting`: receive meetingId to open the native UIViewController `MeetingViewController`

## [MeetingViewController.swift](../ios/App/App/plugins/RingCentral/ViewControllers/MeetingViewController.swift)

- This `UIViewController` will display a `UIView` called [MeetingView.swift](../ios/App/App/plugins/RingCentral/Views/MeetingView.swift).
- In `viewDidLoad()`, it triggers `RcvEngine.instance().joinMeeting(opt)` using the provided meetingId.
- When the `onMeetingJoin` event is triggered and join meeting successfully, it connects the audio and video of both local and remote participants to the MeetingView elements. 
  
    ```swift
    func onMeetingJoin(_ meetingId: String, errorCode: Int64) {
        let errorType = RcvEngine.getErrorType(errorCode)
        
        guard errorType == RcvErrorCodeType.errOk, !meetingId.isEmpty else {
            // Handle meeting join failure (e.g., log or show an alert)
        }
        // (...other setup)
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
    ```

## [LocalVideoView.swift](../ios/App/App/plugins/RingCentral/Views/LocalVideoView.swift)

The `MeetingViewController` can interact with the local video through the `localVideoView` variable defined in `MeetingView.swift`.
To set up the local video, the method `LocalVideoView.updateLocalVideoCanvas(:user)` is triggered.

```swift
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
```
Functionality Overview:
- This function creates a RCVideoCanvas with the local user's ID and attaches it to a UIView to display the local camera view.
- It connects the audio stream to the remote server and enables the meeting audio to broadcast to the speakerphone (note: this feature is currently unstable).

> **Note:** There is only one instance of `LocalVideoView` in `MeetingView`, as there can only be one local user in the meeting at any given time.

## [RemoteVideoView](../ios/App/App/plugins/RingCentral/Views/RemoteVideoView.swift)

### `MeetingViewController` Interaction with `RemoteVideoView`:

The `MeetingViewController` interacts with multiple `RemoteVideoView` instances through the `remoteVideoStackView` and `remoteVideoViews` variables defined in [MeetingView.swift](../ios/App/App/plugins/RingCentral/Views/MeetingView.swift).
- The relevant variables are:
```swift
public var remoteVideoViews: [Int64: RemoteVideoView] = [:]
public let remoteVideoStackView: UIView = UIView()
```
- All `RemoteVideoView` instances are stacked onto `remoteVideoStackView`, and only the avatar or video of the active remote user is displayed at any given time.

### Remote Video Event Handling:
The system tracks and manages remote video events, including:
- `onMeetingJoin`: Adds all currently active, non-local videos in the meeting to remoteVideoViews and remoteVideoStackView.
- `onUserJoined`: Adds the newly joined user's video to the remote videos collection.
- `onUserUpdated`: Updates the user in the collection if their status changes to .ACTIVE.
- `onUserLeave`: Removes the remote user's video when they leave the meeting.

### Remote Video Setup:
A RCVideoCanvas is created when initializing a RemoteVideoView with a user ID. This triggers RcvVideoController.setupRemoteVideo(:RcvVideoCanvas) to complete the remote video setup.

### Managing the Display of Remote Videos:

The system shows one remote video at a time. The conditions that cause a change in the displayed remote video are:
- `onMeetingJoin`: When the user joins a meeting room that is not empty, the first active user's video is shown.
- `onActiveSpeakerUserChanged`: The video of the current active speaker is displayed.
- `onUserLeave`: If the current active user leaves the meeting, the next active remote user's video is shown.
- `onUserJoined`: If a previously empty meeting is joined by a new remote user, their video is displayed.