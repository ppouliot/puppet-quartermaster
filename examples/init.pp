if $virtual == 'docker' {
  include dummy_service
}

class{'quartermaster':}
