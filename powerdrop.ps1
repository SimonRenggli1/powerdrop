# Path: powerdrop.ps1
# Made By Simon Renggli
# Version 1.0

function powerdrop($option)
{
    $option = $option.ToLower()
    if ($option -eq "receive")
    {
        $port = 1337
        $localIP = (Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.PrefixOrigin -eq "Manual"}).IPAddress
        $listener = New-Object System.Net.HttpListener
        $hostAddr = "http://" + $localIP + ":" + $port + "/"
        $hostAddr = $hostAddr -replace " ", ""
        $listener.Prefixes.Add($hostAddr)

        $listener.Start()

        Write-Host "Listening for POST requests on " + $hostAddr

        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $request = $context.Request

            if ($request.HttpMethod -eq "POST") {
                $body = $request.InputStream
                $reader = New-Object System.IO.StreamReader($body, $request.ContentEncoding)
                $data = $reader.ReadToEnd()
                $reader.Close()
                $body.Close()

                Write-Host "Received Text:"
                Write-Host $data
            }

            $response = $context.Response
            $response.StatusCode = 200 
            $response.Close()
        }

        $listener.Stop()
    }
    elseif ($option -eq "send")
    {
        $text = Read-Host "Enter the text you want to send: "
        $ip = Read-Host "Enter the IP address of the receiver: "

        $port = 1337
        $uri = "http://" + $ip + ":" + $port + "/"
        $data = @{
            Text = $text
        }

        $response = Invoke-RestMethod -Uri $uri -Method POST -Body $data -ContentType "application/json"


        # Process the response
        Write-Host "Response status code: $($response.StatusCode)"
        Write-Host "Response body:"
        Write-Host $response.Content.Text

    }
    elseif ($option -eq "help")
    {
        Write-Host "Usage: powerdrop <option>"
        Write-Host "Options:"
        Write-Host "  receive"
        Write-Host "  send"
    }
    else
    {
        Write-Host "Invalid option. Use 'powerdrop help' for more information."
    }
}