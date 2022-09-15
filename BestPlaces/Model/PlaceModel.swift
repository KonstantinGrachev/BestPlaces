import Foundation
import UIKit

struct PlaceModel {
    var name: String
    var location: String?
    var type: String?
    var imageName: String?
    var image: UIImage?
    
    
    static var placesArray = ["First", "Second", "Third"]

    static func generatePlaces() -> [PlaceModel] {
        var places = [PlaceModel]()
        
        placesArray.forEach {
            places.append(PlaceModel(name: $0, location: "Moscow", type: "Cafe", imageName: $0))
            
        }
        
        return places
    }
    
}
