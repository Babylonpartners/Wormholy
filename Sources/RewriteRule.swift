public struct RewriteRule {
    public let urlPredicate: NSPredicate
    public let transform: (URLRequest) -> URLRequest

    public init(urlPredicate: NSPredicate, transform: @escaping (URLRequest) -> URLRequest) {
        self.urlPredicate = urlPredicate
        self.transform = transform
    }
}
