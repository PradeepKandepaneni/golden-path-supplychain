# golden-path-supplychain

Add a **software supply-chain security** layer to the golden path: generate an
SBOM, scan the image and **fail the build on a High/Critical CVE**, keyless-sign
the result, and have the cluster **reject any workload that isn't hardened** —
all proven on free infrastructure.

Third in the [golden-path](https://github.com/PradeepKandepaneni/golden-path)
series. First we shipped it. Then we made it [survive a zone outage](https://github.com/PradeepKandepaneni/golden-path-resilience).
Now we make its supply chain defensible.

> Runs in CI on GitHub's free runners. **Total cost: $0.**

## What the pipeline enforces

Four controls, each one able to stop a bad artifact from shipping:

1. **SBOM (`syft`)** — a Software Bill of Materials in SPDX JSON. You can't
   secure what you can't enumerate; the SBOM is the inventory.
2. **Vulnerability scan (`grype`)** — scans the image and **fails the build**
   on any High or Critical CVE. Not a warning in a dashboard nobody reads — a
   red X that blocks the merge.
3. **Keyless signing (`cosign`)** — signs the SBOM using the workflow's OIDC
   identity. No private key to store, rotate, or leak. Provenance you can verify.
4. **Policy as code (`kyverno`)** — a cluster admission policy that **rejects**
   any pod that runs as root, keeps Linux capabilities, or uses `:latest`. The
   golden path's hardening stops being a convention and becomes enforced.

## The part that proves it works

Most "we do DevSecOps" writeups show the happy path. This repo's CI does the
opposite: it applies a deliberately **bad** pod (root, all caps, `:latest`) and
**fails the build unless Kyverno rejects it**. A policy you haven't watched
reject something is a policy you're trusting on faith.

## Run it locally

```bash
make image         # build
make sbom          # needs syft
make scan          # needs grype — fails on High/Critical
```

Policy enforcement is easiest to see in CI (it needs a cluster + Kyverno), but
the manifests in `policy/` run on any kind cluster.

## Honest limitations

- **Scanners only know what's in their database.** A clean grype scan means "no
  *known* High/Critical CVEs today," not "safe." Tomorrow's disclosure changes
  the answer with no code change — which is why scanning belongs in a scheduled
  job too, not only at build.
- **Keyless signing ties provenance to the workflow identity**, which is only as
  trustworthy as the repo's access controls. Signing proves *who built it*, not
  that what they built is good.
- **Policy as code enforces posture, not intent.** Kyverno can require non-root;
  it can't tell a well-behaved image from a malicious one that happens to be
  hardened. Defense in depth, not a silver bullet.

## Cost

| Piece | Cost |
| --- | --- |
| GitHub Actions (public repo) | Free, unlimited |
| syft / grype / cosign / kyverno | Free / open source |

## License
MIT.
