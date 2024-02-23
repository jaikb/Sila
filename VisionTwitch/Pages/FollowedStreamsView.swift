//
//  FollowedStreamsView.swift
//  VisionTwitch
//
//  Created by Adam Gastineau on 2/17/24.
//

import SwiftUI
import Twitch

struct FollowedStreamsView: View {
    @Environment(\.authController) private var authController

    @State private var liveStreamsLoader = DataLoader<[Twitch.Stream], AuthStatus>()
    @State private var channelsLoader = DataLoader<[Twitch.User], AuthStatus>()

    var body: some View {
        PickerTabView(leftTitle: "Live", leftView: {
            self.liveStreams
        }, rightTitle: "All Channels") {
            self.channels
        }
    }

    @ViewBuilder
    var liveStreams: some View {
        AuthorizedStandardScrollableDataView(loader: self.$liveStreamsLoader, task: { (api, user) in
            print("Request live")
            guard user != nil else {
                // If we have no user, we're unauthenticated and this is a buffered task
                return []
            }
            let (streams, _) = try await api.getFollowedStreams(limit: 100)
            return streams
        }) { streams in
            StreamGridView(streams: streams)
        }
    }

    @ViewBuilder
    var channels: some View {
        AuthorizedStandardScrollableDataView(loader: self.$channelsLoader) { api, user in
            print("Request channels")
            let (_, channels, _) = try await api.getFollowedChannels(limit: 100)

            let broadcasterIds = channels.map({$0.broadcasterId})

            let users = try await api.getUsers(userIDs: broadcasterIds)
            return users
        } content: { channels in
            ChannelGridView(channels: channels)
        }
    }
}