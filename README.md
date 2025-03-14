# WindowRescuer

A simple PowerShell utility to rescue windows that are stuck off-screen after disconnecting monitors or changing display settings.

![image](https://github.com/user-attachments/assets/03e2e16c-cd89-4866-8f04-cac9ff05c357)


## Features

- Lists all open windows on your system
- Allows searching by window title
- Moves the selected window to a visible position (100,100) on your screen
- Preserves the window's original size

## Usage

### Option 1: Run directly in PowerShell

1. Download `WindowRescuer.ps1`
2. Right-click the file and select "Run with PowerShell"
   - If you get a security warning, you may need to run: `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process`
3. Search for your lost window by name (e.g., "Plex")
4. Select it and click "Reset Window Position"

### Option 2: Run in PowerShell ISE (Recommended for novices)

1. Press Start, type "PowerShell ISE" and run it as Administrator
2. Open a new tab (File → New)
3. Copy and paste the entire script code into the new tab
4. Press F5 or click the green "Run Script" button
5. Follow the on-screen instructions

This copy-paste method helps bypass security restrictions that might prevent the script from running.

## Troubleshooting

- **How to download a file from Github**: In the list of files at the top of this page, select `WindowRescuer.ps1`. In the page it opens, look for the download button a the top right. This will always be the most up to date version.
![image](https://github.com/user-attachments/assets/f0d3f412-78db-4cc8-ba4d-97306968aa09)

- **"Running scripts is disabled on this system"**: Run PowerShell as Administrator and enter:
  ```
  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
  ```
  Then try running the script again. For more information, please conduct your own research online. Powershell permissions issues can be complicated and are outside of the scope of this repository.

- **Window still not showing**: Some applications might need to be restarted to properly reset their position.

## License

Copyright © Lou Bernardi 2025

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
