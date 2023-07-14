//
//  StreamingImageView.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-03.
//

import SwiftUI

struct StreamingImageView: View {
    @State var imageURL: URL = URL(string: "file:\(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])/../img_01.jpg")!
    var body: some View {
        let _ = FileMonitor(fileURL: $imageURL)
        GeometryReader { geometry in
            AsyncImage(url: imageURL)
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
    }
}

struct StreamingImageView_Previews: PreviewProvider {
    static var previews: some View {
        StreamingImageView()
    }
}
