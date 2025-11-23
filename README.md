# kind-keycloak-auth

I got tired of reminding myself how to setup a local keycloak instance to be used for OIDC with KinD. So now we've got this mix of YAML, opentofu and a handful of commands to pull it all together.

This will eventually get cleaned up and I'll pull this together a bit more cleanly, but for now this is just for future me to not fight with this again.

To get started:

Create a certificate. I want a self signed cert, but one that I trust. That's fine! Because I've got `mkcert`. If you don't, you can get it with `brew install mkcert`

Once you've got what you need, you can make sure that the local CA is installed and trusted by your machine and then output the your cert files to the local directory.

```
mkcert -install
mkcert -cert-file ./keycloak.crt -key-file ./keycloak.key keycloak
```

Then we're going to go ahead and spin up a local instance of keycloak in docker

```
docker-compose up
```

At this point, we've got an empty keycloak. Which isn't all that useful. So we'll go ahead and create a realm, some users, and a client that we can use.

```
cd keycloak && tofu apply -auto-approve
CLIENT_SECRET=$(tofu output -raw client_secret)
cd ..
```

Now we've got a functional keycloak instance that we can use for our OIDC auth. So now we need a kube cluster.

```
kind create cluster --name=cluster-a --config=kind-config.yaml
```

And now we've got a cluster and an auth provider that are talking to each other. So it's just a matter of getting kubectl to make use of it. To do that we can go ahead and use the `oidc-login` plugin.

If you don't already have it, you can go ahead and use `krew` to install it
```
kubectl krew install oidc-login
```
or you can do it via `brew` as well
```
brew install kubelogin
```

Once we've got the plugin, go ahead and configure it

```
kubectl oidc-login setup \
  --oidc-issuer-url=https://keycloak:8443/realms/nightosphere \
  --oidc-client-id=kubeosphere \
  --oidc-client-secret=${CLIENT_SECRET} \
  --insecure-skip-tls-verify \
  --oidc-extra-scope=email
```

If you find yourself getting any messages about an untrusted cert (in the case where you're not using `mkcert`), you can add the `--insecure-skip-tls-verify` to the above command

The above will output a command that would look like:

```
kubectl config set-credentials oidc \
  --exec-api-version=client.authentication.k8s.io/v1 \
  --exec-interactive-mode=Never \
  --exec-command=kubectl \
  --exec-arg=oidc-login \
  --exec-arg=get-token \
  --exec-arg="--oidc-issuer-url=https://keycloak:8443/realms/nightosphere" \
  --exec-arg="--oidc-client-id=kubeosphere" \
  --exec-arg="--oidc-client-secret=${CLIENT_SECRET}}" \
  --exec-arg="--oidc-extra-scope=email"
```

This sets up a user called `oidc` in your kubeconfig and now you can use that user via the following:

```
kubectl get nodes --user=oidc
```

Since nothing should be configured to use it yet, you should get an error that looks like the following:

```
Error from server (Forbidden): nodes is forbidden: User "finn@nightosphere.dev" cannot list resource "nodes" in API group "" at the cluster scope
```

Which can be resolved by applying the `clusterrole.yaml` and `clusterrolebinding.yaml` at the root of this repository. Once applied, you now have everything working together and some RBAC based off of your OIDC provider.

