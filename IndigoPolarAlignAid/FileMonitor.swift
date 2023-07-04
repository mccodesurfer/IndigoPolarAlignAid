//
//  FileMonitor.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-30.
//

import Foundation

class FileMonitor {
    let fileURL: URL
    let fileDescriptor: CInt
    let fileMonitorQueue: DispatchQueue
    let fileMonitorSource: DispatchSourceFileSystemObject

    init(fileURL: URL) {
        self.fileURL = fileURL
        print(fileURL)
        fileDescriptor = open(fileURL.path, O_EVTONLY)
        print (fileDescriptor)
        fileMonitorQueue = DispatchQueue(label: "GB.IndigoPolarAlignAid_filemonitor")
        fileMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: fileMonitorQueue)
    }

    func startMonitoring() {
        fileMonitorSource.setEventHandler {
            print("File has been written!")
            // Perform any desired actions here
        }

        fileMonitorSource.setCancelHandler {
            close(self.fileDescriptor)
        }

        fileMonitorSource.resume()
    }

    func stopMonitoring() {
        fileMonitorSource.cancel()
    }
}
