# Backing up and Restoring Nextcloud

If you're using our Nextcloud Argo CD App of Apps, then you're already backing up your data to a remote s3 instance of some sort. This directory is just meant to help you test that the backups are there and working, as well as provide a script for helping with restores.

# Restoring Nextcloud from K8up (Restic) Backups

*Prereq*:
- restic
- postgresql

Assuming the entire cluster is gone, first we'll need a new persistent volume and the secrets for backblaze B2 as well as the restic repo password. In our case, since this is all in GitLab, from the root dir of the repo, we can run:

```bash
kubectl apply -f manifests/persistence/
kubectl apply -f manifests/external_secrets/
```

After that, we can run a restore job for the files. You can grab the snapshot ID you want to restore from the `restic snapshots` command. You’ll need the credentials from the secrets and the encryption key. With that information you can configure restic. This example assumes you're using Backblaze B2:

```bash
# nc-bkups is the name of YOUR region and  b2 bucket
export RESTIC_REPOSITORY="s3:https://s3.yourregion.backblazeb2.com/yourb2bucketname"

# in this file, you need to have a single line with your restic repo password. Make sure it's `chmod`ed to 600 and has only your user as the group.
 export RESTIC_PASSWORD_FILE=/etc/restic-password

# the space before these is so that they're not saved in your history
 export AWS_ACCESS_KEY_ID="002x11f5584568299998888zz"
 export AWS_SECRET_ACCESS_KEY="K012eFG6971SshigqrS97QC1dBfd"
```

Example output from the `restic snapshots` command after exporting the above:

```bash
$ restic snapshots
repository h897r543 opened (repository version 1) successfully, password is correct
ID        Time                 Host        Tags        Paths
--------------------------------------------------------------------------------
435489df  2022-09-06 23:45:11  nextcloud               /nextcloud-postgresql.sql
54389dvc  2022-09-06 23:45:21  nextcloud               /data/nextcloud-files
--------------------------------------------------------------------------------
2 snapshots
```

If you want the latest snapshot, you can just run this, otherwise, first edit the `spec.snapshot` parameter to be the ID you of your snapshot and uncomment it.

```bash
kubectl apply -f k8up_restores/restore_files.yaml
```

Then your files should be back, but your database is not yet available, and not as easy to fix. Referencing the database dump snapshot above, you can do...

```bash
# puts nextcloud-postgresql.sql into /tmp/ on local computer
restic restore 435489df --target /tmp
```

There is also a script in this directory called `restore.sh` that you can use
to do most of this, just create a file called `.env` with the shell environment
variables from above and then run the script.


# Caveats

## B2 lockout D:

This could all fail if you're at any of your caps on your b2 account.
Check the caps on your B2 account first.

## 2FA is broken

sometimes TOTP doesn't restore correctly locking you and your users out of nextcloud. Here's a few tips.

### Regenating a one time token

If you as an admin still have access to the nextcloud web interface or you can still run OCC commands, try generating a one time code for your user using the Nextcloud 2FA Admin Support App using these [docs](https://nextcloud-twofactor-admin.readthedocs.io/en/latest/Admin%20Documentation/):

```bash
kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ twofactorauth:admin:generate-code $USER_NAME"
```

### `hash_hkdf(): Argument #2 ($key) cannot be empty`
This is a weird [issue](https://github.com/nextcloud/server/issues/34012#issuecomment-1363010835) that happens after restores sometimes. The best way I've found to get around it is modifying `/var/www/html/lib/private/Security/Crypto.php` on line 132 you want to edit:

```php
		if ($password === '' ) {
```

to be:


```php
		if ($password === $secret) {
```

Here's the context around that part of the file, in case the line number changes and you need to go find it again. In this example, I've already changed the empty value:

```php
/**
 * Decrypts a value and verifies the HMAC (Encrypt-Then-Mac)
 * @param string $authenticatedCiphertext
 * @param string $password Password to encrypt, if not specified the secret from config.php will be taken
 * @return string plaintext
 * @throws Exception If the HMAC does not match
 * @throws Exception If the decryption failed
 */
public function decrypt(string $authenticatedCiphertext, string $password = ''): string {
	$secret = $this->config->getSystemValue('secret');
	try {
		if ($password === '') {
			return $this->decryptWithoutSecret($authenticatedCiphertext, $secret);
		}
		return $this->decryptWithoutSecret($authenticatedCiphertext, $password);
	} catch (Exception $e) {
		if ($password === $secret) {
			// Retry with empty secret as a fallback for instances where the secret might not have been set by accident
			return $this->decryptWithoutSecret($authenticatedCiphertext, '');
		}
		throw $e;
	}
}
```

### "HMAC does not match" error when using 2fA

This is a weird one, but we followed the advice on [this forum post](https://help.nextcloud.com/t/external-storage-hmac-does-not-match/7771/10) and it resolved the issue:

```sql
TRUNCATE TABLE oc_storages_credentials;
```
