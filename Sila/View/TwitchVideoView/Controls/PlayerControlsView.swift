//
//  PlayerControlsView.swift
//  VisionTwitch
//
//  Created by Adam Gastineau on 2/7/24.
//

import SwiftUI
import Twitch
import JunoUI

struct PlayerControlsView: View {
    let player: WebViewPlayer

    let streamableVideo: StreamableVideo

    @Binding var chatVisibility: Visibility

    let onInteraction: (() -> Void)?
    let activeChanged: ((Bool) -> Void)?

    var body: some View {
        let qualityBinding = Binding(get: { self.player.quality }, set: { self.player.setQuality($0) })

        HStack {
            CircleBackgroundLessButton(systemName: self.player.isPlaying ? Icon.pause : Icon.play, tooltip: self.player.isPlaying ? "Pause" : "Play") {
                if self.player.isPlaying {
                    self.player.pause()
                } else {
                    self.player.play()
                }

                self.onInteraction?()
            }
            .controlSize(.extraLarge)

            StreamableVideoStatusControlView(player: self.player, streamableVideo: self.streamableVideo)
                .padding(.horizontal, 4)

            // For some reason embedding a picker in a menu displays a picker with the menu style, with the menu's launch button
            Menu {
                Picker("Quality", selection: qualityBinding) {
                    // Qualties are saved in reverse order
                    ForEach(self.player.availableQualities.reversed(), id: \.quality) { quality in
                        Button(quality.name) {
                            self.player.setQuality(quality.quality)
                        }
                    }
                }
            } label: {
                Image(systemName: Icon.quality)
                    .symbolRenderingMode(.monochrome)
            }
            .buttonStyle(.borderless)
            .buttonBorderShape(.circle)
            .help("Quality")

            CircleBackgroundLessButton(systemName: Icon.chat, tooltip: self.chatVisibility == .visible ? "Hide Chat" : "Show Chat") {
                withAnimation {
                    if self.chatVisibility == .visible {
                        self.chatVisibility = .hidden
                    } else {
                        self.chatVisibility = .visible
                    }
                }
                self.onInteraction?()
            }

            // Force CircleBackgroundLessButton styles
            ShareLink(item: URL(string: "https://twitch.tv/\(self.userLogin())")!)
            .labelStyle(.iconOnly)
            .buttonBorderShape(.circle)
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }

    func userLogin() -> String {
        switch self.streamableVideo {
        case .stream(let stream):
            return stream.userLogin
        case .video(let video):
            return video.userLogin
        }
    }
}

private func previewPlayer() -> WebViewPlayer {
    let player = WebViewPlayer()
    player.quality = "1080p"
    player.availableQualities = [VideoQuality(quality: "chunked", name: "1080p"), VideoQuality(quality: "720p", name: "720p"), VideoQuality(quality: "480p", name: "480p"), VideoQuality(quality: "240p", name: "240p")]

    return player
}

#Preview {
    PlayerControlsView(player: previewPlayer(), streamableVideo: .stream(STREAM_MOCK()), chatVisibility: .constant(.hidden)) {

    } activeChanged: { _ in

    }
}

#Preview {
    Rectangle()
        .ornament(attachmentAnchor: .scene(.bottom)) {
            PlayerControlsView(player: previewPlayer(), streamableVideo: .stream(STREAM_MOCK()), chatVisibility: .constant(.visible)) {

            } activeChanged: { _ in

            }
            .glassBackgroundEffect()
        }
}
