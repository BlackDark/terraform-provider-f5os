# Terraform Provider F5OS (Forked for Pulumi)

This is a fork of the official terraform provider: https://github.com/F5Networks/terraform-provider-f5os
The pulumi provider is located here: https://github.com/BlackDark/pulumi-f5os

This fork is created to simplify the creation of a pulumi provier for the f5os system.
Currently the official terraform provider is not suited for direct usage for the pulumi provider because of:

- the internal provider scope (this makes it more complicated to just use the code in another module)
- the third party vendor which cannot be downloader from other modules `f5osclient`

## How to update the forked provider?

Checkout the `update.sh` and modify the version you want to create the matching provider for.
Also maybe double check what kind of files have changed.
The most things should be done in the script like copy vendor out, rename things, clean up `go.mod` and `modules.txt`.

Checkout the desired remote tag (you should be on the tag and detached head).
We are running the update script directly.

`curl -sSL https://raw.githubusercontent.com/BlackDark/terraform-provider-f5os/refs/heads/main/update.sh | bash`

Then we commit and deleteAfterwards create a matching tag to be used in the pulumi provider.
The we need to prepare the new tag:

```bash
git commit -m "refactor: update for pulumi"
git tag -d v1.8.0 # your used tag
git tag v1.8.0
git push origin v1.8.0
```

Done. 
Continue in the pulumi provider.
