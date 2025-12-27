
  { script-arguments: argv, script-arguments-count: argc, script-folderpath, script-usage, exit } = dependency 'os.shell.Script'
  { stderr-lines } = dependency 'os.shell.IO'
  { try-read-objectfile } = dependency 'os.filesystem.ObjectFile'
  { build-path } = dependency 'os.filesystem.Path'
  { get-tokens-info-status } = dependency 'google.OAuth'

  errorlevel = 1 ; if argc is 0 => stderr-lines script-usage [ '<service>' ] ; exit errorlevel

  [ service ] = argv

  errorlevel++ ; { error, value: tokens-info } = try-read-objectfile build-path [ script-folderpath, "#service.tokens" ]
  if error isnt void => stderr-lines [ "Unable to read tokens file", error.message ] ; exit errorlevel

  { is-expired, is-expiring-soon, is-valid, time-left-minutes, minutes-expired } = get-tokens-info-status tokens-info

  status = switch

    | is-expired => "EXPIRED #{minutes-expired} minutes ago"
    | is-expiring-soon => "EXPIRING #{time-left-minutes} minutes remaining"
    | is-valid => "VALID #{time-left-minutes} minutes remaining"

  WScript.Echo "Token #status"
