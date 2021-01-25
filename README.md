# solarwinds-checkcertexpiration
This was inspired after a quick search of Thwack found nothing that would allow for an arbitrary certificate check.

There is nothing special about this, it is based on some powershell scripts I found in other locations.  This outputs 0 or 1.  Altering the exit code is left as an exercise to the reader (and me for the future).

## Requires
* newer version of SolarWinds, with working PowerShell (We are using v.2020.2.x on Windows)

## Setup:
1. create two custom properties of type "Application"  (there's probably a better way to do this)
  * `ServerName`
  * `ServerPort`
2. Create a new Application Monitor Template, and add a component of type `Windows Powershell Monitor` in SAM.
3. Paste the contents of the monitor into the script body.
3. Test-run the script (`Get Script Output`).  It will fail, but it should create a new statistics section called "Days Left" that will allow you to alter default thresholds.
4. Add the SAM check to an existing node, At the last step, you're given a chance to edit the Application Monitor before you create it.  This is one place where you can enter the `ServerName` and `ServerPort`.

*Note, I fully admit this is not great code, and has not been tested thoroughly.  It works in our environment, but you may experience different results.  Best of luck.*
