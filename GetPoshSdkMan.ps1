<#
	Paragon for the installation script is PsGet
#>

function Install-Posh-Sdk() {
    $poshSdkZipUrl = 'https://github.com/gomorpheus/posh-sdk/archive/master.zip'

    $poshSdkPath = Find-Module-Location

    try {
        # create temp dir
        $tempDir = [guid]::NewGuid().ToString()
        $tempDir = Join-Path -Path $env:TEMP -ChildPath $tempDir
        New-Item -ItemType Directory $tempDir | Out-Null

        # download current version
        $poshSdkZip = "$tempDir\posh-sdk-master.zip"
        Write-Output "Downloading posh-sdk from $poshSdkZipUrl"

        $client = (New-Object Net.WebClient)
        $client.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $client.DownloadFile($poshSdkZipUrl, $poshSdkZip)

        # unzip archive
        $shell = New-Object -com shell.application
        $shell.namespace($tempDir).copyhere($shell.namespace($poshSdkZip).items(), 0x14)

        # check if unzip successfully
        if ( Test-Path "$tempDir\posh-sdk-master" ) {
            if ( !(Test-Path $poshSdkPath) ) {
               New-Item -ItemType Directory $poshSdkPath | Out-Null
            }

            Copy-Item "$tempDir\posh-sdk-master\*" $poshSdkPath -Force -Recurse
            Write-Output "posh-sdk installed!"
            Write-Output "Please see https://github.com/gomorpheus/posh-sdk#usage for details to get started."
            Write-Warning "Execute 'Import-Module posh-sdk -Force' so changes take effect!"
        } else {
            Write-Warning 'Could not unzip archive containing posh-sdk. Most likely the archive is currupt. Please try to install again.'
        }
    } finally {
        # clear temp dir
        Remove-Item -Recurse -Force $tempDir
    }
}

function Find-Module-Location {
    $moduleDescriptor = Get-Module posh-sdk

    if ( $moduleDescriptor ) {
        return (Get-Item ($moduleDescriptor).Path).Directory.FullName
    } else {
        $modulePaths = @($Env:PSModulePath -split ';')
        # set module path to posh default
        $targetModulePath = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath WindowsPowerShell\Modules
        # if its not use select the first defined
        if ( $modulePaths -inotcontains $targetModulePath  ) {
            $targetModulePath = $modulePaths | Select-Object -Index 0
        }

        return "$targetModulePath\posh-sdk"
    }
}

Install-Posh-Sdk
