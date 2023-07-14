//
//  FileMonitor.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-30.
//

import SwiftUI
import Foundation

class FileMonitor {
    @Binding var fileURL: URL
    let fileDescriptor: CInt
    let fileMonitorQueue: DispatchQueue
    let fileMonitorSource: DispatchSourceFileSystemObject

    init(fileURL: Binding<URL>) {
        self._fileURL = fileURL
        fileDescriptor = open(fileURL.wrappedValue.path(), O_EVTONLY)
        fileMonitorQueue = DispatchQueue(label: "GB.IndigoPolarAlignAid_filemonitor")
        fileMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: fileMonitorQueue)
        startMonitoring()
    }

    func startMonitoring() {
        fileMonitorSource.setEventHandler {
            print("File has been written!")
            // Perform any desired actions here
            self.fileURL = self.fileURL
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
