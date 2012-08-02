# sqlBackupRestorePS
My simple MS SQL Server backup and restore Powershell script.

## Instructions
Modify the following variables:

* $userName - This is only used in naming the backup file
* $itemsToBackup - An array of database names
* $localBackupDirectory - The path to a a local directory where backups are copied
* $remoteBackupDirectory - The remote path where remote database backups are made
* $sourceInstanceName - The name of the source/remote database instance
* $targetInstanceName - The name of the target/local database instance
