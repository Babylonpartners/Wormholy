public struct Filter {
    public let name: String
    public let urlPredicate: NSPredicate

    public init(name: String, urlPredicate: NSPredicate) {
        self.name = name
        self.urlPredicate = urlPredicate
    }
}
