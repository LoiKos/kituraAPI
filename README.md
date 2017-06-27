## [Overview](#Overview)  |  [Doc](#Doc)  |  [Code Coverage](#Cov)  |  [Docker](#Docker) |  [Task Flow](#Tasks) 

   [Stores](#Stores)

   [Products](#Products)
  
   [Stock](#Stock)
   
# <a name="Overview"></a> Overview


# <a name="Doc"></a> Api Documentation

This API as been design to be used to tests the kitura framework performances. 
This API is made to work with a PostgreSQL Database and provide a way to interact with stores and products.

# <a name="Stores"></a> Stores

URL        :  ` api/v1/stores ` |  ` api/v1/stores/:id `

Method     :  ` GET `,` POST `  |  ` DELETE ` , ` PATCH ` ` GET `

URL Params :      none          |   id: required

Parameters :  ` Limit ` and ` Offet ` with GET  | None

Request body Structure : 
```Swift
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

### Code: 200 OK

Content: 

```Swift
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

```Swift
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

### Code: 201 CREATED

Content: 
```Swift
// Store obj
{
   "refStore": String   //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
} 
```

### Code: 400 BAD REQUEST 

### Code: 404 NOT FOUND 

### Code: 500 INTERNAL SERVER ERROR 


# <a name="Products"></a> Products
# <a name="Stock"></a> Stock



# <a name="Docker"></a> Work with Docker

*Coming Soon* 

# <a name="Cov"></a> Code Coverage

*Coming Soon* 

# <a name="Tasks"></a> Task Flow
- [x] database connection
- [x] Stores routes
- [x] Products routes 
- [x] Stock routes 
- [ ] Docker
- [ ] Linux compatibility 
- [ ] API docs
- [ ] Unit tests 
- [ ] CI 

