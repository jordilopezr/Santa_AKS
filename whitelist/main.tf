locals  {
  ip_whitelist = distinct(compact(concat(local.onprem_egress_ip,local.spn_api,local.campus_proxy,local.vpn,local.umbrella,local.proxy_san,local.europe,local.netskope)))
  ip_whitelist_name_rule = (compact(concat(local.name_rule)))
  ip_whitelist_start_rule = (compact(concat(local.start_ip_address)))
  ip_whitelist_end_rule = (compact(concat(local.end_ip_address)))
}
