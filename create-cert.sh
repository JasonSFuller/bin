#!/bin/bash -e

# Further reading:
#   - https://www.sslshopper.com/article-most-common-openssl-commands.html
#   - https://wiki.openssl.org/index.php/Manual:Req(1)

################################################################################

# If no arguments have been supplied, show usage info.
if [[ -z "$*" ]]; then
  # IMPORTANT: Here documents (the lines between the `cat` EOF blocks) *REQUIRE*
  #   the start of the line be _literal_ tab characters.  If changing this file,
  #   make *SURE* your editor doesn't convert them to spaces.
  cat <<- EOF
		DESCRIPTION:
		  Generate a private key, a CSR template (first time only; reused afterwards).
		  Generate a CSR and a self-signed public certificate (renewed occasionally).
		  The first hostname (required) will be the common name (CN), and any subsequent
		  hostnames will be used as alternate DNS names.
		USAGE:
		  $(basename "$0") fully.qualified.domain.com [host1 host2 ...]
		EOF
  exit 1
fi

# Check the arguments by looking them up in DNS, and if they come back okay,
# load the appropriate variables.
for host in "$@"
do
  if host "$host" >/dev/null 2>&1; then
    if [[ -z "$cn" ]]; then cn="$host"; else altnames+=("$host"); fi
  else
    echo "ERROR: hostname ($host) doesn't appear to be in DNS"
    exit 1
  fi
done

################################################################################

# These are the files we're using and/or potentially generating.
key="${cn}.key" # private key
cfg="${cn}.cfg" # CSR template
csr="${cn}.csr" # cert signing req
crt="${cn}.crt" # public cert

# What time is it?  (Used for naming backup files.)
now=$(date +%Y%m%d%H%M%S)

# Create the private key, if you don't already have one
if [[ ! -f "$key" ]]; then
  openssl genrsa -out "$key" 4096
  chmod 0600 "$key"
fi

# Verify it's a valid private key.
openssl rsa -check -noout -in "$key"

# If no config exists, create one (otherwise we'll use the existing one).
if [[ ! -f "$cfg" ]]; then
  # Try to gather some more info about the user to stick in the OUs.
  # NOTE: OU length must be limited to 64 characters.
  ou="IT Infrastructure" # default
  user=$(whoami)
  host=$(hostname -f)
  if [[ -n "$SUDO_USER" ]]; then user+="(${SUDO_USER})"; fi
  if [[ -n "$user" ]]; then ou=$(printf "%.64s" "${user}@${host}"); fi

  # Create the base CSR template (config).
  # IMPORTANT: Here documents (the lines between the `cat` EOF blocks) *REQUIRE*
  #   the start of the line be _literal_ tab characters.  If changing this file,
  #   make *SURE* your editor doesn't convert them to spaces.
  cat <<- EOF > "$cfg"
		[ req ]
		default_bits       = 4096
		prompt             = no
		default_md         = sha256
		req_extensions     = req_extensions
		distinguished_name = distinguished_name

		[ distinguished_name ]
		C                  = US
		ST                 = Ohio
		L                  = Cleveland
		O                  = Example, Co.
		OU                 = $ou
		emailAddress       = admin@example.com
		CN                 = $cn

		[ req_extensions ]
		subjectAltName     = @alternate_names

		[ alternate_names ]
		DNS.0 = $cn
		EOF

  # Add the alternate DNS hostnames to the template.
  for ((i=0; i<${#altnames[*]}; i++))
  do echo "DNS.$((i+1)) = ${altnames[i]}" >> "$cfg"
  done
fi

# If a CSR already exists, don't overwrite it.
if [[ -f "$csr" ]]; then
  echo "Found existing CSR; creating backup '${csr}.${now}.backup' and generating a new one."
  mv "$csr" "${csr}.${now}.backup"
fi

# Create the CSR to be sent to your CA for signing.  This is the same command
# you'll use if your public certificate has expired, and you need to renew.
openssl req -new -config "$cfg" -key "$key" -out "$csr"

# Create a one year self-signed public certificate, if none exists, just in
# case it's all you need.  If you need the public certificate to be signed
# (so your user's browser does not issue warnings), simply replace this
# auto-generated public certificate with the one issued/signed by your CA.
if [[ -f "$crt" ]]; then
  skipcrt=1
else
  openssl req -x509 -days 365 -key "$key" -in "$csr" -out "$crt"
fi

# Show the user what you did.
echo '--------------------------------------------------------------------------------'
echo "Common name                       = $cn"
for ((i=0; i<${#altnames[*]}; i++))
do echo "Alternate DNS name                = ${altnames[i]}"
done
echo '--------------------------------------------------------------------------------'
echo "Private key                       = $key"
echo "CSR template                      = $cfg"
echo "CSR (certificate signing request) = $csr"
if [[ $skipcrt -eq 1 ]]; then
  echo "Public certificate (self-signed)  = [[ skipped, already exists ]]"
else
  echo "Public certificate (self-signed)  = $crt"
fi
echo '--------------------------------------------------------------------------------'
echo 'You can view/verify details for each with:'
echo "  openssl rsa  -text -noout -check  -in '$key' # private key"
echo "  openssl req  -text -noout -verify -in '$csr' # csr"
echo "  openssl x509 -text -noout         -in '$crt' # public cert"
echo "  openssl verify                        '$crt' # public cert"
