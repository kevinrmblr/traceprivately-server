# TracePrivatelyServer

Vapor 4 backend reference implementation of the COVID-19 contact tracing API.

This project is meant to be usable in combination with [TracePrivately](TracePrivately), an iOS reference implementation.

## Objectives

- Be compatible with the [TracePrivately app](https://github.com/CrunchyBagel/TracePrivately/blob/master/KeyServer/KeyServer.yaml)
- Log as little as possible about users/devices, only what is needed to prevent abuse

### Main features

- [x] Support for JSON and MessagePack
- [x] Basic webinterface toSee and reject/approve data input
- [ ] Optional authentication support, as privately as possible
- [ ] Push message support

### Privacy & Device Validation

Currently, there's no device validation implemented. Using this option will accept any token without validation. 

## Getting Started

Running is almost as simple as running the Vapor 4 starter app. Open the project in Xcode, set the *working directory* to be `[RepoDirectory]/WorkingDir` and run the app. A SQLite file will be created automatically. 

Optionally, some configuration can be changed in `configure.swift`.

### Prerequisites

To run the app, you can use:

- macOS running Xcode 11 or higher (tested using Xcode 11.4.1), or;
- [Ubuntu with Swift](https://docs.vapor.codes/4.0/install/ubuntu/) and the Vapor toolbox installed, or;
- [A dockerized version of the app](https://docs.vapor.codes/4.0/deploy/docker/)

### Running using XCode

- Open the project in Xcode
- Under Edit scheme -> Run -> Working Directory, point to `[RepoDirectory]/WorkingDir`
 - Without this step, the application will work, but the webppages will not be able to find the leaf templates
- Start the application

### Connecting the TracePrivately iOS App
- Open the app project
- In `KeyServer.plist`, change the *BaseURL* to be:
 - `http://localhost:8080/api/` for simulators
 - `http://[your-local-ip]:8080/api/` for real devices
- To allow connecting to localhost without ssl, don't forget to *Allow Arbitrary Loads* in the `Info.plist`.
- Run the app

## Contributing

Feel free to open issues or pull requests! 

## License

This project is licensed under the MIT License

## Acknowledgments

Thanks to [HendX](https://github.com/CrunchyBagel/TracePrivately/commits?author=HendX) for the iOS app!
