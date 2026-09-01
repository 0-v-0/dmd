$path = Join-Path (Get-Location) 'generated/windows/release/64/sc.ini'
$bs = [char]92
$up = $bs + '..' + $bs + '..' + $bs + '..' + $bs + '..' + $bs + '..'
$lines2 = @(
  '[Environment]',
  ('DFLAGS="-I%@P%' + $up + $bs + 'druntime' + $bs + 'src" "-I%@P%' + $up + $bs + 'compiler' + $bs + 'src"'),
  ('LIB="%@P%' + $up + $bs + 'dmd2' + $bs + 'windows' + $bs + 'lib64"'),
  '',
  '[Environment32]',
  'DFLAGS=%DFLAGS% -L/OPT:NOICF',
  '',
  '[Environment64]',
  'DFLAGS=%DFLAGS% -L/OPT:NOICF'
)
[System.IO.File]::WriteAllLines($path, $lines2, [System.Text.Encoding]::ASCII)
