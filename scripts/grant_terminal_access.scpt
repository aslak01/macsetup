tell application "System Events"
        set theProcess to first process whose name is "Terminal"
        if exists theProcess then
                tell security preferences
                        try
                                authorize
                                set theUIElement to first UI element of scroll area 1 of group 1 of window "Privacy & Security" whose title is "Full Disk Access"
                                if exists theUIElement then
                                        set theRow to first row of table 1 of scroll area 1 of group 1 of window "Privacy & Security" whose value of static text 1 is "Terminal"
                                        if exists theRow then
                                                set theCheckbox to first checkbox of theRow
                                                if value of theCheckbox is 0 then
                                                        click theCheckbox
                                                end if
                                        else
                                                -- Terminal is not in the list, so we need to add it.
                                                click button "+" of scroll area 1 of group 1 of window "Privacy & Security"
                                                delay 1 -- Give the open dialog time to appear. Adjust if necessary.
                                                tell application "System Events"
                                                        tell process "System Preferences"
                                                                set frontmost to true
                                                                keystroke "g" using {command down, shift down}
                                                                delay 0.5
                                                                keystroke "/Applications/Utilities/Terminal.app"
                                                                delay 0.5
                                                                keystroke return
                                                                delay 1 -- Give the open dialog time to process the path.
                                                                keystroke return -- press open button
                                                        end tell
                                                end tell

                                        end if

                                end if
                                --close security preferences window
                                close window "Privacy & Security"
                        on error errMsg
                                display dialog "An error occurred: " & errMsg buttons {"OK"} default button "OK"
                        end try
                end tell
        else
                display dialog "Terminal is not running." buttons {"OK"} default button "OK"
        end if
end tell
