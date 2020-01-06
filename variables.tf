variable "namespace" {
    description = "The project namespace to use for unique resource naming"
    type        = string
    default     = "s3backend"
}

variable "principal_arn" {
    description = "AWS principal arn allowed to assume the IAM role"
    type        = string 
}

variable "force_destroy_state" {
    description = "Force destroy the s3 bucket containing state files?"
    type        = bool 
    default     = true 
}