class FilterModule(object):

    def filters(self):
        return { "codify": self.do_codify }

    def do_codify(self, content):
        return '[code]<pre>' + content.replace('\n','<br>') + '</pre>[/code]'