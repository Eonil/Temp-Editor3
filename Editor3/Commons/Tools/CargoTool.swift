//
//  CargoTool.swift
//  Editor3
//
//  Created by Hoon H. on 2016/01/03.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation

final class CargoTool {
	// MARK: -
	private let executor = CargoShellExecutor()

	// MARK: -
	init() {
	}
}
extension CargoTool {
	enum Event {
		typealias Notification = EventNotification<CargoTool,Event>
		case DidStart
		case DidGenerateIssue(CargoIssue)
		case DidEnd
	}
}
extension CargoTool {
	/// - Parameter url:
	///	A URL to a `Cargo.toml` file.
	func runBuildingAtURL(url: NSURL) {
		
	}
	func runCleaningAtURL(url: NSURL) {

	}
	/// - Parameters:
	///	- rootDirectoryURL:
	///		A URL to a directory that will become root directory of
	///		a cargo project. This directory must not exists.
	///
	///
	func runNew(path path: String, newDirectoryName: String, asExecutable: Bool) {
		//	File system is always asynchronous, and no one can have truly exclusive access.
		//	Then we cannot make any assume on file system. Just try and take the result.
		runCargoImpl(path, command: "cargo new --verbose \(newDirectoryName) \(asExecutable ? "--bin" : "")")
	}
	func runBuild(path path: String) {
		runCargoImpl(path, command: "cargo build --verbose")
	}
	func runClean(path path: String) {
		runCargoImpl(path, command: "cargo clean --verbose")
	}
	func runDoc(path path: String) {
		MARK_unimplemented()
	}
	func runTest(path path: String) {
		MARK_unimplemented()
	}
	func runBench(path path: String) {
		MARK_unimplemented()
	}
	func runUpdate(path path: String) {
		MARK_unimplemented()
	}
	func runSearch(path path: String) {
		MARK_unimplemented()
	}
	func cancelRunning() {
		executor.terminate()
		executor.wait()
	}
}
private extension CargoTool {
	func runCargoImpl(workingDirectoryPath: String, command: String) {
		// Single command execution is an intentional design to get a proper exit code.
		executor.launch(workingDirectoryPath)
//		executor.execute("export PATH=$PATH:~/.multirust/toolchains/stable/bin")
//		executor.execute("export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.multirust/toolchains/stable/lib")
//		executor.execute("export DYLD_FRAMEWORK_PATH=$DYLD_FRAMEWORK_PATH:~/.multirust/toolchains/stable/lib")
//		executor.execute("export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:~/.multirust/toolchains/stable/lib")
//		executor.execute("export DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH:~/.multirust/toolchains/stable/lib")

//		executor.execute("export PATH=$PATH:~/.multirust/toolchains/1.2.0/bin")
//		executor.execute("export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:~/.multirust/toolchains/1.2.0/lib")
//		executor.execute("export PATH=$PATH:~/Unix/multirust/bin")
//		executor.execute("export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:~/Unix/multirust/lib")
//		executor.execute("cd \(workingDirectoryPath)")
//		executor.execute("export DYLD_FALLBACK_LIBRARY_PATH=\"$HOME/Unix/homebrew/lib\"")
//		executor.execute("cc --version")
//		executor.execute("env")
//		executor.execute("rustc --version")
		executor.execute(command)
//		let	cmd	=	"\"cc\" \"-m64\" \"-L\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib\" \"/Users/Eonil/Documents/Editor2Test/a4/target/debug/a4.0.o\" \"-o\" \"/Users/Eonil/Documents/Editor2Test/a4/target/debug/a4\" \"-Wl,-dead_strip\" \"-nodefaultlibs\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/libstd-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/libcollections-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/librustc_unicode-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/librand-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/liballoc-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/liballoc_jemalloc-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/liblibc-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/libcore-1bf6e69c.rlib\" \"-L\" \"/Users/Eonil/Documents/Editor2Test/a4/target/debug\" \"-L\" \"/Users/Eonil/Documents/Editor2Test/a4/target/debug/deps\" \"-L\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib\" \"-L\" \"/Users/Eonil/Documents/Editor2Test/a4/.rust/lib/x86_64-apple-darwin\" \"-L\" \"/Users/Eonil/Documents/Editor2Test/a4/lib/x86_64-apple-darwin\" \"-l\" \"System\" \"-l\" \"pthread\" \"-l\" \"c\" \"-l\" \"m\" \"-l\" \"compiler-rt\""
//		executor.execute(cmd)
//		let	cmd	=	"rustc src/main.rs --crate-name a4 --crate-type bin -g --out-dir /Users/Eonil/Documents/Editor2Test/a4/target/debug --emit=dep-info,link -L dependency=/Users/Eonil/Documents/Editor2Test/a4/target/debug -L dependency=/Users/Eonil/Documents/Editor2Test/a4/target/debug/deps"
//		executor.execute(cmd)
		executor.execute("exit $?")
	}
}








