// AÑADE ESTO ANTES DE UserEventOption y userEventOptions

enum UserEventDomain: String, Codable {
    case attention
    case speedProcessing // Corresponde a ProcessingSpeed
    case verbalFluency   // Corresponde a Fluency
    case memory          // Corresponde a WorkingMemory
    case executiveFunctions
    
    // Mapeo al GameType recomendado (para los juegos internos)
    var recommendedGame: GameType? {
        switch self {
        case .attention:
            return .attention
        case .speedProcessing:
            return .processingSpeed
        case .verbalFluency:
            return .fluency
        case .memory:
            return .workingMemory
        case .executiveFunctions:
            // Las funciones ejecutivas a menudo se entrenan con Memoria de Trabajo
            return .workingMemory 
        }
    }
    
    // Título descriptivo para la UI
    var title: String {
        switch self {
        case .attention: return "Atención Sostenida"
        case .speedProcessing: return "Velocidad de Procesamiento"
        case .verbalFluency: return "Fluidez Verbal"
        case .memory: return "Memoria de Trabajo"
        case .executiveFunctions: return "Funciones Ejecutivas"
        }
    }
}

// Estructura necesaria para que tu array funcione
struct UserEventOption: Codable {
    let id: String
    let text: String
    let domain: UserEventDomain // Ahora UserEventDomain existe
}

// Estructuras de recomendaciones externas (copiadas de la respuesta anterior)
struct ExternalRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let link: String?
}

typealias DomainRecommendations = [UserEventDomain: [ExternalRecommendation]]

// Catálogo hardcodeado de actividades externas
let hardcodedActivities: DomainRecommendations = [
    .attention: [
        ExternalRecommendation(
            title: "Meditació de Consciència Plena (Mindfulness)",
            description: "Practicar 10 minuts diaris ajuda a entrenar l'atenció sostinguda i la capacitat de reenfocament. Pots buscar una guia a YouTube.",
            link: "https://www.youtube.com/results?search_query=meditació+mindfulness+guia"
        ),
        ExternalRecommendation(
            title: "Escolta activa",
            description: "Escoltar sense fer res més una xerrada o un podcast amb temes complexos per millorar l'atenció selectiva i sostinguda.",
            link: nil
        )
    ],
    .speedProcessing: [
        ExternalRecommendation(
            title: "Sudoku fàcil sota temps",
            description: "Fer exercicis de Sudoku o KenKen ràpids per forçar l'escaneig visual i la presa de decisions. Cronometra't!",
            link: nil
        ),
        ExternalRecommendation(
            title: "Cerca ràpida de lletres",
            description: "Busca en una pàgina plena de text la lletra 'P' el més ràpid possible per entrenar l'exploració visual.",
            link: nil
        )
    ],
    .verbalFluency: [
        ExternalRecommendation(
            title: "Joc de paraules per categories",
            description: "Tria una lletra i una categoria (animals, aliments, etc.) i digues tantes paraules com puguis en 60 segons.",
            link: nil
        ),
        ExternalRecommendation(
            title: "Descripció d'imatges",
            description: "Obre una foto i descriu-la utilitzant 5 adjectius nous que no utilitzes normalment.",
            link: nil
        )
    ],
    .memory: [
        ExternalRecommendation(
            title: "Mètode de Loci (Palau de la Memòria)",
            description: "Aprèn a utilitzar la visualització espacial per recordar llistes d'elements, assignant-los a punts coneguts de la teva casa.",
            link: "https://www.google.com/search?q=mètode+loci+palau+memòria"
        ),
        ExternalRecommendation(
            title: "Revisió de llistes del supermercat",
            description: "Abans de sortir de casa, llegeix 10 ítems de la llista de la compra i intenta recordar-los en ordre invers.",
            link: nil
        )
    ],
    .executiveFunctions: [
        ExternalRecommendation(
            title: "Planificació del dia següent (la nit abans)",
            description: "Dedica 15 minuts a planificar el teu dia amb detall (tasques i temps estimat). No es tracta de fer-ho, sinó de planificar-ho.",
            link: nil
        ),
        ExternalRecommendation(
            title: "Exercicis de canvi de tasca",
            description: "Comença una tasca (A) durant 5 minuts, canvia a una tasca diferent (B) durant 5 minuts, i torna a la tasca (A). Entrena la flexibilitat cognitiva.",
            link: nil
        )
    ]
]