
# AIR Package Manager (`apm`)

The AIR Package Manager allows management of AIR libraries and extensions and assits in creation of the application descriptor. 

---

>
> With the ever growing complexity of mobile development most other modern development platforms have a series of package management and merge tools to simplify the development process, particularly around adding third party components. These tools simplify the process of adding a component / library / plugin into an application, managing dependencies and merging manifests or plists.
>
> If AIR is to progress as a modern development tool I believe it is well past time that we have some similar tools at our disposal and as a community agree upon a series of standards around component descriptions. 
>
> I know there are propriatary tools that manage certain aspects of this process such as ane-lab and [Adobe Air Assistant](https://github.com/SaffronCode/Adobe-Air-Assistant) however these tools are highly customised to the integrated ANEs and would probably be better suited as UI components built upon a common standard.
>
> **This repository is designed to form the starting point of an open source "AIR package manager" - `apm`.**
> 
> This tool would be similar to:
> - `npm` (node package manager);
> - `gradle` (Gradle);
> - `mvn` (Maven);
> - `pip` (package installer for python);
> - `haxelib` (Haxelib) 
> 
> ... etc
>
> NOTE: EVERYTHING IN THIS REPOSITORY ARE INITIAL THOUGHTS AND ARE IN NO WAY FINAL
> 

--- 

The goals of `apm` are to:

- be command line tool for macOS and Windows;
- read from a central repository of packages (ANEs and SWCs);
- install (download) packages and dependencies;
- update packages and dependencies;
- assist in the creation of the application descriptor (particularly on iOS / Android to merge android manifest additions and iOS info additions / entitlements );



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

- [Building](Building.md)
- [Package Definition](PackageDefinition.md)
- [Package Repository](PackageRepository.md)
- [Generate App-Descriptor](GenerateAppDescriptor.md)


