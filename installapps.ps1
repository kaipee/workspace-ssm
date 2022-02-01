function Install-Apps ($source = ($env:TEMP + "\deployed_apps"))
{ # Create %TEMP%\deployed_apps if it doesn't already exist
  If (!(Test-Path -Path $source -PathType Container)) {New-Item -Path $source -ItemType Directory | Out-Null}
  
  # Define AWS S3 creds
  $region="eu-west-1"
  $bucket=""
  $iamkey=""
  $iamsecret=""
  
  # Define array of packages and package details
  $packages = @(
    @{key='FortiClientSetup_6.4.6_x64.exe';
      Arguments=' /quiet /passive /norestart';
      Destination=$source},
    @{key='Pritunl.exe';
      Arguments=' /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /CLOSEAPPLICATIONS';
      Destination=$source}
  )
  
  # For every package in array: Define package name and file location
  foreach ($package in $packages) {
    $fileName = $package.key
    $destinationPath = $package.Destination + "\" + $fileName
    $Arguments = $package.Arguments
    
    # Download the package to the defined location
    If (!(Test-Path -Path $destinationPath -PathType Leaf)) {
      Write-Host "Downloading $fileName to $destinationPath"
      Read-S3Object -AccessKey $iamkey -SecretKey $iamsecret -Region $region -BucketName $bucket -Key $fileName -File $destinationPath
    }
  
    # Install the package using any commandline arguments
    Write-Output "Installing $fileName"
    Invoke-Expression -Command "$destinationPath $Arguments"
  }
  
}
  
# Call the function to install all defined apps
Install-Apps
