set -ex
# Generate redis server-id from pod ordinal index.
[[ `hostname` =~ -([0-9]+)$ ]] || exit 1
ordinal=${BASH_REMATCH[1]}
# Copy appropriate redis config files from config-map to respective directories.
if [[ $ordinal -eq 0 ]]; then
    cp /mnt/master.conf /etc/redis-config.conf
else
    cp /mnt/slave.conf /etc/redis-config.conf
fi