$py = Join-Path -Resolve -Path $PSScriptRoot -ChildPath "app.py";
python $py $args;
