import XCTest
@testable import CPm3

public class PM3 {
    var pm3 : OpaquePointer? = nil

    var name : String {
        return String(cString: pm3_name_get(pm3))
    }

    public init?(path: String) {
        // TODO: support g_session

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

final class CPm3Tests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let pm3 = PM3(path: port)
        if let pm3 = pm3 {
            XCTAssertEqual(pm3.name, port)
            pm3.console(cmd)
        } else {
            XCTFail("Unable to create PM3 instance")
        }
    }
}
