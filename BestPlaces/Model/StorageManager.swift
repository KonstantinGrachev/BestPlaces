import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func addNewPlaces(_ place: PlaceModel?) {
        do {
            try realm.write({
                guard let place = place else {
                    return
                }
                realm.add(place)
            })
        } catch let error {
            print(error)
        }
    }
    
    static func deletePlace(_ place: PlaceModel?) {
        do {
            try realm.write({
                guard let place = place else {
                    return
                }
                realm.delete(place)
            })
        } catch let error {
            print(error)
        }
    }
}

