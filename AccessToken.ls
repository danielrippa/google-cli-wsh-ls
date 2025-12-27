
  do ->

    { create-error-context } = dependency 'prelude.error.Context'
    { script-folderpath } = dependency 'os.shell.Script'
    { tool } = dependency 'os.shell.Tool'
    { trim-whitespace } = dependency 'value.string.Whitespace'
    { string-as-words } = dependency 'value.string.Text'
    { try-read-objectfile } = dependency 'os.filesystem.ObjectFile'
    { build-path } = dependency 'os.filesystem.Path'

    { value-as-string } = dependency 'prelude.reflection.Value'

    { argtype, create-error } = create-error-context 'gmail-cli.AccessToken'

    get-service-access-token = (service-name) ->

      { errorlevel, stderr: error-message, stdout: output } = tool "tokenstatus.cmd", service-name
      if errorlevel isnt 0 => throw create-error "Unable to check Access Token status. #error-message"

      [ token, status ] = output |> trim-whitespace |> string-as-words

      switch status

        | 'EXPIRED' =>

          { errorlevel, stderr: error-message } = tool "refreshtoken.cmd", service-name
          if errorlevel isnt 0 => throw create-error "Unable to refresh Access Token. #error-message"

      { error, value: tokens-info } = try-read-objectfile build-path [ script-folderpath, "#service-name.tokens" ]
      if error isnt void => throw create-error "Unable to ready tokens file for service '#service-name'. #{ error.message }"

      { token-type, access-token } = tokens-info

      { token-type, access-token }

    {
      get-service-access-token
    }