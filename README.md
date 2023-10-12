# BMUserDefaults

## BMUserDefaults is userDefaults wrapper. Allow to store, retrieve and observing values in userDefaults. 

### Save objects using variable: 
```swift
BMDefaults(.key) private var myValue: Bool?
myValue = true
print(myValue)
```

### Save objects without variable:
```swift
BMDefaults(.key).setValue(true)
let value = BMDefaults(.key).getValue()
```

### Observing objects variable using Combine:
```swift
BMDefaults(.key) private var myValue: Bool?
$myValue.sink {
    print($0)
}
```

### Remove all stored values:
```swift
BMDefaults.removeAll()
```

### Save codable models:
```swift
BMDefaultsCodable(.key) private var myValue: User?
myValue = User(name: "Anton")

print(myValue)

$myValue.sink {
    print($0)
}
```
