# POSitive Scripts #

## Intro ##
This is a collection of Windows batch (.bat) and Microsoft SQL Server (.sql) scripts for use with the __POSitive Five Star__ and __POSitive Business Manager__ programs. If you find these useful or have any comments or questions, I'd love to hear from you: simply open an issue or email me at [tommy] AT (irdequipment) DOT com.


## Setup ##
### Basic ###
1. Clone the repository, or use the [Download Zip](https://github.com/airdrummingfool/POSitive-Scripts/archive/master.zip) link to download a copy of the repository and extract into an empty folder.
1. In the repository folder, create a file called `config.ini` with the following content (omit `[]`s):

	```
	username=[your SQLServer Username]
	password=[Your SQLServer Password]
	instance=[SQL Server Network Name]\[SQL Server Instance Name]
	autoquotes_db=[Name of the AutoQuotes DB]
	positive_db=[Name of your POSitive Master DB]
	site=[Your POSitive Site ID (likely '$$$$')]
	```

### Advanced ###
* In order for AQ SKU recommendations to work, you must put the AQ Vendor ID in the Vendor AutoSKU field in POSitive.
* If you plan to run these tools on computers other than the SQL Server, each computer must have the `sqlcmd` command installed. To get it, install the `SQL Server Command-Line Tools` that matches your version of the SQL Native Client (for us, it was the file `SQLServer2005_SQLCMD_x64.msi`, part of the [SQL Server 2005 Feature Pack](http://www.microsoft.com/en-us/download/details.aspx?id=15748)).
* In order for AutoQuotes data updating to work, you must have the FEDA Export Tool installed and configured. Contact AutoQuotes support to see if you have access to this tool.
* In order for image update to work, you must install [ImageMagick](http://imagemagick.org/script/binary-releases.php#windows).


## Description ##
### AQ-Item-Update.bat ###
This script updates POSitive items with data from AutoQuotes. You must have the FEDA Export Tool installed and configured to export product data to SQL Server into table called `Products` in the autoquotes_db (from config.ini).

### AQ-Pic-Update.bat ###
This script pulls images from AutoQuotes and stores them in POSitive. An item's image is only updated if the AQ image is newer than the item's existing image in POSitive (or if the item has no image). You must have the FEDA Export Tool installed and configured to export product images to SQL Server into table called `Pictures` in the AutoQuotes Export Database (`autoquotes_db` in config.ini).

### Next-POS-SKU.bat ###
Our showroom likes to use short, 4-5 digit numeric codes for items, which simplifies pricing and ringing up customers. These are stored in the `Alt. SKU` field in POSitive, and this script figures out the next one in sequence to use when creating a new item (ignoring Alt. SKUs that are similar to the Primary SKU or non-numeric).

### Update-AQ-SKU.bat ###
This script allows you to modify the AQ SKU of any item. It makes a best-guess recommendation of what the SKU should be based on the Vendor SKU and the Vendor ID (if the Vendor ID is stored in the Vendor AutoSKU field).

### Update-Station-Wallpaper.bat ###
This script allows you to modify the wallpaper settings of all POSitive stations at once. You can specify the path to an image file to use as the wallpaper (must be accessible to all stations, such as on a mapped drive or network path) as well as whether to tile or center that image.

### Advanced folder ###
This folder contains SQL scripts you can run directly via SQL Server Management Studio.
* `common-problems.sql`: Points out common problems and POSitive DB inconsistencies, such as bad AQ or Vendor SKUs, missing primary vendors, etc.
* `dupe-long-descriptions.sql`: Shows items that have the same long description as another item (in our case, this is often indicitave of a duplicated item).
* `fixable-aq-skus.sql`: This script will generate a best-guess AQ SKU for each item, compare it to the AQ SKU field, and show you which items likely have incorrect AQ SKUs. This script only works if you enter the AQ Vendor ID # in the Vendor AutoSKU field.


## Issues ##
This code is a work-in-progress, and probably has some bugs or corner cases that are not accounted for. If you have any problems, please open an issue or email me at [tommy] AT [irdequipment] DOT com. I will do my best to fix issues, but no promises.


## Copyright ##
All content and code is Copyright 2014 [International Restaurant Distributors, Inc](http://irdequipment.com).


## Disclaimer ##
These scripts have only been tested in limited scenarios, and not at all in a multi-site installation. We use all of them in production, but we in no way guarantee their functionality, or that they won't blow up your database. There is no warranty, express or implied, yadda yadda. Make regular backups, and don't use these scripts if you don't know what you're doing.
