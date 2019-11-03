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
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    private let shareCases: [[ShareItem]] = [
        [.text()],
        [.url()],
        [.image()],
        [.url(), .text()],
        [.text(), .image()]
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
    case url(URL = URL(string: "https://novel.line.me/")!)
    case image(UIImage = #imageLiteral(resourceName: "ezura.png"))
    
    var contents: Any {
        switch self {
        case .text(let v as Any),
             .url(let v as Any),
             .image(let v as Any):
            return v
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
        }
    }
}
