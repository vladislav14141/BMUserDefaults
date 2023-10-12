import Foundation
import Combine

/// A property wrapper for easily storing and retrieving values in UserDefaults.
/// - Example 1:
///
///     BMDefaultsCodable(.key) private var myValue: User?
///     myValue = User(name: "Anton")
///     print(myValue)
///
/// - Example 2:
///
///     let user = User(name: "Anton")
///     BMDefaultsCodable(.key).setValue(user)
///     let value = BMDefaultsCodable(.key).getValue()
///
/// - Example 3:
///
///     BMDefaultsCodable(.key) private var myValue: User?
///     $myValue.sink { print ($0) }
///

@propertyWrapper
public struct BMDefaultsCodable<Value: Codable> {

    public enum Key: String, CaseIterable {
        case key
    }

    private let key: String
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var notificationName: Notification.Name {
        Notification.Name("BMDefaultsCodable_\(key)")
    }

    public init(_ key: Key) {
        self.key = key.rawValue
    }

    public var wrappedValue: Value? {
        get {
            getValue()
        }
        set {
            setValue(newValue)
        }
    }

    public var projectedValue: AnyPublisher<Value?, Never> {
        getPublisher()
    }

    public func getValue() -> Value? {
        guard let data = userDefaults.object(forKey: key) as? Data else {
            return nil
        }

        do {
            return try decoder.decode(Value.self, from: data)
        } catch let err {
            debugPrint("Couldn't decode value: ", err)
            return nil
        }
    }

    public func setValue(_ value: Value?) {
        if let value {
            do {
                let data = try encoder.encode(value)
                userDefaults.setValue(data, forKey: key)
                notify(object: value)
            } catch let err {
                debugPrint("Couldn't encode value: ", err)
            }
        } else {
            removeValue()
        }
    }

    public func removeValue() {
        userDefaults.removeObject(forKey: key)
        notify(object: nil)
    }

    static public func removeAll() {
        Key.allCases.forEach {
            BMDefaultsCodable($0).removeValue()
        }
    }

    private func notify(object: Any?) {
        let notification = Notification(name: notificationName, object: object)
        NotificationCenter.default.post(notification)
    }

    private func getPublisher() -> AnyPublisher<Value?, Never> {
        NotificationCenter.default.publisher(for: notificationName)
            .map {
                $0.object as? Value
            }
            .prepend(getValue())
            .eraseToAnyPublisher()
    }
}
