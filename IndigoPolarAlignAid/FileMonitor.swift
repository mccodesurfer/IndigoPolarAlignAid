//
//  FileMonitor.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-30.
//

import Foundation
import SwiftUI

class FileMonitor : ObservableObject {
    @Published var fileUpdateCount: Int = 0
    @State var filePath: URL
    var fileDescriptor: CInt = 0
    let fileMonitorQueue: DispatchQueue
    let fileMonitorSource: DispatchSourceFileSystemObject
    
    init(filePath: URL) {
        self.filePath = filePath
        fileDescriptor = open(filePath.path(), O_EVTONLY)
        if fileDescriptor != 0 {
            print("FileMonitor: filePath = \(filePath)")
            print("FileMonitor: fileDescriptor = \(fileDescriptor)")
        } else {
            print("FileMonitor: fileDescriptor failed")
        }
            fileMonitorQueue = DispatchQueue(label: "GB.IndigoPolarAlignAid_filemonitor")
            fileMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: fileMonitorQueue)
            startMonitoring()
        }

    func startMonitoring() {
        fileMonitorSource.setEventHandler {
            DispatchQueue.main.async {
                // Perform any desired actions here
                self.fileUpdateCount += 1
                print("\nFileMonitor: File count \(self.fileUpdateCount) has been written!\n")
            }
        }

        fileMonitorSource.setCancelHandler {
            close(self.fileDescriptor)
        }

        fileMonitorSource.resume()
    }

    func stopMonitoring() {
        fileMonitorSource.cancel()
    }
    
    func getFileUpdateCount() -> Int {
        return self.fileUpdateCount
    }
}
