import ProjectDescription

let reverseOrganizationName = "com.sonomos"

let featuresPath = "Features"
let corePath = "Core"
let appPath = "App"

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://tuist.io/docs/usage/helpers/

public enum uFeatureTarget {
    case framework
    case unitTests
    case exampleApp
}

public enum AppModuleType {
    case core
    case feature
    case app

    func path() -> String {
        switch self {
        case .core:
            return corePath
        case .feature:
            return featuresPath
        case .app:
            return appPath
        }
    }
}

public struct Module {
    let name: String
    let path: String
    let frameworkDependancies: [TargetDependency]
    let frameworkResources: [String]
    let testResources: [String]
    let targets: Set<uFeatureTarget>
    let moduleType: AppModuleType
    
    public init(name: String,
                moduleType: AppModuleType,
                path: String,
                frameworkDependancies: [TargetDependency],
                frameworkResources: [String],
                testResources: [String],
                targets: Set<uFeatureTarget> = Set([.framework, .unitTests])) {
        self.name = name
        self.moduleType = moduleType
        self.path = path
        self.frameworkDependancies = frameworkDependancies
        self.frameworkResources = frameworkResources
        self.testResources = testResources
        self.targets = targets
    }
}

extension Project {
    /// Helper function to create the Project for this ExampleApp
    public static func app(name: String,
                           platform: Platform,
                           externalDependencies: [String],
                           targetDependancies: [TargetDependency],
                           moduleTargets: [Module]) -> Project {
        
        let organizationName = "Sonomos.com"
        var dependencies = moduleTargets.map { TargetDependency.target(name: $0.name) }
        dependencies.append(contentsOf: targetDependancies)
        
        let externalTargetDependencies = externalDependencies.map {
            TargetDependency.external(name: $0)
        }
        
        dependencies.append(contentsOf: externalTargetDependencies)
        
        var targets = makeAppTargets(name: name,
                                     platform: platform,
                                     dependencies: dependencies)
        
        targets += moduleTargets.flatMap({ makeFrameworkTargets(module: $0, platform: platform) })

        return Project(name: name,
                       organizationName: organizationName,
                       targets: targets,
                       schemes: [])
    }
    
    public static func makeAppInfoPlist() -> InfoPlist {
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen"
        ]
        
        return InfoPlist.extendingDefault(with: infoPlist)
    }
    
    /// Helper function to create a framework target and an associated unit test target and example app
    public static func makeFrameworkTargets(module: Module, platform: Platform) -> [Target] {
        let frameworkPath = "\(module.moduleType.path())/\(module.path)"

        let frameworkResourceFilePaths = module.frameworkResources.map {
            ResourceFileElement.glob(pattern: Path("\(module.moduleType.path())/\(module.path)/" + $0), tags: [])
        }
        
        let testResourceFilePaths = module.testResources.map {
            ResourceFileElement.glob(pattern: Path("\(module.moduleType.path())/\(module.path)/Tests/" + $0), tags: [])
        }
        
        var targets = [Target]()
        
        if module.targets.contains(.framework) {
            let headers = Headers.headers(public: ["\(frameworkPath)/Sources/**/*.h"])
            
            targets.append(Target(name: module.name,
                                  platform: platform,
                                  product: .framework,
                                  bundleId: "\(reverseOrganizationName).\(module.name)",
                                  infoPlist: .default,
                                  sources: ["\(frameworkPath)/Sources/**"],
                                  resources: ResourceFileElements(resources: frameworkResourceFilePaths),
                                  headers: headers,
                                  dependencies: module.frameworkDependancies))
        }

        if module.targets.contains(.unitTests) {
            targets.append(Target(name: "\(module.name)Tests",
                                  platform: platform,
                                  product: .unitTests,
                                  bundleId: "\(reverseOrganizationName).\(module.name)Tests",
                                  infoPlist: .default,
                                  sources: ["\(frameworkPath)/Tests/**"],
                                  resources: ResourceFileElements(resources: testResourceFilePaths),
                                  dependencies: [.target(name: module.name)]))
        }
        
        return targets
    }
    
    /// Helper function to create the application target and the unit test target.
    public static func makeAppTargets(name: String,
                                      platform: Platform,
                                      dependencies: [TargetDependency]) -> [Target] {
        
        let mainTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: "\(reverseOrganizationName).\(name)",
            infoPlist: makeAppInfoPlist(),
            sources: ["\(appPath)/\(name)/Sources/**"],
            resources: ["\(appPath)/\(name)/Resources/**"
                       ],
            scripts: [
            ],
            dependencies: dependencies
        )

        return [mainTarget]
    }
}
