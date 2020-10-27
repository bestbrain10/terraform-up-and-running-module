variable "cluster_name" {
    description = "Cluster Name"
    type = string
}

variable "db_remote_state_bucket" {
    description = "DB Remote State State"
    type = string
}

variable "db_remote_state_key" {
    type = string
    description = "Path for DB remote state"
}

variable "instance_type" {
    type = string
    description = "The type of EC2 Instance to run"
}

variable "min_size" {
    description = "ASG Minimum instances"
    type = number
}

variable "max_size" {
    description = "ASG Maximum instances"
    type = number
}