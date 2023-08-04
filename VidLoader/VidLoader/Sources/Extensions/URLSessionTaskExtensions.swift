//
//  URLSessionTaskExtensions.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

extension URLSessionTask {
    static let concurrentQueue = DispatchQueue(label: "vidloader_concurrent_queue", attributes: .concurrent)
    
    var item: ItemInformation? {
        guard let data = taskDescription?.data else { return nil }

        return try? JSONDecoder().decode(ItemInformation.self, from: data)
    }

    var hasFailed: Bool {
        guard let state = item?.state else { return false }
        switch state {
        case .failed: return  true
        case .keyLoaded, .canceled, .completed, .prefetching,
             .running, .unknown, .waiting,
             .noConnection, .paused: return false
        }
    }

    func update(progress: Double, downloadedBytes: Int64) {
        URLSessionTask.concurrentQueue.async(flags: .barrier) {
            let bytes = Int(exactly: downloadedBytes) ?? .max
            self.item
                ?|> ItemInformation._progress .~ progress
                ?|> ItemInformation._downloadedBytes .~ bytes
                ?|> self.save
        }
    }

    func update(location: URL) {
        URLSessionTask.concurrentQueue.async(flags: .barrier) {
            self.item
                ?|> ItemInformation._path .~ location.relativePath
                ?|> self.save
        }
    }

    func update(state: DownloadState) {
        URLSessionTask.concurrentQueue.async(flags: .barrier) {
            self.item
                ?|> ItemInformation._state .~ state
                ?|> self.save
        }
    }

    func save(item: ItemInformation) {
        URLSessionTask.concurrentQueue.async(flags: .barrier) {
            self.taskDescription = (try? JSONEncoder().encode(item))?.string
        }
    }
}
