# 2FA-Backup-Sheet

Create backup sheets for any service where you use two-factor authentication (2FA)

Full | Minimal
:-------------------------:|:-------------------------:
<img src="sample-sheet-full.png?raw=true" alt="Full" width="300" /> | <img src="sample-sheet-minimal.png?raw=true" alt="Minimal" width="300" />

## Requirements

 * Unix
   * Bash
   * ImageMagick

## Usage

```bash
$ bash ./2fa-backup-sheet.sh \
    <TITLE> \
    <RECOVERY_CODES> \
    [<SUBTITLE> \
    [<DATE> \
    [<OTP_KEY_URI_QR_PATH> \
    [<FONT_PATH_REGULAR> \
    [<FONT_PATH_BOLD> \
    [<FONT_SCALE> \
    [<OUTPUT_FILE_PATH>]]]]]]]
```

### Examples

```bash
$ bash ./2fa-backup-sheet.sh \
    "Google" \
    "2589 0449\n5908 3492\n8491 4533\n2560 0808"

# or

$ bash ./2fa-backup-sheet.sh \
    "Twitter" \
    "3234 8651\n5962 8640\n2490 2239\n2873 6327\n5730 5927\n4371 8506\n9858 8718\n3884 9458\n9110 6833\n8815 4916" \
    "john.doe@example.com" \
    "" \
    "key-uri-qr-code-screenshot.png" \
    "RobotoMono-Regular.ttf" \
    "RobotoMono-Bold.ttf" \
    "75" \
    "backup-sheet-twitter.png"
```

### Security

Do *not* store the resulting backup sheets in the same place as your passwords, if such a place exists. For example, if you use a password manager to store your passwords, do *not* save your recovery codes or backup sheets there. Consider storing the backup sheets only in *printed form*, and put them in a safe place – perhaps even at two separate physical locations.

If you want to include a QR code representing the key URI, which includes the shared secret or seed, you may want to take a screenshot of the QR code shown to you by the service in question. If you save the QR code directly, e.g. in your web browser, a new code (and thus secret) *may* be generated, depending on the service and the software you use. After generating the backup sheet, delete the screenshot that you took.

## Contributing

All contributions are welcome! If you wish to contribute, please create an issue first so that your feature, problem or question can be discussed.

## License

This project is licensed under the terms of the [MIT License](https://opensource.org/licenses/MIT).
