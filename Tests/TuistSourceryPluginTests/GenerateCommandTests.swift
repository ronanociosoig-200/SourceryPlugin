
import XCTest

@testable import TuistSourceryPlugin

final class GenerateCommandTests: XCTestCase {
    let sut = GenerateCommand()
    
    func testSourcesCommand() throws {
        sut.run()
        
        
    }
    
    func testParsing() throws {
        let generate = try XCTUnwrap(GenerateCommand.parseAsRoot([
            ""
        ]) as? GenerateCommand)
    }
}


