# terraform-aws-securityhub-batch-update-findings

This is handy when codifying suppressions using terraform and a map structure such as YAML.

## Usage

Example of module usage

```hcl
module "securityhub_batch_update_findings" {
  source  = "infralicious/securityhub-batchupdatefindings/aws"
  # It's recommended to pin every module to a specific version
  # version = "x.x.x"

  findings            = yamldecode(file("${path.module}/findings.yaml")).findings
  default_product_arn = "arn:aws:securityhub:us-east-1:ACCOUNTID:product/ACCOUNTID/default"
  default_workflow    = "SUPPRESSED"
  note_suffix         = "\n\nAdded using terraform"
}
```

Example of `findings.yaml` file

```yaml
# findings.yaml
findings:
  # Every finding should have an adequate note for the suppression.
  # A single resource can have multiple findings.
  # We can codify the resource either in the note or in an inline comment.
  - id: "arn:aws:securityhub:us-east-1:ACCOUNTID:subscription/aws-foundational-security-best-practices/v/1.0.0/S3.11/finding/e4c171dc-12e6-433b-8a51-a382e8d24e37"
    product_arn: "arn:aws:securityhub:us-east-1:ACCOUNTID:product/ACCOUNTID/default"
    note:
      text: "INFOSEC-1234: Suppressed since public IP ingress is for data partner"
    workflow:
      status: "SUPPRESED"
```

## Misc

### Generate the yaml file

The yaml file can be autogenerated from existing suppressions using this `awscli` command with `yq`.
Feel free to remove `title` and `resource_id` keys. I use those as inline comments.
Remember the `findings` parent key.

```bash
aws securityhub get-findings \
  --filters '{"WorkflowStatus": [{"Value": "SUPPRESSED", "Comparison": "EQUALS"}] }' \
  --query 'Findings[].{
    id: Id,
    product_arn: ProductArn,
    note: { text: Note.Text },
    workflow: { status: `"SUPPRESSED"` }
    title: Title,
    resource_id: Resources[0].Id,
  }' | yq -P . > findings.yaml
```

### Test

1. Run a plan
1. Retrieve the existing suppression for a specific finding
1. Use `terraform apply -target` to suppress and add a note to the same finding
1. Repeat the previous retrieval to see the new result
1. Compare with the old result and see if there are differences

### Compare the counts between suppressions and codified suppressions

This will give the count of suppressions in aws.

```bash
aws securityhub get-findings \
  --filters '{"WorkflowStatus": [{"Value": "SUPPRESSED", "Comparison": "EQUALS"}] }' \
  --query 'Findings[] | length(@)
```

This will give the codified suppression count.

```bash
yq '.findings | length' findings.yaml
```

If the counts differ, then the clickops'ed suppression(s) can be moved to the yaml file.

### Instead of a single file, use multiple files

If the `findings.yaml` file is too long, consider breaking it up by each control.

```bash
~ tree findings/
findings
├── EC2.1.yaml
├── EC2.2.yaml
├── EC2.3.yaml
└── S3.1.yaml

1 directory, 4 files
```

The terraform can then be modified

```hcl
locals {
  findings = flatten(concat([
    for file in fileset(path.module, "findings/*.yaml"):
    yamldecode(file("${path.module}/${file}")).findings
  ]))
}

module "securityhub_batch_update_findings" {
  source  = "infralicious/securityhub-batchupdatefindings/aws"
  # It's recommended to pin every module to a specific version
  # version = "x.x.x"

  findings            = local.findings
  # ...
}
```

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | > 1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | > 1 |

## Resources

| Name | Type |
|------|------|
| [null_resource.default](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_product_arn"></a> [default\_product\_arn](#input\_default\_product\_arn) | The default product ARN for each finding. This can be overridden using the key `product_arn`. | `string` | n/a | yes |
| <a name="input_findings"></a> [findings](#input\_findings) | The list of findings to run the awscli command on. | <pre>list(object({<br>    id = string<br>    note = object({<br>      text       = string<br>      updated_by = optional(string)<br>    })<br>    workflow = object({<br>      status = string<br>    })<br>    product_arn        = optional(string)<br>    verification_state = optional(string)<br>    confidence         = optional(number)<br>    criticality        = optional(number)<br>  }))</pre> | n/a | yes |
| <a name="input_awscli_additional_arguments"></a> [awscli\_additional\_arguments](#input\_awscli\_additional\_arguments) | n/a | `string` | `""` | no |
| <a name="input_awscli_command"></a> [awscli\_command](#input\_awscli\_command) | n/a | `string` | `"aws"` | no |
| <a name="input_default_note_updated_by"></a> [default\_note\_updated\_by](#input\_default\_note\_updated\_by) | The default UpdatedBy for each finding for its note if a note is provided. This can be overridden using the key `note_updatedby`. | `string` | `"terraform"` | no |
| <a name="input_default_workflow"></a> [default\_workflow](#input\_default\_workflow) | The default workflow for each finding. This can be overridden using the key `workflow`. | `string` | `"SUPPRESSED"` | no |
| <a name="input_dryrun_enabled"></a> [dryrun\_enabled](#input\_dryrun\_enabled) | Whether or not to add an echo before the command to verify the commands prior to applying. | `bool` | `false` | no |
| <a name="input_note_suffix"></a> [note\_suffix](#input\_note\_suffix) | Add a suffix to each note. | `string` | `""` | no |
<!-- END_TF_DOCS -->

## References

- https://ekantmate.medium.com/how-to-suppress-particular-findings-in-aws-security-hub-using-terraform-558bd3819b31
- https://github.com/hashicorp/terraform-provider-aws/issues/29164
- https://registry.terraform.io/modules/infralicious/securityhub-batchupdatefindings/aws
- https://library.tf/modules/infralicious/securityhub-batchupdatefindings/aws/latest
