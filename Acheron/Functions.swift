//
//  Functions.swift
//  Acheron
//
//  Created by Kenneth Fechter on 8/30/20.
//  Copyright © 2020 Kenneth Fechter. All rights reserved.
//

import Foundation
import SwiftUI

func SelectWindowsIso() -> String {
       let dialog = NSOpenPanel();
       dialog.title = "Select Windows 10 iso";
       dialog.showsResizeIndicator    = true;
       dialog.showsHiddenFiles        = false;
       dialog.allowsMultipleSelection = false;
       dialog.canChooseDirectories = false;
       dialog.allowedFileTypes        = ["iso"];
       
       if(dialog.runModal() == NSApplication.ModalResponse.OK) {
           let result = dialog.url;
           if(result != nil) {
               let path: String = result!.path
               return path;
           }
       }
       
       return "";
   }

func CreateUSB(isoPath: String, targetDevicePath: String, userName: String) -> [(output: [String], error: [String], exitCode: Int32)] {
    
    var programErrors = [(output: [String](), error: [String](), exitCode: Int32())]
    
    // This is the only result I need to temporarily save, as I need to analyze it
    let isoMountResult = runCommand(cmd: "/usr/bin/hdiutil", args: "mount", isoPath)
    programErrors.append(isoMountResult)
    
    let isoMountPath = isoMountResult.output[2]
    let userPath = "/Users/\(userName)/Documents/IsoTemp"

    programErrors.append(runCommand(cmd: "/bin/mkdir", args: "-p", userPath))
    programErrors.append(runCommand(cmd: "/bin/cp", args: "-R", "\(isoMountPath)/", userPath))
    programErrors.append(runCommand(cmd: "/bin/chmod", args: "-R", "u+rw", userPath))
    programErrors.append(runCommand(cmd: "/usr/local/bin/wimlib-imagex", args: "split", "\(userPath)/sources/install.wim", "\(userPath)/sources/install.swm", "3800"))
    programErrors.append(runCommand(cmd: "/bin/rm", args: "-rf", "\(userPath)/sources/install.wim"))
    programErrors.append(runCommand(cmd: "/bin/cp", args: "-R", "\(userPath)/", targetDevicePath))
    programErrors.append(runCommand(cmd: "/bin/rm", args: "-rf", userPath))
    programErrors.append(runCommand(cmd: "/usr/sbin/diskutil", args: "unmount", isoMountPath))
    programErrors.append(runCommand(cmd: "/usr/sbin/diskutil", args: "unmount", targetDevicePath))
    
    
    return programErrors
}

func runCommand(cmd: String, args: String...) -> (output: [String], error: [String], exitCode: Int32) {
    
    var output : [String] = []
    var error : [String] = []

    let task = Process()
    task.launchPath = cmd
    task.arguments = args
    
    let outpipe = Pipe()
    task.standardOutput = outpipe
    let errpipe = Pipe()
    task.standardError = errpipe

    task.launch()
    
    let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
    
    if var string = String(data: outdata, encoding: .utf8) {
        string = string.trimmingCharacters(in: CharacterSet.newlines)
        output = string.split(separator: "\t").map { String($0) }
    }

    let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
    
    if var string = String(data: errdata, encoding: .utf8) {
        string = string.trimmingCharacters(in: CharacterSet.newlines)
        error = string.split(separator: "\t").map { String($0) }
    }

    task.waitUntilExit()
    let status = task.terminationStatus
    
    return (output, error, status)
}
