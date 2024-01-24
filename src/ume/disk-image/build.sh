PACKER_VERSION="1.7.8"

if [ ! -f ./packer ]; then
    wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip;
    unzip packer_${PACKER_VERSION}_linux_amd64.zip;
    rm packer_${PACKER_VERSION}_linux_amd64.zip;
fi

# Grabs proxy from user-data file
# Stores second capture group (which is either the proxy or is empty)
proxy=$(sed -n 's/\(proxy:\)\s*\(.*\)/\2/p' shared/user-data | xargs)

./packer validate ume/ume.json
./packer build -vat "proxy=$proxy" ume/ume.json
