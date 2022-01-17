import CPm3

print("This is written in Swift!")

let port = "/dev/tty.usbmodemiceman1"
let cmd = "help"

/*
pm3 *pm3_open(char *port)
int pm3_console(pm3 *dev, char *cmd);
const char *pm3_name_get(pm3 *dev);
void pm3_close(pm3 *dev);
pm3 *pm3_get_current_dev(void);
*/

port.withCString { port in
    let pm3 = pm3_open(port);
    print("Opened")
    let name = String(cString: pm3_name_get(pm3))
    print("name: \(name)")


    print("Running `\(cmd)`")
    cmd.withCString { cmd in
        let result = pm3_console(pm3, cmd);
        print("Result of command: \(result)")
    }

    pm3_close(pm3)
    print("Closed")
}

