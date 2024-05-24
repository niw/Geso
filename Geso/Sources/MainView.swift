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
                Text("\(folderURL.path())")

                if let imageURL = service.imageURLs.first {
                    if let image = NSImage(contentsOf: imageURL) {
                        Text("\(imageURL.lastPathComponent)")
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
                                .padding()
                            }

                            Button {
                                service.accept(imageURL)
                            } label: {
                                Label {
                                    Text("Accept")
                                } icon: {
                                    Image(systemName: "checkmark.seal.fill")
                                }
                                .padding()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        Text("This is not image file.")
                    }
                } else {
                    Text("No image files")
                }
            }
            .scenePadding()
        } else {
            Button {
                isFileImporterPresented = true
            } label: {
                Label {
                    Text("Browse")
                } icon: {
                    Image(systemName: "folder.fill")
                }
                .padding()
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
