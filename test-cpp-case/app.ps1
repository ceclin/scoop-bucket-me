param (
    [Parameter(
        Position = 0,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Path to executable file.")]
    [Alias("exe")]
    [ValidateNotNullOrEmpty()]
    [string]
    $Executable = $( $WaitBeforeExit = $true; Read-Host -Prompt "Input path to executable file" ),
    [Parameter(
        Position = 0,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Path to test case directory.")]
    [Alias("tcd")]
    [ValidateNotNullOrEmpty()]
    [string]
    $TestCaseDir = $( $WaitBeforeExit = $true; Read-Host -Prompt "Input path to test case directory"  )
)

try {
    $Executable = Resolve-Path $Executable
    $TestCaseDir = Resolve-Path $TestCaseDir
}
catch {
    Write-Error -ErrorAction Stop "Resolve-Path Error"
}

$InFiles = Get-ChildItem -File -Filter "*.in" -Path $TestCaseDir
$OutFiles = Get-ChildItem -File -Filter "*.out" -Path $TestCaseDir
foreach ($in in $InFiles) {
    $case = $in.Name.Substring(0, $in.Name.Length - 3)
    $temp = $case + ".out"
    $out = $OutFiles | Where-Object { $_.Name -eq $temp }
    if ($out.Count -eq 0) {
        Write-Host -ForegroundColor DarkYellow "Warning: Case $($case) has no corresponding .out file."
    }
    else {
        $expected = $out | Get-Content
        $TimeUsage = Measure-Command {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
            $actual = $in | Get-Content | & $Executable
        }

        $es = $expected -split "\s+"
        $as = $actual -split "\s+"
        $index = 0
        $flag = $true
        foreach ($item in $es) {
            if ($item -ne $as[$index]) {
                $flag = $false
                break
            }
            $index++
        }

        if ($flag) {
            Write-Host -ForegroundColor Green "Case $($case): OK. Time: $($TimeUsage.Milliseconds) ms."
        }
        else {
            Write-Host -ForegroundColor Red "Case $($case): Error!"
            Write-Host -ForegroundColor Blue "expected:"
            Write-Host $expected
            Write-Host -ForegroundColor Blue "actual:"
            Write-Host $actual
        }
    }
}

if ($WaitBeforeExit) {
    Read-Host -Prompt "Press any key to exit"
}
