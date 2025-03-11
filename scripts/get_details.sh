. ./_utils.sh

subheading "Enter email"
echo "Your email:"
read -r YOUR_EMAIL

refresh_header

subheading "Verify details"

echo "Email: ${color_yellow}$YOUR_EMAIL${color_reset}"

get_consent "Are your details correct?"
if ! has_consent; then
  e_failure "Please rerun script and set the details correctly"
  killall caffeinate
  exit 0
fi

export YOUR_EMAIL
