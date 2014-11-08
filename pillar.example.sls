users:
  manage:
    root:
      password: $6$...
    john_doe:
      name: john
      shell: /bin/bash
      groups:
        - sudo
      password: $6$...
      sshpubkeys:
        - key: AAAAB3NzaC1yc2EAAAADAQABAAAEAQC4YsdZy1...
          comment: host1
        - key: AAAAB3NzaC1yc2EAAAADAQABAAAEAQDahbWStNaRV....
          comment: host2

groups:
  manage:
    lcwebs:
      system: True
      gid: 1337
