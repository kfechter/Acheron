//
//  ErrorView.swift
//  Acheron
//
//  Created by Kenneth Fechter on 8/30/20.
//  Copyright © 2020 Kenneth Fechter. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var errorList: [String]
    
    var body: some View {
        VStack {
            List(errorList, id: \.self) { error in
                Text(error)
                    .foregroundColor(Color.red)
            }
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
            }
        }
    }
}

struct DefinedErrorView : View {
    @State private var errorsList = [String]()
    
    var body: some View {
        ErrorView(errorList: self.$errorsList)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        DefinedErrorView()
    }
}
