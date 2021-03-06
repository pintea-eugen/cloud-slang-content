#   (c) Copyright 2015-2016 Hewlett-Packard Enterprise Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
########################################################################################################################
#!!
#! @description: Run Chef knife command and return filtered result.
#!
#! @input knife_cmd: knife command to run - Example: 'cookbook list'
#! @input knife_host: IP of server with configured knife accessable via SSH, can be main Chef server
#! @input knife_username: SSH username to access server with knife
#! @input knife_password: Optional - password to access server with knife
#! @input knife_privkey: Optional - path to local SSH keyfile for accessing server with knife
#! @input knife_timeout: Optional - timeout in milliseconds - Default: '300000'
#! @input knife_config: Optional - location of knife.rb config file - Default: ~/.chef/knife.rb
#!
#! @output raw_result: full STDOUT
#! @output knife_result: filtered output of knife command
#! @output standard_err: any STDERR
#!
#! @result SUCCESS: filtered result returned successfully
#! @result FAILURE: something went wrong while running knife command
#!!#
########################################################################################################################

namespace: io.cloudslang.chef

imports:
  ssh: io.cloudslang.base.ssh

flow:
  name: knife_command

  inputs:
    - knife_cmd
    - knife_host
    - knife_username
    - knife_password:
        required: false
        sensitive: true
    - knife_privkey:
        required: false
    - knife_timeout:
        default: '300000'
    - knife_config:
        default: '~/.chef/knife.rb'

  workflow:
    - knife_cmd:
        do:
          ssh.ssh_command:
            - host: ${knife_host}
            - username: ${knife_username}
            - password: ${knife_password}
            - privateKeyFile: ${knife_privkey}
            - command: >
                ${'echo [knife output] &&' +
                'knife ' + knife_cmd + ' --config ' + knife_config}
            - timeout: ${knife_timeout}
        publish:
          - return_result
          - standard_err
          - return_code
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE

  outputs:
    - raw_result: ${return_result}
    - knife_result: ${standard_err + ' ' + return_result.split('[knife output]')[1] if return_result else ""}
    - standard_err

  results:
    - SUCCESS
    - FAILURE
