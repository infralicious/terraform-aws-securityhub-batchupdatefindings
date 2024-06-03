variable "default_product_arn" {
  type        = string
  description = "The default product ARN for each finding. This can be overridden using the key `product_arn`."
}

variable "default_workflow" {
  type        = string
  description = "The default workflow for each finding. This can be overridden using the key `workflow`."
  default     = "SUPPRESSED"
}

variable "default_note_updated_by" {
  type        = string
  description = "The default UpdatedBy for each finding for its note if a note is provided. This can be overridden using the key `note_updatedby`."
  default     = "terraform"
}

variable "findings" {
  type = list(object({
    id = string
    note = object({
      text       = string
      updated_by = optional(string)
    })
    workflow = object({
      status = string
    })
    product_arn        = optional(product_arn)
    verification_state = optional(string)
    confidence         = optional(number)
    criticality        = optional(number)
  }))
  description = "The list of findings to run the awscli command on."
}

variable "note_suffix" {
  type        = string
  default     = ""
  description = "Add a suffix to each note."
}

variable "dryrun_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to add an echo before the command to verify the commands prior to applying."
}
