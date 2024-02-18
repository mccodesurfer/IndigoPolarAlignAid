//
//  StreamingImageView.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-03.
//

import SwiftUI

let filePath = URL(string: "file:/Users/\(NSUserName())/Library/Containers/GB.IndigoPolarAlignAid/Data/img_01.jpg")

struct StreamingImageView: View {
    @ObservedObject var monitor: FileMonitor = FileMonitor(filePath: filePath!)
    var id: Int = 0

    var body: some View {
            AsyncImage(url: monitor.filePath)
                    .id(monitor.fileUpdateCount)
}
    
    struct StreamingImageView_Previews: PreviewProvider {
        static var previews: some View {
            StreamingImageView()
        }
    }
}
