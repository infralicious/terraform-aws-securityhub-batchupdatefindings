locals {
  template_command = <<-EOF
      ${var.dryrun_enabled ? "echo" : ""} %s securityhub batch-update-findings %s %s
    EOF
}

resource "null_resource" "default" {
  for_each = { for k, v in var.findings : (v.id) => v }

  provisioner "local-exec" {
    command = self.triggers.command
  }

  triggers = {
    command = format(local.template_command,
      var.awscli_command,
      join(" ", compact([
        format("--finding-identifiers Id=\"%s\",ProductArn=\"%s\"",
          each.value["id"],
          coalesce(each.value["product_arn"], var.default_product_arn)
        ),
        try(length(each.value["workflow"]["status"]), 0) > 0 ? format(
          "--workflow Status=\"%s\"", each.value["workflow"]["status"]
        ) : "",
        try(length(each.value["verification_state"]), 0) > 0 ? format(
          "--verification-state \"%s\"", each.value["verification_state"]
        ) : "",
        try(length(each.value["confidence"]), 0) > 0 ? format(
          "--confidence %s", each.value["confidence"]
        ) : "",
        try(length(each.value["criticality"]), 0) > 0 ? format(
          "--criticality %s", each.value["criticality"]
        ) : "",
        try(length(each.value["note"]["text"]), 0) > 0 || length(var.note_suffix) > 0 ? format(
          "--note Text=\"%s%s\",UpdatedBy=\"%s\"",
          replace(replace(replace(each.value["note"]["text"],
            # TODO: escape single quotes, for now remove them
            "'", ""),
            # escape commas
            ",", "\\,"),
            # escape double quotations
            "\"", "'"
          ),
          var.note_suffix,
          coalesce(each.value["note"]["updated_by"], var.default_note_updated_by)
        ) : "",
        # TODO: None of these are needed at the moment
        # --related-findings
        # --severity
        # --types
        # --user-defined-fields
      ])),
      var.awscli_additional_arguments,
    )
  }
}

# TODO: use an upstream module if it is less maintenance
# module "securityhub_findings" {
#   source  = "digitickets/cli/aws"
#   version = "6.1.0"

#   for_each = { for k, v in local.securityhub_findings : (v.id) => v }

#   # role_session_name = "GettingDesiredCapacityFor${var.environment}"

#   aws_cli_commands  = ["securityhub", "batch-update-findings"]
#   # aws_cli_commands  = ["autoscaling", "describe-auto-scaling-groups"]
#   # aws_cli_query     = "AutoScalingGroups[?Tags[?Key==`Name`]|[?Value==`digitickets-aaa-asg-app`]]|[0].DesiredCapacity"
#   # aws_cli_query     = "AutoScalingGroups[?Tags[?Key==`Name`]]|[0].DesiredCapacity"

#   # aws_cli_commands  = concat(
#   #   [
#   #     "securityhub",
#   #     "batch-update-findings"
#   #   ],
#   #   # compact([
#   #     # try(length(each.value["note"]), 0) > 0 || length(var.note_suffix) > 0 ? "--note \"${replace(each.value["note"], "\"", "'")}${var.note_suffix}\"" : "",
#   #     # try(length(each.value["severity"]), 0) > 0 ? "--severity \"${each.value["severity"]}\"" : "",
#   #     # try(length(each.value["verification_state"]), 0) > 0 ? "--verification-state \"${each.value["verification_state"]}\"" : "",
#   #     # try(length(each.value["confidence"]), 0) > 0 ? "--confidence \"${each.value["confidence"]}\"" : "",
#   #     # try(length(each.value["criticality"]), 0) > 0 ? "--criticality \"${each.value["criticality"]}\"" : "",
#   #   # ])
#   # )
#   # aws_cli_query     = "[]"
# }

# output "result" {
#   value = module.current_desired_capacity
# }
