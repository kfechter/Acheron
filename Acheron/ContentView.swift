//
//  ContentView.swift
//  Acheron
//
//  Created by Kenneth Fechter on 8/29/20.
//  Copyright © 2020 Kenneth Fechter. All rights reserved.
//

import SwiftUI

enum ActiveModal {
   case error, diskSelection
}

struct ContentView: View {
    @State private var isoImage = "";
    @State private var targetDevice = "";
    @State private var targetIsoPath = "";
    
    @State private var showModal = false;
    @State private var modalMode: ActiveModal = .diskSelection
    
    @State private var showHeaderMessage = false;
    
    @State private var errorMessages = [String]();
        
    
    var body: some View {
        VStack {
            Text("USB Creation Complete")
                .foregroundColor(Color.green)
                .opacity(showHeaderMessage ? 1 : 0)
            Text("Choose Windows 10 .iso")
            HStack {
                TextField("", text: $isoImage)
                
                Button(action: {
                    self.isoImage = SelectWindowsIso()
                }) {
                    Text("Open iso")
                }
            }
            .padding()
            Text("Choose Target Device")
            HStack {
                TextField("", text: $targetDevice)
                Button(action: {
                    self.modalMode = ActiveModal.diskSelection
                    self.showModal.toggle();
                }) {
                    Text("Select Target Disk")
                }
            }
        .padding()
            Button(action: {
                self.EvaluateResult(creationResult: CreateUSB(isoPath: self.isoImage, targetDevicePath: self.targetDevice.replacingOccurrences(of: "file://", with: ""), userName: NSUserName()))
            }) {
                Text("Create USB")
            }
        }.sheet(isPresented: $showModal) {
            if(self.modalMode == .diskSelection) {
                DiskPickerView(selectedDisk: self.$targetDevice)
            }
            else {
                ErrorView(errorList: self.$errorMessages)
            }
        }
    .padding()
    }
    
    func EvaluateResult(creationResult: [(output: [String], error: [String], exitCode: Int32)]) {
        creationResult.forEach { result in
            if(result.error.count > 0) {
                self.errorMessages.append(contentsOf: result.error)
            }
        }
        
        if(self.errorMessages.count > 0) {
            self.modalMode = .error
            self.showModal = true;
            self.showHeaderMessage = false;
        }
        else {
            self.showHeaderMessage = true;
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
