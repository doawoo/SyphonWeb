import WebKit
import SwiftUI

extension WKWebView {
    func getFrame(context: CGContext, texture: MTLTexture, region: MTLRegion) {
        
        context.interpolationQuality = CGInterpolationQuality.none
        layer!.isOpaque = true
        layer!.render(in: context)

        let data: UnsafeMutableRawPointer? = context.data
        
        texture.replace(
            region: region,
            mipmapLevel: 0,
            withBytes: data!,
            bytesPerRow: context.bytesPerRow
        )
    }
}