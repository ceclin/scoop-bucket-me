$py = Join-Path -Resolve -Path $PSScriptRoot -ChildPath "main.py";
python $py $args;
