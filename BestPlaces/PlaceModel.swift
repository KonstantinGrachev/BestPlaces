import Foundation

struct PlaceModel {
    var name: String
    var location: String
    var type: String
    var image: String
    
    static var placesArray = ["First", "Second", "Third"]

    static func generatePlaces() -> [PlaceModel] {
        var places = [PlaceModel]()
        
        placesArray.forEach {
            places.append(PlaceModel(name: $0, location: "Moscow", type: "Cafe", image: $0))
            
        }
        
        return places
    }
    
}
