Add-Type -Path C:\Windows\Microsoft.NET\Framework64\v4.0.30319\WPF\UIAutomationClient.dll

# Utility true condition
$TrueCondition = [System.Windows.Automation.Condition]::TrueCondition

# Start a process
$Process = Start-Process "C:\Program Files\Microsoft Office\Office15\WINWORD.EXE" -PassThru
Start-Sleep -Seconds 5
# Build a ProcessID Property
$ProcessElement = [System.Windows.Automation.AutomationElement]::ProcessIdProperty
# Make a new condition to look for the process ID
$ProcessCondition = [System.Windows.Automation.PropertyCondition]::new($ProcessElement,$Process.Id)

# Build a 'Search Children' and 'Search all Descendants' option
$ChildrenTreeScope = [System.Windows.Automation.TreeScope]::Children
$DescendantsTreeScope = [System.Windows.Automation.TreeScope]::Descendants

# RootElement is static'd as the whole desktop
$ElementMainWindow = [System.Windows.Automation.AutomationElement]::RootElement

# Find our process window
$ProcessWindow = $ElementMainWindow.FindFirst($ChildrenTreeScope,$ProcessCondition)
Start-Sleep -Seconds 1
$ProcessWindowElements = $ProcessWindow.FindAll($DescendantsTreeScope,$TrueCondition)

# Make a control type property
$ControlTypeProperty = [System.Windows.Automation.AutomationElement]::LocalizedControlTypeProperty

# Make the button condition
$ButtonCondition = [System.Windows.Automation.PropertyCondition]::new($ControlTypeProperty,"button")
# Make an edit condition
$EditCondition = [System.Windows.Automation.PropertyCondition]::new($ControlTypeProperty,"edit")
# Make a hyperlink condition
$HLCondition = [System.Windows.Automation.PropertyCondition]::new($ControlTypeProperty,"Hyperlink")

#$buttonElements = $ProcessWindow.FindAll($DescendantsTreeScope,$ButtonCondition)

#$closeButton = $buttonElements | Where-Object -FilterScript {$_.Current.Name -like "*close*"}
# $closeButton.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).invoke()

## Word interaction
$NewBlank = $ProcessWindowElements | Where-Object -FilterScript {$_.Current.Name -like "*Blank document*"}
$NewBlank.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).invoke()
Start-Sleep -Seconds 5

# Updated Process
$Process = Get-Process -Name "WinWord"

# Make a new condition to look for the process ID
$ProcessCondition = [System.Windows.Automation.PropertyCondition]::new($ProcessElement,$Process.Id)

# Find our process window
$ProcessWindow = $ElementMainWindow.FindFirst($ChildrenTreeScope,$ProcessCondition)

$ProcessWindowElements = $ProcessWindow.FindAll($DescendantsTreeScope,$TrueCondition)

$Test = [System.Windows.Automation.TreeWalker]::new($TrueCondition)