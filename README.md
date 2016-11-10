JSONExample
===========

More than an example of how Json serialization and deserialization works, this is an example on
how to read and store persistent data on iOS through a series of easy to use mechanisms.

The mechanisms demonstrated in this example are:

- JSONSerialization
- NSUserDefaults
- NSKeyedArchiver

Other mechanisms that are worth mentioning but are not demonstrated in this example are:

- CoreData
- SQLite
- Backend managed data

## UI considerations

This demo's UI consists in 3 parts:

- General information section
- Friends list
- Toolbar

The general information is just the name and the last name obtained from `example.json` in the
main bundle. This information never changes unless you change such Json file.

The Friends list is a list of friends that is initially loaded from `example.json` but is loaded
from the UserDefaults after it has been modified. To modify, the **add** button in the `Toolbar`
allows the user to input new frieds into the list.

## Code

Lines 50 to 53 can be removed to see the app loading from a local `json` file. Otherwise it works
the following way:

1. Application loads data from main bundle `example.json`. You can see this on the project
    resources.
2. Application updates friends list with data loaded from persistent data stored either through use
    of `NSKeyedArchiver` or `JSONSerialization`.
3. Every time you add a friend, the friends list is updated in 3 places: the `keyed` file through
    use of `NSKeyedArchiver`, the `example.json` file through use of `JSONSerialization`, and the
    `UserDefaults`.
4. The app never retrieves anything from `UserDefaults`, but code is commented out in `loadData`.