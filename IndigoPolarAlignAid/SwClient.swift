//
//  myApp.swift
//  IndigoPolarAlignAid
//
//  Created by Greg on 2023-06-01.
//

import Foundation

class SwClient {
    static let sharedInstance = SwClient() // so all view use the same instance
    
    let targetRadius = 10.0
    var correctionVector = CGVector(dx: 50.0, dy: 50.0)
    let imageURL = URL(string: "file:/Users/greg/Library/Containers/GB.IndigoPolarAlignAid/Data/img_01.jpg")

    func setupFileMonitor() {
        // Example usage
        let fileMonitor = FileMonitor(fileURL: imageURL!)
        fileMonitor.startMonitoring()
        
        // Keep the program running to receive notifications
        RunLoop.current.run()
    }
    
    init() {
        let _: Task = Task {
            setupFileMonitor()
        }
        
        let myClientTask: Task = Task {
            let argc: CInt = 2
            var argv: [UnsafePointer<CChar>?] = [("IndigoPolarAlignAid" as NSString).utf8String,("2" as NSString).utf8String,nil]
            
            let isCancelled = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
            isCancelled.initialize(to: Task.isCancelled)
            defer { isCancelled.deallocate() }

            await withTaskCancellationHandler {
                _ = myClient(argc, &argv, isCancelled)
            } onCancel: {
                isCancelled.pointee = true
            }
        }
        
        let _: Task = Task {
            try await Task.sleep(for: .seconds(10))
            print("Timesup!")
            myClientTask.cancel()
            print("SwClient: isCancelled is \(myClientTask.isCancelled)")
        }
    }
}
