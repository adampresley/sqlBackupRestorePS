[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMOExtended") | out-null

$userName = "apresley"
$itemsToBackup = ("database1", "database2")
$localBackupDirectory = "C:\backups"
$remoteBackupDirectory = "\\remoteServer\Backups"
$dt = get-date -format yyyyMMdd

$sourceInstanceName = "db1"
$sourceInstance = New-Object("Microsoft.SqlServer.Management.Smo.Server") $sourceInstanceName
$sourceDatabaseList = $sourceInstance.Databases

$targetInstanceName = "localhost"
$targetInstance = New-Object("Microsoft.SqlServer.Management.Smo.Server") $targetInstanceName
$targetDatabaseList = $targetInstance.Databases


#
# Iterate over each backup item and do it.
#
foreach ($backupItemName in $itemsToBackup) {
	#
	# Backup the database
	#
	Write-Output "Backing up $backupItemName"
	$db = $sourceDatabaseList.Item($backupItemName)
	$backupFileName = $backupItemName + "_" + $userName + "_" + $dt + ".bak"
	$dest = $remoteBackupDirectory + "\" + $backupFileName

	$backupAction = New-Object("Microsoft.SqlServer.Management.Smo.Backup")
	$backupAction.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database
	$backupAction.BackupSetName = "$backupItemName Backup"
	$backupAction.Database = $db.Name
	$backupAction.Devices.AddDevice($dest, "File")
	$backupAction.Incremental = 0
	$backupAction.SqlBackup($sourceInstance)

	#
	# Copy the backup to a local location and clean up the remote backup location
	#
	Copy-Item $dest $localBackupDirectory
	Remove-Item $dest

	# 
	# Now restore it
	#
	Write-Output "Restoring..."
	$db = $targetDatabaseList.Item($backupItemName)
	
	$restore = New-Object("Microsoft.SqlServer.Management.Smo.Restore")
	$restore.Database = $backupItemName
	$restore.ReplaceDatabase = 1
	$restore.Action = "Database"
	$restore.Devices.AddDevice($localBackupDirectory + "\" + $backupFileName, "File")
	$restore.SqlRestore($targetInstance)
}
