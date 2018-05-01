# cpanel_access_logs_summary

Short script that summarizes the access logs for every cPanel user separately

This includes:
- POST requests
- GET requests
- IP logs and their geo location
First the function loops through all cPanel users and then summarizes their access logs

Note: You need root access to the server so that the script could grab all of the access logs for each account.

If you do not have root access you might want to take a look at this script here instead:

[Summarize a specific log](https://github.com/bobbyiliev/quick_access_logs_summary/)

Usage:

- Download the script

- Make it executable
```
chmod +x spike_check
```
- Run:
```
./spike_check
```

For more information you can check out this blog post here:

[Blog Post](https://bobbyiliev.com/blog/bash-script-will-summarize-access-logs-check-caused-spike-server/)
