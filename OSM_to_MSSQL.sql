DECLARE @Object as Int;
DECLARE @hr as Int;
DECLARE @Debug as Int = 0							-- Options are 0 = OFF, 1 = ON
DECLARE @json as table(Json_Table NVARCHAR(MAX))		
DECLARE @place as NVARCHAR(30) = 'Paris'			-- Set here your taget place
DECLARE @amenity as NVARCHAR(30) = 'cinema'			-- Set here your taget place
DECLARE @TableName as NVARCHAR(35) = 'OSM_' + @amenity + '_' + @place			
DECLARE @URL as VARCHAR(MAX)=FORMATMESSAGE('http://overpass-api.de/api/interpreter?data=[out:json];area[name="%s"]->.a;(node(area.a)[amenity="%s"];);out;',@place,@amenity) ;

EXEC @hr=sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT;					-- Use MSXML2.dll (https://support.microsoft.com/en-nz/help/269238/list-of-microsoft-xml-parser-msxml-versions)
IF @Debug = 1 BEGIN IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object END
Exec @hr=sp_OAMethod @Object, 'open', NULL, 'GET', @URL, 'false'				-- Your Web Service Url (invoked)
IF @Debug = 1 BEGIN IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object END 
EXEC @hr=sp_OAMethod @Object, 'send'											-- Send the call
IF @Debug = 1 BEGIN IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object END
EXEC @hr=sp_OAMethod @Object, 'responseText', @json OUTPUT						-- Catch the response
IF @Debug = 1 BEGIN IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object END
INSERT INTO @json (Json_Table) EXEC sp_OAGetProperty @Object, 'responseText'	-- Insert the response into Json_Table
IF @Debug = 1 BEGIN SELECT * FROM @json END

DROP TABLE IF EXISTS dbo. #TempTable
EXEC('DROP TABLE IF EXISTS dbo.' + @TableName)

CREATE TABLE #TempTable (
    [type] VARCHAR(10) NULL,
    [id]   NUMERIC NULL,
	[lat]   DECIMAL(9,6) NULL,
	[lon]   DECIMAL(9,6) NULL,
	[amenity]   NVARCHAR(20) NULL,
	[brand]   NVARCHAR(30) NULL,
	[brand_website]   VARCHAR(MAX) NULL,
	[name]   NVARCHAR(100) NULL,
	[operator]   NVARCHAR(50) NULL,
	[housenumber]   NVARCHAR(15) NULL,
	[street]   NVARCHAR(100) NULL,
	[postcode]   NVARCHAR(15) NULL,
	[city]   NVARCHAR(100) NULL,
	[phone]   NCHAR(30) NULL,
	[website]   VARCHAR(MAX) NULL,
	[email]   NVARCHAR(30) NULL,
	[opening_hours]   NVARCHAR(100) NULL,
	[wheelchair]   VARCHAR(10) NULL,
	[description]   NVARCHAR(max) NULL,
	[screen]   NVARCHAR(10) NULL  
)

INSERT INTO #TempTable 									

SELECT *  FROM OPENJSON((SELECT * FROM @json), N'$.elements')
WITH (   
      [type] VARCHAR(10) N'$.type'   ,
      [id]   NUMERIC N'$.id',
	  [lat]   DECIMAL(9,6) N'$.lat',
	  [lon]   DECIMAL(9,6) N'$.lon',
	  [amenity]   NVARCHAR(20) N'$.tags.amenity',
	  [brand]   NVARCHAR(30) N'$.tags.brand',
	  [brand_website]   VARCHAR(MAX) N'$.tags."brand:website"',
	  [name]   NVARCHAR(100) N'$.tags.name',
	  [operator]   NVARCHAR(50) N'$.tags.operator',
	  [housenumber]   NVARCHAR(15) N'$.tags."addr:housenumber"',
	  [street]   NVARCHAR(100) N'$.tags."addr:street"',
	  [postcode]   NVARCHAR(15) N'$.tags."addr:postcode"',
	  [city]   NVARCHAR(100) N'$.tags."addr:city"',
	  [phone]   NCHAR(30) N'$.tags.phone',
	  [website]   VARCHAR(MAX) N'$.tags.website',
	  [email]   NVARCHAR(30) N'$.tags.email',
	  [opening_hours]   NVARCHAR(100) N'$.tags.opening_hours',
	  [wheelchair]   VARCHAR(10) N'$.tags.wheelchair',
	  [description]   NVARCHAR(max) N'$.tags.description',
	  [screen]   NVARCHAR(10) N'$.tags.screen'    
)

EXEC sp_OADestroy @Object

DECLARE @sql AS NVARCHAR(1000)
SET @sql = 'SELECT * INTO ' + @TableName + ' FROM  #TempTable'
EXEC (@sql)

EXEC('SELECT * FROM ' + @TableName)
DROP TABLE IF EXISTS dbo. #TempTable
