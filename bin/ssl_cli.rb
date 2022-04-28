#!/usr/bin/env ruby
#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Appliance Menu.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Appliance Menu is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Appliance Menu. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Appliance Menu, please visit:
# https://github.com/alces-software/flight-appliance-menu
#==============================================================================

def ssl_cli()
  sel = $prompt.select('Choose an option') do |menu|
    menu.choice 'Create Certificate Signing Request', 'csr'
    menu.choice 'Replace Certificate', 'replace'
    menu.choice 'Generate Self-Signed', 'selfsign'
    menu.choice 'Return', 'ret'
  end
  case sel
  when 'csr'
    createCsrCli()
  when 'replace'
    replaceCertCli()
  when 'selfsign'
    selfSignCert()
  when 'ret'
    main()
  end
end

def createCsrCli()
  cname = $prompt.ask("Enter the FQDN for the appliance:", required: true)
  org = $prompt.ask("Enter your organisation:", required: true)
  country = $prompt.ask("Enter your country (2 letter code):")

  if generateCsr(cname, org, country, "/tmp/csr.out")
    csr = `cat /tmp/csr.out; rm -rf /tmp/csr.out 2>&1 > /dev/null`
    $prompt.ok("Generated CSR:")
    $prompt.say(csr)
  else
    $prompt.error("Failed CSR")
  end
end

def selfSignCert()
  yn = $prompt.yes?("Are you sure you wish to use a self-signed certificate?") do |q|
    q.default false
  end

  if yn
    if generateSelfSignCert()
      $prompt.ok("Certificate generated.")
    else
      $prompt.error("Failed to generate self-signed certifcate.")
    end
  end
end

def replaceCertCli()
  cert = $prompt.multiline("SSL Certificate: ", help: "(Paste SSL certificate here and press CTRL+D to end)")

  yn = $prompt.yes?("Are you sure you wish to use this certificate?") do |q|
    q.default false
  end

  if yn
    if replaceCert(cert.join())
      $prompt.ok("Replaced certificate.")
    else
      $prompt.error("Failed to replace certificate")
    end
  end
end
