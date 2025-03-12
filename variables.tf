variable "zone_name" {
  type        = string
  default     = "prajai.online"
  description = "description"
}

variable "security_group_ids" {
  type        = list(string)
  default     = ["sg-031cee00d0e73d740"]
  description = "List of security group IDs"
}


variable "subnet_id" {   # Use a valid variable name
  type    = string
  default = "subnet-0a6f1c9704ca109db"
}