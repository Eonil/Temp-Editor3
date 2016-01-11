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
	init() {
		shell.onEvent = { [weak self] in self?.process($0) }
	}

	var onEvent: (Event -> ())?

	private let shell = ShellCommandExecutor()
}
extension CargoTool {
	enum Event {
		case DidStart
		case DidGenerateMessage(String)
		case DidGenerateIssue(CargoIssue)
		case DidEnd
	}
	enum Error: ErrorType {
		case NonFileURL
		case MissingParentURL
		case MissingFilePathInURL
		case MissingLastPathComponent
	}
}
extension CargoTool {
	/// - Parameter url:
	///	A URL to BE a `Cargo.toml` file.
	func runNewCommand(url: NSURL, asExecutable: Bool) throws {
		guard url.fileURL else { throw Error.NonFileURL }
		guard let parentURL = url.URLByDeletingLastPathComponent else { throw Error.MissingParentURL }
		guard let newDirName = url.lastPathComponent else { throw Error.MissingLastPathComponent }
		// File system is always asynchronous, and no one can have truly exclusive access.
		// Then we cannot make any assume on file system. Just try and take the result.
		let command = "cargo new --verbose \(newDirName) \(asExecutable ? "--bin" : "")"
		try runCargoWithWorkingDirecotyrURL(parentURL, command: command)
	}
	/// - Parameter url:
	///	A URL to a `Cargo.toml` file.
	func runBuildCommand(url: NSURL) throws {
		try runCargoWithWorkingDirecotyrURL(url, command: "cargo build --verbose")
	}
	/// - Parameter url:
	///	A URL to a `Cargo.toml` file.
	func runCleanCommand(url: NSURL) throws {
		try runCargoWithWorkingDirecotyrURL(url, command: "cargo clean --verbose")
	}

	func runDocCommand(path path: String) throws {
		MARK_unimplemented()
	}
	func runTestCommand(path path: String) throws {
		MARK_unimplemented()
	}
	func runBenchCommand(path path: String) throws {
		MARK_unimplemented()
	}
	func runUpdateCommand(path path: String) throws {
		MARK_unimplemented()
	}
	func runSearchCommand(path path: String) throws {
		MARK_unimplemented()
	}
	func cancelRunningAnyway() {
		if shell.state == .Running {
			shell.terminate()
			shell.wait()
		}
	}
}
extension CargoTool {
	private func process(event: ShellCommandExecutor.Event) {
		assert(onEvent != nil)
		switch event {
		case .Launch:
			break
		case .Clean:
			break
		case .Exit:
			onEvent?(.DidEnd)

		case .StandardOutput(let output):
			onEvent?(.DidGenerateMessage(output))
		case .StandardError(let error):
			onEvent?(.DidGenerateIssue(CargoIssue(code: error)))
		}
	}
	private func runCargoWithWorkingDirecotyrURL(workingDirectoryURL: NSURL, command: String) throws {
		guard workingDirectoryURL.fileURL else { throw Error.NonFileURL }
		guard let path = workingDirectoryURL.path else { throw Error.MissingFilePathInURL }
		runCargoWithWorkingDirectoryPath(path, command: command)
	}
	private func runCargoWithWorkingDirectoryPath(workingDirectoryPath: String, command: String) {
		// Single command execution is an intentional design to get a proper exit code.
		shell.launch(workingDirectoryPath)
//		shell.execute("export PATH=$PATH:~/.multirust/toolchains/stable/bin")
//		shell.execute("export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.multirust/toolchains/stable/lib")
//		shell.execute("export DYLD_FRAMEWORK_PATH=$DYLD_FRAMEWORK_PATH:~/.multirust/toolchains/stable/lib")
//		shell.execute("export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:~/.multirust/toolchains/stable/lib")
//		shell.execute("export DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH:~/.multirust/toolchains/stable/lib")

//		shell.execute("export PATH=$PATH:~/.multirust/toolchains/1.2.0/bin")
//		shell.execute("export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:~/.multirust/toolchains/1.2.0/lib")
//		shell.execute("export PATH=$PATH:~/Unix/multirust/bin")
//		shell.execute("export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:~/Unix/multirust/lib")
//		shell.execute("cd \(workingDirectoryPath)")
//		shell.execute("export DYLD_FALLBACK_LIBRARY_PATH=\"$HOME/Unix/homebrew/lib\"")
//		shell.execute("cc --version")
//		shell.execute("env")
//		shell.execute("rustc --version")
		shell.execute(command)
//		let	cmd	=	"\"cc\" \"-m64\" \"-L\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib\" \"/Users/Eonil/Documents/Editor2Test/a4/target/debug/a4.0.o\" \"-o\" \"/Users/Eonil/Documents/Editor2Test/a4/target/debug/a4\" \"-Wl,-dead_strip\" \"-nodefaultlibs\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/libstd-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/libcollections-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/librustc_unicode-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/librand-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/liballoc-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/liballoc_jemalloc-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/liblibc-1bf6e69c.rlib\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib/libcore-1bf6e69c.rlib\" \"-L\" \"/Users/Eonil/Documents/Editor2Test/a4/target/debug\" \"-L\" \"/Users/Eonil/Documents/Editor2Test/a4/target/debug/deps\" \"-L\" \"/Users/Eonil/.multirust/toolchains/stable/lib/rustlib/x86_64-apple-darwin/lib\" \"-L\" \"/Users/Eonil/Documents/Editor2Test/a4/.rust/lib/x86_64-apple-darwin\" \"-L\" \"/Users/Eonil/Documents/Editor2Test/a4/lib/x86_64-apple-darwin\" \"-l\" \"System\" \"-l\" \"pthread\" \"-l\" \"c\" \"-l\" \"m\" \"-l\" \"compiler-rt\""
//		shell.execute(cmd)
//		let	cmd	=	"rustc src/main.rs --crate-name a4 --crate-type bin -g --out-dir /Users/Eonil/Documents/Editor2Test/a4/target/debug --emit=dep-info,link -L dependency=/Users/Eonil/Documents/Editor2Test/a4/target/debug -L dependency=/Users/Eonil/Documents/Editor2Test/a4/target/debug/deps"
//		shell.execute(cmd)
		shell.execute("exit $?")
	}
}








