$server = "${Application.Custom.ServerName}"
$port = [int]${Application.Custom.Port}

function Get-Certificate {
  <#
  .SYNOPSIS
      Used to return the primary SSL certificate of a server.
      Certificates must be verified against a CA root certificate. (cannot be self-signed).
  .DESCRIPTION
      Uses barebones TCP libraries to retrieve the primary SSL certificate of a server.  
      Does not do any further communications.
      Returns null in case of error.
  .PARAMETER ComputerName
    Name or IP Address of the computer to be connected to.
  .PARAMETER Port
    Port specified for the connection.  Port is mandatory.
  .EXAMPLE
    Get-Certificate -ComputerName www.google.com -Port 443
  #>
  param(
      [parameter(Mandatory=$true)] [string] $ComputerName,
      [parameter(Mandatory=$true)] [int] $Port
  )
  try {
      #Create a TCP Socket to the computer and a port number
    $tcpsocket = New-Object Net.Sockets.TcpClient($ComputerName, $Port)
    #write-host "Successfully Connected to $Computername on $Port" -ForegroundColor Green -BackgroundColor Black
    $tcpstream = $tcpsocket.GetStream()
    #Write-host "Reading SSL Certificate...." -ForegroundColor Yellow -BackgroundColor Black 
    $sslStream = New-Object System.Net.Security.SslStream($tcpstream,$false)
    #Force the SSL Connection to send us the certificate
    $sslStream.AuthenticateAsClient($ComputerName)
    #Read the certificate
    $certinfo = New-Object system.security.cryptography.x509certificates.x509certificate2($sslStream.RemoteCertificate)
    return $certinfo    
  }
  catch {
    #Write-Error "Message: Error Opening Connection: $Port on $ComputerName Unreachable"
    return $null
  }
}

$certinfo = Get-Certificate -ComputerName $server -Port $port

if ($null -ne $certinfo){  
  [DateTime]$Now = Get-Date
  [DateTime]$Expiration =[DateTime]::Parse($certinfo.NotAfter)
  $Days = (New-TimeSpan -Start $Now -End $Expiration).Days
  $Message = "Certificate on " + $server + ":" + $port + " expires in " + $Days + " days."
  $Value = $Days
  $exitcode=0
 }else{
  $Message = "Problem getting certificate from $server`:$port."
  $Value = ""
  $exitcode=1
}
Write-Host "Message.DaysLeft: $Message"
Write-Host "Statistic.DaysLeft: $Value"
Exit $exitcode
