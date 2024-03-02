//
//  SubviewTest.swift
//  VisionTwitch
//
//  Created by Adam Gastineau on 3/1/24.
//

import SwiftUI
import SubviewAttachingTextView
import Nuke
import NukeUI
import Gifu
import TwitchIRC

//struct SubviewTestList: View {
//    var body: some View {
////        List {
////            ForEach(0..<200) { _ in
////                SubviewTest()
////            }
////        }
//        SubviewTest()
//    }
//}

struct SubviewTest: View {
    private let attributedString: NSAttributedString

    @MainActor
    init(message: PrivateMessage) {
        let attributedString = NSMutableAttributedString(string: message.message)

        var removedCharCount = 0
        
        var emotes = message.parseEmotes()

        // Sometimes emotes can be out of order
        emotes.sort { a, b in
            a.startIndex < b.startIndex
        }

        for emote in emotes {
//            if emote.isAnimated && emotes.count > 2 {
//                print(message)
//                print(message.emotes)
//            }

            let attachmentString = createAttachmentString(using: emote)

            let length = emote.endIndex - emote.startIndex + 1

            attributedString.replaceCharacters(in: .init(location: emote.startIndex - removedCharCount, length: length), with: attachmentString)

            removedCharCount += length
        }

//        let imageView = ImageView(frame: .init(x: 0, y: 0, width: 28, height: 28))
//        imageView.setImage(with: URL(string: "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_07de0906cc7141b3808695f6d14cad1f/default/light/1.0")!)
//        let attachment = SubviewTextAttachment(view: imageView)
//
//        let attributedString = NSMutableAttributedString(string: "This is a test string")
////        attributedString.addAttribute(.attachment, value: attachment, range: NSRange(location: 3, length: 7))
//        attributedString.append(NSAttributedString(attachment: attachment))
//
//        attributedString.append(NSAttributedString(string: "Additional string content."))

        self.attributedString = attributedString
    }

    var body: some View {
        SubviewAttachingTextSUIView(attributedString: self.attributedString)
    }
}

private func createAttachmentString(using emote: Emote) -> NSAttributedString {
    let imageView = ImageView(frame: .init(x: 0, y: 0, width: 28, height: 28))
    imageView.setImage(with: URL(string: emoteUrl(from: emote.id))!)
    let attachment = SubviewTextAttachment(view: imageView)

    return NSAttributedString(attachment: attachment)
}

final class ImageView: UIView {
    private let imageView: LazyImageView

    override init(frame: CGRect) {
        self.imageView = LazyImageView(frame: frame)
        self.imageView.makeImageView = { container in
            guard let data = container.data else {
                return nil
            }

            print("rendering data")

            let view = GIFImageView(frame: frame)
            view.animate(withGIFData: data)
            return view
        }

        super.init(frame: frame)

        self.addSubview(self.imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(with url: URL) {
        self.imageView.url = url
    }

    private func prepareForReuse() {
        self.imageView.reset()
    }
}
