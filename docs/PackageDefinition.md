
# Package


A package defines a library and it's dependencies. 

- version
- location
- dependencies
- Android manifest additions
- iOS Info Additions and Entitlements
- required configuration variables to be inserted into the above


A package most likely will be made of a series of files in a structure with a main "index" file. 



## Index

A file(s) containing information about the library. 


`apmpackage.json`:

```json
{
    "id": "com.package.example",
    "name": "Example package definition",
    "url": "https://example.com/package/",
    "description": "An example of a package definition",
    "version":"1.0",
    "type": "swc",
    "dependencies": [
        { 
            "id": "com.package.dependency.a", 
            "version": "2.4"
        },
        { 
            "id": "com.package.dependency.b", 
            "version": "3.1"
        }
    ],
    "configuration": [
        "packageParam"
    ],
    "source": "https://example.com/package/swc/v1.0/com.package.example.swc"
}
```


