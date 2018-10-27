<p align="center">
  <a href="https://github.com/francesco1119/OSM_to_MSSQL/issues"><img alt="issues" src="https://img.shields.io/github/issues/francesco1119/OSM_to_MSSQL.svg"></a>
  <a href="https://github.com/francesco1119/OSM_to_MSSQL/network"><img alt="network" src="https://img.shields.io/github/forks/francesco1119/OSM_to_MSSQL.svg"></a>
  <a href="https://github.com/francesco1119/OSM_to_MSSQL/stargazers"><img alt="stargazers" src="https://img.shields.io/github/stars/francesco1119/OSM_to_MSSQL.svg"></a>
  <a href="https://github.com/francesco1119/OSM_to_MSSQL/blob/master/LICENSE"><img alt="LICENSE" src="https://img.shields.io/github/license/francesco1119/OSM_to_MSSQL.svg"></a>
</p>
<p align="center">

  <h2 align="center">OSM_to_MSSQL</h2>
  <p align="center">Import OSM to MSSQL on SSMS and retrieve JSON through T-SQL with an HTTP request. BOOM!!!</p>

</p>

The Story
------

The idea to build a simple way to import Open Street Map to Microsoft SQL Server was born after [this post](https://gis.stackexchange.com/questions/172399/downloading-entire-osm-world-dataset-and-import-into-ms-sql) when I tragically realised that there was no current way to import easily and on the fly OSM to MSSQL.

The idea became even more challenging when people start blathering that it was impossible (why?) and that OSM **felt better** on MySQL or PostgreSQL database.

At that stage it became personal and I started coding. 

How to use
------

1) Open SSMS  and enable Ole Automation Procedures running this query:
`sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'Ole Automation Procedures', 1;  
GO  
RECONFIGURE;  
GO`
2) Download the query in attach and paste it into SSMS.
3) Edit `DECLARE @place as NVARCHAR(30) = 'Paris'` and instead of `Paris` put `Barcelona` or `Spain` or whatever and run the query

#### Troubleshooting:

- If you run into troubles set `DECLARE @Debug as Int = 1`. Options are 0 = OFF, 1 = ON
- Edit the `@URL` and paste there your favourite API call. You can find a few examples [here](http://harrywood.co.uk/maps/uixapi/xapi.html) or use [overpass-turbo.eu](http://overpass-turbo.eu/) to customize your query or cusult the [official API](https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_API_by_Example)
- In the `@URL` you can also set the [amenity](https://wiki.openstreetmap.org/wiki/Key:amenity).

How it works under the hood
------

Every time you run the query OSM_to_MSSQL creates a table called `'OSM_' + @place`.
Re-running the query will drop the old table and recreate a new one so yes, you can stick this query into a stored procedure and your data can be fresh new every day. 
How cool is that? 

Let's have an argument 
------

OSM_to_MSSQL is using `sp_OACreate` and `MSXML2.ServerXMLHTTP.6.0` to create the request.
Using `sp_OACreate` is considered bad practice and `MSXML2.ServerXMLHTTP.6.0` is deprecated.
Of you are **not OK** with that you can use [SQLCRL](http://www.sqlservercentral.com/articles/SQLCLR/177834/) but don't think not even for a second that this will be safer or it will query the API better or faster or it will provide you a safe place in Heaven.

Future developent
------

On spare time my TODO list is:

* Create the variable `@amenity`
* Brake the `@URL` into: 
    - node(area.a)[amenity=cinema]
    - way(area.a)[amenity=cinema]
    - rel(area.a)[amenity=cinema]
 


