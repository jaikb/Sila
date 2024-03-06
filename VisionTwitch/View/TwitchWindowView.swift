//
//  TwitchWindowView.swift
//  VisionTwitch
//
//  Created by Adam Gastineau on 2/18/24.
//

import SwiftUI
import Twitch

struct TwitchWindowView: View {
    @Environment(\.scenePhase) private var scene

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    let streamableVideo: StreamableVideo

    var body: some View {
        TwitchVideoView(streamableVideo: self.streamableVideo)
            // Set aspect ratio and enforce uniform resizing
            .windowGeometryPreferences(minimumSize: CGSize(width: 160.0, height: 90.0), resizingRestrictions: .uniform)
            .onAppear {
                WindowController.shared.refPlaybackWindow()
                NotificationCenter.default.post(name: .twitchMuteAll, object: nil, userInfo: nil)
            }
            .onChange(of: self.scene) { oldValue, newValue in
                print("Old \(oldValue), new \(newValue)")
                if newValue == .background {
                    if WindowController.shared.derefPlaybackWindow() && !WindowController.shared.mainWindowSpawned {
                        // Closed window, reopen main
                        openWindow(value: "main")
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .twitchLogOut), perform: { _ in
                dismissWindow()
            })
    }
}

#Preview {
    TwitchWindowView(streamableVideo: .stream(STREAM_MOCK()))
}
