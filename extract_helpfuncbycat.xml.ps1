# use Powershell to cd to Matlab directory first and run the script from there

## Find the source files

   Get-ChildItem .\ -Recurse helpfuncbycat.xml |  foreach {

  ## Remove the original  root folder

  $split = $_.Fullname  -split '\\'

  $DestFile =  $split[1..($split.Length - 1)] -join '\' 

  ## Build the new  destination file path

  $DestFile =  "C:\DestinationFolder\$DestFile"

  ## Copy-Item won't  create the folder structure so we have to 

  ## create a blank file  and then overwrite it

  $null = New-Item -Path  $DestFile -Type File -Force

  Copy-Item -Path  $_.FullName -Destination $DestFile -Force

}