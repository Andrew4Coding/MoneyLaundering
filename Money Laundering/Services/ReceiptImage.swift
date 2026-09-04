//
//  ReceiptImage.swift
//  Money Laundering
//
//  Created by Andrew Devito Aryo on 04/09/26.
//

import UIKit

enum ReceiptImage {
    static func compressedData(from image: UIImage, maxDimension: CGFloat = 2000) -> Data? {
        let longestSide = max(image.size.width, image.size.height)
        let scale = longestSide > maxDimension ? maxDimension / longestSide : 1
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let normalized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return normalized.jpegData(compressionQuality: 0.8)
    }
}
