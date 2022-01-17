// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift package clean && swift build --disable-sandbox
// To see what it would be like building as a dependency in Xcode:
// xcodebuild -scheme CPm3 build -destination "platform=iOS Simulator,id=582EAC3D-1322-4EE2-96BA-530C95064C06"

import PackageDescription
import Foundation

let fileManager = FileManager.default
let process = Process()

let instructionSets = ["NOSIMD", "MMX", "SSE2", "AVX", "AVX2", "AVX512"]
let MULTIARCHSRCS = ["hardnested_bf_core.c", "hardnested_bitarray_core.c"]
var combinations : [String] = MULTIARCHSRCS

for IS in instructionSets {
    for SRC in MULTIARCHSRCS {
        // Store all combinations to allow excluding from other targets
        // TODO: See if 'sources' parameter of target would simplify this away
        combinations.append(SRC.replacingOccurrences(of: ".c", with: "_\(IS).c"))

        let current = process.currentDirectoryURL
        let at = URL(fileURLWithPath: "./client/deps/hardnested/\(SRC)", relativeTo: current)
        let to = URL(fileURLWithPath: "./client/deps/hardnested/\(SRC)".replacingOccurrences(of: ".c", with: "_\(IS).c"), relativeTo: current)

        if at.startAccessingSecurityScopedResource() {
            do{
                try fileManager.copyItem(at: at, to: to)
            } catch let error as NSError where error.code == 516 { // File exists
                // No op
            } catch {
                print (error)
            }
            at.stopAccessingSecurityScopedResource()
        } else {
            #if SWIFT_PACKAGE
            print("Unable to duplicate hardnested source for other instruction sets")
            print("Run swift build with --disable-sandbox")
            #endif
        }
    }
}

func hardnestedTarget(IS: String) -> Target {
    let exclude = [
      "Makefile",
      "hardnested_tables.c",
      "hardnested_bruteforce.c",
    ] + combinations.filter { !$0.contains("\(IS).c") }

    // TODO: SUPPORTS_AVX512 :=  $(shell echo | $(CC) -E -mavx512f - > /dev/null 2>&1 && echo "True" ) 
    var flags : [String] = []
    switch(IS) {
    case "NOSIMD":
        flags = ["-mno-mmx", "-mno-sse2", "-mno-avx", "-mno-avx2", "-mno-avx512f"]
    case "MMX":
        flags = ["-mmmx", "-mno-sse2", "-mno-avx", "-mno-avx2", "-mno-avx512f"]
    case "SSE2":
        flags = ["-mmmx", "-msse2", "-mno-avx", "-mno-avx2", "-mno-avx512f"]
    case "AVX":
        flags = ["-mmmx", "-msse2", "-mavx", "-mno-avx2", "-mno-avx512f"]
    case "AVX2":
        flags = ["-mmmx", "-msse2", "-mavx", "-mavx2", "-mno-avx512f"]
    case "AVX512":
        flags = ["-mmmx", "-msse2", "-mavx", "-mavx2", "-mavx512f"]
    default:
        break
    }

    return .target(
        name: "CHardnested_\(IS)",
        dependencies: [],
        path: "client/deps/hardnested",
        exclude: exclude,
        //publicHeadersPath: ".",
        cSettings: [
            .unsafeFlags(["-UDEBUG"]),
            .unsafeFlags(flags),
            .headerSearchPath(".."),
            .headerSearchPath("../.."),
            .headerSearchPath("../../.."),
            .headerSearchPath("../../../include"),
            .headerSearchPath("../../../common"),
            .headerSearchPath("../../../client/src"),
        ]
    )
}

let hardnestedTargets = instructionSets.map { hardnestedTarget(IS: $0) }
let hardnestedDeps = hardnestedTargets.map { Target.Dependency(stringLiteral: $0.name) }

let package = Package(
    name: "CPm3",
    platforms: [
        .macOS("11.3"),
        .iOS("15.0"),
    ],
    products: [
        .library(name: "CPm3", targets: ["CPm3"]),
        //.library(name: "CPm3", type: .dynamic, targets: ["CPm3"]), // Useful for linker debugging
        //.library(name: "CPm3", type: .static, targets: ["CPm3"]),
    ],
    targets: hardnestedTargets + [
        .target(
            name: "CPm3",
            dependencies: ["common", "CHardnested", "CJansson", "CEMV"],
            path: "client",
            exclude: [
                "CMakeLists.txt",
                "Makefile",
                "README-bitlib",
                "atr_scrap_pcsctools.py",
                "cmdscripts/",
                "default_keys_dic2lua.awk",
                "deps/CMakeLists.txt",
                "deps/amiibo.cmake",
                "deps/amiitool/LICENSE",
                "deps/amiitool/Makefile",
                "deps/amiitool/amiitool.c",
                "deps/cliparser.cmake",
                "deps/cliparser/Makefile",
                "deps/cliparser/README.md",
                "deps/hardnested",
                "deps/hardnested.cmake",
                "deps/jansson",
                "deps/jansson.cmake",
                "deps/liblua/Makefile",
                "deps/liblua/lua.c",
                "deps/liblua/luac.c",
                "deps/lua.cmake",
                "deps/mbedtls.cmake",
                "deps/reveng.cmake",
                "deps/reveng/Makefile",
                "deps/tinycbor.cmake",
                "deps/tinycbor/Makefile",
                "deps/whereami.cmake",
                "deps/whereami/Makefile",
                "dictionaries/",
                "emojis_scrap_github.py",
                "experimental_client_with_swig/",
                "experimental_lib/",
                "gen_pm3mfsim_script.sh",
                "lualibs/",
                "luascripts/",
                "pm3_cmd_h2lua.awk",
                "pyscripts/",
                "resources/",
                "src/cmdlfverichip_disabled.c",
                "src/emv",
                "src/pm3.i",
                "src/pm3.py",
                "src/pm3_luawrap.c",
                "src/pm3_pywrap.c",
                "src/proxgui.cpp",
                "src/proxguiqt.cpp",
                "src/uart/README.md",
                "src/uart/uart_win32.c",
                "src/ui/image.ui",
                "src/ui/overlays.ui",
            ],
            publicHeadersPath: "include",
            cxxSettings: [
                .define("__NCURSES_H"), // Block the automatically included ncurses
                .define("LIBPM3"), // Prevent main() in proxmark.c
                .unsafeFlags(["-UDEBUG"]),
                .headerSearchPath("../include"),
                .headerSearchPath("../common"),
                .headerSearchPath("../common_fpga"),
                .headerSearchPath("../common/mbedtls"),
                .headerSearchPath("src"),
                .headerSearchPath("include"),
                .headerSearchPath("deps/liblua/"),
                .headerSearchPath("deps/whereami/"),
                .headerSearchPath("deps/cliparser/"),
                .headerSearchPath("deps/tinycbor/"),
                .headerSearchPath("deps/hardnested/"),
                .headerSearchPath("deps/jansson/"),
                .headerSearchPath("deps/amiitool/"), // Should make these into targets as well
                .headerSearchPath("deps/reveng/"),
            ],
            linkerSettings: [
                .linkedLibrary("bz2"),
            ]
        ),
        .target(
            name: "common",
            dependencies: [],
            path: "common",
            exclude: [
                "lz4/LICENSE",
                "crapto1/readme",
                "get_lz4.sh",

                //"mbedtls/",
                "mbedtls/Makefile",
                "mbedtls/ssl_ticket.c",
                "mbedtls/ssl_cache.c",
                "mbedtls/psa_crypto.c",
                "mbedtls/psa_crypto_client.c",
                "mbedtls/psa_crypto_driver_wrappers.c",
                "mbedtls/psa_crypto_ecp.c",
                "mbedtls/psa_crypto_rsa.c",
                "mbedtls/psa_crypto_se.c",
                "mbedtls/psa_crypto_slot_management.c",
                "mbedtls/psa_crypto_storage.c",
                "mbedtls/psa_its_file.c",
            ],
            publicHeadersPath: "include",
            cxxSettings: [
                .unsafeFlags(["-UDEBUG"]),
                .headerSearchPath("."),
                .headerSearchPath(".."),
                .headerSearchPath("../include"),
                .headerSearchPath("../client/src"),
            ]
        ),
        .target(
            name: "CHardnested",
            dependencies: hardnestedDeps,
            path: "client/deps/hardnested",
            exclude: ["Makefile", "hardnested_tables.c"] + combinations,
            cSettings: [
                .unsafeFlags(["-UDEBUG"]),
                //.unsafeFlags(["-mmmx", "-mno-sse2", "-mno-avx", "-mno-avx2", "-mno-avx512f"]),
                .headerSearchPath(".."),
                .headerSearchPath("../.."),
                .headerSearchPath("../../.."),
                .headerSearchPath("../../../include"),
                .headerSearchPath("../../../common"),
                .headerSearchPath("../../../client/src"),
                .headerSearchPath("../../../client/deps/jansson"),
            ],
            linkerSettings: [
                //.linkedLibrary("CHardnested_SIMD"),
            ]
        ),
        .target(
            name: "CJansson",
            path: "client/deps/jansson",
            exclude: [
                "Makefile",
                "jansson_config.h.in",
            ],
            publicHeadersPath: "include",
            cxxSettings: [
                .unsafeFlags(["-UDEBUG"]),
                .headerSearchPath(".."),
                .headerSearchPath("../.."),
                .headerSearchPath("../../.."),
                .headerSearchPath("../../../include"),
                .headerSearchPath("../../../common"),
                .headerSearchPath("../../../client/src"),
            ]
        ),
        .target(
            name: "CEMV",
            path: "client/src/emv",
            exclude: [],
            publicHeadersPath: "include",
            cxxSettings: [
                .unsafeFlags(["-UDEBUG"]),
                .headerSearchPath(".."),
                .headerSearchPath("../.."),
                .headerSearchPath("../../include"),
                .headerSearchPath("../../deps/cliparser"),
                .headerSearchPath("../../deps/jansson"),
                .headerSearchPath("../../../include"),
                .headerSearchPath("../../../common"),
                .headerSearchPath("../../../common/mbedtls"),
            ]
        ),

        .testTarget(
            name: "example_swift",
            dependencies: ["CPm3"],
            path: "client/experimental_lib/example_swift/"
        ),
    ]
)
