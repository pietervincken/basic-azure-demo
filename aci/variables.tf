variable "docker_username" {
  description = "Username used to pull image from docker hub"
  type = string
}

variable "docker_pat" {
  description = "Pat used to pull image from docker hub"
  type = string
}

variable "email" {
  description = "Email address of the owner of the resources"
  type = string 
}