class FilterModule(object):

    def filters(self):
        return { "extract_pve_local_ip": self.do_extract_pve_local_ip }

    def do_extract_pve_local_ip(self, result):
        ip_addresses = result[0].get('ip-addresses')
        if ip_addresses and len(ip_addresses):
            for entry in ip_addresses:
                if entry.get('ip-address-type', 'UNK') == 'ipv4':
                    return entry.get('ip-address')
        return None