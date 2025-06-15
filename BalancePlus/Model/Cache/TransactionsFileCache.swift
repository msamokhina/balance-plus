import Foundation

// MARK: - FileCacheProtocol

protocol FileCacheProtocol: AnyObject {
    associatedtype Item: Identifiable & Codable

    var items: [Item] { get }

    func add(_ item: Item) throws
    func remove(id: Item.ID) throws
    func save() throws
    func load() throws
}


// MARK: - TransactionsFileCache

final class TransactionsFileCache: FileCacheProtocol {
    typealias Item = Transaction

    // MARK: - Properties

    private(set) var items: [Transaction] = []
    private let fileName: String
    private let fileURL: URL

    // MARK: - Initialization

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
