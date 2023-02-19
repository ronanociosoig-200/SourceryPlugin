import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let project = Project.app(name: "Pokedex",
                          platform: .iOS,
                          externalDependencies: [],
                          targetDependancies: [],
                          moduleTargets: [makeHomeModule(),
                                          makeCommonModule()
                                         ])

func makeHomeModule() -> Module {
    return Module(name: "Home",
                  moduleType: .feature,
                  path: "Home",
                  frameworkDependancies: [.target(name: "Common")],
                  frameworkResources: ["Sources/**/*.storyboard"],
                  testResources: [],
                  targets: [.framework, .unitTests])
}

func makeCommonModule() -> Module {
    return Module(name: "Common",
                  moduleType: .core,
                  path: "Common",
                  frameworkDependancies: [],
                  frameworkResources: [],
                  testResources: [],
                  targets: [.framework, .unitTests])
}
