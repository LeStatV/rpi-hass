DATA_DIR="/usr/local/hassio"
CFG_FILE="${DATA_DIR}/etc/hassio.json"

# Install tools
apt-get install jq

# Fix install directory
mkdir -p "${DATA_DIR}"

# Prepare files and folders
mkdir -p ${DATA_DIR}/bin
cp ./hassio.service /etc/systemd/system
cp ./hassio.sh ${DATA_DIR}/bin

HOMEASSISTANT_DOCKER="homeassistant/qemuarm-64-homeassistant"
HASSIO_DOCKER="homeassistant/aarch64-hassio-supervisor"

# Read infos from web
URL_VERSION="https://version.home-assistant.io/stable.json"
HASSIO_VERSION=$(curl -s $URL_VERSION | jq -e -r '.supervisor')

# Pull supervisor image
/usr/bin/docker pull "${HASSIO_DOCKER}:${HASSIO_VERSION}" >/dev/null &&
/usr/bin/docker tag "${HASSIO_DOCKER}:${HASSIO_VERSION}" "${HASSIO_DOCKER}:latest" >/dev/null

if [ ! -f ${CFG_FILE} ]; then
    mkdir -p ${DATA_DIR}/etc
    cp ./hassio.dist ${CFG_FILE}
    # Write config
    sed -i -e "s|@supervisor@|${HASSIO_DOCKER}|g" ${CFG_FILE}
    sed -i -e "s|@homeassistant@|${HOMEASSISTANT_DOCKER}|g" ${CFG_FILE}
    sed -i -e "s|@data_dir@|${DATA_DIR}|g" ${CFG_FILE}
fi

# Enable services
systemctl enable hassio
systemctl start hassio
