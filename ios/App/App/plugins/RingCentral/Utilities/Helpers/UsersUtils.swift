import Foundation
import rcvsdk

public class UsersUtils {
    public static var remoteUsers: [Int64: RcvIParticipant] = [:]
    
    public static func reset() {
        remoteUsers.removeAll()
    }
    
    public static func getMyself() -> RcvIParticipant? {
        return RCVMeetingDataSource.getMeetingUserController()?.getMyself()
    }
    
    public static func getUserList() -> [NSNumber : RcvIParticipant]  {
        return RCVMeetingDataSource.getMeetingUserController()?.getMeetingUserList() ?? [:]
    }
    
    public static func getRemoteUserList() -> [NSNumber : RcvIParticipant]  {
        return getUserList().filter { !$0.value.isMe() && $0.value.status() == .ACTIVE }
    }
    
    public static func getSavedRemoteUserList() -> [Int64: RcvIParticipant] {
        return remoteUsers
    }
    
    public static func isEmptyRoom() -> Bool {
        return remoteUsers.count == 0
    }
    
    public static func doesRoomHaveUsers(n: Int) -> Bool {
        return remoteUsers.count == n
    }
    
    public static func getUserById(_ uuid: Int64) -> RcvIParticipant? {
        return RCVMeetingDataSource.getMeetingUserController()?.getMeetingUser(byId: uuid)
    }
    
    public static func updateRemoteUser(_ user: RcvIParticipant) {
        remoteUsers.updateValue(user, forKey: user.getModelId())
    }
    
    public static func removeRemoteUser(_ uuid: Int64) {
        remoteUsers.removeValue(forKey: uuid)
    }
    
    public static func getNextActiveRemoteUser() -> RcvIParticipant? {
        let userList = getSavedRemoteUserList()
        
        return (userList.first(where: { $0.value.status() == .ACTIVE }) ?? userList.first)?.value
    }
}
