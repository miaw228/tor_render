# tor-render

A simple web page hosted as a Tor hidden service built with Docker and deployed on render( the main thing )

Live at:
- Tor: `http://xab56hijghdnn3b6raksgxr5644zi53zadxlwijzozh6mwje3rfefpyd.onion`
![front](/images/front.png)
![front2](/images/front2.png)
![demo](/images/demo.png)

## what it does

It runs Nginx inside a Docker container and Tor alongside it, pointing the hidden service at the same port. Anyone with Tor Browser can reach the `.onion` address. Previously used Python's built-in `http.server` but switched to Nginx for proper security headers, no directory listing, and better handling.

## how it works under the hood
Tor connected to directory authorities, downloaded the consensus, and bootstrapped to 100% — all outbound TCP from inside Render's network. That succeeded, meaning Render doesn't block this kind of outbound traffic.

## setup (baking keys into the image)

first copy this repo and then 
in the Dockerfile comment out `# COPY hidden_service_keys/ /var/lib/tor/hidden_service/`
then just build it temporarily 

```bash
docker build -t tor-website-temp .
```
then 
```bash
docker run --rm -v $(pwd)/hidden_service_keys:/out tor-website-temp \
  bash -c "tor & sleep 20 && cp -r /var/lib/tor/hidden_service/* /out/"
```
Check that hidden_service_keys/ now contains 3 files: hostname, hs_ed25519_secret_key, hs_ed25519_public_key

```bash
cat hidden_service_keys/hostname
```
Write this down — this is your permanent address.

Uncomment `COPY hidden_service_keys/ /var/lib/tor/hidden_service/`

before deploy test locally with 
```bash
docker build -t tor-website .
docker run -p 80:80 tor-website
```
Open Tor Browser, paste the .onion address

![screenshot](/images/deploy1.png)

## setup (render secret files — recommended)


 Generate the keys locally the same way as above (temp build + run + copy to `hidden_service_keys/`).
 Base64-encode each key file so it can be pasted as plain text:
   ```bash
   base64 -w0 hidden_service_keys/hostname > hostname.b64
   base64 -w0 hidden_service_keys/hs_ed25519_secret_key > secret_key.b64
   base64 -w0 hidden_service_keys/hs_ed25519_public_key > public_key.b64
```
 In Render → your service → Environment → Secret Files, add three files (filename only)
   - `hostname.b64`
   - `secret_key.b64`
   - `public_key.b64`


## Deploy on Render

New Web Service → connect your repo → Render detects the Dockerfile automatically.
Environment: Docker.
Deploy.
Once deployed, visit the Render URL yourself to wake the free instance, wait ~30–60s or more for Tor to bootstrap, then check logs for "Your service is live."

## Notes

- If reusing the baked-in-image method, never push `hidden_service_keys/hs_ed25519_secret_key` to a public repo — it's the private key for the `.onion` address, and it can't be revoked once leaked.

## Disclaimer

This project was built purely for research and learning purposes — to understand how Tor hidden services work and whether they can be deployed on a general-purpose PaaS like Render. It is not intended for, and must not be used for, any illegal activity. The author takes no responsibility for any misuse of this code or the techniques described here. If you fork or reuse this, generate your own hidden service keys.
