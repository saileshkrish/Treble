//
//  ColourArt.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-05.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit

struct ColourArt {
    var backgroundColor: UIColor!
    var primaryColor: UIColor!
    var secondaryColor: UIColor!
    var detailColor: UIColor!
}

class CountedColor {
    let color: UIColor
    let count: Int
    
    init(color: UIColor, count: Int) {
        self.color = color
        self.count = count
    }
}

extension UIColor {
    
    var isDarkColor: Bool {
        let RGB = CGColorGetComponents(self.CGColor)
        return (0.2126 * RGB[0] + 0.7152 * RGB[1] + 0.0722 * RGB[2]) < 0.5
    }
    
    var isBlackOrWhite: Bool {
        let RGB = CGColorGetComponents(self.CGColor)
        return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91) || (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
    }
    
    func isDistinct(compareColor: UIColor) -> Bool {
        let bg = CGColorGetComponents(self.CGColor)
        let fg = CGColorGetComponents(compareColor.CGColor)
        let threshold: CGFloat = 0.25
        
        if fabs(bg[0] - fg[0]) > threshold || fabs(bg[1] - fg[1]) > threshold || fabs(bg[2] - fg[2]) > threshold {
            if fabs(bg[0] - bg[1]) < 0.03 && fabs(bg[0] - bg[2]) < 0.03 {
                if fabs(fg[0] - fg[1]) < 0.03 && fabs(fg[0] - fg[2]) < 0.03 {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    func minimumSaturation(minSaturation: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return saturation < minSaturation ? UIColor(hue: hue, saturation: minSaturation, brightness: brightness, alpha: alpha) : self
    }
    
    func isContrastingColor(compareColor: UIColor) -> Bool {
        let bg = CGColorGetComponents(self.CGColor)
        let fg = CGColorGetComponents(compareColor.CGColor)
        
        let bgLum = 0.2126 * bg[0] + 0.7152 * bg[1] + 0.0722 * bg[2]
        let fgLum = 0.2126 * fg[0] + 0.7152 * fg[1] + 0.0722 * fg[2]
        let contrast = (bgLum > fgLum) ? (bgLum + 0.05)/(fgLum + 0.05):(fgLum + 0.05)/(bgLum + 0.05)
        
        return 1.6 < contrast
    }
    
}

private extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, alpha: Int) {
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
    }
    
}

extension UIImage {
    
    var averageColor: UIColor {
        let context = CIContext(options: nil)
        let convertImage = CoreImage.CIImage(image: self)
        let filter = CIFilter(name: "CIAreaAverage")!
        filter.setValue(convertImage, forKey: kCIInputImageKey)
        let processImage = filter.outputImage!
        let finalImage = context.createCGImage(processImage, fromRect: processImage.extent)
        return UIImage(CGImage: finalImage).getPixelColor(.zero)
    }
    
    func getPixelColor(pos: CGPoint) -> UIColor {
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        let red = Int(data[pixelInfo]), green = Int(data[pixelInfo+1]), blue = Int(data[pixelInfo+2]), alpha = Int(data[pixelInfo+3])
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func resize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.drawInRect(CGRect(origin: .zero, size: newSize))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func getColors() -> ColourArt {
        let ratio = self.size.width/self.size.height
        let r_width: CGFloat = 250
        return self.getColors(CGSize(width: r_width, height: r_width/ratio))
    }
    
    func getColors(scaleDownSize: CGSize) -> ColourArt {
        var result = ColourArt()
        
        let cgImage = self.resize(scaleDownSize).CGImage
        let width = CGImageGetWidth(cgImage)
        let height = CGImageGetHeight(cgImage)
        
        let bytesPerPixel: Int = 4
        let bytesPerRow: Int = width * bytesPerPixel
        let bitsPerComponent: Int = 8
        let randomColorsThreshold = Int(CGFloat(height)*0.01)
        let sortedColorComparator: NSComparator = { main, other in
            let m = main as! CountedColor, o = other as! CountedColor
            if m.count < o.count {
                return .OrderedDescending
            } else if m.count == o.count {
                return .OrderedSame
            } else {
                return .OrderedAscending
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let raw = malloc(bytesPerRow * height)
        let bitmapInfo = CGImageAlphaInfo.PremultipliedFirst.rawValue
        let ctx = CGBitmapContextCreate(raw, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        CGContextDrawImage(ctx, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), cgImage)
        let data = UnsafePointer<UInt8>(CGBitmapContextGetData(ctx))
        
        let leftEdgeColors = NSCountedSet(capacity: height)
        let imageColors = NSCountedSet(capacity: width * height)
        
        for x in 0..<width {
            for y in 0..<height {
                let pixel = ((width * y) + x) * bytesPerPixel
                let color = UIColor(
                    red: CGFloat(data[pixel+1])/255,
                    green: CGFloat(data[pixel+2])/255,
                    blue: CGFloat(data[pixel+3])/255,
                    alpha: 1
                )
                
                // A lot of albums have white or black edges from crops, so ignore the first few pixels
                if 5 <= x && x <= 10 {
                    leftEdgeColors.addObject(color)
                }
                
                imageColors.addObject(color)
            }
        }
        
        // Get background color
        var enumerator = leftEdgeColors.objectEnumerator()
        var sortedColors = NSMutableArray(capacity: leftEdgeColors.count)
        while let kolor = enumerator.nextObject() as? UIColor {
            let colorCount = leftEdgeColors.countForObject(kolor)
            if randomColorsThreshold < colorCount  {
                sortedColors.addObject(CountedColor(color: kolor, count: colorCount))
            }
        }
        sortedColors.sortUsingComparator(sortedColorComparator)
        
        var proposedEdgeColor: CountedColor
        if sortedColors.count > 0 {
            proposedEdgeColor = sortedColors.objectAtIndex(0) as! CountedColor
        } else {
            proposedEdgeColor = CountedColor(color: .blackColor(), count: 1)
        }
        
        if proposedEdgeColor.color.isBlackOrWhite && 0 < sortedColors.count {
            for color in sortedColors {
                let nextProposedEdgeColor = color as! CountedColor
                if (CGFloat(nextProposedEdgeColor.count)/CGFloat(proposedEdgeColor.count)) > 0.3 {
                    if !nextProposedEdgeColor.color.isBlackOrWhite {
                        proposedEdgeColor = nextProposedEdgeColor
                        break
                    }
                } else {
                    break
                }
            }
        }
        result.backgroundColor = proposedEdgeColor.color
        
        // Get foreground colors
        enumerator = imageColors.objectEnumerator()
        sortedColors.removeAllObjects()
        sortedColors = NSMutableArray(capacity: imageColors.count)
        let findDarkTextColor = !result.backgroundColor.isDarkColor
        
        while var kolor = enumerator.nextObject() as? UIColor {
            kolor = kolor.minimumSaturation(0.15)
            if kolor.isDarkColor == findDarkTextColor {
                let colorCount = imageColors.countForObject(kolor)
                sortedColors.addObject(CountedColor(color: kolor, count: colorCount))
            }
        }
        sortedColors.sortUsingComparator(sortedColorComparator)
        
        for curContainer in sortedColors {
            let kolor = (curContainer as! CountedColor).color
            
            if result.primaryColor == nil {
                if kolor.isContrastingColor(result.backgroundColor) {
                    result.primaryColor = kolor
                }
            } else if result.secondaryColor == nil {
                if !result.primaryColor.isDistinct(kolor) || !kolor.isContrastingColor(result.backgroundColor) {
                    continue
                }
                
                result.secondaryColor = kolor
            } else if result.detailColor == nil {
                if !result.secondaryColor.isDistinct(kolor) || !result.primaryColor.isDistinct(kolor) || !kolor.isContrastingColor(result.backgroundColor) {
                    continue
                }
                
                result.detailColor = kolor
                break
            }
        }
        
        let isDarkBackgound = result.backgroundColor.isDarkColor
        
        if result.primaryColor == nil {
            result.primaryColor = isDarkBackgound ? .whiteColor() : .blackColor()
        }
        
        if result.secondaryColor == nil {
            result.secondaryColor = isDarkBackgound ? .whiteColor() : .blackColor()
        }
        
        if result.detailColor == nil {
            result.detailColor = isDarkBackgound ? .whiteColor() : .blackColor()
        }
        
        // Release the allocated memory
        free(raw)
        
        return result
    }
    
}