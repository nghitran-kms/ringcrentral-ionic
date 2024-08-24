import UIKit
import rcvsdk

public class RCVMeetingDataSource {
    private static var meetingId: String?

    public static func reset() {
        meetingId = nil
    }
    
    public static func setupData(_ meetingId: String) {
        self.meetingId = meetingId
    }
    
    public static func getMeetingController() -> RcvMeetingController? {
        guard let meetingController = RcvEngine.instance().getMeetingController(self.meetingId ?? "") else {
            return nil
        }
        
        return meetingController
    }
    
    public static func getMeetingUserController() -> RcvMeetingUserController? {
        guard let meetingController = getMeetingController() else {
            return nil
        }
        
        return meetingController.getMeetingUserController()
    }
    
    public static func getAudioController() -> RcvAudioController? {
        guard let meetingController = getMeetingController() else {
            return nil
        }
        
        return meetingController.getAudioController()
    }
    
    public static func getVideoController() -> RcvVideoController? {
        guard let meetingController = getMeetingController() else {
            return nil
        }
        
        return meetingController.getVideoController()
    }
}
