import Foundation
import Combine

/// A property wrapper for easily storing and retrieving values in UserDefaults.
/// - Example 1:
///
///     BMDefaults(.key) private var myValue: Bool?
///     myValue = true
///     print(myValue)
///
/// - Example 2:
///
///     BMDefaults(.key).setValue(true)
///     let value = BMDefaults(.key).getValue()
///
/// - Example 3:
///
///     BMDefaultsCodable(.key) private var myValue: Bool?
///     $myValue.sink { print ($0) }
///

@propertyWrapper
public struct BMDefaults<Value> {
    public enum Key: String, CaseIterable {
        case key
    }

    private let key: String
    private let userDefaults = UserDefaults.standard
    private var notificationName: Notification.Name {
        Notification.Name("BMDefaults_\(key)")
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
        userDefaults.object(forKey: key) as? Value
    }

    public func setValue(_ value: Value?) {
        userDefaults.setValue(value, forKey: key)
        notify(object: value)
    }

    public func removeValue() {
        userDefaults.removeObject(forKey: key)
        notify(object: nil)
    }

    static public func removeAll() {
        Key.allCases.forEach {
            BMDefaults($0).removeValue()
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
