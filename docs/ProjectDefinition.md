
# Project

A project file defines an AIR application and it's dependencies. 

- version
- dependencies
- configuration variables to be inserted into dependencies

This project file will be used to download dependencies for an application and construct the application descriptor.


## Index

A file(s) containing information about the project. 


`project.apm`:

```json
{
    "id": "com.application.id",
    "name": "Example Application Prpject File",
    "version": "1.0",
    "configuration": {
        "packageParam": "12345678",
    },
    "dependencies": [
        "com.package.example:1.0",
        "com.package.another:1.5",
    ],
    "repositories": [
        { 
            "url": "https://airnativeextensions.com/repository", 
            "credentials" : { "username": "", "password": "" }
        }
    ]
}
```


This file will be created by 

```
apm create
```


