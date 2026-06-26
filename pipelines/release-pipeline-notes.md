# Release Pipeline notes

## A real bug, found and fixed

The first version of this pipeline put the actual `terraform apply` work
inside a `deployment` job (required for Azure DevOps Environment approval
gates). Every run failed identically:

```
Error: spawn /opt/hostedtoolcache/terraform/1.7.5/x64/terraform ENOENT
```

A debug step confirmed the binary genuinely existed, was executable, and was
on PATH at that exact moment -- ruling out an install or PATH problem. The
real cause, confirmed against a matching open issue on Microsoft's own
`azure-pipelines-extensions` repository (#724): the Microsoft DevLabs
Terraform extension's tasks fail to spawn correctly specifically inside a
deployment job's `runOnce.deploy.steps` -- a known, unresolved limitation of
the extension, not a problem with this project's configuration.

**The fix:** separate "doing the Terraform work" from "being the thing the
approval gate watches." The Staging stage now has two jobs:

1. A **plain job** (`ApplyStaging`) that installs Terraform, downloads the
   plan artifact, and runs `terraform init` / `terraform apply` -- exactly
   the same task configuration that already worked correctly in the Build
   Pipeline.
2. A **lightweight deployment job** (`RecordStaging`) that depends on the
   first and does nothing but echo a confirmation, attached to the
   `staging` Azure DevOps Environment purely for deployment-history
   tracking.

The Production stage was always deployment-job-only with no Terraform
tasks, so it was never affected -- it exists purely as the human approval
checkpoint, with no apply of its own.

## Cross-pipeline artifact download

A separate, related fix: `download: current` only ever resolves to a prior
stage of the *same* pipeline run. Since the Release Pipeline is a genuinely
separate pipeline from the Build Pipeline, downloading its published plan
artifact required declaring the Build Pipeline as a `resources.pipelines`
entry first, then downloading from that resource's identifier rather than
`current`.

## Result

End-to-end pipeline-driven deployment confirmed working: Build Pipeline
produces and publishes a plan -> Release Pipeline's Staging stage downloads
and applies that exact plan -> Production stage pauses for manual approval
-> approved -> deployment confirmed. Verified against real Azure resources
(`rg-claims-platform-dev`, the VM running with the correct private IP and no
public IP) before tearing down.

Screenshots: `release-pipeline-staging-success.png`,
`release-pipeline-approval-gate.png`, `release-pipeline-approved.png`,
`portal-pipeline-deployed-resource-group.png`