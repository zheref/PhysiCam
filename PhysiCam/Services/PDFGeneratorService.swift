import Foundation

import UIKit
import PDFKit

protocol IPDFGeneratorService {
    func getPDF(fromImageData imageData: Data) -> PDFDocument?
}

class PDFGeneratorService: IPDFGeneratorService, Loggable {
    
    static var logCategory: String { String(describing: Self.self) }
    
    func getPDF(fromImageData imageData: Data) -> PDFDocument? {
        let pdfDocument = PDFDocument()
        
        guard let image = UIImage(data: imageData) else {
            Self.logger.error("Could not get image from image data")
            return nil
        }
        
        guard let pdfPage = PDFPage(image: image) else {
            Self.logger.error("Could not create PDF page from image")
            return nil
        }
        
        pdfDocument.insert(pdfPage, at: 0)
        
        return pdfDocument
    }
    
}
