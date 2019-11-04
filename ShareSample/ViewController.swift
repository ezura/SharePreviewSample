//
//  ViewController.swift
//  ShareSample
//
//  Created by yuka ezura on 2019/10/27.
//  Copyright © 2019 繪面友香. All rights reserved.
//

import UIKit
import LinkPresentation

class ViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView! = nil {
        didSet {
            tableView.register(UITableViewCell.self,
                               forCellReuseIdentifier: "default")
            tableView.contentInset.bottom = 500 // workaround: To avoid that share sheet hides cells. 
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    private let shareCases: [[ShareItem]] = [
        [.text()],
        [.url()],
        [.image()],
        [.url(), .text()],
        [.text(), .image()],
        [.image(), .text()],
        [.itemSource(item: URL(string: "https://www.google.com")!,
                     linkMetadata: LPLinkMetadata().setTitle(title: "custom title"))],
        [.itemSource(item: URL(string: "https://www.google.com")!,
                     linkMetadata: nil)],
        [.text(), .itemSource(item: URL(string: "https://www.google.com")!,
        linkMetadata: nil)],
        [.image(), .itemSource(item: URL(string: "https://www.google.com")!,
        linkMetadata: nil)],
        [.url(), .itemSource(item: "text item",
        linkMetadata: nil)],
        [.url(), .itemSource(item: "text item",
        linkMetadata: LPLinkMetadata())],
        [.url(),
        .itemSource(item: "text item",
        linkMetadata: LPLinkMetadata().setTitle(title: "custom title")),
        // first win?
        .itemSource(item: #imageLiteral(resourceName: "ezura.png"),
               linkMetadata: LPLinkMetadata()),],
        [.url(),
        // first win?
        .itemSource(item: #imageLiteral(resourceName: "ezura.png"),
               linkMetadata: LPLinkMetadata()),
        .itemSource(item: "text item",
        linkMetadata: LPLinkMetadata().setTitle(title: "custom title")),],
        [.url(), 
         .itemSource(item: URL(string: "https://developer.apple.com")!,
                     linkMetadata: nil)],
        [.itemSource(item: URL(string: "https://developer.apple.com")!,
        linkMetadata: nil),
         .url(),
         .text("test")],
        [.text("test"),
         .itemSource(item: URL(string: "https://developer.apple.com")!,
        linkMetadata: nil),
         .url()],
    ]
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shareCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", 
                                                 for: indexPath)
        cell.textLabel?.attributedText = shareCases[indexPath.row].map { $0.visualDescription }
            .reduce(into: NSMutableAttributedString()) { result, text in
                let line = NSMutableAttributedString(string: "● ")
                line.append(text)
            result.append(line)
            result.append(NSAttributedString(string: "\n"))
        }
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shareContents = shareCases[indexPath.row]
        let activityVC = UIActivityViewController(activityItems: shareContents.map { $0.contents },
                                                  applicationActivities: nil)                          
        activityVC.popoverPresentationController?.sourceView = self.view                            
        activityVC.completionWithItemsHandler = { [ tableView] _, _, _, _ in 
            guard let selectedCell = tableView.indexPathForSelectedRow else {
                return
            }
                tableView.deselectRow(at: selectedCell,
                                      animated: true)
        }
        self.present(activityVC, animated: true, completion: nil)
    }
}

enum ShareItem {
    case text(String = "sample text")
    case url(URL = URL(string: "https://www.google.com")!)
    case image(UIImage = #imageLiteral(resourceName: "ezura.png"))
    case itemSource(item: Any, linkMetadata: LPLinkMetadata?)
    
    var contents: Any {
        switch self {
        case .text(let v as Any),
             .url(let v as Any),
             .image(let v as Any):
            return v
        case .itemSource(let item, let linkMetadata):
            return ShareActivityItemSource(item: item, linkMetadata: linkMetadata)
        }
    }
    
    var visualDescription: NSAttributedString {
        switch self {
        case .text(let text):
            return NSAttributedString(string: #"Text: "\#(text)""#)
        case .url(let url):
            return NSAttributedString(string: "URL: \(url.absoluteString)")
        case .image(let image):
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds.size = CGSize(width: 15, height: 15)
            let text = NSMutableAttributedString(string: "Image: ")
            text.append(NSAttributedString(attachment: attachment))
            return text
        case .itemSource(let item, let linkMetadata):
            let text = """
                       ItemSource:
                           - item: \(String(describing: item))
                           - metadata: \(linkMetadata?.debugDescription ?? "nil")
                       """
            return NSAttributedString(string: text)
        }
    }
}

class ShareActivityItemSource: NSObject, UIActivityItemSource {
    let item: Any
    let linkMetadata: LPLinkMetadata?
    
    init(item: Any, linkMetadata: LPLinkMetadata?) {
        self.item = item
        self.linkMetadata = linkMetadata
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        linkMetadata
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        item
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        item
    }
    
}

private extension LPLinkMetadata {
    func setTitle(title: String) -> LPLinkMetadata {
        self.title = title
        return self
    }
}

private extension LPLinkMetadata {
    var visualizeString: String {
        return """
        - title: \(title ?? "nil")
        - image: \(self.imageProvider?.suggestedName ?? "nil")
        - originalURL: \(self.originalURL?.debugDescription ?? "nil")
        """
    }
}
