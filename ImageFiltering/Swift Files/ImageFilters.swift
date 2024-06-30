import Foundation
import UIKit

/// Interface that specifies the image filters.
protocol Filters {
    static func amplifyColorFilter(image originalRGBA: RGBAImage, change color: ImageFilters.COLOR, by amount:Int, reverse:Bool) -> UIImage
    static func amplifyContrastFilter(image originalRGBA: RGBAImage, by contrast:Int) -> UIImage
    static func amplifyBrightnessFilter(image originalRGBA: RGBAImage, by amount:Int) -> UIImage
    static func greyFilter(image originalRGBA: RGBAImage, intensityFactor:Double) -> UIImage
    static func sepiaFilter(image originalRGBA: RGBAImage, intensityFactor:Double) -> UIImage
    static func sketchFilter(image originalRGBA: RGBAImage, intensityFactor:Double) -> UIImage
}

/// Public class containing the static methods that applies different image filters.
public class ImageFilters:Filters {
    
    /// Structure that defines which color to modify.
    public enum COLOR {
        case red
        case green
        case blue
    }

    /// This function returns the average colors RGB of a given image.
    /// - Parameter myRGBA: Image to get the average colors.
    /// - Returns: A list of the average colors in [R,G,B] form.
    static func getAvg(myRGBA:RGBAImage) -> [Int] {
        
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                let pixel = myRGBA.pixels[index]
                
                totalRed += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue += Int(pixel.blue)
            }
        }
        let count = myRGBA.width * myRGBA.height
        let avgRed = totalRed/count
        let avgGreen = totalGreen/count
        let avgBlue = totalBlue/count
        
        return [avgRed, avgGreen, avgBlue]
    }

    /// This function amplifies a given color from a given image. The process can be made in reverse order to remove that given color from the image.
    /// - Parameter originalRGBA: Image to amplify the colors.
    /// - Parameter change: Color to be amplified or removed.
    /// - Parameter amount: Value between 0 and 254.
    /// - Parameter reverse: True if the color will be removed, false to amplify the color.
    /// - Returns: Modified image as UIImage.
    public static func amplifyColorFilter(image originalRGBA: RGBAImage, change color: COLOR, by amount:Int, reverse:Bool) -> UIImage{
        
        var myRGBA = originalRGBA
        
        let avgRGB:[Int] = getAvg(myRGBA:myRGBA)

        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                let index = y * myRGBA.width + x
                var pixel = myRGBA.pixels[index]
                
                switch color {
                    case .red:
                        let redDiff = Int(pixel.red) - avgRGB[0]
                        if redDiff > 0 {
                            if reverse{
                                pixel.red = UInt8(max(0, min(255, avgRGB[0] + redDiff / amount)))
                            }else{
                                pixel.red = UInt8(max(0, min(255, avgRGB[0] + redDiff * amount)))
                            }
                            myRGBA.pixels[index] = pixel
                        }
                        break
                    case .green:
                        let greenDiff = Int(pixel.green) - avgRGB[1]
                        if greenDiff > 0 {
                            if reverse{
                                pixel.green = UInt8(max(0, min(255, avgRGB[1] + greenDiff / amount)))
                            }else{
                                pixel.green = UInt8(max(0, min(255, avgRGB[1] + greenDiff * amount)))
                            }
                            myRGBA.pixels[index] = pixel
                        }
                        break
                    case .blue:
                        let blueDiff = Int(pixel.blue) - avgRGB[2]
                        if blueDiff > 0 {
                            if reverse{
                                pixel.blue = UInt8(max(0, min(255, avgRGB[2] + blueDiff / amount)))
                            }else{
                                pixel.blue = UInt8(max(0, min(255, avgRGB[2] + blueDiff * amount)))
                            }
                            myRGBA.pixels[index] = pixel
                        }
                        break
                }
            }
        }

        return (myRGBA.toUIImage())!
    }

    /// This function amplifies the contrast of a given image.
    /// - Parameter originalRGBA: Image to amplify the colors.
    /// - Parameter contrast: Value between 0 and 254, used for the contrast factor calculation.
    /// - Returns: Modified image as UIImage.
    public static func amplifyContrastFilter(image originalRGBA: RGBAImage, by contrast:Int) -> UIImage{

        var myRGBA = originalRGBA
        
        var index = 0
        var newRed = 0
        var newGreen = 0
        var newBlue = 0
        var pixel:Pixel!
        var factor = 0
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                index = y * myRGBA.width + x
                pixel = myRGBA.pixels[index]
                
                factor = (259 * (contrast + 255)) / (255 * (259 - contrast))
                
                newRed = (factor * (Int(pixel.red) - 128)) + 128
                pixel.red = UInt8(max(0, min(255, newRed)))
                
                newGreen = (factor * (Int(pixel.green) - 128)) + 128
                pixel.green = UInt8(max(0, min(255, newGreen)))
                
                newBlue = (factor * (Int(pixel.blue) - 128)) + 128
                pixel.blue = UInt8(max(0, min(255, newBlue)))
                
                myRGBA.pixels[index] = pixel
                
            }
        }

        return (myRGBA.toUIImage())!
    }

    /// This function amplifies/removes the brightness of a given image.
    /// - Parameter originalRGBA: Image to amplify the colors.
    /// - Parameter amount: Value between -254 and 254, used for the brightness calculation.
    /// - Returns: Modified image as UIImage.
    public static func amplifyBrightnessFilter(image originalRGBA: RGBAImage, by amount:Int) -> UIImage {
        
        var myRGBA = originalRGBA
        
        var index = 0
        var newRed = 0
        var newGreen = 0
        var newBlue = 0
        var pixel:Pixel!
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                index = y * myRGBA.width + x
                pixel = myRGBA.pixels[index]
                            
                newRed = Int(pixel.red) + amount
                pixel.red = UInt8(max(0, min(255, newRed)))
                
                newGreen = Int(pixel.green) + amount
                pixel.green = UInt8(max(0, min(255, newGreen)))
                
                newBlue = Int(pixel.blue) + amount
                pixel.blue = UInt8(max(0, min(255, newBlue)))
                
                myRGBA.pixels[index] = pixel
                
            }
        }
        
        return (myRGBA.toUIImage())!
    }
    
    /// This function applies a grey filter to a given image.
    /// - Parameter originalRGBA: Image to amplify the colors.
    /// - Returns: Modified image as UIImage.
    public static func greyFilter(image originalRGBA: RGBAImage, intensityFactor:Double) -> UIImage {
        
        var myRGBA = originalRGBA
        
        var index = 0
        var newRed = 0
        var newGreen = 0
        var newBlue = 0
        var intensity = 0
        var pixel:Pixel!
        
        let tresholdedFactor = max(0.0, min(0.5, intensityFactor))
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                index = y * myRGBA.width + x
                pixel = myRGBA.pixels[index]
                
                intensity = (Int(pixel.red) + Int(pixel.green) + Int(pixel.blue)) / 3
                
                intensity = Int(Double(intensity) * (1 - tresholdedFactor))
                
                            
                newRed = intensity
                pixel.red = UInt8(max(0, min(255, newRed)))
                
                newGreen = intensity
                pixel.green = UInt8(max(0, min(255, newGreen)))
                
                newBlue = intensity
                pixel.blue = UInt8(max(0, min(255, newBlue)))
                
                myRGBA.pixels[index] = pixel
                
            }
        }
        
        return (myRGBA.toUIImage())!
    }
    
    /// This function applies a sepia filter to a given image.
    /// - Parameter originalRGBA: Image to amplify the colors.
    /// - Returns: Modified image as UIImage.
    public static func sepiaFilter(image originalRGBA: RGBAImage, intensityFactor:Double) -> UIImage {
        
        var myRGBA = originalRGBA
        
        var index = 0
        var newRed = 0
        var newRed_r = 0
        var newRed_g = 0
        var newRed_b = 0
        var newGreen = 0
        var newGreen_r = 0
        var newGreen_g = 0
        var newGreen_b = 0
        var newBlue = 0
        var newBlue_r = 0
        var newBlue_g = 0
        var newBlue_b = 0
        var pixel:Pixel!
        
        let tresholdedFactor = max(0.0, min(0.5, intensityFactor))
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                index = y * myRGBA.width + x
                pixel = myRGBA.pixels[index]
                            
                // Calcualte a predefined value for the red inside the sepia image.
                newRed_r = Int(0.393 * Double(Int(pixel.red)))
                newRed_g = Int(0.769 * Double(Int(pixel.green)))
                newRed_b = Int(0.189 * Double(Int(pixel.blue)))
                newRed =  newRed_r + newRed_g + newRed_b
                newRed = Int(Double(newRed) * (1 - tresholdedFactor))
                pixel.red = UInt8(max(0, min(255, newRed)))
                
                // Calcualte a predefined value for the green inside the sepia image.
                newGreen_r = Int(0.349 * Double(Int(pixel.red)))
                newGreen_g = Int(0.686 * Double(Int(pixel.green)))
                newGreen_b = Int(0.168 * Double(Int(pixel.blue)))
                newGreen =  newGreen_r + newGreen_g + newGreen_b
                newGreen = Int(Double(newGreen) * (1 - tresholdedFactor))
                pixel.green = UInt8(max(0, min(255, newGreen)))
                
                // Calcualte a predefined value for the blue inside the sepia image.
                newBlue_r = Int(0.272 * Double(Int(pixel.red)))
                newBlue_g = Int(0.534 * Double(Int(pixel.green)))
                newBlue_b = Int(0.131 * Double(Int(pixel.blue)))
                newBlue =  newBlue_r + newBlue_g + newBlue_b
                newBlue = Int(Double(newBlue) * (1 - tresholdedFactor))
                pixel.blue = UInt8(max(0, min(255, newBlue)))
                
                myRGBA.pixels[index] = pixel
                
            }
        }
        
        return (myRGBA.toUIImage())!
    }
    
    /// This function applies a sketch-like filter to a given image.
    /// - Parameter originalRGBA: Image to amplify the colors.
    /// - Returns: Modified image as UIImage.
    public static func sketchFilter(image originalRGBA: RGBAImage, intensityFactor:Double) -> UIImage {
        
        var myRGBA = originalRGBA
        
        var index = 0
        var intensity = 0
        var pixel:Pixel!
        
        let tresholdedFactor = max(0.0, min(0.5, intensityFactor))
        
        let intensityFactor = 120
        
        for y in 0..<myRGBA.height {
            for x in 0..<myRGBA.width {
                index = y * myRGBA.width + x
                pixel = myRGBA.pixels[index]
                
                intensity = (Int(pixel.red) + Int(pixel.green) + Int(pixel.blue)) / 3
                intensity = Int(Double(intensity) * (1 - tresholdedFactor))
                
                if (intensity > intensityFactor) {
                    // Apply white color if the pixel is too bright.
                    pixel.red = UInt8(255)
                    pixel.green = UInt8(255)
                    pixel.blue = UInt8(255)
                    
                    myRGBA.pixels[index] = pixel

                } else if (intensity > 100) {
                    // Apply grey color if the pixel is not that bright.
                    pixel.red = UInt8(150)
                    pixel.green = UInt8(150)
                    pixel.blue = UInt8(150)
                    
                    myRGBA.pixels[index] = pixel
                } else {
                    // Apply black color if the pixel is too dark.
                    pixel.red = UInt8(0)
                    pixel.green = UInt8(0)
                    pixel.blue = UInt8(0)
                    
                    myRGBA.pixels[index] = pixel
                }
            }
        }
        
        return (myRGBA.toUIImage())!
    }
}



