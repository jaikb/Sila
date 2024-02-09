//
//  VisionTwitchApp.swift
//  VisionTwitch
//
//  Created by Adam Gastineau on 2/2/24.
//

import SwiftUI

@main
struct VisionTwitchApp: App {
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup {
            AssetSelectionView()
        }

        WindowGroup(id: "channelVideo", for: String.self) { channel in
            if let channel = channel.wrappedValue {
                TwitchVideoView(channel: channel)
    //                .onAppear {
    //                    openWindow(id: "chat")
    //                }
                    // Set aspect ratio and enforce uniform resizing
                    .windowGeometryPreferences(minimumSize: CGSize(width: 160.0, height: 90.0), resizingRestrictions: .uniform)
            } else {
                Text("No channel specified")
            }
        }
            .defaultSize(CGSize(width: 800.0, height: 450.0))

//        WindowGroup(id: "chat") {
//            ChatWebView()
//        }
//            .defaultSize(width: 300, height: 500)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.progressive), in: .progressive)
    }
}
