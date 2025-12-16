
  { script-arguments: argv, script-arguments-count: argc, script-usage, script-folderpath, exit } = dependency 'os.shell.Script'
  { stderr-lines } = dependency 'os.shell.IO'
  { try-read-objectfile, try-write-objectfile } = dependency 'os.filesystem.ObjectFile'
  { build-path } = dependency 'os.filesystem.Path'
  { try-read-textfile-lines } = dependency 'os.filesystem.TextFile'
  { get-tokens-info-status, try-get-refresh-tokens-response } = dependency 'google.OAuth'

  errorlevel = 1 ; if argc is 0 => stderr-lines script-usage [ '<service>', '', 'Where <service> can be any of bla bla' ] ; exit errorlevel

  [ service ] = argv

  tokens-filepath = build-path [ script-folderpath, "#service.tokens" ]

  errorlevel++ ; { error, value: tokens-info } = try-read-objectfile tokens-filepath
  if error isnt void => stderr-lines [ "Unable to read tokens file.", error.message ] ; exit errorlevel

  { is-valid, time-left-minutes } = get-tokens-info-status tokens-info
  if is-valid => WScript.Echo "Token still valid for #time-left-minutes minutes." ; exit 0

  { refresh-token } = tokens-info

  errorlevel++ ; { error, value: creds } = try-read-objectfile build-path [ script-folderpath, "#service.creds" ]
  if error isnt void => stderr-lines [ "Unable to read creds file.", error.message ] ; exit errorlevel

  { client-id, client-secret } = creds

  errorlevel++ ; { error, value: refresh-tokens-response } = try-get-refresh-tokens-response client-id, client-secret, refresh-token
  if error isnt void => stderr-lines [ error.message ] ; exit errorlevel

  current-time = new Date!get-time!
  updated-tokens-info = tokens-info <<< refresh-tokens-response <<< { created-at: current-time }

  errorlevel++ ; { error } = try-write-objectfile tokens-filepath, updated-tokens-info
  if error isnt void => stderr-lines [ "Unable to write to tokens file.", error.message ] ; exit errorlevel

  WScript.Echo "Tokens refreshed successfully."
