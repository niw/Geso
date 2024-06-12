//
//  Service.swift
//  Geso
//
//  Created by Yoshimasa Niwa on 5/23/24.
//

import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class Service: NSObject {
    var folderURL: URL? {
        didSet {
            guard oldValue != folderURL else {
                return
            }
            reloadImages()
        }
    }

    var imageURLs: [URL] = []

    private func reloadImages() {
        guard let folderURL else {
            imageURLs = []
            return
        }

        let resourceValueKeys: Set<URLResourceKey> = [
            .isDirectoryKey
        ]
        guard let enumerator = FileManager.default.enumerator(
            at: folderURL,
            includingPropertiesForKeys: Array(resourceValueKeys),
            options: [
                .skipsHiddenFiles,
                .skipsPackageDescendants,
                .skipsSubdirectoryDescendants
            ]
        ) else {
            return
        }

        var imageURLs = [URL]()
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: resourceValueKeys),
                  let isDirectory = values.isDirectory,
                  !isDirectory
            else {
                continue
            }
            imageURLs.append(url)
        }
        self.imageURLs = imageURLs
    }

    private func move(_ imageURL: URL, to directoryName: String) {
        guard let folderURL else {
            return
        }
        let destinationURL = folderURL.appending(component: directoryName)
        do {
            if !FileManager.default.fileExists(atPath: destinationURL.path()) {
                try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: false)
            }
            try FileManager.default.moveItem(at: imageURL, to: destinationURL.appending(component: imageURL.lastPathComponent))
        } catch {
        }
    }

    func accept(_ imageURL: URL) {
        move(imageURL, to: "accept")
        reloadImages()
    }

    func deny(_ imageURL: URL) {
        move(imageURL, to: "deny")
        reloadImages()
    }
    
    func ignore(_ imageURL: URL) {
        move(imageURL, to: "ignore")
        reloadImages()
    }
}

extension Service: NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
