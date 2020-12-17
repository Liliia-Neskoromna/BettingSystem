import Foundation


enum BettingSystemError: Error {
    case RegistrationError
    case isNotRegularUser
    case isNorAdminUser
    case noRegularUser
    case usersBetsIsEmpty
}

enum RegistrationError: Error {
    case userNameIsNotUnique
}

enum LoginErrors: Error {
    case userIsNotExist
    case userIsBanned
    case userIsAlreadyBanned
    case passwordIncorrect
    case loginFailed
}

enum Role {
    case admin
    case regular
}

protocol Admin {
    func browseAllRegularUsers() throws -> [User]
    func banUser(username: String) throws -> Bool
}

protocol RegularUser {
    func placeNewBet(newBet: String) throws
    func printListOfPlacedBets() throws -> [Bets]
}

struct User {
    
    var role:     Role
    var username: String
    var password: String
    var bets:     [Bets] = []
    var isBaned:  Bool = false
}

struct Bets {
    var bet:      String
}

class BettingSystem: Admin, RegularUser {

    static let shared = BettingSystem()
    
    var users = [
        "Ivan"  : User(role: Role.regular, username: "Ivan",  password: "fkjndk"),
        "Anton" : User(role: Role.regular, username: "Anton", password: "dfkjd"),
        "Oleg"  : User(role: Role.regular, username: "Oleg",  password: "sdfbdg"),
        "Artem" : User(role: Role.admin,   username: "Artem", password: "whtrlkn")
    ]

    var banUsers = [
        "Ivan"  : User(role: Role.regular, username: "Ivan",  password: "fkjndk"),
        "Anton" : User(role: Role.regular, username: "Anton", password: "dfkjd")
    ]
    
    var bets = [
        "EventOne"   : Bets(bet: "EventOne"),
        "EventTwo"   : Bets(bet: "EventTwo"),
        "EventThree" : Bets(bet: "EventThree")
    ]
    
    var activeUser      : User?
    var activeUsersBets : [Bets] = []
    
    private init() {}
    
    func register(role: Role, username: String, password: String) throws -> Bool {
        guard users.index(forKey: username) == nil    else { throw RegistrationError.userNameIsNotUnique }
        users[username] = User(role: Role.admin, username: username, password: password)
        return true
    }
    
    func login(username: String, password: String) throws -> Bool {
        guard let user = users[username]              else { throw LoginErrors.userIsNotExist }
        guard user.password == password               else { throw LoginErrors.passwordIncorrect }
        guard banUsers.index(forKey: username) == nil else { throw LoginErrors.userIsBanned }
        activeUser = user
        return true
    }
    
    func logout() {
        self.activeUser = nil
    }
    
    func placeNewBet(newBet: String) throws {
        guard let activeUser = activeUser             else { throw LoginErrors.loginFailed }
        guard activeUser.role == .regular             else { throw BettingSystemError.isNotRegularUser }
        bets[newBet] = Bets(bet: newBet)
    }
    
    func printListOfPlacedBets() throws -> [Bets] {
        guard let activeUser = activeUser             else { throw LoginErrors.loginFailed }
        guard activeUser.role == .regular             else { throw BettingSystemError.isNotRegularUser }

        bets.forEach {
            let temp = $0.value
            activeUsersBets.append(temp)
        }
        return activeUsersBets
    }
    
    func browseAllRegularUsers() throws -> [User] {
        guard let activeUser = activeUser             else { throw LoginErrors.loginFailed }
        guard activeUser.role == .admin               else { throw BettingSystemError.isNorAdminUser }
        let allRegularUser = users.values.filter({ $0.role == .regular }) as [User]
        return allRegularUser
    }
    
    func banUser(username: String) throws -> Bool{
        guard let activeUser = activeUser             else { throw LoginErrors.loginFailed }
        guard activeUser.role == .admin               else { throw BettingSystemError.isNorAdminUser }
        guard users[username] != nil                  else { throw LoginErrors.userIsNotExist }
        guard banUsers.index(forKey: username) == nil else { throw LoginErrors.userIsAlreadyBanned }
        users[username]?.isBaned = true
        return true
    }
}

var example = BettingSystem.shared

// MARK: - Test register
////success register
//do {
//    try example.register(role: Role.regular, username: "Ret", password: "kjerfre44")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}
////failed register
//do {
//    try example.register(role: Role.regular, username: "Ivan", password: "whttyhtyrlkn")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}


// MARK: - Test login
//do {
//    try example.login(username: "Artem", password: "whtrlkn")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}
//LoginErrors.userIsNotExist
//do {
//    try example.login(username: "1111", password: "whtrlkn")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}
//LoginErrors.passwordIncorrect
//do {
//    try example.login(username: "Artem", password: "111111")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}


// MARK: - Test logout
//example.logout()
//print(example.activeUser)


// MARK: - Test placeNewBet
//do {
//    try example.login(username: "Oleg", password: "sdfbdg")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}
//print(example.bets.count)
//do {
//    try example.placeNewBet(newBet: "EventFourth")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}
//print(example.bets.count)
//print(example.bets)


// MARK: - Test printListOfPlacedBets
//do {
//    try example.login(username: "Oleg", password: "sdfbdg")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}
//do {
//    try example.printListOfPlacedBets()
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}


// MARK: - Test browseAllRegularUsers
//do {
//    try example.login(username: "Artem", password: "whtrlkn")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}
//do {
//    try example.browseAllRegularUsers()
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}


// MARK: - Test banUser
//do {
//    try example.login(username: "Artem", password: "whtrlkn")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}
//do {
//    try example.banUser(username: "Oleg")
//} catch RegistrationError.userNameIsNotUnique {
//    print("Error.registrationError")
//}
