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
    @State
    private var isDropTargeted: Bool = false

    var body: some View {
        Group {
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
                                    service.markAsBad(imageURL)
                                } label: {
                                    Label {
                                        Text("Bad")
                                    } icon: {
                                        Image(systemName: "trash")
                                    }
                                }
                                .keyboardShortcut(.leftArrow)
                                .controlSize(.extraLarge)
                                
                                Button {
                                    service.markAsGood(imageURL)
                                } label: {
                                    Label {
                                        Text("Good")
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .fixedSize(horizontal: true, vertical: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(isDropTargeted ? 0.8 : 1.0)
                .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.folder]) { result in
                    guard case .success(let url) = result else {
                        return
                    }
                    service.folderURL = url
                }
                .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
                    guard let provider = providers.first else {
                        return false
                    }
                    _ = provider.loadObject(ofClass: URL.self) { url, error in
                        guard let url else {
                            return
                        }
                        Task { @MainActor in
                            service.folderURL = url
                        }
                    }
                    return true
                }
            }
        }
        .scenePadding()
    }
}

#Preview {
    MainView()
        .environment(Service())
}
