# terraform-aws-securityhub-batch-update-findings

This is handy when codifying suppressions using terraform and a map structure such as YAML.

## Usage

Example of module usage

```hcl
module "securityhub_batch_update_findings" {
  source  = "securityhub/batchupdatefindings/aws"
  # It's recommended to pin every module to a specific version
  # version = "x.x.x"

  findings            = yamldecode("${path.module}/findings.yaml").findings
  default_product_arn = "arn:aws:securityhub:us-east-1:<snip>:product/<snip>/default"
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
  - id: "arn:aws:securityhub:us-east-1:<snip>>:subscription/aws-foundational-security-best-practices/v/1.0.0/S3.11/finding/e4c171dc-12e6-433b-8a51-a382e8d24e37"
    product_arn: "arn:aws:securityhub:us-east-1:<snip>:product/<snip>/default"
    note:
      text: "INFOSEC-1234: Suppressed since public IP ingress is for data partner"
    workflow:
      status: "SUPPRESED"
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
| <a name="input_findings"></a> [findings](#input\_findings) | The path of the YAML file starting with key "findings" and containing a list of items with at least an "id" and "note".<pre>yaml<br>findings:<br>  - id: "arn:..."<br>    note:<br>      text: "Suppressed because of these reasons"<br>      # optional<br>      updated_by: "terraform"<br>    # optional<br>    workflow:<br>      status: SUPPRESSED<br>    verification_state: UNKNOWN|TRUE_POSITIVE|FALSE_POSITIVE|BENIGN_POSITIVE<br>    confidence: 0<br>    criticality: 0</pre> | <pre>list(object({<br>    id = string<br>    note = object({<br>      text       = string<br>      updated_by = optional(string)<br>    })<br>    workflow = object({<br>      status = string<br>    })<br>    verification_state = optional(string)<br>    confidence         = optional(number)<br>    criticality        = optional(number)<br>  }))</pre> | n/a | yes |
| <a name="input_default_note_updated_by"></a> [default\_note\_updated\_by](#input\_default\_note\_updated\_by) | The default UpdatedBy for each finding for its note if a note is provided. This can be overridden using the key `note_updatedby`. | `string` | `"terraform"` | no |
| <a name="input_default_workflow"></a> [default\_workflow](#input\_default\_workflow) | The default workflow for each finding. This can be overridden using the key `workflow`. | `string` | `"SUPPRESSED"` | no |
| <a name="input_dryrun_enabled"></a> [dryrun\_enabled](#input\_dryrun\_enabled) | Whether or not to add an echo before the command to verify the commands prior to applying. | `bool` | `false` | no |
| <a name="input_note_suffix"></a> [note\_suffix](#input\_note\_suffix) | Add a suffix to each note. | `string` | `""` | no |
<!-- END_TF_DOCS -->

## References

* https://ekantmate.medium.com/how-to-suppress-particular-findings-in-aws-security-hub-using-terraform-558bd3819b31
* https://github.com/hashicorp/terraform-provider-aws/issues/29164
