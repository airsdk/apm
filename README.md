
**NOTE: EVERYTHING IN THIS REPOSITORY IS CURRENTLY A WORK-IN-PROGRESS AND ARE IN NO WAY FINAL**


![](images/hero.png)


# AIR Package Manager (`apm`)

The AIR Package Manager allows management of AIR libraries and extensions and assists in creation of the application descriptor. 


It is comprised of a repository server and a command line client.


The goals of `apm` are to:

- be command line tool for macOS and Windows;
- read from a repository of packages (ANEs and SWCs);
- install (download) packages and dependencies;
- update packages and dependencies;
- assist in the creation of the application descriptor (particularly on iOS / Android to merge android manifest additions and iOS info additions / entitlements );


This project also aims to provide a repository server to be the store for packages.


Some examples:

### Search for a library

```
apm search starling
```


### Install a library:

```
apm install starling
```


### Update installed libraries:

```
apm update 
```


### Create descriptor

```
apm generate app-descriptor 
```



Documentation:

- [APM](docs/APM.md)
- [Package Definition](docs/PackageDefinition.md)
- [Package Repository](docs/PackageRepository.md)
- [Project Definition](docs/ProjectDefinition.md)
- [Generate App-Descriptor](docs/GenerateAppDescriptor.md)


