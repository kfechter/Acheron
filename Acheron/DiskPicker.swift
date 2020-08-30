import SwiftUI

struct DiskPickerView: View {
    @State private var chosenDisk = "";
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedDisk: String
    
    var body: some View {
        VStack {
            Text("Choose Target Volume")
            Picker(selection: $selectedDisk, label: Text("Butts")) {
                       ForEach(GetMountedVolumes(), id: \.self) { volume in
                           Text(volume)
                       }
            }.labelsHidden()
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                }) {
                Text("Confirm")
            }
        }
    }
    
    func GetMountedVolumes() -> [String] {
        var mountedVolumes = [String]();
        let keys: [URLResourceKey] = [.volumeNameKey, .volumeIsRemovableKey, .volumeIsEjectableKey]
        let paths = FileManager().mountedVolumeURLs(includingResourceValuesForKeys: keys, options: [])
        if let urls = paths {
            for url in urls {
                let components = url.pathComponents
                if components.count > 1
                   && components[1] == "Volumes"
                {
                    mountedVolumes.append(url.absoluteString);
                }
            }
        }
        
        return mountedVolumes
    }
}

struct DefinedDiskPickerView : View {
    @State private var selectedDisk = ""
    
    var body: some View {
        DiskPickerView(selectedDisk: self.$selectedDisk)
    }
}

struct DiskPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DefinedDiskPickerView()
    }
}
