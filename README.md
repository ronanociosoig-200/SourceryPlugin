
# Tuist Sourcery plugin

A plugin that extends [Tuist](https://tuist.io) and calls [Sourcery](https://github.com/krzysztofzablocki/Sourcery) for a given module.

For example: 
```
tuist sorcery --project-path <path/to/project> --template-path SourceryTemplates --output-path Tests/Mocks Home
``` 

In the example project `Home` has a dependency on `Common`, and therefore it will be included in the sources passed to Sourcery. 

## Usage

The plugin generates all the paths for all the sources

It makes an assumption that all the modules are under a path ./Core and that all the feature modules are under ./Features, and that no feature module can depend on another feature module. This is just a proof of concept and if you want to use it,  

### Arguments

| Argument   | Short  | Description  | Default  | Required  |
|:-:|:-:|:-:|:-:|:-:|
|`--project-path`|`-p`|The path to the directory that contains the Project.swift. If not specified, the current  directory is used. It will exit if the project is not found.|`./`| No |
|`--template-path`|`-t`|The path to the Sourcery template. If not specified it uses a default SourceryTemplates. The template must be named AutoMockable.stencil|SourceryTemplates| No |
|`--output-path`|`-o`|The path for the output. If not specified it will use a default Tests/Mocks.|Tests/Mocks| No|
|`--debug`|`-d`|Show debug information.| - | No |
|`--help`|`-h`|Show help information.| - | No |

## Testing The Project

Download and open Package.swift. Wait for the Swift packages to load, and for Xcode to work out this is a Mac project and have a target to run. Edit the scheme and add launch arguments

--project-path /path-to-project/Tests/Example/Pokedex/ Home

This will generate the mocks at Pokedex/Features/Home/Tests/Mocks/AutoMockable.generated.swift

As this source file is already added to the repo, delete it, and note that it is generated again. 

The binary generated is here: DerivedData/SourceryPlugin/Build/Products/Debug
