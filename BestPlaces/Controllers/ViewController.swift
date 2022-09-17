import UIKit
import RealmSwift
//test
class ViewController: UIViewController {
    
    private func settt() {
        
    }
    //MARK: - constants

    enum Constants {
        static let heightForRow: CGFloat = 85
    }
    
    //MARK: - UI objects

    private let placesTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = MainConstants.sideIndentation
        tableView.separatorInset.right = MainConstants.sideIndentation
        tableView.backgroundColor = .secondarySystemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
        
    var places: Results<PlaceModel>! = realm.objects(PlaceModel.self)

    //MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setDelegates()
        setConstraints()
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
    }
    
    private func setupViews() {
        navigationItem.title = "Best Places"
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        view.addSubview(placesTableView)
    }
    
    private func setDelegates() {
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placesTableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.placeCellId)
    }
    
    //MARK: - @IBActions

    @IBAction private func addButtonTapped() {
        let addPlaceController = AddViewController()
        addPlaceController.delegate = self
        navigationController?.pushViewController(addPlaceController, animated: true)
    }
}

//MARK: - table view


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places == nil ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.heightForRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = placesTableView.dequeueReusableCell(withIdentifier: PlaceCell.placeCellId, for: indexPath) as? PlaceCell else { return UITableViewCell() }
        cell.configure(model: places[indexPath.row])
        return cell
    }
    
    //MARK: Delete cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        let testAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.deletePlace(place)
            tableView.deleteRows(at: [indexPath], with: .none)
        }
        return UISwipeActionsConfiguration(actions: [testAction])
    }
    
    //TODO: Show details and editing place
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addNewPlaceViewController = AddViewController()
        addNewPlaceViewController.currentPlace = places[indexPath.row]
        navigationController?.pushViewController(addNewPlaceViewController, animated: true)
    }
}

//MARK: - constraints

extension ViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            placesTableView.topAnchor.constraint(equalTo: view.topAnchor),
            placesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - delegate AddViewController

extension ViewController: AddViewControllerDelegate {
    func addNewPlaceInModel(newPlace: PlaceModel?) {
        placesTableView.reloadData()
    }
}
