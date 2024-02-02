//
//  StreamingImageView.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-03.
//

import SwiftUI

struct StreamingImageView: View {
    private var filePath : URL?
    @StateObject private var monitor : FileMonitor
    @State var id = UUID()
    
    init(){
        filePath = URL(string: "file:/Users/\(NSUserName())/Library/Containers/GB.IndigoPolarAlignAid/Data/img_01.jpg")!
        let monitor = FileMonitor(filePath: filePath!)
        self._monitor = StateObject(wrappedValue: monitor)
        monitor.startMonitoring()
    }
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: filePath) { image in
                image.image?
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
            }.id(UUID())
            Text("count \(monitor.fileUpdateCount) \(filePath!.absoluteString)")
        }
    }
}

struct StreamingImageView_Previews: PreviewProvider {
    static var previews: some View {
        StreamingImageView()
    }
}
