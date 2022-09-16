import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func addNewPlaces(_ place: PlaceModel?) {
        try! realm.write {
            guard let place = place else {
                return
            }
            realm.add(place)
        }
    }
    
}
