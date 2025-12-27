
  { script-arguments: argv, script-arguments-count: argc, script-usage, exit } = dependency 'os.shell.Script'
  { stderr-lines } = dependency 'os.shell.IO'
  { get-service-manager } = dependency 'Services'
  { serialize-objects } = dependency 'value.string.AsciiSeparators'
  { stderr-lines, stdout } = dependency 'os.shell.IO'
  { is-empty-array } = dependency 'value.Array'
  { value-or-error } = dependency 'prelude.error.Value'

  gmail = get-service-manager!get-service 'gmail'

  errorlevel = 1 ; if argc < 2 => stderr-lines script-usage gmail.get-service-usage! ; exit errorlevel

  [ resource, command, ...args ] = argv

  gmail.invoke-resource-command-with-args resource, command, args

  errorlevel++ ; { error, value: results } = value-or-error -> gmail.invoke-resource-command-with-args resource, command, args
  if error isnt void => stderr-lines [ error.message ] ; exit errorlevel

  stdout serialize-objects results unless is-empty-array results



