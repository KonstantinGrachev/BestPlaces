import RealmSwift

class PlaceModel: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var image: Data?
    
    var placesArray = ["First", "Second", "Third"]

    func savePlaces() {
        
        placesArray.forEach {
            let newPlace = PlaceModel()
            
            guard let image = UIImage(named: $0) else { return }
            let imageData = image.pngData()
            
            newPlace.name = $0
            newPlace.location = "Msk"
            newPlace.type = "Bar"
            newPlace.image = imageData
        }
    }
    
}
