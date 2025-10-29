## Description

Describe the change and the motivation/context. Link related issues.

## Changes
- [ ] Infrastructure changes limited to scope of this PR
- [ ] Backwards compatible (no breaking changes)
- [ ] Documentation updated (README, module docs, examples)

## How to Test
Provide steps to validate:
1. terraform fmt -recursive
2. terraform init
3. terraform validate
4. terraform plan -var-file=infra/main.tfvars.json

## Checklist
- [ ] `terraform fmt -recursive` run
- [ ] `terraform validate` passes
- [ ] `terraform plan` reviewed
- [ ] New/changed variables documented in `infra/variables.tf` and README
- [ ] Sensitive values not committed
- [ ] Added/updated module versions are pinned
- [ ] Relevant CI checks pass
