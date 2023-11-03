//
//  FileMonitor.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-30.
//

import Foundation

class FileMonitor : ObservableObject {
    let fileDescriptor: CInt
    let fileMonitorQueue: DispatchQueue
    let fileMonitorSource: DispatchSourceFileSystemObject
    
    @Published var fileUpdateCount: Int = 0

    init(filePath: URL) {
        print(filePath)
        fileDescriptor = open(filePath.path(), O_EVTONLY)
        print(fileDescriptor)
            fileMonitorQueue = DispatchQueue(label: "GB.IndigoPolarAlignAid_filemonitor")
            fileMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: fileMonitorQueue)
        }

    func startMonitoring() {
        fileMonitorSource.setEventHandler {
            print("File has been written!")
            DispatchQueue.main.async {
                self.fileUpdateCount += 1
                // Perform any desired actions here
                print (self.fileUpdateCount)
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
