//
//  UIImageViewExtension.swift
//  reciplease -extension UIImageView-
//
//  Created by laurent aubourg on 12/11/2021.
//

import Foundation
import UIKit

//MARK: - load an image from url

extension UIImageView {
    func load(url: URL) {
        contentMode = .scaleAspectFill
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        load(url: url)
    }
}
