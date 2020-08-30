//
//  ContentView.swift
//  Acheron
//
//  Created by Kenneth Fechter on 8/29/20.
//  Copyright © 2020 Kenneth Fechter. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var isoImage = "";
    @State private var targetDevice = "";
    @State private var showDriveSelection = false;
    @State private var targetIsoPath = "";
    
    @State private var errorState = false;
    @State private var errorMessage = "";
    
    @State private var successState = false;
    @State private var successMessage = "USB Created";
    
    @State private var executionState = (output: [String](), error: [String](), exitCode: Int32());
    
    var body: some View {
        VStack {
            Text(self.errorMessage)
                .foregroundColor(Color.red)
                .opacity(errorState ? 1 : 0)
            Text(self.successMessage)
                .foregroundColor(Color.green)
                .opacity(successState ? 1 : 0)
            Text("Choose Windows 10 .iso")
            HStack {
                TextField("", text: $isoImage)
                
                Button(action: {
                    self.isoImage = self.SelectWindowsIso()
                }) {
                    Text("Open iso")
                }
            }
            .padding()
            Text("Choose Target Device")
            HStack {
                TextField("", text: $targetDevice)
                Button(action: {
                    self.showDriveSelection.toggle();
                }) {
                    Text("Select Target Disk")
                }.sheet(isPresented: $showDriveSelection) {
                    DiskPickerView(selectedDisk: self.$targetDevice)
                }
            }
        .padding()
            Button(action: {
                self.executionState = self.runCommand(cmd: "/usr/bin/hdiutil", args: "mount", self.isoImage)
                if(self.executionState.exitCode == 0 && self.executionState.output.count == 3) {
                    self.targetIsoPath = self.executionState.output[2]
                    self.errorState = false;
                    // Start Copying some files
                    
                    let userName = NSUserName()
                    let userPath = "/Users/\(userName)/Documents/IsoTemp"
                    self.executionState = self.runCommand(cmd: "/bin/mkdir", args: "-p", userPath)
                    if(self.executionState.exitCode != 0 && self.executionState.error.count > 0) {
                        self.errorState = true;
                        self.errorMessage = self.executionState.error[0];
                    }
                    else {
                        self.executionState = self.runCommand(cmd: "/bin/cp", args: "-R", "\(self.targetIsoPath)/", userPath)
                        if(self.executionState.exitCode != 0 && self.executionState.error.count > 0) {
                                    self.errorState = true;
                                    self.errorMessage = self.executionState.error[0];
                                }
                        else {
                            self.executionState = self.runCommand(cmd: "/bin/chmod", args: "-R", "u+rw", userPath)
                            self.executionState = self.runCommand(cmd: "/usr/local/bin/wimlib-imagex", args: "split", "\(userPath)/sources/install.wim", "\(userPath)/sources/install.swm", "3800")
                            
                            if(self.executionState.exitCode != 0 && self.executionState.error.count > 0) {
                                self.errorState = true;
                                self.errorMessage = self.executionState.error[0];
                            }
                            else {
                                // Remove the install.wim
                                self.executionState = self.runCommand(cmd: "/bin/rm", args: "-rf", "\(userPath)/sources/install.wim")
                                if(self.executionState.exitCode != 0 && self.executionState.error.count > 0) {
                                                               self.errorState = true;
                                                               self.errorMessage = self.executionState.error[0];
                                                           }
                                                           else {
                                    if(self.targetDevice != "") {
                                        self.executionState = self.runCommand(cmd: "/bin/cp", args: "-R", "\(userPath)/", self.targetDevice.replacingOccurrences(of: "file://", with: ""))
                                        if(self.executionState.exitCode != 0 && self.executionState.error.count > 0) {
                                            self.errorState = true;
                                            self.errorMessage = self.executionState.error[0];
                                        }
                                        else {
                                            // cleanup
                                            self.executionState = self.runCommand(cmd: "/bin/rm", args: "-rf", userPath)
                                            // unmount volumes
                                            self.executionState = self.runCommand(cmd: "/usr/sbin/diskutil", args: "unmount", self.targetIsoPath)
                                            self.executionState = self.runCommand(cmd: "/usr/sbin/diskutil", args: "unmount", self.targetDevice.replacingOccurrences(of: "file://", with: ""))
                                            if(self.executionState.exitCode != 0 && self.executionState.error.count > 0) {
                                                self.errorState = true;
                                                self.errorMessage = self.executionState.error[0];
                                            }
                                            else {
                                                self.errorState = false;
                                                self.successState = true;
                                            }
                                        }
                                        
                                    }
                                    else {
                                        self.errorState = true
                                        self.errorMessage = "No Target volume selected"
                                    }
                                }
                            }
                        }
                    }
                }
                else if(self.executionState.exitCode != 0 && self.executionState.error.count > 0) {
                    self.errorState = true;
                    self.errorMessage = self.executionState.error[0];
                }
            }) {
                Text("Create USB")
            }
        }
    .padding()
    }
    
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
