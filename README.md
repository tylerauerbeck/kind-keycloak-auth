# kind-keycloak-auth

I got tired of reminding myself how to setup a local keycloak instance to be used for OIDC with KinD. So now we've got this mix of YAML, opentofu and a handful of commands to pull it all together.

This will eventually get cleaned up and I'll pull this together a bit more cleanly, but for now this is just for future me to not fight with this again.

To get started:
```
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout keycloak.key -out keycloak.crt -config sslcert.conf -extensions 'v3_req'
docker-compose up
cd keycloak && tofu apply
CLIENT_SECRET=$(tofu output -raw client_secret)
cd ..
kind create cluster --name=cluster-a --config=kind-config.yaml
kubectl oidc-login setup \
  --oidc-issuer-url=https://keycloak:8443/realms/nightosphere \
  --oidc-client-id=kubeosphere \
  --oidc-client-secret=${CLIENT_SECRET} \
  --insecure-skip-tls-verify \
  --oidc-extra-scope=email
```
