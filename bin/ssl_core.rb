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

def generateCsr(cname, org, country, output)
  if runPlaybook("generate_csr.yaml", {"cname": cname, "org": org, "country": country, "key": "/etc/ssl/nginx/key.pem", "out": output })
    appendLogFile("generateCsr(#{cname}, #{org}, #{country})",'')
    return true
  else
    quietError("generateCsr(#{cname}, #{org}, #{country})",'')
    return false
  end
end

def generateSelfSignCert()
  if runPlaybook("selfsign_cert.yaml", {"key": "/etc/ssl/nginx/key.pem", "cname": "appliance.alces.network", "org": "Alces Flight", "country": "GB", "crt_out": "/etc/ssl/nginx/fullchain.pem"})
    appendLogFile("generateSelfSignCert()",'')
    return true
  else
    quietError("generateSelfSignCert()",'')
    return false
  end
end

def replaceCert(cert)
  if runPlaybook("install_cert.yaml", {"cert": cert, "dest": "/etc/ssl/nginx/fullchain.pem", "key": "/etc/ssl/nginx/key.pem"})
    appendLogFile("replaceCert()",'')
    return true
  else
    quietError("replaceCert()",'')
    return false
  end
end
