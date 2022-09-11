import UIKit

class ViewController: UIViewController {
    
    enum Constants {
        static let heightForRow: CGFloat = 85
    }
    
    private let placesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
        
    private var places = PlaceModel.generatePlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setDelegates()
        setConstraints()
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
    
    @IBAction private func addButtonTapped() {
        print("addButtonTapped works")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.heightForRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = placesTableView.dequeueReusableCell(withIdentifier: PlaceCell.placeCellId, for: indexPath) as? PlaceCell else { return UITableViewCell() }
        cell.configure(name: places[indexPath.row].name,
                       imageName: places[indexPath.row].image,
                       location: places[indexPath.row].location,
                       type: places[indexPath.row].type)
        return cell
    }
}

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

