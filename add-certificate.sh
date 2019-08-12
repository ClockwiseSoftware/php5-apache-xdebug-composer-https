# Generate certificates command
# openssl req -x509 -nodes -days 730 -newkey rsa:2048 \
# -keyout ./certificates/cert.key -out ./certificates/cert.crt -config req.cnf -sha256

sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./certificates/cert.crt