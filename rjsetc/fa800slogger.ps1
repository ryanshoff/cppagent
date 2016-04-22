
$client = new-object System.Net.WebClient;

$machine = "http://localhost:5000/Fanuc-4Axis-2Y"

$r=[xml]$client.DownloadString($machine + "/current");
$nextseq=$r.MTconnectStreams.Header.NextSequence
$r.MTconnectError.Errors.Error | foreach { if ($_ -ne $NULL) { write-Host "Error:" $_.InnerText $_.errorCode } }

While($nextseq -ne $NULL) {
	write-host "nextseq: " $nextseq $r.MTconnectStreams.Header.creationTime
    
    $r.MTconnectStreams.Streams.DeviceStream.ComponentStream | foreach {
        if( $_.component = "Path") {
            $_.Events.Execution | foreach { if ($_ -ne $NULL) { write-Host "Execution: " $_.InnerText " " $_.timestamp } }
            $_.Events.ControllerMode | foreach { if ($_ -ne $NULL) { write-Host "ControllerMode: " $_.InnerText " " $_.timestamp } }
            $_.Events.Block | foreach { if ($_ -ne $NULL) { write-Host "Block:" $_.InnerText $_.timestamp } }
            $_.Samples.PathFeedrate | foreach { if ($_ -ne $NULL -And $_.dataItemID -ne "path_feedrate") { write-Host $_.dataItemId $_.InnerText " " $_.timestamp } }
        }
        if( $_.component = "Device") {
            $_.Events.Availability | foreach { if ($_ -ne $NULL) { write-Host "Availability:" $_.InnerText $_.timestamp } }
        }
        if( $_.component = "Controller") {
            $_.Events.Message | foreach { if ($_ -ne $NULL) { write-Host "Message:" $_.InnerText $_.timestamp } }
        }
    }
        
#		Write-Output $d | out-file c:\temp\fa800s.txt -append

	Start-Sleep -s 5 

	$r=[xml]$client.DownloadString( $machine + "/sample?from=" + $nextseq );
    # + "&path=//DataItem[@type=""EXECUTION"" or @type=""CONTROLLER_MODE"" or @type=""AVAILABILITY"" or @type=""BLOCK"" or @type=""MESSAGE""]" );

    $nextseq=$r.MTconnectStreams.Header.NextSequence
    $r.MTconnectError.Errors.Error | foreach { if ($_ -ne $NULL) { write-Host "Error:" $_.InnerText $_.errorCode } }

}


