//
//  MainView.swift
//  Geso
//
//  Created by Yoshimasa Niwa on 5/23/24.
//

import SwiftUI

struct MainView: View {
    @Environment(Service.self)
    private var service

    @State
    private var isFileImporterPresented: Bool = false

    var body: some View {
        if let folderURL = service.folderURL {
            VStack(spacing: 20.0) {
                Label {
                    Text(folderURL, format: .url.scheme(.never))
                } icon: {
                    Image(systemName: "folder")
                        .symbolVariant(.fill)
                        .foregroundStyle(.secondary)
                }

                if let imageURL = service.imageURLs.first {
                    if let image = NSImage(contentsOf: imageURL) {
                        Text("\(imageURL.deletingPathExtension().lastPathComponent)")
                            .font(.title)
                            .bold()
                        Image(nsImage: image)
                        HStack(spacing: 100.0) {
                            Button {
                                service.deny(imageURL)
                            } label: {
                                Label {
                                    Text("Deny")
                                } icon: {
                                    Image(systemName: "trash")
                                }
                            }
                            .keyboardShortcut(.leftArrow)
                            .controlSize(.extraLarge)

                            Button {
                                service.accept(imageURL)
                            } label: {
                                Label {
                                    Text("Accept")
                                } icon: {
                                    Image(systemName: "checkmark.seal.fill")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .keyboardShortcut(.rightArrow)
                            .controlSize(.extraLarge)
                        }
                    } else {
                        ContentUnavailableView {
                            Label("Not Image", systemImage: "doc.questionmark")
                        } actions: {
                            Button {
                                service.ignore(imageURL)
                            } label: {
                                Text("Skip")
                            }
                            .keyboardShortcut(.rightArrow)
                        }
                    }
                } else {
                    ContentUnavailableView {
                        Label("No Images", systemImage: "photo.on.rectangle.angled")
                    }
                }
            }
            .scenePadding()
        } else {
            ContentUnavailableView {
                Label("Select Folder", systemImage: "folder")
            } actions: {
                Button {
                    isFileImporterPresented = true
                } label: {
                    Text("Open…")
                }
            }
            .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.folder]) { result in
                guard case .success(let url) = result else {
                    return
                }
                service.folderURL = url
            }
            .scenePadding()
        }
    }
}

#Preview {
    MainView()
        .environment(Service())
}
