#! /bin/sh

# exit script on any error
set -e

CHAIN_ID=${CHAIN_ID:-canto_7700-1}
GENESIS_URL=${GENESIS_URL:-https://raw.githubusercontent.com/Canto-Network/Canto/v${VERSION}/Networks/Mainnet/genesis.json}

export_by_prefix() {
  prefix=$1
  for var in $(set | grep "^$prefix[A-Za-z_0-9]*=" | awk -F= '{print $1}'); do
    export "$var"
  done
}

write_client_toml() {
    export_by_prefix CLIENT_
    envsubst < "$CANTOD_HOME/config/client.template.toml" > client.toml
}

write_config_toml() {
    export_by_prefix CONFIG_
    envsubst < "$CANTOD_HOME/config/config.template.toml" > config.toml
}

write_app_toml() {
    export_by_prefix APP_
    envsubst < "$CANTOD_HOME/config/app.template.toml" > app.toml
}

# retrieve and set trust height/hash automatically if CONFIG_STATESYNC_ENABLE=true and CONFIG_STATESYNC_TRUST_HEIGHT=0
set_trusted_block() {
    if [ "$CONFIG_STATESYNC_ENABLE" != "true" ] || [ "${CONFIG_STATESYNC_TRUST_HEIGHT:-0}" -ne 0 ]; then
        return
    fi
    if [ -z "$CONFIG_STATESYNC_RPC_SERVERS" ]; then
        echo "can't automatically CONFIG_STATESYNC_TRUST_HEIGHT without CONFIG_STATESYNC_RPC_SERVERS"
        return
    fi
    RPC_SERVER=$(echo $CONFIG_STATESYNC_RPC_SERVERS | cut -d , -f1)
    LATEST_HEIGHT=$(wget --quiet --output-document - $RPC_SERVER/block | jq -r .result.block.header.height)
    CONFIG_STATESYNC_TRUST_HEIGHT=$((LATEST_HEIGHT - 2000))
    CONFIG_STATESYNC_TRUST_HASH=$(wget --quiet --output-document - "$RPC_SERVER/block?height=$CONFIG_STATESYNC_TRUST_HEIGHT" | jq -r .result.block_id.hash)
    echo -e "LATEST_HEIGHT: $LATEST_HEIGHT\nCONFIG_STATESYNC_TRUST_HEIGHT: $CONFIG_STATESYNC_TRUST_HEIGHT\nCONFIG_STATESYNC_TRUST_HASH: $CONFIG_STATESYNC_TRUST_HASH"
}

compare_replace_config() {
    TARGET_FILE=$1
    TEMP_FILE=$2
    if [ ! -f "$TARGET_FILE" ]; then
        echo "no existing file found, creating.."
        mv "$TEMP_FILE" "$TARGET_FILE"
    else
        TARGET_FILE_HASH=$(sha256sum "$TARGET_FILE" | awk '{print $1}')
        TEMP_FILE_HASH=$(sha256sum "$TEMP_FILE" | awk '{print $1}')
        echo -n "Updating $TARGET_FILE ... "
        if [ "$TARGET_FILE_HASH" = "$TEMP_FILE_HASH" ]; then
            echo "already up-to-date"
            rm "$TEMP_FILE"
        else
            echo "done"
            mv "$TEMP_FILE" "$TARGET_FILE"
        fi
    fi
}

download_genesis() {
    rm -f genesis.json
    wget $GENESIS_URL
}

initialize() {
    NODE_DIR=$1
    BINARY=$2

    if [ $# != 2 ]; then
        echo "expected 2 arguments for initialize"
        exit 1
    fi

    if [ ! -f "$NODE_DIR/config/genesis.json" ]; then
        echo "no existing genesis file found, initializing.."
        $BINARY init "${CONFIG_MONIKER:-moniker}" --home="$NODE_DIR" --chain-id=$CHAIN_ID
        cd "$NODE_DIR/config"
        download_genesis
    fi
}

update_config_files() {
    CONFIG_DIR=$1
    TEMP_DIR="$CONFIG_DIR/temp"

    mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"

    write_app_toml
    write_client_toml
    write_config_toml

    cd "$CONFIG_DIR"

    compare_replace_config "$CONFIG_DIR/app.toml" "$TEMP_DIR/app.toml"
    compare_replace_config "$CONFIG_DIR/client.toml" "$TEMP_DIR/client.toml"
    compare_replace_config "$CONFIG_DIR/config.toml" "$TEMP_DIR/config.toml"

    rm -rf "$TEMP_DIR"
}

initialize "$CANTOD_HOME" cantod
set_trusted_block
update_config_files "$CANTOD_HOME/config"
