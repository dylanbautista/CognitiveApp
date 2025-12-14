import UIKit
import FirebaseAuth 

class SurveyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Propiedades
    
    // Usamos estilo .plain para tener control total sobre el espaciado y el header
    let tableView = UITableView(frame: .zero, style: .plain) 
    let surveyService = SurveyService()
    let cellIdentifier = "OptionCell"
    
    // Asegúrate de que esta variable global esté definida en tu proyecto
    let options = userEventOptions 
    
    // CLAVE: Set para manejar múltiples IDs seleccionados
    var selectedOptionIds: Set<String> = [] 
    var currentUserId: String?

    // MARK: - Ciclo de Vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Verificar el usuario logueado
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ERROR: Usuario no logueado.")
            // Redirigir a pantalla de login
            return
        }
        self.currentUserId = userId
        
        setupUI()
        loadTodaySelection() 
    }
    
    // MARK: - Configuración UI (Diseño Limpio y Abierto)

    private func setupUI() {
        // Título de navegación
        title = "Diari" 
        view.backgroundColor = .systemBackground // Fondo principal limpio
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        // Configuraciones de la Tabla
        tableView.separatorStyle = .singleLine // Separadores
        tableView.backgroundColor = .clear 
        tableView.sectionHeaderHeight = 0 
        tableView.sectionFooterHeight = 0 
        
        // Asignamos el header customizado y elegante
        tableView.tableHeaderView = createHeaderView()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(tableView)
        
        // Restricciones Auto Layout
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Header Customizado (Título Intuitivo y Elegante)

    private func createHeaderView() -> UIView {
        // El ancho se ignora, pero el alto es crucial para el layout
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 120))
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "✍️ Registra el teu dia"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold) 
        titleLabel.textColor = .label
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Selecciona els símptomes que has experimentat avui."
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        
        // Restricciones del Header (margen de 20px para el aire que solicitaste)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        // Es necesario llamar a layoutIfNeeded y systemLayoutSizeFitting para que Auto Layout
        // calcule la altura correcta del header antes de asignarlo a la tabla.
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
        let size = containerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        containerView.frame.size.height = size.height
        
        return containerView
    }
    
    // MARK: - Lógica de Datos

    private func loadTodaySelection() {
        guard let userId = currentUserId else { return }
        
        surveyService.getTodayLogEntry(for: userId) { [weak self] logEntry in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let entry = logEntry {
                    // Llenar el Set con los IDs guardados en el documento único
                    self.selectedOptionIds = Set(entry.optionIds) 
                }
                self.tableView.reloadData()
            }
        }
    }

    private func saveCurrentSelection() {
        guard let userId = currentUserId else { 
            showAlert(title: "Error", message: "No s'ha trobat l'usuari.")
            return
        }
        
        // Crear el UNICO log del día con el array de todas las opciones seleccionadas
        let logEntry = UserEventLog(
            userId: userId, 
            optionIds: Array(selectedOptionIds), 
            date: Date()
        )
        
        // Guardar/Actualizar el documento único en Firebase
        surveyService.saveOrUpdateLogEntry(logEntry) { result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Fallo al guardar: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource y Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let option = options[indexPath.row]
        
        // Diseño de la Celda
        cell.selectionStyle = .none 
        
        cell.textLabel?.text = option.text
        cell.textLabel?.numberOfLines = 0 
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular) 
        
        let isSelected = selectedOptionIds.contains(option.id)
        
        if isSelected {
            cell.accessoryType = .checkmark
            // Color de acento
            cell.tintColor = UIColor(red: 0.1, green: 0.6, blue: 0.9, alpha: 1.0) 
            cell.textLabel?.textColor = .black 
        } else {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .darkGray 
        }
        
        return cell
    }
    
    // Altura fija para dar el 'aire' y el espaciado
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 
    }
    
    // El footer/header de sección se mantiene a 0 para no interferir con el custom header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) 
        
        let optionId = options[indexPath.row].id
        
        // 1. Toggle (Añadir o Quitar)
        if selectedOptionIds.contains(optionId) {
            selectedOptionIds.remove(optionId)
        } else {
            selectedOptionIds.insert(optionId)
        }
        
        // 2. Guardar el estado completo de todas las selecciones
        saveCurrentSelection()
        
        // 3. Actualizar la UI
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}