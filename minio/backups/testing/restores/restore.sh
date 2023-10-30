#!/bin/bash -
#===============================================================================
#
#         USAGE: ./restore_nextcloud.sh
#
#   DESCRIPTION: Quick script to restore a nextcloud psql dump and in a
#                Backblaze B2 restic repo to a running k8s psql database PVC, as
#                well as nextcloud files to their own PVC.
#
#  REQUIREMENTS: restic, kubectl, krew plugins: ctx, ns
#        AUTHOR: jessebot@linux.com @jessebot on gitlab/github
#===============================================================================
# example: https://cloud.example.com
NEXTCLOUD_URL=""

if [[ -z "$NEXTCLOUD_URL" ]]; then
    echo "Please entire a NEXTCLOUD_URL to check if you're in maintanence mode yet"
    read NEXTCLOUD_URL
fi

# pretty echo so that I don't have to remember this
function p_echo() {
    # prints with green colors and centered
    echo -e "\n\033[92m $1\033[00m\n"
}

p_echo "sourcing an env file for restic"
. .env

p_echo "switching to nextcloud namespace"
kubectl config set-context --namespace=nextcloud --current

p_echo "grabing the exact postgres and nextcloud pods"
NEXTCLOUD_POD=$(kubectl get pods -l app.kubernetes.io/name=nextcloud -o custom-columns=NAME:.metadata.name | tail -n 1)
POSTGRES_POD=$(kubectl get pods -l app.kubernetes.io/name=postgresql -o custom-columns=NAME:.metadata.name | tail -n 1)

p_echo "󰆼 grabing only the most recent postgres pod snapshot"
postgres_snapshot=$(restic snapshots --latest 1 | grep '\.sql')
POSTGRES_SNAPSHOT_ID=$(echo $postgres_snapshot | awk '{print $1}')
echo "POSTGRES_SNAPSHOT_ID is $POSTGRES_SNAPSHOT_ID"
POSTGRES_SNAPSHOT_FILE=$(echo $postgres_snapshot | awk '{print $5}' | awk -F '/' '{print $2}')

p_echo "copying the postgres snapshot locally"
restic restore $POSTGRES_SNAPSHOT_ID --target /tmp

p_echo "copying the postgres snapshot to kubernetes"
kubectl cp /tmp/$POSTGRES_SNAPSHOT_FILE $POSTGRES_POD:/tmp/$POSTGRES_SNAPSHOT_FILE

p_echo "putting nextcloud into maintanence mode while we restore... and blow away the existing database"
kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ maintenance:mode --on"

p_echo "Check if we\'re in MAINTENANCE MODE..."
MAINTENANCE_MODE=$(curl -k -s -w "%{http_code}\n" $NEXTCLOUD_URL -o /dev/null)

while [ $MAINTENANCE_MODE != "503" ]; do
    echo "Not in maintanence mode yet, since URL returned $MAINTENANCE_MODE."
    echo "Sleeping 30 seconds"
    sleep 30
    MAINTENANCE_MODE=$(curl -k -s -w "%{http_code}\n" $NEXTCLOUD_URL -o /dev/null)
done

# Drop and recreate the database, last ditch effort
p_echo ""
kubectl exec $POSTGRES_POD -- psql -U postgres -c 'DROP DATABASE nextcloud'
kubectl exec $POSTGRES_POD -- psql -U postgres -c 'CREATE DATABASE nextcloud with owner nextcloud'
kubectl exec $POSTGRES_POD -- psql -U postgres -c 'GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextcloud'


# database restoration
p_echo "restoring the database"
p_echo 'kubectl exec $POSTGRES_POD -- /bin/bash -c "psql -U postgres nextcloud < /tmp/$POSTGRES_SNAPSHOT_FILE"'
kubectl exec $POSTGRES_POD -- /bin/bash -c "psql -U postgres nextcloud < /tmp/$POSTGRES_SNAPSHOT_FILE"

# files restoration
p_echo "grabing only the most recent nextcloud *files* snapshot"
files_snapshot=$(restic snapshots --latest 1 | grep "nextcloud-files")
FILES_SNAPSHOT_ID=$(echo $files_snapshot | awk '{print $1}')
echo "󰅟  FILES_SNAPSHOT_ID is $FILES_SNAPSHOT_ID"

p_echo "restoring latest snapshot of nextcloud files using this file:"
sed -i "s/REPLACE_ME/$FILES_SNAPSHOT_ID/" restore_files.yaml
bat restore_files.yaml

# this is to do the same thing, but with the k8up cli - untested
# k8up cli restore $FILES_SNAPSHOT_ID

p_echo "restoring latest snapshot of nextcloud files"
kubectl apply -f restore_files.yaml
sed -i "s/$FILES_SNAPSHOT_ID/REPLACE_ME/" restore_files.yaml

p_echo "Waiting up to 45 minutes for restore to complete..."
kubectl wait --timeout=2700s --for='condition=Completed' restore.k8up.io/nextcloud-files

sleep 10

p_echo "Recursively chown data dir to be owned by www-data user and root group"
kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash root -c "chown -R www-data:root /var/www/html/data && chown -R www-data:root /data"

p_echo "doing a file cache cleanup"
kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ files:cleanup"

echo "taking nextcloud out of maintanence mode when we're done"
kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ maintenance:mode --off"

echo -e "Check if we're out of MAINTENANCE MODE...\n"
MAINTENANCE_MODE=$(curl -k -s -w "%{http_code}\n" $NEXTCLOUD_URL -o /dev/null)

while [ $MAINTENANCE_MODE != "302" ]; do
    echo "Not out of maintanence mode yet, since URL returned $MAINTENANCE_MODE."
    echo "Sleeping 30 seconds"
    sleep 30
    MAINTENANCE_MODE=$(curl -k -s -w "%{http_code}\n" $NEXTCLOUD_URL -o /dev/null)
done
echo "🎉 Out of maintanence mode and ready to roll 🚊"

p_echo "doing a file scan to make thumbnails just in case"
kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ files:scan --all"
sleep 10
