variable "cluster_name" {
    description = "Cluster Name"
    type = string
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