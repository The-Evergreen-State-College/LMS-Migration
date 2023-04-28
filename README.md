# LMS-Migration
Lab Management Software migration, current, and looking into the future.

## How it works
Uses product-id to iterate through the web application to extract the product page.
The product web page is then parsed to extract elements.
Those elements are then parsed to create key-value pair.
Key value pair creates the variables used for the outfile.

All of the data content is stored within a web scrape folder, with a subfolder for each item. 


## Parameter

Can pass a single product as a pramater to update.


## How to manage cookies

### Manual
Use Firefox [Cookies manager](https://github.com/hrdl-github/cookies-txt) to extract session cookie for CAS authentication.

### Automated
[Logging on to CAS server through cURL](https://stackoverflow.com/questions/28267660/logging-on-to-cas-server-through-curl)
