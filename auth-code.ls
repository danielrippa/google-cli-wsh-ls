
  { script-arguments: argv, script-arguments-count: argc, sleep, script-folderpath, script-usage, exit } = dependency 'os.shell.Script'
  { stderr-lines, stderr-lf, stdout } = dependency 'os.shell.IO'
  { build-path } = dependency 'os.filesystem.Path'
  { try-read-objectfile, try-write-objectfile } = dependency 'os.filesystem.ObjectFile'
  { try-read-textfile-lines } = dependency 'os.filesystem.TextFile'
  { run } = dependency 'os.com.Shell'
  { try-get-clipboard-text, try-set-clipboard-text } = dependency 'os.shell.Clipboard'
  { get-auth-code-url, get-token-response-for-auth-code } = dependency 'google.OAuth'
  { string-repeat } = dependency 'value.String'

  { value-as-string } = dependency 'prelude.reflection.Value'

  errorlevel = 1 ; if argc is 0 => stderr-lines script-usage [ '<service>', '', 'Where <service> is a google service.',  'Valid service names are: gmail, calendar, tasks, drive, photos.' ] ; exit errorlevel

  [ service ] = argv

  errorlevel++ ; { error, value: creds } = try-read-objectfile build-path [ script-folderpath, "#service.creds" ]
  if error isnt void => stderr-lines [ "Unable to read creds file.", error.message ] ; exit errorlevel

  { client-id, client-secret } = creds

  errorlevel++ ; { error, value: scopes } = try-read-textfile-lines build-path [ script-folderpath, "#service.scopes" ]
  if error isnt void => stderr-lines [ "Unable to read scopes file.", error.message ] ; exit errorlevel

  WScript.Echo "Opening Authorization Code URL."

  run get-auth-code-url client-id, scopes

  #

  WScript.Echo "Waiting for the user to copy the Authorization Code."
  WScript.Echo ""

  auth-code = void ; attempts = 0 ; max-attempts = 60

  WScript.Echo "Attempts:"
  WScript.Echo ""

  WScript.Echo string-repeat '-', max-attempts

  try-set-clipboard-text ''

  loop

    attempts++ ; break if attempts > max-attempts

    stdout '.'

    { value: clipboard-text } = try-get-clipboard-text!
    if clipboard-text is '' => sleep 1000 ; continue

    auth-code = clipboard-text ; break

  WScript.Echo ""

  token-response = get-token-response-for-auth-code client-id, client-secret, auth-code

  created-at = new Date!get-time! ; token-response <<< { created-at }

  errorlevel++ ; { error } = try-write-objectfile (build-path [ script-folderpath, "#service.tokens" ]), token-response
  if error isnt void => stderr-lines [ "Unable to write to tokens file.", error.message ]

  WScript.Echo ""
  WScript.Echo "Successfully wrote tokens file."
