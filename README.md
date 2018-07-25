# R - Download From Secured Cloud
#### Tested with secure WebDAV enabled server (Nextcloud)

| Complication                                         | Solution                                                          |
|------------------------------------------------------|-------------------------------------------------------------------|
| R does not inherently handle user credentials        | The package RCurl provides this support                           |
| R imports the file as a string | Download the file from the web address to a temp file then import |

