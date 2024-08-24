import UIKit
import Capacitor

class ViewController: CAPBridgeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func capacitorDidLoad() {
        super.capacitorDidLoad()
        bridge?.registerPluginInstance(RingCentralPlugin())
    }
    
}
