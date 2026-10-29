import nbformat

def _exec_ipynb(filename, params):
    script = nbformat.read(filename, as_version=4)
    code   = '\n'.join(x.source for x in script.cells if x.cell_type=='code')
    exec(code, params)

_exec_ipynb('script.ipynb', params={})