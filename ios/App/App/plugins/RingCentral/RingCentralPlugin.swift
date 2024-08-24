import Foundation
import Capacitor
import rcvsdk

@objc(RingCentralPlugin)
public class RingCentralPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "RingCentralPlugin"
    public let jsName = "RingCentral"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "initRingCentral", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "joinMeeting", returnType: CAPPluginReturnPromise)
    ]
    
    @objc public func initRingCentral(_ call: CAPPluginCall) {
        DispatchQueue.main.async{
            guard let clientId = call.getString("clientId") else {
                call.reject("Missing Client ID")
                return
            }
            
            guard let clientSecret = call.getString("clientSecret") else {
                call.reject("Missing Client Secret")
                return
            }
            
            RcvEngine.create(clientId, clientSecret: clientSecret, isShareUsageData: false)
            
            print("debug -\(#function)")
            
            call.resolve(["status": "RingCentral initialized"])
        }
        
    }
    
    @objc public func joinMeeting(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let meetingId = call.getString("meetingId") else {
                call.reject("Missing meetingId")
                return
            }
            
            guard let apptEndTime = call.getDate("apptEndTime") else {
                call.reject("Missing meetingId")
                return
            }
            
            guard let userName = call.getString("userName") else {
                call.reject("Missing username")
                return
            }
            
            print("debug -\(#function): \(meetingId)")
            
            let meetingVC = MeettingViewController(meetingId, apptEndTime, userName)
            meetingVC.modalPresentationStyle = .overFullScreen
            meetingVC.onDismiss = { manualLeave in
                call.resolve([ "isManualLeave": manualLeave ])
            }
            meetingVC.onError = { message in
                call.reject(message)
            }
            self.bridge?.viewController?.presentFromRight(meetingVC)
        }
    }
}
