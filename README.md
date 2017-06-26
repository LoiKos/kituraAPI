## [Overview](#Overview)  |  [Doc](#Doc)  |  [Code Coverage](#Cov)  |  [Docker](#Docker) |  [Task Flow](#Tasks) 

   [Stores](#Stores)

   [Products](#Products)
  
   [Stock](#Stock)
   
# <a name="Overview"></a> Overview


# <a name="Doc"></a> Api Documentation

<Additional information about your API call. Try to use verbs that match both request type (fetching vs modifying) and plurality (one vs multiple).>

# <a name="Stores"></a> Stores

URL : ` api/v1/stores `

Method: 
<div style="background-color:rgb(63, 127, 191);">
      <p>GET</p>
</div> 

| POST | DELETE | PUT

URL Params

<If URL params exist, specify them in accordance with name mentioned in URL section. Separate into optional and required. Document data constraints.>

Required:

id=[integer]

Optional:

photo_id=[alphanumeric]

Data Params

<If making a post request, what should the body payload look like? URL Params rules apply here too.>

Success Response:

<What should the status code be on success and is there any returned data? This is useful when people need to to know what their callbacks should expect!>

Code: 200 
Content: { id : 12 }
Error Response:

<Most endpoints will have many ways they can fail. From unauthorized access, to wrongful parameters etc. All of those should be liste d here. It might seem repetitive, but it helps prevent assumptions from being made where they should be.>

Code: 401 UNAUTHORIZED 
Content: { error : "Log in" }
OR

Code: 422 UNPROCESSABLE ENTRY 
Content: { error : "Email Invalid" }
Sample Call:

<Just a sample call to your endpoint in a runnable format ($.ajax call or a curl request) - this makes life easier and more predictable.>

Notes:

<This is where all uncertainties, commentary, discussion etc. can go. I recommend timestamping and identifying oneself when leaving comments here.>

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

