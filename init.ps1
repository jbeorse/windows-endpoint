###### Script to initialize Aggregate to the customized parameters passed into the docker container ######

# Define paths and default parameters
$basePath = "C:\windows\temp"
$rootPath = "$($basePath)\ODKAggregate"
$settingsPath = "$($basePath)\ODKAggregate-settings"
$settingsJarPath = "$($rootPath)\WEB-INF\lib\ODKAggregate-settings.jar"
$settingsJarBasePath = "$($basePath)\ODKAggregate-settings.jar"
$securityPropertiesPath = "$($settingsPath)\security.properties"
$jdbcPropertiesPath = "$($settingsPath)\jdbc.properties"
$resultPath = "C:\Tomcat\apache-tomcat\webapps\"

$hostnameKey = "security`.server`.hostname="
$portKey = "security`.server`.port="

$authKey = "jdbc.url="

$schemaKey="jdbc.schema="

# Read environment variable inputs
$hostnameVal = $env:HOSTNAME
echo "Read hostname: $($hostnameVal)"

$portVal = $env:PORT
echo "Read port: $($portVal)"

$dbName = $env:DB_NAME
echo "Read db name: $($dbName)"

$schemaVal = $env:SCHEMA
echo "Read db schema: $($schemaVal)"

$dbUser = $env:DB_USER
echo "Read db user: $($dbUser)"

$dbPassword = $env:DB_PASS
echo "Read db password: $($dbPassword)"

$sqlServerAddress = $env:SQL_SRV_ADDR
echo "Read sql server address: $($sqlServerAddress)"

$sqlServerTrustCertificate = $env:SQL_SRV_TRUST_CERT
echo "Read sql server trust certificate: $($sqlServerTrustCertificate)"

$sqlServerHostnameInCertificate = $env:SQL_SRV_HOST_IN_CERT
echo "Read sql server hostname in certificate: $($sqlServerHostnameInCertificate)"

$user = $env:USERNAME
echo "Read user: $($user)"

$authVal = "jdbc:sqlserver://$($sqlServerAddress);database=$($dbName);user=$($dbUser);password=$($dbPassword);encrypt=true;trustServerCertificate=$($sqlServerTrustCertificate);hostNameInCertificate=$($sqlServerHostnameInCertificate);loginTimeout=30"
echo "Auth String: $($authVal)"

# Define functions for unzipping and rebuilding the war and jar files
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}
function Zip
{
	param([string]$inpath, [string]$zipfile)

    [System.IO.Compression.ZipFile]::CreateFromDirectory($inpath, $zipfile)
}

# Define a function to update a setting in a config file
function UpdateSetting
{
	param([string]$path, [string]$propKey, [string]$propVal)
	
	(Get-Content $path) | ForEach-Object { $_ -replace "$($propKey).+" , "$($propKey)$($propVal)" } | Set-Content $path
}

# Retrieve the old settings
Move-Item $settingsJarPath $settingsJarBasePath
Unzip $settingsJarBasePath $settingsPath

# Update the settings with the configured values
UpdateSetting $securityPropertiesPath $hostnameKey $hostnameVal
UpdateSetting $securityPropertiesPath $portKey $portVal
UpdateSetting $jdbcPropertiesPath $authKey $authVal
UpdateSetting $jdbcPropertiesPath $schemaKey $schemaVal

# Rebuid the settings jar
Zip $settingsPath $settingsJarPath

# Rebuild the root war
Move-Item $rootPath $resultPath


# Run tomcat
CMD /c "C:\Tomcat\apache-tomcat\bin\catalina.bat" run

# Run forever to keep docker alive
while($true)
{
    $i++
}