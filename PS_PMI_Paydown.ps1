# PMI Deletion Calculator
Write-Host "--- Mortgage PMI Deletion Calculator ---" -ForegroundColor Cyan

function Read-PositiveDouble {
    param ($Prompt)

    while ($true) {
        # FIX: Initialize the variable so the [ref] has a target to point to
        $value = 0 
        
        $userInput = Read-Host $Prompt
        
        # We use $userInput here to avoid conflict with the $value variable
        if ([double]::TryParse($userInput, [ref]$value) -and $value -gt 0) {
            return [double]$value
        }
        
        Write-Host "Please enter a valid positive number." -ForegroundColor Red
    }
}

# Gather validated user inputs
$originalPrice  = Read-PositiveDouble "Enter the Original Purchase Price (or Current Appraised Value)"
$currentBalance = Read-PositiveDouble "Enter your Current Loan Balance"

# Calculate LTV and Targets
$currentLTV = ($currentBalance / $originalPrice) * 100
$target80   = $originalPrice * 0.80
$target78   = $originalPrice * 0.78

# Calculate required paydown (never negative)
$paydownTo80 = [math]::Max(0, $currentBalance - $target80)
$paydownTo78 = [math]::Max(0, $currentBalance - $target78)

# Output Results
Write-Host "`nResults:" -ForegroundColor Yellow
Write-Host "---------------------------------------"
Write-Host ("Current LTV Ratio: {0:N2}%" -f $currentLTV)

if ($currentLTV -le 78) {
    Write-Host "STATUS: Eligible for AUTOMATIC termination (LTV ≤ 78%)." -ForegroundColor Green
}
elseif ($currentLTV -le 80) {
    Write-Host "STATUS: Eligible to REQUEST cancellation (LTV ≤ 80%)." -ForegroundColor Blue
}
else {
    Write-Host "STATUS: Not yet eligible for PMI removal." -ForegroundColor Red
    Write-Host ("To reach 80% LTV, you need to pay down: {0:C2}" -f $paydownTo80)
    Write-Host ("To reach 78% LTV, you need to pay down: {0:C2}" -f $paydownTo78)
}

Write-Host "---------------------------------------"
Write-Host ("Target Balance for 80%: {0:C2}" -f $target80)
