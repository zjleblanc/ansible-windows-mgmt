class TestModule(object):

    def tests(self):
        return {
            'pve_local_ip': self.is_with_local_ip_test,
        }

    def is_with_local_ip_test(self, result):
        ip_addresses = result[0].get('ip-addresses')
        if ip_addresses and len(ip_addresses):
            for entry in ip_addresses:
                if entry.get('ip-address-type', 'UNK') == 'ipv4':
                    return entry.get('ip-address').startswith('192.168')
        return False