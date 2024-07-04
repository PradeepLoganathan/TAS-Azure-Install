#download TAS tile file from Broadcomm support portal - it is a 18GB file.

#upload TAS tile file to operations manager
om -k --target https://your-ops-manager-domain --username your-username --password your-password \
upload-product --product your-tas-tile-file.pivotal

#Stage TAS tile file
om -k --target https://your-ops-manager-domain --username your-username --password your-password \
stage-product --product-name cf --product-version x.x.x