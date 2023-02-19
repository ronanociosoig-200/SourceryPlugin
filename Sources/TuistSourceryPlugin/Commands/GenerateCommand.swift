import Foundation
import ArgumentParser
import ProjectAutomation
import PathKit

let project = "Project.swift"
let featuresPath = "Features"
let corePath = "Core"
let outputPathDefault = "Tests/Mocks"
let sourcesFolder = "Sources"
let templatePathDefault = "SourceryTemplates"
let template = "AutoMockable.stencil"
let outputFile = "AutoMockable.generated.swift"
let outputFileHeaderLines = 5

struct GenerateCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "generate-mocks",
        abstract: "Generates mocks using Sourcery for a given target."
    )
    
    @Option(
        name: .shortAndLong,
        help: "The path to the directory that contains the Project.swift. If not specified, the current directory is used. It will exit if the project is not found.",
        completion: .directory
    )
    var projectPath: String?
    
    @Option(
        name: .shortAndLong,
        help: "The path to the Sourcery template. If not specified it uses a default \(templatePathDefault). The template must be named \(template)",
        completion: .directory
    )
    var templatePath: String?
    
    @Option(
        name: .shortAndLong,
        help: "The path for the output. If not specified it will use a default \(outputPathDefault)",
        completion: .directory
    )
    var outputPath: String?
    
    @Argument(
        help: "The target that is checked for dependencies."
    )
    var target: String
    
    @Flag(name: .shortAndLong, help: "Show debug information.")
    var debug = false
    
    func run() throws {
        let error = "No such file or directory"
        let defaultPath: String
        
        if debug {
            let output = try safeShell("pwd")
            print("Current path: ")
            print(output)
            print("Path parameter: \(projectPath!)")
        }
        
        if let path = projectPath {
            if path.hasSuffix("/") {
                defaultPath = path
            } else {
                defaultPath = path + "/"
            }
        } else {
            if debug {
                print("Using the current director for the default path of the project")
            }
            defaultPath = "./"
        }
        
        if let path = projectPath {
            let output = try safeShell("file " + defaultPath + project)
            
            if output.contains(error) {
                print("Path Error: " + error + ". Ensure that \(project) can be found at the specified path: " + path )
                GenerateCommand.exit(withError: 1 as? Error)
            }
            
        } else {
            let output = try safeShell("file ./" + project)
            
            if output.contains(error) {
                print("Path Error: " + error + ". Ensure that \(project) can be found at the current directory, or use the project-path parameter.")
                GenerateCommand.exit(withError: 1 as? Error)
            }
        }
        
        let graph = try Tuist.graph(at: projectPath)
        let projectTargets = graph.projects.values.flatMap(\.targets)
        var dependencies = [TargetDependency]()
        var targetFound = false
        
        for projectTarget in projectTargets {
            if projectTarget.name == target {
                targetFound = true
                dependencies.append(contentsOf: projectTarget.dependencies)
            }
        }
        
        var targets = [target]
        
        if targetFound {
            if debug { print("Found target \(target) with dependencies") }
            if dependencies.count > 0 {
                for targetDependency in dependencies {
                    if case .target(let name) = targetDependency {
                        if debug { print("Dependency name: \(name)") }
                        targets.append(name)
                    }
                }
            }
            
            let output = outputPath ?? outputPathDefault
            let command = makeSourceryCommand(targets: targets, templatePath: templatePath ?? templatePathDefault, outputPath: output, rootPath: defaultPath)
            
            if debug { print("Command: \(command)") }
            
            let checkCommand = try safeShell("which sourcery")
            
            if checkCommand.contains("not found") {
                print("sourcery not found. Run brew install sourcery")
                GenerateCommand.exit(withError: 1 as? Error)
            } else {
                let sourceryOutput = try safeShell(command)
                print(sourceryOutput)
                
                let sourceryOutputFile = makeOutFilePath(rootPath: defaultPath,
                                                         featuresPath: featuresPath,
                                                         target: target,
                                                         outputPath: output,
                                                         outputFile: outputFile)
                
                injectTestableImportsInHeader(outputFile: sourceryOutputFile, targets: targets)
            }
            
        } else {
            print("Error: Target \(target) not found in project.")
            GenerateCommand.exit(withError: 1 as? Error)
        }
    }
    
    // Insert @testable import for each of the targets into the output file starting
    // from line 5, leaving the header intact.
    func injectTestableImportsInHeader(outputFile: String, targets: [String]) {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: outputFile) {
            do {
                let fileURL = URL(fileURLWithPath: outputFile)
                let fileContent = try String(String(contentsOf: fileURL))
                let fileLines: [String] = fileContent.components(separatedBy: "\n")
                var extendedFileContent = ""
                
                for line in 0...outputFileHeaderLines {
                    extendedFileContent.append(fileLines[line] + "\n")
                }
                
                for target in targets {
                    extendedFileContent.append("@testable import \(target)\n")
                }
                
                for line in outputFileHeaderLines...fileLines.count-1 {
                    extendedFileContent.append(fileLines[line] + "\n")
                }
                try extendedFileContent.write(to: fileURL, atomically: true, encoding: .utf8)
                
            } catch {
                print("Failed to read from or write to file: " + outputFile)
            }
        } else {
            print("Error: File doesn't exist at path: \(outputFile)")
        }
    }
    
    func makeSourceryCommand(targets: [String], templatePath: String, outputPath: String, rootPath: String) -> String {
        
        return "sourcery" + makeSourcesCommand(targets: targets, rootPath: rootPath) + makeTemplateCommand(path: rootPath + templatePath) + makeOutputCommand(target: targets.first!, outputPath: outputPath, rootPath: rootPath)
    }
    
    // This function only works is no feature module dependens on another feature
    func makeSourcesCommand(targets: [String], rootPath: String) -> String {
        var outputCommand = ""
        var feature = true
        
        for target in targets {
            let modulePath = (feature == true) ? featuresPath : corePath
            outputCommand.append(" --sources \(rootPath)\(modulePath)/\(target)/\(sourcesFolder)")
            feature = false
        }
        return outputCommand
    }
    
    func makeOutputCommand(target: String, outputPath: String, rootPath: String) -> String {
        return " --output \(rootPath)\(featuresPath)/\(target)/\(outputPath)"
    }
    
    func makeOutFilePath(rootPath: String,
                         featuresPath: String,
                         target: String,
                         outputPath: String,
                         outputFile: String) -> String {
        return "\(rootPath)\(featuresPath)/\(target)/\(outputPath)/\(outputFile)"
    }
    
    func makeTemplateCommand(path: String) -> String {
        return " --templates \(path)/\(template)"
    }
    
    @discardableResult // Add to suppress warnings when you don't want/need a result
    func safeShell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh") //<--updated
        task.standardInput = nil
        
        try task.run() //<--updated
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}
