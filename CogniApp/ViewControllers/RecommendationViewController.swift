import UIKit

class RecommendationViewController: UIViewController {

    // MARK: - Propiedades
    var recommendation: Recommendation?
    
    // Servicios (Ajusta esto según donde obtengas el ID del usuario)
    private let surveyService = SurveyService()

    var currentUserId: String?

    // MARK: - Componentes de la UI
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let gameButton = UIButton(type: .system)
    private let externalActivitiesTitle = UILabel()
    private let tableView = UITableView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ERROR: Usuario no logueado.")
            // Redirigir a pantalla de login
            return
        }
        self.currentUserId = userId
        view.backgroundColor = .systemBackground
        setupUI()
        
        if recommendation == nil {
            fetchRecommendation()
        } else {
            updateUI(with: recommendation!)
        }
    }
    
    // MARK: - Configuración de la UI
    private func setupUI() {
        title = "Recomendació del Dia"
        
        // 1. Configuración de Labels y Botón
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        descriptionLabel.font = .systemFont(ofSize: 18)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        externalActivitiesTitle.font = .systemFont(ofSize: 20, weight: .bold)
        externalActivitiesTitle.text = "Altres Activitats Recomanades:"
        externalActivitiesTitle.textColor = .label
        externalActivitiesTitle.isHidden = true // Ocultar por defecto
        
        gameButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        gameButton.backgroundColor = .systemBlue
        gameButton.setTitleColor(.white, for: .normal)
        gameButton.layer.cornerRadius = 12
        gameButton.addTarget(self, action: #selector(gameButtonTapped), for: .touchUpInside)
        gameButton.isHidden = true // Ocultar por defecto
        
        // 2. Configuración del TableView para actividades externas
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ActivityCell.self, forCellReuseIdentifier: ActivityCell.reuseIdentifier)
        tableView.isScrollEnabled = false // Deshabilitar scroll si se usa dentro de un scroll view mayor
        tableView.allowsSelection = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        // 3. Stack View y Auto Layout (Usamos un UIScrollView para que el contenido sea desplazable)
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, 
            descriptionLabel, 
            gameButton,
            externalActivitiesTitle,
            tableView
        ])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.setCustomSpacing(15, after: externalActivitiesTitle)
        stackView.alignment = .fill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor), // Necesario para el scroll vertical

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            gameButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Lógica de datos y UI
    private func fetchRecommendation() {
        titleLabel.text = "Analitzant dades..."
        descriptionLabel.text = "Un moment, estem revisant els teus informes diaris..."
        gameButton.isHidden = true
        externalActivitiesTitle.isHidden = true

        surveyService.getTopRecommendation(for: currentUserId) { [weak self] result in
            DispatchQueue.main.async {
                if let rec = result {
                    self?.recommendation = rec
                    self?.updateUI(with: rec)
                } else {
                    self?.showNoDataUI()
                }
            }
        }
    }
    
    private func updateUI(with rec: Recommendation) {
        let domainTitle = rec.reasonDomain.title
        let frequency = rec.frequency
        
        titleLabel.text = "¿Vols millorar la teva \(domainTitle)?"
        descriptionLabel.text = """
        Hem observat que has reportat símptomes relacionats amb **\(domainTitle)** (\(frequency) vegada/es) recentment.

        Per això, et proposem les següents accions personalitzades.
        """
        
        // Si hi ha joc intern, mostra el botó
        if let game = rec.recommendedGame {
            gameButton.setTitle("Començar Joc de \(game.title)", for: .normal)
            gameButton.isHidden = false
        } else {
            gameButton.isHidden = true
        }
        
        // Si hi ha activitats externes, mostra el títol i recarrega la taula
        if !rec.externalActivities.isEmpty {
            externalActivitiesTitle.isHidden = false
            tableView.reloadData()
            // Ajustar l'altura de la taula al contingut
            tableView.layoutIfNeeded()
            let tableHeight = tableView.contentSize.height
            // Necessitaràs una constraint per a l'altura de la TableView si l'has posat directament al StackView
            // Per simplicitat en aquest exemple, assumirem que el StackView ho gestiona bé amb isScrollEnabled = false,
            // però en una app real, necessitaries una constraint d'altura per a la TableView o un hack.
            
            // Hack per forçar la TableView a tenir l'altura correcta dins del StackView:
            self.tableView.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
        }
    }

    private func showNoDataUI() {
        titleLabel.text = "Encara no hi ha dades suficients"
        descriptionLabel.text = "Necessitem almenys un dia de registre de símptomes per poder oferir una recomanació personalitzada. Recorda fer el teu registre diari!"
        gameButton.setTitle("Tornar a l'inici", for: .normal)
        gameButton.isHidden = false
        externalActivitiesTitle.isHidden = true
        recommendation = nil
    }
    
    // MARK: - Accions
    @objc private func gameButtonTapped() {
        if let rec = recommendation, rec.recommendedGame != nil {
            // Lógica para navegar al juego interno (ej. AttentionVC)
            print("Navegando al juego interno: \(rec.recommendedGame!.title)")
            // self.navigateToGame(rec.recommendedGame!) 
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension RecommendationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendation?.externalActivities.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCell.reuseIdentifier, for: indexPath) as! ActivityCell
        if let activity = recommendation?.externalActivities[indexPath.row] {
            cell.configure(with: activity)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let activity = recommendation?.externalActivities[indexPath.row], let linkString = activity.link, let url = URL(string: linkString) else {
            return
        }
        
        // Obrir el link al navegador
        UIApplication.shared.open(url)
    }
}

// MARK: - Cèl·lula Personalitzada
class ActivityCell: UITableViewCell {
    static let reuseIdentifier = "ActivityCell"
    
    private let activityTitle = UILabel()
    private let activityDescription = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        activityTitle.font = .systemFont(ofSize: 17, weight: .semibold)
        activityDescription.font = .systemFont(ofSize: 15)
        activityDescription.numberOfLines = 0
        activityDescription.textColor = .darkGray
        
        let stack = UIStackView(arrangedSubviews: [activityTitle, activityDescription])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with activity: ExternalRecommendation) {
        activityTitle.text = activity.title
        activityDescription.text = activity.description
        accessoryType = activity.link != nil ? .disclosureIndicator : .none
    }
}