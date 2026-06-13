locals {
  double_numbers = [for num in var.numbers_list : num * 2]
  first_names    = [for person in var.objects_list : person.first_name]
  full_names = [
    for person in var.objects_list : "${person.first_name} ${person.last_name}"
  ]
}