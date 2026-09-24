---
name: docker-disaster-recovery
description: Restore Docker-V2rayServer from GitHub and verified private Google Drive runtime bundles after Docker host loss.
---

# Docker-V2rayServer recovery

On the inspected Pi deployment, the matching container was `reverent_germain` using `qinbatista/v2rayserver`. Recheck the image digest and runtime contract on the actual restore day. Use an authorized client connection to the configured TCP/UDP endpoint.

1. Clone this repository from its configured GitHub remote and read the current Dockerfile, Compose files, and runtime instructions. Compare the selected source commit with the image or build recorded in the recovery inventory; report any mismatch.
2. Clone the private `qinbatista/google-drive-helper` repository and follow its `skills/docker-disaster-recovery/SKILL.md`. Authenticate Google Drive on the replacement host, download the exact immutable Docker recovery bundle, and run `recovery_bundle.py stage` in an empty private directory. Require a SHA-256 pass for every included regular file. The bundle and staged files may contain credentials; keep them outside Git.
3. Read `docker-inspect.json` and `manifest.json` in that bundle. Select this service's runtime configuration, bind mounts, named volumes, ports, networks, restart policy, and image digest. Restore only its reviewed paths, retaining ownership and permissions. If a required file or volume is absent, mark the service blocked rather than creating an empty substitute.
4. Validate the restored Compose configuration with `docker compose config --quiet` when Compose owns the service; otherwise rebuild or pull the recorded image and recreate the inspected run contract. Start on isolated ports first and perform the service check above. Verify Docker running/health state and real access before moving to production ports.
5. For dependencies, verify S3 through an authenticated object list and byte-checked download, and Google Drive through a listed and byte-checked download. The Drive helper's normal sync is local-authoritative: never run `sync --apply` against an empty replacement source. Record the count of recovered files, failures, and any unverified network or credential boundary.
