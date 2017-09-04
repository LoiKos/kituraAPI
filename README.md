<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.1/css/font-awesome.min.css">

# <a name="Overview"></a> Overview

This API as been design to be used to test Swift Kitura framework performances. 

This API is build to work with a PostgreSQL database and provide a way to interact with stores and products through an relational model.

<i class="fa fa-book" aria-hidden="true"></i>

## [Doc :book:](#Doc)  |  [Docker :whale:](#Docker)  |   [Code Coverage :shield:](#Cov) |  [Task Flow 🔨](#Tasks) 

# <a name="Doc"></a> Api Documentation

Jazzy docs => inside docs folder 

regenerate Jazzy docs : 

run ` jazzy ` and `.jazzy.yaml` will do the rest 

 [Stores](#Stores) | [Products](#Products) | [Stock](#Stock) | [Errors](#Error)

## <a name="Stores"></a> Stores

URL        :  ` api/v1/stores ` |  ` api/v1/stores/:id `

Method     :  ` GET `,` POST `  |  ` DELETE ` , ` PATCH ` ` GET `

URL Params :      none          |   id: required

Parameters :  ` Limit ` and ` Offet ` with GET  | None

Request body Structure : 
```swift
// Store obj
{
   "refStore": String   //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "vat":Double,        //  optional
   "currency":String,   //  optional
   "merchantkey":String //  optional
} 
```

Code 

#### Code: 200 OK

Content: 

```swift
// Store obj
{
   "refStore": String   //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "vat":Double,        //  optional
   "currency":String,   //  optional
   "merchantkey":String //  optional
} 
```
OR

```swift
[
   {
      "refStore": String   //  Auto generated do not modify
      "name": String,      //  required
      "picture":String,    //  optional
      "vat":Double,        //  optional
      "currency":String,   //  optional
      "merchantkey":String //  optional
   },{
      "refStore": String   //  Auto generated do not modify
      "name": String,      //  required
      "picture":String,    //  optional
      "vat":Double,        //  optional
      "currency":String,   //  optional
      "merchantkey":String //  optional
   }
   ,...
] 
```

#### Code: 201 CREATED

Content: 
```swift
// Store obj
{
   "refStore": String   //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "vat":Double,        //  optional
   "currency":String,   //  optional
   "merchantkey":String //  optional
} 
```

### <a name="Products"></a> Products

URL        :  ` api/v1/products ` |  ` api/v1/products/:id `

Method     :  ` GET `,` POST `  |  ` DELETE ` , ` PATCH ` ` GET `

URL Params :      none          |   id: required

Parameters :  ` Limit ` and ` Offet ` with GET  | None

Request body Structure : 
```swift
// Product obj
{
   "refproduct": String //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "creationdate":Date //  Auto generated do not modify
} 
```

Code 

#### Code: 200 OK

Content: 

```swift
// Product obj
{
   "refproduct": String //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "creationdate":Date //  Auto generated do not modify
} 
```
OR

```swift
[
   // Product obj
{
   "refproduct": String //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "creationdate":Date //  Auto generated do not modify
},{
   "refproduct": String //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "creationdate":Date //  Auto generated do not modify
} 
   ,...
] 
```

#### Code: 201 CREATED

Content: 
```swift
// Product obj
{
   "refproduct": String //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "creationdate":Date //  Auto generated do not modify
} 
```

### <a name="Stock"></a> Stock

URL        :  ` api/v1/stores/:storeId/products ` |  ` api/v1/stores/:storeId/products/:productId `

Method     :  ` GET `,` POST `  |  ` DELETE ` , ` PATCH ` ` GET `

URL Params :      storeId: required          |   storeId:   required, productId: required

Parameters :  ` Limit ` and ` Offet ` with GET  | None


Request body Structure : 
```swift
// Stock obj
{
   "product_refproduct": String //  Auto generated do not modify
   "product_name": String,      //  required
   "product_picture":String,    //  optional
   "product_creationdate":Date, //  Auto generated do not modify
   "refproduct":String,
   "refstore":String,
   "quantity":Int,
   "vat":Double,
   "priceht":Double,
   "status":String,
   "creationdate":Date,
   "lastupdate":Date
} 
```

Code 

#### Code: 200 OK

Content: 

```swift
// Stock obj
{
   "product_refproduct": String //  Auto generated do not modify
   "product_name": String,      //  required
   "product_picture":String,    //  optional
   "product_creationdate":Date, //  Auto generated do not modify
   "refproduct":String,
   "refstore":String,
   "quantity":Int,
   "vat":Double,
   "priceht":Double,
   "status":String,
   "creationdate":Date,
   "lastupdate":Date
} 
```
OR

```swift
[
   // Product obj
// Stock obj
{
   "product_refproduct": String //  Auto generated do not modify
   "product_name": String,      //  required
   "product_picture":String,    //  optional
   "product_creationdate":Date, //  Auto generated do not modify
   "refproduct":String,
   "refstore":String,
   "quantity":Int,
   "vat":Double,
   "priceht":Double,
   "status":String,
   "creationdate":Date,
   "lastupdate":Date
} ,{
   "product_refproduct": String //  Auto generated do not modify
   "product_name": String,      //  required
   "product_picture":String,    //  optional
   "product_creationdate":Date, //  Auto generated do not modify
   "refproduct":String,
   "refstore":String,
   "quantity":Int,
   "vat":Double,
   "priceht":Double,
   "status":String,
   "creationdate":Date,
   "lastupdate":Date
}
   ,...
] 
```

#### Code: 201 CREATED

Content: 
```swift
// Stock obj
{
   "product_refproduct": String //  Auto generated do not modify
   "product_name": String,      //  required
   "product_picture":String,    //  optional
   "product_creationdate":Date, //  Auto generated do not modify
   "refproduct":String,
   "refstore":String,
   "quantity":Int,
   "vat":Double,
   "priceht":Double,
   "status":String,
   "creationdate":Date,
   "lastupdate":Date
}
```

### <a name="Error"></a> API Error

#### Code: 400 BAD REQUEST 

Example : 

- [x] Empty JSON Body for POST or PATCH
          
- [x] Missing required properties POST

- [x] Wrong limit or offset ( < 0 )

#### Code: 404 NOT FOUND 

Example : Id not found in database  

#### Code: 500 INTERNAL SERVER ERROR 

# <a name="Docker"></a> Work with Docker

#### Required images :

```shell 
$ docker pull postgres
```
```shell 
$ docker pull swift
```

#### Launch database container : 
Run a docker container that contains a postgres database. With environnement variable you can specify the name of db, a username and a password
``` shell
$ docker run --name *name* -e POSTGRES_PASSWORD=*pwd* -e POSTGRES_USER=*userName* -e POSTGRES_DB=*dbName* -d postgres
```
#### Build image : 

```
Then lauch this command inside the project folder. If you want to set it  :

```shell 
$ docker build -t *name* . 
```

if your working behind a proxy you need to set proxy with '--build-arg' : 
```shell 
$ docker build --build-arg http_proxy=*yourproxy* --build-arg https-proxy=*yourhttpsproxy* -t *name* . 
```
please be careful about http_proxy and HTTP_PROXY you can have some issues if your not using it correctly. For example apt-get works fine with http_proxy but not with HTTP_PROXY

*name* correspond au nom que vous voulez donner à l'image

#### Launch kitura container : 

```shell
$ docker run -it --rm --link *databaseContainerName*:database -p 8080:8080 -v `pwd`:`pwd` -w `pwd` *name*
```

if your application recover database settings through environnement variable please use -e options with run commands : 

```shell
$ docker run -it --rm --link *databaseContainerName*:database -e DATABASE_USER=USER -p 8080:8080 -v `pwd`:`pwd` -w `pwd` *name*
```
you can also modify the 'Dockerfile' and add some lines to provide directly the ENV variables **(NOT RECOMMENDED)** :

```Dockerfile
# this is an example you have to make it match your application and database settings
ENV DATABASE_USER=USER
ENV DATABASE_DB=storeDB
ENV DATABASE_HOST=...
```

# <a name="Cov"></a> Code Coverage

*Coming* 

# <a name="Tasks"></a> Task Flow
- [x] Database connection
- [x] Stores routes
- [x] Products routes 
- [x] Stock routes 
- [x] Docker
- [x] Linux compatibility 
- [x] API docs
- [ ] Unit tests 
- [ ] CI 
- [ ] Code Cov

