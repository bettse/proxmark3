import CPm3

public class PM3 {
    var pm3 : OpaquePointer? = nil

    var name : String {
        return String(cString: pm3_name_get(pm3))
    }

    public init?(path: String) {
        pm3 = pm3_open(path)
        if (pm3 == nil) {
            return nil
        }
    }

    deinit {
        pm3_close(pm3)
    }

    public func console(_ cmd: String) {
        let _ = pm3_console(pm3, cmd);
    }
}

let port = "/dev/tty.usbmodemiceman1"
let cmd = "help"

let pm3 = PM3(path: port)
if let pm3 = pm3 {
    print("name: \(pm3.name)")

    pm3.console(cmd)
} else {
    print("Unable to create PM3 instance")
}

