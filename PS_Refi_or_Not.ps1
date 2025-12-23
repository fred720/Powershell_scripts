
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

function Get-MonthlyPayment {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateRange(1.0, [double]::MaxValue)]
        [double]$Principal,

        [Parameter(Mandatory=$true)]
        [ValidateRange(0.0, [double]::MaxValue)]
        [double]$AnnualRatePercent,

        [Parameter(Mandatory=$true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Years
    )

    if ($AnnualRatePercent -eq 0) {
        return $Principal / ($Years * 12)
    }

    $MonthlyRate = ($AnnualRatePercent / 100) / 12
    $TotalMonths = $Years * 12

    # Amortization Formula (Cleaned up for readability)
    # We can break lines inside parentheses without backticks
    $OnePlusRatePow = [Math]::Pow((1 + $MonthlyRate), $TotalMonths)

    $Payment = $Principal *
               (($MonthlyRate * $OnePlusRatePow) /
               ($OnePlusRatePow - 1))

    return $Payment
}
function Get-ValidNumber {
    param (
        [string]$Prompt,
        [string]$TypeName, # Accepts "double" or "[double]" as a string
        [double]$MinValue = 0
    )

    # 1. Clean the string (remove brackets if present) and convert to a real Type object
    # This turns "[double]" into "double", then into the [double] type
    $TargetType = ($TypeName -replace '[\[\]]') -as [Type]

    do {
        try {
            $inputStr = Read-Host $Prompt

            # 2. Use the Type object to parse the string input
            $value = $TargetType::Parse($inputStr)

            if ($value -le $MinValue) {
                Write-Warning "Value must be greater than $MinValue. Please try again."
            }
            else {
                return $value
            }
        }
        catch {
            Write-Warning "Invalid input. Please enter a numeric value."
        }
    } while ($true)
}

Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    MORTGAGE REFINANCE BREAK-EVEN CALC    " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Gather Inputs (Using helper function for robustness)
$Principal   = Get-ValidNumber -Prompt "Enter Loan Principal Amount (e.g. 300000)" -Type [double] -MinValue 0
$CurrentRate = Get-ValidNumber -Prompt "Enter Current Interest Rate % (e.g. 6.5)" -Type [double] -MinValue 0
$NewRate     = Get-ValidNumber -Prompt "Enter New Interest Rate %     (e.g. 5.5)" -Type [double] -MinValue 0
$LoanTerm    = Get-ValidNumber -Prompt "Enter Loan Term in Years      (e.g. 30)" -Type [int] -MinValue 0
$ClosingCosts= Get-ValidNumber -Prompt "Enter Total Closing Costs     (e.g. 4000)" -Type [double] -MinValue 0

# 2. Logic Validation
if ($NewRate -ge $CurrentRate) {
    Write-Warning "The new rate is higher than or equal to the current rate. There is no financial benefit to
refinance."
    # Optional: Read-Host "Press Enter to exit"
    return
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
Write-Host "OR" -ForegroundColor DarkGray
Write-Host ("{0:N2} Years" -f $YearsToBreakEven) -ForegroundColor Magenta

Write-Host ""
Write-Host "Note: This calculates Principal & Interest only (excludes taxes/insurance)." -ForegroundColor DarkGray
Write-Host ""
