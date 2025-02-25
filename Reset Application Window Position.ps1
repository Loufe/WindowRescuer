Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll")]
    public static extern int GetWindowTextLength(IntPtr hWnd);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool IsWindowVisible(IntPtr hWnd);
    
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
}

[StructLayout(LayoutKind.Sequential)]
public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
}
"@

# Add Windows Forms for the input dialog
Add-Type -AssemblyName System.Windows.Forms

# Create a class to hold window information
class WindowInfo {
    [IntPtr]$Handle
    [string]$Title

    WindowInfo([IntPtr]$h, [string]$t) {
        $this.Handle = $h
        $this.Title = $t
    }

    [string]ToString() {
        return $this.Title
    }
}

# Global array to store window information
$script:allWindowsList = New-Object System.Collections.ArrayList

# Function to get window title
function Get-WindowTitle($hWnd) {
    $length = [Win32]::GetWindowTextLength($hWnd)
    if ($length -le 0) { return $null }
    
    $sb = New-Object System.Text.StringBuilder($length + 1)
    [void][Win32]::GetWindowText($hWnd, $sb, $sb.Capacity)
    return $sb.ToString()
}

# Callback for EnumWindows
$enumWindowsCallback = {
    param($hWnd, $lParam)
    
    if ([Win32]::IsWindowVisible($hWnd)) {
        $title = Get-WindowTitle $hWnd
        if ($title -and $title.Trim() -ne "") {
            $window = [WindowInfo]::new($hWnd, $title)
            [void]$script:allWindowsList.Add($window)
        }
    }
    
    return $true
}

# Create the Windows Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Reset Window Position"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = "CenterScreen"

# Create a label
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 10)
$label.Size = New-Object System.Drawing.Size(580, 40)
$label.Text = "Select a window from the list below, or enter a partial window title to search for:"
$form.Controls.Add($label)

# Create a textbox for search
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 50)
$textBox.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($textBox)

# Create a search button
$searchButton = New-Object System.Windows.Forms.Button
$searchButton.Location = New-Object System.Drawing.Point(480, 50)
$searchButton.Size = New-Object System.Drawing.Size(100, 23)
$searchButton.Text = "Search"
$form.Controls.Add($searchButton)

# Create a listbox for window selection
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 80)
$listBox.Size = New-Object System.Drawing.Size(560, 230)
$listBox.DisplayMember = "Title"
$listBox.ValueMember = "Handle"
$form.Controls.Add($listBox)

# Create a button to reset the window position
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Location = New-Object System.Drawing.Point(370, 320)
$resetButton.Size = New-Object System.Drawing.Size(200, 30)
$resetButton.Text = "Reset Window Position"
$resetButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($resetButton)

# Create a cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(10, 320)
$cancelButton.Size = New-Object System.Drawing.Size(200, 30)
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.Controls.Add($cancelButton)

# Function to populate the list box
function Populate-ListBox {
    param (
        [string]$searchText = ""
    )
    
    $listBox.Items.Clear()
    
    foreach ($window in $script:allWindowsList) {
        if ($searchText -eq "" -or $window.Title -like "*$searchText*") {
            [void]$listBox.Items.Add($window)
        }
    }
}

# Set up search button click event
$searchButton.Add_Click({
    $searchText = $textBox.Text.Trim()
    Populate-ListBox -searchText $searchText
})

# Also allow searching when pressing Enter in the textbox
$textBox.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
        $searchText = $textBox.Text.Trim()
        Populate-ListBox -searchText $searchText
        $e.SuppressKeyPress = $true  # Prevent the "ding" sound
        $e.Handled = $true  # Prevent the dialog from closing
    }
})

# Ensure the textbox has focus at start
$form.Add_Shown({
    $textBox.Focus()
})

# Set only the cancel button, not the accept button
# This allows our textbox KeyDown event to handle Enter key instead
$form.CancelButton = $cancelButton

# Collect all window information
[Win32]::EnumWindows($enumWindowsCallback, [IntPtr]::Zero)

# Initial population of the list box
Populate-ListBox

# Show the form
$result = $form.ShowDialog()

# Process the result
if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $listBox.SelectedItem) {
    $selectedWindow = $listBox.SelectedItem
    $hWnd = $selectedWindow.Handle
    
    # Get the current window size
    $rect = New-Object RECT
    [Win32]::GetWindowRect($hWnd, [ref]$rect)
    
    $width = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top
    
    Write-Host "Window: $($selectedWindow.Title)"
    Write-Host "Current position: Left=$($rect.Left), Top=$($rect.Top), Width=$width, Height=$height"
    
    # Move window to a visible position (100,100) and maintain its size
    [Win32]::MoveWindow($hWnd, 100, 100, $width, $height, $true)
    
    # Show success message
    [System.Windows.Forms.MessageBox]::Show(
        "Window '$($selectedWindow.Title)' has been moved to position (100,100)",
        "Success",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
} else {
    Write-Host "Operation canceled or no window selected."
}