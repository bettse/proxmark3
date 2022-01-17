import CPm3

print("This is written in Swift!")

let port = "/dev/tty.usbmodemiceman1"

//pm3 *pm3_open(char *port);

port.withCString { port in
    let _ = pm3_open(UnsafeMutablePointer(mutating: port));
    print("Opened")
}

