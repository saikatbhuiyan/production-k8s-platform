variable "numbers_list" {
  type    = list(number)
  default = [1, 2, 3, 4]
}

variable "number_lists" {
  type    = list(list(number))
  default = [[1, 2], [3, 4]]
}

variable "numbers_map" {
  type = map(number)
  default = {
    one   = 1
    two   = 2
    three = 3
    four  = 4
  }
}

variable "objects_list" {
  type = list(object({
    first_name = string
    last_name  = string
  }))
  default = [
    {
      first_name = "Bob"
      last_name  = "Johnson"
    }
  ]
}

variable "users" {
  type = list(object({
    role     = string
    username = string
  }))
}

variable "map_of_strings" {
  type = map(string)
  default = {
    key1 = "value1"
    key2 = "value2"
  }
}

variable "user_to_output" {
  type = string
}