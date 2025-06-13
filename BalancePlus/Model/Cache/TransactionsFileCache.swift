import Foundation

// MARK: - FileCacheProtocol

/// Протокол, определяющий базовый интерфейс для файлового кэша
protocol FileCacheProtocol: AnyObject {
    associatedtype Item: Identifiable & Codable // Элементы должны быть Identifiable и Codable
    
    /// Текущая коллекция элементов в кэше, доступна только для чтения извне
    var items: [Item] { get }
    
    /// Добавляет или обновляет элемент в кэше
    /// Если элемент с таким ID уже существует, он будет обновлен
    /// - Parameter item: Элемент для добавления/обновления
    /// - Throws: Ошибки, связанные с операцией
    func add(_ item: Item) throws
    
    /// Удаляет элемент из кэша по его идентификатору
    /// - Parameter id: Идентификатор элемента для удаления
    /// - Throws: Ошибки, связанные с операцией
    func remove(id: Item.ID) throws
    
    /// Сохраняет текущую коллекцию элементов в файл
    /// - Throws: Ошибки, связанные с сохранением в файл
    func save() throws
    
    /// Загружает коллекцию элементов из файла
    /// - Throws: Ошибки, связанные с загрузкой из файла
    func load() throws
}


// MARK: - TransactionsFileCache

/// Файловый кэш для хранения коллекции финансовых транзакций в JSON файле.
/// Использует `JSONSerialization` для преобразования `Transaction` в/из Foundation Objects.
final class TransactionsFileCache: FileCacheProtocol {
    typealias Item = Transaction

    // MARK: - Properties

    /// Коллекция транзакций
    /// Доступна для чтения извне, но не для прямого изменения
    private(set) var items: [Transaction] = []
    /// Имя файла для сохранения/загрузки
    private let fileName: String
    /// Полный путь к файлу в кэше
    private let fileURL: URL

    // MARK: - Initialization

    /// Инициализирует кэш для транзакций
    /// - Parameter fileName: Имя JSON файла, в котором будут храниться транзакции
    init(fileName: String = "transactions.json") {
        self.fileName = fileName
        
        if let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let directoryURL = appSupportDirectory.appendingPathComponent("BalancePlusCache")
            self.fileURL = directoryURL.appendingPathComponent(fileName)
            
            // Создаем дерикторию, если еще нет
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating cache directory: \(error)")
            }
        } else {
            // Если не удалось найти Application Support Directory, используем временную директорию
            let tempDirectory = FileManager.default.temporaryDirectory
            self.fileURL = tempDirectory.appendingPathComponent(fileName)
            print("Warning: Using temporary directory for cache, could not find Application Support Directory.")
        }
        
        // Поробуем загрузить данные
        try? load()
    }

    // MARK: - Public Methods

    /// Добавляет новую транзакцию в кэш или обновляет существующую
    /// - Parameter item: Транзакция для добавления или обновления
    /// - Throws: `FileCacheError.serializationError` если не удалось сериализовать/десериализовать
    func add(_ item: Transaction) throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            // Если транзакция с таким ID уже есть, обновляем её
            items[index] = item
            print("TransactionsFileCache: Транзакция с ID \(item.id) обновлена")
        } else {
            // Если транзакции с таким ID нет, добавляем новую
            items.append(item)
            print("TransactionsFileCache: Транзакция с ID \(item.id) добавлена")
        }
        try save()
    }

    /// Удаляет транзакцию из кэша по её идентификатору
    /// - Parameter id: ID транзакции для удаления
    /// - Throws: `FileCacheError.notFound` если транзакция не найдена,
    ///           `FileCacheError.serializationError` если не удалось сохранить изменения
    func remove(id: Transaction.ID) throws {
        let initialCount = items.count
        items.removeAll { $0.id == id }

        if items.count == initialCount {
            print("TransactionsFileCache: Транзакция с ID \(id) не найдена для удаления")
            throw FileCacheError.notFound(message: "Транзакция с ID \(id) не найдена")
        } else {
            print("TransactionsFileCache: Транзакция с ID \(id) удалена")
        }
        try save()
    }

    /// Сохраняет текущую коллекцию транзакций в JSON файл
    /// Преобразует `[Transaction]` в `[Any]` (массив Foundation Objects), затем в `Data` и записывает в файл
    /// - Throws: `FileCacheError.serializationError` если кодирование/сериализация не удалась,
    ///           `FileCacheError.fileWriteError` если запись в файл не удалась
    func save() throws {
        let jsonObjects = items.map { $0.jsonObject }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObjects, options: .prettyPrinted)
            try data.write(to: fileURL, options: .atomicWrite)
            print("TransactionsFileCache: Успешно сохранено \(items.count) транзакций в \(fileURL.lastPathComponent)")
        } catch let encodingError as EncodingError {
            throw FileCacheError.serializationError(message: "Ошибка кодирования JSON: \(encodingError)")
        } catch let serializationError as NSError {
            throw FileCacheError.serializationError(message: "Ошибка JSON сериализации: \(serializationError)")
        } catch {
            throw FileCacheError.fileWriteError(message: "Ошибка записи файла: \(error)")
        }
    }

    /// Загружает коллекцию транзакций из JSON файла
    /// Читает `Data` из файла, преобразует в `[Any]`, а затем в `[Transaction]`
    /// - Throws: `FileCacheError.fileReadError` если чтение файла не удалось,
    ///           `FileCacheError.serializationError` если десериализация не удалась
    func load() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("TransactionsFileCache: Файл кэша не найден по пути: \(fileURL.lastPathComponent)")
            items = [] // Если файла нет, создаем пустой список
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            guard let jsonObjects = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
                throw FileCacheError.serializationError(message: "Некорректный формат JSON: ожидался массив")
            }
            
            var loadedTransactions: [Transaction] = []
            for object in jsonObjects {
                if let transaction = Transaction.parse(jsonObject: object) {
                    loadedTransactions.append(transaction)
                } else {
                    print("TransactionsFileCache: Warning: не удалось распарсить один из объектов в Transaction")
                }
            }
            
            self.items = loadedTransactions
            print("TransactionsFileCache: Успешно загружено \(items.count) транзакций из \(fileURL.lastPathComponent)")
        } catch let decodingError as DecodingError {
            throw FileCacheError.serializationError(message: "Ошибка декодирования JSON: \(decodingError)")
        } catch let serializationError as NSError {
            throw FileCacheError.serializationError(message: "Ошибка JSON десериализации: \(serializationError)")
        } catch {
            throw FileCacheError.fileReadError(message: "Ошибка чтения файла: \(error)")
        }
    }

    // MARK: - Internal Helpers (для отладки)

    /// Удаляет файл кэша
    func clearCacheFile() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("TransactionsFileCache: Файл кэша не существует, нечего удалять")
            return
        }
        do {
            try FileManager.default.removeItem(at: fileURL)
            items = []
            print("TransactionsFileCache: Файл кэша \(fileURL.lastPathComponent) успешно удален")
        } catch {
            throw FileCacheError.fileWriteError(message: "Ошибка при удалении файла кэша: \(error)")
        }
    }
}

// MARK: - FileCacheError

/// Ошибки для кэша
enum FileCacheError: Error, LocalizedError {
    case serializationError(message: String) // Ошибки при преобразовании в/из JSON
    case fileReadError(message: String)      // Ошибки чтения файла
    case fileWriteError(message: String)     // Ошибки записи файла
    case notFound(message: String)           // Элемент не найден

    var errorDescription: String? {
        switch self {
        case .serializationError(let msg): return "Ошибка сериализации данных: \(msg)"
        case .fileReadError(let msg): return "Ошибка чтения файла: \(msg)"
        case .fileWriteError(let msg): return "Ошибка записи файла: \(msg)"
        case .notFound(let msg): return "Элемент не найден: \(msg)"
        }
    }
}
