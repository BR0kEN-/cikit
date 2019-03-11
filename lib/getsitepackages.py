import site

if hasattr(site, 'getsitepackages'):
    print(site.getsitepackages())
else:
    # If "site" module has no "getsitepackages" function then most probably Python is running inside of "virtualenv".
    # - https://github.com/pypa/virtualenv/issues/355
    # - https://github.com/SFTtech/openage/pull/1031
    # - https://github.com/dmlc/tensorboard/issues/38#issuecomment-343017735
    from distutils.sysconfig import get_python_lib

    print([get_python_lib()])
