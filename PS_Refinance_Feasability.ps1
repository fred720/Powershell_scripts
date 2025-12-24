<#Here is a complete PowerShell script to calculate the break-even point.

### How it works
This script uses the standard **Amortization Formula** to calculate the monthly payments for both interest rates.
It then determines the monthly savings and divides the total closing costs by that savings amount to find how long
it takes to recover the costs.

### The Script (`Calculate-BreakEven.ps1`)

You can save the following code into a file named `Calculate-BreakEven.ps1` or simply paste it into your
PowerShell terminal.#>


<#
.SYNOPSIS
    Calculates the Break-Even point for a loan refinance.

.DESCRIPTION
    This script calculates the monthly principal and interest payments for two different
    interest rates based on a specific principal amount. It then determines how many
    months/years it will take to recover the closing costs (Break-Even Point).

.NOTES
    Formula: M = P [ i(1 + i)^n ] / [ (1 + i)^n – 1 ]
#>

#>

function Get-MonthlyPayment {
    param (
        [double]$Principal,
        [double]$AnnualRatePercent,
        [int]$Years
    )

    if ($AnnualRatePercent -eq 0) { return $Principal / ($Years * 12) }

    $MonthlyRate = ($AnnualRatePercent / 100) / 12
    $TotalMonths = $Years * 12

    # Amortization Formula
    $Payment = $Principal * ($MonthlyRate * [Math]::Pow((1 + $MonthlyRate), $TotalMonths)) / ([Math]::Pow((1 +
$MonthlyRate), $TotalMonths) - 1)

    return $Payment
}

Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    MORTGAGE REFINANCE BREAK-EVEN CALC    " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Gather Inputs
try {
    $Principal   = [double](Read-Host "Enter Loan Principal Amount (e.g. 300000)")
    $CurrentRate = [double](Read-Host "Enter Current Interest Rate % (e.g. 6.5)")
    $NewRate     = [double](Read-Host "Enter New Interest Rate %     (e.g. 5.5)")
    $LoanTerm    = [int](Read-Host    "Enter Loan Term in Years      (e.g. 30)")
    $ClosingCosts= [double](Read-Host "Enter Total Closing Costs     (e.g. 4000)")
}
catch {
    Write-Error "Invalid input. Please enter numbers only."
    exit
}

# 2. Validation
if ($NewRate -ge $CurrentRate) {
    Write-Warning "The new rate is higher than or equal to the current rate. There is no break-even point."
    exit
}

# 3. Calculate Monthly Payments
$OldMonthlyPayment = Get-MonthlyPayment -Principal $Principal -AnnualRatePercent $CurrentRate -Years $LoanTerm
$NewMonthlyPayment = Get-MonthlyPayment -Principal $Principal -AnnualRatePercent $NewRate -Years $LoanTerm

# 4. Calculate Savings
$MonthlySavings = $OldMonthlyPayment - $NewMonthlyPayment

# 5. Calculate Break Even
$MonthsToBreakEven = $ClosingCosts / $MonthlySavings
$YearsToBreakEven = $MonthsToBreakEven / 12

# 6. Output Results
Write-Host ""
Write-Host "---------------- RESULTS ----------------" -ForegroundColor Green
Write-Host "Old Monthly Payment: " -NoNewline
Write-Host ("{0:C2}" -f $OldMonthlyPayment) -ForegroundColor Yellow

Write-Host "New Monthly Payment: " -NoNewline
Write-Host ("{0:C2}" -f $NewMonthlyPayment) -ForegroundColor Yellow

Write-Host "Monthly Savings:     " -NoNewline
Write-Host ("{0:C2}" -f $MonthlySavings) -ForegroundColor Cyan
Write-Host "-----------------------------------------" -ForegroundColor Green

Write-Host "Break-Even Point:" -ForegroundColor White
Write-Host ("{0:N1} Months" -f $MonthsToBreakEven) -ForegroundColor Magenta
Write-Host ("OR")
Write-Host ("{0:N2} Years" -f $YearsToBreakEven) -ForegroundColor Magenta

Write-Host ""
Write-Host "Note: This calculates Principal & Interest only (excludes taxes/insurance)." -ForegroundColor DarkGray
Write-Host ""
